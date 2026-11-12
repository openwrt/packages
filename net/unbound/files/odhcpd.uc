#!/usr/bin/ucode
/*
 * Copyright (C) 2026 David Härdeman <david@hardeman.nu>
 *
 * Based on odhcpd.sh and odhcpd.awk, Copyright (C) 2016 Eric Luehrsen
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * Load DHCP-DNS records for the leases of odhcpd into Unbound. This allows
 * Unbound+odhcpd without dnsmasq. The current leases are fetched from odhcpd
 * via ubus and turned into A, AAAA and PTR records. Also lift a function from
 * dnsmasq and use the DHCPv4 MAC to find IPv6 SLAAC hosts.
 *
 * The records are loaded via unbound-control, only the differences to the
 * previous run are applied. They are also written to a configuration file
 * which is included when Unbound is (re)started.
 *
 * This is run by a procd trigger on odhcpd's "dhcp.hosts.update" event (see
 * unbound.init).
 */

'use strict';

import { cursor } from 'uci';
import { connect } from 'ubus';
import { access, open, popen, readfile, writefile, unlink } from 'fs';

const UB_VARDIR = '/var/lib/unbound';
const UB_TOTAL_CONF = `${UB_VARDIR}/unbound.conf`;
const UB_DHCP_CONF = `${UB_VARDIR}/dhcp.conf`;
const UB_CONTROL = '/usr/sbin/unbound-control';
/* Records loaded by the previous run (removed by unbound_mkdir() on start) */
const UB_DHCP_RECORDS = `${UB_VARDIR}/dhcp_odhcpd.records`;
const UB_ODHCPD_LOCK = '/var/lock/unbound_odhcpd.lock';
const TTL = 300;

function log(msg) {
	system([ 'logger', '-t', 'unbound-odhcpd', msg ]);
}

function shell_quote(str) {
	return "'" + replace(str, "'", "'\\''") + "'";
}

/* Expand an IPv6 address to 32 hex digits, or return null */
function ipv6_nibbles(addr) {
	const halves = split(addr, '::');
	if (length(halves) > 2)
		return null;

	const head = length(halves[0]) ? split(halves[0], ':') : [];
	const tail = (length(halves) == 2 && length(halves[1])) ? split(halves[1], ':') : [];
	const fill = 8 - length(head) - length(tail);

	if ((length(halves) == 1 && fill != 0) || fill < 0)
		return null;

	let groups = [ ...head ];
	for (let i = 0; i < fill; i++)
		push(groups, '0');
	push(groups, ...tail);

	let hex = '';
	for (let g in groups) {
		if (!match(g, /^[0-9a-fA-F]{1,4}$/))
			return null;
		hex += substr('000' + lc(g), -4);
	}

	return hex;
}

function ipv4_ptr(addr) {
	return join('.', reverse(split(addr, '.'))) + '.in-addr.arpa.';
}

function ipv6_ptr(addr) {
	const hex = ipv6_nibbles(addr);
	return hex ? join('.', reverse(split(hex, ''))) + '.ip6.arpa.' : null;
}

/* Global unicast (2000::/3) */
function ipv6_is_ga(addr) {
	const hex = ipv6_nibbles(addr);
	return hex ? (substr(hex, 0, 1) == '2' || substr(hex, 0, 1) == '3') : false;
}

/* Modified EUI-64 interface identifier (RFC 4291) of a MAC, as used by SLAAC */
function slaac_eui64(mac) {
	mac = lc(replace(mac ?? '', ':', ''));
	if (!match(mac, /^[0-9a-f]{12}/))
		return null;

	/* Invert the universal/local bit */
	const b = split(mac, '');
	b[1] = sprintf('%x', hex(b[1]) ^ 2);

	return `${b[0]}${b[1]}${b[2]}${b[3]}:${b[4]}${b[5]}ff:fe${b[6]}${b[7]}:${b[8]}${b[9]}${b[10]}${b[11]}`;
}

/* The routed (on-link) IPv6 prefixes of a network device */
function device_prefixes(dev) {
	const prefixes = [];
	const p = popen(`ip -6 --oneline route show dev ${shell_quote(dev)}`);
	if (!p)
		return prefixes;

	for (let line = p.read('line'); length(line); line = p.read('line')) {
		const prefix = split(trim(line), ' ')[0];

		if (index(prefix, '::/') < 0 || index(line, 'anycast') >= 0 ||
		    index(line, 'via') >= 0 || substr(prefix, 0, 5) > 'fdff:')
			continue;

		push(prefixes, prefix);
	}

	p.close();
	return prefixes;
}

/* Normalise a hostname into a single DNS label, or return null */
function dns_label(hostname) {
	const label = replace(hostname ?? '', '_', '-');
	return match(label, /^[A-Za-z0-9]([-A-Za-z0-9]*[A-Za-z0-9])?$/) ? label : null;
}

/* Records (and matching config lines) for all DHCP leases of odhcpd */
function lease_records(opts) {
	const ubus = connect();
	const records = {};
	const conf = [];

	if (!ubus)
		return null;

	/* record => name (as unbound-control's local_datas_remove wants it) */
	function add(fqdn, type, addr, ptr) {
		records[`${fqdn}. ${TTL} IN ${type} ${addr}`] = `${fqdn}.`;
		records[`${ptr} ${TTL} IN PTR ${fqdn}`] = ptr;
		push(conf, `local-data: "${fqdn}. ${TTL} IN ${type} ${addr}"`,
		           `local-data-ptr: "${addr} ${TTL} ${fqdn}"`, '');
	}

	function add_ipv6(fqdn, addr) {
		const ptr = ipv6_ptr(addr);

		if (!ptr)
			return;

		if (opts.exclude_ipv6_ga && ipv6_is_ga(addr)) {
			log(`Excluding GA IPv6 address: ${addr} for ${fqdn}`);
			return;
		}

		add(fqdn, 'AAAA', addr, ptr);
	}

	for (let family in [ 4, 6 ]) {
		const reply = ubus.call('dhcp', `ipv${family}leases`);

		for (let dev, iface in reply?.device ?? {}) {
			for (let lease in iface?.leases ?? []) {
				const label = dns_label(lease.hostname);

				/* odhcpd also lists leases which have only been offered */
				if (!label || !('bound' in (lease.flags ?? [])))
					continue;

				const fqdn = lc(`${label}.${opts.domain}`);

				if (family == 4) {
					if (!match(lease.address, /^[0-9.]+$/))
						continue;

					add(fqdn, 'A', lease.address, ipv4_ptr(lease.address));

					const eui64 = opts.slaac ? slaac_eui64(lease.mac) : null;
					if (!eui64)
						continue;

					/* Use the DHCPv4 MAC to find the GA and ULA SLAAC addresses */
					for (let prefix in device_prefixes(dev)) {
						if (opts.exclude_ipv6_ga && ipv6_is_ga(prefix)) {
							log(`Excluding GA IPv6 address: ${prefix} for ${fqdn}`);
							continue;
						}

						let addr = replace(prefix, /\/.*/, '') + eui64;
						if (length(split(addr, ':')) > 8)
							addr = replace(addr, '::', ':');

						add_ipv6(fqdn, addr);
					}
				}
				else {
					/* Only addresses (IA_NA), not delegated prefixes (IA_PD) */
					for (let a in lease['ipv6-addr'] ?? [])
						add_ipv6(fqdn, a.address);
				}
			}
		}
	}

	ubus.disconnect();
	return { records, conf };
}

function unbound_control(cmd, lines) {
	if (!length(lines))
		return true;

	const p = popen(`${UB_CONTROL} -c ${UB_TOTAL_CONF} ${cmd} >/dev/null 2>&1`, 'w');
	if (!p)
		return false;

	p.write(join('\n', lines) + '\n');
	return p.close() == 0;
}

function main() {
	const uci = cursor();
	const opt = (name) => uci.get_first('unbound', 'unbound', name);
	const opts = {
		domain: opt('domain'),
		slaac: opt('dhcp4_slaac6') == '1',
		exclude_ipv6_ga: false,
	};

	switch (opt('exclude_ipv6_ga') ?? '0') {
	case '0':
		break;

	case '1':
		opts.exclude_ipv6_ga = true;
		break;

	default:
		log('invalid exclude_ipv6_ga value, using default (0)');
	}

	if (opt('dhcp_link') != 'odhcpd' || !length(opts.domain) || !access(UB_TOTAL_CONF))
		return 0;

	const lock = open(UB_ODHCPD_LOCK, 'w');
	if (!lock || !lock.lock('x'))
		return 1;

	const current = lease_records(opts);
	if (!current)
		return 1;

	/*
	 * The records loaded by the previous run, record => name. After a failed
	 * run, only names (see below), which forces a resync of those names.
	 */
	const previous = {};
	for (let line in split(readfile(UB_DHCP_RECORDS) ?? '', '\n'))
		if (length(line))
			previous[line] = split(line, ' ')[0];

	/*
	 * unbound-control can only remove names, i.e. all records of a name, so
	 * remove the names of all records which are gone and (re)add all current
	 * records with those names.
	 */
	const removed_names = {};
	for (let record, name in previous)
		if (!exists(current.records, record))
			removed_names[name] = true;

	const add = [];
	for (let record, name in current.records)
		if (!exists(previous, record) || removed_names[name])
			push(add, record);

	writefile(UB_DHCP_CONF, join('\n', current.conf));

	if (!unbound_control('local_datas_remove', keys(removed_names)) ||
	    !unbound_control('local_datas', add)) {
		/*
		 * Unknown what was applied: store only the names that may be loaded,
		 * so the next run removes all of them and adds all records again
		 */
		const names = {};
		for (let record, name in previous)
			names[name] = true;
		for (let record, name in current.records)
			names[name] = true;
		writefile(UB_DHCP_RECORDS, join('\n', keys(names)) + '\n');
		return 1;
	}

	writefile(UB_DHCP_RECORDS, join('\n', keys(current.records)) + '\n');
	return 0;
}

exit(main());
