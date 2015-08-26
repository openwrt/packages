#!/bin/sh
. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_openconnect_init_config() {
	proto_config_add_string "server"
	proto_config_add_int "port"
	proto_config_add_string "username"
	proto_config_add_string "serverhash"
	proto_config_add_string "authgroup"
	proto_config_add_string "password"
	proto_config_add_string "token_mode"
	proto_config_add_string "token_secret"
	proto_config_add_string "interface"
	proto_config_add_string "os"
	proto_config_add_string "csd_wrapper"
	no_device=1
	available=1
}

proto_openconnect_setup() {
	local config="$1"

	json_get_vars server port username serverhash authgroup password interface token_mode token_secret os csd_wrapper

	grep -q tun /proc/modules || insmod tun
	ifname="vpn-$config"

	logger -t openconnect "initializing..."
#	serv_addr=
#	for ip in $(resolveip -t 10 "$server"); do
#		( proto_add_host_dependency "$interface" "$ip" "$ifname" )
#		serv_addr=1
#	done
#	[ -n "$serv_addr" ] || {
#		logger -t openconnect "Could not resolve server address: '$server'"
#		sleep 5
#		proto_setup_failed "$config"
#		exit 1
#	}

	[ -n "$port" ] && port=":$port"

	cmdline="$server$port -i "$ifname" --non-inter --syslog --script /lib/netifd/vpnc-script"

	# migrate to standard config files
	[ -f "/etc/config/openconnect-user-cert-vpn-$config.pem" ] && mv "/etc/config/openconnect-user-cert-vpn-$config.pem" "/etc/openconnect/user-cert-vpn-$config.pem"
	[ -f "/etc/config/openconnect-user-key-vpn-$config.pem" ] && mv "/etc/config/openconnect-user-key-vpn-$config.pem" "/etc/openconnect/user-key-vpn-$config.pem"
	[ -f "/etc/config/openconnect-ca-vpn-$config.pem" ] && mv "/etc/config/openconnect-ca-vpn-$config.pem" "/etc/openconnect/ca-vpn-$config.pem"

	[ -f /etc/openconnect/user-cert-vpn-$config.pem ] && append cmdline "-c /etc/openconnect/user-cert-vpn-$config.pem"
	[ -f /etc/openconnect/user-key-vpn-$config.pem ] && append cmdline "--sslkey /etc/openconnect/user-key-vpn-$config.pem"
	[ -f /etc/openconnect/ca-vpn-$config.pem ] && {
		append cmdline "--cafile /etc/openconnect/ca-vpn-$config.pem"
		append cmdline "--no-system-trust"
	}
	[ -n "$serverhash" ] && {
		append cmdline " --servercert=$serverhash"
		append cmdline "--no-system-trust"
	}
	[ -n "$authgroup" ] && append cmdline "--authgroup $authgroup"
	[ -n "$username" ] && append cmdline "-u $username"
	[ -n "$password" ] && {
		umask 077
		mkdir -p /var/etc
		pwfile="/var/etc/openconnect-$config.passwd"
		echo "$password" > "$pwfile"
		append cmdline "--passwd-on-stdin"
	}

	[ -n "$token_mode" ] && append cmdline "--token-mode=$token_mode"
	[ -n "$token_secret" ] && append cmdline "--token-secret=$token_secret"
	[ -n "$os" ] && append cmdline "--os=$os"
	[ -n "$csd_wrapper" ] && [ -x "$csd_wrapper" ] && append cmdline "--csd-wrapper=$csd_wrapper"

	proto_export INTERFACE="$config"
	logger -t openconnect "executing 'openconnect $cmdline'"

	if [ -f "$pwfile" ]; then
		proto_run_command "$config" /usr/sbin/openconnect-wrapper $pwfile $cmdline
	else
		proto_run_command "$config" /usr/sbin/openconnect $cmdline
	fi
}

proto_openconnect_teardown() {
	local config="$1"

	pwfile="/var/etc/openconnect-$config.passwd"

	rm -f $pwfile
	logger -t openconnect "bringing down openconnect"
	proto_kill_command "$config" 2
}

add_protocol openconnect
