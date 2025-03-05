#!/bin/sh
#
# Copyright (C) 2018 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

. /lib/functions.sh
. ../netifd-proto.sh

init_proto "$@"

INCLUDE_ONLY=1

BONDING_MASTERS="/sys/class/net/bonding_masters"

set_driver_values() {
	local varname

	for varname in "$@"; do
		local value
		json_get_var value "$varname"

		[ -n "$value" ] && echo "$value" > /sys/class/net/"$link"/bonding/"$varname"
	done
}

proto_bonding_init_config() {
	no_device=1
	available=1

	proto_config_add_string "ifname"

	proto_config_add_string "ipaddr"
	proto_config_add_string "netmask"

	proto_config_add_string "bonding_policy"
	proto_config_add_string "link_monitoring"
	proto_config_add_array "slaves"
	proto_config_add_string "all_slaves_active"

	proto_config_add_string "min_links"
	proto_config_add_string "ad_actor_sys_prio"
	proto_config_add_string "ad_actor_system"
	proto_config_add_string "ad_select"
	proto_config_add_string "lacp_rate"
	proto_config_add_string "packets_per_slave"
	proto_config_add_string "xmit_hash_policy"
	proto_config_add_string "primary"
	proto_config_add_string "primary_reselect"
	proto_config_add_string "lp_interval"
	proto_config_add_string "tlb_dynamic_lb"
	proto_config_add_string "resend_igmp"
	proto_config_add_string "fail_over_mac"
	proto_config_add_string "num_grat_arp__num_unsol_na"

	proto_config_add_string "arp_interval"
	proto_config_add_string "arp_ip_target"
	proto_config_add_string "arp_all_targets"
	proto_config_add_string "arp_validate"

	proto_config_add_string "miimon"
	proto_config_add_string "downdelay"
	proto_config_add_string "updelay"
	proto_config_add_string "use_carrier"
}

proto_bonding_add_slave() {
	local slave=$1
	local idx=$2
	local cfg=$3
	local link=$4

	if [ ! -e "/sys/class/net/$slave" ]; then
		echo "$cfg" "No slave device $slave found"
		proto_notify_error "$cfg" NO_DEVICE
		proto_block_restart "$cfg"
		return
	fi

	ip link set dev "$slave" down

	sleep 1

	echo "+$slave" > /sys/class/net/"$link"/bonding/slaves

	ip link set dev "$slave" up
}

proto_bonding_setup() {
	local cfg="$1"
	local link="bond-$cfg"

	# Check for loaded kernel bonding driver (/sys/class/net/bonding_masters exists)
	[ -f "$BONDING_MASTERS" ] || {
		echo "$cfg" "setup: bonding_masters does not exist in sysfs (kernel module not loaded?)"
		proto_notify_error "$cfg" BONDING_MASTER_DOES_NOT_EXIST
		proto_block_restart "$cfg"
		return
	}

	# Add bonding interface to system
	echo "+$link" > "$BONDING_MASTERS"

	# Set bonding policy (with corresponding parameters)
	local bonding_policy
	json_get_vars bonding_policy

	case "$bonding_policy" in

		802.3ad)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values min_links ad_actor_sys_prio ad_actor_system ad_select lacp_rate xmit_hash_policy
		;;

		balance-rr)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values packets_per_slave xmit_hash_policy
		;;

		balance-tlb)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values primary primary_reselect lp_interval tlb_dynamic_lb resend_igmp xmit_hash_policy
		;;

		balance-alb)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values primary primary_reselect lp_interval tlb_dynamic_lb resend_igmp xmit_hash_policy
		;;

		balance-xor)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values xmit_hash_policy
		;;

		broadcast)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
		;;

		active-backup)
			echo "$bonding_policy" > /sys/class/net/"$link"/bonding/mode
			set_driver_values primary primary_reselect fail_over_mac num_grat_arp__num_unsol_na xmit_hash_policy
		;;
        esac

	# Set link monitoring (with corresponding parameters)
	local link_monitoring
	json_get_vars link_monitoring

	case "$link_monitoring" in

		arp)
			local arp_interval arp_ip_target arp_all_targets arp_validate
			json_get_vars arp_interval arp_ip_target arp_all_targets arp_validate

			[ -n "$arp_interval" -a "$arp_interval" != 0 ] && echo "$arp_interval" > /sys/class/net/"$link"/bonding/arp_interval

			IFS=' '
			for target in $arp_ip_target; do
				echo "+$target" > /sys/class/net/"$link"/bonding/arp_ip_target
			done

			[ -n "$arp_all_targets" ] && echo "$arp_all_targets" > /sys/class/net/"$link"/bonding/arp_all_targets
			[ -n "$arp_validate" ] && echo "$arp_validate" > /sys/class/net/"$link"/bonding/arp_validate
		;;

		mii)
			local miimon downdelay updelay use_carrier
			json_get_vars miimon downdelay updelay use_carrier

			[ -n "$miimon" -a "$miimon" != 0 ] && echo "$miimon" > /sys/class/net/"$link"/bonding/miimon
			[ -n "$downdelay" ] && echo "$downdelay" > /sys/class/net/"$link"/bonding/downdelay
			[ -n "$updelay" ] && echo "$updelay" > /sys/class/net/"$link"/bonding/updelay
			[ -n "$use_carrier" ] && echo "$use_carrier" > /sys/class/net/"$link"/bonding/use_carrier
		;;
	esac

	# Add slaves to bonding interface
	local slaves
	json_get_vars slaves
	json_for_each_item proto_bonding_add_slave slaves "$cfg" "$link"

	[ -n "$all_slaves_active" ] && echo "$all_slaves_active" > /sys/class/net/"$link"/bonding/all_slaves_active

	local ipaddr netmask
	json_get_vars ipaddr netmask

	# ATTENTION
	#All json vars have to be read before the line below, as the
	# json object will be overwritten by proto_init_update
	# ATTENTION

	proto_init_update "$link" 1

	# If ipaddr is configured, configure the ip to the interface
	[ -n "$ipaddr" ] && proto_add_ipv4_address "$ipaddr" "$netmask"

	proto_send_update "$cfg"
}

proto_bonding_teardown() {
	local cfg="$1"
	local link="bond-$cfg"

	# Check for loaded kernel bonding driver (/sys/class/net/bonding_masters exists)
	[ -f "$BONDING_MASTERS" ] || {
		echo "$cfg" "teardown: bonding_masters does not exist in sysfs (kernel module not loaded?)"
		proto_notify_error "$cfg" BONDING_MASTER_DOES_NOT_EXIST
		proto_block_restart "$cfg"
		return
	}

	echo "-$link" > /sys/class/net/bonding_masters
	logger "bonding_teardown($1): $2"
}

add_protocol bonding
