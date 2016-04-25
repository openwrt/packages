#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_batadv_init_config() {
	proto_config_add_string "mesh"
	proto_config_add_string "routing_algo"
}

proto_batadv_setup() {
	local config="$1"
	local iface="$2"

	local mesh routing_algo
	json_get_vars mesh routing_algo

	[ -n "$routing_algo" ] || routing_algo="BATMAN_IV"
	echo "$routing_algo" > "/sys/module/batman_adv/parameters/routing_algo"

	echo "$mesh" > "/sys/class/net/$iface/batman_adv/mesh_iface"
	proto_init_update "$iface" 1
	proto_send_update "$config"
}

proto_batadv_teardown() {
	local config="$1"
	local iface="$2"

	echo "none" > "/sys/class/net/$iface/batman_adv/mesh_iface" || true
}

add_protocol batadv
