#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_batadv_vlan_init_config() {
	proto_config_add_string "ap_isolation"
}

proto_batadv_vlan_setup() {
	local config="$1"
	local iface="$2"

	# VLAN specific variables
	local device="${iface%.*}"
	local vid="${iface#*.}"

	# batadv_vlan options
	local ap_isolation

	json_get_vars ap_isolation

	echo "$ap_isolation" > "/sys/class/net/${device}/mesh/vlan${vid}/ap_isolation"
	proto_init_update "$iface" 1
	proto_send_update "$config"
}

add_protocol batadv_vlan
