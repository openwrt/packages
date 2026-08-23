// shunt - ip rule and route renderer
//
// Renders the argv arrays for the policy routing tables and their rules.
// Pure, like nft.uc - nothing here talks to the kernel.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { addr_family, DEFAULTS } from 'shunt.nft';

const RE_IFACE = /^[A-Za-z0-9_][A-Za-z0-9_.-]{0,14}$/;

const BLACKHOLE_METRIC = 9999;

export function compile(policies, marks, opts) {
	let mask = opts?.mask ?? DEFAULTS.mask;
	let add = [], del = [], tables = [], issues = [];

	let by_name = {};
	for (let m in (marks ?? []))
		by_name[m.name] = m;

	function reject(policy, entry, reason) {
		push(issues, { policy, entry, reason });
	}

	for (let p in (policies ?? [])) {
		let m = by_name[p?.name];
		if (!m)
			continue;

		let iface = p.interface;
		if (type(iface) != 'string' || match(iface, RE_IFACE) == null) {
			reject(p.name, iface, 'invalid or missing interface');
			continue;
		}

		let fb = p.fallback ?? 'main';
		if (fb != 'main' && fb != 'block') {
			reject(p.name, p.fallback, "fallback must be 'main' or 'block'");
			continue;
		}

		let gw = { '4': null, '6': null };
		let gw_bad = false;

		for (let fam in [ '4', '6' ]) {
			let g = p[`gw${fam}`];
			if (g == null)
				continue;
			if (sprintf('%d', addr_family(g)) == fam && index(g, '/') < 0)
				gw[fam] = g;
			else {
				reject(p.name, g, `invalid gw${fam}`);
				gw_bad = true;
			}
		}

		if (gw_bad)
			continue;

		let fwmark = sprintf('0x%x/0x%x', m.mark, mask);
		let table = sprintf('%d', m.rt_table);
		let pref = sprintf('%d', m.rt_prio);

		push(tables, sprintf('%d\tshunt_%s', m.rt_table, m.name));

		for (let fam in [ '4', '6' ]) {
			let v = `-${fam}`;

			let route = [ 'ip', v, 'route', 'replace', 'default' ];
			if (gw[fam])
				push(route, 'via', gw[fam]);
			push(route, 'dev', iface, 'table', table);
			push(add, route);

			if (fb == 'block')
				push(add, [ 'ip', v, 'route', 'replace', 'blackhole',
					'default', 'metric',
					sprintf('%d', BLACKHOLE_METRIC),
					'table', table ]);

			push(add, [ 'ip', v, 'rule', 'add', 'pref', pref,
				'fwmark', fwmark, 'lookup', table ]);

			unshift(del, [ 'ip', v, 'route', 'flush', 'table', table ]);
			unshift(del, [ 'ip', v, 'rule', 'del', 'pref', pref ]);
		}
	}

	return {
		add,
		del,
		rt_tables: length(tables) ? join('\n', tables) + '\n' : '',
		issues
	};
};
