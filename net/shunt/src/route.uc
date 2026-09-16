// shunt - rule and route renderer
//
// Renders the netlink operations for the policy routing tables and their
// rules, as rt.uc sends them. Pure, like nft.uc - nothing here talks to
// the kernel, which is why the handful of kernel constants it needs are
// spelled out below rather than read from the rtnl module.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { addr_family, DEFAULTS } from 'shunt.nft';

const RE_IFACE = /^[A-Za-z0-9_][A-Za-z0-9_.-]{0,14}$/;

const BLACKHOLE_METRIC = 9999;

// Kernel ABI, from linux/rtnetlink.h and linux/fib_rules.h. Fixed for as
// long as netlink exists, so a literal here costs nothing and keeps the
// renderer importable without ucode-mod-rtnl.
const AF = { '4': 2, '6': 10 };
const ANY = { '4': '0.0.0.0/0', '6': '::/0' };
const RTN_UNICAST = 1;
const RTN_BLACKHOLE = 6;
const RTPROT_BOOT = 3;
const RT_SCOPE_UNIVERSE = 0;
const RT_SCOPE_LINK = 253;
const RT_TABLE_MAIN = 254;
const FR_ACT_TO_TBL = 1;

// Policy options arrive as UCI strings - config.uc only collects them - so the
// one boolean among them is read here, with the rest of the routing checks.
function to_bool(v, dflt) {
	if (v == null || v == '')
		return dflt;
	if (v === true || v === false)
		return v;
	if (v == '1' || v == 1)
		return true;
	if (v == '0' || v == 0)
		return false;
	return null;
}

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

		// A bypass policy has no mark, so it has no table and no rule; the
		// nft chain returning is the whole of it. `interface` is not read.
		if (m.action == 'bypass')
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

		let keep = to_bool(p.keep_local, true);

		if (keep === null) {
			reject(p.name, p.keep_local, 'keep_local must be 0 or 1, default kept');
			keep = true;
		}

		let table = m.rt_table;

		push(tables, sprintf('%d\tshunt_%s', m.rt_table, m.name));

		for (let fam in [ '4', '6' ]) {
			let family = AF[fam];

			// `ip route replace default [via gw] dev iface table n`: a
			// gateway makes it a global-scope route, without one it is
			// the point to point form with link scope, as ip renders it.
			let route = { family, table, dst: ANY[fam], oif: iface,
				type: RTN_UNICAST, protocol: RTPROT_BOOT,
				scope: gw[fam] ? RT_SCOPE_UNIVERSE : RT_SCOPE_LINK };
			if (gw[fam])
				route.gateway = gw[fam];
			push(add, { cmd: 'newroute', msg: route });

			if (fb == 'block')
				push(add, { cmd: 'newroute', msg: { family, table,
					dst: ANY[fam], type: RTN_BLACKHOLE,
					protocol: RTPROT_BOOT, scope: RT_SCOPE_UNIVERSE,
					priority: BLACKHOLE_METRIC } });

			// Ahead of the policy rule and on the same mark: main is
			// consulted with its default route suppressed, so marked traffic
			// to anything main has a specific route for - every attached
			// subnet, every static route - keeps taking it, and only what
			// would have used the default route reaches the policy table.
			if (keep)
				push(add, { cmd: 'newrule', msg: { family,
					action: FR_ACT_TO_TBL, priority: m.rt_prio_local,
					fwmark: m.mark, fwmask: mask, table: RT_TABLE_MAIN,
					suppress_prefixlen: 0 } });

			push(add, { cmd: 'newrule', msg: { family,
				action: FR_ACT_TO_TBL, priority: m.rt_prio,
				fwmark: m.mark, fwmask: mask, table } });

			unshift(del, { cmd: 'flush', msg: { family, table } });
			unshift(del, { cmd: 'delrule', msg: { family, priority: m.rt_prio } });
			// Deleted whether or not it is rendered now: keep_local may have
			// been on when the running ruleset was applied.
			unshift(del, { cmd: 'delrule', msg: { family, priority: m.rt_prio_local } });
		}
	}

	return {
		add,
		del,
		rt_tables: length(tables) ? join('\n', tables) + '\n' : '',
		issues
	};
};
