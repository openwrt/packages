#!/usr/bin/env ucode
// ubus interface for LibreSpeed measurements.
//
// Runs inside rpcd, which is exactly why it never measures anything itself: a
// measurement takes tens of seconds and would stall rpcd's event loop -- and
// with it every rpcd consumer on the system. Anything long-lived is handed to
// librespeed-run as a detached process.

'use strict';

import { open, readfile, stat } from 'fs';
import { cursor } from 'uci';

const STATE_DIR = '/tmp/librespeed';
const STATE = `${STATE_DIR}/state.json`;
const RESULT = `${STATE_DIR}/result.json`;
const LOCK = '/var/lock/librespeed.lock';
const RUN = '/usr/libexec/librespeed-run';

function read_json(path) {
	const text = readfile(path);

	if (text == null)
		return null;

	let value = null;

	try {
		value = json(text);
	}
	catch (e) {
		value = null;
	}

	return value;
}

// The process group of a pid, read from /proc: the runner is spawned detached
// (start-stop-daemon -b or setsid), so its group holds the whole measurement
// tree and nothing else. Parsed after the comm field's closing parenthesis,
// the one place a process can put spaces.
function pgid_of(pid) {
	const st = readfile(`/proc/${pid}/stat`);

	if (!st)
		return 0;

	const f = split(trim(substr(st, rindex(st, ')') + 1)), ' ');

	return int(f[2] ?? 0);
}

// The lock says whether a measurement runs, not a field in a file: a process
// that dies takes its lock with it, so there is no stale state to age out.
function is_running() {
	const f = open(LOCK, 'r');

	if (!f)
		return false;

	const acquired = f.lock('xn');

	if (acquired)
		f.lock('u');

	f.close();

	return !acquired;
}

function config_get(uci, section, option, fallback) {
	const v = uci.get('librespeed', section, option);

	return (v == null || v == '') ? fallback : v;
}

// Next occurrences of the drawn cron line, computed here rather than in the
// browser: the schedule fires in the router's timezone, and the browser may
// well sit in another one. Understands only the shapes librespeed.init
// emits: numbers, ranges, ranges with a step, star, and comma lists.
// Hoisted: ucode recompiles a regex literal on every evaluation, and these
// two dominate cron_next's cost inside rpcd, which must never stall.
const CRON_STEP = /^(.+)\/([0-9]+)$/;
const CRON_RANGE = /^([0-9]+)-([0-9]+)$/;

function cron_next(line, count) {
	const f = split(trim(line ?? ''), /\s+/);

	if (length(f) < 5)
		return [];

	const match_field = function(pat, val) {
		for (let part in split(pat, ',')) {
			let step = 1;
			let m = match(part, CRON_STEP);

			if (m) {
				part = m[1];
				step = int(m[2]);
			}

			let a, b;

			if (part == '*') {
				a = 0;
				b = 59;
			}
			else {
				m = match(part, CRON_RANGE);
				if (m) {
					a = int(m[1]);
					b = int(m[2]);
				}
				else {
					a = int(part);
					b = a;
				}
			}

			if (val >= a && val <= b && (val - a) % step == 0)
				return true;
		}

		return false;
	};

	const out = [];
	let t = time();
	t -= t % 60;

	// A miss skips the rest of the day or hour instead of walking its
	// minutes; that keeps this cheap inside rpcd's event loop, and cheap
	// enough for a five-week horizon, which a weekly schedule needs to
	// fill three rows where eight days could not. The day jump aims at
	// 23:00, not midnight: it is computed in local minutes but applied as
	// real ones, and across a spring-forward that lands an hour long --
	// from 23:00 the hour branch walks the last hour and cannot overshoot
	// into minutes that were never examined.
	for (let i = 0; i < 35 * 24 * 60 && length(out) < count; ) {
		t += 60;
		const lt = localtime(t);
		let skip;

		// % 7 folds both weekday conventions onto cron's 0-6 with Sunday 0.
		if (!match_field(f[4], lt.wday % 7)) {
			skip = (24 - lt.hour) * 60 - lt.min - 60;
			if (skip <= 0)
				skip = 60 - lt.min;
		}
		else if (!match_field(f[1], lt.hour))
			skip = 60 - lt.min;
		else {
			if (match_field(f[0], lt.min))
				push(out, t);
			i++;
			continue;
		}

		t += (skip - 1) * 60;
		i += skip;
	}

	return out;
}

const methods = {
	start: {
		call: function() {
			if (is_running())
				return { error: 'already running' };

			if (!stat(RUN))
				return { error: 'not installed' };

			// Detached: the frontend polls status instead of waiting here.
			system(`start-stop-daemon -S -b -x ${RUN} >/dev/null 2>&1 || ( setsid ${RUN} >/dev/null 2>&1 & )`);

			return { started: true };
		}
	},

	stop: {
		call: function() {
			const st = read_json(STATE);

			// Kill the whole process group, not just the wrapper shell:
			// librespeed-cli and the sampler must die with it, or a "stopped"
			// answer would leave the measurement running on inherited fds.
			// busybox kill takes the negative pgid without `--`.
			if (is_running() && st?.pid) {
				const pg = pgid_of(int(st.pid));

				if (pg > 0)
					system(`kill -TERM -${pg} 2>/dev/null`);
				else
					system(`kill -TERM ${int(st.pid)} 2>/dev/null`);
			}

			return { stopped: true };
		}
	},

	status: {
		call: function() {
			const st = read_json(STATE) ?? {};

			if (is_running()) {
				const out = { running: true, phase: st.phase ?? '' };

				if (st.pid)
					out.pid = int(st.pid);
				if (st.started) {
					out.started = int(st.started);
					// Elapsed is computed here, on the clock that stamped
					// started: the browser's clock may sit anywhere.
					out.elapsed = time() - int(st.started);
				}
				if (st.mbps != null)
					out.mbps = st.mbps + 0.0;
				if (st.progress != null)
					out.progress = int(st.progress);

				return out;
			}

			const out = { running: false, last_error: st.last_error ?? '' };

			if (st.last_finished)
				out.last_finished = int(st.last_finished);

			return out;
		}
	},

	result: {
		call: function() {
			return read_json(RESULT) ?? {};
		}
	},

	// Contract: one response comes from exactly one source. A range that fits
	// the raw retention window returns raw measurements; an older range is
	// served from the daily archive at 1d resolution (completed days only, so
	// today is absent there). The two never mix in one response --
	// `resolution` names the source, and a consumer comparing two windows
	// must compare like with like.
	history: {
		args: { from: 0, to: 0, limit: 0 },
		call: function(request) {
			const from = int(request.args?.from ?? 0);
			const to = int(request.args?.to ?? 0);
			const limit = int(request.args?.limit ?? 0);

			const uci = cursor();
			const raw_path = config_get(uci, 'history', 'path',
				`${STATE_DIR}/history.jsonl`);
			const archive_path = config_get(uci, 'history', 'archive_path', '');
			const raw_days = int(config_get(uci, 'history', 'retention', '30d')) || 30;
			uci.unload('librespeed');

			// Ranges the raw window can answer come from raw; anything reaching
			// further back is served from the daily archive when one is kept.
			// The hour of slack keeps the boundary request -- "the last 30
			// days" against a 30-day window -- from flapping between sources
			// over clock skew.
			let resolution = 'raw';
			let path = raw_path;

			if (archive_path != '' && stat(archive_path) &&
			    (from == 0 || from < time() - raw_days * 86400 - 3600)) {
				resolution = '1d';
				path = archive_path;
			}

			const entries = [];
			const f = open(path, 'r');

			if (f) {
				for (let line = f.read('line'); length(line); line = f.read('line')) {
					let e = null;

					try {
						e = json(line);
					}
					catch (err) {
						continue;
					}

					if (from > 0 && int(e?.epoch ?? 0) < from)
						continue;
					if (to > 0 && int(e?.epoch ?? 0) > to)
						continue;

					push(entries, e);
				}

				f.close();
			}

			// Newest N, still oldest first.
			const kept = (limit > 0 && length(entries) > limit)
				? slice(entries, -limit) : entries;

			return { resolution: resolution, entries: kept };
		}
	},

	config: {
		call: function() {
			const uci = cursor();

			// The drawn schedule lives in the crontab, not in UCI: for a daily
			// interval the time is picked at sync. Handing the line out lets
			// the frontend show when measurements will actually run.
			let cron = '';
			const cf = open('/etc/crontabs/root', 'r');

			if (cf) {
				for (let line = cf.read('line'); length(line); line = cf.read('line'))
					if (index(line, '/usr/libexec/librespeed-run') >= 0)
						cron = trim(line);
				cf.close();
			}

			const out = {
				interface: config_get(uci, 'main', 'interface', 'wan'),
				server: config_get(uci, 'main', 'server', 'auto'),
				scheme: config_get(uci, 'main', 'scheme', 'auto'),
				server_list: config_get(uci, 'main', 'server_list', ''),
				schedule: {
					// What the crontab holds, not what UCI intends: a
					// hand-set 'true' satisfies the init script's bool but
					// not a string compare, and the page would say No while
					// cron fires. The line is the one source of truth.
					enabled: cron != '',
					interval: config_get(uci, 'schedule', 'interval', '1d'),
					days: config_get(uci, 'schedule', 'days', '*'),
					hours: config_get(uci, 'schedule', 'hours', ''),
					cron: cron,
					next_runs: cron != '' ? cron_next(cron, 3) : []
				},
				history: {
					enabled: config_get(uci, 'history', 'enabled', '1') != '0',
					path: config_get(uci, 'history', 'path',
						`${STATE_DIR}/history.jsonl`),
					retention: config_get(uci, 'history', 'retention', '30d')
				}
			};

			uci.unload('librespeed');

			return out;
		}
	}
};

return { librespeed: methods };
