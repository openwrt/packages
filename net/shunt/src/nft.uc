// shunt - nftables renderer
//
// Renders the whole ruleset: one table, two chains, per policy sets and
// marks. Pure string building, no kernel access.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export const TABLE = 'inet shunt';

// The mask must stay a contiguous block: shift, capacity and mark are all
// derived from it. That is why it is a constant and not a UCI option.
export const DEFAULTS = {
	mask: 0xff000000,
	entry_ttl: 1200
};

// What a policy does with the traffic it selects. `route` marks it for its
// own table, `bypass` only ends rule evaluation, so a later policy cannot
// claim the same packet, `tproxy` hands it to a transparent proxy listening
// on the router. Everything else is a configuration error.
export const ACTIONS = { route: true, bypass: true, tproxy: true };

// Where tproxy delivers. Without an address the kernel takes the primary
// address of the incoming interface, and a proxy bound to loopback - the
// usual way to keep it off the LAN - is then never found: the statement
// fails, and the rule with it. Loopback is found by a loopback listener and
// a wildcard one alike, whichever interface the packet came in on.
export const TPROXY_ADDR = { '4': '127.0.0.1', '6': '[::1]' };

const RE_NAME = /^[A-Za-z0-9_]{1,24}$/;
const RE_V4 = /^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})(\/([0-9]{1,2}))?$/;
const RE_V6 = /^[0-9A-Fa-f:]{2,45}(\/([0-9]{1,3}))?$/;

export function set_name(kind, family, policy) {
	return `${kind}${family}_${policy}`;
};

function valid_name(s) {
	return type(s) == 'string' && match(s, RE_NAME) != null;
}

export function mac_addr(s) {
	if (type(s) != 'string')
		return null;

	let m = trim(lc(s));

	return match(m, /^[0-9a-f]{2}(:[0-9a-f]{2}){5}$/) ? m : null;
};

// An ingress device as the kernel names it - at most IFNAMSIZ - 1 bytes,
// the same shape route.uc accepts for a policy interface. Matched by name,
// so a device that does not exist yet is not an error: its rule simply
// matches nothing until it appears.
export function dev_name(s) {
	if (type(s) != 'string')
		return null;

	let d = trim(s);

	return match(d, /^[A-Za-z0-9_][A-Za-z0-9_.-]{0,14}$/) ? d : null;
};

// A destination port or an inclusive range, normalised to nft syntax. Ports
// are 1-65535; 0 is reserved and never a destination.
export function port_spec(s) {
	let v = trim(`${s ?? ''}`);
	let m = match(v, /^([0-9]{1,5})(-([0-9]{1,5}))?$/);

	if (!m)
		return null;

	let lo = +m[1];
	let hi = m[3] != null ? +m[3] : lo;

	if (lo < 1 || hi > 65535 || lo > hi)
		return null;

	return lo == hi ? `${lo}` : `${lo}-${hi}`;
};

// tcp or udp only - nothing else carries a destination port, and naming a
// protocol that cannot be filtered by port is a configuration error worth
// reporting rather than silently rendering.
export function proto_name(s) {
	let v = lc(trim(`${s ?? ''}`));

	return (v == 'tcp' || v == 'udp') ? v : null;
};

export function addr_family(s) {
	if (type(s) != 'string')
		return null;

	let m = match(s, RE_V4);
	if (m) {
		for (let i = 1; i <= 4; i++)
			if (+m[i] > 255)
				return null;
		if (m[6] != null && +m[6] > 32)
			return null;
		return 4;
	}

	m = match(s, RE_V6);
	if (m) {
		let body = split(s, '/')[0];
		if (m[2] != null && +m[2] > 128)
			return null;
		if (index(body, ':::') >= 0)
			return null;
		if (length(split(body, '::')) > 2)
			return null;
		if (substr(body, 0, 1) == ':' && substr(body, 0, 2) != '::')
			return null;
		if (substr(body, -1) == ':' && substr(body, -2) != '::')
			return null;
		let groups = filter(split(body, ':'), (g) => g != '');
		if (length(groups) > 8 || (length(groups) == 8 && index(body, '::') >= 0))
			return null;
		for (let g in groups)
			if (length(g) > 4 || !match(g, /^[0-9A-Fa-f]+$/))
				return null;
		if (index(body, '::') < 0 && length(groups) != 8)
			return null;
		return 6;
	}

	return null;
};

export function action_name(s) {
	let v = lc(trim(`${s ?? ''}`));

	if (!length(v))
		return 'route';

	return ACTIONS[v] ? v : null;
};

function mask_shift(mask) {
	let n = 0;
	while (n < 32 && !((mask >> n) & 1))
		n++;
	return n;
}

export function compile(policies, opts) {
	let mask = opts?.mask ?? DEFAULTS.mask;
	let shift = mask_shift(mask);
	let capacity = mask >> shift;
	// Rule records, not strings: a MAC rule belongs in prerouting only, and
	// both chains must render from one ordered list or precedence breaks.
	let issues = [], marks = [], sets = [], rules4 = [], rules6 = [];
	let restore = [], restore_out = [], fill = [];
	let idx = 0;
	let learn = {};

	function reject(policy, entry, reason) {
		push(issues, { policy, entry, reason });
	}

	for (let pi = 0; pi < length(policies ?? []); pi++) {
		let p = policies[pi];
		let pname = p?.name;

		if (!valid_name(pname)) {
			reject(pname ?? `#${pi}`, null,
				'invalid policy name - must match [A-Za-z0-9_]{1,24}');
			continue;
		}

		let action = action_name(p.action);

		if (action == null) {
			reject(pname, p.action,
				"invalid action - 'route', 'bypass' or 'tproxy'");
			continue;
		}

		let tp_port = null, tp_block = false;

		if (action == 'tproxy') {
			// Checked here and not left to nft: the ruleset is one batch, and
			// a tproxy rule the kernel cannot load would take every other
			// policy down with it.
			if (opts?.tproxy === false) {
				reject(pname, null,
					'tproxy is not available in this kernel - install kmod-nft-tproxy, policy skipped');
				continue;
			}

			tp_port = port_spec(p.tproxy_port);

			if (tp_port == null || index(tp_port, '-') >= 0) {
				reject(pname, p.tproxy_port,
					'invalid or missing tproxy_port - expected 1-65535');
				continue;
			}

			// Applied anyway: only clients behind a bridge are hit, and the
			// switch is not shunt's to flip.
			if (length(opts?.br_netfilter))
				reject(pname, null, sprintf('%s at 1 - tproxy fails for clients behind a bridge, set to 0',
					join(' and ', opts.br_netfilter)));

			let fb = p.fallback ?? 'main';

			if (fb != 'main' && fb != 'block') {
				reject(pname, p.fallback, "fallback must be 'main' or 'block'");
				continue;
			}

			tp_block = (fb == 'block');
		}

		let src = { '4': [], '6': [] }, dst = { '4': [], '6': [] };

		for (let a in (p.src ?? [])) {
			let fam = addr_family(a);
			if (fam)
				push(src[sprintf('%d', fam)], a);
			else
				reject(pname, a, 'invalid src address');
		}

		for (let a in (p.dst ?? [])) {
			let fam = addr_family(a);
			if (fam)
				push(dst[sprintf('%d', fam)], a);
			else
				reject(pname, a, 'invalid dst address');
		}

		// Entries from a dst_file arrive validated from list_file.uc, so the
		// family is all that is left to tell - and a colon tells it.
		for (let a in (p.file_dst ?? []))
			push(dst[index(a, ':') >= 0 ? '6' : '4'], a);

		let macs = [], devs = [], seen_dev = {};

		for (let a in (p.src_mac ?? [])) {
			let m = mac_addr(a);
			if (m)
				push(macs, m);
			else
				reject(pname, a, 'invalid src_mac address');
		}

		for (let a in (p.src_dev ?? [])) {
			let d = dev_name(a);
			if (d == null)
				reject(pname, a, 'invalid src_dev - expected a device name');
			else if (!seen_dev[d]) {
				seen_dev[d] = true;
				push(devs, d);
			}
		}

		let ports = [], protos = [];

		for (let v in (p.dport ?? [])) {
			let q = port_spec(v);
			if (q)
				push(ports, q);
			else
				reject(pname, v, 'invalid dport - expected 1-65535 or a range');
		}

		for (let v in (p.proto ?? [])) {
			let q = proto_name(v);
			if (q)
				push(protos, q);
			else
				reject(pname, v, 'invalid proto - only tcp and udp carry ports');
		}

		// Whether the policy itself names protocols or ports. A blocking
		// tproxy policy that does not rejects everything it cannot proxy;
		// one that does keeps to what it names.
		let narrowed = length(protos) > 0 || length(ports) > 0;

		// A port with no protocol means both, as banIP does it: "port 443 of
		// this client" almost always includes QUIC, and requiring the
		// protocol would let it slip through unnoticed.
		if (length(ports) && !length(protos))
			protos = [ 'tcp', 'udp' ];

		// tproxy has nothing to hand over but tcp and udp, and the kernel
		// refuses the statement without the protocol pinned.
		if (action == 'tproxy' && !length(protos))
			protos = [ 'tcp', 'udp' ];

		// A named domain file counts as a domain selector whether or not it
		// was readable at this moment: the policy's sets exist and stay
		// empty until the file is, and `shunt flush` tears the policy down
		// without having to read anything.
		let has_dom = length(p.domains ?? []) + length(p.domain_files ?? []) > 0;

		// The same holds for an address file: its sets exist, empty until
		// the file is readable, and are refilled by `shunt refresh`.
		let has_dfile = length(p.dst_files ?? []) > 0;
		let has_dst_any = length(dst['4']) || length(dst['6']) || has_dfile;

		// Ports and protocols were asked for and none survived validation.
		// Rendering the policy anyway would drop the narrowing and mark
		// everything the client sends - the same widening a mistyped client
		// selector gets refused for.
		if (length(p.dport ?? []) + length(p.proto ?? []) > 0 &&
			!length(ports) && !length(protos)) {
			reject(pname, null,
				'no usable port or protocol - policy skipped rather than widened to all traffic');
			continue;
		}
		let has_ipsrc = length(src['4']) || length(src['6']);
		let has_mac = length(macs) > 0;
		let has_dev = length(devs) > 0;
		let has_src = has_ipsrc || has_mac || has_dev;

		// A port or a protocol is a selector of its own: `dport 25` alone
		// routes everybody's smtp. Only what the policy names counts here -
		// the protocols tproxy pins on its own select nothing.
		let has_any = has_src || has_dst_any || has_dom || narrowed;

		if (!has_any) {
			reject(pname, null, 'policy selects nothing');
			continue;
		}

		if (length(p.src ?? []) + length(p.src_mac ?? []) + length(p.src_dev ?? []) > 0 && !has_src) {
			reject(pname, null,
				'no usable client selector - policy skipped rather than widened to every client');
			continue;
		}

		// The same widening on the other side: destinations were asked for
		// and none survived, so the policy would cover every destination of
		// its clients. Domains still narrow it, their sets exist either way.
		if (length(p.dst ?? []) > 0 && !has_dst_any && !has_dom) {
			reject(pname, null,
				'no usable destination - policy skipped rather than widened to every destination');
			continue;
		}

		// A bypass policy owns no mark, no table and no rule - it only ends
		// evaluation - so it costs nothing from the mark capacity.
		if (action != 'bypass' && ++idx > capacity) {
			reject(pname, null,
				sprintf('mark capacity exceeded (%d policies fit in mask 0x%08x)',
					capacity, mask));
			continue;
		}

		let mark = (action != 'bypass') ? idx << shift : null;
		// One transport term for all three rule shapes. `th dport` reads the
		// port at the transport header offset, which works for tcp and udp
		// alike, so a port without a protocol needs no rule per protocol.
		let l4 = '', pt = '';

		if (length(ports))
			pt = length(ports) == 1
				? sprintf('th dport %s ', ports[0])
				: sprintf('th dport { %s } ', join(', ', ports));

		if (length(protos))
			l4 = length(protos) == 1
				? sprintf('meta l4proto %s ', protos[0])
				: sprintf('meta l4proto { %s } ', join(', ', protos));

		l4 += pt;

		// tproxy has no keep_local, so without this a client selector alone
		// would hand the proxy everything the client sends - DNS and LuCI on
		// the router itself, broadcast and multicast included - and with
		// fallback 'block' reject it while the proxy is down. Not proxied
		// means untouched: it is delivered or forwarded as it would be
		// without shunt. A forwarded unicast address still matches, an
		// unreachable one too, so a router without a route for a family
		// can still have it proxied. The block rules below carry the same
		// term, which also keeps neighbour discovery out of their reach.
		let fib = (action == 'tproxy')
			? 'fib daddr type != { local, broadcast, multicast } ' : '';

		// bypass keeps whatever mark the packet carries: no shunt rule after
		// this one is reached, and the bits outside the mask are not ours.
		// route also records the mark on the conntrack entry, so the flow's
		// later packets can be marked from it without another lookup - see
		// the restore rules below.
		let setmark = (mark != null)
			? sprintf('meta mark set (meta mark & 0x%08x) | 0x%08x ct mark set (ct mark & 0x%08x) | 0x%08x ',
				~mask & 0xffffffff, mark, ~mask & 0xffffffff, mark)
			: '';

		// tproxy names the family of its address, so its statement exists
		// once per family. When the socket lookup finds no listener the
		// statement ends the rule unmatched and the packet goes on to the
		// next one - with fallback 'block' those are the rejects rendered
		// right after it, otherwise the normal uplink.
		function stmt(fam) {
			if (action == 'bypass')
				return sprintf('%scounter return', l4);
			if (action == 'tproxy')
				return sprintf('%s%stproxy %s to %s:%s %scounter return', l4, fib,
					fam == '4' ? 'ip' : 'ip6', TPROXY_ADDR[fam], tp_port, setmark);
			return sprintf('%s%scounter return', l4, setmark);
		}

		// A rule, and for a blocking tproxy policy the rejects that catch
		// it failing. Rejected, not dropped, so a client gives up at once
		// rather than on a timeout: tcp is reset, anything else answered
		// with admin-prohibited. Without its own protocols or ports the
		// policy owns every protocol the client sends, and what the proxy
		// cannot take - icmp, esp, gre - is rejected whether it runs or
		// not; with them, it owns only those. tproxy exists in prerouting
		// only, so none of it goes to output: the router's own traffic is
		// not proxied, and the proxy's own upstream connections cannot
		// loop back into it.
		function emit(rules, out, pre, fam) {
			push(rules, { out: out && action != 'tproxy',
				text: sprintf('\t\t%s%s', pre, stmt(fam)) });
			if (!tp_block)
				return;
			if (!narrowed || index(protos, 'tcp') >= 0)
				push(rules, { out: false,
					text: sprintf('\t\t%smeta l4proto tcp %s%scounter reject with tcp reset',
						pre, pt, fib) });
			if (!narrowed)
				push(rules, { out: false,
					text: sprintf('\t\t%s%scounter reject with icmpx admin-prohibited',
						pre, fib) });
			else if (index(protos, 'udp') >= 0)
				push(rules, { out: false,
					text: sprintf('\t\t%smeta l4proto udp %s%scounter reject with icmpx admin-prohibited',
						pre, pt, fib) });
		}

		// The decision for a flow is made on its first packet and kept:
		// later packets in the original direction take the mark from the
		// conntrack entry, and never reach the lookups. That is what makes
		// a set change safe for connections already running - masquerade
		// kills a conntrack entry whose output interface changed
		// (nf_nat_inet_fn, oif_changed), so re-marking a live flow would
		// reset it. One rule per route policy, with its mark as a constant:
		// nft has no expression-to-expression OR. Family-agnostic, so one
		// rule serves both. Replies stay unmarked, as they always did - a
		// marked reply would look up the policy table and miss the LAN.
		let ctm = sprintf('ct state != new ct direction original ct mark & 0x%08x == 0x%08x ',
			mask, mark);
		let rmark = sprintf('meta mark set (meta mark & 0x%08x) | 0x%08x ',
			~mask & 0xffffffff, mark);

		if (action == 'route') {
			let r = sprintf('\t\t%s%scounter return', ctm, rmark);
			push(restore, r);
			push(restore_out, r);
		}

		// A proxied flow needs the statement on every packet, not only the
		// mark: a udp proxy answers from a socket bound to the original
		// destination, so the mark alone delivers the client's next datagram
		// to that socket rather than the listener - measured. tcp would find
		// its connected socket either way. Without a listener the flow
		// cannot go on anywhere: its state is in the proxy, and the conntrack
		// entry was never NATed, so forwarding it would put the client's
		// own address on the uplink - measured too. It is rejected whatever
		// the fallback, tcp with a reset so the client sees the end at once;
		// fallback decides about new flows only.
		if (action == 'tproxy') {
			let pl = length(protos) == 1 ? protos[0] : sprintf('{ %s }', join(', ', protos));
			for (let fam in [ '4', '6' ])
				push(restore, sprintf(
					'\t\t%smeta nfproto ipv%s meta l4proto %s tproxy %s to %s:%s %scounter return',
					ctm, fam, pl, fam == '4' ? 'ip' : 'ip6', TPROXY_ADDR[fam],
					tp_port, rmark));
			push(restore, sprintf('\t\t%smeta l4proto tcp counter reject with tcp reset', ctm));
			push(restore, sprintf('\t\t%scounter reject with icmpx admin-prohibited', ctm));
		}

		// Two rule priorities per routing policy, in two bands 500 apart:
		// keep_local's main lookup keeps the band a released version already
		// used, so an upgrade removes the old rule with the new one's del,
		// and the policy table rule moves up out of the way.
		let entry = (action == 'bypass')
			? { name: pname, action, index: null, mark: null,
				rt_table: null, rt_prio: null, rt_prio_local: null }
			: { name: pname, action, index: idx, mark,
				rt_table: 8000 + idx,
				rt_prio: 31500 + idx,
				rt_prio_local: 31000 + idx };

		if (action == 'tproxy')
			entry.port = +tp_port;

		push(marks, entry);

		if (has_mac)
			push(sets, sprintf(
				'\tset %s { type ether_addr; counter; elements = { %s }; }',
				set_name('m', '', pname), join(', ', macs)));

		if (has_dev)
			push(sets, sprintf(
				'\tset %s { type ifname; counter; elements = { %s }; }',
				set_name('i', '', pname),
				join(', ', map(devs, (d) => `"${d}"`))));

		for (let fam in [ '4', '6' ]) {
			let ip = (fam == '4') ? 'ip' : 'ip6';
			let rules = (fam == '4') ? rules4 : rules6;
			let atype = (fam == '4') ? 'ipv4_addr' : 'ipv6_addr';

			if (has_dom)
				push(sets, sprintf(
					'\tset %s { type %s; flags timeout; counter; }',
					set_name('d', fam, pname), atype));

			let prefixes = [];

			if (length(src[fam]))
				prefixes = [ ...prefixes, {
					pre: sprintf('%s saddr @%s ', ip, set_name('c', fam, pname)),
					out: true, per_family: true
				} ];

			if (has_mac)
				prefixes = [ ...prefixes, {
					pre: sprintf('ether saddr @%s ', set_name('m', '', pname)),
					out: false, per_family: false
				} ];

			// Like a MAC, an ingress device exists in prerouting only: the
			// router's own traffic has no input interface.
			if (has_dev)
				prefixes = [ ...prefixes, {
					pre: sprintf('iifname @%s ', set_name('i', '', pname)),
					out: false, per_family: false
				} ];

			if (!has_src)
				prefixes = [ { pre: '', out: true, per_family: false } ];

			if (!length(prefixes)) {
				if (length(dst[fam]) || has_dom)
					reject(pname, null, sprintf(
						'src has no v%s entry - v%s rules skipped to avoid over-marking',
						fam, fam));
				continue;
			}

			// auto-merge: overlapping prefixes - 10.0.0.0/8 next to
			// 10.1.0.0/16, as any list of real networks has - are folded
			// instead of failing the batch with "conflicting intervals",
			// which would take every policy down with this one.
			if (length(src[fam]))
				push(sets, sprintf(
					'\tset %s { type %s; flags interval; auto-merge; counter; elements = { %s }; }',
					set_name('c', fam, pname), atype,
					join(', ', src[fam])));

			// A policy with an address file gets both families' sets even
			// while they are empty: the next refresh may bring either.
			let has_sset = length(dst[fam]) > 0 || has_dfile;

			if (has_sset)
				push(sets, length(dst[fam])
					? sprintf('\tset %s { type %s; flags interval; auto-merge; counter; elements = { %s }; }',
						set_name('s', fam, pname), atype, join(', ', dst[fam]))
					: sprintf('\tset %s { type %s; flags interval; auto-merge; counter; }',
						set_name('s', fam, pname), atype));

			// Refilled as a whole on `shunt refresh`: flush and add in one
			// batch, so the set is never seen half-filled.
			if (has_dfile) {
				push(fill, sprintf('flush set %s %s', TABLE, set_name('s', fam, pname)));
				if (length(dst[fam]))
					push(fill, sprintf('add element %s %s { %s }', TABLE,
						set_name('s', fam, pname), join(', ', dst[fam])));
			}

			for (let px in prefixes)
				if (has_sset)
					emit(rules, px.out, sprintf('%s%s daddr @%s ',
						px.pre, ip, set_name('s', fam, pname)), fam);

			if (has_dom)
				learn[set_name('d', fam, pname)] = true;

			// Destinations exist, but all in the other family: nothing for
			// this one to route. A port or protocol alone does not have a
			// family, so it does not trigger this.
			if (!has_sset && !has_dom && has_dst_any)
				continue;

			for (let px in prefixes) {
				if (has_dom)
					emit(rules, px.out, sprintf('%s%s daddr @%s ',
						px.pre, ip, set_name('d', fam, pname)), fam);

				// A rule with no address in it serves both families at once,
				// except under tproxy, whose statement names one: there it
				// is rendered per family, pinned with nfproto.
				if (!has_dst_any && !has_dom) {
					if (px.per_family)
						emit(rules, px.out, px.pre, fam);
					else if (action == 'tproxy')
						emit(rules, px.out,
							sprintf('%smeta nfproto ipv%s ', px.pre, fam), fam);
					else if (fam == '4')
						emit(rules, px.out, px.pre, fam);
				}
			}
		}
	}

	// Every other flow past its first packet is settled too: a bypass
	// decision, no policy, or older than the ruleset. It keeps whatever it
	// has and is not re-evaluated against sets that changed since.
	let settled = length(restore)
		? [ '\t\tct state != new counter return' ] : [];
	let settled_out = length(restore_out) ? settled : [];

	let setup = join('\n', [
		`destroy table ${TABLE}`,
		`table ${TABLE} {`,
		...sets,
		'\tchain prerouting {',
		'\t\ttype filter hook prerouting priority mangle; policy accept;',
		...restore, ...settled,
		...map(rules4, (r) => r.text), ...map(rules6, (r) => r.text),
		'\t}',
		'\tchain output {',
		'\t\ttype route hook output priority mangle; policy accept;',
		...restore_out, ...settled_out,
		...map(filter(rules4, (r) => r.out), (r) => r.text),
		...map(filter(rules6, (r) => r.out), (r) => r.text),
		'\t}',
		'}',
		''
	]);

	return { setup, marks, issues, learn,
		fill: length(fill) ? join('\n', fill) + '\n' : '' };
};

// A write may carry its own timeout - the TTL of the answer it came from,
// already clamped by the caller - or fall back to entry_ttl. slack goes on
// top of either: a client asks again when the TTL runs out, and the write
// for that answer reaches the kernel up to one write interval later. An
// element timed out to the second would be gone for exactly that gap, and
// a connection opened in it starts on the normal uplink and stays there.
export function refresh(writes, entry_ttl, slack) {
	let dflt = entry_ttl ?? DEFAULTS.entry_ttl;
	let pad = (type(slack) == 'int' && slack > 0) ? slack : 0;
	let out = [], issues = [];

	for (let w in (writes ?? [])) {
		let m = match(w?.set ?? '', /^[csd]([46])_[A-Za-z0-9_]{1,24}$/);
		let fam = addr_family(w?.addr ?? '');

		if (!m || fam == null || sprintf('%d', fam) != m[1] ||
			index(w.addr, '/') >= 0) {
			push(issues, { entry: w, reason: 'rejected, not rendered' });
			continue;
		}

		push(out, sprintf('destroy element %s %s { %s }', TABLE, w.set, w.addr));
		push(out, sprintf('add element %s %s { %s timeout %ds }',
			TABLE, w.set, w.addr, (w.ttl ?? dflt) + pad));
	}

	return { batch: length(out) ? join('\n', out) + '\n' : '', issues };
};

export function teardown() {
	return `destroy table ${TABLE}\n`;
};
