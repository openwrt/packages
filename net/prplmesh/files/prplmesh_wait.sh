#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause-Patent
# Keep transport, controller and agent on the same settled AL address.
. /lib/functions.sh

process="$1"
shift

bridge="$(uci -q get prplmesh.config.backhaul_wire_iface)"
case "$bridge" in
	''|*[!a-zA-Z0-9_.-]*) exit 1 ;;
esac
[ "${#bridge}" -le 15 ] || exit 1

expected_mac=
find_bridge_mac() {
	local name type mac
	config_get name "$1" name
	config_get type "$1" type
	[ "$type" = bridge ] && [ "$name" = "$bridge" ] || return 0
	config_get expected_mac "$1" macaddr
}
find_legacy_bridge_mac() {
	local type
	config_get type "$1" type
	[ "$type" = bridge ] && [ "br-$1" = "$bridge" ] || return 0
	config_get expected_mac "$1" macaddr
}
config_load network
config_foreach find_bridge_mac device
config_foreach find_legacy_bridge_mac interface
expected_mac="$(printf '%s' "$expected_mac" | tr 'A-F' 'a-f')"

previous=
stable=0
while :; do
	ready=1
	current="$(cat "/sys/class/net/$bridge/address" 2>/dev/null)"
	[ -n "$current" ] && [ "$current" != 00:00:00:00:00:00 ] || ready=0
	[ -z "$expected_mac" ] || [ "$current" = "$expected_mac" ] || ready=0
	# Only the agent needs AP sockets at startup. The backhaul manager
	# attaches to supplicant if it actually selects a wireless uplink.
	if [ "$process" = agent ]; then
		interfaces="$(uci -q get prplmesh.config.mandatory_interfaces | tr ',' ' ')"
		for interface in $interfaces; do
			[ -S "/var/run/hostapd/$interface" ] || ready=0
		done
	fi
	if [ "$ready" = 1 ] && [ "$current" = "$previous" ]; then
		stable=$((stable + 1))
		[ "$stable" -ge 3 ] && break
	else
		stable=0
	fi
	previous="$current"
	sleep 1
done
exec "$@"
