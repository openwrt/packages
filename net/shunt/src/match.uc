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

// The regex is the fast path and says the same thing ok_label() does; the
// label walk runs only on failure, to name the offender. Measured on 100k
// patterns from a file: four times faster than walking every label.
const RE_NAME = /^[a-z0-9_-]{1,63}(\.[a-z0-9_-]{1,63})*$/;

function validate(name) {
	if (!length(name))
		return 'empty';
	if (length(name) > LIM.name)
		return 'too long';

	if (match(name, RE_NAME))
		return null;

	for (let l in split(name, '.'))
		if (!ok_label(l))
			return `bad label '${l}'`;

	return 'invalid';
}

// One pattern, checked the way compile() checks it: `{ pat, wild }` for a
// usable one, `{ error }` otherwise. Exported so a domain file is validated
// by the same rules as a `list domain` entry.
export function pattern(raw) {
	let pat = normalize(raw);
	let wild = false;

	if (substr(pat, 0, 2) == '*.') {
		wild = true;
		pat = substr(pat, 2);
	}

	if (index(pat, '*') >= 0)
		return { error: 'wildcard only allowed as leading *. label' };

	let bad = validate(pat);
	if (bad)
		return { error: bad };

	return { pat, wild };
};

export function compile(policies) {
	let exact = {}, wild = {}, issues = [];

	function reject(policy, pattern, reason) {
		push(issues, { policy, pattern, reason });
	}

	function insert(pname, pat, is_wild) {
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

	for (let pi = 0; pi < length(policies ?? []); pi++) {
		let p = policies[pi];
		let pname = p?.name ?? `#${pi}`;

		for (let raw in (p?.domains ?? [])) {
			let r = pattern(raw);

			if (r.error) {
				reject(pname, raw, r.error);
				continue;
			}

			insert(pname, r.pat, r.wild);
		}

		// file_domains arrive canonical from domain_file.uc - validated,
		// lower case, deduplicated - so they are not checked a second
		// time: with a list of a hundred thousand names that is the
		// difference between a start and a stall.
		for (let pat in (p?.file_domains ?? [])) {
			if (substr(pat, 0, 2) == '*.')
				insert(pname, substr(pat, 2), true);
			else
				insert(pname, pat, false);
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
