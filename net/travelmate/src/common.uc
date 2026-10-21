// travelmate - shared settings: typed 'global' options, curl arguments and
// the command runner for the daemon and the login scripts, no shell involved

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { popen, access } from 'fs';

export const RUNDIR = '/var/run/travelmate';

// seconds per curl attempt and between its retries
export const FETCH_TIMEOUT = 5;

// option: [ type, default, min ]; bool: '1' is on, int: default if not a
// number or below min, list: a uci list or the words of an option
export const OPTIONS = {
	trm_enabled: [ 'bool', false ],
	trm_debug: [ 'bool', false ],
	trm_iface: [ 'string', '' ],
	trm_laniface: [ 'string', '' ],
	trm_captive: [ 'bool', true ],
	trm_proactive: [ 'bool', false ],
	trm_vpn: [ 'bool', false ],
	trm_netcheck: [ 'bool', false ],
	trm_autoadd: [ 'bool', false ],
	trm_randomize: [ 'bool', false ],
	trm_eviltwin: [ 'bool', false ],
	trm_mail: [ 'bool', false ],
	trm_mailreceiver: [ 'string', '' ],
	trm_mailsender: [ 'string', 'no-reply@travelmate' ],
	trm_mailtopic: [ 'string', '' ],
	trm_mailprofile: [ 'string', 'trm_notify' ],
	trm_mailtemplate: [ 'string', '/etc/travelmate/mail.template' ],
	trm_minquality: [ 'int', 35 ],
	trm_maxretry: [ 'int', 3 ],
	trm_maxwait: [ 'int', 30, 1 ],
	trm_maxautoadd: [ 'int', 5 ],
	trm_autoaddcnt: [ 'int', 0 ],
	trm_timeout: [ 'int', 30, 1 ],
	trm_radio: [ 'list', [] ],
	trm_revradio: [ 'bool', false ],
	trm_ssidfilter: [ 'list', [] ],
	trm_vpnifacelist: [ 'list', [] ],
	trm_stdvpniface: [ 'string', '' ],
	trm_captiveurl: [ 'string', 'http://detectportal.firefox.com' ],
	trm_useragent: [ 'string', 'Mozilla/5.0 (X11; Linux x86_64; rv:144.0) Gecko/20100101 Firefox/144.0' ]
};

export function words(s) {
	return filter(split(trim('' + (s ?? '')), /[ \t\n]+/), length);
};

// one option value as its type
export function typed(kind, v, dflt, min) {
	if (v == null)
		return dflt;

	switch (kind) {
	case 'bool':
		return v == '1';

	case 'int':
		let n = int(v);

		return (n == n && (min == null || n >= min)) ? n : dflt;

	case 'list':
		return (type(v) == 'array') ? v : words(v);

	default:
		return (type(v) == 'array') ? join(' ', v) : '' + v;
	}
};

// the 'global' section, typed, unknown options are left out
export function global(c) {
	let g = c.get_all('travelmate', 'global') ?? {};
	let cfg = {};

	for (let k, o in OPTIONS)
		cfg[k] = typed(o[0], g[k], o[1], o[2]);

	return cfg;
};

// curl arguments of every fetch, bound to the uplink device if known
export function fetch_args(cfg, device) {
	let t = '' + FETCH_TIMEOUT;
	let args = [ '--silent', '--location', '--fail', '--referer', 'http://www.example.com',
		'--retry', '2', '--retry-delay', t, '--max-time', t ];

	if (length(device ?? ''))
		push(args, '--interface', device);

	return args;
};

// run a command directly (no shell), return { out: stdout, rc: exit code }
export function capture(argv) {
	let p = popen(argv, 'r');

	if (!p)
		return { out: '', rc: -1 };

	let out = p.read('all') ?? '';
	let rc = p.close();

	return { out, rc: rc ?? -1 };
};

// command lookup in PATH, like 'command -v'
export function have(cmd) {
	for (let dir in split(getenv('PATH') ?? '/usr/sbin:/usr/bin:/sbin:/bin', ':'))
		if (length(dir) && access(dir + '/' + cmd, 'x') == true)
			return true;

	return false;
};
