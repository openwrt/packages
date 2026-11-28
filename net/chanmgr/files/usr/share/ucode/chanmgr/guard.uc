// SPDX-License-Identifier: GPL-2.0-only
// Guarded channel switch, run on the device that owns the radio.
//
// When a radio carries the mesh link that connects this device to the rest of
// the network, the controller loses contact as soon as the channel changes and
// can neither confirm nor undo the switch. The device therefore decides on its
// own: it switches, checks that the radio came up and that its mesh peers came
// back, waits for the controller's confirmation and otherwise returns to the
// previous channel. A marker in /etc restores the previous channel after a
// power loss in the middle of a switch.

'use strict';

let fs = require('fs');
let agent = require('chanmgr.agent');
let chan = require('chanmgr.chan');

const RUN_DIR = getenv('CHANMGR_RUN_DIR') ?? '/tmp/chanmgr';
const PENDING_DIR = getenv('CHANMGR_PENDING_DIR') ?? '/etc';
const TICK = +(getenv('CHANMGR_GUARD_TICK') ?? 2000);

const FINAL = { done: true, rolled_back: true, failed: true };

function path(radio, ext) {
	return sprintf('%s/guard-%s%s', RUN_DIR, radio, ext);
}

function pending_path(radio) {
	return sprintf('%s/chanmgr.pending.%s', PENDING_DIR, radio);
}

function read_json(file) {
	try {
		return json(fs.readfile(file) ?? 'null');
	}
	catch (e) {
		return null;
	}
}

function status(radio) {
	let s = read_json(path(radio, '.json'));

	// a guard that died (killed, reboot) without reaching a final state
	if (s && !FINAL[s.state] && s.pid && !fs.stat('/proc/' + s.pid))
		s = { ...s, state: 'failed', msg: 'guard process died' };

	return s ?? { radio, state: 'none' };
}

function set_state(radio, st, state, msg) {
	st.state = state;
	st.ts = time();

	if (msg != null)
		st.msg = msg;

	fs.writefile(path(radio, '.json.tmp'), sprintf('%J', st));
	fs.rename(path(radio, '.json.tmp'), path(radio, '.json'));

	if (FINAL[state] && st.to != null)
		agent.note(radio, {
			from: st.from, from_width: st.from_width, to: st.to, width: st.width,
			ok: state == 'done', how: 'guarded', msg: st.msg
		});
	system([ 'logger', '-t', 'chanmgr', '-p', 'daemon.notice', sprintf('%s: guard %s%s', radio, state, msg ? ': ' + msg : '') ]);
}

// Poll cond() every tick until it is true, the timeout passes, or the
// controller aborts. Returns 'ok', 'timeout' or 'abort'.
function wait_for(radio, cond, timeout) {
	let until = time() + timeout;

	while (true) {
		if (fs.stat(path(radio, '.abort')))
			return 'abort';

		if (cond())
			return 'ok';

		if (time() >= until)
			return 'timeout';

		sleep(TICK);
	}
}

// numeric option with a default; 0 is a valid value
function opt(args, key, def) {
	let v = args?.[key];

	return (v == null || v === '') ? def : +v;
}

function apply_channel(radio, channel, width) {
	agent.persist(radio, channel, width);
	system('wifi reload >/dev/null 2>&1');
}

// args: { radio, channel, width, delay, up_timeout, mesh_timeout, confirm_timeout, watch, mesh_lost }
// confirm_timeout 0: no controller, confirm by itself once healthy (manual use)
function run(args) {
	let radio = args.radio;
	let r = agent.info().radios[radio];
	let st = { radio, pid: +fs.readlink('/proc/self'), started: time() };

	fs.mkdir(RUN_DIR, 0700);
	fs.unlink(path(radio, '.confirm'));
	fs.unlink(path(radio, '.abort'));

	if (!r) {
		set_state(radio, st, 'failed', 'radio is not active');
		return st;
	}

	let to = chan.spec(r.band, +args.channel, +(args.width || r.width));
	let up_timeout = opt(args, 'up_timeout', 60), mesh_timeout = opt(args, 'mesh_timeout', 90);
	let confirm_timeout = opt(args, 'confirm_timeout', 240), watch = opt(args, 'watch', 300), mesh_lost = opt(args, 'mesh_lost', 60);
	let mesh_ifs = map(filter(r.ifaces, (i) => i.mode == 'mesh'), (i) => i.ifname);

	st.from = r.channel;
	st.from_width = r.width;
	st.to = to.channel;
	st.width = to.width;
	st.peers_before = agent.mesh_peers(mesh_ifs);

	let on = (freq, width) => () => agent.running_on(r.ifname, freq, width);
	let peers = () => agent.mesh_peers(mesh_ifs) > 0;

	let rollback = (why) => {
		set_state(radio, st, 'rolling_back', why);
		fs.unlink(path(radio, '.abort'));
		apply_channel(radio, st.from, st.from_width);

		let back = wait_for(radio, on(r.freq, st.from_width), up_timeout) == 'ok';

		fs.unlink(pending_path(radio));
		set_state(radio, st, back ? 'rolled_back' : 'failed',
			why + (back ? '; back on channel ' + st.from : '; COULD NOT RETURN to channel ' + st.from));

		return st;
	};

	// reboot safety: the init script restores this channel if we never finish
	fs.writefile(pending_path(radio), sprintf('%J', { radio, channel: st.from, width: st.from_width }));
	set_state(radio, st, 'switching');

	// let the reply to the controller leave before the link goes away
	sleep(opt(args, 'delay', 5) * 1000);
	apply_channel(radio, to.channel, to.width);

	let t0 = time();
	let w = wait_for(radio, on(to.freq, to.width), up_timeout);

	if (w != 'ok')
		return rollback((w == 'abort') ? 'aborted by the controller' : 'radio did not come up on channel ' + to.channel);

	let steps = [ sprintf('radio up after %d s', time() - t0) ];

	if (st.peers_before > 0) {
		set_state(radio, st, 'waiting_mesh');
		w = wait_for(radio, peers, mesh_timeout);

		if (w != 'ok')
			return rollback((w == 'abort') ? 'aborted by the controller' : 'mesh peers did not come back');

		push(steps, sprintf('mesh back after %d s', time() - t0));
	}

	if (confirm_timeout > 0) {
		set_state(radio, st, 'waiting_confirm');
		w = wait_for(radio, () => fs.stat(path(radio, '.confirm')), confirm_timeout);

		if (w != 'ok')
			return rollback((w == 'abort') ? 'aborted by the controller' : 'no confirmation from the controller');
	}

	push(steps, (confirm_timeout > 0) ? 'confirmed by the router' : 'confirmed locally');
	fs.unlink(pending_path(radio));
	set_state(radio, st, 'confirmed', join(', ', steps));

	// keep watching the mesh for a while: if this device ended up alone on
	// the new channel (its peer went back), follow the peer back
	if (st.peers_before > 0) {
		let lost = null, until = time() + watch;

		while (time() < until) {
			if (peers())
				lost = null;
			else if (lost == null)
				lost = time();
			else if (time() - lost >= mesh_lost) {
				fs.writefile(pending_path(radio), sprintf('%J', { radio, channel: st.from, width: st.from_width }));

				return rollback('mesh lost after the switch');
			}

			sleep(TICK);
		}
	}

	set_state(radio, st, 'done');

	return st;
}

// Start a guard in the background. Refuses while one runs for this radio.
function start(args) {
	if (!match(args.radio ?? '', /^[A-Za-z0-9_]+$/))
		return { ok: false, error: 'invalid radio name' };

	let s = status(args.radio);

	if (s.state != 'none' && !FINAL[s.state])
		return { ok: false, error: 'a switch is already running on ' + args.radio };

	if (!agent.info().radios[args.radio])
		return { ok: false, error: 'radio is not active: ' + args.radio };

	fs.mkdir(RUN_DIR, 0700);
	fs.writefile(path(args.radio, '.json'), sprintf('%J', { radio: args.radio, state: 'starting', ts: time() }));

	let opts = join(' ', map(filter([ 'channel', 'width', 'delay', 'up_timeout', 'mesh_timeout', 'confirm_timeout', 'watch', 'mesh_lost' ],
		(k) => args[k] != null && args[k] !== ''), (k) => sprintf('%s=%d', k, +args[k])));

	system(sprintf('%s agent guard %s %s >/dev/null 2>&1 </dev/null &', getenv('CHANMGR_BIN') ?? '/usr/sbin/chanmgr', args.radio, opts));

	return { ok: true };
}

function confirm(radio) {
	fs.writefile(path(radio, '.confirm'), '' + time());

	return status(radio);
}

function abort(radio) {
	fs.writefile(path(radio, '.abort'), '' + time());

	return status(radio);
}

// Boot: restore channels of switches that never finished (power loss).
function recover() {
	let res = [];

	for (let f in fs.glob(PENDING_DIR + '/chanmgr.pending.*') ?? []) {
		let p = read_json(f);

		if (p?.radio && p.channel) {
			agent.persist(p.radio, p.channel, p.width);
			push(res, p);
			system([ 'logger', '-t', 'chanmgr', '-p', 'daemon.warn', sprintf('%s: restoring channel %d after an unfinished switch', p.radio, p.channel) ]);
		}

		fs.unlink(f);
	}

	if (length(res))
		system('wifi reload >/dev/null 2>&1');

	return res;
}

// tests run the guard against the real agent module
function use_agent(a) {
	agent = a;
}

return { run, start, status, confirm, abort, recover, FINAL, use_agent };
