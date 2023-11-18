#!/bin/sh

PROG=/usr/bin/netbird

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_netbird_init_config() {
	no_device=0
	available=0

	proto_config_add_string "device:device"
	proto_config_add_int "delay"
}

proto_netbird_setup() {
	local cfg="$1"
	local iface="$2"
	local device delay

	json_get_vars device delay

	[ -z "$delay" ] && delay=2

	[ -n "$device" ] || {
		echo "netbird tunnel interface not specified"
		proto_notify_error "$cfg" NO_DEVICE
		proto_set_available "$cfg" 0
		return 1
	}

	[ -n "$delay" ] && sleep "$delay"

	[ "$(/etc/init.d/netbird status)" = "running" ] || {
		echo "netbird service is not running"
		proto_notify_error "$cfg" NO_SERVICE_RUNNING
		proto_set_available "$cfg" 0
		return 1
	}

	[ -L "/sys/class/net/${device}" ] || {
		$PROG up
		sleep 1
	}

	[ -L "/sys/class/net/${device}" ] || {
		echo "specified interface $device is not present"
		proto_notify_error "$cfg" NO_DEVICE
		proto_set_available "$cfg" 0
		return 1
	}

	IP4ADDRS=
	IP6ADDRS=

	local addresses="$(ip -json address list dev "$device")"
	json_init
	json_load "{\"addresses\":${addresses}}"

	if json_is_a addresses array; then
		json_select addresses
		json_select 1

		if json_is_a addr_info array; then
			json_select addr_info

			local i=1
			while json_is_a ${i} object; do
				json_select ${i}
				json_get_vars scope family local prefixlen broadcast

				if [ "${scope}" == "global" ]; then
					case "${family}" in
						inet)
							append IP4ADDRS "$local/$prefixlen/$broadcast/"
							;;

						inet6)
							append IP6ADDRS "$local/$prefixlen/$broadcast///"
							;;
					esac
				fi

				json_select ..
				i=$(( i + 1 ))
			done
		fi
	fi

	IP4ROUTES=
	IP6ROUTES=

	local routes="$(ip -json route list dev "$device")"
	json_init
	json_load "{\"routes\":${routes}}"

	if json_is_a routes array;then
		json_select routes

		local i=1
		while json_is_a ${i} object; do
			json_select ${i}
			json_get_vars dst gateway metric prefsrc

			case "${dst}" in
				*:*/*)
					append IP6ROUTES "$dst/$gateway/$metric///$prefsrc"
					;;
				*.*/*)
					append IP4ROUTES "$dst/$gateway/$metric///$prefsrc"
					;;
				*:*)
					append IP6ROUTES "$dst/128/$gateway/$metric///$prefsrc"
					;;
				*.*)
					append IP4ROUTES "$dst/32/$gateway/$metric///$prefsrc"
					;;
			esac

			json_select ..
			i=$(( i + 1 ))
		done
	fi

	[ -z "$IP4ADDRS" ] && {
		echo "netbird tunnel $device does not have ip address"
		proto_notify_error "$cfg" NO_IPADDRESS
		return 1
	}

	proto_init_update "$device" 1 1

	PROTO_IPADDR="${IP4ADDRS}"
	PROTO_IP6ADDR="${IP6ADDRS}"

	PROTO_ROUTE="${IP4ROUTES}"
	PROTO_ROUTE6="${IP6ROUTES}"

	proto_send_update "$cfg"
}

proto_netbird_set_available_delayed() {
	local cfg="$1"
	sleep 2
	[ "$(/etc/init.d/netbird status)" = "running" ] && {
		proto_set_available "$cfg" 1
	} || {
		proto_set_available "$cfg" 0
	}
}

proto_netbird_teardown() {
	local cfg="$1"

	sleep 1
	$PROG down > /dev/null 2>&1
	proto_netbird_set_available_delayed "$cfg" &
	return 0
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol netbird
}
