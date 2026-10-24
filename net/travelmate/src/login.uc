// travelmate - helpers for the login scripts /etc/travelmate/*.uc (args:
// credentials, exit code 0 on success), test: ucode /etc/travelmate/x.uc u p

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { cursor } from 'uci';
import { connect } from 'ubus';
import { global as cfg_global, fetch_args, capture } from 'travelmate.common';
import { hostname } from 'travelmate.net';

const cfg = cfg_global(cursor());

export const captiveurl = cfg.trm_captiveurl;
export const useragent = cfg.trm_useragent;

let base = null;

// curl arguments like the daemon's, bound to the uplink device
function args() {
	if (base == null) {
		let dev = connect()?.call('network.interface.' + cfg.trm_iface, 'status')?.device;

		base = fetch_args(cfg, (dev != null) ? '' + dev : '');
	}

	return base;
}

// fetch an url with the travelmate curl settings, returns { rc, body }; opts:
// args (extra curl arguments), follow (false: no redirects), write_out
export function fetch(url, opts) {
	let a = [ ...args() ];

	if (opts?.follow === false)
		a = filter(a, (x) => x != '--location');

	let argv = [ 'curl', ...a, '--user-agent', useragent ];

	if (opts?.write_out != null)
		push(argv, '--write-out', opts.write_out);

	// '--url': an url from a portal page must never be taken as option
	push(argv, ...(opts?.args ?? []), '--url', '' + url);

	let r = capture(argv);

	return { rc: r.rc, body: r.out };
};

// true if the name resolves, only dns names are looked up
export function lookup(domain) {
	return hostname(domain) && system([ '/bin/sh', '-c', 'exec nslookup "$0" >/dev/null 2>&1', domain ]) == 0;
};

// true if url is an https url on host (the login post of a script must not
// go to a host taken from a page of a spoofed hotspot)
export function https_on(url, host) {
	return index(lc('' + url), 'https://' + lc(host) + '/') == 0;
};

// percent-encode everything but unreserved characters, a blank as %20
export function urlencode(s) {
	let out = '';

	for (let i = 0; i < length(s); i++) {
		let c = substr(s, i, 1);

		out += match(c, /^[a-zA-Z0-9.~_-]$/) ? c : sprintf('%%%02X', ord(s, i));
	}

	return out;
};

// per line the text between the first opening and the last closing tag,
// tags matched case-insensitively, all hits joined
export function between(text, open, close) {
	let out = '';

	open = lc(open);
	close = lc(close);

	for (let l in split(text ?? '', '\n')) {
		let ll = lc(l), a = index(ll, open), b = rindex(ll, close);

		if (a >= 0 && b >= a + length(open))
			out += substr(l, a + length(open), b - a - length(open));
	}

	return out;
};
