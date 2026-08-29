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

		let macs = [];

		for (let a in (p.src_mac ?? [])) {
			let m = mac_addr(a);
			if (m)
				push(macs, m);
			else
				reject(pname, a, 'invalid src_mac address');
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

		// A port with no protocol means both, as banIP does it: "port 443 of
		// this client" almost always includes QUIC, and requiring the
		// protocol would let it slip through unnoticed.
		if (length(ports) && !length(protos))
			protos = [ 'tcp', 'udp' ];

		let has_dom = length(p.domains ?? []) > 0;
		let has_dst_any = length(dst['4']) || length(dst['6']);

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
		let has_src = has_ipsrc || has_mac;
		let has_any = has_src || length(dst['4']) || length(dst['6']) || has_dom;

		if (!has_any) {
			reject(pname, null, 'policy selects nothing');
			continue;
		}

		if (length(p.src ?? []) + length(p.src_mac ?? []) > 0 && !has_src) {
			reject(pname, null,
				'no usable client selector - policy skipped rather than widened to every client');
			continue;
		}

		if (++idx > capacity) {
			reject(pname, null,
				sprintf('mark capacity exceeded (%d policies fit in mask 0x%08x)',
					capacity, mask));
			continue;
		}

		let mark = idx << shift;
		// One transport term for all three rule shapes. `th dport` reads the
		// port at the transport header offset, which works for tcp and udp
		// alike, so a port without a protocol needs no rule per protocol.
		let l4 = '';

		if (length(protos))
			l4 = length(protos) == 1
				? sprintf('meta l4proto %s ', protos[0])
				: sprintf('meta l4proto { %s } ', join(', ', protos));

		if (length(ports))
			l4 += length(ports) == 1
				? sprintf('th dport %s ', ports[0])
				: sprintf('th dport { %s } ', join(', ', ports));

		let stmt = sprintf('%smeta mark set (meta mark & 0x%08x) | 0x%08x counter return',
			l4, ~mask & 0xffffffff, mark);

		push(marks, { name: pname, index: idx, mark,
			rt_table: 8000 + idx, rt_prio: 31000 + idx });

		if (has_mac)
			push(sets, sprintf(
				'\tset %s { type ether_addr; counter; elements = { %s }; }',
				set_name('m', '', pname), join(', ', macs)));

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

			if (!has_src)
				prefixes = [ { pre: '', out: true, per_family: false } ];

			if (!length(prefixes)) {
				if (length(dst[fam]) || has_dom)
					reject(pname, null, sprintf(
						'src has no v%s entry - v%s rules skipped to avoid over-marking',
						fam, fam));
				continue;
			}

			if (length(src[fam]))
				push(sets, sprintf(
					'\tset %s { type %s; flags interval; counter; elements = { %s }; }',
					set_name('c', fam, pname), atype,
					join(', ', src[fam])));

			if (length(dst[fam]))
				push(sets, sprintf(
					'\tset %s { type %s; flags interval; counter; elements = { %s }; }',
					set_name('s', fam, pname), atype,
					join(', ', dst[fam])));

			for (let px in prefixes)
				if (length(dst[fam]))
					push(rules, { out: px.out,
						text: sprintf('\t\t%s%s daddr @%s %s',
							px.pre, ip, set_name('s', fam, pname), stmt) });

			if (has_dom)
				learn[set_name('d', fam, pname)] = true;

			// Destinations exist, but all in the other family: nothing for
			// this one to route. A port or protocol alone does not have a
			// family, so it does not trigger this.
			if (!length(dst[fam]) && !has_dom && has_dst_any)
				continue;

			for (let px in prefixes) {
				if (has_dom)
					push(rules, { out: px.out,
						text: sprintf('\t\t%s%s daddr @%s %s',
							px.pre, ip, set_name('d', fam, pname), stmt) });

				if (!has_dst_any && !has_dom && (px.per_family || fam == '4'))
					push(rules, { out: px.out,
						text: sprintf('\t\t%s%s', px.pre, stmt) });
			}
		}
	}

	let setup = join('\n', [
		`destroy table ${TABLE}`,
		`table ${TABLE} {`,
		...sets,
		'\tchain prerouting {',
		'\t\ttype filter hook prerouting priority mangle; policy accept;',
		...map(rules4, (r) => r.text), ...map(rules6, (r) => r.text),
		'\t}',
		'\tchain output {',
		'\t\ttype route hook output priority mangle; policy accept;',
		...map(filter(rules4, (r) => r.out), (r) => r.text),
		...map(filter(rules6, (r) => r.out), (r) => r.text),
		'\t}',
		'}',
		''
	]);

	return { setup, marks, issues, learn };
};

export function refresh(writes, entry_ttl) {
	let ttl = entry_ttl ?? DEFAULTS.entry_ttl;
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
			TABLE, w.set, w.addr, ttl));
	}

	return { batch: length(out) ? join('\n', out) + '\n' : '', issues };
};

export function teardown() {
	return `destroy table ${TABLE}\n`;
};
