#!/bin/sh

# shellcheck disable=SC2039

# shellcheck source=/dev/null
. /usr/share/libubox/jshn.sh
# shellcheck source=/dev/null
. /lib/functions.sh

peer() {
	local cfg=$1
	local c_name=$2
	local name last_sync_time last_sync_status

	config_get name "$cfg" name
	[ "$name" != "$c_name" ] && return

	config_get last_sync_time "$cfg" last_sync_time 0
	config_get last_sync_status "$cfg" last_sync_status NA

	json_add_object unicast_peer
	json_add_string name "$name"
	json_add_int time "$last_sync_time"
	json_add_string status "$last_sync_status"
	json_close_array
}

unicast_peer() {
	config_foreach peer peer "$1"
}

vrrp_instance() {
	local cfg=$1
	local name

	config_get name "$cfg" name

	json_add_object vrrp_instance
	json_add_string name "$name"
	json_add_array unicast_peer
	config_list_foreach "$cfg" unicast_peer unicast_peer
	json_close_array
	json_close_object
}

rsync_status() {
	config_load keepalived

	json_init
	json_add_array vrrp_instance
	config_foreach vrrp_instance vrrp_instance
	json_close_array
	json_dump
}

sync_help() {
	json_add_object rsync_status
	json_close_object
}
