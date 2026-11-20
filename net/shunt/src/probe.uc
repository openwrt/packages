// shunt - kernel feature probes
//
// What the running kernel can do, read once by the daemon at build time and
// by the rpcd backend per status call, so both report the same verdict.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { popen, readfile, access } from 'fs';
import { action_name } from 'shunt.nft';

// The probe is a rule, not a table: nft -c hands the batch to the kernel and
// aborts it, so the kernel resolves the tproxy expression - autoloading the
// module if it is installed - and installs nothing. Both families, in the
// form nft.uc renders them. The destroy goes first so that a table of the
// same name, whatever it holds, cannot fail the probe; aborted with the
// rest, it never touches that table.
const TPROXY_PROBE = `destroy table inet shunt_probe
table inet shunt_probe {
	chain p {
		type filter hook prerouting priority mangle; policy accept;
		meta nfproto ipv4 meta l4proto tcp tproxy ip to 127.0.0.1:1
		meta nfproto ipv6 meta l4proto tcp tproxy ip6 to [::1]:1
	}
}
`;

let tproxy_ok = false;

// kmod-nft-tproxy is not a dependency, so a tproxy policy may name a module
// that is not there - and nft loads the ruleset as one batch, so one rule
// the kernel cannot resolve would take every policy down. Loaded or
// installed is decided from the file system; anything else, a kernel with
// tproxy built in among it, by asking the kernel. Only a yes is kept: a
// module installed later turns up in /sys/module without a restart of the
// caller. Without a tproxy policy there is nothing to ask, and no nft to
// spawn.
export function tproxy(policies) {
	if (tproxy_ok)
		return true;

	let wanted = false;

	for (let p in (policies ?? []))
		if (action_name(p?.action) == 'tproxy')
			wanted = true;

	if (!wanted)
		return true;

	let rel = trim(readfile('/proc/sys/kernel/osrelease') ?? '');

	if (access('/sys/module/nft_tproxy') ||
	    (length(rel) && access(`/lib/modules/${rel}/nft_tproxy.ko`)))
		return (tproxy_ok = true);

	let fh = popen('nft -c -f - >/dev/null 2>&1', 'w');

	if (!fh)
		return false;

	fh.write(TPROXY_PROBE);

	return (tproxy_ok = (fh.close() == 0));
};

// With br_netfilter calling the inet hooks for bridged traffic, a tproxy
// statement for a client behind a bridge is evaluated in the bridge's
// prerouting pass: the socket is assigned, and TCP still answers the SYN
// with a reset - measured, with and without shunt. The switch is box-wide
// and something else turned it on, so it is reported, not changed.
// Returns the keys that are on.
export function br_netfilter() {
	let on = [];

	for (let k in [ 'bridge-nf-call-iptables', 'bridge-nf-call-ip6tables' ])
		if (trim(readfile(`/proc/sys/net/bridge/${k}`) ?? '') == '1')
			push(on, `net.bridge.${k}`);

	return on;
};

// A kernel booted with ipv6.disable=1 has no IPv6 family at all, and every
// IPv6 route and rule is refused. Disabling IPv6 per device keeps the tree.
export function ipv6() {
	return !!access('/proc/sys/net/ipv6');
};
