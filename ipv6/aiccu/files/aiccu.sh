#!/bin/sh
# aiccu.sh - AICCU proto
# Copyright (c) 2014 OpenWrt.org

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_aiccu_setup() {
	local cfg="$1"
	local iface="$2"
	local link="aiccu-$cfg"

	local username password protocol server ip6prefix tunnelid requiretls defaultroute nat heartbeat verbose sourcerouting ip6addr ntpsynctimeout
	json_get_vars username password protocol server ip6prefix tunnelid requiretls defaultroute nat heartbeat verbose sourcerouting ip6addr ntpsynctimeout

	[ -z "$username" -o -z "$password" ] && {
		proto_notify_error "$cfg" "MISSING_USERNAME_OR_PASSWORD"
		proto_block_restart "$cfg"
		return
	}

	( proto_add_host_dependency "$cfg" 0.0.0.0 )

	CFGFILE="/var/etc/${link}.conf"
	PIDFILE="/var/run/${link}.pid"
	NTPSTRATUMFILE="/var/run/aiccu_ntp_stratum"
	mkdir -p /var/run /var/etc

	echo "username $username" > "$CFGFILE"
	echo "password $password" >> "$CFGFILE"
	echo "ipv6_interface $link" >> "$CFGFILE"
	[ -n "$server" ] && echo "server $server" >> "$CFGFILE"
	[ -n "$protocol" ] && echo "protocol $protocol" >> "$CFGFILE"
	[ -n "$tunnelid" ] && echo "tunnel_id $tunnelid" >> "$CFGFILE"
	[ "$requiretls" == 1 ] && echo "requiretls true" >> "$CFGFILE"
	[ "$nat" == 1 ] && echo "behindnat true" >> "$CFGFILE"
	[ "$heartbeat" == 1 ] && echo "makebeats true" >> "$CFGFILE"
	[ "$verbose" == 1 ] && echo "verbose true" >> "$CFGFILE"
	echo "defaultroute false" >> "$CFGFILE"
	echo "daemonize true" >> "$CFGFILE"
	echo "pidfile $PIDFILE" >> "$CFGFILE"

	# By default, wait at most 90 seconds for NTP sync
	[ -z "$ntpsynctimeout" ] && ntpsynctimeout=90
	for i in $(seq 1 $ntpsynctimeout); do
		[ -f "$NTPSTRATUMFILE" ] && \
		[ "$(cat $NTPSTRATUMFILE)" -lt 16 ] && \
		echo "NTP synced, stratum $(cat $NTPSTRATUMFILE)" && break
		[ "$(( $i % 10 ))" -eq 0 ] && echo "Waiting ${i} secs for NTP sync..."
		sleep 1
	done

	aiccu start "$CFGFILE"

	[ "$?" -ne 0 ] && {
		proto_notify_error "$cfg" "AICCU_FAILED_SEE_LOG"
		proto_block_restart "$cfg"
		return
	}

	proto_init_update "$link" 1

	local source=""
	[ "$sourcerouting" != "0" ] && source="::/128"
	[ "$defaultroute" != "0" ] && proto_add_ipv6_route "::" 0 "" "" "" "$source"

	[ -n "$ip6addr" ] && {
		local local6="${ip6addr%%/*}"
		local mask6="${ip6addr##*/}"
		[[ "$local6" = "$mask6" ]] && mask6=
		proto_add_ipv6_address "$local6" "$mask6"
		[ "$defaultroute" != "0" -a "$sourcerouting" != "0" ] && proto_add_ipv6_route "::" 0 "" "" "" "$local6/$mask6"
	}

	[ -n "$ip6prefix" ] && {
		proto_add_ipv6_prefix "$ip6prefix"
		[ "$defaultroute" != "0" -a "$sourcerouting" != "0" ] && proto_add_ipv6_route "::" 0 "" "" "" "$ip6prefix"
	}

	proto_send_update "$cfg"

}

proto_aiccu_teardown() {
	local cfg="$1"
	local link="aiccu-$cfg"
	CFGFILE="/var/etc/${link}.conf"
	PIDFILE="/var/run/${link}.pid"
	[ -f "$CFGFILE" -a -f "$PIDFILE" ] && {
		local pid="$(cat "$PIDFILE")"
		[ -d /proc/$pid -a $(cat /proc/$pid/comm) = "aiccu" ] && \
		aiccu stop "$CFGFILE"
	}
}

proto_aiccu_init_config() {
	no_device=1
	available=1
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_string "protocol"
	proto_config_add_string "server"
	proto_config_add_string "ip6addr:ip6addr"
	proto_config_add_string "ip6prefix:ip6addr"
	proto_config_add_string "tunnelid"
	proto_config_add_boolean "requiretls"
	proto_config_add_boolean "defaultroute"
	proto_config_add_boolean "sourcerouting"
	proto_config_add_boolean "nat"
	proto_config_add_boolean "heartbeat"
	proto_config_add_boolean "verbose"
	proto_config_add_int "ntpsynctimeout"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol aiccu
}
