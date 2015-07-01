#!/bin/sh /etc/rc.common

START=90
STOP=15

SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1
EXTRA_COMMANDS="rules"
CONFIG_FILE=/var/etc/shadowsocks.json

get_config() {
	config_get_bool enable $1 enable
	config_get_bool use_conf_file $1 use_conf_file
	config_get config_file $1 config_file
	config_get server $1 server
	config_get server_port $1 server_port
	config_get local $1 local
	config_get local_port $1 local_port
	config_get password $1 password
	config_get timeout $1 timeout
	config_get encrypt_method $1 encrypt_method
	config_get ignore_list $1 ignore_list
	config_get udp_relay $1 udp_relay
	config_get_bool tunnel_enable $1 tunnel_enable
	config_get tunnel_port $1 tunnel_port
	config_get tunnel_forward $1 tunnel_forward
	config_get lan_ac_mode $1 lan_ac_mode
	config_get lan_ac_ip $1 lan_ac_ip
	config_get wan_bp_ip $1 wan_bp_ip
	config_get wan_fw_ip $1 wan_fw_ip
	config_get ipt_ext $1 ipt_ext
	: ${timeout:=60}
	: ${udp_relay:=1}
	: ${local:=0.0.0.0}
	: ${local_port:=1080}
	: ${tunnel_port:=5300}
	: ${tunnel_forward:=8.8.4.4:53}
	: ${config_file:=/etc/shadowsocks/config.json}
}

start_rules() {
	local ac_args

	if [ -n "$lan_ac_ip" ]; then
		case $lan_ac_mode in
			1) ac_args="w$lan_ac_ip"
			;;
			2) ac_args="b$lan_ac_ip"
			;;
		esac
	fi
	/usr/bin/ss-rules \
		-c "$CONFIG_FILE" \
		-i "$ignore_list" \
		-a "$ac_args" \
		-b "$wan_bp_ip" \
		-w "$wan_fw_ip" \
		-e "$ipt_ext" \
		-o $udp
	return $?
}

start_redir() {
	service_start /usr/bin/ss-redir \
		-c "$CONFIG_FILE" \
		-b "$local" $udp
	return $?
}

start_tunnel() {
	service_start /usr/bin/ss-tunnel \
		-c "$CONFIG_FILE" \
		-b "$local" \
		-l "$tunnel_port" \
		-L "$tunnel_forward" \
		-u
	return $?
}

rules() {
	config_load shadowsocks
	config_foreach get_config shadowsocks
	[ "$enable" = 1 ] || exit 0
	[ "$udp_relay" = 1 ] && udp="-u"
	mkdir -p $(dirname $CONFIG_FILE)

	if [ "$use_conf_file" = 1 ]; then
		cat $config_file >$CONFIG_FILE
	else
		: ${server:?}
		: ${server_port:?}
		: ${password:?}
		: ${encrypt_method:?}
		cat <<-EOF >$CONFIG_FILE
			{
			    "server": "$server",
			    "server_port": $server_port,
			    "local_port": $local_port,
			    "password": "$password",
			    "timeout": $timeout,
			    "method": "$encrypt_method"
			}
EOF
	fi
	start_rules
}

boot() {
	until iptables-save -t nat | grep -q "^:zone_lan_prerouting"; do
		sleep 1
	done
	start
}

start() {
	rules && start_redir
	[ "$tunnel_enable" = 1 ] && start_tunnel
}

stop() {
	/usr/bin/ss-rules -f
	service_stop /usr/bin/ss-redir
	service_stop /usr/bin/ss-tunnel
	rm -f $CONFIG_FILE
}
