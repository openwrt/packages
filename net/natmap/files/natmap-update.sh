#!/bin/sh

[ -z "${CONFIG_SECTION_ID}" ] && exit 1
export -n CONFIG_SECTION_ID

(
	. /usr/share/libubox/jshn.sh

	json_init
	json_add_string ip "$1"
	json_add_int port "$2"
	json_add_int inner_port "$4"
	json_add_string protocol "$5"
	json_dump > "/var/run/natmap/${CONFIG_SECTION_ID}.json"
)

. /lib/functions.sh

NOTIFY_SCRIPT="$(uci_get natmap "${CONFIG_SECTION_ID}" notify_script)"
[ "$?" -eq 0 ] && [ -n "${NOTIFY_SCRIPT}" ] && exec "${NOTIFY_SCRIPT}" "$@"
