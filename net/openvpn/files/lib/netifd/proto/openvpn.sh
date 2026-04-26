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

CONF_DIR="/var/run"
CONF_PREFIX="${CONF_DIR}/openvpn."

# Helper to DRY up repeated option handling in init/setup
option_builder() {
	# option_builder <action:add|build> <LIST_VAR_NAME> <type>
	local action="$1"; shift
	local list_var="$1"; shift
	local opt_type="$1"; shift
	local f v

	for f in $(eval echo \$"$list_var")
	do
		if [ "$action" = "add" ]; then
			f=${f%%:*}
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
			f=${f%%:*}
			case "$opt_type" in
				bool)
					json_get_var v "$f"
					[ "$v" = 1 ] && append exec_params "--${f//_/-}"
					;;
				uinteger|integer|string)
					json_get_var v "$f"
					case $f in
						push_remove)
							[ -n "$v" ] && append exec_params "--${f//_/-} '$v'"
						;;
						*)
							[ -n "$v" ] && append exec_params "--${f//_/-} $v"
						;;
					esac
					;;
				file)
					json_get_var v "$f"
					[ -f "$v" ] || continue
					[ -n "$v" ] && append exec_params "--${f//_/-} '$v'"
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
							case $f in
								push)
									append exec_params "--${f//_/-} '$val'"
								;;
								*)
									append exec_params "--${f//_/-} $val"
								;;
							esac
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
defaultroute
ipv6
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

# rewrite_config_line <dst> <old_path> <new_path>
# Replace a `config <old_path>` line in <dst> with `config <new_path>`.
# Handles absolute path, relative filename, no quotes / single quotes / double quotes,
# and optional trailing whitespace.
rewrite_config_line() {
	local dst="$1"
	local old="$2"
	local new="$3"
	local fname="${old##*/}"

	# absolute path, three quote styles
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)${old}[[:space:]]*$|\1${new}|"         "$dst"
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)'${old}'[[:space:]]*$|\1${new}|"       "$dst"
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)\"${old}\"[[:space:]]*$|\1${new}|"     "$dst"
	# relative filename, three quote styles
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)${fname}[[:space:]]*$|\1${new}|"       "$dst"
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)'${fname}'[[:space:]]*$|\1${new}|"     "$dst"
	sed -i "s|^\([[:space:]]*config[[:space:]]\+\)\"${fname}\"[[:space:]]*$|\1${new}|"   "$dst"
}

# Recursively copy config files referenced by `config` directives.
# Updates the `config` paths in the destination file to point to the copies.
# Appends all copied files to the global CONFIG_FILES variable.
#
# Usage: copy_config_recursive <dst_file> <visited>
#   dst_file: the already-copied config file to scan for `config` lines
#   visited:  pipe-delimited list of source paths already processed (cycle guard)
copy_config_recursive() {
	local dst="$1"
	local visited="$2"
	local ref dst_ref fname

	while IFS= read -r ref; do
		# skip empty lines
		[ -n "$ref" ] || continue

		# expand relative path to absolute using cd_dir
		case "$ref" in
			/*) ;;
			*) ref="$cd_dir/$ref" ;;
		esac

		# cycle guard
		case "$visited" in
			*"|$ref|"*) continue ;;
		esac

		[ -f "$ref" ] || continue

		fname="${ref##*/}"
		dst_ref="${CONF_PREFIX}${config}.user_${fname}"

		cp "$ref" "$dst_ref" || {
			logger -t "openvpn_$config(proto)" -p daemon.err "failed to copy config '$ref' to '$dst_ref'"
			continue
		}

		# rewrite the `config` line in the parent file to point to the copy
		rewrite_config_line "$dst" "$ref" "$dst_ref"

		# accumulate file list
		CONFIG_FILES="$CONFIG_FILES $dst_ref"

		# recurse
		copy_config_recursive "$dst_ref" "$visited|$ref|"

	done <<EOF
$(grep -E '^[[:space:]]*config[[:space:]]+' "$dst" \
	| grep -v "${CONF_PREFIX}" \
	| sed "s/^[[:space:]]*config[[:space:]]*//" \
	| sed "s/^['\"]//;s/[[:space:]]*['\"][[:space:]]*$//;s/[[:space:]]*$//")
EOF
}

proto_openvpn_setup() {
	local config="$1"
	local conf_file="${CONF_PREFIX}$config.conf"
	local exec_params cd_dir

	mkdir -p "$CONF_DIR"
	exec_params=

	json_get_var dev_type dev_type
	[ -z "$dev_type" ] && append exec_params "--dev-type tun"
	json_get_var ovpnproto ovpnproto
	[ -n "$ovpnproto" ] && append exec_params "--proto $ovpnproto"

	json_get_var config_file config
	# shellcheck disable=SC2154
	cd_dir="${config_file%/*}"
	[ "$cd_dir" = "$config_file" ] && cd_dir="/"
	append exec_params "--cd $cd_dir"
	append exec_params "--status ${CONF_PREFIX}$config.status"
	append exec_params "--syslog openvpn_$config"
	append exec_params "--tmp-dir /tmp"

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

	json_get_vars auth_user_pass askpass username password cert_password

	# Testing option
	# ${tls_exit:+--tls-exit} \

	# Check 'script_security' option
	json_get_var script_security script_security
	[ -z "$script_security" ] && script_security=2

	# Add default hotplug handling if 'script_security' option is ge '2'
	if [ "$script_security" -ge '2' ]; then
		local up down route_up route_pre_down
		local client tls_client tls_server
		local tls_crypt_v2_verify mode learn_address client_connect
		local client_crresponse client_disconnect auth_user_pass_verify

		json_get_vars up down route_up route_pre_down
		json_get_vars tls_crypt_v2_verify mode learn_address client_connect
		json_get_vars client_crresponse client_disconnect auth_user_pass_verify

		json_get_vars ifconfig_noexec route_noexec

		[ -n "$up" ] && append exec_params "--setenv user_up '$up'"
		[ -n "$down" ] && append exec_params "--setenv user_down '$down'"
		[ -n "$route_up" ] && append exec_params "--setenv user_route_up '$route_up'"
		[ -n "$route_pre_down" ] && append exec_params "--setenv user_route_pre_down '$route_pre_down'"

		append exec_params "--tls-crypt-v2-verify '/usr/libexec/openvpn-hotplug'"
		[ -n "$tls_crypt_v2_verify" ] && append exec_params "--setenv user_tls_crypt_v2_verify '$tls_crypt_v2_verify'"

		[ "$mode" = 'server' ] && {
			append exec_params "--learn-address '/usr/libexec/openvpn-hotplug'"
			[ -n "$learn_address" ] && append exec_params "--setenv user_learn_address '$learn_address'"
			append exec_params "--client-connect '/usr/libexec/openvpn-hotplug'"
			[ -n "$client_connect" ] && append exec_params "--setenv user_client_connect '$client_connect'"
			append exec_params "--client-crresponse '/usr/libexec/openvpn-hotplug'"
			[ -n "$client_crresponse" ] && append exec_params "--setenv user_client_crresponse '$client_crresponse'"
			append exec_params "--client-disconnect '/usr/libexec/openvpn-hotplug'"
			[ -n "$client_disconnect" ] && append exec_params "--setenv user_client_disconnect '$client_disconnect'"

			[ -n "$auth_user_pass_verify" ] && {
				append exec_params "--auth-user-pass-verify '/usr/libexec/openvpn-hotplug' via-file"
				append exec_params "--setenv user_auth_user_pass_verify '$auth_user_pass_verify'"
			}
		}

		json_get_vars client tls_client tls_server
		if [ "$client" = 1 ] || [ "$tls_client" = 1 ]; then
			append exec_params "--ipchange '/usr/libexec/openvpn-hotplug'"
			json_get_var ipchange ipchange
			[ -n "$ipchange" ] && append exec_params "--setenv user_ipchange '$ipchange'"
		fi

		if [ "$tls_client" = 1 ] || [ "$tls_server" = 1 ]; then
			append exec_params "--tls-verify '/usr/libexec/openvpn-hotplug'"
			json_get_var tls_verify tls_verify
			[ -n "$tls_verify" ] && append exec_params "--setenv user_tls_verify '$tls_verify'"
		fi
	fi

	# Write first-phase params to conf_file
	eval "set -- $exec_params"
	umask 077
	printf "%b\n" "${exec_params//--/\\n}" > "$conf_file"
	umask 022

	local CONFIG_FILES="$conf_file"
	# Copy user config and recursively copy all referenced config files,
	# rewriting `config` directives to point to the copies in CONF_DIR.
	local user_conf="${CONF_PREFIX}$config.user.conf"
	if [ -n "$config_file" -a -e "$config_file" ]; then
		cp "$config_file" "$user_conf" || {
			logger -t "openvpn_$config(proto)" -p daemon.err "failed to copy config '$config_file'"
			return 1
		}
		CONFIG_FILES="$CONFIG_FILES $user_conf"
		copy_config_recursive "$user_conf" ""

		# Update the `config` reference in conf_file to point to the copied user_conf.
		rewrite_config_line "$conf_file" "$config_file" "$user_conf"
	fi

	is_openvpn_client() {
		grep -qE '^[[:space:]]*remote[[:space:]]+' $CONFIG_FILES && return 0
	}

	local ipv6 defaultroute
	exec_params=

	# combine into --askpass:
	if [ -n "$cert_password" ]; then
		cp_file="${CONF_PREFIX}$config.pass"
		umask 077
		printf '%s\n' "${cert_password:-}" > "$cp_file"
		umask 022
		append exec_params "--askpass $cp_file"
	elif [ -n "$askpass" ]; then
		append exec_params "--askpass $askpass"
	fi

	# combine into --auth-user-pass:
	if [ -n "$username" ] || [ -n "$password" ]; then
		auth_file="${CONF_PREFIX}$config.auth"
		umask 077
		printf '%s\n' "${username:-}" "${password:-}" > "$auth_file"
		umask 022
		append exec_params "--auth-user-pass $auth_file"
	elif [ -n "$auth_user_pass" ]; then
		append exec_params "--auth-user-pass $auth_user_pass"
	fi

	#Always Override Options
	append exec_params "--setenv INTERFACE $config"
	append exec_params "--script-security 3"
	append exec_params "--ifconfig-noexec"
	append exec_params "--route-noexec"
	append exec_params "--up '/usr/libexec/openvpn-hotplug'"
	append exec_params "--down '/usr/libexec/openvpn-hotplug'"
	append exec_params "--route-up '/usr/libexec/openvpn-hotplug'"
	append exec_params "--route-pre-down '/usr/libexec/openvpn-hotplug'"
	append exec_params "--persist-tun"
	append exec_params "--persist-key"

	# filter out dup options - applied to all copied config files
	sed -i '/^[[:space:]]*script-security[[:space:]]*/s/^/# /'   $CONFIG_FILES
	sed -i '/^[[:space:]]*ifconfig-noexec[[:space:]]*/s/^/# /'   $CONFIG_FILES
	sed -i '/^[[:space:]]*route-noexec[[:space:]]*/s/^/# /'      $CONFIG_FILES
	sed -i '/^[[:space:]]*up[[:space:]]/s/^/# /'                 $CONFIG_FILES
	sed -i '/^[[:space:]]*down[[:space:]]/s/^/# /'               $CONFIG_FILES
	sed -i '/^[[:space:]]*route-up[[:space:]]/s/^/# /'           $CONFIG_FILES
	sed -i '/^[[:space:]]*route-pre-down[[:space:]]/s/^/# /'     $CONFIG_FILES
	sed -i '/^[[:space:]]*persist-tun[[:space:]]*/s/^/# /'       $CONFIG_FILES
	sed -i '/^[[:space:]]*persist-key[[:space:]]*/s/^/# /'       $CONFIG_FILES

	json_get_vars ipv6 defaultroute
	#default ipv6 is enabled
	[ -n "$ipv6" ] || ipv6=1
	append exec_params "--setenv IPV6 $ipv6"

	if is_openvpn_client; then
		append exec_params "--redirect-gateway def1 ipv6"
		[ -n "$defaultroute" ] || defaultroute=1
		sed -i '/^[[:space:]]*redirect-gateway[[:space:]]*/s/^/# /' $CONFIG_FILES
	else
		defaultroute=0
	fi
	append exec_params "--setenv DEFAULTROUTE $defaultroute"

	proto_run_command "$config" openvpn $exec_params --config "$conf_file"

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

	proto_kill_command "$iface"
	[ -n "$iface" ] && rm -f "${CONF_PREFIX}${iface}."*

	/usr/libexec/openvpn-hotplug cleanup "$iface"

	proto_init_update "*" 0
	proto_send_update "$iface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol openvpn
}
