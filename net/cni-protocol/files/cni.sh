#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_cni_init_config() {
	no_device=0
	available=0

	proto_config_add_string "device:device"
	proto_config_add_int "delay"
}

proto_cni_setup() {
	local cfg="$1"
	local iface="$2"
	local device delay

	json_get_vars device delay

	[ -n "$device" ] || {
		echo "No cni interface specified"
		proto_notify_error "$cfg" NO_DEVICE
		proto_set_available "$cfg" 0
		return 1
	}

	[ -n "$delay" ] && sleep "$delay"

	[ -L "/sys/class/net/${iface}" ] || {
		echo "The specified interface $iface is not present"
		proto_notify_error "$cfg" NO_DEVICE
		proto_set_available "$cfg" 0
		return 1
	}

	local ipaddr netmask broadcast route routemask routesrc

	ipaddr=$(ip -4 -o a show "$iface" | awk '{ print $4 }' | cut -d '/' -f1)
	netmask=$(ip -4 -o a show "$iface" | awk '{ print $4 }' | cut -d '/' -f2)
	broadcast=$(ip -4 -o a show "$iface" | awk '{ print $6 }')
	route=$(ip -4 -o r show dev "$iface" | awk '{ print $1 }' | cut -d '/' -f1)
	routemask=$(ip -4 -o r show dev "$iface" | awk '{ print $1 }' | cut -d '/' -f2)
	routesrc=$(ip -4 -o r show dev "$iface" | awk '{ print $7 }')

	[ -z "$ipaddr" ] && {
		echo "interface $iface does not have ip address"
		proto_notify_error "$cfg" NO_IPADDRESS
		return 1
	}

	proto_init_update "$iface" 1
	[ -n "$ipaddr" ] && proto_add_ipv4_address "$ipaddr" "$netmask" "$broadcast" ""
	[ -n "$route" ] && proto_add_ipv4_route "$route" "$routemask" "" "$routesrc" ""
	proto_send_update "$cfg"
}

proto_cni_teardown() {
	local cfg="$1"
	return 0
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol cni
}
