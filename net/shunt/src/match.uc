// shunt - domain matcher
//
// Compiles the policies' domain patterns into an exact and a wildcard map
// and answers which policies claim a queried name.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export const LIM = {
	name: 253,
	label: 63
};

function ok_label(s) {
	if (!length(s) || length(s) > LIM.label)
		return false;

	for (let i = 0; i < length(s); i++) {
		let c = ord(s, i);
		if ((c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39) ||
			c == 0x2d || c == 0x5f)
			continue;
		return false;
	}

	return true;
}

export function normalize(s) {
	s = lc(trim(s ?? ''));

	while (length(s) && substr(s, -1) == '.')
		s = substr(s, 0, length(s) - 1);

	return s;
};

function validate(name) {
	if (!length(name))
		return 'empty';
	if (length(name) > LIM.name)
		return 'too long';

	for (let l in split(name, '.'))
		if (!ok_label(l))
			return `bad label '${l}'`;

	return null;
}

export function compile(policies) {
	let exact = {}, wild = {}, issues = [];

	function reject(policy, pattern, reason) {
		push(issues, { policy, pattern, reason });
	}

	for (let pi = 0; pi < length(policies ?? []); pi++) {
		let p = policies[pi];
		let pname = p?.name ?? `#${pi}`;

		for (let raw in (p?.domains ?? [])) {
			let pat = normalize(raw);
			let is_wild = false;

			if (substr(pat, 0, 2) == '*.') {
				is_wild = true;
				pat = substr(pat, 2);
			}

			if (index(pat, '*') >= 0) {
				reject(pname, raw, 'wildcard only allowed as leading *. label');
				continue;
			}

			let bad = validate(pat);
			if (bad) {
				reject(pname, raw, bad);
				continue;
			}

			let map = is_wild ? wild : exact;

			if (!map[pat])
				map[pat] = [];

			let dup = false;

			for (let owner in map[pat])
				if (owner == pname)
					dup = true;

			if (!dup)
				push(map[pat], pname);
		}
	}

	// A list even for one element - a caller that has to distinguish shapes
	// gets it wrong exactly once, in the rare case, in production.
	function test(qname) {
		let q = normalize(qname);

		if (!length(q) || length(q) > LIM.name)
			return null;

		if (exists(exact, q))
			return exact[q];

		let off = index(q, '.');

		while (off >= 0) {
			let sfx = substr(q, off + 1);

			if (exists(wild, sfx))
				return wild[sfx];

			let nxt = index(sfx, '.');
			off = (nxt < 0) ? -1 : off + 1 + nxt;
		}

		return null;
	}

	return {
		test,
		issues,
		size: { exact: length(keys(exact)), wild: length(keys(wild)) }
	};
};
