#!/bin/bash
# Mock /lib/functions/network.sh for pbr tests
# Provides configurable network state via MOCK_NET_* variables

# Default mock network data - tests can override these before calling setup
: "${MOCK_NET_wan_device:=eth0}"
: "${MOCK_NET_wan_gateway:=192.168.1.1}"
: "${MOCK_NET_wan_proto:=dhcp}"
: "${MOCK_NET_wan6_device:=eth0}"
: "${MOCK_NET_wan6_gateway6:=fd00::1}"
: "${MOCK_NET_wan6_proto:=dhcpv6}"
: "${MOCK_NET_wg0_device:=wg0}"
: "${MOCK_NET_wg0_proto:=wireguard}"
: "${MOCK_NET_lan_device:=br-lan}"
: "${MOCK_NET_lan_proto:=static}"
: "${MOCK_NET_loopback_device:=lo}"
: "${MOCK_NET_loopback_proto:=static}"

_net_get_var() {
	local var="$1" iface="$2" field="$3"
	local iface_safe="${iface//-/_}"
	local val=""
	eval "val=\"\${MOCK_NET_${iface_safe}_${field}:-}\""
	eval "$var=\"\$val\""
}

network_get_device() {
	_net_get_var "$1" "$2" "device"
}

network_get_physdev() {
	_net_get_var "$1" "$2" "device"
}

network_get_gateway() {
	local var="$1" iface="$2"
	_net_get_var "$var" "$iface" "gateway"
}

network_get_gateway6() {
	local var="$1" iface="$2"
	_net_get_var "$var" "$iface" "gateway6"
}

network_get_protocol() {
	_net_get_var "$1" "$2" "proto"
}

network_get_ipaddr() {
	_net_get_var "$1" "$2" "ipaddr"
}

network_get_ip6addr() {
	_net_get_var "$1" "$2" "ip6addr"
}

network_flush_cache() { :; }

network_get_dnsserver() {
	_net_get_var "$1" "$2" "dns"
}
