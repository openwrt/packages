// travelmate - vpn handling decisions: plan() returns the steps for an action
// (op: down, clear, rc, pgm), infolist() the usable vpn interfaces

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

// netifd protocols that are vpn interfaces without further notice
const VPN_PROTOS = [ 'wireguard', 'openvpn' ];

// the vpn service of a network interface section, its netifd protocol
export function service(s) {
	return '' + (s?.proto ?? '');
};

// st: { vpn, list, action, connection, connected, ntp }, up: { vpn, iface,
// service } of the current uplink; returns { steps, pgm }
export function plan(st, up, is_up) {
	let out = [], connected = st.connected, action = st.action, pgm = false;

	if (!st.vpn || !length(st.list))
		return { steps: out, pgm };

	// initial cleanup: tear down all known vpn interfaces
	if (!connected || action == 'enable') {
		for (let iface in st.list)
			if (is_up(iface))
				push(out, { op: 'down', iface, why: 'initial' });

		push(out, { op: 'clear' });
		connected = false;
	}

	// switch: tear down a foreign vpn interface, keep the configured one
	else if (up.vpn && length(up.iface) && action == 'enable_keep') {
		for (let iface in st.list) {
			if (is_up(iface) && iface != up.iface) {
				push(out, { op: 'down', iface, why: 'switch' }, { op: 'rc' }, { op: 'clear' });
				connected = false;
				break;
			}
		}
	}

	// start or stop the vpn connection on valid enable/disable transitions
	if (length(up.service) && length(up.iface)) {
		let enable = (action == 'enable' || action == 'enable_keep');

		pgm = true;

		if ((action == 'disable' && connected) ||
		    (!up.vpn && enable && connected) ||
		    (st.ntp && up.vpn && enable && !connected)) {
			if (st.connection || action == 'disable')
				push(out, { op: 'pgm', action: up.vpn ? action : 'disable', iface: up.iface, service: up.service });
		}
	}

	return { steps: out, pgm };
};

// usable: all wireguard/openvpn interfaces and any other netifd protocol
// that is referenced (refs) or listed in trm_vpnifacelist
export function infolist(ifaces, filter_list, refs) {
	let list = [], logs = [];
	let dash = (v) => length(v ?? '') ? v : '-';

	for (let s in ifaces) {
		let iface = s['.name'], proto = service(s);

		if ((!length(filter_list) || iface in filter_list) && !(iface in list) &&
		    (proto in VPN_PROTOS || (length(proto) && proto != 'none' && (length(filter_list) || iface in (refs ?? [])))))
			push(list, iface);

		push(logs, sprintf('f_getvpn    ::: iface: %s, proto: %s, vpn_ifacelist: %s, vpn_infolist: %s',
			dash(iface), dash(proto), dash(join(' ', filter_list)), dash(join(' ', list))));
	}

	return { list, logs };
};
