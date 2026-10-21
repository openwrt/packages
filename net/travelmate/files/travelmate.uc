#!/usr/bin/ucode
// travelmate - wlan connection manager for travel routers: 'run' is the
// procd daemon, the other commands serve the init script and LuCI

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { readfile, writefile, rename, unlink, open, readlink } from 'fs';
import { create, system_io, FILES } from 'travelmate.daemon';

function usage() {
	warn('usage: travelmate run [<action>]\n' +
		'       travelmate stop\n' +
		'       travelmate scan <radio|ifname>\n' +
		'       travelmate status\n');
	exit(1);
}

// syslog with the 'trm-<version>[pid]' tag LuCI filters on; TRM_TRACE
// redirects logs and sleeps into a file for the test suite
let trace = getenv('TRM_TRACE');
let syslog_tag = null;

function log_line(class, tag, msg) {
	if (trace) {
		let fh = open(trace, 'a');

		fh?.write(sprintf('LOG %s %s: %s\n', class, tag, msg));
		fh?.close();

		return;
	}

	let l = require('log');

	if (syslog_tag != tag) {
		l.openlog(tag, l.LOG_PID, l.LOG_USER);
		syslog_tag = tag;
	}

	l.syslog({ debug: l.LOG_DEBUG, info: l.LOG_INFO, err: l.LOG_ERR, emerg: l.LOG_EMERG }[class] ?? l.LOG_NOTICE, '%s', msg);
}

function make_io() {
	let io = system_io(log_line);

	if (trace) {
		io.sleep = (s) => {
			let fh = open(trace, 'a');

			fh?.write(sprintf('SLEEP %d\n', s));
			fh?.close();
		};
		io.time = () => '2026-01-01 00:00:00';
	}

	return io;
}

function stop_service() {
	system([ '/etc/init.d/travelmate', 'stop' ]);
	exit(0);
}

// wait for the cycle timeout; a reload (SIGHUP) cuts it short, then only a
// missing gateway starts a cycle, otherwise the full timeout starts over
let hup = false;

function idle(d) {
	while (true) {
		hup = false;

		for (let left = +d.T.cfg.trm_timeout; left > 0 && !hup; left--)
			sleep(1000);

		if (!hup || !d.getgw())
			return;
	}
}

// the action comes from a file, not the command line, so a 'start' from a
// trigger leaves the running procd instance alone
function run(action) {
	let d = create(make_io());

	action ??= trim(readfile(FILES.actionfile) ?? '');

	signal('SIGHUP', () => { hup = true; });
	d.startup(length(action) ? action : 'start');

	if (!d.conf())
		stop_service();

	if (length(d.T.action)) {
		d.log('info', sprintf('travelmate instance started ::: action: %s, pid: %d', d.T.action, +readlink('/proc/self')));
		d.main();
		d.T.action = '';
	}

	while (true) {
		idle(d);

		if (!d.conf())
			stop_service();

		d.main();
	}
}

function stop() {
	let d = create(make_io());
	let pid = trim(readfile(FILES.pidfile) ?? '');

	d.startup('stop');

	if (length(pid)) {
		d.log('info', sprintf('travelmate instance stopped ::: action: stop, pid: %s', pid));
		writefile(FILES.rtfile, '');
		writefile(FILES.revivefile, '');
		writefile(FILES.pidfile, '');
	}

	return 0;
}

function scan(radio) {
	if (!match(radio ?? '', /^[a-z0-9]+$/))
		return 1;

	let d = create(make_io());
	let tmp = FILES.scanfile + '.tmp';

	writefile(tmp, sprintf('%J\n', d.scan(radio)));
	rename(tmp, FILES.scanfile);

	return 0;
}

function status() {
	print(create(make_io()).status_text());

	return 0;
}

switch (ARGV[0]) {
case 'run':
	run(ARGV[1]);
	break;

case 'stop':
	exit(stop());

case 'scan':
	exit(scan(ARGV[1]));

case 'status':
	exit(status());

default:
	usage();
}
