// shunt - interface resolution
//
// Turns each configured interface of a policy into its device, gateways and
// link state from a netifd dump. Explicit config values always win.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

function nexthop(entry, fam) {
	let dflt = (fam == 4) ? '0.0.0.0' : '::';

	for (let r in (entry?.route ?? [])) {
		if (r?.target == dflt && r?.mask == 0 && length(r?.nexthop ?? '') && r.nexthop != dflt)
			return r.nexthop;
	}

	return null;
}

// One configured name. A logical interface resolves to its l3_device and is
// up as netifd says; a raw netdev netifd knows is adopted and up with its
// interface; anything netifd knows nothing about passes through as given,
// with its state unknown. A logical interface without a device yet passes
// its name through, so its routes fail as they always did, and `up` says
// why.
function member(name, entries) {
	let device = null, up = null;

	for (let e in entries)
		if (e?.interface == name) {
			if (length(e.l3_device ?? ''))
				device = e.l3_device;
			up = !!e.up && device != null;
			break;
		}

	if (device == null && up == null)
		for (let e in entries)
			if (e?.l3_device == name) {
				device = name;
				up = !!e.up;
				break;
			}

	let gw4 = null, gw6 = null;

	if (device != null)
		for (let e in entries) {
			if (e?.l3_device != device)
				continue;

			gw4 ??= nexthop(e, 4);
			gw6 ??= nexthop(e, 6);
		}

	return { name, dev: device ?? name, gw4, gw6, up };
}

export function resolve(policies, dump) {
	let entries = dump?.interface ?? [];
	let out = [];

	for (let p in (policies ?? [])) {
		let names = p?.interfaces ?? ((p?.interface != null) ? [ p.interface ] : []);
		let members = map(names, (n) => member(n, entries));

		// Gateway overrides belong to a single interface; with several the
		// route renderer reports them and they are not applied.
		if (length(members) == 1) {
			members[0].gw4 = p.gw4 ?? members[0].gw4;
			members[0].gw6 = p.gw6 ?? members[0].gw6;
		}

		let first = members[0];

		push(out, {
			...p,
			members,
			interface: first?.dev,
			gw4: (length(members) == 1) ? first.gw4 : p.gw4,
			gw6: (length(members) == 1) ? first.gw6 : p.gw6
		});
	}

	return out;
};
