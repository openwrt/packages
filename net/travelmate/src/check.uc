// travelmate - uplink check decisions: init() resolves the uplink before the
// poll, round() returns the steps (op) of one polling round

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { ref as uplink_ref, option as uplink_option } from 'travelmate.uplink';

// st: { mode, status (bool), radio, essid, bssid, ifstatus, wifireload (bool) }
export function init(st, uplinks) {
	let uref = uplink_ref(uplinks, st.radio, st.essid, st.bssid);
	let enabled = true;

	if (st.mode != 'rev' && length(st.radio) && st.radio != '-' && length(st.essid) && st.essid != '-')
		enabled = uplink_option(uplinks, uref, 'enabled', '0') == '1';

	// wifi reload on disconnects (not initial/dev), on disabled-uplink dev
	// events or on idle dev events if requested by the main cycle
	let wifi = (st.mode != 'initial' && st.mode != 'dev' && !st.status) ||
		(st.mode == 'dev' && ((!st.status && st.wifireload) ||
			(st.ifstatus !== st.status && !enabled)));

	return { uplinkcfg: uref, enabled, wifi };
};

// drop the connection and settle the status
function drop(out, st, msg) {
	if (msg)
		push(out, { op: 'log', class: 'info', msg }, { op: 'vpn' });

	push(out, { op: 'conn' }, { op: 'ifstatus', value: st.status }, { op: 'genstatus' }, { op: 'break' });

	return out;
}

// st: { mode, status, enabled, ifstatus, connection, wait, maxwait,
// minquality, quality (of an earlier round), sta_id }, q: probe queries
export function round(st, q) {
	let out = [], mode = st.mode, sta_id = st.sta_id;

	if (q.wireless()) {
		// dev mode: persist a status change and end
		if (mode == 'dev') {
			if (st.ifstatus !== st.status)
				push(out, { op: 'ifstatus', value: st.status }, { op: 'genstatus' });

			if (!st.status)
				push(out, { op: 'sleep', s: int(st.maxwait / 6) });

			push(out, { op: 'break' });

			return out;
		}

		// rev mode: drop the connection state and end
		if (mode == 'rev') {
			push(out, { op: 'conn' }, { op: 'ifstatus', value: st.status }, { op: 'break' });

			return out;
		}

		// initial/sta mode: look at the sta interface
		let ifname = q.ifname();

		if (length(ifname) && st.enabled) {
			let quality = q.quality(ifname) ?? st.quality;

			push(out, { op: 'probe', ifname, quality });

			// no signal: connection dropped or overall wait timeout
			if (quality == null) {
				let up = q.up();

				push(out, { op: 'ifstatus', value: up });

				if (st.connection && up === false)
					return drop(out, st, sprintf("no signal from uplink '%s'", sta_id));

				if (st.wait == st.maxwait)
					return drop(out, st, sprintf("uplink connection could not be established after %d seconds '%s'", st.maxwait, sta_id));

				push(out, { op: 'continue' });

				return out;
			}

			// acceptable signal: net/captive check once the interface is up
			if (quality >= st.minquality) {
				let up = q.up();

				push(out, { op: 'ifstatus', value: up });

				if (up === true) {
					push(out, { op: 'net' });

					return out;
				}
			}

			// signal below minquality on an existing link
			else if (st.connection && mode == 'initial') {
				return drop(out, st, sprintf("uplink is out of range '%s' (%d/%d)", sta_id, quality, st.minquality));
			}

			// signal below minquality on an initial/sta probe
			else if (mode == 'initial' || mode == 'sta') {
				return drop(out, st);
			}
		}
		else {
			push(out, { op: 'probe', ifname, quality: st.quality });

			// sta interface gone while connected
			if (st.connection)
				return drop(out, st, sprintf("uplink connection lost '%s' (interface gone)", sta_id));

			// initial probe, no sta interface yet
			if (mode == 'initial') {
				push(out, { op: 'ifstatus', value: st.status }, { op: 'genstatus' }, { op: 'break' });

				return out;
			}
		}
	}

	// initial mode safety net, also on an empty wireless status
	if (mode == 'initial') {
		if (st.connection)
			push(out, { op: 'log', class: 'info', msg: sprintf("uplink connection lost '%s' (interface down)", sta_id) },
				{ op: 'vpn' }, { op: 'conn' });

		push(out, { op: 'ifstatus', value: st.status }, { op: 'genstatus' }, { op: 'break' });
	}

	return out;
};
