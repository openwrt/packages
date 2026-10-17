#!/bin/sh

# shellcheck shell=busybox

IPKG_INSTROOT=${IPKG_INSTROOT:-}
export IPKG_INSTROOT

. /lib/functions.sh
. /lib/mwan3/mwan3.sh

set -e

mwan3_init

sanitize_route()
{
	printf '%s\n' "$1" | sed -ne "$MWAN3_ROUTE_LINE_EXP"
}

expected='192.0.2.0/24 dev eth0 scope link src 192.0.2.1 '

for flags in 'dead linkdown' 'linkdown dead' 'dead' 'linkdown'; do
	actual=$(sanitize_route "$expected$flags")
	[ "$actual" = "$expected" ] || {
		echo "failed to sanitize route flags: $flags" >&2
		echo "expected: '$expected'" >&2
		echo "actual:   '$actual'" >&2
		exit 1
	}
done

ipv6_route='fd00:1::/64 via fe80::dead dev eth0 proto static metric 1024 pref medium'
actual=$(sanitize_route "$ipv6_route")
[ "$actual" = "$ipv6_route" ] || {
	echo "failed to preserve an IPv6 address ending in dead" >&2
	echo "expected: '$ipv6_route'" >&2
	echo "actual:   '$actual'" >&2
	exit 1
}

# Exercise the installed rpcd implementation with isolated state/ubus fixtures.
ucode -S - <<'EOF'
'use strict';
import { readfile } from 'fs';

const path = '/usr/share/rpcd/ucode/mwan3';
let source = readfile(path);
if (source == null)
	die('Cannot read mwan3 rpcd plugin');
// Keep the actual functions and RPC implementation; replace only external I/O.
source = substr(source, index(source, 'function get_str_raw('));
let state = {};
const io = {
	readfile: path => {
		if (path == '/proc/uptime')
			return '1000.00 1000.00\n';
		return state[split(path, '/')[-1]];
	},
	cursor: () => ({ foreach: (config, section, callback) => callback({
		'.name': 'wan', 'enabled': '1', 'track_ip': ['192.0.2.1']
	}) }),
	ubus: { call: (object, method, args) => object == 'service' ?
		{ mwan3: { instances: { track_wan: { running: true } } } } :
		{ up: true, uptime: 900 } },
	popen: () => die('Unexpected process execution')
};
const plugin = call(loadstring(source, { raw_mode: true }), null, io);
let checks = 0;
const fields = ['age', 'online', 'offline', 'score', 'lost', 'turn'];
for (let value in [null, '', '\n', 'invalid', '0', '17', '17\n']) {
	state = { STARTED: '1', STATUS: 'online' };
	for (let key in ['TIME', 'ONLINE', 'OFFLINE', 'SCORE', 'LOST', 'TURN', 'LATENCY_192.0.2.1', 'LOSS_192.0.2.1'])
		state[key] = value;
	const status = call(plugin.mwan3.status.call, null, io, { args: { section: 'interfaces' } });
	const wan = status.interfaces.wan;
	for (let field in fields) {
		const expected = (value == '17' || value == '17\n') ?
			((field in ['age', 'online', 'offline']) ? 983 : 17) : 0;
		if (wan[field] !== expected)
			die(sprintf('%s for %J: expected %d, got %J\n', field, value, expected, wan[field]));
		checks++;
	}
	for (let key in ['latency', 'packetloss']) {
		const expected = (value == '17' || value == '17\n') ? 17 : 0;
		if (wan.track_ip[0][key] !== expected)
			die(sprintf('%s for %J: got %J\n', key, value, wan.track_ip[0][key]));
		checks++;
	}
	if (!wan.running || !wan.up || wan.uptime != 900)
		die('Unrelated interface status changed');
	checks++;
}
printf('mwan3 rpcd integer status: %d checks passed\n', checks);
EOF
