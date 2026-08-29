// shunt - write suppression
//
// Remembers which (set, address) pairs were written recently so a repeated
// DNS answer does not rewrite an element that is still fresh.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export function create(entry_ttl) {
	let last = {};

	function due(set, addr, now) {
		let k = `${set}/${addr}`;
		let t = last[k];

		if (t != null && (now - t) * 2 < entry_ttl)
			return false;

		last[k] = now;
		return true;
	}

	function prune(now) {
		let n = 0;

		for (let k in last) {
			if (now - last[k] >= entry_ttl) {
				delete last[k];
				n++;
			}
		}

		return n;
	}

	function size() {
		return length(keys(last));
	}

	return { due, prune, size };
};
