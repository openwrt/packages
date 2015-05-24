#!/bin/sh

[ -x /usr/sbin/xl2tpd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_l2tp_init_config() {
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_string "keepalive"
	proto_config_add_string "pppd_options"
	proto_config_add_boolean "ipv6"
	proto_config_add_int "mtu"
	proto_config_add_string "server"
	available=1
	no_device=1
	no_proto_task=1
}

proto_l2tp_setup() {
	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"

	local ip serv_addr server
	json_get_var server server && {
		for ip in $(resolveip -t 5 "$server"); do
			( proto_add_host_dependency "$interface" "$ip" )
			serv_addr=1
		done
	}
	[ -n "$serv_addr" ] || {
		echo "Could not resolve server address" >&2
		sleep 5
		proto_setup_failed "$interface"
		exit 1
	}

	if [ ! -p /var/run/xl2tpd/l2tp-control ]; then
		/etc/init.d/xl2tpd start

		local wait_timeout=0
		while [ ! -p /var/run/xl2tpd/l2tp-control ]; do
			wait_timeout=$(($wait_timeout + 1))
			[ "$wait_timeout" -gt 5 ] && {
				echo "Cannot find xl2tpd control file." >&2
				proto_setup_failed "$interface"
				exit 1
			}
			sleep 1
		done
	fi

	local ipv6 demand keepalive username password pppd_options
	json_get_vars ipv6 demand keepalive username password pppd_options
	[ "$ipv6" = 1 ] || ipv6=""
	if [ "${demand:-0}" -gt 0 ]; then
		demand="precompiled-active-filter /etc/ppp/filter demand idle $demand"
	else
		demand="persist"
	fi

	local mtu
	[ -n "$mtu" ] || json_get_var mtu mtu

	local interval="${keepalive##*[, ]}"
	[ "$interval" != "$keepalive" ] || interval=5

	mkdir -p /tmp/l2tp

	echo "${keepalive:+lcp-echo-interval $interval lcp-echo-failure ${keepalive%%[, ]*}}" > "${optfile}"
	echo "usepeerdns" >> "${optfile}"
	echo "nodefaultroute" >> "${optfile}"
	echo "${username:+user \"$username\" password \"$password\"}" >> "${optfile}"
	echo "ipparam \"$interface\"" >> "${optfile}"
	echo "ifname \"l2tp-$interface\"" >> "${optfile}"
	echo "ip-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ipv6-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ip-down-script /lib/netifd/ppp-down" >> "${optfile}"
	echo "ipv6-down-script /lib/netifd/ppp-down" >> "${optfile}"
	# Don't wait for LCP term responses; exit immediately when killed.
	echo "lcp-max-terminate 0" >> "${optfile}"
	echo "${ipv6:++ipv6} ${pppd_options}" >> "${optfile}"
	echo "${mtu:+mtu $mtu mru $mtu}" >> "${optfile}"

	xl2tpd-control add l2tp-${interface} pppoptfile=${optfile} lns=${server} redial=yes redial timeout=20 || {
		echo "xl2tpd-control: Add l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
	xl2tpd-control connect l2tp-${interface} || {
		echo "xl2tpd-control: Connect l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
}

proto_l2tp_teardown() {
	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"

	rm -f ${optfile}
	case "$ERROR" in
		11|19)
			proto_notify_error "$interface" AUTH_FAILED
			proto_block_restart "$interface"
		;;
		2)
			proto_notify_error "$interface" INVALID_OPTIONS
			proto_block_restart "$interface"
		;;
	esac

	if [ -p /var/run/xl2tpd/l2tp-control ]; then
		xl2tpd-control remove l2tp-${interface} || {
			echo "xl2tpd-control: Remove l2tp-$interface failed" >&2
		}
	fi
	# Wait for interface to go down
        while [ -d /sys/class/net/l2tp-${interface} ]; do
		sleep 1
	done
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol l2tp
}
