// shunt - write suppression
//
// Remembers when each (set, address) element expires in the kernel so a
// repeated DNS answer does not rewrite an element that is still fresh.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

// `limit` is how many pairs one set may have on record - the global option
// learn_limit. Nothing a network asks for should come near it; it is there
// because snoop cannot tell a DNS answer from a frame made to look like one,
// and without a bound a host on an observed segment could grow the sets, and
// this table with them, until the router is out of memory. Counted per set,
// so that filling one leaves every other policy, and the other address
// family of the same one, learning as before.
//
// The kernel keeps an element a little past the lifetime on record - the
// slack the daemon puts on every timeout, see written(). A lapsed pair keeps
// its place in the count until the kernel has dropped it too: freed at the
// lifetime, the place would go to a new address while the kernel still
// holds the old one, and a set under a steady flood would hold up to twice
// the limit.
export function create(entry_ttl, limit) {
	let exp = {}, gone = {}, count = {}, total = 0, pruned = null;

	// The key is `set/addr`; neither part can contain a slash.
	function set_of(k) {
		return substr(k, 0, index(k, '/'));
	}

	function drop(k) {
		let set = set_of(k);

		delete exp[k];
		delete gone[k];
		total--;

		if (--count[set] <= 0)
			delete count[set];
	}

	function prune(now) {
		let n = 0;

		for (let k in exp) {
			if (now >= (gone[k] ?? exp[k])) {
				drop(k);
				n++;
			}
		}

		return n;
	}

	// A write is due when it moves the expiry by at least half of the
	// lifetime it carries, in either direction: an answer with a long TTL
	// extends an element that has aged past half, a short one cuts an
	// element that poll or an earlier answer left long. Anything closer is
	// a rewrite the kernel would not notice. A due write reports whether
	// the pair is unknown or already past its expiry ('new' - prune runs
	// only once per poll cycle, so a lapsed pair can still be on record) or
	// only moves an expiry that is still running ('move'); the caller
	// writes the first kind without waiting. With its set at the limit an
	// unknown pair is 'full' and not recorded; the lapsed pairs are cleared
	// out first, at most once a second, since prune otherwise runs once per
	// poll cycle.
	function due(set, addr, now, ttl) {
		let k = `${set}/${addr}`;
		let t = ttl ?? entry_ttl;
		let e = now + t;
		let cur = exp[k];
		let d = (cur == null) ? t : (e > cur) ? e - cur : cur - e;

		if (d * 2 < t)
			return false;

		if (cur == null) {
			if (limit && count[set] >= limit && pruned !== now) {
				pruned = now;
				prune(now);
			}

			if (limit && count[set] >= limit)
				return 'full';

			count[set] = (count[set] ?? 0) + 1;
			total++;
		}

		exp[k] = e;
		return (cur == null || cur <= now) ? 'new' : 'move';
	}

	// A pair the kernel took, with the slack its timeout got on top of the
	// lifetime: it is in the kernel until then, and counted until then.
	function written(set, addr, slack) {
		let k = `${set}/${addr}`;

		if (exp[k] != null)
			gone[k] = exp[k] + slack;
	}

	// A pair whose write the kernel did not take: off the record, so the
	// next answer for it is due again.
	function forget(set, addr) {
		let k = `${set}/${addr}`;

		if (exp[k] != null)
			drop(k);
	}

	// Dropped wholesale when the table had to be re-created: the kernel has
	// no elements any more, so every pair is due again regardless of age.
	function reset() {
		exp = {};
		gone = {};
		count = {};
		total = 0;
	}

	// Every pair still running, with its absolute expiry - what the kernel
	// holds, as far as shunt wrote it.
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
		return total;
	}

	return { due, prune, written, forget, reset, dump, size };
};
