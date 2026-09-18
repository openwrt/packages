#!/bin/sh
# Copyright 2016-2017 Dan Luedtke <mail@danrl.com>
# Licensed to the public under the Apache License 2.0.

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
	proto_config_add_string "private_key"
	proto_config_add_int "listen_port"
	proto_config_add_int "mtu"
	proto_config_add_string "fwmark"
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
	available=1
	no_proto_task=1
}

proto_amneziawg_is_kernel_mode() {
	if [ ! -e /sys/module/amneziawg ]; then
		modprobe amneziawg > /dev/null 2>&1 || true

		if [ -e /sys/module/amneziawg ]; then
			return 0
		else
			if ! command -v "${WG_QUICK_USERSPACE_IMPLEMENTATION:-amneziawg-go}" >/dev/null; then
				ret=$?
				echo "Please install either kernel module (kmod-amneziawg package) or user-space implementation in /usr/bin/amneziawg-go."
				exit $ret
			else
				return 1
			fi
		fi
	else
		return 0
	fi
}

proto_amneziawg_setup_peer() {
	local peer_config="$1"

	local disabled
	local public_key
	local preshared_key
	local allowed_ips
	local route_allowed_ips
	local endpoint_host
	local endpoint_port
	local persistent_keepalive

	config_get_bool disabled "${peer_config}" "disabled" 0
	config_get public_key "${peer_config}" "public_key"
	config_get preshared_key "${peer_config}" "preshared_key"
	config_get allowed_ips "${peer_config}" "allowed_ips"
	config_get_bool route_allowed_ips "${peer_config}" "route_allowed_ips" 0
	config_get endpoint_host "${peer_config}" "endpoint_host"
	config_get endpoint_port "${peer_config}" "endpoint_port"
	config_get persistent_keepalive "${peer_config}" "persistent_keepalive"

	if [ "${disabled}" -eq 1 ]; then
		# skip disabled peers
		return 0
	fi

	if [ -z "$public_key" ]; then
		echo "Skipping peer config $peer_config because public key is not defined."
		return 0
	fi

	echo "[Peer]" >> "${awg_cfg}"
	echo "PublicKey=${public_key}" >> "${awg_cfg}"
	if [ "${preshared_key}" ]; then
		echo "PresharedKey=${preshared_key}" >> "${awg_cfg}"
	fi
	for allowed_ip in ${allowed_ips}; do
		echo "AllowedIPs=${allowed_ip}" >> "${awg_cfg}"
	done
	if [ "${endpoint_host}" ]; then
		case "${endpoint_host}" in
			*:*)
				endpoint="[${endpoint_host}]"
				;;
			*)
				endpoint="${endpoint_host}"
				;;
		esac
		if [ "${endpoint_port}" ]; then
			endpoint="${endpoint}:${endpoint_port}"
		else
			endpoint="${endpoint}:51820"
		fi
		echo "Endpoint=${endpoint}" >> "${awg_cfg}"
	fi
	if [ "${persistent_keepalive}" ]; then
		echo "PersistentKeepalive=${persistent_keepalive}" >> "${awg_cfg}"
	fi

	if [ ${route_allowed_ips} -ne 0 ]; then
		for allowed_ip in ${allowed_ips}; do
			case "${allowed_ip}" in
				*:*/*)
					proto_add_ipv6_route "${allowed_ip%%/*}" "${allowed_ip##*/}"
					;;
				*.*/*)
					proto_add_ipv4_route "${allowed_ip%%/*}" "${allowed_ip##*/}"
					;;
				*:*)
					proto_add_ipv6_route "${allowed_ip%%/*}" "128"
					;;
				*.*)
					proto_add_ipv4_route "${allowed_ip%%/*}" "32"
					;;
			esac
		done
	fi
}

ensure_key_is_generated() {
	local private_key
	private_key="$(uci get network."$1".private_key)"

	if [ "$private_key" == "generate" ]; then
		local ucitmp
		oldmask="$(umask)"
		umask 077
		ucitmp="$(mktemp -d)"
		private_key="$("${AWG}" genkey)"
		uci -q -t "$ucitmp" set network."$1".private_key="$private_key" && \
			uci -q -t "$ucitmp" commit network
		rm -rf "$ucitmp"
		umask "$oldmask"
	fi
}

proto_amneziawg_setup() {
	local config="$1"
	local awg_dir="/tmp/amneziawg"
	local awg_cfg="${awg_dir}/${config}"

	local private_key
	local listen_port
	local addresses
	local mtu
	local fwmark
	local ip6prefix
	local nohostroute
	local tunlink

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

	if proto_amneziawg_is_kernel_mode; then
		logger -t "amneziawg" "info: using kernel-space kmod-amneziawg for ${AWG}"
		ip link del dev "${config}" 2>/dev/null
		ip link add dev "${config}" type amneziawg
	else
		logger -t "amneziawg" "info: using user-space amneziawg-go for ${AWG}"
		rm -f "/var/run/amneziawg/${config}.sock"
		amneziawg-go "${config}"
	fi

	if [ "${mtu}" ]; then
		ip link set mtu "${mtu}" dev "${config}"
	fi

	proto_init_update "${config}" 1

	umask 077
	mkdir -p "${awg_dir}"
	echo "[Interface]" > "${awg_cfg}"
	echo "PrivateKey=${private_key}" >> "${awg_cfg}"
	if [ "${listen_port}" ]; then
		echo "ListenPort=${listen_port}" >> "${awg_cfg}"
	fi
	if [ "${fwmark}" ]; then
		echo "FwMark=${fwmark}" >> "${awg_cfg}"
	fi
	# AmneziaWG parameters
	if [ "${awg_jc}" ]; then
		echo "Jc=${awg_jc}" >> "${awg_cfg}"
	fi
	if [ "${awg_jmin}" ]; then
		echo "Jmin=${awg_jmin}" >> "${awg_cfg}"
	fi
	if [ "${awg_jmax}" ]; then
		echo "Jmax=${awg_jmax}" >> "${awg_cfg}"
	fi
	if [ "${awg_s1}" ]; then
		echo "S1=${awg_s1}" >> "${awg_cfg}"
	fi
	if [ "${awg_s2}" ]; then
		echo "S2=${awg_s2}" >> "${awg_cfg}"
	fi
	if [ "${awg_s3}" ]; then
		echo "S3=${awg_s3}" >> "${awg_cfg}"
	fi
	if [ "${awg_s4}" ]; then
		echo "S4=${awg_s4}" >> "${awg_cfg}"
	fi
	if [ "${awg_h1}" ]; then
		echo "H1=${awg_h1}" >> "${awg_cfg}"
	fi
	if [ "${awg_h2}" ]; then
		echo "H2=${awg_h2}" >> "${awg_cfg}"
	fi
	if [ "${awg_h3}" ]; then
		echo "H3=${awg_h3}" >> "${awg_cfg}"
	fi
	if [ "${awg_h4}" ]; then
		echo "H4=${awg_h4}" >> "${awg_cfg}"
	fi
	if [ "${awg_i1}" ]; then
		echo "I1=${awg_i1}" >> "${awg_cfg}"
	fi
	if [ "${awg_i2}" ]; then
		echo "I2=${awg_i2}" >> "${awg_cfg}"
	fi
	if [ "${awg_i3}" ]; then
		echo "I3=${awg_i3}" >> "${awg_cfg}"
	fi
	if [ "${awg_i4}" ]; then
		echo "I4=${awg_i4}" >> "${awg_cfg}"
	fi
	if [ "${awg_i5}" ]; then
		echo "I5=${awg_i5}" >> "${awg_cfg}"
	fi
	config_foreach proto_amneziawg_setup_peer "amneziawg_${config}"

	# Apply configuration file
	${AWG} setconf "${config}" "${awg_cfg}"
	AWG_RETURN=$?

	rm -f "${awg_cfg}"

	if [ ${AWG_RETURN} -ne 0 ]; then
		sleep 5
		proto_setup_failed "${config}"
		exit 1
	fi

	for address in ${addresses}; do
		case "${address}" in
			*:*/*)
				proto_add_ipv6_address "${address%%/*}" "${address##*/}"
				;;
			*.*/*)
				proto_add_ipv4_address "${address%%/*}" "${address##*/}"
				;;
			*:*)
				proto_add_ipv6_address "${address%%/*}" "128"
				;;
			*.*)
				proto_add_ipv4_address "${address%%/*}" "32"
				;;
		esac
	done

	for prefix in ${ip6prefix}; do
		proto_add_ipv6_prefix "$prefix"
	done

	# endpoint dependency
	if [ "${nohostroute}" != "1" ]; then
		${AWG} show "${config}" endpoints | \
		sed -E 's/\[?([0-9.:a-f]+)\]?:([0-9]+)/\1 \2/' | \
		while IFS=$'\t ' read -r key address port; do
			[ -n "${port}" ] || continue
			proto_add_host_dependency "${config}" "${address}" "${tunlink}"
		done
	fi

	proto_send_update "${config}"
}

proto_amneziawg_teardown() {
	local config="$1"
	if proto_amneziawg_is_kernel_mode; then
		ip link del dev "${config}" >/dev/null 2>&1
	else
		rm -f "/var/run/amneziawg/${config}.sock"
	fi
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol amneziawg
}
