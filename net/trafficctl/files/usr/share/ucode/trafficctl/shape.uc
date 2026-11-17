// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.shape: the shaper, tc/HTB classes per device, its records in
// shapes.json, and their restore on ifup lan.
//
//   import * as shape from 'trafficctl.shape';
//
//   ifb_dev()                the IFB device upload is shaped on
//   entries()                the records of shapes.json as the shell's
//                            pattern finds them, as text
//   lookup_classid(ip)       the classid recorded for ip, else null
//   legacy_classid(ip)       the classid derived from the address, as before
//                            classids were allocated; null if reserved
//   alloc_classid()          the lowest free classid, else null
//   apply(ip, rate, up)      both directions, then the record: { reply, rc }
//   remove(ip)               the classes on both devices, then the record
//   status(ip)               the download class's rate
//   main(args, quiet)        trafficctl shape <add|remove|status> <ip>
//                            [rate_kbit] [label] [rate_up]: { reply, rc };
//                            quiet (the restore): no limit_applied event
//   restore()                every record of shapes.json (ifup lan), quiet
//
// Download is shaped on the LAN device's egress (match ip dst), upload on an
// IFB device fed by mirred from the ingress of every LAN port (match ip src):
// at WAN egress the source is already masqueraded and a per-client filter
// matches nothing. Each address has one classid minor, the same on both
// devices, allocated once and kept in shapes.json.

import { dirname } from 'fs';
import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as limit from 'trafficctl.limit';
import * as notify from 'trafficctl.notify';

const SHAPES = '/etc/trafficctl/shapes.json';
// Shared with every other writer of shapes.json, the shell shaper of older
// releases among them: a bare mkdir lock, taken over after 5 s.
const LOCK = '/tmp/trafficctl_shapes.lock.d';
const LOCK_TRIES = 50;
const LOCK_STALE = 5;

// A minor is 16 bit; 1:1 is the root class and 1:fffe the default one. One
// derived from the address would put 192.168.0.1 on the root class (whose
// removal tears down every other shape) and x.x.255.254 on the default one,
// and two subnets sharing their last two octets on the same class.
const CLASSID_MIN = 2;
const CLASSID_MAX = 65533;

// The record pattern every release matched: a record it misses disappears
// from the allocator, its minor goes to another device, and removing one of
// the two tears down the other. Read per line, as grep -o did; the optional
// rate_kbit_up is at the tail, where the shell writer puts it.
const RECORD = /\{"ip":"[^"]+","rate_kbit":[0-9]+(,"classid":"1:[0-9a-f]+")?(,"rate_kbit_up":[0-9]+)?\}/g;
const WITH_CLASSID = /^\{"ip":"([^"]+)","rate_kbit":[0-9]+,"classid":"(1:[0-9a-f]+)"(,"rate_kbit_up":[0-9]+)?\}$/;

// Root qdiscs OpenWrt or the kernel put there carry nothing worth keeping,
// and HTB is taken for this app's own tree: ensure_root reuses an HTB root
// that has a class 1:1 and replaces one that has none, so a foreign HTB tree
// is not protected. Any other root (cake from SQM, HFSC, ...) is not torn
// down; shaping is declined instead.
const REPLACEABLE = [ 'pfifo_fast', 'fq_codel', 'fq', 'noqueue', 'mq', 'pfifo', 'bfifo', 'sfq', 'codel', 'htb' ];

const KMOD_IFB = 'opkg/apk install kmod-ifb kmod-sched';

function tc(argv) {
	return lib.sh('tc ' + lib.qv(argv)) == 0;
}

function tc_lines(argv) {
	return lib.lines('tc ' + lib.qv(argv));
}

function has_line(lines, s) {
	for (let l in lines)
		if (index(l, s) >= 0)
			return true;
	return false;
}

function ifb_dev() {
	let d = lib.uci_get('trafficctl', 'main', 'shape_ifb');
	return (d == null || d == '') ? 'tctl-ifb0' : d;
}

function entries() {
	let out = [];
	for (let l in lib.file_lines(SHAPES))
		for (let m in match(l, RECORD) ?? [])
			push(out, m[0]);
	return out;
}

function lookup_classid(ip, ents) {
	for (let e in ents ?? entries()) {
		let m = match(e, WITH_CLASSID);
		if (m && m[1] == ip)
			return m[2];
	}
	return null;
}

function legacy_classid(ip) {
	let o = split(ip, '.');
	if (length(o) != 4)
		return null;
	let dec = int(o[2]) * 256 + int(o[3]);
	return (dec < CLASSID_MIN || dec > CLASSID_MAX) ? null : sprintf('1:%x', dec);
}

// A hex minor as a number; one too long for any classid counts as large.
function hexval(h) {
	if (length(h) > 8)
		return CLASSID_MAX + 1;
	let n = 0;
	for (let i = 0; i < length(h); i++)
		n = n * 16 + index('0123456789abcdef', substr(h, i, 1));
	return n;
}

// Minors in shapes.json and in the live classes on both devices: a class
// left behind by a crash keeps its minor out of reuse too.
function used_minors(ents) {
	let used = {};
	for (let e in ents) {
		let m = match(e, /"classid":"1:([0-9a-f]+)"/);
		if (m)
			used['' + hexval(m[1])] = true;
	}
	for (let dev in [ net.lan_device(), ifb_dev() ])
		for (let l in tc_lines([ 'class', 'show', 'dev', dev ])) {
			let m = match(l, /^class htb 1:([0-9a-f]+) /);
			if (m)
				used['' + hexval(m[1])] = true;
		}
	return used;
}

function alloc_classid(ents) {
	let used = used_minors(ents ?? entries()), free = CLASSID_MIN;
	while (exists(used, '' + free))
		free++;
	return (free > CLASSID_MAX) ? null : sprintf('1:%x', free);
}

function root_replaceable(dev) {
	for (let l in tc_lines([ 'qdisc', 'show', 'dev', dev ]))
		if (index(l, ' root ') >= 0) {
			let f = filter(split(l, /[ \t]+/), (w) => w != '');
			return index(REPLACEABLE, f[1]) >= 0;
		}
	return true;
}

// The root HTB tree: 1: with the default class 1:fffe under 1:1. Its
// status is that of the last step, the default class's fq_codel, as it was.
function ensure_root(dev) {
	if (has_line(tc_lines([ 'class', 'show', 'dev', dev ]), 'class htb 1:1 '))
		return true;
	if (!root_replaceable(dev))
		return false;
	tc([ 'qdisc', 'del', 'dev', dev, 'root' ]);
	tc([ 'qdisc', 'add', 'dev', dev, 'root', 'handle', '1:', 'htb', 'default', 'fffe', 'r2q', '10' ]);
	tc([ 'class', 'add', 'dev', dev, 'parent', '1:', 'classid', '1:1', 'htb',
		'rate', '1000mbit', 'ceil', '1000mbit', 'burst', '125000b', 'cburst', '125000b' ]);
	tc([ 'class', 'add', 'dev', dev, 'parent', '1:1', 'classid', '1:fffe', 'htb',
		'rate', '1000mbit', 'ceil', '1000mbit', 'burst', '125000b', 'cburst', '125000b', 'prio', '0' ]);
	return tc([ 'qdisc', 'add', 'dev', dev, 'parent', '1:fffe', 'fq_codel' ]);
}

// The IFB device, and every LAN port's ingress mirrored into it. Needs
// kmod-ifb and act_mirred: false without them, so upload is reported as not
// shaped instead of pretended.
function ensure_ifb(ifb) {
	if (lib.sh('ip link show ' + lib.q(ifb)) != 0 &&
	    lib.sh('ip link add name ' + lib.q(ifb) + ' type ifb') != 0)
		return false;
	if (lib.sh('ip link set ' + lib.q(ifb) + ' up') != 0 || !ensure_root(ifb))
		return false;
	for (let dev in limit.ingress_devices()) {
		if (!has_line(tc_lines([ 'qdisc', 'show', 'dev', dev, 'ingress' ]), 'qdisc ingress'))
			tc([ 'qdisc', 'add', 'dev', dev, 'handle', 'ffff:', 'ingress' ]);
		if (!has_line(tc_lines([ 'filter', 'show', 'dev', dev, 'parent', 'ffff:' ]), 'mirred'))
			tc([ 'filter', 'add', 'dev', dev, 'parent', 'ffff:', 'protocol', 'ip', 'prio', '1', 'u32',
				'match', 'u32', '0', '0', 'action', 'mirred', 'egress', 'redirect', 'dev', ifb ]);
	}
	return has_line(tc_lines([ 'class', 'show', 'dev', ifb ]), 'class htb 1:1 ');
}

function filter_argv(op, dev, dir, ip) {
	return [ 'filter', op, 'dev', dev, 'parent', '1:0', 'prio', '10', 'protocol', 'ip', 'u32',
		'match', 'ip', dir, ip + '/32' ];
}

// The handles of the prio-10 filters on dev that send to class cid or match
// ip in direction dir. A u32 delete without a handle removes the whole prio,
// which up to v1.30.x took every other device's filter with it on each add
// and remove: only the last shape applied stayed in force. Verified on
// kernel 6.x; tools/ci/live-shape.sh checks it on every release's tc.
function filter_handles(dev, dir, ip, cid) {
	let o = map(split(ip, '.'), (x) => int(x));
	let key = sprintf('match %02x%02x%02x%02x/ffffffff at %d', o[0], o[1], o[2], o[3],
		(dir == 'dst') ? 16 : 12);
	let out = [], fh = null;
	for (let l in tc_lines([ 'filter', 'show', 'dev', dev, 'parent', '1:' ])) {
		let m = match(l, /^filter .*pref 10 u32 .*fh ([0-9a-f]+:[0-9a-f]*:[0-9a-f]+) .*flowid (1:[0-9a-f]+)/);
		if (m) {
			fh = m[1];
			if (m[2] == cid)
				push(out, fh);
		}
		else if (substr(l, 0, 7) == 'filter ')
			fh = null;
		else if (fh != null && trim(l) == key && index(out, fh) < 0)
			push(out, fh);
	}
	return out;
}

function detach(dev, dir, ip, cid) {
	for (let fh in filter_handles(dev, dir, ip, cid))
		tc([ 'filter', 'del', 'dev', dev, 'parent', '1:0', 'prio', '10', 'handle', fh, 'protocol', 'ip', 'u32' ]);
	tc([ 'qdisc', 'del', 'dev', dev, 'parent', cid ]);
	tc([ 'class', 'del', 'dev', dev, 'classid', cid ]);
}

// One class on dev for ip in one direction: dst on the LAN device, src on
// the IFB. tc's error output goes nowhere: the reply is the only output.
function attach(dev, dir, ip, cid, rate, burst) {
	detach(dev, dir, ip, cid);
	if (!ensure_root(dev))
		return false;
	if (!tc([ 'class', 'add', 'dev', dev, 'parent', '1:1', 'classid', cid, 'htb',
		'rate', rate + 'kbit', 'ceil', rate + 'kbit', 'burst', burst + 'b', 'cburst', burst + 'b' ]))
		return false;
	tc([ 'qdisc', 'add', 'dev', dev, 'parent', cid, 'fq_codel' ]);
	return tc([ ...filter_argv('add', dev, dir, ip), 'flowid', cid ]);
}

function rec_prefix(ip) {
	return '{"ip":"' + ip + '",';
}

// The record of ip replaced (rate > 0) or dropped (0), the others kept byte
// for byte: what the pattern does not match is dropped, as the shell did.
// rate_kbit_up only when the directions differ, so a symmetric shape writes
// the record every release reads. The caller holds LOCK (locked()).
function save(ip, rate, cid, up) {
	let pfx = rec_prefix(ip);
	let recs = filter(entries(), (e) => substr(e, 0, length(pfx)) != pfx);
	if (rate > 0)
		push(recs, sprintf('{"ip":"%s","rate_kbit":%d,"classid":"%s"%s}', ip, rate, cid,
			(up != null && up != rate) ? sprintf(',"rate_kbit_up":%d', up) : ''));
	return lib.write_atomic(SHAPES, '[' + join(',', recs) + ']', 0o644);
}

// fn() under LOCK, from the read of shapes.json to its write: two adds at
// once (the DHCP hook's and the UI's, or the bot's) would otherwise read the
// same file, pick the same free minor, and share one class. Not taken in 5 s
// (a holder that is stuck), fn runs anyway, as the shell writer did.
function locked(fn) {
	lib.mkdir_p(dirname(SHAPES));
	return lib.with_lock(LOCK, LOCK_TRIES, LOCK_STALE, fn);
}

const NOT_SAVED = ' — WARNING: shapes.json could not be written';

function reply(o, rc) {
	return { reply: o, rc: rc ?? (o.ok ? 0 : 1) };
}

function fail(msg) {
	return reply({ ok: false, msg });
}

// 10 ms of data, at least 1600 bytes.
function burst_of(kbit) {
	let b = int(kbit * 125 / 100);
	return (b < 1600) ? 1600 : b;
}

// The classes and the record, under LOCK: { err } or { cid, ul_ok, saved }.
function apply_locked(ip, rate, up) {
	let ents = entries();
	let cid = lookup_classid(ip, ents) ?? alloc_classid(ents);
	if (cid == null)
		return { err: 'no free shaping class available' };
	let lan = net.lan_device(), ifb = ifb_dev();

	if (!attach(lan, 'dst', ip, cid, rate, burst_of(rate))) {
		// Declining a foreign root qdisc is deliberate (it is how SQM
		// survives this app), and "tc setup failed" would read as a bug.
		if (!root_replaceable(lan))
			return { err: 'shaping declined on ' + lan + ': another QoS setup (SQM/cake or another non-HTB qdisc) owns the root qdisc and will not be torn down. Use the limiter instead — it is a policer and coexists with SQM.' };
		return { err: 'tc setup failed for ' + ip + ' on ' + lan };
	}
	// Reported apart, so a missing kmod-ifb does not read as a total failure.
	let ul_ok = ensure_ifb(ifb) && attach(ifb, 'src', ip, cid, up, burst_of(up));
	return { cid, ul_ok, saved: save(ip, rate, cid, up) };
}

// Both directions and the record; rates already validated, as ints. A record
// that cannot be written leaves the shape in force but unknown to the
// restore and to every reader: still ok, and the reply says so.
function apply(ip, rate, up) {
	let a = locked(() => apply_locked(ip, rate, up));
	if (a.err != null)
		return fail(a.err);
	let cid = a.cid, ul_ok = a.ul_ok;
	let rates = (up != rate) ? sprintf('%d kbit/s down, %d kbit/s up', rate, up) : sprintf('%d kbit/s', rate);
	// HTB never queues a flow the NSS firmware forwards (#81): installed and
	// inert, and said so.
	lib.nss_defunct();
	let note = lib.nss_note(), nss = lib.nss_status(), msg;
	if (ul_ok)
		msg = sprintf('shape %s applied to %s both directions (class %s)%s', rates, ip, cid, note);
	else if (up != rate)
		// "applied" would be a lie about the half asked to differ.
		msg = sprintf('shape %d kbit/s applied to %s for download only — the %d kbit/s upload ceiling was NOT applied, it needs kmod-ifb: %s%s',
			rate, ip, up, KMOD_IFB, note);
	else
		msg = sprintf('shape %d kbit/s applied to %s (download only — upload needs kmod-ifb: %s)%s', rate, ip, KMOD_IFB, note);
	if (!a.saved)
		msg += NOT_SAVED + ': this shape will not be restored on the next ifup lan';
	return reply({ ok: true, nss, msg });
}

// The class of ip's record: its classid, or for a record written before
// classids were allocated the one derived from the address. No record, no
// class: the derived minor of an address never shaped may be allocated to
// another device, and detaching it would tear that device's shape down.
function remove_locked(ip) {
	let ents = entries(), pfx = rec_prefix(ip);
	let cid = lookup_classid(ip, ents);
	if (cid == null && length(filter(ents, (e) => substr(e, 0, length(pfx)) == pfx)))
		cid = legacy_classid(ip);
	if (cid != null) {
		detach(net.lan_device(), 'dst', ip, cid);
		detach(ifb_dev(), 'src', ip, cid);
	}
	return save(ip, 0);
}

function remove(ip) {
	let msg = 'shape removed for ' + ip;
	if (!locked(() => remove_locked(ip)))
		msg += NOT_SAVED + ': the record stays and the shape comes back on the next ifup lan';
	return reply({ ok: true, msg });
}

function status(ip) {
	let cid = lookup_classid(ip), info = 'no shape active';
	if (cid != null) {
		let out = lib.run('tc ' + lib.qv([ '-s', 'class', 'show', 'dev', net.lan_device(), 'classid', cid ]));
		if (out != '') {
			let m = match(out, /rate [0-9]+[a-zA-Z]+/);
			info = m ? split(m[0], ' ')[1] : '';
		}
	}
	return reply({ ok: true, ip, classid: cid ?? '', info });
}

function arg(a) {
	return (a == null) ? '' : '' + a;
}

const USAGE = 'usage: trafficctl shape <add|remove|status> <ip> [rate_kbit] [label]';

// args: <add|remove|status> <ip> [rate_kbit] [label] [rate_up]. The label is
// taken and unused; an empty rate_up is the download rate, never zero (a
// zero ceiling is a total upload block reported as success). quiet: the
// restore, which puts back what was already announced.
function main(args, quiet) {
	let action = arg(args[0]), ip = arg(args[1]), rate = arg(args[2]), up = arg(args[4]);
	if (up == '')
		up = rate;
	if (action != 'add' && action != 'remove' && action != 'status')
		return fail(USAGE);
	if (ip == '' || (action == 'add' && rate == ''))
		return fail((action == 'add') ? 'usage: trafficctl shape add <ip> <rate_kbit> [label]'
			: sprintf('usage: trafficctl shape %s <ip>', action));
	if (!lib.valid_ip(ip))
		return fail('invalid IP address');
	if (action == 'remove')
		return remove(ip);
	if (action == 'status')
		return status(ip);
	// Here and not at the callers: rpcd, the bot, newdevice and the restore.
	if (limit.valid_rate(rate) == null)
		return fail(sprintf('invalid rate: expected whole kbit/s, 1 to %d', limit.MAX_KBIT));
	if (limit.valid_rate(up) == null)
		return fail(sprintf('invalid upload rate: expected whole kbit/s, 1 to %d', limit.MAX_KBIT));
	let r = apply(ip, int(rate), int(up));
	// Announced as the shell shaper did (tctl_notify after the save), but not
	// by the restore, which passes quiet: a reboot does not announce every
	// saved shape again. emit_action also stays silent under TCTL_NOTIFY=0,
	// which the ifup hook exports for everything it runs.
	if (r.rc == 0 && !quiet)
		notify.emit_action('limit_applied', { ip, rate_kbit: int(rate), rate_kbit_up: int(up), mode: 'shaper' });
	return r;
}

// A record field as the shell's jsonfilter printed it.
function rec_str(v) {
	if (v == null)
		return '';
	if (type(v) == 'string' || type(v) == 'int')
		return '' + v;
	return lib.to_json(v);
}

// Every record of shapes.json, whatever persist_rules says: a shape is
// always saved, and nothing else knows which class belongs to which
// device. Through the same validation as `trafficctl shape add`; nothing is
// logged to the activity log or announced, as nothing was changed. A file
// that is no JSON array is reported by lib.read_records and left alone.
function restore() {
	let res = { restored: 0, failed: 0 }, d = lib.read_records(SHAPES);
	if (d == null)
		return res;
	for (let r in d) {
		if (type(r) != 'object' || r.ip == null || r.ip == '')
			continue;
		let ip = rec_str(r.ip), rate = rec_str(r.rate_kbit), up = rec_str(r.rate_kbit_up), ok;
		if (rate == '' || rate == '0')
			continue;
		// One record that dies (a tc or file error) does not stop the rest.
		try {
			ok = main([ 'add', ip, rate, 'shape_' + ip, up ], true).rc == 0;
		}
		catch (e) {
			ok = false;
		}
		if (ok)
			res.restored++;
		else {
			res.failed++;
			lib.logger(sprintf('Failed to restore shape for %s (%skbit)', ip, rate));
		}
	}
	return res;
}

// 2022-12 needs a ';' after `export function f() {}`; one list avoids it.
export { ifb_dev, entries, lookup_classid, legacy_classid, alloc_classid, apply, remove, status,
	main, restore };
