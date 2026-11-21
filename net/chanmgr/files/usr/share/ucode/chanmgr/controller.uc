// SPDX-License-Identifier: GPL-2.0-only
// Controller: collects measurements from all nodes, plans channels jointly
// per band and applies the plan one radio at a time.

'use strict';

let fs = require('fs');
let uci = require('uci');
let chan = require('chanmgr.chan');
let score = require('chanmgr.score');
let agent = require('chanmgr.agent');
let remote = require('chanmgr.remote');
let guard = require('chanmgr.guard');

const RUN_DIR = getenv('CHANMGR_RUN_DIR') ?? '/tmp/chanmgr';
const STATE_FILE = RUN_DIR + '/state.json';
// copy kept across reboots, written after evaluations and switches only (a
// few times a day, not on every 5 min sample) to spare the flash
const PERSIST_DIR = getenv('CHANMGR_PERSIST_DIR') ?? '/etc/chanmgr';
const PERSIST_FILE = PERSIST_DIR + '/state.json';
const LOCK_DIR = RUN_DIR + '/lock';
const HISTORY_MAX = 50;
const EVALS_MAX = 50;

function log(prio, fmt, ...args) {
	let msg = sprintf(fmt, ...args);

	system([ 'logger', '-t', 'chanmgr', '-p', 'daemon.' + prio, msg ]);

	if (getenv('CHANMGR_VERBOSE'))
		warn(msg, '\n');
}

function list(v) {
	if (v == null)
		return [];

	return (type(v) == 'array') ? v : split(trim(v), /[ \t,]+/);
}

function config() {
	let c = uci.cursor();
	let m = c.get_all('chanmgr', 'main') ?? {};
	let n = (v, d) => (v != null && v !== '') ? +v : d;

	let cfg = {
		enabled: m.enabled == '1',
		// router: plans and switches all nodes; ap: only answers a controller
		role: (m.role == 'ap') ? 'ap' : 'router',
		mode: (m.mode == 'apply') ? 'apply' : 'recommend',
		eval_times: list(m.eval_times ?? '02:30 04:30'),
		sample_interval: n(m.sample_interval, 300),
		scan_gap: n(m.scan_gap, 120),
		apply_gap: n(m.apply_gap, 30),
		min_gain_rel: n(m.min_gain_rel, 25),
		// and by at least this much capacity (in free 20 MHz channels)
		min_capacity_gain: n(m.min_gain_abs, 0.2),
		confirm: n(m.confirm, 2),
		min_switch_interval: n(m.min_switch_interval, 86400),
		// DFS channels: off, all radios, or only radios outside mesh groups
		// ("nomesh": a radar hit moves one node only and splits the mesh)
		dfs: (m.allow_dfs == '1') ? 'all' : (m.allow_dfs == 'nomesh') ? 'nomesh' : 'off',
		allow_dfs: m.allow_dfs == '1',
		ref_rssi: n(m.ref_rssi, -70),
		bcn_count: n(m.bcn_count, 10),
		reload_fallback: m.reload_fallback == '1',
		// radios with a mesh interface: "reload" restarts them on the new
		// channel; "csa" (experimental) announces the switch like for APs
		mesh_method: (m.mesh_method == 'csa') ? 'csa' : 'reload',
		// guarded switch of mesh radios: seconds the agents wait for their
		// mesh peers and for the controller's confirmation before going back
		guard_mesh_timeout: n(m.guard_mesh_timeout, 90),
		guard_confirm_timeout: n(m.guard_confirm_timeout, 240),
		channels_2g: map(list(m.channels_2g ?? '1 6 11'), (x) => +x),
		// channel width analysis (5 GHz, off by default): widths to compare,
		// days of data
		width_analysis: m.width_analysis == '1',
		widths_5g: map(list(m.widths_5g ?? '40 80'), (x) => +x),
		history_days: n(m.history_days, 3),
		max_combos: n(m.max_combos, 50000),
		nodes: [],
		groups: []
	};

	// sections created in LuCI are anonymous and carry an explicit name
	let name_of = (s) => (s.name != null && s.name != '') ? s.name : s['.name'];

	c.foreach('chanmgr', 'node', (s) => {
		let name = name_of(s);

		if (s.enabled == '0' || length(filter(cfg.nodes, (n) => n.name == name)))
			return;

		push(cfg.nodes, {
			name,
			type: s.host ? 'remote' : 'local',
			host: s.host,
			port: s.port,
			https: s.https == '1',
			insecure: s.insecure == '1',
			username: s.username,
			password: s.password,
			timeout: n(s.timeout, 30),
			exclude: list(s.exclude),
			lock: list(s.lock)
		});
	});

	c.foreach('chanmgr', 'group', (s) => {
		push(cfg.groups, { name: name_of(s), members: list(s.member) });
	});

	return cfg;
}

/* --- state & locking ---------------------------------------------------- */

function read_json(file) {
	try {
		return json(fs.readfile(file) ?? 'null');
	}
	catch (e) {
		return null;
	}
}

// After a reboot /tmp is empty: start from the copy in PERSIST_DIR.
function load_state() {
	let s = read_json(STATE_FILE) ?? read_json(PERSIST_FILE) ?? {};

	s.nodes ??= {};
	s.radios ??= {};
	s.plans ??= {};
	s.util ??= {};
	s.last_switch ??= {};
	s.history ??= [];
	s.chanstats ??= {};
	s.evals ??= [];

	return s;
}

// persist: also write the copy kept across reboots.
function save_state(s, persist) {
	fs.mkdir(RUN_DIR, 0700);
	s.updated = time();
	fs.writefile(STATE_FILE + '.tmp', sprintf('%J', s));
	fs.rename(STATE_FILE + '.tmp', STATE_FILE);

	if (persist) {
		// utilization counters are meaningless after a reboot
		let keep = { ...s };

		delete keep.util;
		fs.mkdir(PERSIST_DIR, 0755);
		fs.writefile(PERSIST_FILE + '.tmp', sprintf('%J', keep));
		fs.rename(PERSIST_FILE + '.tmp', PERSIST_FILE);
	}
}

function lock(what) {
	fs.mkdir(RUN_DIR, 0700);

	for (let attempt = 0; attempt < 2; attempt++) {
		if (fs.mkdir(LOCK_DIR)) {
			fs.writefile(LOCK_DIR + '/owner', sprintf('%s %s', fs.readlink('/proc/self'), what));

			return true;
		}

		let pid = split(fs.readfile(LOCK_DIR + '/owner') ?? '', ' ')[0];

		// stale lock of a process that died
		if (!pid || !fs.stat('/proc/' + pid)) {
			fs.unlink(LOCK_DIR + '/owner');
			fs.rmdir(LOCK_DIR);
		}
		else
			return false;
	}

	return false;
}

function unlock() {
	fs.unlink(LOCK_DIR + '/owner');
	fs.rmdir(LOCK_DIR);
}

function running() {
	let owner = fs.readfile(LOCK_DIR + '/owner');

	if (!owner)
		return null;

	let parts = split(trim(owner), ' ');

	return fs.stat('/proc/' + parts[0]) ? parts[1] : null;
}

// The units a plan moves, as recorded before it is applied.
function plan_changes(p) {
	return map(filter(p.units, (u) => u.best && (u.best.channel != u.current?.channel || u.best.width != u.current?.width)),
		(u) => ({ unit: u.id, from: u.current, to: u.best }));
}

function push_eval(st, entry) {
	unshift(st.evals, entry);

	if (length(st.evals) > EVALS_MAX)
		st.evals = slice(st.evals, 0, EVALS_MAX);
}

// One line of the evaluation log: when, why, and per band the decision.
//   changes: { band: plan_changes() } of this run
function add_eval(st, opts, now, errors, changes) {
	let bands = {};

	for (let band, p in st.plans) {
		if (p.ts < now)
			continue;

		bands[band] = {
			action: p.action, reason: p.reason,
			current_value: p.current_value, best_value: p.best_value, rel: p.rel,
			changes: changes[band] ?? []
		};
	}

	push_eval(st, {
		ts: now, trigger: opts?.trigger ?? 'manual', slot: opts?.slot,
		dry_run: opts?.apply === false, bands, errors
	});
}

// A radio moved: the status page shows it on its new channel until the next
// evaluation measures it there.
function mark_switched(st, rid, to) {
	let r = st.radios?.[rid];

	if (!r)
		return;

	r.channel = to.channel;
	r.width = to.width;
	r.util = null;

	for (let o in r.options ?? [])
		o.current = (o.channel == to.channel && o.width == to.width);
}

function add_history(st, entry) {
	unshift(st.history, { ts: time(), ...entry });

	if (length(st.history) > HISTORY_MAX)
		st.history = slice(st.history, 0, HISTORY_MAX);
}

/* --- nodes -------------------------------------------------------------- */

function handle(node) {
	if (node.type == 'local') {
		let fns = {
			info: () => agent.info(),
			survey: () => agent.survey(),
			scan: (a) => agent.scan(a.radio),
			switch: (a) => agent.switch_channel(a),
			confirm: (a) => agent.confirm(a),
			guard_start: (a) => guard.start(a),
			guard_status: (a) => guard.status(a.radio),
			guard_confirm: (a) => guard.confirm(a.radio),
			guard_abort: (a) => guard.abort(a.radio)
		};

		return {
			call: (method, args) => {
				try {
					let d = fns[method](args ?? {});

					return d?.error ? { error: d.error } : { data: d };
				}
				catch (e) {
					return { error: e.message };
				}
			}
		};
	}

	let cl = remote.client(node);

	return {
		call: (method, args, timeout) => {
			let r = cl.call('chanmgr', 'agent_' + method, args, timeout);

			return r.data?.error ? { error: r.data.error } : r;
		}
	};
}

function discover(cfg, st) {
	let res = {};

	for (let node in cfg.nodes) {
		node.h ??= handle(node);

		let r = node.h.call('info');

		res[node.name] = r;
		st.nodes[node.name] = r.error
			? { ok: false, error: r.error, ts: time() }
			: { ok: true, ts: time(), hostname: r.data.hostname, agent: r.data.agent ?? 1, radios: r.data.radios, down: r.data.down ?? {} };

		if (r.error)
			log('warn', 'node %s: %s', node.name, r.error);

		for (let radio, why in r.data?.down ?? {})
			log('warn', '%s/%s: %s', node.name, radio, why);
	}

	// forget nodes removed from the config
	for (let name in keys(st.nodes))
		if (!length(filter(cfg.nodes, (n) => n.name == name)))
			delete st.nodes[name];

	return res;
}

// May this radio use DFS channels? r: { has_mesh }
function dfs_ok(cfg, rid, r) {
	if (cfg.dfs == 'all')
		return true;

	return cfg.dfs == 'nomesh' && !r?.has_mesh && !length(filter(cfg.groups, (g) => index(g.members, rid) >= 0));
}

/* --- sampling ----------------------------------------------------------- */

function hour_start(ts) {
	let lt = localtime(ts);

	return ts - lt.min * 60 - lt.sec;
}

// The channel in use is measured all day, the others only while the radio
// scans (at the evaluation times). To compare them at the same hours, its
// 5 min samples are also kept per hour, as samples marked "in use" (third
// element 1) in the channel history; chanstats_summary matches them to the
// hours of the scans.
function flush_hour(st, rid, u) {
	let b = u?.hour;

	if (!b)
		return false;

	delete u.hour;

	if (!(b.active > 0))
		return false;

	let h = (st.chanstats ??= {})[rid] ??= {};

	push((h['' + u.freq] ??= { samples: [] }).samples, [ b.start, min(1, 1.0 * b.busy / b.active), 1 ]);

	return true;
}

function sample_into(st, cfg) {
	for (let node in cfg.nodes) {
		node.h ??= handle(node);

		let r = node.h.call('survey');

		if (r.error)
			continue;

		for (let radio, d in r.data.radios) {
			let rid = node.name + '/' + radio;
			let known = st.nodes?.[node.name]?.radios?.[radio];

			// moved since the last discovery (by hand, or by a switch)
			if (known && d.freq && known.freq != d.freq) {
				known.freq = d.freq;
				known.channel = chan.freq2chan(d.freq);
			}

			let e = filter(d.survey, (x) => x.in_use)[0] ?? filter(d.survey, (x) => x.freq == d.freq)[0];

			if (!e || e.active == null || e.busy == null)
				continue;

			let u = st.util[rid];

			if (!u || u.freq != e.freq) {
				flush_hour(st, rid, u);
				u = st.util[rid] = { freq: e.freq, acc_active: 0, acc_busy: 0, last: null, since: time() };
			}

			let busy = e.busy - (e.tx ?? 0);

			if (u.last) {
				let da = e.active - u.last.active, db = busy - u.last.busy;

				// receive airtime of our own clients (per station, in us) is
				// our traffic too, not congestion caused by neighbors
				let own = 0;

				for (let mac, us in d.stations ?? {}) {
					let prev = u.last.stations?.[mac];

					if (prev != null && us >= prev)
						own += (us - prev) / 1000.0;
				}

				// counters reset (interface restart) produce negative deltas
				if (da > 0 && db >= 0 && db <= da) {
					let hs = hour_start(time());

					u.acc_active += da;
					u.acc_busy += max(0, db - own);

					if (u.hour && u.hour.start != hs)
						flush_hour(st, rid, u);

					u.hour ??= { start: hs, active: 0, busy: 0 };
					u.hour.active += da;
					u.hour.busy += max(0, db - own);
				}
			}

			u.last = { active: e.active, busy, stations: d.stations ?? {} };
			u.value = (u.acc_active > 0) ? 1.0 * u.acc_busy / u.acc_active : null;
		}
	}

	st.last_sample = time();
}

function sample() {
	if (!lock('sample'))
		return { error: 'busy' };

	let st = load_state();

	sample_into(st, config());
	save_state(st);
	unlock();

	return { ok: true };
}

/* --- evaluation --------------------------------------------------------- */

// Secondary BSSIDs of a device usually differ from the primary MAC only in
// the first (locally administered bit) and last octet. Only used to tell
// which node a BSSID belongs to, never which radio.
function mac_core(mac) {
	return substr(mac, 3, 11);
}

function util_map(survey) {
	let res = {};

	for (let e in survey ?? [])
		if (e.active > 0 && e.busy != null)
			res['' + e.freq] = min(1, 1.0 * max(0, e.busy - (e.tx ?? 0)) / e.active);

	return res;
}

// Build radios, units and pairs per band from discovery + scan results.
function build_model(cfg, st, scans) {
	let radios = {}, own = {}, own_core = {};

	for (let node in cfg.nodes) {
		for (let radio, r in st.nodes[node.name]?.radios ?? {}) {
			let rid = node.name + '/' + radio;

			for (let b in r.bssids) {
				own[b] = node.name;
				own_core[mac_core(b)] = node.name;
			}

			if (r.band != '2g' && r.band != '5g')
				continue;

			if (index(node.exclude, radio) >= 0)
				continue;

			let width = (r.band == '2g') ? 20 : chan.htmode_width(r.htmode);

			radios[rid] = {
				rid, node: node.name, radio, band: r.band, htmode: r.htmode, max_width: r.max_width,
				current: chan.spec(r.band, r.channel, (r.band == '2g') ? 20 : r.width, (r.band == '2g') ? null : r.center),
				candidates: chan.candidates(r.band, width, chan.allowed_map(r.channels, r.band), { ...cfg, allow_dfs: dfs_ok(cfg, rid, r) }, r.channel),
				has_mesh: r.has_mesh,
				locked: (index(node.lock, radio) >= 0) ? 'locked in configuration' : null,
				neighbors: [],
				util: {},
				scanned: false
			};
		}
	}

	let heard = {};

	for (let rid, sc in scans) {
		let r = radios[rid];

		if (!r)
			continue;

		r.scanned = true;
		r.util = util_map(sc.survey);

		let acc = st.util[rid];

		if (acc?.value != null && acc.freq == r.current.freq)
			r.util['' + acc.freq] = acc.value;

		for (let b in sc.neighbors) {
			if (chan.freq2band(b.freq) != r.band)
				continue;

			let on = own[b.bssid] ?? own_core[mac_core(b.bssid)];

			if (on == r.node)
				continue;

			if (on) {
				// the radio of that node in the same band
				let o = filter(keys(radios), (k) => radios[k].node == on && radios[k].band == r.band)[0];

				if (!o)
					continue;

				let k = join('|', sort([ rid, o ]));

				heard[k] = max(heard[k] ?? -200, b.signal);
				continue;
			}

			push(r.neighbors, { bssid: b.bssid, ssid: b.ssid, signal: b.signal, spec: chan.neighbor_spec(b) });
		}
	}

	let pairs = [];

	for (let k, sig in heard) {
		let ab = split(k, '|');

		push(pairs, { a: ab[0], b: ab[1], signal: sig });
	}

	let group_of = {};

	for (let g in cfg.groups)
		for (let m in g.members)
			group_of[m] = g.name;

	let bands = {};

	for (let rid, r in radios) {
		if (!r.scanned)
			continue;

		let b = bands[r.band] ??= { units: [], byid: {} };
		let g = group_of[rid];
		let id = g ? 'group:' + g : rid;
		let u = b.byid[id];

		if (!u) {
			u = b.byid[id] = { id, radios: [], current: r.current, candidates: r.candidates, locked: null };
			push(b.units, u);
		}
		else {
			let ok = {};

			for (let s in r.candidates)
				ok[chan.key(s)] = true;

			u.candidates = filter(u.candidates, (s) => ok[chan.key(s)]);
		}

		push(u.radios, rid);

		if (r.locked)
			u.locked = r.locked;
		else if (r.has_mesh && !g)
			u.locked ??= 'mesh interface outside a group';
	}

	return { radios, pairs, bands };
}

/* --- channel width analysis --------------------------------------------- */

// Keep one busy-fraction sample per 20 MHz channel and evaluation, from the
// survey counters reported after a scan. Counters may be cumulative (then
// the difference to the previous evaluation is used) or reset per scan.
// The channel in use (current: { freq, value }) is recorded from its hourly
// in-use samples, which exclude our own clients' traffic (its survey entry
// from the scan would count that traffic as congestion); without any yet,
// from the long-term value.
function record_chanstats(st, rid, survey, days, now, current) {
	let h = st.chanstats[rid] ??= {};

	if (current?.value != null && !length(filter(h['' + current.freq]?.samples ?? [], (x) => x[2])))
		push((h['' + current.freq] ??= { samples: [] }).samples, [ now, current.value, 1 ]);

	for (let e in survey ?? []) {
		if (e.active == null || e.busy == null || e.in_use || e.freq == current?.freq)
			continue;

		let c = h['' + e.freq] ??= { samples: [] };
		let busy = max(0, e.busy - (e.tx ?? 0)), active = e.active;
		let da = active, db = busy;

		if (c.last && active > c.last.active && busy >= c.last.busy) {
			da = active - c.last.active;
			db = busy - c.last.busy;
		}

		c.last = { active, busy };

		if (da > 0)
			push(c.samples, [ now, min(1, 1.0 * db / da) ]);
	}

	// keep a little more than the analysis window (in use: 24 samples a day)
	for (let f, c in h) {
		c.samples = filter(c.samples, (x) => x[0] >= now - (days + 1) * 86400);  // > window + grace

		if (length(c.samples) > 24 * (days + 2) + 50)
			c.samples = slice(c.samples, -(24 * (days + 2) + 50));
	}
}

// Mean busy fraction per frequency over the last `days`, with sample count
// and age of the oldest sample.
// Evaluations run at about the same time every day, never exactly 24 h
// apart: a few hours of grace keep the sample of `days` ago in the window
// and let that window count as complete (see DATA_GRACE).
const DATA_GRACE = 6 * 3600;

//
// Samples of the channel in use (marked, one per hour) only count for the
// hours of the day in which the other channels were scanned: neighbors are
// busier in the evening than at 3 am, and an all-day mean of the current
// channel against night-time scans of the others would favor any switch.
// Without in-use samples at those hours (the first day), all of them count.
function chanstats_summary(h, days, now) {
	let util = {}, count = {}, first = {}, hours = {};
	let since = now - days * 86400 - DATA_GRACE;

	for (let f, c in h ?? {})
		for (let x in c.samples)
			if (x[0] >= since && !x[2])
				hours[localtime(x[0]).hour] = true;

	let matched = length(keys(hours)) > 0;

	for (let f, c in h ?? {}) {
		let all = filter(c.samples, (x) => x[0] >= since);
		let xs = matched ? filter(all, (x) => !x[2] || hours[localtime(x[0]).hour]) : all;

		if (!length(xs))
			xs = all;

		if (!length(xs))
			continue;

		let sum = 0, oldest = xs[0][0];

		for (let x in xs) {
			sum += x[1];
			oldest = min(oldest, x[0]);
		}

		util[f] = 1.0 * sum / length(xs);
		count[f] = length(xs);
		first[f] = oldest;
	}

	return { util, count, first };
}

// Inputs of the planner for one band (see score.plan): per radio the
// estimated busy fraction of every 20 MHz channel, per unit the options all
// members can use: the current width, plus every width in widths_5g on 5 GHz
// when width_analysis is on, up to the widest one the hardware supports.
function capacity_model(cfg, st, model, band, now) {
	let radios = {}, sums = {}, options = {};

	for (let rid, r in model.radios) {
		if (r.band != band || !r.scanned)
			continue;

		let nr = split(rid, '/');
		let allowed = chan.allowed_map(st.nodes[nr[0]]?.radios?.[nr[1]]?.channels ?? [], band);
		let sum = chanstats_summary(st.chanstats?.[rid], cfg.history_days, now);
		let measured = {};

		for (let f, m in sum.util)
			measured[f] = { mean: m, n: sum.count[f] };

		let channels = uniq([ ...map(keys(allowed), (k) => +k), ...chan.subchannels(r.current) ]);
		let vht = chan.htmode_flags(r.htmode, band).vht;
		let widths = (band == '5g' && cfg.width_analysis)
			? uniq([ ...filter(cfg.widths_5g, (w) => (w == 20 || w == 40 || (w >= 80 && vht)) && w <= (r.max_width ?? w)), r.current.width ])
			: [ r.current.width ];
		let opts = [];

		for (let w in widths)
			push(opts, ...chan.candidates(band, w, allowed, { ...cfg, allow_dfs: dfs_ok(cfg, rid, r) }, r.current.channel));

		radios[rid] = { busy: score.busy_estimate(band, channels, r.neighbors, measured, cfg) };
		sums[rid] = sum;
		options[rid] = opts;
	}

	let units = [];

	for (let u in model.bands[band].units) {
		let members = filter(u.radios, (rid) => radios[rid]);

		if (!length(members))
			continue;

		let cands = options[members[0]];

		for (let rid in slice(members, 1)) {
			let ok = {};

			for (let o in options[rid])
				ok[chan.key(o)] = true;

			cands = filter(cands, (o) => ok[chan.key(o)]);
		}

		push(units, { ...u, candidates: cands });
	}

	// samples and days of data behind an option on one radio
	let data = (rid, s) => {
		let subs = chan.subchannels(s), sum = sums[rid];
		let n = min(...map(subs, (c) => sum?.count['' + chan.chan2freq(band, c)] ?? 0));
		let oldest = min(...map(subs, (c) => sum?.first['' + chan.chan2freq(band, c)] ?? now));

		return { samples: n, days: (now - oldest) / 86400.0 };
	};

	// least days of measurements behind the proposed option of each unit
	let days = (best) => {
		let res = {};

		for (let u in units)
			res[u.id] = best[u.id] ? min(...map(filter(u.radios, (rid) => radios[rid]), (rid) => data(rid, best[u.id]).days)) : 0;

		return res;
	};

	let ready = (best) => {
		let res = {}, d = days(best);

		for (let u in units)
			res[u.id] = !!best[u.id] && d[u.id] >= cfg.history_days - DATA_GRACE / 86400.0;

		return res;
	};

	return { units, radios, data, days, ready };
}

function spec_json(s) {
	return s ? { channel: s.channel, width: s.width } : null;
}

function record(st, model, band, p, d, units, cm) {
	let b = { units: units ?? model.bands[band].units };

	st.plans[band] = {
		ts: time(),
		current_value: p.current_value,
		best_value: p.best_value,
		ready: p.ready,
		gain: d.gain, rel: d.rel,
		action: d.action, reason: d.reason,
		key: d.key, streak: d.streak,
		combos: p.combos, exhaustive: p.exhaustive,
		units: map(b.units, (u) => ({
			id: u.id, radios: u.radios, locked: u.locked,
			current: spec_json(u.current),
			best: spec_json(p.best[u.id])
		}))
	};

	for (let u in b.units) {
		for (let rid in u.radios) {
			let r = model.radios[rid];

			st.radios[rid] = {
				node: r.node, radio: r.radio, band, unit: u.id, locked: u.locked,
				channel: r.current.channel, width: r.current.width, max_width: r.max_width,
				util: r.util['' + r.current.freq],
				options: map(slice(p.table[rid], 0, 10), (o) => ({
					...o, ...cm.data(rid, chan.spec(band, o.channel, o.width))
				})),
				neighbors: slice(sort(map(r.neighbors, (n) => ({
					bssid: n.bssid, ssid: n.ssid, signal: n.signal,
					channel: n.spec.channel, width: n.spec.width
				})), (x, y) => y.signal - x.signal), 0, 40)
			};
		}
	}
}

function node_call(handles, rid, method, args, timeout) {
	let nr = split(rid, '/');
	let h = handles[nr[0]];
	let r = h ? h.call(method, { radio: nr[1], ...(args ?? {}) }, timeout) : { error: 'node not configured' };

	return r.error ? { ok: false, errors: [ r.error ] } : r.data;
}

// How to switch a radio, or an error when its agent is too old for that.
function switch_method(cfg, st, rid, to) {
	let nr = split(rid, '/');
	let n = st.nodes?.[nr[0]];

	if (to && n?.radios?.[nr[1]]?.width != null && to.width != n.radios[nr[1]].width && (n.agent ?? 1) < 4)
		return { error: 'update chanmgr on ' + nr[0] + ': its agent cannot change the channel width' };

	if (!n?.radios?.[nr[1]]?.has_mesh || cfg.mesh_method == 'csa')
		return { method: 'csa' };

	if ((n.agent ?? 1) < 3)
		return { error: 'update chanmgr on ' + nr[0] + ': its agent cannot switch mesh radios safely' };

	return { method: 'guard' };
}

function switch_one(cfg, st, handles, rid, from, to) {
	let m = switch_method(cfg, st, rid, to);

	if (m.method == 'guard')
		return switch_guarded(cfg, st, handles, rid, [ rid ], from, to);

	let res = m.error ? { ok: false, errors: [ m.error ] } : node_call(handles, rid, 'switch', {
		channel: to.channel, width: to.width, method: m.method,
		bcn_count: cfg.bcn_count, reload_fallback: cfg.reload_fallback
	}, 180);

	add_history(st, { rid, from: from?.channel, from_width: from?.width, to: to.channel, width: to.width, ok: res.ok, msg: join('; ', res.errors ?? []) });

	if (!res.ok)
		log('err', '%s: switch to channel %d failed: %s', rid, to.channel, join('; ', res.errors ?? []));

	return res.ok;
}

// Guarded switch of radios that carry mesh links (see guard.uc): every
// member switches on its own and returns to the old channel by itself unless
// its radio and mesh peers come back AND this controller confirms. The
// controller confirms only once all members report healthy, so the members
// never stay split across channels; when one fails, the others are aborted.
// The 10 s start delay lets the order reach every member before the first
// one moves (members behind the mesh are reached through the others).
function switch_guarded(cfg, st, handles, id, rids, from, to) {
	let tick = +(getenv('CHANMGR_GUARD_TICK') ?? 5000);
	let started = [];

	for (let rid in rids) {
		let r = node_call(handles, rid, 'guard_start', {
			channel: to.channel, width: to.width, delay: 10,
			mesh_timeout: cfg.guard_mesh_timeout, confirm_timeout: cfg.guard_confirm_timeout
		}, 30);

		if (!r.ok) {
			let why = r.error ?? (join('; ', r.errors ?? []) || 'could not start');

			log('err', '%s: switch not started on %s: %s', id, rid, why);

			for (let s in started)
				node_call(handles, s, 'guard_abort', {}, 10);

			add_history(st, { rid, from: from?.channel, from_width: from?.width, to: to.channel, width: to.width, ok: false, msg: 'not started: ' + why });

			return false;
		}

		push(started, rid);
	}

	log('notice', '%s: guarded switch %d -> %d started on %s', id, from?.channel, to.channel, join(', ', rids));

	let deadline = time() + cfg.guard_confirm_timeout + cfg.guard_mesh_timeout + 120;
	let state = {}, msg = {}, aborted = false;
	let all = (fn) => length(filter(rids, (r) => fn(state[r]))) == length(rids);
	let any = (fn) => length(filter(rids, (r) => fn(state[r]))) > 0;
	let good = (s) => s == 'confirmed' || s == 'done';

	while (time() < deadline) {
		sleep(tick);

		// members behind a moving mesh link are unreachable for a while
		for (let rid in rids) {
			let s = node_call(handles, rid, 'guard_status', {}, 10);

			if (s.state) {
				state[rid] = s.state;
				msg[rid] = s.msg;
			}
		}

		if (all((s) => guard.FINAL[s]))
			break;

		if (!aborted && any((s) => s == 'rolling_back' || s == 'rolled_back' || s == 'failed')) {
			aborted = true;
			log('warn', '%s: a member failed, sending everyone back to channel %d', id, from?.channel);

			for (let rid in rids)
				if (!guard.FINAL[state[rid]])
					node_call(handles, rid, 'guard_abort', {}, 10);
		}

		if (!aborted && all((s) => s == 'waiting_confirm' || good(s))) {
			for (let rid in rids)
				if (state[rid] == 'waiting_confirm')
					node_call(handles, rid, 'guard_confirm', {}, 10);
		}

		if (!aborted && all(good))
			break;
	}

	let ok = !aborted && all(good);

	for (let rid in rids)
		add_history(st, {
			rid, from: from?.channel, from_width: from?.width, to: to.channel, width: to.width, ok,
			msg: ok ? 'guarded switch' + (msg[rid] ? ': ' + msg[rid] : '')
				: sprintf('%s%s', state[rid] ?? 'unreachable', msg[rid] ? ': ' + msg[rid] : '')
		});

	if (!ok && !all((s) => guard.FINAL[s]))
		log('warn', '%s: some members are still finishing; they return to channel %d on their own', id, from?.channel);

	return ok;
}

// Members of a group (e.g. an 802.11s mesh) must end up on the same channel:
// announce the switch on all of them, confirm each, and if any of them did not
// make it, move all of them back to the old channel.
function switch_group(cfg, st, handles, u) {
	let methods = map(u.radios, (rid) => switch_method(cfg, st, rid, u.best));
	let err = filter(methods, (m) => m.error)[0]?.error;

	if (err) {
		log('err', '%s: %s', u.id, err);
		add_history(st, { rid: u.id, from: u.current?.channel, from_width: u.current?.width, to: u.best.channel, width: u.best.width, ok: false, msg: err });

		return false;
	}

	if (length(filter(methods, (m) => m.method == 'guard')))
		return switch_guarded(cfg, st, handles, u.id, u.radios, u.current, u.best);

	let reload = length(filter(methods, (m) => m.method == 'reload')) > 0;

	let move = (to, method) => {
		let ok = true;

		for (let rid in u.radios) {
			let res = node_call(handles, rid, 'switch', {
				channel: to.channel, width: to.width, bcn_count: cfg.bcn_count, nowait: true, method
			}, 60);

			if (!res.ok) {
				log('err', '%s: channel switch announcement failed: %s', rid, join('; ', res.errors ?? []));
				ok = false;
			}
		}

		let results = {};

		for (let rid in u.radios) {
			results[rid] = node_call(handles, rid, 'confirm', { channel: to.channel, width: to.width, timeout: 45 }, 90).ok;
			ok = ok && results[rid];
		}

		return { ok, results };
	};

	let r = move(u.best, reload ? 'reload' : 'csa');

	for (let rid in u.radios)
		add_history(st, {
			rid, from: u.current?.channel, from_width: u.current?.width, to: u.best.channel, width: u.best.width, ok: r.results[rid],
			msg: r.results[rid] ? 'group ' + u.id : 'not on the new channel after the switch'
		});

	if (r.ok)
		return true;

	log('err', '%s: not all members switched, moving the group back to channel %d', u.id, u.current.channel);

	// restarting is the most reliable way back, whatever went wrong
	let back = move(u.current, 'reload');

	for (let rid in u.radios)
		add_history(st, {
			rid, from: u.best.channel, from_width: u.best.width, to: u.current.channel, width: u.current.width, ok: back.results[rid],
			msg: back.results[rid] ? 'rollback, group ' + u.id : 'ROLLBACK FAILED, check this radio'
		});

	if (!back.ok)
		log('crit', '%s: rollback failed, group members may be on different channels', u.id);

	return false;
}

// Apply the stored plan of a band, one unit at a time. Stops on first failure.
//   manual: "Apply plan now", the plan is applied whatever its decision said
function apply_band(cfg, st, band, manual) {
	let p = st.plans[band];
	let handles = {};
	let changed = 0;

	for (let n in cfg.nodes)
		handles[n.name] = n.h ?? (n.h = handle(n));

	for (let u in p?.units ?? []) {
		if (u.locked || !u.best || (u.best.channel == u.current?.channel && u.best.width == u.current?.width))
			continue;

		if (changed++ > 0)
			sleep(cfg.apply_gap * 1000);

		let ok = (length(u.radios) > 1)
			? switch_group(cfg, st, handles, u)
			: switch_one(cfg, st, handles, u.radios[0], u.current, u.best);

		if (!ok) {
			p.action = 'failed';
			p.reason = 'switch failed, stopped';

			return false;
		}

		for (let rid in u.radios) {
			st.last_switch[rid] = time();
			delete st.util[rid];
			mark_switched(st, rid, u.best);
			log('notice', '%s: switched channel %d -> %d (%d MHz)', rid, u.current?.channel, u.best.channel, u.best.width);
		}

		u.current = u.best;
	}

	p.action = 'applied';
	p.applied = time();
	p.key = '';
	p.streak = 0;

	if (manual)
		p.reason = 'by "Apply plan now", ignoring the decision rules';

	return true;
}

// Full evaluation: discover, scan every node (staggered), plan, maybe apply.
//   opts: { apply: true|false|null (null = follow configured mode), nogap }
function evaluate(opts) {
	if (!lock('evaluate'))
		return { error: 'another operation is running' };

	let cfg = config(), st = load_state(), now = time();
	let scans = {}, errors = [], changes = {};

	delete st.last_error;

	try {
		discover(cfg, st);
		sample_into(st, cfg);

		for (let node in cfg.nodes)
			if (st.nodes[node.name]?.error)
				push(errors, sprintf('%s: %s', node.name, st.nodes[node.name].error));

		let first = true;

		for (let node in cfg.nodes) {
			let n = st.nodes[node.name];

			if (!n?.ok)
				continue;

			if (!first && !opts?.nogap && cfg.scan_gap > 0)
				sleep(cfg.scan_gap * 1000);

			first = false;

			for (let radio, r in n.radios) {
				if (index(node.exclude, radio) >= 0 || (r.band != '2g' && r.band != '5g'))
					continue;

				let res = node.h.call('scan', { radio }, 90);

				if (res.error) {
					log('warn', '%s/%s: scan failed: %s', node.name, radio, res.error);
					push(errors, sprintf('%s/%s: scan failed: %s', node.name, radio, res.error));
				}
				else {
					scans[node.name + '/' + radio] = res.data;

					let u = st.util[node.name + '/' + radio];

					// the hour of this scan, in use so far
					if (u?.freq == r.freq)
						flush_hour(st, node.name + '/' + radio, u);

					record_chanstats(st, node.name + '/' + radio, res.data.survey, cfg.history_days, now,
						{ freq: r.freq, value: (u?.freq == r.freq) ? u.value : null });
				}
			}
		}

		let model = build_model(cfg, st, scans);

		st.radios = {};

		for (let band, b in model.bands) {
			let cm = capacity_model(cfg, st, model, band, now);
			let units = cm.units;
			let p = score.plan(units, cm.radios, model.pairs, cfg);

			p.ready = cm.ready(p.best);
			p.days = cm.days(p.best);

			let d = score.decide(units, p, st.plans[band], st.last_switch, cfg, now);

			record(st, model, band, p, d, units, cm);
			changes[band] = plan_changes(st.plans[band]);
			st.plans[band].history_days = cfg.history_days;
			log('info', '%s: capacity %.2f -> %.2f, %s (%s)', band, p.current_value, p.best_value, d.action, d.reason);

			let do_apply = (opts?.apply != null) ? opts.apply : (cfg.mode == 'apply');

			if (d.action == 'switch' && do_apply)
				apply_band(cfg, st, band);
			else if (d.action == 'switch')
				st.plans[band].action = 'recommend';
		}

		for (let band in keys(st.plans))
			if (!model.bands[band])
				delete st.plans[band];

		// exponential window: older samples weigh half at every evaluation
		for (let rid, u in st.util) {
			u.acc_active /= 2.0;
			u.acc_busy /= 2.0;
		}

		st.last_eval = now;
	}
	catch (e) {
		log('err', 'evaluation failed: %s', e.message);
		st.last_error = e.message;
		push(errors, 'evaluation failed: ' + e.message);
	}

	add_eval(st, opts, now, errors, changes);
	save_state(st, true);
	unlock();

	return { ok: !st.last_error, plans: st.plans };
}

// Apply the latest stored plan now, ignoring hysteresis ("Apply now").
//   only_band: '2g' or '5g' to leave the other band alone
function apply(only_band) {
	if (!lock('apply'))
		return { error: 'another operation is running' };

	let cfg = config(), st = load_state(), ok = true, bands = {}, now = time();

	for (let band, p in st.plans) {
		if ((only_band && band != only_band) || p.key == '' || p.action == 'applied')
			continue;

		let changes = plan_changes(p);

		ok = apply_band(cfg, st, band, true) && ok;
		bands[band] = { action: p.action, reason: p.reason, changes };
	}

	if (length(bands))
		push_eval(st, { ts: now, trigger: 'apply', bands, errors: [] });

	discover(cfg, st);
	save_state(st, true);
	unlock();

	return { ok };
}

function do_discover() {
	let cfg = config(), st = load_state();
	let res = discover(cfg, st);

	if (lock('discover')) {
		save_state(st);
		unlock();
	}

	return res;
}

// Scheduled evaluation times of the day containing `now`, as timestamps.
function eval_slots(cfg, now) {
	let lt = localtime(now);
	let midnight = now - lt.hour * 3600 - lt.min * 60 - lt.sec;
	let res = [];

	for (let t in cfg.eval_times) {
		let m = match(t, /^([0-9]{1,2}):([0-9]{2})$/);

		if (m && +m[1] < 24 && +m[2] < 60)
			push(res, { name: t, ts: midnight + +m[1] * 3600 + +m[2] * 60 });
	}

	return sort(res, (a, b) => a.ts - b.ts);
}

// The slot to run now, if any: due within the last hour and not run since.
// The window (instead of the exact minute) keeps a slow sample or a long
// evaluation from making the scheduler skip a slot.
function due_slot(cfg, now, last_eval) {
	for (let s in eval_slots(cfg, now))
		if (now >= s.ts && now - s.ts < 3600 && (last_eval ?? 0) < s.ts)
			return s;

	return null;
}

function next_slot(cfg, now) {
	for (let day = 0; day < 2; day++)
		for (let s in eval_slots(cfg, now + day * 86400))
			if (s.ts > now)
				return s.ts;

	return null;
}

function heartbeat(cfg, extra) {
	fs.mkdir(RUN_DIR, 0700);
	fs.writefile(RUN_DIR + '/daemon.json', sprintf('%J', {
		pid: +fs.readlink('/proc/self'), ts: time(), next_eval: next_slot(cfg, time()), ...(extra ?? {})
	}));
}

function scheduler() {
	let d;

	try {
		d = json(fs.readfile(RUN_DIR + '/daemon.json') ?? 'null');
	}
	catch (e) {
		d = null;
	}

	let cfg = config();

	return {
		enabled: cfg.enabled,
		role: cfg.role,
		mode: cfg.mode,
		eval_times: cfg.eval_times,
		running: !!(d?.pid && fs.stat('/proc/' + d.pid)),
		next_eval: d?.next_eval ?? next_slot(cfg, time())
	};
}

// "Clear history": change history, channel measurements and plans (with
// their confirmation streaks). The 24 h minimum between switches of a radio
// is a safeguard, not history, and is kept.
function clear_history() {
	if (!lock('clear'))
		return { error: 'another operation is running' };

	let st = load_state();

	st.history = [];
	st.evals = [];
	st.chanstats = {};
	st.util = {};
	st.plans = {};
	st.radios = {};
	save_state(st, true);
	agent.clear_changes();
	unlock();
	log('notice', 'history cleared');

	return { ok: true };
}

// The radios and plans as last evaluated, but on the channels the nodes
// report now: a switch, or a change made by hand, shows at once instead of
// at the next evaluation.
function follow_nodes(st) {
	let live = (rid) => {
		let nr = split(rid, '/');

		return st.nodes[nr[0]]?.radios?.[nr[1]];
	};

	for (let rid, r in st.radios) {
		let l = live(rid);

		if (!l?.channel || (l.channel == r.channel && (r.band == '2g' || l.width == r.width)))
			continue;

		mark_switched(st, rid, { channel: l.channel, width: (r.band == '2g') ? r.width : (l.width ?? r.width) });

		let u = st.util[rid];

		if (u?.value != null && u.freq == l.freq)
			r.util = u.value;
	}

	for (let band, p in st.plans)
		for (let u in p.units ?? []) {
			let l = live(u.radios[0]);

			if (l?.channel && u.current)
				u.current = { ...u.current, channel: l.channel, width: (band == '2g') ? u.current.width : (l.width ?? u.current.width) };
		}
}

function status() {
	let st = load_state();

	follow_nodes(st);
	st.running = running();
	st.scheduler = scheduler();
	delete st.util;
	delete st.chanstats;

	return st;
}

// One round of the service loop. ctx: { last_sample, failed }
function daemon_tick(ctx) {
	let cfg = config(), now = time();
	let slot = due_slot(cfg, now, load_state().last_eval);

	heartbeat(cfg);

	if (slot && !ctx.failed[slot.ts]) {
		log('info', 'scheduled evaluation (%s)', slot.name);
		heartbeat(cfg, { busy: 'evaluate' });

		let r = evaluate({ trigger: 'scheduled', slot: slot.name });

		// another operation held the lock: try again on the next round;
		// an evaluation that failed is not retried for this slot
		if (r?.error)
			log('warn', 'scheduled evaluation postponed: %s', r.error);
		else if (!r?.ok)
			ctx.failed[slot.ts] = true;

		ctx.last_sample = time();
	}
	else if (now - ctx.last_sample >= cfg.sample_interval) {
		sample();
		ctx.last_sample = now;
	}

	return ctx;
}

// Long-running service loop (procd).
function daemon() {
	let ctx = { last_sample: 0, failed: {} };

	log('info', 'scheduler started, evaluations at %s', join(' ', config().eval_times));

	while (true) {
		daemon_tick(ctx);
		sleep(20000);
	}
}

return { config, dfs_ok, evaluate, apply, sample, discover: do_discover, status, daemon, build_model, switch_group, switch_guarded, due_slot, next_slot, scheduler, daemon_tick, record_chanstats, chanstats_summary, sample_into, clear_history, capacity_model };
