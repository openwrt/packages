// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.cut: the global internet cut (#55), `trafficctl cut ...`.
//
//   main(args)   engage <seconds|0> [persist] | release | status | restore |
//                tick | keeper: { reply, rc }, reply null when the command
//                prints nothing
//
// This is the one control that can lock its operator out of the router, so
// everything here leans towards failing open:
//   * the ruleset is one `nft -f -` transaction, router-local traffic accepted
//     first in its prerouting chain, and what loaded is read back: a chain
//     without that accept in first place is taken down again;
//   * no LAN device means no cut (its drop would take the LAN too);
//   * the engaged state lives in tmpfs, and in /etc only on its own opt-in;
//   * the keeper (/etc/init.d/trafficctl-cut, procd) and `status` both
//     enforce the deadline, and the keeper outlives an exception.
// The ruleset text, the state files and the replies are those of
// trafficctl-cut.sh v1.30.0, so either side can release what the other
// engaged.

import { dirname } from 'fs';
import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import * as notify from 'trafficctl.notify';

const COMMENT = 'tctl_cut';
const RUN_DIR = '/var/run/trafficctl';
const STATE = '/var/run/trafficctl/cut.state';
const PSTATE = '/etc/trafficctl/cut.state';
const INIT = '/etc/init.d/trafficctl-cut';
const LOCK = '/var/run/trafficctl/cut.lock';
const TICK_MS = 5000;
const MIN_SECS = 60;
const MAX_SECS = 604800;

const USAGE = 'usage: trafficctl cut engage <seconds|0> [persist] | release | status | restore';
const NO_NFT = 'global cut needs nftables (fw4); nft cannot list inet tables here';
const NO_LAN = 'no LAN interfaces found — refusing, a cut with no LAN to spare would black-hole the LAN too';
const NO_RULE = 'failed to install the cut rule';
const BAD_DEV = 'a LAN interface name has characters an nft ruleset cannot quote safely — refusing';
const NO_STATE = 'failed to record the cut state — the rule was taken down again';
const TPROXY = 'this router intercepts traffic with a transparent proxy (TPROXY — podkop/sing-box, ' +
	'passwall or similar), and the prerouting chain could not be installed on this kernel (no nft_fib?). ' +
	'A forward-only cut would miss proxied traffic while reporting success, so it is refused rather than faked.';
const NO_CT = ' (conntrack unavailable — connections opened before now may linger)';

// The tests' clock; a router always reads its own.
function now() {
	let t = (lib.ROOT != '') ? getenv('TCTL_NOW') : null;
	return (t != null && match(t, /^[0-9]+$/)) ? int(t) : time();
}

function fail(msg) {
	return { reply: { ok: false, msg }, rc: 1 };
}

function logger(msg) {
	lib.sh('logger -t trafficctl ' + lib.q(msg));
}

// ── the rule ────────────────────────────────────────────────────────────────

function supported() {
	return lib.sh('nft list tables inet') == 0;
}

// The text listing, as the shell reads it: '' when the table is not there.
function listing() {
	return lib.run('nft list table inet tctl_cut');
}

function present(d) {
	return index(d ?? listing(), '"' + COMMENT + '"') >= 0;
}

function coverage(d) {
	d ??= listing();
	if (!present(d))
		return 'none';
	return (index(d, 'hook prerouting') >= 0) ? 'full' : 'forward';
}

// Interface names go into the ruleset text between quotes, so a name that
// could close the quote or start a new statement is not used at all. Linux
// allows nearly any byte in a name; OpenWrt's are well inside this set.
function safe_devs(devs) {
	for (let d in devs)
		if (type(d) != 'string' || !match(d, /^[A-Za-z0-9._@-]+$/))
			return false;
	return true;
}

function lan_set(devs) {
	return '{ ' + join(', ', map(devs, (d) => '"' + d + '"')) + ' }';
}

// Byte for byte the shell's heredoc. The `add` before the `delete` makes the
// delete valid when the table is not there yet, so the whole script is one
// transaction either way. Router-addressed traffic is accepted before
// anything that trusts the LAN device list.
function ruleset(devs, mode) {
	let set = lan_set(devs), pre = '';
	if (mode == 'full')
		pre = '\tchain cut_prerouting {\n' +
			'\t\ttype filter hook prerouting priority -300; policy accept;\n' +
			'\t\tfib daddr type { local, broadcast, multicast } accept\n' +
			'\t\tip6 daddr fe80::/10 accept\n' +
			'\t\tiifname != ' + set + ' accept\n' +
			'\t\tfib daddr . iif oifname ' + set + ' accept\n' +
			'\t\tcounter drop comment "' + COMMENT + '"\n' +
			'\t}';
	return 'add table inet tctl_cut\n' +
		'delete table inet tctl_cut\n' +
		'table inet tctl_cut {\n' +
		pre + '\n' +
		'\tchain cut_forward {\n' +
		'\t\ttype filter hook forward priority -190; policy accept;\n' +
		'\t\toifname != ' + set + ' counter drop comment "' + COMMENT + '"\n' +
		'\t}\n' +
		'}\n';
}

// pipe() keeps no exit status; the echo carries it out.
function load(text) {
	return lib.pipe('nft -f - >/dev/null 2>&1 && echo ok', text) == 'ok\n';
}

// The first rule of the prerouting chain as nft lists it back.
function first_pre_rule(d) {
	let l = split(d, '\n'), n = length(l), i = 0;
	while (i < n && index(l[i], 'hook prerouting') < 0)
		i++;
	i++;
	while (i < n && trim(l[i]) == '')
		i++;
	return (i < n) ? trim(l[i]) : '';
}

// A zero exit status is not evidence: what a kernel accepted is read back.
// The shell checked that the local accept was somewhere in the table; here
// it has to be the prerouting chain's first rule, because anywhere after the
// drop it is no escape hatch at all.
function verify(mode) {
	let d = listing();
	if (!present(d))
		return false;
	if (mode != 'full')
		return true;
	let r = first_pre_rule(d);
	return index(d, 'hook prerouting') >= 0 && index(d, 'fib daddr type') >= 0 &&
		substr(r, 0, 16) == 'fib daddr type {' && index(r, 'local') >= 0 &&
		substr(r, -7) == ' accept';
}

function remove_rule() {
	lib.sh('nft delete table inet tctl_cut');
}

function install(devs) {
	if (!safe_devs(devs))
		return false;
	if (load(ruleset(devs, 'full')) && verify('full'))
		return true;
	remove_rule();
	if (load(ruleset(devs, 'forward')) && verify('forward'))
		return true;
	remove_rule();
	return false;
}

function proxy_intercept() {
	return index(lib.run('nft list ruleset'), 'tproxy') >= 0;
}

// -C is the probe: -D also fails when there was nothing to delete.
function flush_conntrack() {
	if (lib.sh('command -v conntrack') != 0 || lib.sh('conntrack -C') != 0)
		return false;
	for (let s in net.subnets()) {
		lib.sh('conntrack -D -s ' + lib.q(s.cidr));
		lib.sh('conntrack -D -d ' + lib.q(s.cidr));
	}
	return true;
}

// ── state ───────────────────────────────────────────────────────────────────
// key=value lines, values all digits; epochs stay strings until compared, so
// '0' (never) and '00' (long past) mean what they meant to the shell.

function state_write(file, expires, persist, started) {
	lib.mkdir_p(dirname(file));
	return lib.write_atomic(file, sprintf('expires_at=%s\npersist=%s\nstarted_at=%s\n',
		'' + expires, '' + persist, '' + started));
}

function state_get(file, key) {
	for (let l in lib.file_lines(file)) {
		if (substr(l, 0, length(key) + 1) != key + '=')
			continue;
		let v = substr(l, length(key) + 1);
		// Past 15 digits int() is no longer exact; the shell's test(1) failed
		// on such a value too, and read it as "not expired".
		return (match(v, /^[0-9]+$/) && length(v) <= 15) ? v : null;
	}
	return null;
}

function active() {
	return lib.is_file(STATE);
}

function expired(file) {
	let exp = state_get(file ?? STATE, 'expires_at');
	if (exp == null || exp == '0')
		return false;
	return now() >= int(exp);
}

// ── keeper ──────────────────────────────────────────────────────────────────

// Asked of procd, which started it: a process-name match also finds a v1.30
// keeper that a package upgrade orphaned, or anything else named alike.
function keeper_running() {
	let inst = lib.ubus_call('service', 'list', { name: 'trafficctl-cut' })?.['trafficctl-cut']?.instances;
	for (let k in inst ?? {})
		if (inst[k]?.running)
			return true;
	return false;
}

function have_init() {
	return lib.sh('test -x ' + lib.q(lib.path(INIT))) == 0;
}

function keeper_start() {
	if (have_init() && !keeper_running())
		lib.sh(lib.q(lib.path(INIT)) + ' start');
}

function keeper_stop() {
	if (have_init())
		lib.sh(lib.q(lib.path(INIT)) + ' stop');
}

// ── replies ─────────────────────────────────────────────────────────────────

function default_duration() {
	let d = lib.uci_get('trafficctl', 'cut', 'default_duration');
	return (d != null && match(d, /^[0-9]+$/) && length(d) <= 15) ? int(d) : 0;
}

function status_reply(msg) {
	let on = active(), exp = 0, started = 0, persist = false, remaining = 0;
	if (on) {
		exp = int(state_get(STATE, 'expires_at') ?? '0');
		started = int(state_get(STATE, 'started_at') ?? '0');
		persist = state_get(STATE, 'persist') == '1';
		if (exp != 0) {
			remaining = exp - now();
			if (remaining < 0)
				remaining = 0;
		}
	}
	let d = listing();
	return {
		ok: true,
		active: on,
		rule_present: present(d),
		supported: supported(),
		coverage: coverage(d),
		expires_at: exp,
		remaining,
		started_at: started,
		persist,
		keeper_running: keeper_running(),
		lan_devices: join(' ', net.lan_devices()),
		default_duration: default_duration(),
		default_persist: lib.uci_get('trafficctl', 'cut', 'persist') == '1',
		msg: msg ?? '',
	};
}

function log(action, detail) {
	lib.log(action, 'all', detail, getenv('TCTL_VIA'), getenv('TCTL_SRC'));
}

// ── commands ────────────────────────────────────────────────────────────────

function release(quiet) {
	remove_rule();
	lib.remove(STATE);
	lib.remove(PSTATE);
	log('uncut', '');
	keeper_stop();
	return quiet ? null : status_reply('internet restored for all devices');
}

// One step after the cut is in place: an exception is logged, not raised.
function soft(fn) {
	try {
		fn();
	}
	catch (e) {
		warn(sprintf('trafficctl cut: %s\n', e.message));
	}
}

function engage_now(expires, persist, quiet) {
	if (!supported())
		return fail(NO_NFT);
	let devs = net.lan_devices();
	if (!length(devs))
		return fail(NO_LAN);
	if (!safe_devs(devs))
		return fail(BAD_DEV);
	if (!install(devs)) {
		remove_rule();
		return fail(NO_RULE);
	}
	if (coverage() == 'forward' && proxy_intercept()) {
		remove_rule();
		return fail(TPROXY);
	}
	let t = now();
	// From here the rule is live. Without the state nothing would ever
	// release it, so a state that cannot be written takes it down again.
	if (!state_write(STATE, expires, persist, t) || !active()) {
		remove_rule();
		return fail(NO_STATE);
	}
	// The cut is engaged now, and every step after this one is reported as
	// such whatever it does: a failure reply for a live cut is a cut the UI
	// does not show. The keeper goes first, because the deadline depends
	// on it.
	soft(keeper_start);
	soft(() => {
		if (persist == '1')
			state_write(PSTATE, expires, persist, t);
		else
			lib.remove(PSTATE);
	});
	let ct = NO_CT;
	soft(() => { if (flush_conntrack()) ct = ''; });
	soft(() => log('cut', 'expires=' + expires + ' persist=' + persist));
	if (quiet)
		return { reply: null, rc: 0 };
	// A restore after a reboot is quiet and is not a new cut.
	notify.emit_action('cut_engaged', { duration: (int(expires) > 0) ? int(expires) - now() : 0, persist });
	let msg = 'internet cut for all devices' + ct, r;
	try {
		r = status_reply(msg);
	}
	catch (e) {
		warn(sprintf('trafficctl cut: %s\n', e.message));
		r = { ok: true, active: true, rule_present: true, msg };
	}
	return { reply: r, rc: 0 };
}

// A rule in place with no state behind it holds the internet off with
// nothing claiming to: if anything throws once the table may be loaded, it
// goes again before the error is reported.
function engage(expires, persist, quiet) {
	try {
		return engage_now(expires, persist, quiet);
	}
	catch (e) {
		if (!active())
			remove_rule();
		die(e.message);
	}
}

function restore() {
	if (!lib.is_file(PSTATE))
		return { reply: null, rc: 0 };
	if (state_get(PSTATE, 'persist') != '1') {
		lib.remove(PSTATE);
		return { reply: null, rc: 0 };
	}
	let exp = state_get(PSTATE, 'expires_at');
	// A deadline that cannot be read is taken as passed: restored as
	// "never", it would hold the internet off with no end at all.
	if (exp == null || expired(PSTATE)) {
		lib.remove(PSTATE);
		logger('global internet cut expired while down — not restored');
		return { reply: null, rc: 0 };
	}
	return engage(exp, '1', true);
}

function tick() {
	if (!active()) {
		if (present())
			remove_rule();
		return 2;
	}
	if (expired()) {
		release(true);
		logger('global internet cut expired — internet restored');
		return 2;
	}
	if (!present()) {
		let devs = net.lan_devices();
		if (length(devs) && install(devs)) {
			// A release that gave up waiting for the lock may have run in
			// the meantime: a rule with no state behind it goes again.
			if (!active())
				remove_rule();
			else
				logger('global internet cut re-asserted after the rule disappeared');
		}
	}
	return 0;
}

function status() {
	if (active() && expired()) {
		release(true);
		return status_reply('the cut expired and the internet was restored');
	}
	if (active() && !keeper_running())
		keeper_start();
	// A rule nothing claims, e.g. re-installed by a tick that a release
	// waiting past the lock raced: nothing else would ever take it away.
	if (!active() && present())
		remove_rule();
	return status_reply('');
}

// One writer at a time. Without it a tick that found the rule missing could
// re-install it just after a release removed the state: a cut nobody holds.
// Waited for, never required: a stuck lock must not keep a release from
// running.
function locked(fn) {
	lib.mkdir_p(RUN_DIR);
	let held = lib.lock(LOCK, 50, 30), r;
	try {
		r = fn();
	}
	catch (e) {
		if (held)
			lib.unlock(LOCK);
		die(e.message);
	}
	if (held)
		lib.unlock(LOCK);
	return r;
}

function keeper() {
	let n = 0;
	while (true) {
		let rc = 0;
		n++;
		// An exception must not end the loop: the auto-revert depends on it.
		try {
			rc = locked(tick);
		}
		catch (e) {
			warn(sprintf('trafficctl cut keeper: %s\n', e.message));
		}
		if (rc != 0)
			break;
		sleep(TICK_MS);
		net.reset();
		if (n % 12 == 0)
			gc();
	}
	return 0;
}

function valid_duration(s) {
	if (!match(s, /^[0-9]+$/))
		return false;
	if (s == '0')
		return true;
	let n = int(s);
	return n >= MIN_SECS && n <= MAX_SECS;
}

function main(args) {
	switch (args[0]) {
	case 'engage': {
		let secs = (args[1] == null || args[1] == '') ? '0' : '' + args[1];
		let persist = (args[2] == null || args[2] == '') ? '0' : '' + args[2];
		if (!lib.plain(secs) || !valid_duration(secs))
			return fail(sprintf('duration must be 0 (indefinite) or between %d and %d seconds', MIN_SECS, MAX_SECS));
		if (persist != '0' && persist != '1')
			return fail('persist must be 0 or 1');
		// Decimal: the shell's $(( now + 060 )) read a leading zero as octal.
		let expires = (secs == '0') ? 0 : now() + int(secs);
		lib.mkdir_p(RUN_DIR);
		return locked(() => engage(expires, persist, false));
	}
	case 'release':
		return { reply: locked(() => release(false)), rc: 0 };
	case 'status':
		return { reply: locked(status), rc: 0 };
	case 'restore':
		return locked(restore);
	case 'tick':
		return { reply: null, rc: locked(tick) };
	case 'keeper':
		return { reply: null, rc: keeper() };
	default:
		return fail(USAGE);
	}
}

export { main, ruleset, verify, keeper_running };
