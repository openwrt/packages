// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.report: the read-only reports, ported from the shell scripts of
// the same names with their output unchanged.
//
//   summary()          the `summary` command: one row per active device, the
//                      LuCI table's 2-second poll. Spawns the reverse-DNS and
//                      netify refreshes detached; never waits for them
//   device(args)       `device <ip> [--rdns] [--proto P] [--max-bytes N]`: { reply, rc }
//   metrics(src)       `metrics`: the OpenMetrics text. src replaces the
//                      sources in tests: { totals, summary } return the
//                      values, { portfw, netify } the text of those commands
//   netify(args)       `netify status|collect [secs]|list|raw [secs]`:
//                      { out, rc }, out a string to print as it is or a value
//                      to print as JSON
//
// Inputs are read the way the shell read them (awk fields, first match wins,
// grep substrings), because the LuCI view, the bot and the exporter are
// written against what those produced.

import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as ctl from 'trafficctl.ctl';
import * as portfw from 'trafficctl.portfw';
import { stat, lsdir, writefile, readfile } from 'fs';

const CLI = '/usr/sbin/trafficctl';
const LEASES = '/tmp/dhcp.leases';
const NAMES = '/etc/trafficctl/names';
const RDNS_CACHE = '/tmp/trafficctl_rdns_cache';
const CONN_CACHE = '/tmp/trafficctl_conn_cache';
const IFROLES = '/tmp/trafficctl_ifroles';
const CONNTRACK = '/proc/net/nf_conntrack';
const SYSFS = '/sys/class/net';
const NETIFY_CACHE = '/tmp/trafficctl_netify.json';
const NETIFY_LOCK = '/tmp/trafficctl_netify.lock';
const NETIFY_SOCKET = '/var/run/netifyd/netifyd.sock';
const NETIFY_SINK = '/etc/netifyd/netify-sink-socket.json';
// A collection runs 60 s at most; the shell's lock never went stale at all,
// so a collector killed mid-run stopped every later one.
const NETIFY_LOCK_STALE = 120;
const NSLOOKUP_MS = 5000;
// The summary hands the refresher this many addresses per poll.
const RDNS_PER_POLL = 8;

const DOTTED = /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/;
const ON_LINK = { REACHABLE: true, STALE: true, DELAY: true, PROBE: true };
const WIFI_TYPES = { wifi: true, '2.4G': true, '5G': true, '6G': true };

// ── how awk and the shell read things ───────────────────────────────────────

// awk's default field split.
function fields(l) {
	l = trim(l, ' \t');
	return (l == '') ? [] : split(l, /[ \t]+/);
}

// A string as awk turns it into a number: its numeric prefix, else 0.
const NUM_PREFIX = /^[ \t]*([-+]?([0-9]+|[0-9]+\.[0-9]+|\.[0-9]+)([eE][-+]?[0-9]+)?)/;
function anum(s) {
	if (type(s) == 'int' || type(s) == 'double')
		return s;
	let m = lib.plain(s) ? match(s, NUM_PREFIX) : null;
	if (!m)
		return 0;
	// ucode reads ".5" as NaN.
	let t = ltrim(m[1], '+'), neg = substr(t, 0, 1) == '-';
	t = ltrim(t, '-');
	let n = +((substr(t, 0, 1) == '.') ? '0' + t : t);
	if (n != n)
		return 0;
	return neg ? -n : n;
}

// $(( s )) in ash: hex, octal or decimal; null for what would abort the
// script there.
function sh_int(s) {
	s = trim(s ?? '');
	if (!lib.plain(s))
		return null;
	if (match(s, /^0[xX][0-9a-fA-F]+$/))
		return hex(substr(s, 2));
	if (match(s, /^0[0-7]*$/)) {
		let n = 0;
		for (let c in split(s, ''))
			n = n * 8 + ord(c) - 48;
		return n;
	}
	if (match(s, /^[1-9][0-9]*$/))
		return +s;
	// A word is a variable name to $(( )), unset here: 0.
	return match(s, /^[A-Za-z_][A-Za-z0-9_]*$/) ? 0 : null;
}

// Digits only, leading zeros allowed (the shell's case pattern), as a number.
function digits_int(s) {
	return lib.plain(s) && match(s, /^[0-9]+$/) ? +(ltrim(s, '0') || '0') : null;
}

// printf %.0f (round half to even): f0 prints it, round0 gives the integer
// for to_json. An integer is kept as it is: through a double, a byte sum
// past 2^53 would lose its low bits.
function f0(n) {
	return (type(n) == 'int') ? sprintf('%d', n) : sprintf('%.0f', n + 0.0);
}

function round0(n) {
	return (type(n) == 'int') ? n : int(f0(n));
}

// tr 'A-F' 'a-f': the MACs are matched in that case.
function lower_af(s) {
	return lib.plain(s) ? replace(s, /[A-F]/g, (c) => lc(c)) : '';
}

function strip_nl(s) {
	return rtrim(s, '\n');
}

// The block a section marker opens, in a reader's output: "@@tctl:<name>".
function sections(text) {
	let out = [], cur = null;
	for (let l in split(text, '\n')) {
		if (substr(l, 0, 7) == '@@tctl:') {
			cur = { name: substr(l, 7), lines: [] };
			push(out, cur);
		}
		else if (cur)
			push(cur.lines, l);
	}
	return out;
}

// First line per key (awk's `$1 == ip { ...; exit }`), keyed on field n.
function first_by(ls, n, fn) {
	let m = {};
	for (let l in ls) {
		let f = fields(l), k = f[n];
		if (k != null && !exists(m, k)) {
			let v = fn(l, f);
			if (v != null)
				m[k] = v;
		}
	}
	return m;
}

function have_tools() {
	let r = {};
	for (let c in lib.lines('for c in socat nc netifyd hostapd_cli; do command -v "$c" >/dev/null && echo "$c"; done'))
		r[c] = true;
	return r;
}

// Detached through the CLI, so a slow refresh never holds up the caller.
function spawn(argv) {
	lib.sh(lib.qv([ lib.path(CLI), ...argv ]) + ' &');
}

// ── firewall and shaper state ───────────────────────────────────────────────

// The nft and tc state the summary and the device report read, from the
// trafficctl.ctl readers: nft rules as `nft -j` records, so an address is
// compared whole and never found inside a longer one.
function limits(lan_dev) {
	return {
		fwd: ctl.nft_rules([ 'chain', 'inet', 'fw4', 'forward' ]),
		rl: ctl.rl_rules(),
		tc: ctl.tc_class_rates(lan_dev),
		tcup: ctl.tc_class_rates(ctl.ifb_dev()),
		shape: ctl.shape_classmap()
	};
}

// tctl_block_comment + '_mac': the IPv6 half of a block names a MAC, not the
// address, so its full comment is the only handle on it.
function block_mac_comment(ip) {
	return 'tctl_block_' + replace(ip, /[.\/]/g, '_') + '_mac';
}

// A rule naming the device: its address as the source, or the IPv6 half.
function names_device(r, ip, mac) {
	return r.saddr == ip || r.comment == mac;
}

// The shell's "ip saddr IP .*drop", or the IPv6 half's comment.
function is_block(r, ip, mac) {
	return (r.saddr == ip && r.verdict == 'drop') || r.comment == mac;
}

function counter_sum(rules, key) {
	let t = 0;
	for (let r in rules)
		t += r[key];
	return t;
}

// The summary's two lookups: blocked, and the bytes on every rule naming the
// device (either half of the block).
function summary_block(lim, ip) {
	let mac = block_mac_comment(ip), blocked = false, hits = [];
	for (let r in lim.fwd) {
		if (!blocked && is_block(r, ip, mac))
			blocked = true;
		if (names_device(r, ip, mac))
			push(hits, r);
	}
	return { blocked, bytes: counter_sum(hits, 'bytes') };
}

// The ceiling of the first `ip <fld> <ip>` limit, 0 without one.
function rl_kbit(lim, ip, fld) {
	return ctl.rl_rate_kbit(lim.rl, ip, fld) ?? 0;
}

// The shaped rate as tc printed it, or null: the classid is looked up in
// shapes.json, never derived from the address (minors are allocated).
function shape_rate(lim, ip, up) {
	let c = lim.shape[ip];
	if (c == null)
		return null;
	return (up ? lim.tcup : lim.tc)[c];
}

// ── WiFi and bridge ports ───────────────────────────────────────────────────

// [{ allow, maclist }] per wifi-iface, maclist a list joined by spaces.
function wifi_ifaces() {
	let out = [];
	lib.uci_foreach('wireless', 'wifi-iface', (s) => {
		let l = s.maclist;
		push(out, {
			allow: s.macfilter == 'allow',
			maclist: (type(l) == 'array') ? join(' ', l) : (l == null) ? '' : '' + l
		});
	});
	return out;
}

function band_of(ch) {
	if (ch == '')
		return '';
	// `[ "$ch" -le 14 ]`: anything that is not one integer fails both tests.
	if (!match(ch, /^-?[0-9]+$/))
		return '6G';
	let n = +ch;
	return (n <= 14) ? '2.4G' : (n <= 177) ? '5G' : '6G';
}

// "mac iface band" per associated station, as the shell listed them.
function wifi_stations() {
	let secs = sections(lib.run("for i in $(iw dev | awk '/Interface/{print $2}'); do " +
		'echo "@@tctl:info $i"; iw dev "$i" info; echo "@@tctl:dump $i"; iw dev "$i" station dump; done'));
	let out = [], band = '';
	for (let s in secs) {
		let sp = index(s.name, ' '), kind = substr(s.name, 0, sp), iface = substr(s.name, sp + 1);
		if (kind == 'info') {
			let ch = [];
			for (let l in s.lines)
				if (index(l, 'channel') >= 0)
					push(ch, fields(l)[1] ?? '');
			band = band_of(strip_nl(join('\n', ch)));
		}
		else
			for (let l in s.lines)
				if (index(l, 'Station') >= 0)
					push(out, lc(fields(l)[1] ?? '') + ' ' + iface + ' ' + band);
	}
	return out;
}

// `grep -i "$MAC"` over such a list.
function grep_i(ls, mac) {
	let m = lc(mac);
	return filter(ls, (l) => index(lc(l), m) >= 0);
}

// A third field per matching line, as `awk '{print $3}'` joined them.
function station_type(st, mac) {
	let hit = grep_i(st, mac);
	if (!length(hit))
		return null;
	let b = strip_nl(join('\n', map(hit, (l) => fields(l)[2] ?? '')));
	return (b == '') ? 'wifi' : b;
}

// Bridge port number -> port device, from sysfs, in glob order.
function bridge_ports(dev) {
	let dir = SYSFS + '/' + dev + '/brif', out = [];
	for (let e in sort(lsdir(lib.path(dir)) ?? [])) {
		let p = dir + '/' + e;
		if (stat(lib.path(p))?.type != 'directory')
			continue;
		let raw = strip_nl(lib.readfile(p + '/port_no') ?? '');
		let n = (raw == '') ? null : sh_int(raw);
		if (n != null)
			push(out, [ n, e ]);
	}
	return out;
}

function has_brif(dev) {
	return stat(lib.path(SYSFS + '/' + dev + '/brif'))?.type == 'directory';
}

// "mac port" for every learned, non-local MAC on the LAN bridges.
function bridge_macs(devs) {
	let br = filter(devs, has_brif);
	if (!length(br))
		return [];
	let secs = map(br, (d) => ({ name: d, lines: split(lib.run('brctl showmacs ' + lib.q(d)), '\n') }));
	let out = [];
	for (let s in secs) {
		let names = {};
		for (let p in bridge_ports(s.name))
			names['' + p[0]] = p[1];
		let first = true;
		for (let l in s.lines) {
			// brctl's header line; the trailing empty line of the output is
			// not a row either.
			if (first) {
				first = false;
				continue;
			}
			let f = fields(l), port = '' + int(anum(f[0] ?? ''));
			if (f[2] == 'no' && exists(names, port))
				push(out, lc(f[1] ?? '') + ' ' + names[port]);
		}
	}
	return out;
}

// ── names ───────────────────────────────────────────────────────────────────

// Manual aliases, the whole rest of the line ("IP NAME WITH SPACES").
function aliases() {
	return first_by(lib.file_lines(NAMES), 0, (l) => replace(l, /^[^ ]+ +/, ''));
}

function rdns_enabled() {
	return lib.uci_get('trafficctl', 'main', 'resolve_names') != '0';
}

// ── conntrack ───────────────────────────────────────────────────────────────

// awk's ip2int, which takes anything: an IPv6 source reads as its leading
// digits, and only a subnet starting at 0 could ever hold it.
function awk_ip2int(s) {
	let a = split(s, '.');
	return int(anum(a[0] ?? '') * 16777216 + anum(a[1] ?? '') * 65536 + anum(a[2] ?? '') * 256 + anum(a[3] ?? ''));
}

// `sort -t. -k1,1n -k2,2n -k3,3n -k4,4n`, then the whole line.
function ip_cmp(a, b) {
	let x = split(a, '.'), y = split(b, '.');
	for (let i = 0; i < 4; i++) {
		let p = anum(x[i] ?? ''), q = anum(y[i] ?? '');
		if (p != q)
			return (p < q) ? -1 : 1;
	}
	return (a < b) ? -1 : (a > b) ? 1 : 0;
}

// Per source address: { total, tcp, udp, conns, kind } over one read of the
// table. The source is the first src= (original, then reply) in a monitored
// subnet, l(an) or r(outed); failing that, a flow this router SNATed (reply
// dst != original src) names a forwarded client. Its bytes are the counter of
// the direction it is the source of.
function ct_sources(subs) {
	let memo = {}, locals = null, acc = {};
	let idx = (ip) => {
		if (exists(memo, ip))
			return memo[ip];
		let si = awk_ip2int(ip), k = -1;
		for (let i = 0; i < length(subs); i++)
			if (si - si % subs[i].block == subs[i].base) {
				k = i;
				break;
			}
		memo[ip] = k;
		return k;
	};

	net.ct_each((c) => {
		let src = null, dst, b, kind, k = idx(c.osrc);
		if (k >= 0) {
			src = c.osrc;
			dst = c.odst;
			b = c.obytes;
		}
		else if (c.rsrc != null && (k = idx(c.rsrc)) >= 0) {
			src = c.rsrc;
			dst = c.rdst;
			b = c.rbytes;
		}
		if (src != null) {
			// The router itself, and the network and broadcast addresses
			// (a routed /31 or /32 has neither).
			let s = subs[k], si = awk_ip2int(src);
			if ((s.router && si == s.router) || (s.block > 2 && (si == s.base || si == s.base + s.block - 1)))
				return;
			kind = s.router ? 'l' : 'r';
		}
		else {
			let o = c.osrc;
			if (o == '' || c.rdst == null || c.rdst == '' || c.rdst == o || !match(o, DOTTED))
				return;
			locals ??= net.local_ips();
			if (exists(locals, o))
				return;
			src = o;
			dst = c.odst;
			b = c.obytes;
			kind = 'r';
		}
		if (dst == null || dst == src)
			return;
		let a = acc[src];
		if (!a)
			a = acc[src] = { total: 0, tcp: 0, udp: 0, conns: 0, kind };
		a.conns++;
		a.kind = kind;
		a.total += b;
		if (c.proto == 'tcp')
			a.tcp += b;
		else if (c.proto == 'udp')
			a.udp += b;
	});
	return acc;
}

// "ip type epoch" lines: the last connection type seen per device, shown as
// conn_last once it is offline.
function cache_last(ls, ip) {
	let pre = ip + ' ', last = null;
	for (let l in ls)
		if (substr(l, 0, length(pre)) == pre)
			last = l;
	if (last == null)
		return '';
	let f = fields(last);
	return (f[1] ?? '') + '@' + (f[2] ?? '');
}

function cache_put(ls, ip, ctype, now) {
	let pre = ip + ' ';
	ls = filter(ls, (l) => substr(l, 0, length(pre)) != pre);
	// A multi-line type (a MAC on two radios) was echoed as it is.
	push(ls, ...split(sprintf('%s %s %d', ip, ctype, now), '\n'));
	return ls;
}

function conn_cache_init() {
	if (!lib.is_file(CONN_CACHE))
		writefile(lib.path(CONN_CACHE), '');
}

// ── summary ─────────────────────────────────────────────────────────────────

function netify_apps(now) {
	if (lib.uci_get('trafficctl', 'main', 'netify_enabled') == '0')
		return {};
	let sock = lib.uci_get('trafficctl', 'main', 'netify_socket') ?? NETIFY_SOCKET;
	if (sock == '' || stat(lib.path(sock))?.type != 'socket')
		return {};
	let pairs = [];
	for (let l in lib.file_lines(NETIFY_CACHE))
		for (let piece in split(l, '},{')) {
			let m = lib.plain(piece) ? match(piece, /^.*"ip":"([^"]*)","top":"([^"]*)"/) : null;
			if (m)
				push(pairs, m[1] + ' ' + m[2]);
		}
	let age = now - (stat(lib.path(NETIFY_CACHE))?.mtime ?? 0);
	let iv = lib.valid_int(lib.uci_get('trafficctl', 'main', 'netify_interval'), 1) ?? 45;
	if (age >= iv)
		spawn([ 'netify', 'collect' ]);
	return first_by(pairs, 0, (l, f) => f[1] ?? '');
}

// The hostname as the shell left it: quotes, backslashes and line breaks
// removed (a DHCP hostname is client-controlled).
function summary_name(n) {
	return replace(n, /["\\\n\r\t]/g, '');
}

function summary() {
	conn_cache_init();
	if (!length(net.lan_subnets()))
		return [];
	let acc = ct_sources(net.monitored_subnets());
	let ips = sort(keys(acc), ip_cmp);
	if (!length(ips))
		return [];

	let now = time();
	let leases = lib.file_lines(LEASES);
	let lease_name = first_by(leases, 2, (l, f) => (f[3] != '*') ? (f[3] ?? '') : null);
	let lease_mac = first_by(leases, 2, (l, f) => f[1] ?? '');
	let neigh = lib.lines('ip neigh show');
	let neigh_mac = first_by(neigh, 0, (l, f) => {
		let i = index(f, 'lladdr');
		return (i >= 0) ? (f[i + 1] ?? '') : null;
	});
	let neigh_state = first_by(neigh, 0, (l, f) => f[-1]);
	let alias = aliases();
	let resolve = rdns_enabled();
	let rd = lib.file_lines(RDNS_CACHE);
	let rd_name = first_by(rd, 0, (l, f) => (f[1] != '-') ? (f[1] ?? '') : null);
	let rd_ts = first_by(rd, 0, (l, f) => f[2] ?? '');
	let ttl = lib.valid_int(lib.uci_get('trafficctl', 'main', 'rdns_ttl'), 1) ?? 300;
	let apps = netify_apps(now);

	let lim = limits(net.lan_device());

	// "Listed" means opposite things per policy: on a deny radio a listed MAC
	// is blocked, on an allow (whitelist) radio an unlisted one is.
	let deny = [], allow = [], has_allow = false;
	for (let w in wifi_ifaces()) {
		if (w.allow) {
			has_allow = true;
			push(allow, w.maclist);
		}
		else
			push(deny, w.maclist);
	}
	deny = '  ' + lower_af(join(' ', deny)) + ' ';
	allow = '  ' + lower_af(join(' ', allow)) + ' ';

	let st = wifi_stations();
	let br = bridge_macs(net.lan_devices());
	let cache = lib.file_lines(CONN_CACHE), puts = [];
	let pending = [], rows = [];

	for (let ip in ips) {
		let a = acc[ip];
		let name = alias[ip] ?? '';
		if (name == '')
			name = lease_name[ip] ?? '';
		if (name == '' && resolve)
			name = rd_name[ip] ?? '';
		let mac = lease_mac[ip] ?? '';
		if (mac == '')
			mac = neigh_mac[ip] ?? '';
		mac = lower_af(mac);
		let blk = summary_block(lim, ip);
		let wifi_blocked = mac != '' && (index(deny, ' ' + mac + ' ') >= 0 ||
			(has_allow && index(allow, ' ' + mac + ' ') < 0));
		if (name == '') {
			name = '*';
			if (resolve) {
				let ts = rd_ts[ip];
				if (ts == null || ts == '' || now - (sh_int(ts) ?? 0) >= ttl)
					push(pending, ip);
			}
		}

		let ctype = '', last = '';
		if (a.kind == 'r')
			// Behind a downstream router: no MAC, bridge port or ARP entry here.
			ctype = 'routed';
		else {
			if (mac != '') {
				ctype = station_type(st, mac);
				if (ctype == null) {
					ctype = '';
					let hit = grep_i(br, mac);
					if (length(hit)) {
						let port = strip_nl(join('\n', map(hit, (l) => fields(l)[1] ?? '')));
						ctype = match(port, /^(phy|wlan)/) ? 'wifi' : port;
					}
				}
			}
			if (ctype != '') {
				cache = cache_put(cache, ip, ctype, now);
				push(puts, [ ip, ctype ]);
			}
			else if (ON_LINK[neigh_state[ip] ?? ''])
				ctype = 'ethernet';
			else {
				ctype = '?';
				last = cache_last(cache, ip);
			}
		}

		push(rows, {
			ip,
			name: summary_name(name),
			mac,
			conn_type: ctype,
			conn_last: last,
			app: apps[ip] ?? '',
			conns: a.conns,
			total: a.total,
			tcp: a.tcp,
			udp: a.udp,
			blocked: blk.blocked,
			block_bytes: blk.bytes,
			wifi_blocked,
			wifi_block_pending: wifi_blocked && !!WIFI_TYPES[ctype],
			rate_limit_kbit: rl_kbit(lim, ip, 'daddr'),
			rate_limit_kbit_up: rl_kbit(lim, ip, 'saddr'),
			shape_kbit: round0(anum(shape_rate(lim, ip, false) ?? '0')),
			shape_kbit_up: round0(anum(shape_rate(lim, ip, true) ?? '0'))
		});
	}

	// Replayed onto the file as it is now, not the copy read before the
	// rows: a `device` call writing its entry meanwhile keeps it.
	if (length(puts)) {
		let fresh = lib.file_lines(CONN_CACHE);
		for (let p in puts)
			fresh = cache_put(fresh, p[0], p[1], now);
		lib.write_atomic(CONN_CACHE, join('\n', fresh) + '\n');
	}
	// Whatever is still unnamed: detached and capped, the names land in the
	// cache and show on the next poll.
	if (length(pending))
		spawn([ 'rdns-refresh', ...slice(pending, -RDNS_PER_POLL) ]);
	return rows;
}

// ── device ──────────────────────────────────────────────────────────────────

const DEVICE_USAGE = 'usage: trafficctl device <ip> [--rdns] [--proto tcp|udp|all]';

// --max-bytes: rpcd's file.exec answers NOT_SUPPORTED, with nothing, once a
// command prints 256 KiB, and a device behind a torrent client tracks enough
// connections for that. Over the budget the largest connections by bytes are
// kept, in their order, and connections_omitted says how many were not.
function cap_connections(reply, budget) {
	let conns = reply.connections;
	if (length(lib.to_json(reply)) <= budget)
		return reply;
	reply.connections = [];
	let room = budget - length(lib.to_json(reply)) - length(',"connections_omitted":') - 12;
	let sizes = map(conns, (c) => length(lib.to_json(c)) + 1);
	let order = sort(map(conns, (c, i) => i), (x, y) => {
		let d = conns[y].bytes - conns[x].bytes;
		return (d > 0) ? 1 : (d < 0) ? -1 : x - y;
	});
	let keep = {}, n = 0;
	for (let i in order) {
		if (sizes[i] > room)
			break;
		room -= sizes[i];
		keep[i] = true;
		n++;
	}
	reply.connections = filter(conns, (c, i) => keep[i]);
	reply.connections_omitted = length(conns) - n;
	return reply;
}
const SERVICES = { '80': 'http', '443': 'https', '53': 'dns', '22': 'ssh', '123': 'ntp',
	'5353': 'mdns', '21': 'ftp', '25': 'smtp', '993': 'imaps', '8080': 'http-alt' };
const META_STATES = { ESTABLISHED: true, TIME_WAIT: true, SYN_SENT: true, CLOSE_WAIT: true };
const CONN_STATES = { ...META_STATES, FIN_WAIT: true };

// One conntrack line holding "src=<ip> ", read as the shell's awk did: the
// destination is the first dst= after that src=, the counters and port come
// after the destination, the state is the last state word outside the span
// between the two.
function ct_line(l, ip) {
	let f = fields(l), key = 'src=' + ip, n = length(f);
	let r = { proto: '', dst: '', dport: '', bytes: 0, meta: '', state: '', mark: '0' };
	let s = -1, d = -1;
	for (let i = 0; i < n; i++) {
		let w = f[i];
		if (w == 'tcp' || w == 'udp' || w == 'icmp')
			r.proto = w;
		if (substr(w, 0, 5) == 'mark=')
			r.mark = substr(w, 5);
		if (s < 0 && w == key) {
			s = i;
			continue;
		}
		if (s >= 0 && d < 0) {
			if (substr(w, 0, 4) != 'dst=')
				continue;
			d = i;
			r.dst = substr(w, 4);
		}
		if (s >= 0) {
			if (r.dport == '' && substr(w, 0, 6) == 'dport=')
				r.dport = substr(w, 6);
			if (r.bytes == 0 && substr(w, 0, 6) == 'bytes=')
				r.bytes = anum(substr(w, 6));
		}
		if (META_STATES[w])
			r.meta = w;
		if (CONN_STATES[w])
			r.state = w;
	}
	return r;
}

function lan_member(ip) {
	let n = lib.ip2int(ip);
	for (let s in net.lan_subnets())
		if (n - n % s.block == s.base)
			return true;
	return false;
}

function device_conn_type(ip, mac) {
	if (!lan_member(ip))
		// Not on a connected LAN subnet: reached through a downstream router.
		return 'routed';
	if (mac == '')
		return '';
	let t = station_type(wifi_stations(), mac);
	if (t != null)
		return t;
	let dev = net.lan_device(), port = null, first = true;
	for (let l in lib.lines('brctl showmacs ' + lib.q(dev))) {
		if (first) {
			first = false;
			continue;
		}
		let f = fields(l);
		if (f[2] == 'no' && lc(f[1] ?? '') == mac) {
			port = f[0];
			break;
		}
	}
	if (port == null || !match(port, /^-?[0-9]+$/))
		return '';
	let iface = '';
	for (let p in bridge_ports(dev))
		if (p[0] == +port) {
			iface = p[1];
			break;
		}
	return (iface == '') ? '' : match(iface, /^(phy|wlan)/) ? 'wifi' : iface;
}

// Egress device per destination of the connections carrying a non-zero
// conntrack mark: `ip route get <dst> mark <mark>` honours the fwmark rules,
// so it names the WAN that policy routing (mwan3) picked. Unmarked ones stay
// blank rather than showing the main table's egress.
function oif_devices(cts, ip) {
	let pairs = {};
	for (let r in cts)
		if (r.dst != '' && r.dst != ip && r.mark != '0' && r.mark != '')
			pairs[r.dst + ' ' + r.mark] = [ r.dst, r.mark ];
	let out = {};
	for (let k in sort(keys(pairs))) {
		let p = pairs[k];
		let m = match(lib.run(lib.qv([ 'ip', 'route', 'get', p[0], 'mark', p[1] ])), /dev ([^ \n]+)/);
		if (m && m[1] != 'lo')
			out[p[0]] = m[1];
	}
	return out;
}

// The uci name of each device ("Finland" for awg3), from the role map
// `trafficctl ifaces` memoises.
function oif_labels(need) {
	let p = getenv('TCTL_IFROLE_CACHE');
	p = (p != null && p != '') ? p : lib.path(IFROLES);
	if (need && !(stat(p)?.size > 0)) {
		try {
			net.ifaces();
		}
		catch (e) {
		}
	}
	let out = {};
	for (let l in split(readfile(p) ?? '', '\n')) {
		if (substr(l, 0, 1) == '#')
			continue;
		let f = fields(l);
		if (length(f) >= 7 && f[6] != '-')
			out[f[0]] = f[6];
	}
	return out;
}

function host_ok(h) {
	return type(h) == 'string' && lib.plain(h) && !!match(h, /^[a-zA-Z0-9._-]+$/);
}

// PTR names of every dst= address in the device's entries: one rrdns batch
// (what the LuCI frontend uses), else nslookup per address.
function dst_hosts(ls, ip) {
	let seen = {};
	for (let l in ls)
		for (let m in match(l, /dst=[0-9.]+/g) ?? []) {
			let a = substr(m[0], 4);
			if (a != ip)
				seen[a] = true;
		}
	let addrs = sort(keys(seen)), out = {};
	if (!length(addrs))
		return out;
	let r = lib.ubus_call('network.rrdns', 'lookup', { addrs, timeout: 3000, limit: 64 });
	if (r != null) {
		for (let a in addrs)
			if (type(r) == 'object' && host_ok(r[a]))
				out[a] = r[a];
		return out;
	}
	for (let a in addrs)
		for (let l in lib.lines('nslookup ' + lib.q(a), NSLOOKUP_MS)) {
			let m = match(l, /^.*name = (.*)\.$/);
			if (m) {
				if (host_ok(m[1]))
					out[a] = m[1];
				break;
			}
		}
	return out;
}

function device(args) {
	let ip = '', do_rdns = false, pf = 'all', budget = null;
	for (let i = 0; i < length(args); i++) {
		if (args[i] == '--rdns')
			do_rdns = true;
		else if (args[i] == '--proto')
			pf = args[++i] ?? '';
		else if (args[i] == '--max-bytes') {
			budget = lib.valid_int('' + (args[++i] ?? ''), 1024, 1073741824);
			if (budget == null)
				return { reply: { ok: false, msg: DEVICE_USAGE }, rc: 1 };
		}
		else if (ip == '')
			ip = '' + args[i];
	}
	if (ip == '')
		return { reply: { ok: false, msg: DEVICE_USAGE }, rc: 1 };
	if (!lib.valid_ip(ip))
		return { reply: { ok: false, msg: 'invalid IP address' }, rc: 1 };

	let leases = filter(lib.file_lines(LEASES), (l) => fields(l)[2] == ip);
	let name = fields(leases[0] ?? '')[3] ?? '';
	let mac = fields(leases[0] ?? '')[1] ?? '';
	if (mac == '') {
		let m = match(lib.run('ip neigh show ' + lib.q(ip)), /[0-9a-fA-F:]{17}/);
		mac = m ? m[0] : '';
	}
	mac = lower_af(mac);
	if (name == '*')
		name = '';
	let al = aliases()[ip] ?? '';
	if (al != '')
		name = al;
	if (name == '' && rdns_enabled())
		name = first_by(lib.file_lines(RDNS_CACHE), 0, (l, f) => (f[1] != '-') ? (f[1] ?? '') : null)[ip] ?? '';
	if (name == '')
		name = '*';

	conn_cache_init();
	let ctype = device_conn_type(ip, mac), last = '';
	if (ctype != '')
		lib.write_atomic(CONN_CACHE, join('\n', cache_put(lib.file_lines(CONN_CACHE), ip, ctype, time())) + '\n');
	else {
		let st = strip_nl(join('\n', map(lib.lines('ip neigh show ' + lib.q(ip)), (l) => fields(l)[-1] ?? '')));
		if (ON_LINK[st])
			ctype = 'ethernet';
		else {
			ctype = '?';
			last = cache_last(lib.file_lines(CONN_CACHE), ip);
		}
	}

	let lim = limits(net.lan_device());
	let macc = block_mac_comment(ip);
	let blk = filter(lim.fwd, (r) => is_block(r, ip, macc));
	let blocked = length(blk) > 0;

	let wifs = wifi_ifaces(), wifi_blocked = false;
	if (mac != '')
		for (let w in wifs) {
			let listed = index(lc(w.maclist), lc(mac)) >= 0;
			if (w.allow ? !listed : listed) {
				wifi_blocked = true;
				break;
			}
		}

	let now = time(), key = 'src=' + ip + ' ', ls = [];
	lib.each_line(CONNTRACK, (l) => {
		if (index(l, key) >= 0)
			push(ls, l);
	});
	let cts = map(ls, (l) => ct_line(l, ip));
	let oifs = oif_devices(cts, ip);
	let labels = oif_labels(length(keys(oifs)) > 0);
	let hosts = do_rdns ? dst_hosts(ls, ip) : {};

	let total = 0, protos = { tcp: 0, udp: 0, other: 0 };
	let states = { established: 0, time_wait: 0, syn_sent: 0, close_wait: 0 };
	let conns = [];
	for (let r in cts) {
		if ((pf != 'all' && r.proto != pf) || r.dst == '' || r.dst == ip)
			continue;
		total += r.bytes;
		protos[(r.proto == 'tcp' || r.proto == 'udp') ? r.proto : 'other']++;
		if (r.meta != '')
			states[lc(r.meta)]++;
		let port = (r.dport == '') ? '0' : r.dport, odev = oifs[r.dst] ?? '';
		push(conns, {
			proto: r.proto,
			dst: r.dst,
			host: hosts[r.dst] ?? '',
			port: anum(port),
			service: SERVICES[port] ?? '',
			bytes: round0(r.bytes),
			state: r.state,
			oif: (odev != '' && exists(labels, odev)) ? labels[odev] : odev,
			oif_dev: odev
		});
	}

	let tools = length(wifs) ? have_tools() : {};
	let reply = {
		ip,
		name,
		mac,
		conn_type: ctype,
		conn_last: last,
		timestamp: now,
		blocked,
		block_packets: counter_sum(blk, 'packets'),
		block_bytes: counter_sum(blk, 'bytes'),
		wifi_blocked,
		wifi_block_pending: wifi_blocked && !!WIFI_TYPES[ctype],
		wifi_filter: !length(wifs) ? 'none' : tools.hostapd_cli ? 'full' : 'temporary',
		total: round0(total),
		protocols: protos,
		tcp_states: states,
		connections: conns,
		rate_limit_kbit: rl_kbit(lim, ip, 'daddr'),
		rate_limit_kbit_up: rl_kbit(lim, ip, 'saddr'),
		// printf %d here, %.0f in the summary: 0.8 kbit/s reads 0 and 1.
		shape_kbit: int(anum(shape_rate(lim, ip, false) ?? '0')),
		shape_kbit_up: int(anum(shape_rate(lim, ip, true) ?? '0'))
	};
	return { rc: 0, reply: (budget == null) ? reply : cap_connections(reply, budget) };
}

// ── netify ──────────────────────────────────────────────────────────────────
//
// Telemetry comes from the agent's socket SINK (netify-sink-socket.json,
// typically tcp://127.0.0.1:1780), not from netifyd.sock: in Agent v5 that is
// a request/response API which never pushes flows. Records are parsed by
// field extraction, which tolerates any framing, and both the aggregator's
// {"stats":[...]} records and v4's raw per-flow records are taken.

const NETIFY_USAGE = 'usage: trafficctl netify status|collect [secs]|list|raw [secs]';

function netify_enabled() {
	return lib.uci_get('trafficctl', 'main', 'netify_enabled') != '0';
}

function netify_socket() {
	let s = lib.uci_get('trafficctl', 'main', 'netify_socket');
	return (s != null && s != '') ? s : NETIFY_SOCKET;
}

// An explicit override, else the first socket-sink channel, else the unix
// socket (Agent v4).
function netify_endpoint() {
	let ep = lib.uci_get('trafficctl', 'main', 'netify_endpoint');
	if (ep != null && ep != '')
		return ep;
	for (let l in lib.file_lines(NETIFY_SINK)) {
		let m = lib.plain(l) ? match(l, /^.*"bind_address"[ \t]*:[ \t]*"(tcp:\/\/[^"]*)"/) : null;
		if (m)
			return m[1];
	}
	return 'unix://' + netify_socket();
}

function netify_reader(tools) {
	return tools.socat ? 'socat' : tools.nc ? 'nc' : '';
}

// Recorded agent output (TCTL_NETIFY_FEED, for tests and offline debugging),
// else secs of the socket through socat or nc, killed when they are up.
function netify_feed(secs) {
	let f = getenv('TCTL_NETIFY_FEED');
	if (f != null && f != '' && stat(f)?.type == 'file')
		return readfile(f) ?? '';
	let ep = netify_endpoint(), reader = netify_reader(have_tools()), argv;
	if (reader == '')
		return '';
	if (substr(ep, 0, 6) == 'tcp://') {
		let hp = substr(ep, 6), c = index(hp, ':');
		argv = (reader == 'socat') ? [ 'socat', '-u', 'TCP-CONNECT:' + hp, '-' ]
			: [ 'nc', (c < 0) ? hp : substr(hp, 0, c), (c < 0) ? hp : substr(hp, rindex(hp, ':') + 1) ];
	}
	else if (substr(ep, 0, 7) == 'unix://' || substr(ep, 0, 1) == '/') {
		let p = lib.path((substr(ep, 0, 7) == 'unix://') ? substr(ep, 7) : ep);
		if (stat(p)?.type != 'socket')
			return '';
		argv = (reader == 'socat') ? [ 'socat', '-u', 'UNIX-CONNECT:' + p, '-' ] : [ 'nc', '-U', p ];
	}
	else
		return '';
	// The sink never closes the stream, and lib.run(cmd, 0) means no timeout:
	// `raw 0` would read forever. BusyBox `timeout 0` stopped it after about
	// a second, so that is the floor.
	return lib.run(lib.qv(argv), ((secs > 0) ? secs : 1) * 1000);
}

function netify_status() {
	let tools = have_tools(), sock = netify_socket(), reader = netify_reader(tools), age = -1;
	if (lib.is_file(NETIFY_CACHE))
		age = time() - (stat(lib.path(NETIFY_CACHE))?.mtime ?? 0);
	return {
		enabled: netify_enabled(),
		installed: !!tools.netifyd,
		running: stat(lib.path(sock))?.type == 'socket',
		socket: sock,
		endpoint: netify_endpoint(),
		reader: (reader != '') ? reader : 'none',
		readable: reader != '',
		cache_age: age
	};
}

// The value of the first "key": as a string or an int, '' when neither.
let nre = {};
function nfield(l, key) {
	nre[key] ??= regexp('"' + key + '"[ \t]*:[ \t]*(.*)$');
	let m = match(l, nre[key]);
	if (!m)
		return '';
	let seg = m[1];
	if (substr(seg, 0, 1) == '"') {
		let i = index(substr(seg, 1), '"');
		return (i < 0) ? '' : substr(seg, 1, i);
	}
	let n = match(seg, /^-?[0-9]+/);
	return n ? +n[0] : '';
}

function nstr(v) {
	return (type(v) == 'string') ? v : '' + v;
}

// awk's `v == ""` and `v == 0` for a field that is a string or a number.
function nzero(v) {
	return (type(v) == 'string') ? (v == '' || v == '0') : v == 0;
}

const SUBSEP = '\x1c';

// "ip app bytes flows" lines. The agent re-emits a flow as its counters grow,
// so bytes are the last sighting per flow digest, summed only at the end.
function parse_flows(raw) {
	let seen = {}, dbytes = {}, flows = {}, nr = 0;
	for (let line in split(raw, '\n'))
		for (let l in split(replace(line, /\},[ ]*\{/g, '}\n{'), '\n')) {
			nr++;
			let ip = nfield(l, 'local_ip');
			if (type(ip) != 'string' || !match(ip, DOTTED))
				continue;
			// Aggregator records name the app "<id>.netify.<name>".
			let app = replace(nstr(nfield(l, 'application_id')), /^[0-9]+\./, '');
			if (app == '')
				app = nstr(nfield(l, 'detected_application_name'));
			app = replace(app, /^netify\./, '');
			if (app == '' || app == 'unknown')
				app = nstr(nfield(l, 'detected_protocol_name'));
			if (app == '' || app == 'Unknown') {
				let host = nstr(nfield(l, 'host_server_name'));
				app = (host != '') ? host : 'unclassified';
			}
			app = replace(app, /[^a-zA-Z0-9._ -]/g, '');
			if (app == '')
				app = 'unclassified';

			let digest = nfield(l, 'digest');
			// Aggregator: per-interval deltas already summed per device+app.
			let bytes = anum(nfield(l, 'download')) + anum(nfield(l, 'upload'));
			if (bytes == 0)
				bytes = nfield(l, 'total_bytes');
			if (nzero(bytes))
				bytes = anum(nfield(l, 'local_bytes')) + anum(nfield(l, 'other_bytes'));
			digest = (type(digest) == 'string' && digest == '') ? ip + '|' + app + '|' + nr : nstr(digest);

			let key = ip + SUBSEP + app;
			if (!exists(seen, digest)) {
				seen[digest] = key;
				flows[key] = (flows[key] ?? 0) + 1;
			}
			dbytes[digest] = anum(bytes);
		}
	let total = {};
	for (let d in keys(seen))
		total[seen[d]] = (total[seen[d]] ?? 0) + dbytes[d];
	return map(keys(total), (k) => {
		let p = split(k, SUBSEP);
		return sprintf('%s %s %s %d', p[0], p[1], f0(total[k]), flows[k]);
	});
}

// sort's -n: the numeric prefix, no exponent.
function sort_num(s) {
	let m = match(s ?? '', /^-?([0-9]+\.?[0-9]*|\.[0-9]+)/);
	return m ? anum(m[0]) : 0;
}

// `sort -k1,1 -k3,3nr`, then the whole line.
function flow_cmp(a, b) {
	let x = fields(a), y = fields(b);
	if ((x[0] ?? '') != (y[0] ?? ''))
		return ((x[0] ?? '') < (y[0] ?? '')) ? -1 : 1;
	let p = sort_num(x[2]), q = sort_num(y[2]);
	if (p != q)
		return (p > q) ? -1 : 1;
	return (a < b) ? -1 : (a > b) ? 1 : 0;
}

// Grouped by address, apps by bytes descending; the first is the top app.
function flows_json(parsed) {
	let out = '[', cur = '', first = true;
	for (let l in sort(parsed, flow_cmp)) {
		let f = fields(l);
		if (length(f) < 4)
			continue;
		if (f[0] != cur) {
			if (cur != '')
				out += ']},';
			out += sprintf('{"ip":"%s","top":"%s","apps":[', f[0], f[1]);
			cur = f[0];
			first = true;
		}
		if (!first)
			out += ',';
		out += sprintf('{"name":"%s","bytes":%s,"flows":%d}', f[1], f0(anum(f[2])), int(anum(f[3])));
		first = false;
	}
	if (cur != '')
		out += ']}';
	return out + ']\n';
}

// secs as the shell's case pattern and clamps took it, still a string.
function netify_secs(s, lo) {
	s = (s == null || s == '') ? '18' : '' + s;
	let n = digits_int(s);
	if (n == null)
		return '18';
	if (lo && n < 1)
		return '1';
	return (n > 60) ? '60' : s;
}

function collect_locked(secs) {
	// NUL bytes vanish in a shell command substitution.
	let raw = rtrim(join('', split(netify_feed(digits_int(secs)), chr(0))), '\n');
	if (raw == '')
		return { ok: false, msg: 'no data from netifyd socket' };
	let parsed = parse_flows(raw);
	lib.write_atomic(NETIFY_CACHE, flows_json(parsed));
	let ips = {};
	for (let l in parsed)
		ips[fields(l)[0]] = true;
	return { ok: true, msg: 'collected ' + secs + 's', devices: length(keys(ips)) };
}

// The aggregator publishes every ~15 s, so the default window spans one
// report. One collector at a time: overlapping samples would double the
// socket load and race on the cache.
function netify_collect(arg) {
	let secs = netify_secs(arg, true);
	if (!netify_enabled())
		return { ok: false, msg: 'netify integration disabled' };
	if (!lib.lock(NETIFY_LOCK, 0, NETIFY_LOCK_STALE))
		return { ok: false, msg: 'collection already running' };
	let r;
	try {
		r = collect_locked(secs);
	}
	catch (e) {
		lib.unlock(NETIFY_LOCK);
		die(e.message);
	}
	lib.unlock(NETIFY_LOCK);
	return r;
}

function netify_list() {
	return lib.is_file(NETIFY_CACHE) ? (lib.readfile(NETIFY_CACHE) ?? '') : '[]\n';
}

function netify(args) {
	switch (args[0]) {
	case 'status':
		return { out: netify_status(), rc: 0 };
	case 'collect':
		return { out: netify_collect(args[1]), rc: 0 };
	case 'list':
		return { out: netify_list(), rc: 0 };
	case 'raw':
		return { out: netify_feed(digits_int(netify_secs(args[1], false))), rc: 0 };
	default:
		return { out: { ok: false, msg: NETIFY_USAGE }, rc: 1 };
	}
}

// ── metrics ─────────────────────────────────────────────────────────────────
//
// The exporter read its sources' JSON as text with awk, one object per line
// after splitting on "},{", and this keeps doing so: the series it prints are
// what dashboards and alerts are written against, byte for byte.

function json_lines(text, sep) {
	return split(replace(text, sep ?? '},{', (sep == null) ? '}\n{' : ']}\n{'), '\n');
}

let jre = {};
function jnum(l, key, dflt) {
	jre['n' + key] ??= regexp('"' + key + '"[ \t]*:[ \t]*([0-9]*)');
	let m = match(l, jre['n' + key]);
	return (m && m[1] != '') ? +m[1] : dflt;
}

function jstr(l, key) {
	jre['s' + key] ??= regexp('"' + key + '"[ \t]*:[ \t]*"([^"]*)(")?');
	let m = match(l, jre['s' + key]);
	return (m && m[2] == '"') ? m[1] : '';
}

function esc(v) {
	return replace(replace(v, '\\', '\\\\'), '"', '\\"');
}

function source_text(fn) {
	try {
		let v = fn();
		return (type(v) == 'string') ? v : lib.to_json(v) + '\n';
	}
	catch (e) {
		return '';
	}
}

function opt_on(o) {
	return lib.uci_get('trafficctl', 'metrics', o) != '0';
}

function metrics(src) {
	if (lib.uci_get('trafficctl', 'metrics', 'enabled') != '1')
		return '# trafficctl metrics are disabled (set trafficctl.metrics.enabled=1)\n';
	src ??= {};
	let o = [];

	// Device byte counters: the accumulator in net.totals() is the one the
	// LuCI Bytes column reads, so the two cannot drift apart. --all, so a
	// quiet device's series does not vanish whenever its last flow expires.
	push(o, '# HELP trafficctl_device_bytes_total Bytes transferred per device since the counter started. The store is tmpfs, so this resets on reboot; it advances whenever anything samples (a scrape, or the LuCI page).\n',
		'# TYPE trafficctl_device_bytes_total counter\n',
		'# HELP trafficctl_device_bytes_degraded 1 when the counter above was built from byte counters the forwarding path does not update (uncountered flow offload with no usable nftables fallback). The counter is then a lower bound that stalls while traffic continues; alert on this rather than trusting a flat rate().\n',
		'# TYPE trafficctl_device_bytes_degraded gauge\n');
	for (let l in json_lines(source_text(src.totals ?? (() => net.totals(true))))) {
		let ip = jstr(l, 'ip');
		if (ip == '')
			continue;
		let rx = jnum(l, 'bytes_in_total', -1), tx = jnum(l, 'bytes_out_total', -1);
		push(o, sprintf('trafficctl_device_bytes_total{ip="%s",direction="rx"} %s\n', ip, f0((rx < 0) ? 0 : rx)),
			sprintf('trafficctl_device_bytes_total{ip="%s",direction="tx"} %s\n', ip, f0((tx < 0) ? 0 : tx)),
			sprintf('trafficctl_device_bytes_degraded{ip="%s"} %d\n', ip, (index(l, '"degraded":true') >= 0) ? 1 : 0));
	}

	// Per-device state gauges: the full summary, markedly heavier than the
	// byte pass.
	if (opt_on('state')) {
		let rdns = {};
		for (let l in lib.file_lines(RDNS_CACHE)) {
			let f = fields(l);
			if (length(f) >= 2 && f[1] != '-')
				rdns[f[0]] = f[1];
		}
		push(o, '# HELP trafficctl_device_connections Active tracked connections per device.\n',
			'# TYPE trafficctl_device_connections gauge\n',
			'# HELP trafficctl_device_blocked Whether the device is blocked from the internet.\n',
			'# TYPE trafficctl_device_blocked gauge\n',
			'# HELP trafficctl_device_limit_kbit Applied throttle in kbit/s (0 = none).\n',
			'# TYPE trafficctl_device_limit_kbit gauge\n',
			'# HELP trafficctl_device_limit_up_kbit Applied upload throttle in kbit/s (0 = none); equals the download one unless split.\n',
			'# TYPE trafficctl_device_limit_up_kbit gauge\n',
			'# HELP trafficctl_device_wifi_blocked Whether the device is denied on WiFi.\n',
			'# TYPE trafficctl_device_wifi_blocked gauge\n',
			'# HELP trafficctl_device_conntrack_bytes Bytes currently accounted in conntrack (falls as flows expire).\n',
			'# TYPE trafficctl_device_conntrack_bytes gauge\n',
			'# HELP trafficctl_device_blocked_bytes Bytes dropped by the block rule.\n',
			'# TYPE trafficctl_device_blocked_bytes gauge\n',
			'# HELP trafficctl_device_info Device metadata; the value is always 1.\n',
			'# TYPE trafficctl_device_info gauge\n');
		for (let l in json_lines(source_text(src.summary ?? summary))) {
			let ip = jstr(l, 'ip');
			if (ip == '')
				continue;
			push(o, sprintf('trafficctl_device_connections{ip="%s"} %d\n', ip, jnum(l, 'conns', 0)),
				sprintf('trafficctl_device_blocked{ip="%s"} %d\n', ip, (index(l, '"blocked":true') >= 0) ? 1 : 0),
				sprintf('trafficctl_device_wifi_blocked{ip="%s"} %d\n', ip, (index(l, '"wifi_blocked":true') >= 0) ? 1 : 0),
				sprintf('trafficctl_device_limit_kbit{ip="%s",mode="limiter"} %d\n', ip, jnum(l, 'rate_limit_kbit', 0)),
				sprintf('trafficctl_device_limit_kbit{ip="%s",mode="shaper"} %d\n', ip, jnum(l, 'shape_kbit', 0)),
				sprintf('trafficctl_device_limit_up_kbit{ip="%s",mode="limiter"} %d\n', ip, jnum(l, 'rate_limit_kbit_up', 0)),
				sprintf('trafficctl_device_limit_up_kbit{ip="%s",mode="shaper"} %d\n', ip, jnum(l, 'shape_kbit_up', 0)),
				sprintf('trafficctl_device_conntrack_bytes{ip="%s",proto="all"} %s\n', ip, f0(jnum(l, 'total', 0))),
				sprintf('trafficctl_device_conntrack_bytes{ip="%s",proto="tcp"} %s\n', ip, f0(jnum(l, 'tcp', 0))),
				sprintf('trafficctl_device_conntrack_bytes{ip="%s",proto="udp"} %s\n', ip, f0(jnum(l, 'udp', 0))),
				sprintf('trafficctl_device_blocked_bytes{ip="%s"} %s\n', ip, f0(jnum(l, 'block_bytes', 0))),
				// Names and MACs on an info metric, never on the counters:
				// label churn would start a new series for the same device.
				sprintf('trafficctl_device_info{ip="%s",name="%s",mac="%s",link="%s",app="%s",rdns="%s"} 1\n',
					ip, esc(jstr(l, 'name')), esc(jstr(l, 'mac')), esc(jstr(l, 'conn_type')),
					esc(jstr(l, 'app')), esc(rdns[ip] ?? '')));
		}
	}

	if (opt_on('portfw')) {
		push(o, '# HELP trafficctl_portfw_connections Active inbound connections per port forward.\n',
			'# TYPE trafficctl_portfw_connections gauge\n',
			'# HELP trafficctl_portfw_clients Distinct remote clients per port forward.\n',
			'# TYPE trafficctl_portfw_clients gauge\n',
			'# HELP trafficctl_portfw_paused Whether inbound traffic is paused.\n',
			'# TYPE trafficctl_portfw_paused gauge\n',
			'# HELP trafficctl_portfw_enabled Whether the firewall rule itself is enabled.\n',
			'# TYPE trafficctl_portfw_enabled gauge\n',
			'# HELP trafficctl_portfw_limit_kbit Inbound rate limit in kbit/s (0 = none).\n',
			'# TYPE trafficctl_portfw_limit_kbit gauge\n',
			'# HELP trafficctl_portfw_bytes Bytes currently accounted per port forward.\n',
			'# TYPE trafficctl_portfw_bytes gauge\n');
		// In process: the port-forward list is ucode too.
		let text = source_text(src.portfw ?? (() => portfw.main([ 'list' ]).reply));
		for (let l in json_lines(text)) {
			if (jstr(l, 'id') == '')
				continue;
			let lbl = sprintf('name="%s",proto="%s",port="%s"', esc(jstr(l, 'name')), esc(jstr(l, 'proto')),
				esc(jstr(l, 'ext_port')));
			push(o, sprintf('trafficctl_portfw_connections{%s} %d\n', lbl, jnum(l, 'conns', 0)),
				sprintf('trafficctl_portfw_clients{%s} %d\n', lbl, jnum(l, 'clients', 0)),
				sprintf('trafficctl_portfw_paused{%s} %d\n', lbl, (index(l, '"paused":true') >= 0) ? 1 : 0),
				sprintf('trafficctl_portfw_enabled{%s} %d\n', lbl, (index(l, '"enabled":true') >= 0) ? 1 : 0),
				sprintf('trafficctl_portfw_limit_kbit{%s} %d\n', lbl, jnum(l, 'limit_kbit', 0)),
				sprintf('trafficctl_portfw_bytes{%s,direction="rx"} %s\n', lbl, f0(jnum(l, 'bytes_in', 0))),
				sprintf('trafficctl_portfw_bytes{%s,direction="tx"} %s\n', lbl, f0(jnum(l, 'bytes_out', 0))));
		}
	}

	// Off by default: device x application is a cardinality trap.
	if (lib.uci_get('trafficctl', 'metrics', 'apps') == '1') {
		push(o, '# HELP trafficctl_app_bytes Bytes per device per application in the last DPI sample.\n',
			'# TYPE trafficctl_app_bytes gauge\n');
		for (let l in json_lines(source_text(src.netify ?? netify_list), ']},{')) {
			let m = lib.plain(l) ? match(l, /"ip":"([^"]*)"/) : null;
			if (!m)
				continue;
			let ip = m[1];
			// The whole app object, not just up to "bytes": "flows" follows.
			for (let r in match(l, /\{"name":"[^"]*","bytes":[0-9]+[^}]*\}/g) ?? []) {
				let app = match(r[0], /"name":"([^"]*)"/)[1], b = match(r[0], /"bytes":([0-9]+)/)[1];
				push(o, sprintf('trafficctl_app_bytes{ip="%s",app="%s"} %s\n', ip, app, f0(+b)));
				let fl = match(r[0], /"flows":([0-9]+)/);
				if (fl)
					push(o, sprintf('trafficctl_app_flows{ip="%s",app="%s"} %d\n', ip, app, +fl[1]));
			}
		}
	}

	push(o, '# HELP trafficctl_up Always 1; presence indicates the exporter ran.\n',
		'# TYPE trafficctl_up gauge\n',
		'trafficctl_up 1\n');
	return join('', o);
}

export { summary, device, metrics, netify };
