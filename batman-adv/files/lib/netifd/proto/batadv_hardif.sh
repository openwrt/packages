#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_batadv_hardif_init_config() {
	proto_config_add_string "master"
}

proto_batadv_hardif_setup() {
	local config="$1"
	local iface="$2"

	local master

	json_get_vars master

	( proto_add_host_dependency "$config" '' "$master" )

	batctl -m "$master" interface -M add "$iface"

	proto_init_update "$iface" 1
	proto_send_update "$config"
}

proto_batadv_hardif_teardown() {
	local config="$1"
	local iface="$2"

	local master

	json_get_vars master

	batctl -m "$master" interface -M del "$iface" || true
}

add_protocol batadv_hardif
