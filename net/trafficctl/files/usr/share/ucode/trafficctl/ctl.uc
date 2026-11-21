// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.ctl: what restricts each device, read back from where it lives
// (nft, tc, the radios) and from where it is saved (rules.json, shapes.json,
// the uci maclist), and the commands that place and lift a block, a WiFi
// deny and a new device's default limit.
//
//   import * as ctl from 'trafficctl.ctl';
//
// nft. Read as `nft -j`, so a rule is matched on its comment, its handle and
// whole address fields, never on a substring of the text listing (which is
// how a limit on 192.168.1.5 used to be read as one on 192.168.1.50).
//   nft_rules(what)          the rules of `nft -j list <what>` (a qv() list),
//                            in listing order, as records:
//                              { chain, handle, comment, daddr, saddr, mac,
//                                limit, over, rate_kbit, each, counter,
//                                packets, bytes, verdict }
//                            daddr/saddr: an `ip` match's address or prefix
//                            ("10.0.20.0/24"); mac: an `ether saddr` match;
//                            each: the limit sits in a per-address meter
//   rate_kbit(n, unit)       an nft rate as SI kbit/s (nft steps by 1024)
//   rl_rules()               nft_rules of netdev tm_ratelimit
//   rl_rate_kbit(rules, ip, fld)
//                            the ceiling of the first `ip <fld> <ip>` limit
//                            (fld 'daddr' or 'saddr'), null when none
//   live_blocks(rules)       [{ ip, mac, handle, comment }] of the blocks in
//                            inet fw4 forward (rules defaults to that chain)
//   ratelimit_stats(rules)   trafficctl ratelimit-stats
// tc
//   shape_records()          the records of shapes.json
//   shape_classmap(recs)     { ip: classid }
//   ifb_dev()                the IFB device upload shaping runs on
//   tc_class_rates(dev)      { classid: kbit } of the per-device HTB classes
//   shape_stats()            trafficctl shape-stats
// Everything together
//   rules_list()             trafficctl rules list
// Writers. The commands return { reply, rc }: the reply object the CLI
// prints, the exit status of the script they replace.
//   block_comment(ip)        tctl_block_<ip with . and / as _>; its v6 half
//                            adds _mac
//   is_blocked(ip, rules)    a drop on ip saddr, or the v6 half's comment
//   block_add(ip, comment)   both halves: { ok (the v4 rule), ipv6, mac }
//   block_remove(comment)    every rule with that comment or its _mac
//   block_remove_legacy(ip)  v4 drops on ip with any other tctl_block_ comment
//   block(ip, label), unblock(ip, label)
//                            trafficctl block / unblock
//   macfilter(op, arg)       trafficctl macfilter-add / macfilter-remove
//                            (op 'add' or 'remove'): the uci maclist, then
//                            every running AP, the result one enforcement
//                            word (acl, ban, none, no-radio)
//   has_limit(ip)            a limit or shape, live or saved
//   newdevice(env)           trafficctl newdevice: the DHCP hook's ACTION,
//                            MACADDR, IPADDR and HOSTNAME; the default limit
//                            in process (limit.ratelimit or shape.main)
//   restore()                trafficctl restore: the saved blocks, once fw4
//                            is up; { ok, restored, failed }

import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as limit from 'trafficctl.limit';
import * as shape from 'trafficctl.shape';
import * as notify from 'trafficctl.notify';

const RULES = '/etc/trafficctl/rules.json';
const SHAPES = '/etc/trafficctl/shapes.json';
const LEASES = '/tmp/dhcp.leases';
const NAMES = '/etc/trafficctl/names';
const RDNS_CACHE = '/tmp/trafficctl_rdns_cache';

// The shell readers' test for an address; looser than lib.valid_ip on purpose,
// so the same rules are listed.
const DOTTED = /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/;

// awk's fields of a line.
function fields(l) {
	return filter(split(l, /[ \t]+/), (w) => w != '');
}

// awk's s+0: the leading number, 0 without. Whole numbers stay ints, so a
// 64-bit tc counter is not rounded.
function anum(s) {
	if (type(s) == 'int' || type(s) == 'double')
		return s;
	let m = match('' + (s ?? ''), /^[ \t]*([-+]?[0-9]+)(\.[0-9]*)?/);
	if (m)
		return (m[2] == null || m[2] == '.') ? int(m[1]) : +(m[1] + m[2]);
	m = match('' + (s ?? ''), /^[ \t]*([-+]?\.[0-9]+)/);
	return m ? +m[1] : 0;
}

// ── nft ─────────────────────────────────────────────────────────────────────

const UNIT = { bytes: 1, kbytes: 1024, mbytes: 1048576, gbytes: 1073741824 };

function rate_kbit(n, unit) {
	let m = UNIT[unit];
	if (!m || (type(n) != 'int' && type(n) != 'double'))
		return 0;
	// Rounded, as TCTL_NFT_RATE_AWK does.
	return int(n * m * 8 / 1000.0 + 0.5);
}

// A match's right-hand side as an address: a plain value or a prefix.
function addr(r) {
	if (type(r) == 'string')
		return r;
	let p = (type(r) == 'object') ? r.prefix : null;
	if (type(p) == 'object' && type(p.addr) == 'string' && type(p.len) == 'int')
		return sprintf('%s/%d', p.addr, p.len);
	return null;
}

function set_limit(rec, l, each) {
	if (type(l) != 'object' || rec.limit)
		return;
	rec.limit = true;
	rec.each = each;
	// "limit rate over": a ceiling. A plain "limit rate" passes the first N,
	// which the limiter never writes; the shell readers read it as 0.
	rec.over = (l.inv == true);
	rec.rate_kbit = rec.over ? rate_kbit(l.rate, l.rate_unit) : 0;
}

const VERDICTS = [ 'accept', 'drop', 'reject', 'jump', 'goto', 'return', 'continue', 'queue' ];

function rule_rec(r) {
	let rec = {
		chain: r.chain, handle: r.handle, comment: (type(r.comment) == 'string') ? r.comment : '',
		daddr: null, saddr: null, mac: null, limit: false, over: false, rate_kbit: 0, each: false,
		counter: false, packets: 0, bytes: 0, verdict: null,
	};
	for (let e in r.expr) {
		if (type(e) != 'object')
			continue;
		if (type(e.match) == 'object') {
			let m = e.match, p = m.left?.payload, a = addr(m.right);
			if (m.op != '==' || type(p) != 'object' || a == null)
				continue;
			if (p.protocol == 'ip' && p.field == 'daddr')
				rec.daddr ??= a;
			else if (p.protocol == 'ip' && p.field == 'saddr')
				rec.saddr ??= a;
			else if (p.protocol == 'ether' && p.field == 'saddr')
				rec.mac ??= lc(a);
		}
		else if (exists(e, 'limit'))
			set_limit(rec, e.limit, false);
		// A per-address bucket: nftables 1.0 lists it as a meter, 1.1 as a
		// named dynamic set the rule adds to, with the limit inside.
		else if (type(e.meter) == 'object')
			set_limit(rec, e.meter.stmt?.limit, true);
		else if (type(e.set) == 'object' && type(e.set.stmt) == 'array') {
			for (let s in e.set.stmt)
				if (type(s) == 'object' && exists(s, 'limit'))
					set_limit(rec, s.limit, true);
		}
		else if (type(e.counter) == 'object') {
			rec.counter = true;
			rec.packets = anum(e.counter.packets);
			rec.bytes = anum(e.counter.bytes);
		}
		else {
			for (let v in VERDICTS)
				if (exists(e, v))
					rec.verdict ??= v;
		}
	}
	return rec;
}

function nft_rules(what) {
	let out = lib.run('nft -j list ' + lib.qv(what)), d;
	try {
		d = json(out);
	}
	catch (e) {
		// No such table or chain: nft prints nothing on stdout.
		return [];
	}
	let rules = [];
	for (let o in (type(d?.nftables) == 'array') ? d.nftables : [])
		if (type(o?.rule) == 'object' && type(o.rule.expr) == 'array')
			push(rules, rule_rec(o.rule));
	return rules;
}

function rl_rules() {
	return nft_rules([ 'table', 'netdev', 'tm_ratelimit' ]);
}

function rl_rate_kbit(rules, ip, fld) {
	fld ??= 'daddr';
	for (let r in rules)
		if (r.over && (r[fld] == ip || r[fld] == ip + '/32'))
			return r.rate_kbit;
	return null;
}

// Only drop rules this app wrote, told by their comment. The v4 half matches
// on the address, and its comment is tctl_block_ and the address slug
// (tctl_block_comment), or, when it was written before v1.13.2, tctl_block_
// and the caller's label (tctl_block_block_<ip> from LuCI, tctl_block_tg from
// Telegram). The prefix is all the two forms share, and unblock removes both
// (block_remove_legacy). The v6 half matches on the MAC and carries no
// address; it exists since v1.18.2, so its comment is always the current one,
// and that exact comment is the way back to an address.
function live_blocks(rules) {
	rules ??= nft_rules([ 'chain', 'inet', 'fw4', 'forward' ]);
	let out = [];
	for (let r in rules) {
		if (r.verdict != 'drop' || substr(r.comment, 0, 11) != 'tctl_block_')
			continue;
		let ip;
		if (r.saddr != null)
			ip = replace(r.saddr, /\/32$/, '');
		else {
			let m = match(r.comment, /^tctl_block_([0-9_]+)_mac$/);
			if (!m)
				continue;
			ip = replace(m[1], /_/g, '.');
		}
		if (match(ip, DOTTED))
			push(out, { ip, mac: r.mac, handle: r.handle, comment: r.comment });
	}
	return out;
}

// One entry per target, counters summed across chains: the download rule is
// installed on every LAN device's egress chain, and only the copy on the
// device the target lives behind ever matches. Upload rules match on saddr
// and are not targets of their own.
function ratelimit_stats(rules) {
	rules ??= rl_rules();
	let by = {}, out = [];
	for (let r in rules) {
		if (r.daddr == null || !r.limit || !r.counter || !match(r.daddr, /^[0-9]/))
			continue;
		let e = by[r.daddr];
		if (!e) {
			e = { ip: r.daddr, mode: '', rate_kbit: 0, packets: 0, bytes: 0, pass_packets: 0, pass_bytes: 0 };
			by[r.daddr] = e;
			push(out, e);
		}
		e.mode = r.each ? 'each' : 'shared';
		e.rate_kbit = r.rate_kbit;
		e.packets += r.packets;
		e.bytes += r.bytes;
	}
	return out;
}

// ── tc ──────────────────────────────────────────────────────────────────────

// shapes.json as the shaper writes it, [{ ip, rate_kbit[, classid][,
// rate_kbit_up] }]. Read as JSON: the shell readers' patterns also accepted
// a record whose JSON was broken, and none of them agreed on key order.
function shape_records() {
	let d;
	try {
		d = json(lib.readfile(SHAPES) ?? '');
	}
	catch (e) {
		return [];
	}
	return filter((type(d) == 'array') ? d : [], (s) => type(s) == 'object' &&
		type(s.ip) == 'string' && s.ip != '' && type(s.rate_kbit) == 'int' && s.rate_kbit >= 0);
}

// Minors are allocated, not derived from the address, so this map is the only
// way from an address to its class. A record from before allocation has no
// classid, and its class is the one the old derivation gave it.
function classmap_pairs(recs) {
	let out = [];
	for (let s in recs ?? shape_records()) {
		if (exists(s, 'classid')) {
			if (type(s.classid) == 'string' && match(s.classid, /^1:[0-9a-f]+$/))
				push(out, [ s.ip, s.classid ]);
			continue;
		}
		let o = split(s.ip, '.');
		if (length(o) != 4)
			continue;
		let dec = int(o[2]) * 256 + int(o[3]);
		if (dec >= 2 && dec <= 65533)
			push(out, [ s.ip, sprintf('1:%x', dec) ]);
	}
	return out;
}

function shape_classmap(recs) {
	let m = {};
	for (let p in classmap_pairs(recs))
		m[p[0]] = p[1];
	return m;
}

function ifb_dev() {
	let d = lib.uci_get('trafficctl', 'main', 'shape_ifb');
	return (d == null || d == '') ? 'tctl-ifb0' : d;
}

// A tc rate word ("8Mbit") in kbit/s. tc -j class is not JSON on 22.03's
// iproute2 (5.15 prints the text form for classes), so classes are read from
// the text listing everywhere. plain: also take a bare "bit" figure.
function tc_kbit(v, plain) {
	if (index(v, 'Gbit') >= 0)
		return anum(v) * 1000000;
	if (index(v, 'Mbit') >= 0)
		return anum(v) * 1000;
	if (match(v, /[Kk]bit/))
		return anum(v);
	return plain ? anum(v) / 1000.0 : 0;
}

function htb_minor(f) {
	let c = f[2] ?? '';
	return (substr(c, 0, 2) == '1:') ? substr(c, 2) : c;
}

function line_rate(f, plain) {
	for (let i = 0; i < length(f); i++)
		if (f[i] == 'rate')
			return tc_kbit(f[i + 1] ?? '', plain);
	return 0;
}

function tc_class_rates(dev) {
	let m = {};
	for (let l in lib.lines('tc class show dev ' + lib.q(dev))) {
		if (substr(l, 0, 12) != 'class htb 1:')
			continue;
		let f = fields(l), minor = htb_minor(f);
		if (minor == '1' || minor == 'fffe')
			continue;
		m['1:' + minor] = line_rate(f, true);
	}
	return m;
}

// `tc -s class show`: one record per HTB class this app knows, root 1:1 and
// default 1:fffe left out.
function htb_stats(text, ipmap) {
	let out = [], cur = null, skip = false;
	let flush = () => {
		if (cur && cur.rate > 0 && cur.rate < 1000000 && exists(ipmap, cur.classid))
			push(out, cur);
		cur = null;
	};
	for (let l in split(text, '\n')) {
		if (index(l, 'class fq_codel') >= 0) {
			skip = true;
			continue;
		}
		let f = fields(l);
		if (substr(l, 0, 12) == 'class htb 1:') {
			// A record ends where the next class starts. v1.30.0 did not
			// close it at the root or default class, and printed the class
			// before one of those twice.
			flush();
			let minor = htb_minor(f);
			skip = (minor == '1' || minor == 'fffe');
			if (!skip)
				cur = { classid: '1:' + minor, rate: line_rate(f, false), bytes: 0, pkts: 0,
					backlog: 0, drops: 0, overlimits: 0, requeues: 0, lended: 0, borrowed: 0 };
			continue;
		}
		if (skip || !cur)
			continue;
		if (match(l, /Sent [0-9]+ bytes/)) {
			for (let i = 0; i < length(f); i++) {
				let v = f[i + 1] ?? '';
				if (f[i] == 'Sent')
					cur.bytes = anum(v);
				if (match(f[i], /^[0-9]+$/) && v == 'pkt')
					cur.pkts = anum(f[i]);
				if (f[i] == '(dropped')
					cur.drops = anum(v);
				if (f[i] == 'overlimits')
					cur.overlimits = anum(v);
				if (f[i] == 'requeues' && v != '' && match(v, /[0-9]/))
					cur.requeues = anum(v);
			}
		}
		if (index(l, 'backlog') >= 0)
			for (let i = 0; i < length(f); i++)
				if (f[i] == 'backlog')
					cur.backlog = anum(f[i + 1]);
		if (index(l, 'lended:') >= 0)
			for (let i = 0; i < length(f); i++) {
				if (f[i] == 'lended:')
					cur.lended = anum(f[i + 1]);
				if (f[i] == 'borrowed:')
					cur.borrowed = anum(f[i + 1]);
			}
	}
	flush();
	return out;
}

// `tc -s qdisc show`: the fq_codel leaf under each class, by parent classid.
// Read as text, not tc -j: iproute2's JSON gives the target in microseconds
// as the kernel holds it (4999 for "5ms"), so the figures would change.
function fq_stats(text) {
	let by = {}, cur = null;
	let flush = () => {
		if (cur && cur.parent != '')
			by[cur.parent] = cur;
		cur = null;
	};
	for (let l in split(text, '\n')) {
		let f = fields(l);
		if (substr(l, 0, 14) == 'qdisc fq_codel') {
			flush();
			cur = { parent: '', ecn_mark: 0, new_flows: 0, old_flows: 0, target_us: 0, memory_used: 0 };
			for (let i = 0; i < length(f); i++) {
				let v = f[i + 1] ?? '';
				if (f[i] == 'parent')
					cur.parent = v;
				if (f[i] == 'target')
					cur.target_us = match(v, /ms$/) ? anum(v) * 1000 : match(v, /us$/) ? anum(v) : 0;
			}
			continue;
		}
		if (substr(l, 0, 5) == 'qdisc') {
			flush();
			continue;
		}
		if (!cur)
			continue;
		for (let i = 0; i < length(f); i++) {
			let v = f[i + 1];
			if (f[i] == 'ecn_mark')
				cur.ecn_mark = anum(v);
			// iproute2 prints new_flows_len/old_flows_len, which v1.30.0
			// never matched: both stay 0, as they always read.
			if (f[i] == 'new_flows' && index(l, 'new_flow_count') < 0)
				cur.new_flows = anum(v);
			if (f[i] == 'old_flows' && index(l, 'new_flow_count') < 0)
				cur.old_flows = anum(v);
			if (f[i] == 'memory_used')
				cur.memory_used = anum(v);
		}
	}
	flush();
	return by;
}

function shape_stats() {
	let dev = net.lan_device();
	let qd = lib.run('tc -s qdisc show dev ' + lib.q(dev));
	if (index(qd, 'htb 1:') < 0)
		return [];
	let ipmap = {};
	for (let p in classmap_pairs())
		ipmap[p[1]] = p[0];
	let fq = fq_stats(qd), out = [];
	for (let c in htb_stats(lib.run('tc -s class show dev ' + lib.q(dev)), ipmap)) {
		let q = fq[c.classid] ?? {};
		push(out, {
			ip: ipmap[c.classid], rate_kbit: int(c.rate), bytes: c.bytes, packets: c.pkts,
			backlog: int(c.backlog), drops: c.drops, overlimits: c.overlimits,
			requeues: c.requeues, lended: c.lended, borrowed: c.borrowed,
			ecn_mark: q.ecn_mark ?? 0, new_flows: int(q.new_flows ?? 0),
			old_flows: int(q.old_flows ?? 0), target_us: int(q.target_us ?? 0),
			memory_used: int(q.memory_used ?? 0),
		});
	}
	return out;
}

// ── the Rules tab ───────────────────────────────────────────────────────────

// Names and presence, with the device table's precedence: alias > DHCP lease
// > cached PTR. Online = a flow right now, or a live neighbour entry.
function naming() {
	let n = { lmac: {}, lip: {}, lname: {}, alias: {}, rdns: {}, nmac: {}, nip: {}, on: {} };
	for (let l in lib.file_lines(LEASES)) {
		let f = fields(l);
		if (length(f) < 3)
			continue;
		let mac = lc(f[1]), ip = f[2], name = f[3] ?? '';
		if (!exists(n.lmac, ip))
			n.lmac[ip] = mac;
		if (!exists(n.lip, mac))
			n.lip[mac] = ip;
		if (name != '' && name != '*' && !exists(n.lname, ip))
			n.lname[ip] = name;
	}
	// Whitespace runs collapse and a later line wins, as the shell merge had it.
	for (let l in lib.file_lines(NAMES)) {
		let f = fields(l);
		if (length(f) >= 2)
			n.alias[f[0]] = join(' ', fields(replace(l, /^[^ ]+ +/, '')));
	}
	if (lib.uci_get('trafficctl', 'main', 'resolve_names') != '0')
		for (let l in lib.file_lines(RDNS_CACHE)) {
			let f = fields(l);
			if (length(f) >= 2 && f[1] != '-' && !exists(n.rdns, f[0]))
				n.rdns[f[0]] = f[1];
		}
	for (let l in lib.lines('ip neigh show')) {
		let f = fields(l), nf = length(f);
		if (nf == 0 || !match(f[0], DOTTED))
			continue;
		let mac = null;
		for (let i = 1; i < nf - 1; i++)
			if (f[i] == 'lladdr')
				mac = lc(f[i + 1]);
		if (mac != null) {
			if (!exists(n.nmac, f[0]))
				n.nmac[f[0]] = mac;
			if (!exists(n.nip, mac))
				n.nip[mac] = f[0];
		}
		if (index([ 'REACHABLE', 'DELAY', 'PROBE', 'PERMANENT' ], f[nf - 1]) >= 0)
			n.on[f[0]] = true;
	}
	net.ct_each((rec) => {
		n.on[rec.osrc] = true;
	});
	return n;
}

// rules.json as JSON, so a label holding braces or a quote is read whole;
// a file that does not parse pattern by pattern, as the shell read it: a
// record is any flat {...}, a field any "key":"string" in it.
function persisted_rules() {
	let s = lib.readfile(RULES) ?? '', out = [], d;
	try {
		d = json(s);
	}
	catch (e) {
		d = null;
	}
	if (type(d) == 'array') {
		let str = (v) => (type(v) == 'string') ? v : '';
		for (let r in d)
			if (type(r) == 'object')
				push(out, { type: str(r.type), ip: str(r.ip), param: str(r.param),
					mode: str(r.mode), param_up: str(r.param_up) });
		return out;
	}
	let get = (o, k) => {
		let m = match(o, regexp('"' + k + '":"([^"]*)"'));
		return m ? m[1] : '';
	};
	for (let m in match(s, /\{[^{}]*\}/g) ?? []) {
		let o = m[0];
		push(out, { type: get(o, 'type'), ip: get(o, 'ip'), param: get(o, 'param'),
			mode: get(o, 'mode'), param_up: get(o, 'param_up') });
	}
	return out;
}

function hostapd_ifaces() {
	let objs = lib.ubus_list();
	if (objs == null)
		return null;
	let out = [];
	for (let o in objs)
		if (substr(o, 0, 8) == 'hostapd.')
			push(out, substr(o, 8));
	return out;
}

// The tool installed AND this AP's control socket answering: only a PONG
// shows the ACL commands reach anything. Timed, as every hostapd_cli call
// here: a hung socket must not hold the caller past its own deadline.
const CLI_MS = 3000;

let has_cli;
function cli_alive(iface) {
	has_cli ??= (lib.sh('command -v hostapd_cli') == 0);
	return has_cli && index(lib.run('hostapd_cli -i ' + lib.q(iface) + ' ping', CLI_MS), 'PONG') >= 0;
}

// What keeps a denied MAC off the air, read back from each running AP: its
// ACL (acl), a timed ubus ban (ban) or nothing (none); the weakest AP wins.
// "unknown" when which AP carries which policy cannot be told, "no-radio"
// when no AP runs (the uci maclist applies when one starts).
function wifi_denies() {
	let allow = 0, words = [];
	lib.uci_foreach('wireless', 'wifi-iface', (s) => {
		if (s.macfilter == 'allow') {
			allow++;
			return;
		}
		if (s.macfilter != 'deny')
			return;
		for (let v in (type(s.maclist) == 'array') ? s.maclist : [ s.maclist ?? '' ])
			push(words, ...fields(v));
	});
	let macs = uniq(sort(filter(map(words, lc), (w) => match(w, /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/))));
	let out = [];
	if (!length(macs))
		return { allow, macs: out };
	let ifaces = (allow > 0) ? null : hostapd_ifaces();
	let fixed = (allow > 0 || ifaces == null) ? 'unknown' : !length(ifaces) ? 'no-radio' : null;
	let rank = { acl: 3, ban: 2, none: 1 };
	for (let mac in macs) {
		if (fixed) {
			push(out, { mac, state: fixed });
			continue;
		}
		let worst = 3;
		for (let ifc in ifaces) {
			let st = 'none';
			if (cli_alive(ifc) && index(lc(lib.run('hostapd_cli -i ' + lib.q(ifc) + ' deny_acl SHOW', CLI_MS)), mac) >= 0)
				st = 'acl';
			else {
				let b = lib.ubus_call('hostapd.' + ifc, 'list_bans');
				if (b != null && index(lc(lib.to_json(b)), mac) >= 0)
					st = 'ban';
			}
			if (rank[st] < worst)
				worst = rank[st];
		}
		push(out, { mac, state: (worst == 3) ? 'acl' : (worst == 2) ? 'ban' : 'none' });
	}
	return { allow, macs: out };
}

// The shell merge's string escape: control characters dropped, not escaped.
function esc(s) {
	return replace('' + (s ?? ''), /[\x01-\x1f]/g, '');
}

function num_or(v, dflt) {
	return (v == null || v == '') ? dflt : v;
}

function rules_list() {
	let persist = (lib.uci_get('trafficctl', 'main', 'persist_rules') == '1');
	let n = naming();
	let recs = {}, order = [];
	let add = (t, target) => {
		let k = t + '|' + target;
		if (!exists(recs, k)) {
			recs[k] = { t, target, live: false, saved: false, mode: null, rate: null, up: null, bmac: null, enf: null };
			push(order, k);
		}
		return recs[k];
	};

	for (let b in live_blocks()) {
		let r = add('block', b.ip);
		r.live = true;
		if (b.mac != null)
			r.bmac = b.mac;
	}

	let rl = rl_rules();
	for (let s in ratelimit_stats(rl)) {
		let r = add('ratelimit', s.ip);
		r.live = true;
		r.mode = s.mode;
		r.rate = s.rate_kbit;
		r.up = rl_rate_kbit(rl, s.ip, 'saddr') ?? 0;
	}

	// rules.json records only count while persist_rules is on: the restore
	// hook skips the file otherwise, so a record left in it restricts nothing.
	if (persist)
		for (let p in persisted_rules()) {
			if (p.ip == '')
				continue;
			if (p.type == 'block')
				add('block', p.ip).saved = true;
			else if (p.type == 'ratelimit') {
				let r = add('ratelimit', p.ip);
				r.saved = true;
				if (!r.live) {
					r.rate = num_or(p.param, 0);
					r.mode = p.mode;
					r.up = (anum(p.param_up) > 0) ? p.param_up : r.rate;
				}
			}
		}

	// shapes.json is written on every add and remove, so it is the list of
	// shapes; a class with that minor on the LAN device is what makes one live.
	let srecs = shape_records(), cls = shape_classmap(srecs);
	let dl = tc_class_rates(net.lan_device()), ul = tc_class_rates(ifb_dev());
	for (let s in srecs) {
		if (s.rate_kbit <= 0)
			continue;
		let r = add('shape', s.ip), c = cls[s.ip], up = s.rate_kbit_up ?? 0;
		r.saved = true;
		r.rate = s.rate_kbit;
		r.up = (anum(up) > 0) ? up : s.rate_kbit;
		if (c != null && exists(dl, c)) {
			r.live = true;
			r.rate = dl[c];
			if (anum(ul[c] ?? 0) > 0)
				r.up = ul[c];
		}
	}

	let w = wifi_denies();
	for (let d in w.macs) {
		let r = add('wifi', d.mac);
		r.saved = true;
		r.enf = d.state;
	}

	let rules = [];
	for (let k in order) {
		let r = recs[k], ip = '', mac = '', name = '', online = null, applied = null;
		if (r.t == 'wifi') {
			mac = r.target;
			ip = n.lip[mac] ?? n.nip[mac] ?? '';
			if (r.enf == 'acl' || r.enf == 'ban')
				applied = true;
			else if (r.enf == 'none')
				applied = false;
		}
		else {
			applied = r.live;
			if (match(r.target, DOTTED))
				ip = r.target;
			if (ip != '')
				mac = n.lmac[ip] ?? n.nmac[ip] ?? '';
			if (mac == '' && r.bmac != null)
				mac = r.bmac;
		}
		if (ip != '') {
			name = n.alias[ip] ?? n.lname[ip] ?? n.rdns[ip] ?? '';
			online = exists(n.on, ip);
		}
		let o = { type: r.t, target: esc(r.target), ip: esc(ip), mac: esc(mac), name: esc(name),
			online, applied, persisted: r.saved };
		if (r.t == 'ratelimit' || r.t == 'shape') {
			o.rate_kbit = int(anum(r.rate));
			o.rate_kbit_up = int(anum((r.up == null || r.up == '' || anum(r.up) == 0) ? r.rate : r.up));
		}
		if (r.t == 'ratelimit') {
			// A record written before modes were stored has none; it gets
			// the default the restore hook gives it.
			let mode = r.mode ?? '';
			if (mode == '')
				mode = (index(r.target, '/') >= 0 && !match(r.target, /\/32$/)) ? 'each' : 'shared';
			o.mode = esc(mode);
		}
		if (r.t == 'wifi')
			o.enforcement = esc(r.enf);
		push(rules, o);
	}
	return { fw: 'nft', persist_rules: persist, wifi_allow_ifaces: w.allow, rules };
}

// ── blocks: writers (tctl_block_*, trafficctl-block.sh, -unblock.sh) ────────

const FW4 = [ 'chain', 'inet', 'fw4', 'forward' ];
const CT_MS = 5000;

// From the target, never the caller's label: the label once made LuCI's and
// the bot's comment for the same device differ, and neither could remove the
// other's rule.
function block_comment(ip) {
	return 'tctl_block_' + lib.slug(ip);
}

// The rules unblock removes, told the way it tells them: a drop on exactly
// this address whose comment starts with tctl_block_ (a block from before
// v1.13.2 carries the caller's label after it), or the v6 half by its whole
// comment, which names no address. Not any drop on the address: a firewall
// rule of the operator's own (one port, say) made a block a no-op that
// reported "already blocked", and unblock could not lift it either.
function is_blocked(ip, rules) {
	rules ??= nft_rules(FW4);
	let mc = block_comment(ip) + '_mac';
	for (let r in rules)
		if (r.verdict == 'drop' && ((substr(r.comment, 0, 11) == 'tctl_block_' &&
		    (r.saddr == ip || r.saddr == ip + '/32')) || r.comment == mc))
			return true;
	return false;
}

// Inserted, not added: fw4 accepts established and offloaded flows near the
// top of the chain, and a rule below that never fires. "meta nfproto ipv6"
// keeps the MAC rule off IPv4, so no v4 outcome depends on a MAC lookup.
// The v6 half only after the v4 one: alone it is a block is_blocked counts,
// so a failed block would read as "already blocked" from then on.
function block_add(ip, comment) {
	let ok = lib.sh('nft insert rule inet fw4 forward ' +
		lib.q('ip saddr ' + ip + ' counter drop comment "' + comment + '"')) == 0;
	let mac = ok ? net.target_mac(ip) : null, ipv6 = false;
	if (mac != null)
		ipv6 = lib.sh('nft insert rule inet fw4 forward ' +
			lib.q('meta nfproto ipv6 ether saddr ' + mac + ' counter drop comment "' + comment + '_mac"')) == 0;
	return { ok, ipv6, mac };
}

function delete_handles(hs) {
	// The shell's loop: the status of the last delete, 0 with nothing to do.
	let rc = 0;
	for (let h in hs)
		rc = lib.sh('nft delete rule inet fw4 forward handle ' + lib.q(h));
	return rc == 0;
}

// The whole comment: a substring match on 192.168.1.1 deletes the rule of
// 192.168.1.10.
function block_remove(comment) {
	let hs = [];
	for (let r in nft_rules(FW4))
		if (type(r.handle) == 'int' && (r.comment == comment || r.comment == comment + '_mac'))
			push(hs, r.handle);
	return delete_handles(hs);
}

// Blocks from before v1.13.2 carry whatever label the caller gave, so no
// comment finds them; what every version wrote is a drop on exactly this
// address with a comment starting tctl_block_. Their v6 half came later and
// always has the current comment. The rule with the current comment is left
// to block_remove, so the two halves go in the order the shell deleted them.
function block_remove_legacy(ip) {
	let hs = [], cur = block_comment(ip);
	for (let r in nft_rules(FW4))
		if (type(r.handle) == 'int' && r.verdict == 'drop' && substr(r.comment, 0, 11) == 'tctl_block_' &&
		    r.comment != cur && (r.saddr == ip || r.saddr == ip + '/32'))
			push(hs, r.handle);
	return delete_handles(hs);
}

function reply(o, rc) {
	return { reply: o, rc: rc ?? (o.ok ? 0 : 1) };
}

function block(ip, label) {
	if (ip == null || ip == '')
		return reply({ ok: false, msg: 'usage: trafficctl block <ip> [label]' });
	if (!lib.valid_ip(ip))
		return reply({ ok: false, msg: 'invalid IP address' });
	label = (label == null || label == '') ? 'block_' + ip : label;

	let m = match(lib.run('ip -4 addr show dev ' + lib.q(net.lan_device())), /inet ([0-9.]+)/);
	if (m && m[1] == ip)
		return reply({ ok: false, msg: 'cannot block the router itself' });

	let comment = block_comment(ip), src = getenv('TCTL_SRC');
	if (is_blocked(ip))
		return reply({ ok: true, msg: ip + ' is already blocked' });

	let b = block_add(ip, comment);
	if (!b.ok)
		return reply({ ok: false, msg: 'failed to block ' + ip });

	lib.sh('conntrack -D -s ' + lib.q(ip), CT_MS);
	lib.sh('conntrack -D -d ' + lib.q(ip), CT_MS);
	// The v4 flush leaves every IPv6 flow running, and an offloaded one is
	// never checked against the new rule.
	if (b.mac != null)
		net.flush_v6(b.mac);
	// The same one layer further out, for flows the NSS firmware carries.
	lib.nss_defunct();

	let persist = lib.persist_enabled();
	let saved = persist ? lib.persist_save('block', ip, label) : null;
	lib.log('block', ip, label, getenv('TCTL_VIA'), src);
	notify.emit_action('block_applied', { ip, mac: b.mac ?? '', kind: 'internet' });

	// Which families are covered, said rather than left to be found out.
	let note = '';
	if (!b.ipv6)
		note = net.ip_is_nexthop(ip)
			? ' — IPv4 only: ' + ip + ' is a routed next hop, and a MAC-keyed IPv6 rule would also block everything behind it'
			: ' — IPv4 only: no MAC known for ' + ip + ' (no DHCP lease, no neighbour entry), so IPv6 is not covered';
	note += lib.nss_note() + lib.persist_note() +
		lib.persist_warn(saved, 'this block will not be restored on the next ifup lan');
	let self = (src != null && src != '' && src == ip) ? ' (your device — LuCI access preserved)' : '';
	return reply({ ok: true, ipv6: b.ipv6, nss: lib.nss_status(), persist,
		msg: 'internet blocked for ' + ip + self + note });
}

function unblock(ip, label) {
	if (ip == null || ip == '')
		return reply({ ok: false, msg: 'usage: trafficctl unblock <ip> [label]' });
	if (!lib.valid_ip(ip))
		return reply({ ok: false, msg: 'invalid IP address' });
	label = (label == null || label == '') ? 'block_' + ip : label;

	// A rule from before v1.13.2 carries the caller's label, so a block
	// placed from LuCI could not be removed from Telegram; the Rules tab
	// sends no label at all. Found by address: the shell also deleted every
	// rule with the comment tctl_block_<label>, so unblocking one device
	// with the label tg lifted every other device's Telegram block.
	block_remove_legacy(ip);
	if (!block_remove(block_comment(ip)))
		return reply({ ok: false, msg: 'failed to unblock ' + ip });

	let removed = lib.persist_enabled() ? lib.persist_remove('block', ip) : null;
	lib.log('unblock', ip, label, getenv('TCTL_VIA'), getenv('TCTL_SRC'));
	return reply({ ok: true, msg: 'internet unblocked for ' + ip +
		lib.persist_warn(removed, 'the saved block is still there and comes back on the next ifup lan') });
}

// ── WiFi: the uci maclist and the running hostapd ACL ───────────────────────
//
// The maclist is the durable half of a WiFi block, hostapd's running ACL the
// half that decides whether the device is on the air now. Each runtime step
// is read back, and the outcome is one word:
//   acl       the running ACL was changed and read back
//   ban       no usable hostapd_cli; hostapd's ubus deauthed and banned the
//             client, which expires by itself (WIFI_BAN_MS)
//   none      nothing could be applied or verified
//   no-radio  ubus answered and no AP runs; the maclist applies when one starts
// Only acl and no-radio mean the operator's intent is in force.

// hostapd's ubus object has no ACL method, so a timed ban is the strongest
// measure it offers; an hour, and always called temporary.
const WIFI_BAN_MS = 3600000;
function hostapd_cli(iface, args) {
	return lib.run('hostapd_cli -i ' + lib.q(iface) + ' ' + lib.qv(args), CLI_MS);
}

// Not the radios: the configured wifi-iface sections, in uci's order.
function wifi_sections() {
	let out = [];
	lib.uci_foreach('wireless', 'wifi-iface', (s) => {
		push(out, s);
	});
	return out;
}

function acl_blocks(iface, mac, mode) {
	if (mode == 'allow')
		return index(lc(hostapd_cli(iface, [ 'accept_acl', 'SHOW' ])), mac) < 0;
	return index(lc(hostapd_cli(iface, [ 'deny_acl', 'SHOW' ])), mac) >= 0;
}

function ubus_banned(iface, mac) {
	let b = lib.ubus_call('hostapd.' + iface, 'list_bans');
	return b != null && index(lc(lib.to_json(b)), mac) >= 0;
}

// The call's own status is ignored: it fails for a client that is not
// associated while the ban still lands, and list_bans is the answer.
function ubus_ban(iface, mac) {
	lib.ubus_call('hostapd.' + iface, 'del_client', { addr: mac, reason: 1, deauth: true, ban_time: WIFI_BAN_MS });
	return ubus_banned(iface, mac);
}

function block_iface(iface, mac, mode) {
	if (cli_alive(iface)) {
		hostapd_cli(iface, (mode == 'allow') ? [ 'accept_acl', 'DEL_MAC', mac ] : [ 'deny_acl', 'ADD_MAC', mac ]);
		hostapd_cli(iface, [ 'deauthenticate', mac ]);
		if (acl_blocks(iface, mac, mode))
			return 'acl';
	}
	return ubus_ban(iface, mac) ? 'ban' : 'none';
}

function unblock_iface(iface, mac, mode) {
	if (cli_alive(iface)) {
		hostapd_cli(iface, (mode == 'allow') ? [ 'accept_acl', 'ADD_MAC', mac ] : [ 'deny_acl', 'DEL_MAC', mac ]);
		// The ACL lets the MAC in again, but a ban from an earlier block
		// without hostapd_cli still keeps it out, and ubus cannot lift one.
		if (!acl_blocks(iface, mac, mode))
			return ubus_banned(iface, mac) ? 'ban' : 'acl';
	}
	return ubus_banned(iface, mac) ? 'ban' : 'none';
}

// Enforced from the runtime state on every call, so pressing Block again
// applies a block that only ever reached the config.
function hostapd_apply(op, mac, mode) {
	let ifaces = hostapd_ifaces();
	if (ifaces == null)
		return 'none';
	if (!length(ifaces))
		return 'no-radio';
	let rank = { acl: 3, ban: 2 }, worst = 3;
	for (let ifc in ifaces) {
		let st = (op == 'block') ? block_iface(ifc, mac, mode) : unblock_iface(ifc, mac, mode);
		let r = rank[st] ?? 1;
		if (r < worst)
			worst = r;
	}
	return (worst == 3) ? 'acl' : (worst == 2) ? 'ban' : 'none';
}

// The MAC as the scripts found it: the first lease for ip, else the first
// MAC-shaped word of its neighbour entry. Validated, which they did not.
function wifi_mac(ip) {
	let mac = null;
	if (lib.is_file(LEASES))
		for (let l in lib.file_lines(LEASES))
			if (lib.field(l, 2) == ip) {
				mac = lib.field(l, 1);
				break;
			}
	if (mac == null || mac == '') {
		let m = match(lib.run('ip neigh show ' + lib.q(ip)), /[0-9a-fA-F:]{17}/);
		mac = m ? m[0] : null;
	}
	return lib.norm_mac(mac);
}

const MACFILTER_USAGE = {
	add: 'usage: trafficctl macfilter-add <ip>',
	remove: 'usage: trafficctl macfilter-remove <ip|mac>',
};

function macfilter(op, arg) {
	if (arg == null || arg == '')
		return reply({ ok: false, msg: MACFILTER_USAGE[op] });
	let ip = arg, mac = null;
	// A MAC too: the deny list is keyed on it, and a device long gone has no
	// lease or neighbour entry left to find it by (#128).
	if (op == 'remove' && lib.norm_mac(arg) != null) {
		mac = lib.norm_mac(arg);
		ip = null;
		for (let l in lib.file_lines(LEASES))
			if (lc(lib.field(l, 1)) == mac) {
				ip = lib.field(l, 2);
				break;
			}
		if (ip == null || ip == '')
			ip = mac;
	}
	else if (!lib.valid_ip(arg))
		return reply({ ok: false, msg: 'invalid IP address' });
	mac ??= wifi_mac(ip);
	if (mac == null)
		return reply({ ok: false, msg: 'cannot find MAC for ' + ip });

	let secs = wifi_sections();
	if (!length(secs))
		return reply({ ok: false, msg: 'no wifi interfaces found' });

	// The policy the administrator chose: forcing "deny" once turned a
	// curated allow-list into a block-list.
	let changed = false, mode = 'deny';
	for (let s in secs) {
		let name = s['.name'], allow = (s.macfilter == 'allow');
		if (allow)
			mode = 'allow';
		let list = (type(s.maclist) == 'array') ? join(' ', s.maclist) : '' + (s.maclist ?? '');
		let listed = index(lc(list), mac) >= 0;
		if (!allow && op == 'add' && (s.macfilter == null || s.macfilter == '')) {
			lib.uci_cli([ 'set', 'wireless.' + name + '.macfilter=deny' ]);
			changed = true;
		}
		// Blocking takes the MAC off an allow-list or puts it on a deny-list
		// (made one if unset); unblocking does the opposite.
		if (allow ? (listed == (op == 'add')) : (listed != (op == 'add'))) {
			lib.uci_cli([ (allow == (op == 'add')) ? 'del_list' : 'add_list',
				'wireless.' + name + '.maclist=' + mac ]);
			changed = true;
		}
	}
	if (changed)
		lib.uci_cli([ 'commit', 'wireless' ]);

	// Always, not only when uci changed: a maclist that names the MAC while
	// the radio never got it made pressing Block again a no-op.
	let enf = hostapd_apply((op == 'add') ? 'block' : 'unblock', mac, mode);
	let min = WIFI_BAN_MS / 60000, ok = (enf == 'acl' || enf == 'no-radio'), msg;
	// The uci entry stays even when the radio refused it: it is the durable
	// record and applies at the next wifi start. What goes is the claim of
	// success. A wifi reload would apply it now and drop every client.
	if (op == 'add')
		msg = (enf == 'acl') ? sprintf('MAC %s blocked on wifi for %s', mac, ip)
			: (enf == 'no-radio') ? sprintf('MAC %s added to the wifi deny list for %s; no radio is running, it applies when wifi starts', mac, ip)
			: (enf == 'ban') ? sprintf('MAC %s is NOT permanently blocked: hostapd_cli is missing, so the block is temporary (%d min). Install hostapd-utils, or restart wifi (drops all clients)', mac, min)
			: sprintf('MAC %s saved to the wifi deny list but NOT applied to the radio, so the device stays online. Install hostapd-utils, or restart wifi (drops all clients)', mac);
	else
		msg = (enf == 'acl') ? sprintf('MAC %s removed from wifi filter for %s', mac, ip)
			: (enf == 'no-radio') ? sprintf('MAC %s removed from the wifi filter for %s; no radio is running', mac, ip)
			: (enf == 'ban') ? sprintf('MAC %s removed from the wifi filter, but hostapd still bans it for up to %d min. Restart wifi (drops all clients) to clear it now', mac, min)
			: sprintf('MAC %s removed from the wifi filter, but the radio ACL could not be read back: it may still be blocked. Install hostapd-utils, or restart wifi', mac);
	lib.log((op == 'add') ? 'wifi_block' : 'wifi_unblock', ip, 'MAC=' + mac + ' enforce=' + enf,
		getenv('TCTL_VIA'), getenv('TCTL_SRC'));
	if (op == 'add' && ok)
		notify.emit_action('block_applied', { ip, mac, kind: 'wifi' });
	// Exit 0 either way, as the scripts did: the reply says how far it got.
	return reply({ ok, enforcement: enf, msg }, 0);
}

// ── new devices (the DHCP hotplug hook) ─────────────────────────────────────

const KNOWN = '/etc/trafficctl/telegram_known.json';

// A limit somebody set deliberately, live or saved: after a reboot the
// restore hook runs only on ifup lan, and a default limit applied before
// that would overwrite the operator's choice.
function has_limit(ip) {
	if (ip == null || ip == '')
		return false;
	for (let s in ratelimit_stats())
		if (s.ip == ip)
			return true;
	for (let s in shape_stats())
		if (s.ip == ip)
			return true;
	let key = '"ip":"' + ip + '"';
	return index(lib.readfile(RULES) ?? '', key) >= 0 || index(lib.readfile(SHAPES) ?? '', key) >= 0;
}

// Two consumers of "this MAC is new", independent of each other: the bot's
// notification keys off its own telegram_known.json, the default limit off
// the seen-MAC ledger, because a limit must not be applied twice or by
// mistake.
function newdevice(env) {
	let mac = env.MACADDR ?? '', ip = env.IPADDR ?? '';
	if (env.ACTION != 'add' || mac == '')
		return 0;

	// Only an unknown MAC costs a notify start; `trafficctl notify dhcp`
	// decides whether anybody listens, detached so dnsmasq never waits on
	// the network.
	if (index(lib.readfile(KNOWN) ?? '', '"' + mac + '"') < 0)
		lib.sh(lib.qv([ lib.path('/usr/sbin/trafficctl'), 'notify', 'dhcp', mac, ip, env.HOSTNAME ?? '' ]) + ' &');

	if (lib.uci_get('trafficctl', 'newdevice', 'enabled') != '1')
		return 0;
	let kbit = lib.uci_get('trafficctl', 'newdevice', 'limit_kbit');
	if (!lib.valid_int(kbit, 1))
		return 0;

	// Without a ledger "new" has no answer, and the wrong one limits every
	// device as its lease renews. The seed reads leases and neighbours, thin
	// early in boot, so the first pass records the baseline and applies
	// nothing.
	if (!lib.seen_ready()) {
		lib.seen_seed();
		lib.seen_mark(mac);
		lib.logger(sprintf('newdevice: seeded the seen-MAC ledger (%d devices); no limit applied on this pass', lib.seen_count()));
		return 0;
	}
	if (lib.seen_known(mac))
		return 0;
	// Before acting: a failed apply must not leave the device unmarked, or
	// every renewal retries and races an operator setting a limit by hand.
	lib.seen_mark(mac);

	if (ip == '') {
		lib.logger(sprintf('newdevice: %s is new but has no address yet; no limit applied', mac));
		return 0;
	}
	if (has_limit(ip)) {
		lib.logger(sprintf('newdevice: %s (%s) already has a limit; left alone', ip, mac));
		return 0;
	}

	let shaper = (lib.uci_get('trafficctl', 'newdevice', 'limit_mode') == 'shaper');
	// The limiter logs its own entry, with this via/src; the shaper logs
	// nothing, so its entry is here.
	lib.set_context({ via: 'newdevice', src: 'hotplug' });
	let r = shaper
		? shape.main([ 'add', ip, kbit, 'shape_' + ip ])
		: limit.ratelimit([ ip, kbit, 'rl_ratelimit_' + lib.slug(ip) ]);
	lib.set_context({});
	if (r.rc == 0) {
		if (shaper)
			lib.log('shape_set', ip, kbit + 'kbit default for new device ' + mac, 'newdevice', 'hotplug');
	}
	else
		lib.logger(sprintf('newdevice: failed to apply %skbit to %s (%s)', kbit, ip, mac));
	return 0;
}

// ── restore after boot (the block half of the iface hotplug hook) ───────────

// At boot ifup lan can come before fw4 has loaded its ruleset.
const FW4_TRIES = 20;
const FW4_WAIT_MS = 500;

// The saved blocks, only while persist_rules is on (the shell hook's gate).
function restore() {
	let res = { ok: true, restored: 0, failed: 0 };
	if (!lib.persist_enabled())
		return res;
	let d = lib.read_records(RULES);
	if (d == null)
		return res;
	let ips = [];
	for (let r in d)
		if (type(r) == 'object' && r.type == 'block' && type(r.ip) == 'string' && r.ip != '')
			push(ips, r.ip);
	if (!length(ips))
		return res;
	for (let i = 0; i < FW4_TRIES && lib.sh('nft list table inet fw4') != 0; i++)
		sleep(FW4_WAIT_MS);
	let rules = nft_rules(FW4);
	for (let ip in ips) {
		// Checked before the rule string is built: the file is only as
		// trustworthy as whoever last wrote /etc. A block already in the
		// chain (lan going up again without a fw4 reload) is not doubled.
		if (lib.valid_ip(ip) && (is_blocked(ip, rules) || block_add(ip, block_comment(ip)).ok))
			res.restored++;
		else {
			res.failed++;
			lib.logger('Failed to restore block for ' + ip);
		}
	}
	res.ok = (res.failed == 0);
	return res;
}

// 2022-12 needs a ';' after `export function f() {}`; one list avoids it.
export { nft_rules, rate_kbit, rl_rules, rl_rate_kbit, live_blocks, ratelimit_stats,
	shape_records, shape_classmap, ifb_dev, tc_class_rates, shape_stats, rules_list,
	block_comment, is_blocked, block_add, block_remove, block_remove_legacy, block, unblock,
	macfilter, has_limit, newdevice, restore };
