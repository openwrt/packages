// travelmate - uplink state probe: wireless status, sta interface, signal
// quality and interface state for one polling round, queries only

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { quality } from 'travelmate.scan';

// first interface in sta mode, in the order netifd reports the radios
function sta_ifname(status) {
	for (let radio, r in status)
		for (let i in (r?.interfaces ?? []))
			if (i?.config?.mode == 'sta' && i?.ifname != null)
				return '' + i.ifname;

	return '';
}

// lazy, cached queries for one polling round, asked only as far as the
// decision gets; quality: int or null, up: bool or null
export function queries(conn, iface) {
	let status, name, up, asked = false;

	return {
		wireless: () => (status ??= conn?.call('network.wireless', 'status') ?? false) !== false,
		ifname: () => name ??= sta_ifname(status || {}),
		quality: (ifname) => {
			let signal = conn?.call('iwinfo', 'info', { device: ifname })?.signal;

			return (type(signal) == 'int' && signal >= -120) ? quality(signal) : null;
		},
		up: () => {
			if (!asked) {
				let v = conn?.call('network.interface.' + iface, 'status')?.up;

				up = (type(v) == 'bool') ? v : null;
				asked = true;
			}

			return up;
		}
	};
};

// all radios up and not pending, the idle cycle skips the wifi reload then
export function ready(conn, radios) {
	let status = conn?.call('network.wireless', 'status');

	for (let radio in radios)
		if ('' + status?.[radio]?.up != 'true' || '' + status?.[radio]?.pending != 'false')
			return false;

	return true;
};
