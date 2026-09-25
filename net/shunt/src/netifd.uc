// shunt - interface resolution
//
// Turns a configured interface name into its device and gateways from a
// netifd dump. Explicit config values always win.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

function nexthop(entry, fam) {
	let dflt = (fam == 4) ? '0.0.0.0' : '::';

	for (let r in (entry?.route ?? []))
		if (r?.target == dflt && r?.mask == 0 && length(r?.nexthop ?? ''))
			return r.nexthop;

	return null;
}

export function resolve(policies, dump) {
	let entries = dump?.interface ?? [];
	let out = [];

	for (let p in (policies ?? [])) {
		let device = null;

		for (let e in entries) {
			if (e?.interface == p?.interface && length(e?.l3_device ?? '')) {
				device = e.l3_device;
				break;
			}
		}

		if (device == null)
			for (let e in entries)
				if (e?.l3_device == p?.interface) {
					device = p.interface;
					break;
				}

		if (device == null) {
			push(out, p);
			continue;
		}

		let gw4 = null, gw6 = null;

		for (let e in entries) {
			if (e?.l3_device != device)
				continue;

			gw4 ??= nexthop(e, 4);
			gw6 ??= nexthop(e, 6);
		}

		push(out, {
			...p,
			interface: device,
			gw4: p.gw4 ?? gw4,
			gw6: p.gw6 ?? gw6
		});
	}

	return out;
};
