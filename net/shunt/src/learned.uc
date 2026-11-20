// shunt - learned addresses across a restart
//
// The learned sets live in shunt's own table, and every start destroys and
// re-creates that table, so a reload would forget everything snoop picked
// up and route those destinations over the normal uplink until a client asks
// again. On the way out the daemon writes what it still holds to tmpfs, the
// next start writes it back.
//
// An entry comes back only into the same set, with the time it has left,
// and only if the policy's domain selectors are unchanged: a policy that now
// names other domains must not inherit the addresses of the old ones. The
// selectors are compared as configured - `domain` and the `domain_file`
// names, not the file contents - which matches `shunt refresh`, where a
// changed file keeps the learned addresses too.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { readfile, writefile, rename, unlink } from 'fs';
import { set_name } from 'shunt.nft';

export const PATH = '/var/run/shunt.learned';

// 2: expiries on CLOCK_MONOTONIC instead of the wall clock. A file of
// another format is dropped without a word: it can only be left over from
// the previous package version, one restart ago.
const FORMAT = 2;

// Selector fingerprint per learned set name.
export function fingerprints(policies, learn) {
	let out = {};

	for (let p in (policies ?? [])) {
		let fp = sprintf('%J', [ sort([ ...(p?.domains ?? []) ]),
			sort([ ...(p?.domain_files ?? []) ]) ]);

		for (let fam in [ 4, 6 ]) {
			let s = set_name('d', fam, p?.name);

			if (learn?.[s])
				out[s] = fp;
		}
	}

	return out;
};

// entries: [ { set, addr, exp } ], exp in CLOCK_MONOTONIC seconds - valid
// within one boot, and the file in tmpfs does not outlive it either.
export function save(path, entries, fps) {
	let tmp = `${path}.tmp`;
	let data = sprintf('%J', { format: FORMAT, fps, entries });

	if (!writefile(tmp, data))
		return false;
	if (!rename(tmp, path)) {
		unlink(tmp);
		return false;
	}

	return true;
};

// Reads and removes the file - it is good for exactly one start. Returns
// the writes to queue, each with the lifetime it has left, and the number
// of entries dropped because their policy is gone or changed.
export function load(path, fps, now) {
	let raw = readfile(path);

	if (raw == null)
		return null;

	unlink(path);

	let d;

	try {
		d = json(raw);
	}
	catch (e) {
		return { writes: [], dropped: 0, bad: true };
	}

	if (type(d) != 'object' || type(d.entries) != 'array')
		return { writes: [], dropped: 0, bad: true };

	if (d.format != FORMAT)
		return { writes: [], dropped: 0, bad: false };

	let writes = [], dropped = 0;

	for (let e in d.entries) {
		let left = (type(e?.exp) == 'int') ? e.exp - now : 0;

		if (left <= 0)
			continue;

		let fp = fps[e.set];

		if (fp == null || fp != d.fps?.[e.set]) {
			dropped++;
			continue;
		}

		push(writes, { set: e.set, addr: e.addr, ttl: left, kept: true });
	}

	return { writes, dropped, bad: false };
};
