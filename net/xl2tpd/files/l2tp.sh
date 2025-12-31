#!/bin/sh

[ -x /usr/sbin/xl2tpd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_l2tp_select_ipaddr()
{
	local subnets=$1
	local res
	local res_mask

	for subnet in $subnets; do
		local addr="${subnet%%/*}"
		local mask="${subnet#*/}"

		if [ -n "$res_mask" -a "$mask" != 32 ]; then
			[ "$mask" -gt "$res_mask" ] || [ "$res_mask" = 32 ] && {
				res="$addr"
				res_mask="$mask"
			}
		elif [ -z "$res_mask" ]; then
			res="$addr"
			res_mask="$mask"
		fi
	done

	echo "$res"
}

proto_l2tp_init_config() {
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_string "keepalive"
	proto_config_add_string "pppd_options"
	proto_config_add_boolean "ipv6"
	proto_config_add_int "mtu"
	proto_config_add_int "checkup_interval"
	proto_config_add_string "server"
	proto_config_add_string "hostname"
	proto_config_add_string "unnumbered"
	available=1
	no_device=1
	no_proto_task=1
	teardown_on_l3_link_down=1
}

proto_l2tp_setup() {
	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"
	local ip serv_addr server host hostname

	json_get_vars server hostname
	host="${server%:*}"
	for ip in $(resolveip -t 5 "$host"); do
		( proto_add_host_dependency "$interface" "$ip" )
		serv_addr=1
	done
	[ -n "$serv_addr" ] || {
		echo "Could not resolve server address" >&2
		sleep 5
		proto_setup_failed "$interface"
		exit 1
	}

	hostname="${hostname:+hostname=$hostname}"

	# Start and wait for xl2tpd
	if [ ! -p /var/run/xl2tpd/l2tp-control -o -z "$(pidof xl2tpd)" ]; then
		/etc/init.d/xl2tpd restart

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

	local ipv6 keepalive username password pppd_options mtu unnumbered localip
	json_get_vars ipv6 keepalive username password pppd_options mtu unnumbered
	[ "$ipv6" = 1 ] || ipv6=""

	local interval="${keepalive##*[, ]}"
	[ "$interval" != "$keepalive" ] || interval=5

	keepalive="${keepalive:+lcp-echo-interval $interval lcp-echo-failure ${keepalive%%[, ]*}}"
	username="${username:+user \"$username\" password \"$password\"}"
	ipv6="${ipv6:++ipv6}"
	mtu="${mtu:+mtu $mtu mru $mtu}"

	[ -n "$unnumbered" ] && {
		local subnets
		( proto_add_host_dependency "$interface" "" "$unnumbered" )
		network_get_subnets subnets "$unnumbered"
		localip=$(proto_l2tp_select_ipaddr "$subnets")
		[ -n "$localip" ] || {
			proto_block_restart "$interface"
			return
		}
		localip="${localip:+$localip:}"
	}

	mkdir -p /tmp/l2tp
	cat <<EOF >"$optfile"
usepeerdns
nodefaultroute
ipparam "$interface"
ifname "l2tp-$interface"
ip-up-script /lib/netifd/ppp-up
ipv6-up-script /lib/netifd/ppp-up
ip-down-script /lib/netifd/ppp-down
ipv6-down-script /lib/netifd/ppp-down
# Don't wait for LCP term responses; exit immediately when killed.
lcp-max-terminate 0
$keepalive
$username
$ipv6
$mtu
$localip
$pppd_options
EOF

	xl2tpd-control add-lac l2tp-${interface} pppoptfile=${optfile} lns=${server} ${hostname} || {
		echo "xl2tpd-control: Add l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
	xl2tpd-control connect-lac l2tp-${interface} || {
		echo "xl2tpd-control: Connect l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
}

proto_l2tp_teardown() {
	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"

	rm -f ${optfile}
	if [ -p /var/run/xl2tpd/l2tp-control ]; then
		xl2tpd-control remove-lac l2tp-${interface} || {
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
