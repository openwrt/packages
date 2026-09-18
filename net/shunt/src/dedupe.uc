// shunt - write suppression
//
// Remembers when each (set, address) element expires in the kernel so a
// repeated DNS answer does not rewrite an element that is still fresh.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export function create(entry_ttl) {
	let exp = {};

	// A write is due when it moves the expiry by at least half of the
	// lifetime it carries, in either direction: an answer with a long TTL
	// extends an element that has aged past half, a short one cuts an
	// element that poll or an earlier answer left long. Anything closer is
	// a rewrite the kernel would not notice.
	function due(set, addr, now, ttl) {
		let k = `${set}/${addr}`;
		let t = ttl ?? entry_ttl;
		let e = now + t;
		let cur = exp[k];
		let d = (cur == null) ? t : (e > cur) ? e - cur : cur - e;

		if (d * 2 < t)
			return false;

		exp[k] = e;
		return true;
	}

	function prune(now) {
		let n = 0;

		for (let k in exp) {
			if (now >= exp[k]) {
				delete exp[k];
				n++;
			}
		}

		return n;
	}

	// Dropped wholesale when the table had to be re-created: the kernel has
	// no elements any more, so every pair is due again regardless of age.
	function reset() {
		exp = {};
	}

	function size() {
		return length(keys(exp));
	}

	return { due, prune, reset, size };
};
