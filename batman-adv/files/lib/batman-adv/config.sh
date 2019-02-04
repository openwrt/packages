#!/bin/sh

bat_load_module()
{
	[ -d "/sys/module/batman_adv/" ] && return

	. /lib/functions.sh
	load_modules /etc/modules.d/*-crc16 /etc/modules.d/*-crypto* /etc/modules.d/*-lib-crc* /etc/modules.d/*-batman-adv*
}

bat_config()
{
	local mesh="$1"
	local aggregated_ogms ap_isolation bonding bridge_loop_avoidance distributed_arp_table fragmentation
	local gw_bandwidth gw_mode gw_sel_class isolation_mark hop_penalty multicast_mode network_coding log_level
	local orig_interval

	config_get aggregated_ogms "$mesh" aggregated_ogms
	config_get ap_isolation "$mesh" ap_isolation
	config_get bonding "$mesh" bonding
	config_get bridge_loop_avoidance "$mesh" bridge_loop_avoidance
	config_get distributed_arp_table "$mesh" distributed_arp_table
	config_get fragmentation "$mesh" fragmentation
	config_get gw_bandwidth "$mesh" gw_bandwidth
	config_get gw_mode "$mesh" gw_mode
	config_get gw_sel_class "$mesh" gw_sel_class
	config_get hop_penalty "$mesh" hop_penalty
	config_get isolation_mark "$mesh" isolation_mark
	config_get multicast_mode "$mesh" multicast_mode
	config_get network_coding "$mesh" network_coding
	config_get log_level "$mesh" log_level
	config_get orig_interval "$mesh" orig_interval

	[ ! -f "/sys/class/net/$mesh/mesh/orig_interval" ] && echo "batman-adv mesh $mesh does not exist - check your interface configuration" && return 1

	[ -n "$aggregated_ogms" ] && batctl -m "$mesh" aggregation "$aggregated_ogms"
	[ -n "$ap_isolation" ] && batctl -m "$mesh" ap_isolation "$ap_isolation"
	[ -n "$bonding" ] && batctl -m "$mesh" bonding "$bonding"
	[ -n "$bridge_loop_avoidance" ] &&  batctl -m "$mesh" bridge_loop_avoidance "$bridge_loop_avoidance" 2>&-
	[ -n "$distributed_arp_table" ] && batctl -m "$mesh" distributed_arp_table "$distributed_arp_table" 2>&-
	[ -n "$fragmentation" ] && batctl -m "$mesh" fragmentation "$fragmentation"

	[ -n "$gw_bandwidth" ] && echo $gw_bandwidth > /sys/class/net/$mesh/mesh/gw_bandwidth
	[ -n "$gw_mode" ] && echo $gw_mode > /sys/class/net/$mesh/mesh/gw_mode
	[ -n "$gw_sel_class" ] && echo $gw_sel_class > /sys/class/net/$mesh/mesh/gw_sel_class
	[ -n "$hop_penalty" ] && echo $hop_penalty > /sys/class/net/$mesh/mesh/hop_penalty

	[ -n "$isolation_mark" ] && batctl -m "$mesh" isolation_mark "$isolation_mark"
	[ -n "$multicast_mode" ] && batctl -m "$mesh" multicast_mode "$multicast_mode" 2>&-
	[ -n "$network_coding" ] && batctl -m "$mesh" network_coding "$network_coding" 2>&-
	[ -n "$log_level" ] && batctl -m "$mesh" loglevel "$log_level" 2>&-
	[ -n "$orig_interval" ] && batctl -m "$mesh" orig_interval "$orig_interval"
}
