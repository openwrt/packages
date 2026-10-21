// travelmate - uplink lookup: maps a station (radio, essid, bssid) to its
// travelmate 'uplink' section by name and reads its options

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { normbssid } from 'travelmate.select';

// travelmate 'uplink' sections in config order
export function load(c) {
	let out = [];

	c.foreach('travelmate', 'uplink', (s) => push(out, s));

	return out;
};

// section name of the first uplink matching radio, essid and bssid, '' if
// none; radio and essid must be set, bssid compares case-normalized
export function ref(uplinks, radio, essid, bssid) {
	if (!length(radio) || !length(essid))
		return '';

	for (let u in uplinks)
		if (u.device == radio && u.ssid == essid && normbssid(u.bssid) == normbssid(bssid))
			return u['.name'];

	return '';
};

// option of the referenced uplink as string, dflt if there is no such
// uplink or the option is unset or empty
export function option(uplinks, name, opt, dflt) {
	if (length(name ?? ''))
		for (let u in uplinks)
			if (u['.name'] == name) {
				let v = u[opt];

				return (v == null || v == '') ? (dflt ?? '') : '' + v;
			}

	return dflt ?? '';
};
