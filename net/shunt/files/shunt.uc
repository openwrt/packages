#!/usr/bin/ucode
// shunt - policy based routing daemon
//
// Reads the config, renders the ruleset and the routes, applies them, then
// keeps the learned sets fed from a poll cycle and a passive DNS observer.
// All decisions live in the modules; this file is wiring.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { popen, writefile, readfile, unlink, mkdir, lstat, error as fs_error } from 'fs';
import { openlog, syslog, LOG_PID, LOG_DAEMON, LOG_ERR, LOG_WARNING,
	LOG_NOTICE, LOG_INFO, LOG_DEBUG } from 'log';
import { load as cfg_load, parse as cfg_parse } from 'shunt.config';
import { compile as match_compile } from 'shunt.match';
import { compile as nft_compile, refresh, teardown } from 'shunt.nft';
import { compile as route_compile } from 'shunt.route';
import { open as snoop_open, observe, RECV_LEN } from 'shunt.snoop';
import { names as poll_names, plan as poll_plan,
	addresses as poll_addresses,
	index_results as poll_index } from 'shunt.poll';
import { resolve as netifd_resolve } from 'shunt.netifd';
import { create as dedupe_create } from 'shunt.dedupe';

const RT_TABLES = '/etc/iproute2/rt_tables.d/shunt.conf';
const TAG = 'shunt';

let verbose = false;

let dbg = false;

// syslog(3) through the binding, not a `logger` process per line. '%s' as the
// format because syslog() runs sprintf over its arguments, and an ip error
// text can contain a percent sign.
const PRIO = { err: LOG_ERR, warn: LOG_WARNING, notice: LOG_NOTICE,
	info: LOG_INFO, debug: LOG_DEBUG };

openlog(TAG, LOG_PID, LOG_DAEMON);

function log(prio, msg) {
	syslog(PRIO[prio] ?? LOG_NOTICE, '%s', msg);

	if (verbose)
		warn(sprintf('[%s] %s\n', prio, msg));
}

function debug(msg) {
	if (dbg)
		log('debug', msg);
}

let ubus_conn = null;

function ubus() {
	if (ubus_conn != null)
		return ubus_conn;

	try {
		ubus_conn = require('ubus').connect();
	}
	catch (e) {
		ubus_conn = false;
	}

	if (!ubus_conn)
		log('warn', 'ubus unavailable - gateway discovery and interface events disabled');

	return ubus_conn;
}

function netifd_dump() {
	let c = ubus();
	return c ? c.call('network.interface', 'dump') : null;
}

function load_config() {
	let sections = cfg_load();

	if (sections == null) {
		log('err', 'ucode-mod-uci missing');
		return null;
	}

	return cfg_parse(sections);
}

function report(kind, issues) {
	for (let i in issues)
		log('warn', sprintf('%s: %J', kind, i));
}

const RUN_DIR = '/tmp/.shunt';
const RUN_ERR = RUN_DIR + '/cmd.err';

function capture_ok() {
	mkdir(RUN_DIR, 0o700);

	let st = lstat(RUN_DIR);

	return st != null && st.type == 'directory' && st.uid == 0 &&
		!st.perm.group_write && !st.perm.other_write &&
		!st.perm.group_read && !st.perm.other_read;
}

function loud(argv) {
	if (!capture_ok())
		return { rc: quiet(argv), err: '' };

	let rc = system([ '/bin/sh', '-c',
		sprintf('exec "$0" "$@" 2>%s', RUN_ERR), ...argv ]);
	let err = '';

	if (rc != 0)
		err = replace(trim(readfile(RUN_ERR) ?? ''), /\s*\n\s*/g, '; ');

	unlink(RUN_ERR);

	return { rc, err };
}

// quiet() drops the child's stderr, loud() keeps it for the warning. Neither
// may be called `run` - that name is the daemon's own entry point.
function quiet(argv) {
	return system([ '/bin/sh', '-c', 'exec "$0" "$@" 2>/dev/null', ...argv ]);
}

function nft_pipe(batch, what) {
	let fh = popen('nft -f -', 'w');

	if (!fh) {
		log('err', sprintf('%s: cannot spawn nft: %s', what, fs_error()));
		return false;
	}

	fh.write(batch);

	let rc = fh.close();
	if (rc != 0) {
		log('err', sprintf('%s: nft exited %d', what, rc));
		return false;
	}

	return true;
}

function apply(state) {
	if (!nft_pipe(state.nft.setup, 'setup'))
		return false;

	if (length(state.route.rt_tables)) {
		mkdir('/etc/iproute2/rt_tables.d', 0o755);
		if (!writefile(RT_TABLES, state.route.rt_tables))
			log('warn', sprintf('cannot write %s: %s', RT_TABLES, fs_error()));
	}

	for (let argv in state.route.del)
		quiet(argv);

	let failed = 0;
	let reasons = {};

	for (let argv in state.route.add) {
		let r = loud(argv);

		if (r.rc != 0) {
			let why = length(r.err) ? r.err : sprintf('exit %d', r.rc);

			failed++;
			reasons[why] = (reasons[why] ?? 0) + 1;
			debug(sprintf('not applied: %s - %s', join(' ', argv), why));
		}
	}

	for (let why in reasons)
		log('warn', sprintf('%d of %d route/rule command(s) not applied - %s',
			reasons[why], length(state.route.add), why));

	if (failed)
		log('warn', 'policy not applied yet - traffic falls through to main; restart once the interface is up');

	return true;
}

function flush(state) {
	if (state)
		for (let argv in state.route.del)
			quiet(argv);

	nft_pipe(teardown(), 'teardown');

	if (readfile(RT_TABLES) != null)
		unlink(RT_TABLES);
}

function rp_read(k) {
	return trim(readfile(`/proc/sys/net/ipv4/conf/${k}/rp_filter`) ?? '');
}

// Distinct, existing policy devices. Deduped so a device shared by several
// policies is set or reported once.
function policy_devices(policies) {
	let seen = {}, out = [];

	for (let p in (policies ?? [])) {
		let dev = p.interface;

		if (length(dev ?? '') && !seen[dev]) {
			seen[dev] = true;
			push(out, dev);
		}
	}

	return out;
}

// Which policy devices the kernel would drop marked traffic on. rp_filter
// takes max(conf.all, conf.<dev>), so a device is blocked only when all is
// strict (1 - 0 is off, 2 is loose) AND the device is not loosened itself. A
// device with no /proc entry does not exist yet and inherits default.
function rp_filter_blocked(policies) {
	if (rp_read('all') != '1')
		return [];

	let blocked = [];

	for (let dev in policy_devices(policies)) {
		let v = rp_read(dev);

		if (v == '')
			continue;

		if (v != '2')
			push(blocked, dev);
	}

	return blocked;
}

// With rp_filter_manage set, shunt loosens rp_filter on its own policy devices
// - the per-interface fix the README documents, done automatically. Bounded to
// exactly the devices shunt routes into, never all/default, and only on a
// device that exists. Off by default: changing a security setting is opt-in.
function rp_filter_apply(policies) {
	for (let dev in policy_devices(policies))
		if (rp_read(dev) != '' && rp_read(dev) != '2')
			loud([ 'sysctl', '-w', sprintf('net.ipv4.conf.%s.rp_filter=2', dev) ]);
}

// Reads the live /proc value, so when rp_filter_apply has done its job the
// list is empty on its own - no need to consult the switch a second time.
function check_rp_filter(policies) {
	for (let dev in rp_filter_blocked(policies))
		log('warn', sprintf('rp_filter is strict on %s - shunt\'s marked traffic will be dropped there; set net.ipv4.conf.%s.rp_filter=2 or enable rp_filter_manage, see the README',
			dev, dev));
}

// silent: build only what a teardown consumes and say nothing about the
// configuration - flush() needs route.del and nothing else.
function build_state(silent) {
	let cfg = load_config();
	if (!cfg)
		return null;

	if (!silent)
		report('config', cfg.issues);

	cfg.policies = netifd_resolve(cfg.policies, netifd_dump());

	let matcher = null;

	if (!silent) {
		matcher = match_compile(cfg.policies);
		report('domain', matcher.issues);
	}

	let n = nft_compile(cfg.policies);
	if (!silent)
		report('nft', n.issues);

	let r = route_compile(cfg.policies, n.marks);
	if (!silent)
		report('route', r.issues);

	return { cfg, matcher, nft: n, route: r };
}

// nft -f reads the entire ruleset before resolving a single name, so on a box
// with large sets from another tool one add element costs seconds of CPU.
// Writes are collected and applied by a timer whose interval follows the
// measured cost: an ordinary box stays at the floor, an expensive one backs
// off.
const WRITE_MIN = 2;
const WRITE_MAX = 60;
const WRITE_FACTOR = 3;

function queue_writes(st, writes, now) {
	for (let w in writes)
		if (st.state.nft.learn[w.set] && st.cache.due(w.set, w.addr, now))
			st.pending[`${w.set}/${w.addr}`] = w;
}

function drain_writes(st) {
	let due = values(st.pending);

	st.pending = {};

	if (!length(due))
		return;

	let r = refresh(due, st.state.cfg.global.entry_ttl);
	report('refresh', r.issues);

	if (!length(r.batch))
		return;

	let t0 = time();
	let ok = nft_pipe(r.batch, 'refresh');
	let cost = time() - t0;

	if (ok)
		debug(sprintf('%d element(s) written in %ds', length(due), cost));

	let want = cost * WRITE_FACTOR;

	if (want < WRITE_MIN)
		want = WRITE_MIN;
	if (want > WRITE_MAX)
		want = WRITE_MAX;

	if (want != st.interval) {
		debug(sprintf('write interval %ds -> %ds (last write %ds)',
			st.interval, want, cost));
		st.interval = want;
		st.timer.set(want * 1000);
	}
}

function run() {
	let uloop, resolv;

	try {
		uloop = require('uloop');
	}
	catch (e) {
		log('err', 'ucode-mod-uloop missing');
		return 1;
	}

	let state = build_state();
	if (!state)
		return 2;

	dbg = verbose || state.cfg.global.debug;

	if (!state.cfg.global.enabled) {
		log('notice', 'disabled in config - running idle; enable and reload to start');
		state.cfg.policies = [];
		state.matcher = match_compile([]);
		state.nft = nft_compile([]);
		state.route = route_compile([], state.nft.marks);
	}

	if (!length(state.nft.marks))
		log('warn', 'no usable policy - running idle; configure a policy and reload, `shunt check` shows the reasons');

	if (state.cfg.global.rp_filter_manage)
		rp_filter_apply(state.cfg.policies);

	check_rp_filter(state.cfg.policies);

	if (!apply(state)) {
		flush(state);
		return 1;
	}

	let cache = dedupe_create(state.cfg.global.entry_ttl);
	let targets = poll_names(state.cfg.policies);

	let stats = { started: time(), resolv: false, snoop: [],
		matched: 0, drops: {} };

	try {
		resolv = require('resolv');
	}
	catch (e) {
		resolv = null;
		if (length(targets))
			log('warn', 'ucode-mod-resolv missing - poll disabled, snoop only');
	}

	stats.resolv = (resolv != null);

	let unresolved = {};

	let wq = { state, cache, pending: {}, interval: WRITE_MIN, timer: null };

	function poll_cycle() {
		if (!resolv || !length(targets))
			return;

		let res = resolv.query(targets, { type: [ 'A', 'AAAA' ],
			timeout: 2000, retries: 1 });
		if (!res) {
			log('warn', 'poll: query failed');
			return;
		}

		let by = poll_index(res);

		for (let name in targets) {
			let got = poll_addresses(by, name);
			let n = length(got.a) + length(got.aaaa);

			if (n && unresolved[name]) {
				unresolved[name] = false;
				log('info', sprintf('poll: %s resolves again', name));
			}
			else if (!n && !unresolved[name]) {
				let owners = state.matcher.test(name);

				unresolved[name] = true;
				log('warn', sprintf('poll: %s%s has no address - the policy entry has no effect until it resolves',
					name, owners != null
						? sprintf(' (policy %s)', join(', ', owners)) : ''));
			}
		}

		queue_writes(wq, poll_plan(res, state.matcher, targets), time());
	}

	// The cache is pruned here and not at the tail of poll_cycle():
	// poll_cycle() returns early without resolv, without pollable names
	// and on a failed query, while snoop keeps feeding queue_writes() in
	// all three cases.
	function tick() {
		for (let argv in state.route.add)
			quiet(argv);

		poll_cycle();
		cache.prune(time());
	}

	wq.timer = uloop.interval(WRITE_MIN * 1000, () => drain_writes(wq));

	poll_cycle();
	uloop.interval(state.cfg.global.poll_interval * 1000, tick);

	if (resolv && length(targets))
		log('info', sprintf('poll: %d name(s) every %ds', length(targets),
			state.cfg.global.poll_interval));

	let c = ubus();

	if (c) {
		let pending = null;

		function rebuild_routes() {
			pending = null;

			let resolved = netifd_resolve(state.cfg.policies, netifd_dump());
			let r = route_compile(resolved, state.nft.marks);

			report('route', r.issues);

			// A policy device may have just appeared - the boot-time case a
			// static sysctl.d file misses, since /proc/<dev> did not exist
			// yet. Re-apply so it is loose from the moment it comes up, then
			// re-check: with manage on the check reads the value just set
			// and stays silent, without it this is the moment to warn.
			if (state.cfg.global.rp_filter_manage)
				rp_filter_apply(resolved);

			check_rp_filter(resolved);

			for (let argv in state.route.del)
				quiet(argv);
			for (let argv in r.add)
				quiet(argv);

			state.route = r;
		}

		c.listener('network.interface', (type, msg) => {
			if (msg?.action != 'ifup' && msg?.action != 'ifdown')
				return;

			log('info', sprintf('%s %s - rebuilding routes',
				msg.action, msg.interface ?? '?'));

			if (pending)
				pending.set(500);
			else
				pending = uloop.timer(500, rebuild_routes);
		});

		// Must be total: an exception in a ubus handler halts uloop and takes
		// snoop, poll and the keeper down with the reply.
		function status_reply() {
			let names = [];

			for (let m in state.nft.marks)
				push(names, m.name);

			return {
				started: stats.started,
				policies: names,
				poll: {
					resolv: stats.resolv,
					names: length(targets),
					interval: state.cfg.global.poll_interval
				},
				snoop: {
					devices: stats.snoop,
					matched: stats.matched,
					drops: stats.drops
				},
				dedupe: cache.size()
			};
		}

		let obj = c.publish('shunt', { status: { call: () => status_reply() } });

		if (!obj)
			log('warn', sprintf('cannot publish ubus object: %s',
				require('ubus').error() ?? 'unknown'));
	}

	let socks = [];

	if (state.cfg.global.snoop && length(state.nft.marks)) {
		let socket = null;

		for (let dev in state.cfg.global.snoop_devices) {
			let s = snoop_open(dev);

			if (!s.ok) {
				log('err', sprintf('snoop %s: %s', dev, s.err));
				continue;
			}

			if (socket == null)
				socket = require('socket');

			let sock = s.sock;

			push(socks, sock);
			push(stats.snoop, dev);

			// Each handler closes over its own socket; binding the loop
			// variable would leave them all reading the last one opened.
			uloop.handle(sock, () => {
				let frame;

				while ((frame = sock.recv(RECV_LEN, socket.MSG_DONTWAIT)) != null) {
					let v = observe(frame, state.matcher);

					if (v.drop != null) {
						stats.drops[v.drop] = (stats.drops[v.drop] ?? 0) + 1;
						continue;
					}

					stats.matched++;

					let writes = [];
					for (let policy in v.policies) {
						for (let a in v.a)
							push(writes, { set: `d4_${policy}`, addr: a });
						for (let a in v.aaaa)
							push(writes, { set: `d6_${policy}`, addr: a });
					}

					debug(sprintf('snoop: %s -> %s (%d addr)',
						v.qname, join(', ', v.policies), length(writes)));
					queue_writes(wq, writes, time());
				}
			}, uloop.ULOOP_READ);
		}

		if (length(socks))
			log('info', sprintf('snoop: listening on %s',
				join(', ', stats.snoop)));
		else if (!resolv || !length(targets)) {
			log('err', 'neither snoop nor poll available - nothing to do');
			flush(state);
			return 1;
		}
	}

	log('notice', sprintf('started: %d polic%s, mask 0x%08x',
		length(state.nft.marks), length(state.nft.marks) == 1 ? 'y' : 'ies',
		0xff000000));

	uloop.run();

	log('notice', 'stopping');
	for (let sock in socks)
		sock.close();
	flush(state);

	return 0;
}

function check() {
	verbose = true;

	let state = build_state();
	if (!state)
		return 2;

	printf('global:   %.2J\n', state.cfg.global);
	printf('policies: %d accepted, %d mark(s)\n',
		length(state.cfg.policies), length(state.nft.marks));

	for (let m in state.nft.marks)
		printf('  %-16s mark 0x%08x  table %d  pref %d\n',
			m.name, m.mark, m.rt_table, m.rt_prio);

	let total = length(state.matcher.issues) + length(state.nft.issues) +
		length(state.route.issues);

	printf('issues:   %d (see above)\n', total);
	printf('poll:     %d name(s)\n', length(poll_names(state.cfg.policies)));

	return length(state.nft.marks) ? 0 : 2;
}

let cmd = null;

for (let a in ARGV) {
	if (a == '-v')
		verbose = dbg = true;
	else if (cmd == null)
		cmd = a;
}

switch (cmd) {
case 'run':
	exit(run());
case 'check':
	exit(check());
case 'flush':
	flush(build_state(true));
	exit(0);
default:
	warn('usage: shunt [-v] run|check|flush\n');
	exit(2);
}
