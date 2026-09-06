#!/usr/bin/ucode
// SPDX-License-Identifier: GPL-2.0-or-later
//
// getlease6.uc - resolve a LAN host's global IPv6 address from DHCPv6 leases
//
// Installed as /usr/sbin/getlease6. A ddns-scripts 'ip_source=script' helper,
// so an AAAA record can track a host *behind* the router rather than the
// router itself:
//
//   option ip_source 'script'
//   option ip_script '/usr/sbin/getlease6 myhost'
//   option use_ipv6  '1'
//
// ddns-scripts validates only that the first word is an executable path, and
// not what this prints, so exactly one address goes to stdout and every
// diagnostic goes to stderr.
//
// The record alone does not make the host reachable. Pin the host id with a
// static lease and write the rule against that host id, not a full address:
//
// /etc/config/dhcp:
//   config host
//           option name   'myhost'
//           option duid   '000100...'
//           option hostid 'cafe'
//
// /etc/config/firewall:
//   config rule
//           option src     'wan'
//           option dest    'lan'
//           option dest_ip '::cafe/-64'
//           option family  'ipv6'
//           option target  'ACCEPT'
//
// fw4 reads a negative length as "match those bits only", so neither the lease
// nor the rule is rewritten when the prefix moves. The lease is also what this
// script reads back.

let ubus = require("ubus");
let log = require("log");

// ucode has no argv[0], so the invoked name - not necessarily this file's -
// comes from the source path
const PATHV = split(sourcepath(), "/");
const PROG = PATHV[length(PATHV) - 1];

function fail(msg) {
	warn(sprintf("%s: %s\n", PROG, msg));
}

function notify(msg) {
	fail(msg);
	log.openlog(PROG, log.LOG_PID, log.LOG_DAEMON);
	log.syslog(log.LOG_WARNING, msg);
}

// -h is a request, not an error, so it exits 0 where a malformed call exits 2
function usage(code) {
	warn(`
Usage: ${PROG} hostname
       ${PROG} [-n hostname | -d duid] [-a iaid] [-i interface] [-w upstream]
       ${PROG} -h

  -n hostname   DHCPv6 client hostname to look up (case-insensitive); the
                flag may be omitted, so '${PROG} myhost' means the same
  -d duid       DHCPv6 client DUID; ':' and '-' separators are ignored
  -a iaid       IA identifier, '--iaid' also works; picks one NIC of a host
                holding a lease per NIC, so it narrows -n or -d rather than
                selecting on its own. Decimal as the listing shows it, or
                hex prefixed with '0x'; LuCI shows the IAID in hex without
                that prefix, so add it when pasting from there
  -i interface  logical interface the host is on (default: lan)
  -w upstream   accept only addresses formed from a prefix delegated to this
                upstream interface (e.g. wan6, wanb6, wan_6, ...)
  -h            show this help

Selecting a host with -n or -d looks its address up; given neither, the leases
on the interface are listed instead. A DUID is the lease key, so -d is the
reliable selector and takes precedence: when both are given, -n is not used
to match. The IPv6 address is printed on stdout; diagnostics go to stderr.

`);
	exit(code ?? 2);
}

// iptoarr parses with inet_pton, so a malformed address returns null rather
// than a wrong expansion
function bytes_of(addr) {
	let a = iptoarr(addr);
	return (a && length(a) == 16) ? a : null;
}

// 2000::/3 is global unicast; checked on the prefix, so no ULA or link-local
// address can match one later
function is_global(b) {
	return (b[0] & 0xe0) == 0x20;
}

function prefix_match(a, p, bits) {
	// null compares as 0 rather than failing, so a length that is not a number
	// has to be rejected on its type or a missing mask would match everything
	if (type(bits) != "int" && type(bits) != "double")
		return false;

	if (bits < 0 || bits > 128)
		return false;

	let full = int(bits / 8), rem = bits % 8;

	for (let i = 0; i < full; i++)
		if (a[i] != p[i])
			return false;

	// a length such as /62 ends mid-byte, so that byte is compared over its
	// leading bits only
	if (rem) {
		let mask = (0xff << (8 - rem)) & 0xff;
		if ((a[full] & mask) != (p[full] & mask))
			return false;
	}

	return true;
}

// a logical interface is a uci section name: letters, digits and underscore
function valid_ifname(n) {
	return n && match(n, /^[A-Za-z0-9_]+$/);
}

let sel_host, sel_duid, sel_iaid, iface = "lan", upstream;

for (let i = 0; i < length(ARGV); i++) {
	let opt = ARGV[i], val = ARGV[i + 1];

	if (opt == "-h" || opt == "--help")
		usage(0);

	if (opt == "-n" || opt == "-d" || opt == "-i" || opt == "-w" ||
	    opt == "-a" || opt == "--iaid") {
		if (val == null)
			usage();
		i++;
		switch (opt) {
		case "-n":
			// however it is spelled, naming the host twice is ambiguous
			if (sel_host != null)
				usage();
			sel_host = val;
			break;
		case "-d": sel_duid = val; break;
		case "-a":
		case "--iaid": sel_iaid = val; break;
		case "-i": iface = val; break;
		case "-w": upstream = val; break;
		}
	}
	// a hostname is the usual selector, so -n may be left off; a second bare
	// word would be ambiguous rather than useful
	else if (substr(opt, 0, 1) == "-" || sel_host != null) {
		usage();
	}
	else {
		sel_host = opt;
	}
}

if (!valid_ifname(iface)) {
	fail(`invalid interface name: ${iface}`);
	exit(2);
}

if (upstream != null && !valid_ifname(upstream)) {
	fail(`invalid upstream interface name: ${upstream}`);
	exit(2);
}

if (sel_duid != null) {
	// the '-' leads the class: ucode rejects it escaped inside brackets
	sel_duid = lc(replace(sel_duid, /[-: ]/g, ""));

	if (!match(sel_duid, /^[0-9a-f]+$/)) {
		fail("invalid DUID: expected hex digits");
		exit(2);
	}
}

if (sel_iaid != null) {
	// ubus reports the IAID as a number but LuCI's lease table shows it in
	// hex, so a pasted hex value made only of decimal digits would silently
	// narrow to a different IA; the prefix is what tells the two apart. int()
	// stops at the first non-digit instead of failing, so both forms are
	// matched whole before being converted
	if (match(sel_iaid, /^0[xX][0-9a-fA-F]+$/))
		sel_iaid = hex(sel_iaid);
	else if (match(sel_iaid, /^[0-9]+$/))
		sel_iaid = int(sel_iaid);
	else {
		fail("invalid IAID: expected a decimal number, or hex prefixed with '0x'");
		exit(2);
	}

	// the same IAID is handed out to unrelated hosts - 0 is the first IA of
	// every client - so on its own it would pick between them arbitrarily
	if (!sel_host && !sel_duid) {
		fail("-a narrows a host selector; pass -n or -d as well");
		exit(2);
	}
}

// both lookup failures go to syslog as well as stderr, where there is no
// command line to read them against, so they name what was asked for. Hostname
// matching is case-insensitive but the caller's own spelling is echoed back,
// and an IAID narrows rather than selects, so it is appended. The DUID comes
// first for the same reason it wins the lookup, or a failure would name a
// hostname that was never compared
let sel_label = (sel_duid != null) ? `DUID ${sel_duid}` : `'${sel_host}'`;

if (sel_iaid != null)
	sel_label += ` (IAID ${sel_iaid})`;

if (sel_host != null)
	sel_host = lc(sel_host);

let conn = ubus.connect();

if (!conn) {
	fail("cannot connect to ubus");
	exit(1);
}

let dump = conn.call("network.interface", "dump");
let ifaces = dump ? dump.interface : null;

if (!ifaces) {
	fail("cannot query network interfaces");
	exit(1);
}

function find_iface(name) {
	for (let i in ifaces)
		if (i.interface == name)
			return i;
	return null;
}

let li = find_iface(iface);

// odhcpd keys its lease table by netdev, so the L3 device is what maps a
// logical interface onto leases
if (!li || !li.l3_device) {
	fail(`interface '${iface}' has no device`);
	exit(1);
}

let leases = conn.call("dhcp", "ipv6leases");
let devs = leases ? leases.device : null;

if (!devs) {
	fail("cannot query DHCPv6 leases; odhcpd is required");
	exit(1);
}

let entries = (devs[li.l3_device] || {}).leases || [];

// both empty outcomes - nothing selected, or a selector matching nothing -
// want the leases themselves: hostname, DUID and IAID are what -n, -d and -a
// match on, and the address ends in the host id a static lease pins
function list_leases() {
	let rows = [], hw = length("HOSTNAME"), dw = length("DUID"),
	    iw = length("IAID");

	for (let l in entries) {
		let host = l.hostname ?? "", duid = l.duid ?? "-";
		let iaid = (l.iaid != null) ? `${l.iaid}` : "-";
		let addrs = map(l["ipv6-addr"] ?? [], (e) => e.address);

		// an IA_PD lease carries no address, but the lease itself still counts
		// as an answer
		if (!length(addrs))
			addrs = ["-"];

		for (let a in addrs)
			push(rows, [ length(host) ? host : "-", duid, iaid, a ]);
	}

	if (!length(rows)) {
		// the caller cannot map odhcpd's netdev keys back to interfaces, so
		// the ones holding leases are named here
		let elsewhere = [];

		for (let i in ifaces)
			if (i.l3_device && i.l3_device != li.l3_device &&
			    length((devs[i.l3_device] ?? {}).leases ?? []))
				push(elsewhere, i.interface);

		elsewhere = uniq(elsewhere);

		warn(`no DHCPv6 leases on '${iface}' (${li.l3_device})` +
		     (length(elsewhere)
			? `; leases exist on: ${join(", ", elsewhere)}\n`
			: "\n"));

		return;
	}

	for (let r in rows) {
		if (length(r[0]) > hw)
			hw = length(r[0]);
		if (length(r[1]) > dw)
			dw = length(r[1]);
		if (length(r[2]) > iw)
			iw = length(r[2]);
	}

	// widths come from the data, so the columns line up whatever the hostnames
	// and DUID types in use are
	let fmt = `  %-${hw}s  %-${dw}s  %-${iw}s  %s\n`;

	warn(`current DHCPv6 leases on '${iface}' (${li.l3_device}):\n`);
	warn(sprintf(fmt, "HOSTNAME", "DUID", "IAID", "ADDRESS"));

	for (let r in rows)
		warn(sprintf(fmt, r[0], r[1], r[2], r[3]));
}

// listing needs no prefix of its own, and comes before one is required: on an
// interface still waiting for a delegation, the leases are what was asked for
if (!sel_host && !sel_duid) {
	fail("no host given; showing current leases (-h for usage)");
	list_leases();
	exit(2);
}

// every prefix the interface holds, each with its own length, rather than the
// delegation it came from: this covers PD, 6in4 and 6rd tunnels and a static
// ip6prefix alike
let assignments = li["ipv6-prefix-assignment"];

if (!assignments || !length(assignments)) {
	fail(`interface '${iface}' has no IPv6 prefix`);
	exit(1);
}

if (upstream != null) {
	let ui = find_iface(upstream);
	let delegated = ui ? ui["ipv6-prefix"] : null;

	if (!delegated || !length(delegated)) {
		fail(`upstream interface '${upstream}' has no delegated prefix`);
		exit(1);
	}

	// an assignment does not record which upstream delegated it, so narrow to
	// those falling inside that upstream's own delegations
	assignments = filter(assignments, (a) => {
		let ab = bytes_of(a.address);
		if (!ab)
			return false;

		for (let d in delegated) {
			let db = bytes_of(d.address);
			if (db && prefix_match(ab, db, d.mask))
				return true;
		}

		return false;
	});
}

let prefixes = [];

for (let a in assignments) {
	let b = bytes_of(a.address);
	if (b && is_global(b))
		push(prefixes, { bytes: b, mask: a.mask });
}

if (!length(prefixes)) {
	fail(`no global IPv6 prefix on '${iface}'` +
	     (upstream != null ? ` delegated to '${upstream}'` : ""));
	exit(1);
}

// odhcpd stores only the host id and synthesises one address per prefix, so a
// lease can yield several candidates; IA_NA and IA_PD are separate leases and
// only IA_NA carries 'ipv6-addr', so every matching lease is collected
let candidates = [], host_warned = false;

for (let l in entries) {
	let host = lc(l.hostname ?? "");

	if (sel_duid != null) {
		if (lc(l.duid ?? "") != sel_duid)
			continue;

		// -n is not consulted once a DUID is given, but a hostname that
		// disagrees means one of the two has gone stale, and the answer would
		// then be a host the caller did not ask for
		if (sel_host != null && host != sel_host && !host_warned) {
			host_warned = true;
			notify(`lease for that DUID is '${host || "<no hostname>"}', ` +
			       `not '${sel_host}'; -d takes precedence`);
		}
	}
	else if (host != sel_host) {
		continue;
	}

	let iaid = l.iaid ?? -1;

	if (sel_iaid != null && iaid != sel_iaid)
		continue;

	// only global prefixes were collected, so no separate ULA or link-local
	// check is needed here
	for (let e in (l["ipv6-addr"] ?? [])) {
		let ab = bytes_of(e.address);
		if (!ab)
			continue;

		// which prefix matched is kept, since it is what tells a host with an
		// address under several delegations from one holding several here
		for (let i = 0; i < length(prefixes); i++) {
			if (prefix_match(ab, prefixes[i].bytes, prefixes[i].mask)) {
				push(candidates, {
					addr: e.address,
					bytes: ab,
					prefix: i,
					iaid
				});
				break;
			}
		}
	}
}

if (!length(candidates)) {
	fail(`no global IPv6 lease for ${sel_label} on '${iface}'`);
	list_leases();
	exit(1);
}

// numeric order keeps the answer stable across runs for a host holding several
// addresses; an unstable one would cause needless DDNS updates
sort(candidates, (x, y) => {
	for (let i = 0; i < 16; i++)
		if (x.bytes[i] != y.bytes[i])
			return x.bytes[i] - y.bytes[i];
	return 0;
});

let chosen = candidates[0].addr;

// sort order decides which of several is published - stable, but arbitrary, so
// it is said out loud. Several has three causes and three answers, so the hint
// names the one that applies rather than guessing at -w
if (length(candidates) > 1) {
	let seen_prefixes = {}, seen_iaids = {};

	for (let c in candidates) {
		seen_prefixes[c.prefix] = true;
		seen_iaids[c.iaid] = true;
	}

	let hint;

	if (length(keys(seen_prefixes)) > 1)
		hint = (upstream != null)
			? `'${upstream}' delegates more than one`
			: "pass -w to select an upstream";
	else if (length(keys(seen_iaids)) > 1)
		hint = "one lease per NIC; pass -a to select one";
	else
		hint = "a single lease holds several addresses";

	notify(`${sel_label} matches ${length(candidates)} global addresses ` +
	       `on '${iface}', using ${chosen} (${hint})`);
}

print(chosen, "\n");
