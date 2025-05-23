#!/bin/sh

DAEMON=/usr/bin/zerotier-one
CONFIG_PATH=/var/lib/zerotier-one

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_zerotier_init_config() {
	available=1
	no_device=1
	proto_config_add_string "network_id"
	proto_config_add_string "secret"
	proto_config_add_string "port"
	proto_config_add_string "config_path"
	proto_config_add_boolean "copy_config_path"
}

proto_zerotier_setup() {
	local interface="$1"

	local network_id secret port config_path copy_config_path
	local args=""

	config_load network
	config_get network_id "${interface}" "network_id"
	config_get secret "${interface}" "secret"
	config_get port "${interface}" "port"
	config_get config_path "${interface}" "config_path"
	config_get_bool copy_config_path "${interface}" "copy_config_path" 0

	path=${CONFIG_PATH}_$interface

	# Remove existing link or folder
	rm -rf "${path}"

	# Create link or copy files from CONFIG_PATH to config_path
	if [ -n "$config_path" -a "$config_path" != "$path" ]; then
		if [ ! -d "$config_path" ]; then
			echo "ZeroTier config_path does not exist: $config_path" 1>&2
			return
		fi

		# ensure that the target exists
		mkdir -p $(dirname "${path}")

		if [ "$copy_config_path" = "1" ]; then
			cp -r "$config_path" "${path}"
		else
			ln -s "$config_path" "${path}"
		fi
	fi

	mkdir -p "${path}"/networks.d
	touch "${path}"/networks.d/"${network_id}".conf

	# enforce service to use given interface name
	touch "${path}"/devicemap
	echo "${network_id}=${interface}" >> "${path}"/devicemap

	if [ -n "$port" ]; then
		args="$args -p${port}"
	else
		args="$args -p0"
	fi

	local secret
	secret="$(uci get network."${interface}".secret)"

	if [ -z "$secret" ]; then
		echo "Generate secret - please wait..."
		local sf="/tmp/zt.${interface}.secret"

		zerotier-idtool generate "$sf" > /dev/null
		[ $? -ne 0 ] && return 1

		secret="$(cat $sf)"
		rm "$sf"

		uci set network."${interface}".secret="$secret"
		uci commit network
	fi

	if [ -n "$secret" ]; then
		echo "$secret" > "${path}"/identity.secret
		# make sure there is not previous identity.public
		rm -f "${path}"/identity.public
	fi

	proto_run_command "${interface}" "${DAEMON}" -p0 "${path}"

	local status
	while true; do
		status="$(zerotier-cli -D${path} get ${network_id} status 2>/dev/null)"
		[ "$status" != "REQUESTING_CONFIGURATION" -a -n "$status" ] && break
		sleep 1
	done

	if [ "$status" != "OK" ]; then
		echo "Unable to connect"
		proto_zerotier_teardown
		proto_notify_error "$interface" "$status"
		return 1
	fi


	IP4ADDRS=
	IP6ADDRS=

	local addresses="$(ip -json address list dev "$interface")"
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

	local routes="$(ip -json route list dev "$interface")"
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

	proto_init_update "${interface}" 1

	PROTO_IPADDR="${IP4ADDRS}"
	PROTO_IP6ADDR="${IP6ADDRS}"

	PROTO_ROUTE="${IP4ROUTES}"
	PROTO_ROUTE6="${IP6ROUTES}"

	echo "Zerotier is up"

	proto_send_update "${interface}"
}

proto_zerotier_teardown() {
	local interface="$1"

	proto_kill_command "${interface}"

	# Wait for daemon to stop before removing config path otherwise there might be 'file not found' errors
	sleep 2

	# Remove existing link or folder
	rm -rf ${CONFIG_PATH}_"${interface}"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol zerotier
}
