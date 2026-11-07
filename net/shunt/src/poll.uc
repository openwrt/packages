// shunt - active resolution
//
// Collects the resolvable names from the policies and turns query results
// into set writes, following CNAME chains from the queried name.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { normalize } from 'shunt.match';
import { set_name } from 'shunt.nft';

export function names(policies) {
	let seen = {}, out = [];

	for (let p in (policies ?? [])) {
		for (let raw in (p?.domains ?? [])) {
			let n = normalize(raw);

			if (!length(n) || index(n, '*') >= 0)
				continue;
			if (seen[n])
				continue;

			seen[n] = true;
			push(out, n);
		}
	}

	return out;
};

const CHAIN_MAX = 8;

// resolv keys records by their own owner name, so a CNAME answer hides the
// address under the canonical name. Walk from the name that was asked for.
export function addresses(by_name, name) {
	let seen = {};
	let cur = normalize(name);
	let a = [], aaaa = [];

	for (let hop = 0; hop < CHAIN_MAX; hop++) {
		if (!length(cur ?? '') || seen[cur])
			break;

		seen[cur] = true;

		let e = by_name[cur];
		if (!e)
			break;

		for (let v in (e.A ?? []))
			push(a, v);
		for (let v in (e.AAAA ?? []))
			push(aaaa, v);

		cur = normalize((e.CNAME ?? [])[0] ?? '');
	}

	return { a, aaaa };
};

export function index_results(results) {
	let by = {};

	for (let k in (results ?? {})) {
		let n = normalize(k);

		if (length(n))
			by[n] = results[k];
	}

	return by;
};

export function plan(results, matcher, names) {
	let writes = [];
	let by = index_results(results);

	for (let raw in (names ?? [])) {
		let name = normalize(raw);

		let policies = matcher.test(name);
		if (policies == null)
			continue;

		let got = addresses(by, name);

		for (let policy in policies) {
			for (let a in got.a)
				push(writes, { set: set_name('d', 4, policy), addr: a });

			for (let a in got.aaaa)
				push(writes, { set: set_name('d', 6, policy), addr: a });
		}
	}

	return writes;
};
