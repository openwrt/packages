#!/bin/sh
. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_openconnect_init_config() {
	proto_config_add_string "server"
	proto_config_add_int "port"
	proto_config_add_string "username"
	proto_config_add_string "cookie"
	proto_config_add_string "password"
	no_device=1
	available=1
}

proto_openconnect_setup() {
	local config="$1"

	json_get_vars server port username cookie password

	grep -q tun /proc/modules || insmod tun

	serv_addr=
	for ip in $(resolveip -t 5 "$server"); do
		proto_add_host_dependency "$config" "$server"
		serv_addr=1
	done
	[ -n "$serv_addr" ] || {
		echo "Could not resolve server address"
		sleep 5
		proto_setup_failed "$config"
		exit 1
	}

	[ -n "$port" ] && port=":$port"

	cmdline="$server$port -i vpn-$config --no-cert-check --non-inter --syslog --script /lib/netifd/vpnc-script"

	[ -n "$cookie" ] && append cmdline "-C $cookie"
	[ -n "$username" ] && append cmdline "-u $username"
	[ -n "$password" ] && {
		umask 077
		pwfile="/var/run/openconnect-$config.passwd"
		echo "$password" > "$pwfile"
		append cmdline "--passwd-on-stdin"
	}

	proto_export INTERFACE="$config"
	proto_run_command "$config" /usr/sbin/openconnect $cmdline <$pwfile
}

proto_openconnect_teardown() {
	proto_kill_command "$config"
}

add_protocol openconnect
