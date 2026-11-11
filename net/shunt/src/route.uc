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

// Whether a name can stand for one device under /proc/sys/net/ipv4/conf: an
// interface name and nothing else - no path that leads out of that directory,
// and not `all` or `default`, which are entries there but not devices, so
// that a policy naming one of them never changes the setting of every
// interface.
export function conf_dev(dev) {
	return type(dev) == 'string' && match(dev, RE_IFACE) != null &&
		dev != 'all' && dev != 'default';
};

// A rule is deleted by its priority and its mark, never by the priority
// alone: the kernel takes every attribute left out as a wildcard, and a rule
// of somebody else's that happens to sit on one of shunt's priorities is not
// shunt's to remove. Priority and mark are both derived from the policy's
// index, so every rule a released version ever added still matches.
function rule_del(family, priority, fwmark, fwmask) {
	return { cmd: 'delrule', msg: { family, priority, fwmark, fwmask } };
}

// What tells one route of a policy table from another: the kernel replaces a
// route of the same destination and metric in place, and every route shunt
// renders is a default route.
export function route_key(msg) {
	return sprintf('%d/%d/%d', msg?.family, msg?.table, msg?.priority ?? 0);
};

export function compile(policies, marks, opts) {
	let mask = opts?.mask ?? DEFAULTS.mask;
	// Without the IPv6 family the kernel refuses every IPv6 operation, so
	// none is rendered; the nft side loads either way.
	let fams = (opts?.ipv6 === false) ? [ '4' ] : [ '4', '6' ];
	let add = [], del = [], issues = [];

	// A tracked device gets a probe table with the default route of its first
	// policy, and a rule that leads the device's probe mark there. It is
	// never withdrawn, so the probes still leave through the device while
	// its policies treat it as dead.
	let probe_of = {}, probed = {};

	for (let pr in (opts?.probes ?? []))
		probe_of[pr.name] = pr;

	// A route policy with several interfaces has one entry for each.
	let by_name = {};
	for (let m in (marks ?? []))
		push(by_name[m.name] ??= [], m);

	function reject(policy, entry, reason) {
		push(issues, { policy, entry, reason });
	}

	for (let p in (policies ?? [])) {
		let m = by_name[p?.name]?.[0];
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
				unshift(del, rule_del(family, m.rt_prio, m.mark, mask));
				unshift(del, rule_del(family, m.rt_prio_local, m.mark, mask));
			}
			continue;
		}

		// Every interface of the policy, in order, each with the mark, table
		// and rules nft.uc numbered for it. A single one is the plain policy.
		let members = p.members ?? ((p.interface != null)
			? [ { name: p.interface, dev: p.interface } ] : []);
		let ms = filter(by_name[p.name], (e) => e.action == 'route');
		let many = length(members) > 1;

		if (!length(members)) {
			reject(p.name, p.interface, 'invalid or missing interface');
			continue;
		}

		let bad = false;

		for (let mb in members)
			if (type(mb.dev) != 'string' || match(mb.dev, RE_IFACE) == null) {
				reject(p.name, mb.dev ?? mb.name, 'invalid or missing interface');
				bad = true;
			}

		if (bad)
			continue;

		let fb = p.fallback ?? 'main';
		if (fb != 'main' && fb != 'block') {
			reject(p.name, p.fallback, "fallback must be 'main' or 'block'");
			continue;
		}

		// An override names the gateway of one interface. With several, each
		// takes the gateway netifd reports for it.
		let gw = { '4': null, '6': null };
		let gw_bad = false;

		if (many) {
			if (p.gw4 != null || p.gw6 != null)
				reject(p.name, p.gw4 ?? p.gw6,
					'gw4/gw6 apply to a single interface - ignored, the gateways come from netifd');
		}
		else
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

		for (let j = 0; j < length(members) && j < length(ms); j++) {
			let m = ms[j], mb = members[j];
			let iface = mb.dev, name = mb.name ?? mb.dev;
			let mgw = many ? { '4': mb.gw4, '6': mb.gw6 } : gw;
			let table = m.rt_table;

			let pr = probe_of[name];

			if (pr && !probed[name]) {
				probed[name] = true;

				for (let fam in fams) {
					push(add, { cmd: 'newroute',
						msg: default_route(fam, pr.rt_table, iface, mgw[fam]) });
					push(add, { cmd: 'newrule', msg: { family: AF[fam],
						action: FR_ACT_TO_TBL, priority: pr.rt_prio,
						fwmark: pr.mark, fwmask: mask, table: pr.rt_table } });

					unshift(del, { cmd: 'flush', msg: { family: AF[fam], table: pr.rt_table } });
					unshift(del, rule_del(AF[fam], pr.rt_prio, pr.mark, mask));
				}
			}

			// A dead interface is handled as one whose link went down: its
			// table loses the default route, and the fallback below it - main
			// or the prohibit route - takes over for the flows marked for it.
			let dead = !!opts?.dead?.[name];

			for (let fam in fams) {
				let family = AF[fam];

				if (!dead)
					push(add, { cmd: 'newroute', name,
						msg: default_route(fam, table, iface, mgw[fam]) });

				if (fb == 'block')
					push(add, { cmd: 'newroute', msg: { family, table,
						dst: ANY[fam], type: RTN_PROHIBIT,
						protocol: RTPROT_BOOT, scope: RT_SCOPE_UNIVERSE,
						priority: BLOCK_METRIC } });

				// Ahead of the policy rule and on the same mark: main is
				// consulted with its default route suppressed, so marked
				// traffic to anything main has a specific route for - every
				// attached subnet, every static route - keeps taking it, and
				// only what would have used the default route reaches the
				// policy table.
				if (keep)
					push(add, { cmd: 'newrule', msg: { family,
						action: FR_ACT_TO_TBL, priority: m.rt_prio_local,
						fwmark: m.mark, fwmask: mask, table: RT_TABLE_MAIN,
						suppress_prefixlen: 0 } });

				push(add, { cmd: 'newrule', msg: { family,
					action: FR_ACT_TO_TBL, priority: m.rt_prio,
					fwmark: m.mark, fwmask: mask, table } });

				unshift(del, { cmd: 'flush', msg: { family, table } });
				unshift(del, rule_del(family, m.rt_prio, m.mark, mask));
				// Deleted whether or not it is rendered now: keep_local may
				// have been on when the running ruleset was applied.
				unshift(del, rule_del(family, m.rt_prio_local, m.mark, mask));
			}
		}
	}

	return {
		add,
		del,
		issues
	};
};

// What an interface changing state needs and nothing more: the default
// route of each of its policies' tables added back or taken out. Gateways
// and checks as compile() has them, so the two always render the same route.
export function state_ops(policies, marks, opts, name) {
	let r = compile(policies, marks, { ...opts, dead: { ...opts?.dead, [name]: false } });
	let ops = [];

	for (let op in r.add)
		if (op.name == name)
			push(ops, opts?.dead?.[name]
				? { cmd: 'delroute', msg: op.msg }
				: { cmd: op.cmd, msg: op.msg });

	return ops;
};

// What is left to remove once a new rendering has been applied on top of
// the old one. The new routes replace the old ones in place and the rules are
// the same ones again, so nothing has to go first - and nothing may: with the
// rules or a default route gone, even for the moment it takes to put them
// back, marked traffic takes the main table, a blocking policy leaks, and
// masquerade resets every running flow whose packet falls into that gap.
// Left over is only what the new rendering no longer has - the default route
// of an interface that is dead now - and an old route whose replacement the
// kernel refused: a wrong route is not better than the fallback.
export function stale(old_ops, new_ops, failed) {
	let routes = {}, rules = {}, ops = [];

	for (let op in (new_ops ?? [])) {
		if (op?.cmd == 'newroute')
			routes[route_key(op.msg)] = sprintf('%J', op.msg);
		else if (op?.cmd == 'newrule')
			rules[sprintf('%J', op.msg)] = true;
	}

	for (let op in (old_ops ?? [])) {
		if (op?.cmd == 'newroute') {
			let k = route_key(op.msg);

			if (routes[k] == null ||
			    (failed?.[k] && routes[k] != sprintf('%J', op.msg)))
				push(ops, { cmd: 'delroute', msg: op.msg });
		}
		else if (op?.cmd == 'newrule' && !rules[sprintf('%J', op.msg)])
			push(ops, { cmd: 'delrule', msg: op.msg });
	}

	return ops;
};
