#!/bin/sh
#
# SPDX-FileCopyrightText: 2023 Stijn Tintel <stijn@linux-ipv6.be>
# SPDX-License-Identifier: GPL-2.0-only

OTCTL="/usr/sbin/ot-ctl"
PROG="/usr/sbin/otbr-agent"
RCP_PROG="/usr/sbin/otbr-rcp"

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

proto_openthread_init_config() {
	proto_config_add_array 'prefix:list(string)'
	proto_config_add_boolean verbose
	proto_config_add_string backbone_network
	proto_config_add_string dataset
	proto_config_add_string radio_url
	proto_config_add_string rcp
	proto_config_add_boolean rcp_firmware_update
	proto_config_add_int uart_baudrate
	proto_config_add_boolean uart_flow_control
	proto_config_add_string rest_listen_address
	proto_config_add_int rest_listen_port

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

proto_openthread_setup_retry() {
	# A missing RCP dongle is not a configuration error, but the interface
	# must still be blocked: netifd re-runs a failed setup immediately and
	# without backoff, which would busy-loop until a dongle appears. The
	# hotplug handler's ifup lifts the block, so recovery is unaffected;
	# this helper differs from proto_openthread_setup_error only in intent.
	proto_openthread_setup_error "$@"
}

proto_openthread_setup() {
	interface="$1"
	device="$2"

	mkdir -p /var/lib/thread

	json_get_vars backbone_network dataset device radio_url rcp \
		rcp_firmware_update:0 uart_baudrate:0 uart_flow_control:1 \
		rest_listen_address rest_listen_port verbose:0

	[ -n "$backbone_network" ] || proto_openthread_setup_error "$interface" MISSING_BACKBONE_NETWORK
	proto_add_host_dependency "$interface" "" "$backbone_network"
	network_get_device backbone_ifname "$backbone_network"

	[ -n "$backbone_ifname" ] || proto_openthread_setup_error "$interface" MISSING_BACKBONE_IFNAME
	[ -n "$device" ] || proto_openthread_setup_error "$interface" MISSING_DEVICE
	if [ -z "$radio_url" ]; then
		case "$rcp" in
		/dev/*)
			# A fixed serial device needs no discovery.
			radio_url="spinel+hdlc+uart://$rcp"
			;;
		*)
			# Let otbr-rcp locate the dongle by its USB properties and,
			# when a handler knows how, install or update its firmware.
			# This runs here rather than under the launched command: a
			# flash can take minutes, and it must not race the bounded
			# wait for the agent's ubus object below.
			#
			# Pick the one value we need out of the output rather than
			# evaluating it: otbr-rcp sources every firmware handler in
			# /usr/share/openthread-rcp/, and a handler that prints to
			# stdout would otherwise have its output run as root here.
			RCPTTY="$("$RCP_PROG" \
				$([ "$rcp_firmware_update" -eq 0 ] || echo --update) \
				"${rcp:-any}" | sed -n 's/^RCPTTY=//p')"
			[ -n "$RCPTTY" ] || \
				proto_openthread_setup_retry "$interface" RCP_NOT_FOUND
			radio_url="spinel+hdlc+uart://$RCPTTY"
			;;
		esac
		radio_url="${radio_url}?uart-exclusive"
		[ "$uart_baudrate" -eq 0 ] || radio_url="${radio_url}&uart-baudrate=${uart_baudrate}"
		[ "$uart_flow_control" -eq 0 ] || radio_url="${radio_url}&uart-flow-control"
	fi

	opts="--auto-attach=0"
	[ "$verbose" -eq 0 ] || append opts -v
	append opts "-I$device"
	append opts "-B$backbone_ifname"
	# The REST API listens on 127.0.0.1 by default. Bind it elsewhere (e.g. a
	# LAN address) to let remote clients such as Home Assistant reach it;
	# leaving it unset keeps the loopback-only default. The REST API is
	# unauthenticated and can both read and replace the Thread dataset, so any
	# non-loopback address must be firewalled to trusted hosts.
	[ -n "$rest_listen_address" ] && append opts "--rest-listen-address=$rest_listen_address"
	[ -n "$rest_listen_port" ] && append opts "--rest-listen-port=$rest_listen_port"
	append opts "$radio_url"
	append opts "trel://$backbone_ifname"
	# run in subshell to prevent wiping json data needed for prefixes
	( proto_run_command "$interface" "$PROG" $opts )

	ubus -t30 wait_for otbr

	[ -n "$dataset" ] && {
		$OTCTL dataset set active "$dataset"
	}

	json_for_each_item proto_openthread_add_prefix prefix
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
