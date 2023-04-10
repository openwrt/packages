#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_cni_init_config() {
	no_device=0
	available=0
	no_proto_task=1
	teardown_on_l3_link_down=1

	proto_config_add_string "device:device"
}

proto_cni_setup() {

	local cfg="$1"
	local device ipaddr netmask broadcast route routemask routesrc

	json_get_var device device

	ipaddr=$(ip -4 -o a show "$device" | awk '{ print $4 }' | cut -d '/' -f1)
	netmask=$(ip -4 -o a show "$device" | awk '{ print $4 }' | cut -d '/' -f2)
	broadcast=$(ip -4 -o a show "$device" | awk '{ print $6 }')
	route=$(ip -4 -o r show dev "$device" | awk '{ print $1 }' | cut -d '/' -f1)
	routemask=$(ip -4 -o r show dev "$device" | awk '{ print $1 }' | cut -d '/' -f2)
	routesrc=$(ip -4 -o r show dev "$device" | awk '{ print $7 }')

	[ -z "$ipaddr" ] && {
		echo "cni network $cfg does not have ip address"
		proto_notify_error "$cfg" NO_IPADDRESS
		return 1
	}

	proto_init_update "$device" 1
	[ -n "$ipaddr" ] && proto_add_ipv4_address "$ipaddr" "$netmask" "$broadcast" ""
	[ -n "$route" ] && proto_add_ipv4_route "$route" "$routemask" "" "$routesrc" ""
	proto_send_update "$cfg"
}

proto_cni_teardown() {
	local cfg="$1"
	#proto_set_available "$cfg" 0
	return 0
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol cni
}
