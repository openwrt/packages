// travelmate - internet and captive portal check: classifies the curl
// probe reply as net ok, nok or cp (captive portal) with its host

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

export const MARKER = '#trm-meta#';

// lowercased host, port stripped (the host ends up in the dnsmasq rebind
// allowlist), an IPv6 literal keeps its brackets
function host(h) {
	h = lc(h ?? '');

	if (substr(h, 0, 1) == '[') {
		let i = index(h, ']');

		return (i >= 0) ? substr(h, 0, i + 1) : h;
	}

	return replace(h, /:[0-9]*$/, '');
}

export function probe_host(url) {
	let i = index(url, '://');

	if (i >= 0)
		url = substr(url, i + 3);

	return host(split(url, '/')[0]);
};

// bytes above 0x7f as '?', libc regex may refuse invalid UTF-8 from portal
// pages; lengths stay the same, so match offsets still apply
function ascii(s) {
	let out = '';

	for (let i = 0; i < length(s); i++)
		out += (ord(s, i) > 127) ? '?' : substr(s, i, 1);

	return out;
}

// host of an absolute ('scheme://') or scheme-relative ('//') redirect
// target, '' for a relative one; an IPv6 literal keeps its brackets
function target_host(t) {
	t = replace(t, /^[ \t"']+/, '');

	let m = match(t, /^([a-z][a-z0-9+.-]*:)?\/\//);

	if (!m)
		return '';

	t = substr(t, length(m[0]));

	if (substr(t, 0, 1) == '[') {
		let i = index(t, ']');

		return (i >= 0) ? substr(t, 0, i + 1) : t;
	}

	return replace(t, /[:\/?#;>"' \t].*$/, '');
}

// first body line with a redirect, the host of its target
function redirect(lines, needle, re) {
	for (let l in lines) {
		l = lc(l);

		if (index(l, needle) < 0)
			continue;

		l = ascii(l);

		let m = match(l, re);

		if (m)
			return target_host(substr(l, length(m[0])));
	}

	return '';
}

// last word of a curl error message that ends in a domain name
function err_domain(msg) {
	msg = ascii(msg);

	if (!match(msg, /([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+$/))
		return '';

	let w = split(trim(msg), /[ \t]+/);

	return lc(w[length(w) - 1]);
}

// a dns name: letters, digits and hyphens in dot separated labels, at
// least two labels, the last one not numeric; no ip address literal
export function hostname(h) {
	if (type(h) != 'string' || length(h) > 253)
		return false;

	let labels = split(h, '.');

	if (length(labels) < 2 || match(labels[-1], /^[0-9]+$/))
		return false;

	for (let l in labels)
		if (!match(l, /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/i))
			return false;

	return true;
};

export function classify(raw, probe_url, captive) {
	let i = rindex(raw, MARKER);
	let json_raw = (i >= 0) ? substr(raw, i + length(MARKER)) : raw;
	let html_raw = (i >= 0) ? substr(raw, 0, i) : raw;
	let r = {
		result: 'net nok', probe_host: probe_host(probe_url),
		ec: '', rc: '', eff_url: '', cp: '', html: '', js: '', err: ''
	};

	if (length(json_raw)) {
		let meta = null;

		try { meta = json(json_raw); } catch (e) { }

		if (type(meta) == 'object') {
			r.ec = '' + (meta.exitcode ?? '');
			r.rc = '' + (meta.response_code ?? '');
			r.eff_url = '' + (meta.url_effective ?? '');
		}

		r.cp = host(split(r.eff_url, '/')[2]);

		if (r.ec == '0') {
			if (length(r.cp) && r.cp != r.probe_host) {
				r.result = sprintf("net cp '%s'", r.cp);
			}
			else if (r.rc == '200' || r.rc == '204') {
				let lines = split(html_raw, '\n');

				r.html = redirect(lines, 'http-equiv=', /^.*<meta[ \t]+http-equiv=['"]*refresh.*[ \t;]url=/);
				r.js = redirect(lines, 'location.href=', /^.*location\.href=['"]*/);

				if (length(r.html))
					r.result = sprintf("net cp '%s'", r.html);
				else if (length(r.js))
					r.result = sprintf("net cp '%s'", r.js);
				else
					r.result = 'net ok';
			}
		}
		else {
			r.err = (type(meta) == 'object' && type(meta.errormsg) == 'string') ? meta.errormsg : '';

			let ed = err_domain(r.err);

			if (r.ec == '6') {
				if (length(ed) && ed != r.probe_host)
					r.result = sprintf("net cp '%s'", ed);
			}
			else if (length(r.cp) && r.cp != r.probe_host) {
				r.result = sprintf("net cp '%s'", r.cp);
			}
		}
	}

	// without captive portal handling a detected portal is a dead end
	if (substr(r.result, 0, 6) == 'net cp' && !captive)
		r.result = 'net nok';

	let m = match(r.result, /^net cp '(.*)'$/);

	r.net = m ? 'cp' : substr(r.result, 4);
	// the portal host, as far as it consists of host name or address
	// characters; it is logged and, if a dns name, allowlisted
	r.domain = m ? match(m[1], /^[]a-z0-9._:[-]*/)[0] : '';

	return r;
};


// the debug fields of the net check
export function debug(r) {
	let d = (v) => length(v) ? v : '-';

	return sprintf('cp (url/html/js): %s/%s/%s, result: %s, error (rc/msg): %s/%s, probe_host: %s, eff_url: %s',
		d(r.cp), d(r.html), d(r.js), r.result, r.ec, d(r.err), d(r.probe_host), d(r.eff_url));
};
