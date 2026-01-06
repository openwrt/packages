#!/bin/sh

. /usr/share/libubox/jshn.sh

KEEPALIVED_STATUS_DIR="/var/run/keepalived"

dump() {
	local type="${1}"
	local value name time status

	json_add_array "$(echo "$type" | tr A-Z a-z)"
	for dir in ${KEEPALIVED_STATUS_DIR}/*; do
		value="${dir##*_}"
		name="${dir%_*}"
		name="${name##*/}"
		[ -f "${dir}/TIME" ] && time=$(cat "${dir}/TIME")
		[ -f "${dir}/STATUS" ] && status=$(cat "${dir}/STATUS")
		if [ "${value}" = "${type}" ]; then
			json_add_object
			json_add_string "name" "${name}"
			json_add_int "event" "${time}"
			json_add_string "status" "${status}"
			json_close_object
		fi
	done
	json_close_array
}

status() {
	json_init
	dump "INSTANCE"
	dump "GROUP"
	json_dump
}
