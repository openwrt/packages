#!/bin/sh
# Copyright 2016-2017 Dan Luedtke <mail@danrl.com>
# Copyright (C) 2026 Karen Khachatryan <karen0734@gmail.com>
# Licensed to the public under the Apache License 2.0.
# shellcheck disable=SC2317

AWG=/usr/bin/awg
if [ ! -x $AWG ]; then
	logger -t "amneziawg" "error: missing amneziawg-tools (${AWG})"
	exit 0
fi

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_amneziawg_init_config() {
	renew_handler=1
	peer_detect=1

	proto_config_add_string "private_key"
	proto_config_add_int "listen_port"
	proto_config_add_int "mtu"
	proto_config_add_string "fwmark"
	proto_config_add_string "addresses"

	# AmneziaWG specific parameters
	proto_config_add_int "awg_jc"
	proto_config_add_int "awg_jmin"
	proto_config_add_int "awg_jmax"
	proto_config_add_int "awg_s1"
	proto_config_add_int "awg_s2"
	proto_config_add_int "awg_s3"
	proto_config_add_int "awg_s4"
	proto_config_add_string "awg_h1"
	proto_config_add_string "awg_h2"
	proto_config_add_string "awg_h3"
	proto_config_add_string "awg_h4"
	proto_config_add_string "awg_i1"
	proto_config_add_string "awg_i2"
	proto_config_add_string "awg_i3"
	proto_config_add_string "awg_i4"
	proto_config_add_string "awg_i5"
	proto_config_add_string "awg_header_protection_key"
	proto_config_add_string "awg_content_padding_addition"
	proto_config_add_string "awg_rekey_after_time"
	proto_config_add_string "awg_rekey_timeout"
	proto_config_add_string "awg_reject_after_time"
	proto_config_add_string "awg_keepalive_timeout"
	proto_config_add_string "awg_max_handshake_attempts"
	proto_config_add_boolean "awg_random_trailers"
	proto_config_add_boolean "awg_disable_cookies"

	available=1
	no_proto_task=1
}

ensure_key_is_generated() {
	local private_key
	private_key="$(uci get network."$1".private_key)"

	if [ "$private_key" = "generate" ] || [ -z "$private_key" ]; then
		private_key="$("${AWG}" genkey)"
		uci -q set network."$1".private_key="$private_key" && \
			uci -q commit network
	fi
}

proto_amneziawg_setup() {
	local config="$1"

	local private_key listen_port mtu fwmark addresses ip6prefix nohostroute tunlink

	# AmneziaWG specific parameters
	local awg_jc
	local awg_jmin
	local awg_jmax
	local awg_s1
	local awg_s2
	local awg_s3
	local awg_s4
	local awg_h1
	local awg_h2
	local awg_h3
	local awg_h4
	local awg_i1
	local awg_i2
	local awg_i3
	local awg_i4
	local awg_i5
	local awg_header_protection_key
	local awg_content_padding_addition
	local awg_rekey_after_time
	local awg_rekey_timeout
	local awg_reject_after_time
	local awg_keepalive_timeout
	local awg_max_handshake_attempts
	local awg_random_trailers
	local awg_disable_cookies

	ensure_key_is_generated "${config}"

	config_load network
	config_get private_key "${config}" "private_key"
	config_get listen_port "${config}" "listen_port"
	config_get addresses "${config}" "addresses"
	config_get mtu "${config}" "mtu"
	config_get fwmark "${config}" "fwmark"
	config_get ip6prefix "${config}" "ip6prefix"
	config_get nohostroute "${config}" "nohostroute"
	config_get tunlink "${config}" "tunlink"

	# AmneziaWG specific parameters
	config_get awg_jc "${config}" "awg_jc"
	config_get awg_jmin "${config}" "awg_jmin"
	config_get awg_jmax "${config}" "awg_jmax"
	config_get awg_s1 "${config}" "awg_s1"
	config_get awg_s2 "${config}" "awg_s2"
	config_get awg_s3 "${config}" "awg_s3"
	config_get awg_s4 "${config}" "awg_s4"
	config_get awg_h1 "${config}" "awg_h1"
	config_get awg_h2 "${config}" "awg_h2"
	config_get awg_h3 "${config}" "awg_h3"
	config_get awg_h4 "${config}" "awg_h4"
	config_get awg_i1 "${config}" "awg_i1"
	config_get awg_i2 "${config}" "awg_i2"
	config_get awg_i3 "${config}" "awg_i3"
	config_get awg_i4 "${config}" "awg_i4"
	config_get awg_i5 "${config}" "awg_i5"
	config_get awg_header_protection_key "${config}" "awg_header_protection_key"
	config_get awg_content_padding_addition "${config}" "awg_content_padding_addition"
	config_get awg_rekey_after_time "${config}" "awg_rekey_after_time"
	config_get awg_rekey_timeout "${config}" "awg_rekey_timeout"
	config_get awg_reject_after_time "${config}" "awg_reject_after_time"
	config_get awg_keepalive_timeout "${config}" "awg_keepalive_timeout"
	config_get awg_max_handshake_attempts "${config}" "awg_max_handshake_attempts"
	config_get_bool awg_random_trailers "${config}" "awg_random_trailers" ""
	config_get_bool awg_disable_cookies "${config}" "awg_disable_cookies" ""

	# Add the link only if it didn't already exist
	ip -br link show "${config}" >/dev/null 2>&1 || ip link add dev "${config}" type amneziawg

	[ -n "${mtu}" ] && ip link set mtu "${mtu}" dev "${config}"

	proto_init_update "${config}" 1

	# Build AmneziaWG configuration entirely in memory
	local awg_config="[Interface]\n"
	awg_config="${awg_config}PrivateKey=${private_key}\n"
	[ -n "${listen_port}" ]	&& awg_config="${awg_config}ListenPort=${listen_port}\n"
	[ -n "${fwmark}" ]		&& awg_config="${awg_config}FwMark=${fwmark}\n"

	# AmneziaWG specific parameters
	[ -n "${awg_jc}" ] && awg_config="${awg_config}Jc=${awg_jc}\n"
	[ -n "${awg_jmin}" ] && awg_config="${awg_config}Jmin=${awg_jmin}\n"
	[ -n "${awg_jmax}" ] && awg_config="${awg_config}Jmax=${awg_jmax}\n"
	[ -n "${awg_s1}" ] && awg_config="${awg_config}S1=${awg_s1}\n"
	[ -n "${awg_s2}" ] && awg_config="${awg_config}S2=${awg_s2}\n"
	[ -n "${awg_s3}" ] && awg_config="${awg_config}S3=${awg_s3}\n"
	[ -n "${awg_s4}" ] && awg_config="${awg_config}S4=${awg_s4}\n"
	[ -n "${awg_h1}" ] && awg_config="${awg_config}H1=${awg_h1}\n"
	[ -n "${awg_h2}" ] && awg_config="${awg_config}H2=${awg_h2}\n"
	[ -n "${awg_h3}" ] && awg_config="${awg_config}H3=${awg_h3}\n"
	[ -n "${awg_h4}" ] && awg_config="${awg_config}H4=${awg_h4}\n"
	[ -n "${awg_i1}" ] && awg_config="${awg_config}I1=${awg_i1}\n"
	[ -n "${awg_i2}" ] && awg_config="${awg_config}I2=${awg_i2}\n"
	[ -n "${awg_i3}" ] && awg_config="${awg_config}I3=${awg_i3}\n"
	[ -n "${awg_i4}" ] && awg_config="${awg_config}I4=${awg_i4}\n"
	[ -n "${awg_i5}" ] && awg_config="${awg_config}I5=${awg_i5}\n"
	[ -n "${awg_header_protection_key}" ] && awg_config="${awg_config}HeaderProtectionKey=${awg_header_protection_key}\n"
	[ -n "${awg_content_padding_addition}" ] && awg_config="${awg_config}ContentPaddingAddition=${awg_content_padding_addition}\n"
	[ -n "${awg_rekey_after_time}" ] && awg_config="${awg_config}RekeyAfterTime=${awg_rekey_after_time}\n"
	[ -n "${awg_rekey_timeout}" ] && awg_config="${awg_config}RekeyTimeout=${awg_rekey_timeout}\n"
	[ -n "${awg_reject_after_time}" ] && awg_config="${awg_config}RejectAfterTime=${awg_reject_after_time}\n"
	[ -n "${awg_keepalive_timeout}" ] && awg_config="${awg_config}KeepaliveTimeout=${awg_keepalive_timeout}\n"
	[ -n "${awg_max_handshake_attempts}" ] && awg_config="${awg_config}MaxHandshakeAttempts=${awg_max_handshake_attempts}\n"
	[ -n "${awg_random_trailers}" ] && awg_config="${awg_config}RandomTrailers=${awg_random_trailers}\n"
	[ -n "${awg_disable_cookies}" ] && awg_config="${awg_config}DisableCookies=${awg_disable_cookies}\n"

	# Collect peer configs into awg_config as well
	local peer_config
	peer_config=""
	proto_amneziawg_setup_peer_collect() {
		local section="$1"
		local peer_block

		config_get_bool route_allowed_ips "$section" "route_allowed_ips" 0
		config_get_bool disabled "$section" "disabled" 0
		[ "$disabled" = 1 ] && return;
		config_get peer_key "$section" "public_key"
		config_get peer_eph "$section" "endpoint_host"
		config_get peer_port "$section" "endpoint_port" "51820"
		config_get peer_a_ips "$section" "allowed_ips"
		config_get peer_p_ka "$section" "persistent_keepalive"
		config_get peer_psk "$section" "preshared_key"


		[ "${peer_eph##*:}" != "$peer_eph" ] && peer_eph="[$peer_eph]"
		peer_port=${peer_port:-51820}

		peer_block="\n[Peer]\n"
		[ -n "${peer_key}" ]	&& peer_block="${peer_block}PublicKey=${peer_key}\n"
		[ -n "${peer_psk}" ]	&& peer_block="${peer_block}PresharedKey=${peer_psk}\n"
		[ -n "${peer_eph}" ]	&& peer_block="${peer_block}Endpoint=${peer_eph}${peer_port:+:$peer_port}\n"
		[ -n "${peer_a_ips}" ]	&& peer_block="${peer_block}AllowedIPs=${peer_a_ips// /, }\n"
		[ -n "${peer_p_ka}" ]	&& peer_block="${peer_block}PersistentKeepalive=${peer_p_ka}\n"

		[ -n "$peer_key" ] && peer_config="$peer_config$peer_block\n"
		if [ $route_allowed_ips -ne 0 ]; then
			for allowed_ip in $peer_a_ips; do
				case "${allowed_ip}" in
					*:*/*) proto_add_ipv6_route "${allowed_ip%%/*}" "${allowed_ip##*/}" ;;
					*.*/*) proto_add_ipv4_route "${allowed_ip%%/*}" "${allowed_ip##*/}" ;;
					*:*) proto_add_ipv6_route "${allowed_ip%%/*}" "128" ;;
					*.*) proto_add_ipv4_route "${allowed_ip%%/*}" "32" ;;
				esac
			done
		fi

	}

	config_foreach proto_amneziawg_setup_peer_collect "amneziawg_${config}"

	# Combine interface + peer config into one variable
	awg_config="${awg_config}${peer_config}"

	# Apply configuration directly using awg syncconf via stdin
	printf "%b" "$awg_config" | ${AWG} syncconf "${config}" /dev/stdin
	local AWG_RETURN=$?

	if [ ${AWG_RETURN} -ne 0 ]; then
		echo "Could not sync AmneziaWG configuration"
		sleep 5
		proto_setup_failed "${config}"
		exit 1
	fi

	# Assign addresses
	for address in ${addresses}; do
		case "${address}" in
			*:*/*) proto_add_ipv6_address "${address%%/*}" "${address##*/}" ;;
			*.*/*) proto_add_ipv4_address "${address%%/*}" "${address##*/}" ;;
			*:*)   proto_add_ipv6_address "${address%%/*}" "128" ;;
			*.*)   proto_add_ipv4_address "${address%%/*}" "32" ;;
		esac
	done

	for prefix in ${ip6prefix}; do
		proto_add_ipv6_prefix "$prefix"
	done

	# Endpoint dependency tracking
	if [ "${nohostroute}" != "1" ]; then
		awg show "${config}" endpoints | \
		sed -E 's/\[?([0-9.:a-f]+)\]?:([0-9]+)/\1 \2/' | \
		while IFS=$'\t ' read -r key address port; do
			[ -n "${port}" ] || continue
			proto_add_host_dependency "${config}" "${address}" "${tunlink}"
		done
	fi

	proto_send_update "${config}"
}

proto_amneziawg_renew() {
	local interface="$1"
	proto_amneziawg_setup "$interface"
}

proto_amneziawg_teardown() {
	local config="$1"
	ip link del dev "${config}" >/dev/null 2>&1
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol amneziawg
}
