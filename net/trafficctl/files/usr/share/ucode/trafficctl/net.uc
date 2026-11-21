// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.net: what the router's network looks like to trafficctl.
//
//   lan_subnets()        [{ dev, base, block, router }], one per LAN L3 interface
//   lan_devices()        their devices, sorted and unique
//   lan_device()         network.lan's device, 'br-lan' by default
//   routed_subnets()     downstream subnets (via a LAN next hop) and
//                        trafficctl.main.extra_subnets; router is 0
//   monitored_subnets()  both, first entry per prefix wins
//   subnets()            the `subnets` command: [{ cidr, device, kind }]
//   ifaces()             the `ifaces` command: per-interface counters + roles
//   rdns(ip)             the `rdns` command: { ip, host }, null on bad input
//   rdns_refresh(ips)    the `rdns-refresh` command: fills the PTR cache
//   offload_mode()       none, software[-counter] or hardware[-counter]
//   ct_each(fn)          fn(rec) per /proc/net/nf_conntrack entry. rec is one
//                        object reused for every entry: { proto ('tcp', 'udp'
//                        or ''), osrc, odst, obytes, rsrc, rdst, rbytes }, o
//                        the original direction and r the reply; bytes are 0
//                        without accounting, rsrc/rdst null when missing
//   bytes()              the `bytes` command: one sample per device, from
//                        conntrack, flagged degraded under uncountered offload
//   totals(all, sample)  the `totals [--all]` command: lifetime totals
//                        accumulated from bytes() (from sample in tests)
//   reset()              drop the cached interface dump and LAN subnets, and
//                        lib.reset(); long-running callers call it per request
// MACs, for the IPv6 halves of the block and the limiter (#67)
//   lookup_mac(ip)       lease first, neighbour table second, lower case;
//                        null when neither knows a valid one
//   ip_is_nexthop(ip)    ip is the `via` of a route: a router, whose MAC is
//                        the source of everything it forwards
//   target_mac(t)        the MAC to key t's IPv6 rules on: null for a CIDR,
//                        a next hop, or a device without a known MAC
//   flush_v6(mac)        conntrack -D both ways for every IPv6 neighbour
//                        address of mac
//
// Subnet records are "netbase block router" as in v1.30's tctl_lan_subnets
// (trafficctl-fw.sh): tests/equiv.sh keeps them equal to that release.

import * as lib from 'trafficctl.lib';

let dump, lan_cache;
function iface_dump() {
	dump ??= lib.ubus_call('network.interface', 'dump')?.interface ?? [];
	return dump;
}

function reset() {
	dump = null;
	lan_cache = null;
	lib.reset();
}

// "LAN" = firewall zones that are not internet-facing: named lan, or neither
// wan/wan6 nor masqueraded. That keeps VPN zones (masqueraded) out.
function lan_subnets() {
	if (lan_cache)
		return lan_cache;

	let zones = [];
	// The shell walks @zone[i] until a name is missing; so does this.
	lib.uci_foreach('firewall', 'zone', (s) => {
		if (type(s.name) != 'string' || s.name == '')
			return false;
		push(zones, s);
	});

	let byname = {};
	for (let e in iface_dump())
		if (type(e?.interface) == 'string' && !exists(byname, e.interface))
			byname[e.interface] = e;

	let out = [];
	for (let z in zones) {
		if (z.name == 'wan' || z.name == 'wan6' || (z.name != 'lan' && z.masq == '1'))
			continue;
		let nets = (type(z.network) == 'array') ? join(' ', z.network) : '' + (z.network ?? '');
		for (let net in split(nets, /[ \t\n]+/)) {
			let e = (net != '') ? byname[net] : null;
			let a = e?.['ipv4-address']?.[0];
			let l3 = e?.l3_device, mask = a?.mask;
			if (type(l3) != 'string' || l3 == '' || !lib.valid_ip(a?.address) ||
			    type(mask) != 'int' || mask < 1 || mask > 32)
				continue;
			let ipint = lib.ip2int(a.address), block = 1 << (32 - mask);
			if (ipint == null)
				continue;
			push(out, { dev: l3, base: ipint - ipint % block, block, router: ipint });
		}
	}
	lan_cache = out;
	return out;
}

function lan_devices() {
	return sort(uniq(map(lan_subnets(), (s) => s.dev)));
}

function lan_device() {
	let d = lib.uci_get('network', 'lan', 'device');
	if (d == null || d == '')
		d = lib.uci_get('network', 'lan', 'ifname');
	return (d == null || d == '') ? 'br-lan' : d;
}

function routed_subnets() {
	let devs = lan_devices(), out = [];

	if (length(devs)) {
		for (let l in lib.lines('ip route show')) {
			let f = split(ltrim(l, ' \t'), /[ \t]+/);
			if (f[0] == 'default' || index(l, ' via ') < 0)
				continue;
			let dev = '';
			for (let i = 0; i < length(f); i++)
				if (f[i] == 'dev')
					dev = f[i + 1] ?? '';
			let spec = (dev != '' && index(devs, dev) >= 0) ? lib.cidr_spec(f[0]) : null;
			if (spec)
				push(out, { dev, base: spec.base, block: spec.block, router: 0 });
		}
	}

	let extras = lib.uci_words('trafficctl', 'main', 'extra_subnets');
	if (length(extras)) {
		let dev = lan_device();
		for (let c in extras) {
			let spec = lib.cidr_spec(c);
			if (spec)
				push(out, { dev, base: spec.base, block: spec.block, router: 0 });
		}
	}
	return out;
}

function monitored_subnets() {
	let seen = {}, out = [];
	for (let s in [ ...lan_subnets(), ...routed_subnets() ]) {
		let k = s.base + ':' + s.block;
		if (!exists(seen, k)) {
			seen[k] = true;
			push(out, s);
		}
	}
	return out;
}

// Exactly the set a limit can be enforced on: the policing hooks attach to
// the devices these subnets resolve to.
function subnets() {
	return map(monitored_subnets(), (s) => {
		let mask = 32;
		for (let b = s.block; b > 1; b = b >> 1)
			mask--;
		return {
			cidr: lib.int2ip(s.base) + '/' + mask,
			device: s.dev,
			kind: (s.router == 0) ? 'routed' : 'lan'
		};
	});
}

// ── ifaces: per-interface counters for the global overview ──────────────────
//
// The hot path is one read of /proc/net/dev plus sysfs operstate. Roles need
// uci, ubus and `ip route`, so they are memoised in tmpfs for TTL seconds in
// the format trafficctl-device.sh also reads:
//   # <epoch>
//   <dev> <role> <tunnel> <primary> <defroute> <enslaved> <label|->

const IFROLES = '/tmp/trafficctl_ifroles';
const IFROLES_TTL = 60;
const SYSFS = '/sys/class/net';

// ppp* is absent on purpose: pppoe-wan is the usual DSL uplink, not a VPN.
const TUN_RE = /^(wg|awg|tun|tap|gre|sit|vti|ipsec|ip6tnl|xfrm|zt|nordlynx|tailscale|l2tp|pptp)/;

function netdev_rows(text) {
	let rows = [], l = split(text, '\n');
	for (let i = 2; i < length(l); i++) {
		let c = index(l[i], ':');
		if (c < 0)
			continue;
		let dev = replace(substr(l[i], 0, c), /[ \t]/g, '');
		if (dev != '' && dev != 'lo')
			push(rows, { dev, rest: substr(l[i], c + 1) });
	}
	return rows;
}

// Which of several uci interfaces on one device names it: wan over wan6 over
// wan6_alias0, whatever order the dump uses. Lower wins.
function label_score(n) {
	return (index(n, '_alias') >= 0 ? 4 : 0) + (match(n, /6$|6_/) ? 2 : 0);
}

function label_better(n, old, s, olds) {
	return s < olds || (s == olds && (length(n) < length(old) ||
		(length(n) == length(old) && n < old)));
}

function build_roles(rows, now) {
	let isdef = {}, islan = {}, isuciwan = {}, lbl = {}, lblscore = {};

	for (let d in lan_devices())
		islan[d] = true;

	// Default-route holders, v4 or v6. Not the same as the WAN: a full-tunnel
	// router routes via awg0 while the uplink carries the encapsulated bytes.
	for (let l in lib.lines('ip -4 route show default; ip -6 route show default')) {
		let f = split(ltrim(l, ' \t'), /[ \t]+/);
		for (let i = 0; i < length(f) - 1; i++)
			if (f[i] == 'dev')
				isdef[f[i + 1]] = true;
	}

	for (let e in iface_dump()) {
		let d = e?.l3_device, n = e?.interface;
		if (type(d) != 'string' || d == '' || type(n) != 'string' || n == '')
			continue;
		// Any uci wan/wan6 (or alias) marks the uplink, even if something else
		// holds the default route now.
		if (match(n, /^wan6?$|^wan6?_/))
			isuciwan[d] = true;
		let s = label_score(n);
		if (!exists(lbl, d) || label_better(n, lbl[d], s, lblscore[d])) {
			lbl[d] = n;
			lblscore[d] = s;
		}
	}

	let roles = {}, nwan = 0;
	for (let r in rows) {
		let d = r.dev;
		let tun = !!match(d, TUN_RE);
		// A bridge port reports the same bytes as its bridge.
		let ens = length(lib.readfile(SYSFS + '/' + d + '/master/ifindex') ?? '') > 0;
		let role = 'other';
		// Tunnels before default routes; see above.
		if (ens)
			role = 'other';
		else if (islan[d])
			role = 'lan';
		else if (tun)
			role = 'vpn';
		else if (isuciwan[d] || isdef[d]) {
			role = 'wan';
			nwan++;
		}
		roles[d] = { role, tun, prim: false, dfr: !!isdef[d], ens, lbl: lbl[d] ?? '-' };
	}

	// No uplink at all (tunnel-only router): promote the route holder, or
	// the overview has no headline row.
	if (!nwan)
		for (let r in rows)
			if (isdef[r.dev] && !roles[r.dev].ens)
				roles[r.dev].role = 'wan';

	// Exactly one primary: the headline graph shows it rather than a sum,
	// which would double-count a failover pair.
	let prim = null;
	for (let test in [ (d) => isuciwan[d], (d) => isdef[d], (d) => true ]) {
		for (let r in rows)
			if (roles[r.dev].role == 'wan' && test(r.dev)) {
				prim = r.dev;
				break;
			}
		if (prim != null)
			break;
	}
	if (prim != null)
		roles[prim].prim = true;

	let text = sprintf('# %d\n', now);
	for (let r in rows) {
		let x = roles[r.dev];
		text += sprintf('%s %s %d %d %d %d %s\n', r.dev, x.role,
			x.tun ? 1 : 0, x.prim ? 1 : 0, x.dfr ? 1 : 0, x.ens ? 1 : 0, x.lbl);
	}
	lib.write_atomic(IFROLES, text);
	return roles;
}

// awk's string-to-number: the leading digits, 0 if none. Declared before its
// callers: ucode resolves names at compile time, without hoisting.
function num(s) {
	let m = match(s, /^[0-9]+/);
	return m ? int(m[0]) : 0;
}

function read_roles() {
	let l = lib.file_lines(IFROLES), roles = {};
	// "# <epoch>": the shell read it with `read -r _hash TS`.
	let m = match(l[0] ?? '', /^[ \t]*[^ \t]+[ \t]+(.*)$/);
	let ts = lib.valid_int(rtrim(m?.[1] ?? '', ' \t')) ?? 0;
	for (let x in l) {
		if (substr(x, 0, 1) == '#')
			continue;
		let f = split(trim(x, ' \t'), /[ \t]+/);
		if (length(f) < 7)
			continue;
		roles[f[0]] = { role: f[1], tun: num(f[2]) != 0, prim: num(f[3]) != 0,
			dfr: num(f[4]) != 0, ens: num(f[5]) != 0, lbl: f[6] };
	}
	return { ts, roles };
}

function emit(rows, roles) {
	let out = [], miss = false;
	for (let r in rows) {
		// Split after the colon: a name that fills the padded column leaves
		// no space before rx_bytes.
		let c = split(ltrim(r.rest, ' \t'), /[ \t]+/);
		if (length(c) < 16)
			continue;
		let x = roles[r.dev];
		if (!x)
			miss = true;
		let state = split(lib.readfile(SYSFS + '/' + r.dev + '/operstate') ?? '', '\n')[0];
		let name = replace(r.dev, /["\\]/g, '');
		let label = (x && x.lbl != '' && x.lbl != '-') ? replace(x.lbl, /["\\]/g, '') : name;
		push(out, {
			dev: name,
			label,
			role: x ? x.role : 'other',
			tunnel: !!x?.tun,
			primary: !!x?.prim,
			defroute: !!x?.dfr,
			enslaved: !!x?.ens,
			// A tunnel that is down but still holds counters is worth showing.
			up: state == 'up' || state == 'unknown',
			rx_bytes: num(c[0]),
			tx_bytes: num(c[8])
		});
	}
	return { out, miss };
}

function ifaces() {
	let text = lib.readfile('/proc/net/dev');
	if (text == null)
		return [];
	let rows = netdev_rows(text), now = time();
	let cache = read_roles();
	let roles = (now - cache.ts >= IFROLES_TTL) ? build_roles(rows, now) : cache.roles;
	let r = emit(rows, roles);
	// A device the cached map has never seen (a tunnel came up): classify it
	// now rather than after the TTL. One rebuild covers every current device.
	if (r.miss)
		r = emit(rows, build_roles(rows, now));
	return r.out;
}

// ── reverse DNS ─────────────────────────────────────────────────────────────

const RDNS_CACHE = '/tmp/trafficctl_rdns_cache';
const RDNS_LOCK = '/tmp/trafficctl_rdns.lock';
// A refresher killed mid-run leaves its lock behind (no signal handling).
const RDNS_LOCK_STALE = 300;
// Stop well before the lock could be taken as stale; the rest waits for the
// next poll.
const RDNS_MAX_RUN = 240;
const NSLOOKUP_MS = 5000;
const NAME_LINE = regexp('^Name:[ \t]*(.*)$');

function rrdns(ip) {
	let r = lib.ubus_call('network.rrdns', 'lookup', { addrs: [ ip ], timeout: 2000, limit: 1 });
	return (type(r?.[ip]) == 'string') ? r[ip] : '';
}

function nslookup(ip, srv) {
	return lib.lines('nslookup ' + lib.q(ip) + (srv ? ' ' + lib.q(srv) : ''), NSLOOKUP_MS);
}

function rdns(ip) {
	if (!lib.valid_ip(ip))
		return null;
	let host = rrdns(ip);
	if (host == '')
		for (let l in nslookup(ip)) {
			let m = match(l, /^.*name = (.*)\.$/);
			if (m) {
				host = m[1];
				break;
			}
		}
	return { ip, host: (lib.plain(host) && match(host, /^[a-zA-Z0-9._-]+$/)) ? host : '' };
}

function ptr_name(ls) {
	for (let l in ls) {
		let m = match(l, /^.*name = ([^ ]*)\.$/) ?? match(l, NAME_LINE);
		if (m)
			return m[1];
	}
	return '';
}

// trafficctl.main.rdns_server first (point it at a downstream router), then
// the system resolver. Bare host names, '' when there is none.
function resolve(ip, servers) {
	let host = '';
	for (let srv in servers) {
		host = ptr_name(nslookup(ip, srv));
		if (host != '')
			break;
	}
	if (host == '')
		host = rrdns(ip);
	if (host == '')
		host = ptr_name(nslookup(ip));
	// Some resolvers echo the reverse zone instead of NXDOMAIN.
	if (!lib.plain(host) || index(host, 'in-addr.arpa') >= 0 || !match(host, /^[a-zA-Z0-9._-]+$/))
		return '';
	return split(host, '.')[0];
}

// Cache lines "IP HOST TIMESTAMP", HOST '-' = no record. Run detached from the
// summary poll: resolving is slow and must never block the device table.
function cache_put(ip, host, now) {
	let l = filter(lib.file_lines(RDNS_CACHE), (x) => lib.field(x, 0) != ip);
	push(l, sprintf('%s %s %d', ip, (host != '') ? host : '-', now));
	lib.write_atomic(RDNS_CACHE, join('\n', l) + '\n');
}

function rdns_refresh(ips) {
	if (!lib.lock(RDNS_LOCK, 0, RDNS_LOCK_STALE))
		return;
	let servers = lib.uci_words('trafficctl', 'main', 'rdns_server');
	let now = time();
	for (let ip in ips) {
		if (time() - now >= RDNS_MAX_RUN)
			break;
		if (lib.valid_ip(ip))
			cache_put(ip, resolve(ip, servers), now);
	}
	lib.unlock(RDNS_LOCK);
}

// ── conntrack ───────────────────────────────────────────────────────────────

const CONNTRACK = '/proc/net/nf_conntrack';

// The value of the first `key` (' dst=', say) in s, up to the next space;
// null if there is none.
function kv(s, key) {
	let i = index(s, key);
	if (i < 0)
		return null;
	s = substr(s, i + length(key));
	i = index(s, ' ');
	return (i < 0) ? s : substr(s, 0, i);
}

// B of an "A dst=B ..." half, whose words are w: the kernel prints src= and
// dst= side by side, so it is the second word (looked up for anything else).
function ct_dst(h, w) {
	let d = w[1];
	return (d != null && substr(d, 0, 4) == 'dst=') ? substr(d, 4) : kv(h, ' dst=');
}

// A byte count as awk read it: the leading digits, 0 without.
function count(s) {
	let n = (s == null) ? 0 : int(s);
	return (n == n) ? n : 0;
}

// "ipv4 2 tcp 6 431999 ESTABLISHED src=A dst=B ... bytes=N src=B dst=A ...
// bytes=M [ASSURED] ...": the second src= starts the reply direction. Cut
// with index() and split() rather than a regex or a walk over every field:
// this runs for every entry, up to 16k of them, every few seconds. (Measured
// on 16k entries: a regex match per line is ~1.4x and a field walk ~4x the
// time of this.)
function ct_parse(l, rec) {
	let p = index(l, ' src=');
	if (p < 0)
		return false;
	// The protocol is a bare word in the header, before any key=value.
	let head = substr(l, 0, p);
	rec.proto = (index(head, ' tcp ') >= 0) ? 'tcp' : (index(head, ' udp ') >= 0) ? 'udp' : '';
	let h = split(substr(l, p + 5), ' src=', 2), o = h[0], r = h[1];
	let w = split(o, ' ', 3);
	rec.osrc = w[0];
	rec.odst = ct_dst(o, w);
	rec.obytes = count(kv(o, ' bytes='));
	if (r == null) {
		rec.rsrc = null;
		rec.rdst = null;
		rec.rbytes = 0;
		return true;
	}
	w = split(r, ' ', 3);
	rec.rsrc = w[0];
	rec.rdst = ct_dst(r, w);
	rec.rbytes = count(kv(r, ' bytes='));
	return true;
}

function ct_each(fn) {
	let rec = {};
	lib.each_line(CONNTRACK, (l) => {
		if (ct_parse(l, rec))
			fn(rec);
	});
}

// ── per-device byte samples ─────────────────────────────────────────────────
//
// [{ ip, bytes_in, bytes_out, bytes_tcp, bytes_udp, src, degraded }]
//
// src names the counter source, always 'ct' now. Up to 1.30.x it could also be
// 'nft' (per-address counter maps, counting since their table was built), and
// totals() still meets that in old state files: the magnitudes are unrelated,
// so it rebaselines on a source change instead of reading it as traffic.
//
// degraded says whether the numbers can be believed at all: true only under
// offload whose flowtable has no counter (fw4 on 22.03, or a custom one). An
// offloaded flow then bypasses conntrack accounting, and nothing else can
// count it: the flowtable hooks netdev ingress, so its packets never reach an
// inet forward chain at any priority, and counting downloads on the way out
// would need a netdev egress hook (kernel 5.16+). It is separate from src on
// purpose: src is about magnitude (and drives the rebaseline), degraded is
// about trust; folding them together would make a change in trust look like a
// change of counter and throw a delta away for nothing.
//
// bytes_tcp/bytes_udp are both directions summed.
//
// Arrays are sorted by address; the shell printed awk hash order.

function offload_mode() {
	let sw, hw;
	lib.uci_foreach('firewall', 'defaults', (s) => {
		sw = s.flow_offloading;
		hw = s.flow_offloading_hw;
		return false;
	});
	if (hw != '1' && sw != '1')
		return 'none';
	// A counter-flagged flowtable syncs offloaded byte counts back to
	// conntrack (kernel 5.7+; fw4 declares it from 23.05 on), so conntrack
	// stays accurate under software offload. Hardware offload also needs the
	// driver to report its byte counts, and some (Mediatek Filogic) do not,
	// so the counts can freeze even with the flag; nothing here can see that,
	// and the UI warns about it. fw4 on 22.03 declares no flag at all: the
	// counts of every offloaded flow freeze, which is what degraded flags.
	let counted = index(lib.run('nft list flowtables'), 'counter') >= 0;
	return ((hw == '1') ? 'hardware' : 'software') + (counted ? '-counter' : '');
}

// Offload whose fast path the conntrack counters never see.
function uncountered(mode) {
	return mode != 'none' && substr(mode, -8) != '-counter';
}

function by_ip(a, b) {
	let x = lib.ip2int(a), y = lib.ip2int(b);
	if (x == null || y == null)
		return (x != null) ? -1 : (y != null) ? 1 : (a < b) ? -1 : (a > b) ? 1 : 0;
	return x - y;
}

function sorted_ips(o) {
	return sort(keys(o), by_ip);
}

function local_ips() {
	let out = {};
	for (let l in lib.lines('ip -4 addr show')) {
		if (index(l, 'inet ') < 0)
			continue;
		let a = split(lib.field(l, 1), '/')[0];
		if (a != '')
			out[a] = true;
	}
	return out;
}

function bytes_ct(degraded) {
	let subs = monitored_subnets();
	if (!length(subs))
		return [];

	// Membership per address, not per entry: the table holds a few hundred
	// addresses in up to 16k entries.
	let lan = {}, locals = null, acc = {};
	let is_lan = (ip) => {
		if (exists(lan, ip))
			return lan[ip];
		let n = lib.ip2int(ip), hit = false;
		if (n != null)
			for (let s in subs)
				if (n - n % s.block == s.base) {
					hit = true;
					break;
				}
		lan[ip] = hit;
		return hit;
	};

	ct_each((c) => {
		let src = is_lan(c.osrc) ? c.osrc : (c.rsrc != null && is_lan(c.rsrc)) ? c.rsrc : null;
		// NAT fallback: SNAT/masqueraded here (reply dst != original src),
		// so the original source is a forwarded client even outside every
		// monitored subnet (behind a downstream router, say). The router's
		// own addresses are not clients; read only when first needed.
		if (src == null && c.rdst != null && c.rdst != c.osrc && lib.ip2int(c.osrc) != null) {
			locals ??= local_ips();
			if (!locals[c.osrc])
				src = c.osrc;
		}
		if (src == null)
			return;
		let a = acc[src];
		if (!a)
			a = acc[src] = [ 0, 0, 0, 0 ];
		a[0] += c.rbytes;
		a[1] += c.obytes;
		// Both directions: the split answers how much of this device's
		// traffic was TCP, which is not a question about direction.
		if (c.proto == 'tcp')
			a[2] += c.obytes + c.rbytes;
		else if (c.proto == 'udp')
			a[3] += c.obytes + c.rbytes;
	});

	return map(sorted_ips(acc), (ip) => ({
		ip, bytes_in: acc[ip][0], bytes_out: acc[ip][1], bytes_tcp: acc[ip][2],
		bytes_udp: acc[ip][3], src: 'ct', degraded: !!degraded
	}));
}

// Logged once per offload mode, not per sample: bytes() runs on every poll.
// One marker per uncountered mode, created exclusively, so of two samplers
// running at once only one logs, and the log follows a successful write: a
// full tmpfs costs the warning, never a warning per poll. tmpfs, so a reboot
// says it again; the markers go once offload is countered again, so turning
// it back off later is reported too.
const OFFLOAD_HINT = '/tmp/trafficctl_offload_hint';
const UNCOUNTERED = ['software', 'hardware'];

function offload_hint(mode) {
	for (let m in UNCOUNTERED)
		if (m != mode)
			lib.remove(OFFLOAD_HINT + '.' + m);
	if (!uncountered(mode) || !lib.create_once(OFFLOAD_HINT + '.' + mode, mode + '\n'))
		return;
	lib.sh('logger -t trafficctl -p daemon.warn ' + lib.q('flow offload (' + mode +
		') has no flowtable counter, so offloaded connections are not counted ' +
		'and device speeds and totals are reported as degraded. Disable flow ' +
		'offloading, or upgrade to OpenWrt 23.05 or later, whose firewall counts them.'));
}

// Offload without a flowtable counter keeps conntrack's counters frozen for
// every offloaded flow, so the sample is a lower bound that stalls while
// traffic continues: a total built from it would look authoritative, hence
// degraded, which the UI and the exporter refuse to present as a total.
function bytes() {
	let mode = offload_mode();
	offload_hint(mode);
	return bytes_ct(uncountered(mode));
}

// ── lifetime totals ─────────────────────────────────────────────────────────
//
// Conntrack is no lifetime total (issue #26): it forgets a flow's bytes when
// the flow expires. So positive deltas are accumulated here, the one store behind both the LuCI
// Bytes/TCP/UDP columns and trafficctl_device_bytes_total.
//
// The store is tmpfs, rewritten on every poll and scrape: totals reset on
// reboot, and flash is not worn. One line per device, in the shell's format,
// which the shell writer (still running during an upgrade) and 1.30.x (after
// a downgrade) read too:
//   ip rx_acc tx_acc rx_last tx_last seen tcp_acc udp_acc tcp_last udp_last
//   src since degraded
// Shorter lines from older versions still load: 5 or 6 fields (the exporter's
// own store before this one), 10 (protocol split), 12 (source and start).
//
// Output: the bytes() array plus bytes_in_total, bytes_out_total,
// bytes_tcp_total, bytes_udp_total (-1 while there is no protocol baseline:
// a state line from before the split, or from 1.30.x on the nft maps, which
// could not split), total_since and live. With all, also devices no longer sampled
// that carry a total, so a Prometheus series does not vanish whenever a quiet
// device's last flow expires; their current readings are -1.
//
// degraded is sticky per device: a total that took in one frozen sample stays
// understated for the rest of its life, so a later healthy sample must not
// re-present it as trustworthy.

const TOTALS_STATE = '/tmp/trafficctl_totals.state';
// The shell's lock directory, held the shell's way (an empty directory) so
// either writer can take it over from the other.
const TOTALS_LOCK = '/tmp/trafficctl_totals.lock.d';
// The shell waited 30 x 100 ms, then took the lock regardless. This one takes
// a bare lock over only at TOTALS_LOCK_STALE seconds of age, so the wait must
// outlast that: 30 tries end 2.9 s after the first, when a lock made just
// before it still read 2 s old, and the write went ahead unlocked and left
// the lock to the next caller. The first try is at once, so 32 span 3.1 s,
// past 3 s plus a tick of the coarse clock that time() and mtime both read.
const TOTALS_LOCK_TRIES = 32;
const TOTALS_LOCK_STALE = 3;

// What awk's "$n + 0" gave for the shell's numbers.
function snum(s) {
	let n = int(s);
	return (n == n) ? n : 0;
}

function totals_load(now) {
	let st = {};
	for (let l in lib.file_lines(TOTALS_STATE)) {
		let f = split(trim(l), /[ \t]+/), n = length(f);
		if (n < 5)
			continue;
		// Field by field, as awk did: a later line for the same address
		// overwrites what it carries and keeps the rest.
		let r = st[f[0]];
		if (!r)
			r = st[f[0]] = { tca: 0, uda: 0 };
		r.rxa = snum(f[1]);
		r.txa = snum(f[2]);
		r.rxl = snum(f[3]);
		r.txl = snum(f[4]);
		r.seen = (n >= 6) ? snum(f[5]) : now;
		if (n >= 10) {
			r.tca = snum(f[6]);
			r.uda = snum(f[7]);
			r.tcl = snum(f[8]);
			r.udl = snum(f[9]);
		}
		else {
			r.tcl = -1;
			r.udl = -1;
		}
		r.src = (n >= 11) ? f[10] : '?';
		r.since = (n >= 12) ? snum(f[11]) : now;
		r.deg = (n >= 13 && f[12] == 'true');
	}
	return st;
}

// A sample reading: -1 for missing or not a count, as the shell's num().
function reading(v) {
	return (type(v) == 'int' && v >= 0) ? v : -1;
}

// One protocol counter: [ acc, last ] after reading v.
function proto_step(acc, last, v, switched) {
	if (v < 0)
		// No split in this sample: forget the baseline, or whatever moved
		// meanwhile lands as one fake delta when the split returns.
		return [ acc, -1 ];
	if (!switched)
		acc += (last < 0) ? v : (v > last) ? v - last : 0;
	return [ acc, v ];
}

function totals_apply(st, sample, now) {
	let live = {};
	for (let e in sample) {
		let ip = e?.ip;
		if (type(ip) != 'string' || ip == '')
			continue;
		let rx = reading(e.bytes_in), tx = reading(e.bytes_out);
		let tcv = reading(e.bytes_tcp), udv = reading(e.bytes_udp);
		let s = (type(e.src) == 'string' && e.src != '') ? e.src : '?';
		if (rx < 0)
			rx = 0;
		if (tx < 0)
			tx = 0;

		let r = st[ip], known = (r != null);
		// A source switch (a 1.30.x state line on the nft maps, which
		// counted since their table was built, meeting conntrack's live
		// flows) is a jump that is not traffic, so this tick only takes a
		// new baseline. Trust (degraded) is no part of it:
		// conntrack counters are continuous across a change in trust.
		let switched = known && r.src != '?' && s != '?' && r.src != s;
		if (!known)
			r = st[ip] = { rxa: 0, txa: 0, tca: 0, uda: 0, tcl: -1, udl: -1, deg: false };

		if (known && !switched) {
			// Only upward movement is traffic. A drop means flows expired,
			// and their bytes were counted while they lived.
			if (rx > r.rxl)
				r.rxa += rx - r.rxl;
			if (tx > r.txl)
				r.txa += tx - r.txl;
		}
		else if (!switched) {
			// No baseline yet: the sample is the starting point.
			r.rxa += rx;
			r.txa += tx;
			r.since = now;
		}
		r.rxl = rx;
		r.txl = tx;
		let t = proto_step(r.tca, r.tcl, tcv, switched);
		r.tca = t[0];
		r.tcl = t[1];
		t = proto_step(r.uda, r.udl, udv, switched);
		r.uda = t[0];
		r.udl = t[1];

		r.src = s;
		if (e.degraded === true)
			r.deg = true;
		r.seen = now;
		r.cur = [ rx, tx, tcv, udv ];
		live[ip] = true;
	}
	return live;
}

function totals_text(st, ips, live) {
	let text = '';
	for (let ip in ips) {
		let r = st[ip];
		// A quiet device without a total goes, or the file grows without
		// bound on a busy network.
		if (!live[ip] && r.rxa + r.txa + r.tca + r.uda == 0)
			continue;
		text += sprintf('%s %d %d %d %d %d %d %d %d %d %s %d %s\n', ip, r.rxa, r.txa,
			r.rxl, r.txl, r.seen, r.tca, r.uda, r.tcl, r.udl, r.src,
			r.since, r.deg ? 'true' : 'false');
	}
	return text;
}

function totals(all, sample) {
	// Sampled before the lock: reading conntrack is by far the slowest part,
	// and holding the lock across it would queue every poll behind it (two
	// browser tabs would then hit the steal path, which is for a killed
	// writer, not for load).
	// A failed sample is an empty one, as the shell's empty pipe was: the
	// stored devices still print under --all, and nothing is accumulated.
	if (sample == null) {
		try {
			sample = bytes();
		}
		catch (e) {
			warn(sprintf('trafficctl totals: no sample: %s\n', e.message));
			sample = [];
		}
	}

	// Without the lock a LuCI poll and a metrics scrape landing together
	// read the same state, and the later writer drops the earlier delta. Not
	// getting it within the shell's wait means a killed holder: carry on, as
	// the shell did, rather than stop accumulating.
	let locked = lib.lock(TOTALS_LOCK, TOTALS_LOCK_TRIES, TOTALS_LOCK_STALE, true);
	let now = time(), st, live, ips;
	// Released on an exception too: a bare lock has no pid for the next
	// writer to find dead, so a leak would cost every caller the full wait
	// for TOTALS_LOCK_STALE.
	try {
		st = totals_load(now);
		live = totals_apply(st, sample, now);
		ips = sorted_ips(st);
		lib.write_atomic(TOTALS_STATE, totals_text(st, ips, live));
	}
	catch (e) {
		if (locked)
			lib.unlock(TOTALS_LOCK);
		die(e.message);
	}
	if (locked)
		lib.unlock(TOTALS_LOCK);

	let out = [];
	for (let ip in ips) {
		let r = st[ip], on = !!live[ip];
		if (!on && !all)
			continue;
		// No current reading for a device absent from this sample: its last
		// one would be a frozen number that looks live.
		let c = on ? r.cur : [ -1, -1, -1, -1 ];
		push(out, {
			ip, bytes_in: c[0], bytes_out: c[1], bytes_tcp: c[2], bytes_udp: c[3],
			src: r.src, degraded: r.deg,
			bytes_in_total: r.rxa, bytes_out_total: r.txa,
			// -1, never 0, without a protocol baseline: 0 would claim the
			// device sent no TCP. Keyed off the stored baseline, so a quiet
			// device under --all keeps the history it has.
			bytes_tcp_total: (r.tcl >= 0) ? r.tca : -1,
			bytes_udp_total: (r.udl >= 0) ? r.uda : -1,
			total_since: r.since, live: on
		});
	}
	return out;
}

// ── MACs (tctl_lookup_mac, tctl_ip_is_nexthop, tctl_target_mac) ─────────────

const LEASES = '/tmp/dhcp.leases';

// The value is interpolated into an nft rule, so only six hex pairs pass. A
// lease that names a broken MAC is not overridden by the neighbour table:
// the shell did not look further either.
function lookup_mac(ip) {
	if (!lib.valid_ip(ip))
		return null;
	let mac = null;
	for (let l in lib.file_lines(LEASES))
		if (lib.field(l, 2) == ip) {
			mac = lib.field(l, 1);
			break;
		}
	if (mac == null || mac == '') {
		mac = null;
		for (let l in lib.lines('ip neigh show')) {
			let f = split(ltrim(l, ' \t'), /[ \t]+/);
			if (f[0] != ip)
				continue;
			for (let i = 1; i < length(f) - 1; i++)
				if (f[i] == 'lladdr') {
					mac = f[i + 1];
					break;
				}
			if (mac != null)
				break;
		}
	}
	return lib.norm_mac(mac);
}

function ip_is_nexthop(ip) {
	if (ip == null || ip == '')
		return false;
	for (let l in lib.lines('ip route show')) {
		let f = split(ltrim(l, ' \t'), /[ \t]+/);
		for (let i = 0; i < length(f) - 1; i++)
			if (f[i] == 'via' && f[i + 1] == ip)
				return true;
	}
	return false;
}

function target_mac(t) {
	t = '' + (t ?? '');
	if (substr(t, -3) == '/32')
		t = substr(t, 0, -3);
	else if (index(t, '/') >= 0)
		return null;
	return ip_is_nexthop(t) ? null : lookup_mac(t);
}

// `conntrack -D -s <v4>` leaves the device's IPv6 flows alone, and under flow
// offload an established one is never checked against a new rule again. The
// addresses come from a one-shot snapshot, which is sound for a flush and
// would not be for a rule: privacy addresses rotate.
const CT_MS = 5000;

function flush_v6(mac) {
	mac = lib.norm_mac(mac);
	if (mac == null || lib.sh('command -v conntrack') != 0)
		return;
	for (let l in lib.lines('ip -6 neigh show')) {
		let f = split(ltrim(l, ' \t'), /[ \t]+/);
		for (let i = 1; i < length(f) - 1; i++) {
			if (f[i] != 'lladdr' || lc(f[i + 1]) != mac)
				continue;
			if (match(f[0], /^[0-9a-fA-F:]+$/)) {
				lib.sh('conntrack -D -f ipv6 -s ' + lib.q(f[0]), CT_MS);
				lib.sh('conntrack -D -f ipv6 -d ' + lib.q(f[0]), CT_MS);
			}
			break;
		}
	}
}

// 2022-12 needs a ';' after `export function f() {}`; one list avoids it.
export { lan_subnets, lan_devices, lan_device, routed_subnets,
	monitored_subnets, subnets, ifaces, rdns, rdns_refresh, offload_mode, ct_each,
	bytes, totals, reset, local_ips, lookup_mac, ip_is_nexthop, target_mac, flush_v6 };
