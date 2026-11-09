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
	// a rewrite the kernel would not notice. A due write reports whether
	// the pair is unknown or already past its expiry ('new' - prune runs
	// only once per poll cycle, so a lapsed pair can still be on record) or
	// only moves an expiry that is still running ('move'); the caller
	// writes the first kind without waiting.
	function due(set, addr, now, ttl) {
		let k = `${set}/${addr}`;
		let t = ttl ?? entry_ttl;
		let e = now + t;
		let cur = exp[k];
		let d = (cur == null) ? t : (e > cur) ? e - cur : cur - e;

		if (d * 2 < t)
			return false;

		exp[k] = e;
		return (cur == null || cur <= now) ? 'new' : 'move';
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

	// Every pair still running, with its absolute expiry - what the kernel
	// holds, as far as shunt wrote it. The key is `set/addr`; neither part
	// can contain a slash.
	function dump(now) {
		let out = [];

		for (let k, e in exp) {
			if (e <= now)
				continue;

			let i = index(k, '/');
			push(out, { set: substr(k, 0, i), addr: substr(k, i + 1), exp: e });
		}

		return out;
	}

	function size() {
		return length(keys(exp));
	}

	return { due, prune, reset, dump, size };
};
