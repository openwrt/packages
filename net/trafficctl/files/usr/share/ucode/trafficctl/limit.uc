// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.limit: the rate limiter, a policer in nft table netdev
// tm_ratelimit, and its restore on ifup lan.
//
//   import * as limit from 'trafficctl.limit';
//
//   MAX_KBIT                 the highest ceiling, 100 Gbit/s
//   valid_rate(s)            a ceiling in kbit/s: 1..MAX_KBIT, digits, no
//                            leading zero; the int, else null
//   rate_bytes(kbit)         the bytes/second nft is given (SI, at least 1)
//   default_mode(t)          shared for a host or a /32, each for a block
//   comment(t)               rl_ratelimit_<t with . and / as _>
//   wan_device()             the WAN netdev, checked in sysfs; null if none
//   ingress_devices()        the LAN devices, bridges as their ports
//   add(ip, kbit, cmt, mode, kbit_up)
//                            both directions, rule by rule; what loaded:
//                            { netdev, dl_failed, ul_failed, dl_err, ul_err,
//                              ul6, dl6 }
//   remove(ip, cmt)          the rules with these comments, the meters they
//                            used, then the IPv6 address set
//   remove_legacy(ip, cmt)   a limit from before v1.13.2, comment
//                            rl_ratelimit_<label>: only the rules that name
//                            ip, then their meters
//   ratelimit(args)          trafficctl ratelimit: { reply, rc }
//   restore()                the ratelimit records of rules.json (ifup lan)
//
// Download is policed at LAN egress on each LAN device (chain dl_<dev>,
// ip daddr), with WAN ingress (chain dl) as the fallback of a kernel without
// the egress hook; upload at LAN ingress on every bridge port (ul_<port>,
// ip saddr). Every rule is its own nft command: a port that refuses one
// loses only that rule, and the device and nft's reason are reported.

import { stat, lsdir } from 'fs';
import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as notify from 'trafficctl.notify';

const RULES = '/etc/trafficctl/rules.json';
const SYSFS = '/sys/class/net';
const TABLE = [ 'netdev', 'tm_ratelimit' ];
export const MAX_KBIT = 100000000;

// tctl_validate_rate. A leading zero is refused because the shell read it
// as octal, and anything else that is not digits as 0: a 1 byte/s limit,
// which is a block reported as success.
function valid_rate(s) {
	if (type(s) == 'int')
		s = '' + s;
	if (!lib.plain(s) || !match(s, /^[1-9][0-9]{0,8}$/))
		return null;
	let n = int(s);
	return (n <= MAX_KBIT) ? n : null;
}

// kbit/s is SI, 1000 bits, as in tc and the UI; nft's kbytes is 1024 bytes,
// so the rate is written in bytes.
function rate_bytes(kbit) {
	let b = int(kbit) * 125;
	return (b < 1) ? 1 : b;
}

// A shared cap on a block lets one device starve the rest. The boot restore
// gives a record saved without a mode the same answer, so a subnet does not
// change meaning across a reboot.
function default_mode(t) {
	t = '' + t;
	if (substr(t, -3) == '/32')
		return 'shared';
	return (index(t, '/') >= 0) ? 'each' : 'shared';
}

// lib.valid_target, and a zero-padded mask as 1.30.x took it
// (tctl_validate_target read 10.0.0.0/024 as a number and kept it as
// typed): in its normal form, 10.0.0.0/24.
function target(s) {
	let t = lib.valid_target(s);
	if (t != null)
		return t;
	let m = lib.plain(s) ? match(s, /^([0-9.]+)\/0+([0-9]{1,2})$/) : null;
	return m ? lib.valid_target(m[1] + '/' + int(m[2])) : null;
}

// From the target, never the caller's label (see ctl.block_comment).
function comment(t) {
	return 'rl_ratelimit_' + lib.slug(t);
}

function fields(l) {
	return filter(split(l, /[ \t]+/), (w) => w != '');
}

// Device names come from ubus, uci, the routing table and sysfs, and go
// into an nft command (device %s) and a sysfs path: only what the kernel
// itself allows in a name (IFNAMSIZ, no '/' or space) and nft parses as one
// word.
function valid_dev(d) {
	return lib.plain(d) && match(d, /^[A-Za-z0-9._@-]{1,15}$/) != null && d != '.' && d != '..';
}

// For a message: the name with anything unsafe masked.
function shown_dev(d) {
	return lib.plain(d) ? replace(substr(d, 0, 32), /[^A-Za-z0-9._@-]/g, '?') : '?';
}

function is_dev(d) {
	return valid_dev(d) && stat(lib.path(SYSFS + '/' + d)) != null;
}

// Every candidate is checked in sysfs: the literal "wan" the shell once
// fell back to is an interface name, nft refused the chain, and download
// went unlimited while the limit was reported.
function wan_device() {
	let cands = [];
	let l3 = lib.ubus_call('network.interface.wan', 'status')?.l3_device;
	if (type(l3) == 'string')
		push(cands, ...fields(l3));
	push(cands, ...lib.uci_words('network', 'wan', 'device'));
	push(cands, ...lib.uci_words('network', 'wan', 'ifname'));
	let rt = null;
	for (let l in lib.lines('ip route show default')) {
		let f = fields(l);
		if (substr(l, 0, 7) != 'default')
			continue;
		for (let i = 0; i < length(f) - 1 && rt == null; i++)
			if (f[i] == 'dev')
				rt = f[i + 1];
		if (rt != null) {
			push(cands, rt);
			break;
		}
	}
	for (let d in cands)
		if (is_dev(d))
			return d;
	return null;
}

// A netdev ingress hook on a bridge never sees bridged traffic: packets are
// received on its ports, so the hook goes there.
function ingress_devices() {
	let out = [];
	for (let d in net.lan_devices()) {
		let brif = lib.path(SYSFS + '/' + d + '/brif');
		if (stat(brif)?.type == 'directory')
			push(out, ...(lsdir(brif) ?? []));
		else
			push(out, d);
	}
	return sort(uniq(out));
}

// Chain names cannot hold the dots and dashes device names do.
function chain(pfx, dev) {
	return pfx + replace(dev, /[^a-zA-Z0-9]/g, '_');
}

// A test knob, but it lands in an nft set declaration: a duration or the
// default.
function v6_timeout() {
	let t = getenv('TCTL_V6SET_TIMEOUT');
	return (lib.plain(t) && match(t, /^[0-9]{1,9}[smhd]$/)) ? t : '1h';
}

function nft(argv) {
	return lib.sh('nft ' + lib.qv(argv)) == 0;
}

// The reason in nft's error output, one line, safe in a JSON string: the
// LAST "Error: " line, as nftables 1.0.2 prints a spurious "Not supported"
// before the meter clash's "Resource busy".
function nft_err(out) {
	let last = '';
	for (let l in split(out ?? '', '\n'))
		if (substr(l, 0, 7) == 'Error: ')
			last = replace(substr(l, 7), /^Could not process rule: /, '');
	return replace((last != '') ? last : 'nft failed', /["\\]/g, '');
}

// An added rule: null when it went in, else nft's reason.
function add_rule(ch, text) {
	let r = lib.run_rc('nft ' + lib.qv([ 'add', 'rule', ...TABLE, ch, text ]), null, true);
	return (r.rc == 0) ? null : nft_err(r.out);
}

function add_chain(ch, hook, dev, prio) {
	nft([ 'add', 'chain', ...TABLE, ch,
		sprintf('{ type filter hook %s device %s priority %d; policy accept; }', hook, dev, prio) ]);
}

// One meter per chain, tctl_m_<slug>_<chain>: nftables 1.0 binds a meter to
// the rule that declares it, so one name on every port failed with "Resource
// busy" after the first; nftables 1.1 keeps it as a named set that outlives
// its rules (hence the set deletion in delete_rules). At most 44 characters.
function v4_expr(fld, ip, b, mode, s, ch) {
	if (mode == 'each')
		return sprintf('ip %s %s meter tctl_m_%s_%s { ip %s limit rate over %d bytes/second }', fld, ip, s, ch, fld, b);
	return sprintf('ip %s %s limit rate over %d bytes/second', fld, ip, b);
}

function joined(a, b) {
	return (a != '' && b != '') ? a + '; ' + b : a + b;
}

// IPv6 is keyed on the MAC where the client's own frame is available: the
// upload policer, and the rule feeding its addresses into tctl_v6_<slug> at
// LAN ingress, which the download policer matches at egress (no L2 header
// there yet). The set is fed by the data path, so a rotated privacy address
// is in from its first packet. "meta protocol ip6", not "meta nfproto": nft
// rejects nfproto in the netdev family. Without the scope the ether rule
// would police the client's IPv4 a second time.
function add(ip, kbit, cmt, mode, kbit_up) {
	if (kbit_up == null || kbit_up == '')
		kbit_up = kbit;
	let b = rate_bytes(kbit), bu = rate_bytes(kbit_up), s = lib.slug(ip);
	let res = { netdev: true, dl_failed: false, ul_failed: false, dl_err: '', ul_err: '', ul6: false, dl6: false };

	let ul6 = null, feed6 = null, dl6 = null, v6set = 'tctl_v6_' + s;
	let mac = net.target_mac(ip);
	if (mac != null) {
		ul6 = sprintf('meta protocol ip6 ether saddr %s limit rate over %d bytes/second', mac, bu);
		feed6 = sprintf('meta protocol ip6 ether saddr %s ip6 saddr != fe80::/10 update @%s { ip6 saddr }', mac, v6set);
		dl6 = sprintf('meta protocol ip6 ip6 daddr @%s limit rate over %d bytes/second', v6set, b);
	}

	// Without the netdev family (kmod-nft-netdev) every chain below fails
	// too: stop and say why.
	let t = lib.run_rc('nft ' + lib.qv([ 'add', 'table', ...TABLE ]), null, true);
	if (t.rc != 0) {
		lib.logger('rate limit: cannot create nft table netdev tm_ratelimit (kmod-nft-netdev missing?): ' + rtrim(t.out, '\n'));
		res.netdev = false;
		res.dl_failed = res.ul_failed = true;
		return res;
	}
	// Before any rule names it; without it the v6 download half is skipped
	// and reported as such, never half-built.
	if (dl6 != null && !nft([ 'add', 'set', ...TABLE, v6set,
		sprintf('{ type ipv6_addr; flags dynamic,timeout; timeout %s; }', v6_timeout()) ]))
		feed6 = dl6 = null;

	// Download at LAN egress on the device itself: at WAN ingress a reply is
	// still addressed to the masqueraded WAN address, and an egress hook on
	// a bridge port never fires for routed traffic.
	let dl_ok = false, dl6_ok = false, dl_err = '', dl6_err = '', e;
	for (let dev in net.lan_devices()) {
		if (!valid_dev(dev)) {
			dl_err = joined(dl_err, shown_dev(dev) + ': invalid device name');
			lib.logger('rate limit: skipped LAN device with an invalid name: ' + shown_dev(dev));
			continue;
		}
		let ch = chain('dl_', dev);
		add_chain(ch, 'egress', dev, 0);
		if ((e = add_rule(ch, v4_expr('daddr', ip, b, mode, s, ch) + ' counter drop comment "' + cmt + '"')) == null)
			dl_ok = true;
		else
			dl_err = joined(dl_err, dev + ': ' + e);
		if (dl6 == null)
			continue;
		if ((e = add_rule(ch, dl6 + ' counter drop comment "' + cmt + '_dl6"')) == null)
			dl6_ok = true;
		else
			dl6_err = joined(dl6_err, dev + ': ' + e);
	}
	// A kernel before 5.16 has no egress hook: WAN ingress, right for a
	// client that is not masqueraded, and for IPv6. Only when no LAN device
	// took the rule, whose errors then say nothing the fallback's will not.
	let wan = dl_ok ? null : wan_device();
	if (wan != null) {
		dl_err = dl6_err = '';
		dl6_ok = false;
		add_chain('dl', 'ingress', wan, -200);
		if ((e = add_rule('dl', v4_expr('daddr', ip, b, mode, s, 'dl') + ' counter drop comment "' + cmt + '"')) == null)
			dl_ok = true;
		else
			dl_err = wan + ': ' + e;
		if (dl6 != null) {
			if ((e = add_rule('dl', dl6 + ' counter drop comment "' + cmt + '_dl6"')) == null)
				dl6_ok = true;
			else
				dl6_err = wan + ': ' + e;
		}
	}
	if (dl6_err != '')
		dl_err = joined(dl_err, 'IPv6 ' + dl6_err);
	if (dl_err != '') {
		lib.logger('rate limit: download rule for ' + ip + ' failed on ' + dl_err);
		res.dl_err = 'download rule failed on ' + dl_err;
	}
	res.dl_failed = !dl_ok;

	// One chain per port: a port that refuses the hook loses only its own.
	let ul_ok = false, ul6_ok = false, feed6_ok = false, ul_err = '', ul6_err = '', feed6_err = '';
	for (let dev in ingress_devices()) {
		if (!valid_dev(dev)) {
			ul_err = joined(ul_err, shown_dev(dev) + ': invalid device name');
			lib.logger('rate limit: skipped LAN port with an invalid name: ' + shown_dev(dev));
			continue;
		}
		let ch = chain('ul_', dev);
		add_chain(ch, 'ingress', dev, -200);
		if ((e = add_rule(ch, v4_expr('saddr', ip, bu, mode, s, ch) + ' counter drop comment "' + cmt + '_ul"')) == null)
			ul_ok = true;
		else
			ul_err = joined(ul_err, dev + ': ' + e);
		if (ul6 == null)
			continue;
		// Feed before police, so a packet the upload limit drops still keeps
		// its address in the set. A port it misses leaves the addresses
		// behind it out, so its failure goes with the download direction.
		if (feed6 != null) {
			if ((e = add_rule(ch, feed6 + ' comment "' + cmt + '_v6"')) == null)
				feed6_ok = true;
			else
				feed6_err = joined(feed6_err, dev + ': ' + e);
		}
		if ((e = add_rule(ch, ul6 + ' counter drop comment "' + cmt + '_ul6"')) == null)
			ul6_ok = true;
		else
			ul6_err = joined(ul6_err, dev + ': ' + e);
	}
	if (feed6_err != '') {
		lib.logger('rate limit: IPv6 address feed for ' + ip + ' failed on ' + feed6_err);
		res.dl_err = joined(res.dl_err, 'IPv6 address feed failed on ' + feed6_err);
	}
	if (ul6_err != '')
		ul_err = joined(ul_err, 'IPv6 ' + ul6_err);
	if (ul_err != '') {
		lib.logger('rate limit: upload rule for ' + ip + ' failed on ' + ul_err);
		res.ul_err = 'upload rule failed on ' + ul_err;
	}
	res.ul_failed = !ul_ok;
	res.ul6 = ul6_ok;
	// A download rule over a set nothing feeds matches nothing.
	res.dl6 = dl6_ok && feed6_ok;
	return res;
}

// The fields of the first comment in a listed rule, quotes included; null
// when it has none.
function comment_of(f) {
	for (let i = 0; i < length(f) - 1; i++)
		if (f[i] == 'comment')
			return f[i + 1];
	return null;
}

// The rules pick(fields) chooses, then the meters they used. Meters are read
// from the rules, not rebuilt from the name format, so a chain whose device
// is gone and the per-target tctl_u_/tctl_d_ names of releases before 1.30.4
// go too: nftables 1.0 lists "meter <name>", 1.1 "add @<name>" and keeps the
// set, which can only go after the last rule using it. Read as text, the
// listing every release matched comments against.
function delete_rules(pick) {
	let ch = null, rules = [], sets = [], seen = {};
	for (let l in lib.lines('nft -a list table netdev tm_ratelimit')) {
		let m = match(l, /^[ \t]*chain ([a-zA-Z0-9_]+) \{/);
		if (m) {
			ch = m[1];
			continue;
		}
		let f = fields(l);
		if (!pick(f))
			continue;
		let h = null, set = null;
		for (let i = 0; i < length(f) - 1; i++) {
			if (f[i] == 'handle')
				h = f[i + 1];
			if (f[i] == 'meter')
				set = f[i + 1];
			if (f[i] == 'add' && substr(f[i + 1], 0, 1) == '@')
				set = substr(f[i + 1], 1);
		}
		if (h != null && ch != null)
			push(rules, [ ch, h ]);
		if (set != null && !exists(seen, set)) {
			seen[set] = true;
			push(sets, set);
		}
	}
	for (let r in rules)
		nft([ 'delete', 'rule', ...TABLE, r[0], 'handle', r[1] ]);
	for (let set in sets)
		nft([ 'delete', 'set', ...TABLE, set ]);
}

const SUFFIXES = [ '', '_ul', '_ul6', '_dl6', '_v6' ];

// 1.30.x kept a zero-padded mask as typed (10.0.0.0/024) in the comment:
// the comment with the mask as a number, and the slug as it was, else null.
function unpad(c) {
	let m = match(c, /^"rl_ratelimit_([0-9]+_[0-9]+_[0-9]+_[0-9]+)_(0+[0-9]+)(_ul|_ul6|_dl6|_v6)?"$/);
	if (!m)
		return null;
	return [ sprintf('"rl_ratelimit_%s_%d%s"', m[1], int(m[2]), m[3] ?? ''), m[1] + '_' + m[2] ];
}

// The whole quoted comment: "_ul" is a prefix of "_ul6" and the slugs nest,
// so a substring would take 192.168.1.10's rules for 192.168.1.1's. The same
// comment with a zero-padded mask is the same target. The v6 address sets
// last, once no rule uses them. Most targets never had one, and its absence
// is not a failure: the shell once returned nft's status here, so removing
// such a limit failed and left its rules.json record.
function remove(ip, cmt) {
	let want = {}, padded = {};
	for (let x in SUFFIXES)
		want['"' + cmt + x + '"'] = true;
	delete_rules(function(f) {
		let c = comment_of(f) ?? '';
		if (exists(want, c))
			return true;
		let u = unpad(c);
		if (u == null || !exists(want, u[0]))
			return false;
		padded[u[1]] = true;
		return true;
	});
	nft([ 'delete', 'set', ...TABLE, 'tctl_v6_' + lib.slug(ip) ]);
	for (let s in keys(padded))
		nft([ 'delete', 'set', ...TABLE, 'tctl_v6_' + s ]);
	return true;
}

// Limits from before v1.13.2 carry the caller's label (rl_ratelimit_<label>,
// upload <...>_ul), and every target limited from Telegram shares
// rl_ratelimit_tg: v1.30.5 and earlier removed that comment on every target
// at once. A rule goes only when it also names exactly this target, the
// download rule as ip daddr, the upload rule as ip saddr (as main's
// tctl_ratelimit_remove_legacy, #161). Those releases wrote nothing for IPv6.
function remove_legacy(ip, cmt) {
	let dl = '"' + cmt + '"', ul = '"' + cmt + '_ul"';
	delete_rules(function(f) {
		let c = comment_of(f), dir = (c == dl) ? 'daddr' : (c == ul) ? 'saddr' : null;
		if (dir == null)
			return false;
		for (let i = 0; i + 2 < length(f); i++)
			if (f[i] == 'ip' && f[i + 1] == dir && (f[i + 2] == ip || f[i + 2] == ip + '/32'))
				return true;
		return false;
	});
}

function reply(o, rc) {
	return { reply: o, rc: rc ?? (o.ok ? 0 : 1) };
}

function fail(msg) {
	return reply({ ok: false, msg });
}

function arg(a) {
	return (a == null) ? '' : '' + a;
}

// The records of t in another spelling: 1.30.x saved a zero-padded mask as
// typed, and "all" as it was given. remove() takes their rules.
// false when one of them could not be removed, as persist_remove says.
function unsave_others(t) {
	if (!lib.persist_enabled())
		return null;
	let d, ok = true;
	try {
		d = json(lib.readfile(RULES) ?? '');
	}
	catch (e) {
		return ok;
	}
	for (let r in (type(d) == 'array') ? d : [])
		if (type(r) == 'object' && r.type == 'ratelimit' && type(r.ip) == 'string' &&
		    r.ip != t && target(r.ip) == t && !lib.persist_remove('ratelimit', r.ip))
			ok = false;
	return ok;
}

// Both writes of a change: false if either failed, null if neither ran.
function both(a, b) {
	return (a === false || b === false) ? false : (a ?? b);
}

// args: <target> <rate_kbit> [label] [mode] [rate_up]. rate 0 removes the
// limit; an empty rate_up is the download rate, never zero (a zero ceiling
// polices every packet: a block reported as a limit).
function ratelimit(args) {
	let ip = arg(args[0]), rate = arg(args[1]), label = arg(args[2]), mode = arg(args[3]), up = arg(args[4]);
	if (up == '')
		up = rate;
	if (ip == '' || rate == '')
		return fail('usage: trafficctl ratelimit <target> <rate_kbit> [label] [each|shared]');
	// Here and not at the callers: rpcd, the bot and the CLI all land here.
	if (rate != '0' && valid_rate(rate) == null)
		return fail(sprintf('invalid rate: expected whole kbit/s, 1 to %d', MAX_KBIT));
	if (rate != '0' && valid_rate(up) == null)
		return fail(sprintf('invalid upload rate: expected whole kbit/s, 1 to %d', MAX_KBIT));
	let t = target(ip);
	if (t == null)
		return fail('invalid target — expected an IP, a CIDR, or "all"');
	ip = t;
	if (mode == '')
		mode = default_mode(ip);
	if (mode != 'each' && mode != 'shared')
		return fail('mode must be each or shared');
	if (label == '')
		label = 'rl_' + lib.slug(ip);
	let cmt = comment(ip), via = getenv('TCTL_VIA'), src = getenv('TCTL_SRC');

	if (rate == '0') {
		// A limit from before comments were derived from the target carries
		// the caller's label, so one set from LuCI could not be removed from
		// Telegram.
		remove_legacy(ip, 'rl_ratelimit_' + label);
		remove(ip, cmt);
		let removed = both(unsave_others(ip), lib.persist_enabled() ? lib.persist_remove('ratelimit', ip) : null);
		lib.log('ratelimit_remove', ip, '', via, src);
		return reply({ ok: true, msg: 'rate limit removed for ' + ip +
			lib.persist_warn(removed, 'the saved limit is still there and comes back on the next ifup lan') });
	}

	let rk = int(rate), uk = int(up);
	let rates = (uk != rk) ? sprintf('%d kbit/s down, %d kbit/s up', rk, uk) : sprintf('%d kbit/s', rk);
	remove(ip, cmt);
	let unsaved = unsave_others(ip);
	let r = add(ip, rk, cmt, mode, uk);
	if (!r.netdev)
		return fail('failed to set rate limit for ' + ip + ': cannot create the nftables netdev table (is kmod-nft-netdev installed?)');

	// Which part is live, IPv6 included: "both directions" without this is
	// how #67 stayed invisible.
	let v6note = (r.ul6 && r.dl6) ? ' [IPv6: both directions]' : r.ul6 ? ' [IPv6: upload only]'
		: r.dl6 ? ' [IPv6: download only]' : ' [IPv4 only]';
	if (r.dl_failed && r.ul_failed) {
		let why = 'no usable WAN or LAN ingress device';
		if (r.dl_err != '' || r.ul_err != '')
			why = ((r.dl_err != '') ? r.dl_err : 'no usable WAN device') + '; ' +
				((r.ul_err != '') ? r.ul_err : 'no LAN ingress device');
		return fail('failed to set rate limit for ' + ip + ' (' + why + ')');
	}

	// The mode and the upload rate are saved with the rate, the upload rate
	// only when it differs, so a symmetric limit keeps its old record.
	let persist = lib.persist_enabled();
	let saved = both(unsaved, persist ? lib.persist_save('ratelimit', ip, '' + rk, mode, (uk != rk) ? '' + uk : '') : null);
	// What was applied is recorded here, once: the activity log, and the
	// place any other announcement of the change belongs.
	lib.log('ratelimit_set', ip, rates, via, src);
	// Not from restore(), which calls add() directly; the ifup hook also sets
	// TCTL_NOTIFY=0 for everything it runs.
	notify.emit_action('limit_applied', { ip, rate_kbit: rk, rate_kbit_up: uk, mode: 'limiter' });
	// A flow the NSS firmware already accelerates is not checked against a
	// rule that came after it.
	lib.nss_defunct();
	let note = lib.nss_note() + lib.persist_note() +
		lib.persist_warn(saved, 'this limit will not be restored as set on the next ifup lan');

	// Live on some devices and not on others: ok, and said, with the
	// devices and nft's reason.
	let partial = (r.dl_err != '' || r.ul_err != '');
	let o = { ok: true, partial, ipv6_upload: r.ul6, ipv6_download: r.dl6, nss: lib.nss_status(), persist };
	if (r.dl_failed)
		o.msg = sprintf('rate limit %d kbit/s applied to %s UPLOAD ONLY — %s%s%s%s', uk, ip,
			(r.dl_err != '') ? r.dl_err : 'WAN device not resolvable', (r.ul_err != '') ? '; ' + r.ul_err : '', v6note, note);
	else if (r.ul_failed)
		o.msg = sprintf('rate limit %d kbit/s applied to %s DOWNLOAD ONLY — %s%s%s%s', rk, ip,
			(r.ul_err != '') ? r.ul_err : 'no LAN ingress device', (r.dl_err != '') ? '; ' + r.dl_err : '', v6note, note);
	else
		o.msg = sprintf('rate limit %s for %s (both directions, %s)%s%s%s', rates, ip, mode,
			partial ? ' — PARTIAL: ' + joined(r.dl_err, r.ul_err) : '', v6note, note);
	return reply(o);
}

// A record field as the shell's jsonfilter printed it: absent or null is
// empty, an int its digits, anything else (true, an object) text that is no
// rate, so it is refused and logged rather than skipped as "no rate".
function rec_str(v) {
	if (v == null)
		return '';
	if (type(v) == 'string' || type(v) == 'int')
		return '' + v;
	return lib.to_json(v);
}

// The limits of rules.json, while persist_rules is on, on ifup lan. A limit
// still in the table (lan going up again without a reboot) is replaced, not
// stacked: a second copy's meter clashed with the first on nftables 1.0.
// Each comment is matched whole, closing quote included. Nothing is logged
// to the activity log or saved: the record is where it came from.
function restore() {
	let res = { restored: 0, failed: 0 };
	if (!lib.persist_enabled())
		return res;
	let d = lib.read_records(RULES);
	if (d == null)
		return res;
	let live = null;
	for (let r in d) {
		if (type(r) != 'object' || r.type != 'ratelimit' || type(r.ip) != 'string' || r.ip == '')
			continue;
		let ip = r.ip, param = rec_str(r.param), up = rec_str(r.param_up);
		// A record with no rate restores nothing and is not a failure.
		if (param == '' || param == '0')
			continue;
		// Older releases saved unvalidated rates; one came back as a 1 byte/s
		// block on every boot. The file is only as trustworthy as whoever
		// last wrote /etc, so the target is checked before it is in a rule.
		if (valid_rate(param) == null || (up != '' && valid_rate(up) == null)) {
			lib.logger(sprintf("Not restoring ratelimit for %s: invalid rate '%s'/'%s'", ip, param, up));
			continue;
		}
		// In its normal form: 1.30.x saved a zero-padded mask as typed
		// (10.0.0.0/024), and removing either spelling reaches the rules.
		let t = target(ip);
		if (t == null || ip == 'all' || ip == 'any') {
			lib.logger('Not restoring ratelimit for ' + ip + ': invalid target');
			continue;
		}
		ip = t;
		// A mode other than each is a shared bucket, as it always was here.
		let mode = (type(r.mode) == 'string' && r.mode != '') ? r.mode : default_mode(ip);
		let cmt = comment(ip);
		live ??= lib.run('nft list table netdev tm_ratelimit');
		// Or with the mask zero-padded, as 1.30.x left it live.
		let found = (index(ip, '/') >= 0 && index(live, '"rl_ratelimit_' + lib.slug(split(ip, '/')[0]) + '_0') >= 0);
		for (let x in SUFFIXES)
			if (index(live, '"' + cmt + x + '"') >= 0)
				found = true;
		if (found)
			remove(ip, cmt);
		let a = add(ip, int(param), cmt, mode, (up != '') ? int(up) : null);
		let errs = ((a.dl_err != '') ? ': ' + a.dl_err : '') + ((a.ul_err != '') ? ': ' + a.ul_err : '');
		if (!a.netdev || a.dl_failed || a.ul_failed) {
			res.failed++;
			lib.logger(sprintf('Failed to restore ratelimit for %s (%skbit)%s', ip, param, errs));
		}
		else {
			res.restored++;
			// Live on the devices that took it; the next ifup or a re-apply
			// retries the rest.
			if (errs != '')
				lib.logger(sprintf('Restored ratelimit for %s (%skbit) PARTIALLY%s', ip, param, errs));
		}
	}
	return res;
}

// 2022-12 needs a ';' after `export function f() {}`; one list avoids it.
export { valid_rate, rate_bytes, default_mode, comment, wan_device, ingress_devices,
	add, remove, remove_legacy, ratelimit, restore };
