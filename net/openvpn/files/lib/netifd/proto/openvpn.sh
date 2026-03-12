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
			[ "${f#*:}" = "d" ] && [ "$ALLOW_DEPRECATED" = 0 ] && continue
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
					[ -n "$v" ] && append exec_params " --${f//_/-} \"$v\""
					;;
				list)
					local type
					json_get_type type "$f"
					case "$type" in
					object|array)
						local keys key
						json_select "$f"
						json_get_keys keys
						for key in $keys; do
							json_get_var val "$key"
							append exec_params " --${f//_/-} \"$val\""
						done
						json_select ..
						;;
					*)  ;;
					esac
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
ovpnproto
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
	local exec_params cd_dir

	exec_params=

	json_get_var dev_type dev_type
	[ -z "$dev_type" ] && append exec_params " --dev-type tun"
	json_get_var ovpnproto ovpnproto
	[ -n "$ovpnproto" ] && append exec_params " --proto $ovpnproto"

	json_get_var config_file config
	# shellcheck disable=SC2154
	cd_dir="${config_file%/*}"
	[ "$cd_dir" = "$config_file" ] && cd_dir="/"
	append exec_params " --cd $cd_dir"
	append exec_params " --status /var/run/openvpn.$config.status"
	append exec_params " --syslog openvpn_$config"
	append exec_params " --tmp-dir /var/run"
	[ -n "$config_file" ] && append exec_params " --config \"$config_file\""

	json_get_var ALLOW_DEPRECATED allow_deprecated
	[ -z "$ALLOW_DEPRECATED" ] && ALLOW_DEPRECATED=0

	# Build exec params from configured options we get from ubus values stored during init_config
	option_builder build OPENVPN_BOOLS bool
	option_builder build OPENVPN_UINTS uinteger
	option_builder build OPENVPN_INTS integer
	option_builder build OPENVPN_PARAMS_STRING string
	option_builder build OPENVPN_PARAMS_FILE file
	option_builder build OPENVPN_LIST list

	proto_add_dynamic_defaults

	json_get_vars username password cert_password

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
		append exec_params " --auth-user-pass $auth_user_pass"
	fi

	# Testing option
	# ${tls_exit:+--tls-exit} \

	# Check 'script_security' option
	json_get_var script_security script_security
	[ -z "$script_security" ] && {
		script_security=3
	}

	# Add default hotplug handling if 'script_security' option is equal '3'
	if [ "$script_security" -eq '3' ]; then
		local up down route_up route_pre_down
		local client tls_client
		logger -t "openvpn(proto)" \
			-p daemon.info "Enabled default hotplug processing, as the openvpn configuration 'script_security' is '3'"

		append exec_params " --setenv INTERFACE $config"
		append exec_params " --script-security 3"

		json_get_vars up down route_up route_pre_down
		append exec_params "--up '/usr/libexec/openvpn-hotplug'"
		[ -n "$up" ] && append exec_params "--setenv user_up '$up'"

		append exec_params "--down '/usr/libexec/openvpn-hotplug'"
		[ -n "$down" ] && append exec_params "--setenv user_down '$down'"

		append exec_params "--route-up '/usr/libexec/openvpn-hotplug'"
		[ -n "$route_up" ] && append exec_params "--setenv user_route_up '$route_up'"

		append exec_params "--route-pre-down '/usr/libexec/openvpn-hotplug'"
		[ -n "$route_pre_down" ] && append exec_params "--setenv user_route_pre_down '$route_pre_down'"

		json_get_vars client tls_client
		if [ "$client" = 1 ] || [ "$tls_client" = 1 ]; then
			append exec_params "--ipchange '/usr/libexec/openvpn-hotplug'"
			json_get_var ipchange ipchange
			[ -n "$ipchange" ] && append exec_params "--setenv user_ipchange '$ipchange'"
		fi
	else
		logger -t "openvpn(proto)" \
			-p daemon.warn "Default hotplug processing disabled, as the openvpn configuration 'script_security' is less than '3'"
	fi

	eval "set -- $exec_params"
	proto_run_command "$config" openvpn "$@"

	# last param wins; user provided status or syslog supersedes.
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
