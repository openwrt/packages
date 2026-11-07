// travelmate - uplink scan: ranks an iwinfo scan reply, one entry per
// BSS, for the connection loop and the LuCI scan file

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

const WPA = { '1': 'WPA1', '2': 'WPA2', '3': 'WPA3' };

// Drop control octets (awk [[:cntrl:]] under LC_ALL=C) bytewise: an ssid is
// arbitrary octets, and libc regex may refuse input that is not valid UTF-8.
function clean_ssid(s) {
	let out = '';

	for (let i = 0; i < length(s); i++) {
		let c = ord(s, i);

		if (c >= 32 && c != 127)
			out += substr(s, i, 1);
	}

	return trim(out, ' ');
}

// -100 dBm = 0 %, -50 dBm = 100 %
export function quality(signal) {
	if (type(signal) != 'int')
		return 0;

	let q = 2 * (signal + 100);

	return q > 100 ? 100 : (q < 0 ? 0 : q);
}

// rpcd sends no 'wpa' array for WEP, only enabled plus 'wep'. Report it as
// such, otherwise the connection loop sees an open network.
function versions(enc) {
	let out = [];

	for (let n in (enc.wpa ?? []))
		if (WPA[n])
			push(out, WPA[n]);

	if (!length(out) && enc.enabled)
		return 'WEP';

	return length(out) ? join('+', out) : '-';
}

function words(list) {
	let out = [];

	for (let w in (list ?? []))
		if (length('' + w))
			push(out, uc('' + w));

	return length(out) ? join('+', out) : '-';
}

// quoted form used in scan lines and debug output
export function quote(s) {
	return '"' + join('\\"', split(s, '"')) + '"';
};

export function entry(r) {
	let enc = r?.encryption ?? {};
	let ssid = clean_ssid('' + (r?.ssid ?? ''));

	return {
		raw: ssid,
		quality: quality(r?.signal),
		channel: r?.channel ?? 0,
		bssid: length(r?.bssid ?? '') ? uc(r.bssid) : '-',
		wpa: versions(enc),
		cipher: words(enc.ciphers),
		auth: words(enc.authentication),
		ssid: length(ssid) ? quote(ssid) : 'hidden',
		hidden: !length(ssid),
		open: !enc.enabled,
		enc
	};
};

// the fields the connection loop compares, 'quality rsn wpa bssid essid',
// where rsn and wpa both '-' means open; also the sort key for ties
export function format(e) {
	return sprintf('%d %s - %s %s', e.quality, e.wpa, e.bssid, e.ssid);
};

// Same order as 'sort -rn' on the formatted lines: quality descending, ties
// by the whole line in reverse byte order (busybox and GNU fallback).
export function rank(results) {
	let rows = [];

	for (let r in (results ?? [])) {
		let e = entry(r);

		e.line = format(e);
		push(rows, e);
	}

	sort(rows, (a, b) => (b.quality - a.quality) ||
		(a.line < b.line ? 1 : (a.line > b.line ? -1 : 0)));

	return rows;
};

function upper(list) {
	return map(filter(list ?? [], (w) => length('' + w)), (w) => uc('' + w));
}

// the scan file for LuCI, a JSON array in ranking order (a hidden ssid is ''
// with hidden: true, encrypted: false for an open network)
export function report(results) {
	return map(rank(results), (e) => ({
		quality: e.quality,
		channel: e.channel,
		bssid: (e.bssid == '-') ? '' : e.bssid,
		ssid: e.raw,
		hidden: !length(e.raw),
		encrypted: !!e.enc.enabled,
		wpa: map(filter(e.enc.wpa ?? [], (n) => n in [ 1, 2, 3 ]), (n) => +n),
		ciphers: upper(e.enc.ciphers),
		auth: upper(e.enc.authentication)
	}));
};
