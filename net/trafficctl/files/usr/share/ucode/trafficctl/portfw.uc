// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.portfw: inbound port-forward control, `trafficctl portfw ...`
// (the "Port Forwards" tab).
//
//   main(args)   list | pause|resume <forward|input> <tcp|udp|tcpudp> <ip|-> <port>
//                | limit <...> <rate_kbit>: { reply, rc }
//   restore()    the pfw_pause and pfw_limit records of rules.json, put back
//                on ifup lan while persist_rules is on: { ok, restored, failed }
//
// Own table inet tctl_pfw, chains at forward/input priority -190 (after DNAT,
// before fw4's flow offload rule). A rule's comment,
// tctl_pfw_<pause|limit>_<proto>_<ip|local>_<port>, is the only record of
// what is paused or limited; it is matched whole, quotes included.
// Commands, rule text and replies are those of trafficctl-portfw.sh v1.30.0.

import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as ctl from 'trafficctl.ctl';

const CHAINS = [ 'pfw_forward', 'pfw_input' ];
const RATE_MAX_KBIT = 100000000;

const USAGE = 'usage: trafficctl portfw <list|pause|resume|limit> ...';
const USAGE_PAUSE = 'usage: trafficctl portfw pause|resume <forward|input> <tcp|udp|tcpudp> <ip|-> <port>';
const USAGE_LIMIT = 'usage: trafficctl portfw limit <forward|input> <tcp|udp|tcpudp> <ip|-> <port> <rate_kbit>';

function str(v) {
	return (v == null) ? '' : '' + v;
}

function digits(s) {
	return lib.plain(s) && !!match(s, /^[0-9]+$/);
}

// test(1)'s view of a digit string: past int64 it fails, never compares.
function num(s) {
	return (length(s) <= 18) ? int(s) : null;
}

function in_port_range(n) {
	return n != null && n >= 1 && n <= 65535;
}

// N or lo-hi, as the shell's glob took them: lo before the first '-', hi
// after the last.
function valid_port(s) {
	if (!lib.plain(s))
		return false;
	if (match(s, /^[0-9].*-[0-9]/)) {
		let lo = substr(s, 0, index(s, '-')), hi = substr(s, rindex(s, '-') + 1);
		if (!digits(lo) || !digits(hi))
			return false;
		lo = num(lo);
		hi = num(hi);
		return in_port_range(lo) && in_port_range(hi) && lo <= hi;
	}
	return digits(s) && in_port_range(num(s));
}

function proto_tokens(p) {
	switch (str(p)) {
	case 'tcpudp': case 'tcp udp': case 'udp tcp': case 'all': case '':
		return [ 'tcp', 'udp' ];
	case 'tcp':
		return [ 'tcp' ];
	case 'udp':
		return [ 'udp' ];
	}
	return null;
}

function comment(kind, proto, ip, port) {
	return sprintf('tctl_pfw_%s_%s_%s_%s', kind, proto, ip, port);
}

// ── nft ─────────────────────────────────────────────────────────────────────

function nft(argv) {
	return lib.sh('nft ' + lib.qv(argv));
}

function ensure_table() {
	nft([ 'add', 'table', 'inet', 'tctl_pfw' ]);
	nft([ 'add', 'chain', 'inet', 'tctl_pfw', 'pfw_forward',
		'{ type filter hook forward priority -190; policy accept; }' ]);
	nft([ 'add', 'chain', 'inet', 'tctl_pfw', 'pfw_input',
		'{ type filter hook input priority -190; policy accept; }' ]);
}

function delete_by_comment(cmt) {
	let q = '"' + cmt + '"';
	for (let chain in CHAINS)
		for (let l in lib.lines('nft -a list chain inet tctl_pfw ' + lib.q(chain))) {
			if (index(l, q) < 0)
				continue;
			for (let m in match(l, /handle ([0-9]+)/g) ?? [])
				nft([ 'delete', 'rule', 'inet', 'tctl_pfw', chain, 'handle', m[1] ]);
		}
}

// The match half of a rule: a forward has its LAN host, an open port none.
function rule_match(scope, proto, ip, port) {
	return (scope == 'input') ? [ proto, 'dport', port ] : [ 'ip', 'daddr', ip, proto, 'dport', port ];
}

function chain_for(scope) {
	return (scope == 'input') ? 'pfw_input' : 'pfw_forward';
}

function add_pause(scope, proto, ip, cmt_ip, port) {
	ensure_table();
	return nft([ 'insert', 'rule', 'inet', 'tctl_pfw', chain_for(scope),
		...rule_match(scope, proto, ip, port), 'counter', 'drop',
		'comment', '"' + comment('pause', proto, cmt_ip, port) + '"' ]) == 0;
}

function add_limit(scope, proto, ip, cmt_ip, port, kbit) {
	let b = kbit * 125;
	ensure_table();
	return nft([ 'add', 'rule', 'inet', 'tctl_pfw', chain_for(scope),
		...rule_match(scope, proto, ip, port), 'limit', 'rate', 'over', '' + ((b < 1) ? 1 : b),
		'bytes/second', 'counter', 'drop',
		'comment', '"' + comment('limit', proto, cmt_ip, port) + '"' ]) == 0;
}

function flush_conntrack(proto, ip, port) {
	if (lib.sh('command -v conntrack') != 0)
		return;
	if (ip != '' && ip != '-') {
		lib.sh('conntrack -D -p ' + lib.qv([ proto, '--reply-src', ip ]));
		return;
	}
	let lo = substr(port, 0, index(port, '-') < 0 ? length(port) : index(port, '-'));
	let hi = substr(port, rindex(port, '-') + 1);
	if (lo == hi || num(hi) - num(lo) > 64) {
		lib.sh('conntrack -D -p ' + lib.qv([ proto, '--dport', lo ]));
		return;
	}
	for (let p = num(lo); p <= num(hi); p++)
		lib.sh('conntrack -D -p ' + lib.qv([ proto, '--dport', '' + p ]));
}

// ── list ────────────────────────────────────────────────────────────────────

function clean_name(s) {
	return replace(str(s), /[^a-zA-Z0-9 _.()-]/g, '');
}

function fw(s, opt) {
	return str(lib.uci_get('firewall', s['.name'], opt));
}

function entries() {
	let out = [];
	// @redirect[i] / @rule[i] in order, as the shell walked them.
	let i = 0;
	lib.uci_foreach('firewall', 'redirect', (s) => {
		let id = 'r' + i++;
		let target = fw(s, 'target'), dport = fw(s, 'src_dport'), dest_ip = fw(s, 'dest_ip');
		if (target != '' && target != 'DNAT')
			return;
		if (dest_ip == '' || dport == '')
			return;
		let dest_port = fw(s, 'dest_port');
		if (dest_port == '')
			dest_port = dport;
		let name = clean_name(fw(s, 'name')), en = fw(s, 'enabled'), src = fw(s, 'src');
		push(out, { id, kind: 'forward', protos: proto_tokens(fw(s, 'proto')) ?? [ 'tcp', 'udp' ],
			ip: dest_ip, port: dest_port, ext: dport,
			name: (name != '') ? name : 'forward ' + dport,
			en: (en != '') ? en : '1', zone: (src != '') ? src : 'wan' });
	});
	i = 0;
	lib.uci_foreach('firewall', 'rule', (s) => {
		let id = 'a' + i++;
		let src = fw(s, 'src'), dport = fw(s, 'dest_port');
		if (index(src, 'wan') < 0 || fw(s, 'dest') != '' || fw(s, 'target') != 'ACCEPT' || dport == '')
			return;
		let protos = proto_tokens(fw(s, 'proto'));
		if (!protos)
			return;
		let name = clean_name(fw(s, 'name')), en = fw(s, 'enabled');
		push(out, { id, kind: 'open', protos, ip: '-', port: dport, ext: dport,
			name: (name != '') ? name : 'open ' + dport,
			en: (en != '') ? en : '1', zone: src });
	});
	return out;
}

// awk's numeric value of a string: its leading number, else 0.
function anum(s) {
	let m = match(str(s), /^[ \t]*([-+]?[0-9]+)/);
	return m ? +m[1] : 0;
}

function port_in(p, range) {
	let sep = index(range, '-');
	if (sep < 0)
		return anum(p) == anum(range);
	return anum(p) >= anum(substr(range, 0, sep)) && anum(p) <= anum(substr(range, sep + 1));
}

function octets(ip) {
	let o = split(ip, '.');
	return ((+o[0]) * 16777216) + ((+o[1]) * 65536) + ((+o[2]) * 256) + (+o[3]);
}

// Connections, clients and bytes per entry, from the conntrack table: the
// first entry whose protocol and destination fit takes the connection.
function ct_stats(list) {
	let subs = net.monitored_subnets(), st = map(list, () => ({ conns: 0, clients: 0, bin: 0, bout: 0, seen: {} }));
	let internal = (ip) => {
		if (!match(ip, /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/))
			return false;
		let si = octets(ip);
		for (let s in subs)
			if (si - (si % s.block) == s.base)
				return true;
		return false;
	};
	lib.each_line('/proc/net/nf_conntrack', (l) => {
		let f = split(trim(l), /[ \t]+/), proto = '';
		for (let x in f)
			if (x == 'tcp' || x == 'udp')
				proto = x;
		if (proto == '')
			return;
		let t = 0, osrc = '', odst = '', odport = '', ob = 0, rsrc = '', rsport = '', rb = 0;
		for (let x in f) {
			if (substr(x, 0, 4) == 'src=') {
				t++;
				if (t == 1)
					osrc = substr(x, 4);
				else if (t == 2)
					rsrc = substr(x, 4);
			}
			else if (substr(x, 0, 4) == 'dst=') {
				if (t == 1 && odst == '')
					odst = substr(x, 4);
			}
			else if (substr(x, 0, 6) == 'dport=') {
				if (t == 1 && odport == '')
					odport = substr(x, 6);
			}
			else if (substr(x, 0, 6) == 'sport=') {
				if (t == 2 && rsport == '')
					rsport = substr(x, 6);
			}
			else if (substr(x, 0, 6) == 'bytes=') {
				if (t == 1)
					ob = anum(substr(x, 6));
				else if (t == 2)
					rb = anum(substr(x, 6));
			}
		}
		if (osrc == '' || rsrc == '')
			return;
		for (let k = 0; k < length(list); k++) {
			let e = list[k];
			if (index(e.protos, proto) < 0)
				continue;
			if (e.kind == 'forward') {
				// odst == rsrc: LAN-direct, not DNATed.
				if (rsrc != e.ip || !port_in(rsport, e.port) || odst == rsrc)
					continue;
			}
			else {
				// rsrc != odst: NATed, so not router-local; an internal source
				// is a LAN client, not inbound.
				if (rsrc != odst || !port_in(odport, e.port) || internal(osrc))
					continue;
			}
			let s = st[k];
			s.conns++;
			s.bin += ob;
			s.bout += rb;
			if (!exists(s.seen, osrc)) {
				s.seen[osrc] = true;
				s.clients++;
			}
			break;
		}
	});
	return st;
}

// The rate of the first listed rule carrying cmt, as SI kbit/s.
function limit_kbit(dump, cmt) {
	let q = '"' + cmt + '"';
	for (let l in dump) {
		if (index(l, q) < 0)
			continue;
		let m = match(l, /(^|[ \t])over[ \t]+([0-9]+)[ \t]+(bytes|kbytes|mbytes|gbytes)/);
		return m ? ctl.rate_kbit(int(m[2]), m[3]) : 0;
	}
	return 0;
}

function list() {
	let es = entries();
	if (!length(es))
		return [];
	let dump = split(lib.run('nft list table inet tctl_pfw'), '\n'), st = ct_stats(es);
	let has = (cmt) => {
		let q = '"' + cmt + '"';
		for (let l in dump)
			if (index(l, q) >= 0)
				return true;
		return false;
	};
	return map(es, (e, k) => {
		let cmt_ip = (e.kind == 'open') ? 'local' : e.ip, paused = false, kbit = 0;
		for (let p in e.protos) {
			// v1.30 commented an open port's rules with '-' for the address.
			if (has(comment('pause', p, cmt_ip, e.port)) ||
			    (e.kind == 'open' && has(comment('pause', p, '-', e.port))))
				paused = true;
			if (kbit == 0)
				kbit = limit_kbit(dump, comment('limit', p, cmt_ip, e.port));
			if (kbit == 0 && e.kind == 'open')
				kbit = limit_kbit(dump, comment('limit', p, '-', e.port));
		}
		return {
			id: e.id, kind: e.kind, name: e.name, zone: e.zone, proto: join(' ', e.protos),
			ext_port: e.ext, ip: e.ip, port: e.port, enabled: e.en != '0', paused,
			limit_kbit: kbit, conns: st[k].conns, clients: st[k].clients,
			bytes_in: st[k].bin, bytes_out: st[k].bout,
		};
	});
}

// ── pause / resume / limit ──────────────────────────────────────────────────

function check_args(scope, proto, ip, port) {
	if (scope != 'forward' && scope != 'input')
		return false;
	if (!proto_tokens(proto))
		return false;
	if (scope == 'forward' && !lib.valid_ip(ip))
		return false;
	return valid_port(port);
}

function ok(msg) {
	return { reply: { ok: true, msg }, rc: 0 };
}

function fail(msg) {
	return { reply: { ok: false, msg }, rc: 1 };
}

function log(action, cmt_ip, port, detail) {
	lib.log(action, 'pfw:' + cmt_ip + ':' + port, detail, getenv('TCTL_VIA'), getenv('TCTL_SRC'));
}

// An open port is commented 'local'. v1.30 wrote the '-' it was given
// instead and then looked for 'local', so such a pause could never be
// resumed; both forms go.
function delete_kind(kind, scope, p, cmt_ip, port) {
	delete_by_comment(comment(kind, p, cmt_ip, port));
	if (scope == 'input')
		delete_by_comment(comment(kind, p, '-', port));
}

function pause(scope, proto, ip, port) {
	let cmt_ip = (scope == 'input') ? 'local' : ip;
	for (let p in proto_tokens(proto)) {
		delete_kind('pause', scope, p, cmt_ip, port);
		if (!add_pause(scope, p, ip, cmt_ip, port))
			return fail('failed to pause ' + p + ' port ' + port);
		flush_conntrack(p, (scope == 'input') ? '-' : ip, port);
	}
	let saved = lib.persist_enabled() ? lib.persist_save('pfw_pause', scope + '/' + proto + '/' + cmt_ip + '/' + port, '1') : null;
	log('block', cmt_ip, port, 'pause ' + proto);
	return ok('paused ' + proto + ' port ' + port +
		lib.persist_warn(saved, 'this pause will not be restored on the next ifup lan'));
}

function resume(scope, proto, ip, port) {
	let cmt_ip = (scope == 'input') ? 'local' : ip;
	for (let p in proto_tokens(proto))
		delete_kind('pause', scope, p, cmt_ip, port);
	let removed = lib.persist_enabled() ? lib.persist_remove('pfw_pause', scope + '/' + proto + '/' + cmt_ip + '/' + port) : null;
	log('unblock', cmt_ip, port, 'resume ' + proto);
	return ok('resumed ' + proto + ' port ' + port +
		lib.persist_warn(removed, 'the saved pause is still there and comes back on the next ifup lan'));
}

// tctl_validate_rate: no leading zero, at most 9 digits, at most 100 Gbit/s.
function valid_rate(s) {
	return digits(s) && substr(s, 0, 1) != '0' && length(s) <= 9 && int(s) <= RATE_MAX_KBIT;
}

function limit(scope, proto, ip, port, kbit) {
	if (kbit != '0' && !valid_rate(kbit))
		return fail('invalid rate');
	let cmt_ip = (scope == 'input') ? 'local' : ip;
	for (let p in proto_tokens(proto)) {
		delete_kind('limit', scope, p, cmt_ip, port);
		if (kbit != '0' && !add_limit(scope, p, ip, cmt_ip, port, int(kbit)))
			return fail('failed to limit ' + p + ' port ' + port);
	}
	let key = scope + '/' + proto + '/' + cmt_ip + '/' + port;
	if (kbit == '0') {
		let removed = lib.persist_enabled() ? lib.persist_remove('pfw_limit', key) : null;
		log('ratelimit_remove', cmt_ip, port, '');
		return ok('limit removed for port ' + port +
			lib.persist_warn(removed, 'the saved limit is still there and comes back on the next ifup lan'));
	}
	let saved = lib.persist_enabled() ? lib.persist_save('pfw_limit', key, kbit) : null;
	log('ratelimit_set', cmt_ip, port, kbit + 'kbit');
	return ok('limit ' + kbit + ' kbit/s set for port ' + port +
		lib.persist_warn(saved, 'this limit will not be restored on the next ifup lan'));
}

function main(args) {
	let a = map(args, str);
	switch (a[0]) {
	case 'list':
		return { reply: list(), rc: 0 };
	case 'pause':
	case 'resume':
		if (!check_args(a[1], a[2], a[3], a[4]))
			return fail(USAGE_PAUSE);
		return (a[0] == 'pause') ? pause(a[1], a[2], a[3], a[4]) : resume(a[1], a[2], a[3], a[4]);
	case 'limit':
		if (!check_args(a[1], a[2], a[3], a[4]))
			return fail(USAGE_LIMIT);
		return limit(a[1], a[2], a[3], a[4], a[5] ?? '');
	default:
		return fail(USAGE);
	}
}

// ── restore after boot (the port half of the iface hotplug hook) ────────────

const RULES = '/etc/trafficctl/rules.json';

// The record's ip is the key scope/proto/ip|local/port, cut as the hook's
// ${x%%/*} and ${x#*/} cut it: a part with no '/' left is the whole rest.
function key_parts(k) {
	let parts = [];
	for (let i = 0; i < 3; i++) {
		let j = index(k, '/');
		push(parts, (j < 0) ? k : substr(k, 0, j));
		k = (j < 0) ? k : substr(k, j + 1);
	}
	push(parts, k);
	return parts;
}

// A value as jsonfilter printed it to the hook.
function field(v) {
	return (v == null || type(v) == 'object' || type(v) == 'array') ? '' : '' + v;
}

function restore() {
	let res = { ok: true, restored: 0, failed: 0 };
	if (!lib.persist_enabled())
		return res;
	let d = lib.read_records(RULES);
	if (d == null)
		return res;
	// The hook read @[0], @[1], ... until a record had no type. The records
	// are read once: each restore rewrites rules.json, which made the hook's
	// index skip one record and apply another twice.
	for (let r in d) {
		let t = (type(r) == 'object') ? field(r.type) : '';
		if (t == '')
			break;
		let ip = field(r.ip), param = field(r.param);
		if (ip == '' || (t != 'pfw_pause' && t != 'pfw_limit'))
			continue;
		let k = key_parts(ip);
		if (k[2] == 'local')
			k[2] = '-';
		// A limit with no rate has nothing to restore: skipped, not a
		// failure (v1.30's hook logged one, as it did for the limiter).
		if (t == 'pfw_limit' && (param == '' || param == '0'))
			continue;
		let what = (t == 'pfw_pause') ? 'pause' : 'limit';
		let argv = (t == 'pfw_pause') ? [ 'pause', ...k ] : [ 'limit', ...k, param ];
		let rc;
		try {
			rc = main(argv).rc;
		}
		catch (e) {
			rc = 1;
		}
		if (rc == 0)
			res.restored++;
		else {
			res.failed++;
			lib.logger('Failed to restore port ' + what + ' for ' + k[3]);
		}
	}
	res.ok = (res.failed == 0);
	return res;
}

export { main, valid_port, restore };
