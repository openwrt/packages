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
	local orig_interval vis_mode

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
	config_get vis_mode "$mesh" vis_mode

	[ ! -f "/sys/class/net/$mesh/mesh/orig_interval" ] && echo "batman-adv mesh $mesh does not exist - check your interface configuration" && return 1

	[ -n "$aggregate_ogms" ] && echo $aggregate_ogms > /sys/class/net/$mesh/mesh/aggregate_ogms
	[ -n "$ap_isolation" ] && echo $ap_isolation > /sys/class/net/$mesh/mesh/ap_isolation
	[ -n "$bonding" ] && echo $bonding > /sys/class/net/$mesh/mesh/bonding
	[ -n "$bridge_loop_avoidance" ] && echo $bridge_loop_avoidance > /sys/class/net/$mesh/mesh/bridge_loop_avoidance 2>&-
	[ -n "$distributed_arp_table" ] && echo $distributed_arp_table > /sys/class/net/$mesh/mesh/distributed_arp_table 2>&-
	[ -n "$fragmentation" ] && echo $fragmentation > /sys/class/net/$mesh/mesh/fragmentation
	[ -n "$gw_bandwidth" ] && echo $gw_bandwidth > /sys/class/net/$mesh/mesh/gw_bandwidth
	[ -n "$gw_mode" ] && echo $gw_mode > /sys/class/net/$mesh/mesh/gw_mode
	[ -n "$gw_sel_class" ] && echo $gw_sel_class > /sys/class/net/$mesh/mesh/gw_sel_class
	[ -n "$hop_penalty" ] && echo $hop_penalty > /sys/class/net/$mesh/mesh/hop_penalty
	[ -n "$isolation_mark" ] && echo $isolation_mark > /sys/class/net/$mesh/mesh/isolation_mark
	[ -n "$multicast_mode" ] && echo $multicast_mode > /sys/class/net/$mesh/mesh/multicast_mode 2>&-
	[ -n "$network_coding" ] && echo $network_coding > /sys/class/net/$mesh/mesh/network_coding 2>&-
	[ -n "$log_level" ] && echo $log_level > /sys/class/net/$mesh/mesh/log_level 2>&-
	[ -n "$orig_interval" ] && echo $orig_interval > /sys/class/net/$mesh/mesh/orig_interval
	[ -n "$vis_mode" ] && echo $vis_mode > /sys/class/net/$mesh/mesh/vis_mode
}
