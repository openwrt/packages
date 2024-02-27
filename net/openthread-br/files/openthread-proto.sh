#!/bin/sh
#
# SPDX-FileCopyrightText: 2023 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

OTCTL="/usr/sbin/ot-ctl"
PROG="/usr/sbin/otbr-agent"

[ -x "$PROG" ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_openthread_add_prefix() {
	prefix="$1"
	# shellcheck disable=SC2086
	[ -n "$prefix" ] && $OTCTL prefix add $prefix
}

proto_openthread_check_service() {
	service="$1"
	ret=1
	json_init
	json_add_string name "$service"
	ubus call service list "$(json_dump)" | jsonfilter -e '@[*].instances[*]["running"]' > /dev/null
	ret=$?
	json_cleanup

	return "$ret"
}

proto_openthread_init_config() {
	proto_config_add_array 'prefix:list(string)'
	proto_config_add_boolean verbose
	proto_config_add_string backbone_network
	proto_config_add_string dataset
	proto_config_add_string radio_url
	proto_config_add_string foobar

	available=1
	no_device=1
}

proto_openthread_setup_error() {
	interface="$1"
	error="$2"
	proto_notify_error "$interface" "$error"
	# prevent netifd from trying to bring up interface over and over
	proto_block_restart "$interface"
	proto_setup_failed "$interface"
	exit 1
}

proto_openthread_setup() {
	interface="$1"
	device="$2"

	json_get_vars backbone_network dataset device radio_url verbose:0

	[ -n "$backbone_network" ] || proto_openthread_setup_error "$interface" MISSING_BACKBONE_NETWORK
	proto_add_host_dependency "$interface" "" "$backbone_network"
	network_get_device backbone_ifname "$backbone_network"

	[ -n "$backbone_ifname" ] || proto_openthread_setup_error "$interface" MISSING_BACKBONE_IFNAME
	[ -n "$device" ] || proto_openthread_setup_error "$interface" MISSING_DEVICE
	[ -n "$radio_url" ] || proto_openthread_setup_error "$interface" MISSING_RADIO_URL

	# run in subshell to prevent wiping json data needed for prefixes
	( proto_openthread_check_service mdnsd ) || proto_openthread_setup_error "$interface" MISSING_SVC_MDNSD

	opts="--auto-attach=0"
	[ "$verbose" -eq 0 ] || append opts -v
	append opts "-I$device"
	append opts "-B$backbone_ifname"
	append opts "$radio_url"
	append opts "trel://$backbone_ifname"
	# run in subshell to prevent wiping json data needed for prefixes
	( proto_run_command "$interface" "$PROG" $opts )

	ubus -t30 wait_for otbr

	[ -n "$dataset" ] && {
		$OTCTL dataset set active "$dataset"
	}

	json_for_each_item proto_openthread_add_prefix prefix
	mkdir -p /var/lib/thread
	ubus call otbr threadstart || proto_openthread_setup_error "$interface" MISSING_UBUS_OBJ
	$OTCTL netdata register

	proto_init_update "$device" 1 1
	proto_send_update "$interface"
}

proto_openthread_teardown() {
	interface="$1"
	ubus call otbr threadstop
	proto_kill_command "$interface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol openthread
}
