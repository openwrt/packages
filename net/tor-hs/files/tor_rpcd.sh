#!/bin/sh
# shellcheck disable=SC1091,SC3043,SC2086,SC2154,SC2034

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

parse_hs_conf() {
	local name description public_port local_port enable_bool public_local_port ipaddr
	local config="$1"
	local custom="$2"

	config_get name "$config" Name
	config_get description "$config" Description

	config_get_bool enabled "$config" Enabled 0
	config_get ipaddr "$config" IPv4
	config_get ipaddr "$config" IPaddr "$ipaddr" # IPv4 or IPv6; prefer IPaddr property, default to IPv4 value if absent
	config_get ports "$config" PublicLocalPort
	config_get hs_dir common HSDir

	hostname="$([ -f "$hs_dir/$name/hostname" ] && cat "$hs_dir/$name/hostname")"

	json_add_object
	json_add_string 'name' "$name"
	json_add_string 'description' "$description"
	json_add_string 'enabled' "$enabled"
	json_add_string 'ipv4' "$ipaddr" 
	json_add_string 'ipaddr' "$ipaddr" 
	json_add_string 'hostname' "$hostname"
	json_add_array 'ports'
	set -- $ports
	for port; do
		json_add_string '' "$port"
	done
	json_close_array
	json_close_object
}

get_tor_hs_list() {
	config_load tor-hs

	json_init
	json_add_array 'hs-list'
	config_foreach parse_hs_conf hidden-service
	json_close_array
	json_dump
	json_cleanup
}



case "$1" in
	list)
		echo '{ "list-hs": { } }'
	;;
	call)
		case "$2" in
			list-hs)
				# return json object
				get_tor_hs_list
			;;
		esac
	;;
esac



