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

const BLOCK_METRIC = 9999;

// Kernel ABI, from linux/rtnetlink.h and linux/fib_rules.h. Fixed for as
// long as netlink exists, so a literal here costs nothing and keeps the
// renderer importable without ucode-mod-rtnl.
const AF = { '4': 2, '6': 10 };
const ANY = { '4': '0.0.0.0/0', '6': '::/0' };
const RTN_UNICAST = 1;
const RTN_LOCAL = 2;
const RTN_PROHIBIT = 8;
const RTPROT_BOOT = 3;
const RT_SCOPE_UNIVERSE = 0;
const RT_SCOPE_LINK = 253;
const RT_SCOPE_HOST = 254;
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

// `ip route replace default [via gw] dev iface table n`: a gateway makes it a
// global-scope route, without one it is the point to point form with link
// scope, as ip renders it.
function default_route(fam, table, iface, gw) {
	let route = { family: AF[fam], table, dst: ANY[fam], oif: iface,
		type: RTN_UNICAST, protocol: RTPROT_BOOT,
		scope: gw ? RT_SCOPE_UNIVERSE : RT_SCOPE_LINK };

	if (gw)
		route.gateway = gw;

	return route;
}

export function compile(policies, marks, opts) {
	let mask = opts?.mask ?? DEFAULTS.mask;
	// Without the IPv6 family the kernel refuses every IPv6 operation, so
	// none is rendered; the nft side loads either way.
	let fams = (opts?.ipv6 === false) ? [ '4' ] : [ '4', '6' ];
	let add = [], del = [], tables = [], issues = [];

	// A tracked device gets a probe table with the default route of its first
	// policy, and a rule that leads the device's probe mark there. It is
	// never withdrawn, so the probes still leave through the device while
	// its policies treat it as dead.
	let probe_of = {}, probed = {};

	for (let pr in (opts?.probes ?? []))
		probe_of[pr.dev] = pr;

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

		// tproxy delivers to a socket on the router, so its table holds a
		// single local default route and nothing of the interface options
		// applies. keep_local in particular must not: main would forward
		// a packet the tproxy statement has already given a socket, and
		// the kernel drops those on forward - measured. The fallback is
		// nft's, see there.
		if (m.action == 'tproxy') {
			if (to_bool(p.keep_local, false) === true)
				reject(p.name, p.keep_local, 'keep_local does not apply to tproxy, ignored');

			push(tables, sprintf('%d\tshunt_%s', m.rt_table, m.name));

			for (let fam in fams) {
				let family = AF[fam];

				push(add, { cmd: 'newroute', msg: { family,
					table: m.rt_table, dst: ANY[fam], oif: 'lo',
					type: RTN_LOCAL, protocol: RTPROT_BOOT,
					scope: RT_SCOPE_HOST } });

				push(add, { cmd: 'newrule', msg: { family,
					action: FR_ACT_TO_TBL, priority: m.rt_prio,
					fwmark: m.mark, fwmask: mask, table: m.rt_table } });

				unshift(del, { cmd: 'flush', msg: { family, table: m.rt_table } });
				unshift(del, { cmd: 'delrule', msg: { family, priority: m.rt_prio } });
				unshift(del, { cmd: 'delrule', msg: { family, priority: m.rt_prio_local } });
			}
			continue;
		}

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

		let pr = probe_of[iface];

		if (pr && !probed[iface]) {
			probed[iface] = true;
			push(tables, sprintf('%d\tshunt_track_%s', pr.rt_table, iface));

			for (let fam in fams) {
				push(add, { cmd: 'newroute',
					msg: default_route(fam, pr.rt_table, iface, gw[fam]) });
				push(add, { cmd: 'newrule', msg: { family: AF[fam],
					action: FR_ACT_TO_TBL, priority: pr.rt_prio,
					fwmark: pr.mark, fwmask: mask, table: pr.rt_table } });

				unshift(del, { cmd: 'flush', msg: { family: AF[fam], table: pr.rt_table } });
				unshift(del, { cmd: 'delrule', msg: { family: AF[fam], priority: pr.rt_prio } });
			}
		}

		// A dead device is handled as one whose link went down: its policy
		// table loses the default route, and the fallback below it - main
		// or the prohibit route - takes over.
		let dead = !!opts?.dead?.[iface];

		for (let fam in fams) {
			let family = AF[fam];

			if (!dead)
				push(add, { cmd: 'newroute',
					msg: default_route(fam, table, iface, gw[fam]) });

			if (fb == 'block')
				push(add, { cmd: 'newroute', msg: { family, table,
					dst: ANY[fam], type: RTN_PROHIBIT,
					protocol: RTPROT_BOOT, scope: RT_SCOPE_UNIVERSE,
					priority: BLOCK_METRIC } });

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

// What a device changing state needs and nothing more: the default route of
// each of its route policies added back or taken out. Gateways and checks
// as compile() has them, so the two always render the same route.
export function state_ops(policies, marks, opts, dev) {
	let r = compile(policies, marks, { ...opts, dead: { ...opts?.dead, [dev]: false } });
	let ops = [];

	for (let op in r.add) {
		let m = op.msg;

		if (op.cmd != 'newroute' || m.type != RTN_UNICAST || m.oif != dev ||
		    m.table >= 8500)
			continue;

		push(ops, opts?.dead?.[dev] ? { cmd: 'delroute', msg: m } : op);
	}

	return ops;
};
