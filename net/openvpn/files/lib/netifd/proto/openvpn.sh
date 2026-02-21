#!/bin/sh
# OpenVPN netifd proto handler for OpenWrt
# Copyright (C) 2026
# shellcheck disable=SC1091,2046,2091,3043,3060

[ -x /usr/sbin/openvpn ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /usr/share/openvpn/openvpn.options # OPENVPN_* options
	. ../netifd-proto.sh
	. /usr/share/libubox/jshn.sh
	init_proto "$@"
}

# Helper to DRY up repeated option handling in init/setup
option_builder() {
	# option_builder <action:add|build> <LIST_VAR_NAME> <type>
	local action="$1"; shift
	local list_var="$1"; shift
	local opt_type="$1"; shift
	local f v

	for f in $(eval echo \$"$list_var")
	do
		f=${f%%:*}

		if [ "$action" = "add" ]; then
			case "$opt_type" in
				bool) proto_config_add_boolean "$f:bool" ;;
				protobool) proto_config_add_boolean "$f:protobool" ;;
				uinteger) proto_config_add_int "$f:uinteger" ;;
				integer) proto_config_add_int "$f:integer" ;;
				string) proto_config_add_string "$f:string" ;;
				protostring) proto_config_add_string "$f:protostring" ;;
				file) proto_config_add_string "$f:file" ;;
				list) proto_config_add_array "$f:list" ;;
			esac
		elif [ "$action" = "build" ]; then
			[ "${f#*:}" = "d" ] && [ "$allow_deprecated" = 0 ] && continue
			case "$opt_type" in
				bool)
					json_get_var v "$f"
					[ "$v" = 1 ] && append exec_params " --${f//_/-}"
					;;
				uinteger|integer|string)
					json_get_var v "$f"
					[ -n "$v" ] && append exec_params " --${f//_/-} $v"
					;;
				file)
					json_get_var v "$f"
					[ -f "$v" ] || continue
					[ -n "$v" ] && append exec_params " --${f//_/-} $v"
					;;
				list)
					json_get_values v "$f"
					[ -n "${v}" ] && append exec_params "$(for d in $v; do echo " --${f//_/-} $d"; done)"
					;;
			esac
		fi
	done
}


# Not real config params used by openvpn - only by our proto handler
PROTO_BOOLS='
allow_deprecated
'

PROTO_STRINGS='
username
password
cert_password
'

proto_openvpn_init_config() {
	available=1
	no_device=1
	lasterror=1
	renew_handler=1

	# There may be opvnvpn options which mean that a tap L2 device exists.
	# TODO: Set no_device to depend on tap device

	proto_add_dynamic_defaults

	# Add proto config options - netifd compares these for changes between interface events
	option_builder add PROTO_BOOLS protobool
	option_builder add PROTO_STRINGS string
	option_builder add OPENVPN_BOOLS bool
	option_builder add OPENVPN_UINTS uinteger
	option_builder add OPENVPN_INTS integer
	option_builder add OPENVPN_PARAMS_STRING string
	option_builder add OPENVPN_PARAMS_FILE file
	option_builder add OPENVPN_LIST list

}


proto_openvpn_setup() {
	local config="$1"
	local allow_deprecated exec_params
	allow_deprecated=0

	exec_params=

	json_get_var allow_deprecated allow_deprecated

	# Build exec params from configured options we get from ubus values stored during init_config
	option_builder build OPENVPN_BOOLS bool
	option_builder build OPENVPN_UINTS uinteger
	option_builder build OPENVPN_INTS integer
	option_builder build OPENVPN_PARAMS_STRING string
	option_builder build OPENVPN_PARAMS_FILE file
	option_builder build OPENVPN_LIST list

	proto_add_dynamic_defaults

	json_get_var username username
	json_get_var password password
	json_get_var cert_password cert_password
	json_get_var config_file config

	mkdir -p /var/run
	# combine into --askpass:
	if [ -n "$cert_password" ]; then
		cp_file="/var/run/openvpn.$config.pass"
		umask 077
		printf '%s\n' "${cert_password:-}" > "$cp_file"
		umask 022
		append exec_params " --askpass $cp_file"
	elif [ -n "$askpass" ]; then
		append exec_params " --askpass $askpass"
	fi

	# combine into --auth-user-pass:
	if [ -n "$username" ] || [ -n "$password" ]; then
		auth_file="/var/run/openvpn.$config.auth"
		umask 077
		printf '%s\n' "${username:-}" "${password:-}" > "$auth_file"
		umask 022
		append exec_params " --auth-user-pass $auth_file"
	elif [ -n "$auth_user_pass" ]; then
		auth_file="$auth_user_pass"
	fi

	# shellcheck disable=SC2154
	cd_dir="${config_file%/*}"
	[ "$cd_dir" = "$config_file" ] && cd_dir="/"

	# Testing option
	# ${tls_exit:+--tls-exit} \

	json_get_var dev_type dev_type
	# shellcheck disable=SC2086
	proto_run_command "$config" openvpn \
		$([ -z "$dev_type" ] && echo " --dev-type tun") \
		--cd "$cd_dir" \
		--status "/var/run/openvpn.$config.status" \
		--syslog "openvpn_$config" \
		--tmp-dir "/var/run" \
		$exec_params

	# last param wins; user provided status or syslog supersedes these.

}

proto_openvpn_renew() {
	config="$1"
	local sigusr1

	sigusr1="$(kill -l SIGUSR1)"
	[ -n "$sigusr1" ] && proto_kill_command "$config" "$sigusr1"

}

proto_openvpn_teardown() {
	local iface="$1"
	rm -f \
		"/var/run/openvpn.$iface.pass" \
		"/var/run/openvpn.$iface.auth" \
		"/var/run/openvpn.$iface.status" 
	proto_kill_command "$iface"
}


[ -n "$INCLUDE_ONLY" ] || {
	add_protocol openvpn
}
