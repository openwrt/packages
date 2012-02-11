#!/bin/sh

bat_config(){
	local mesh="$1"
	local aggregated_ogms bonding fragmentation gw_bandwidth gw_mode gw_sel_class log_level orig_interval hop_penalty vis_mode

	config_get aggregated_ogms "$mesh" aggregated_ogms
	config_get bonding "$mesh" bonding
	config_get fragmentation "$mesh" fragmentation
	config_get gw_bandwidth "$mesh" gw_bandwidth
	config_get gw_mode "$mesh" gw_mode
	config_get gw_sel_class "$mesh" gw_sel_class
	config_get log_level "$mesh" log_level
	config_get orig_interval "$mesh" orig_interval
	config_get hop_penalty "$mesh" hop_penalty
	config_get vis_mode "$mesh" vis_mode
	config_get ap_isolation "$mesh" ap_isolation

	[ -n "$orig_interval" ] && echo $orig_interval > /sys/class/net/$mesh/mesh/orig_interval
	[ -n "$hop_penalty" ] && echo $hop_penalty > /sys/class/net/$mesh/mesh/hop_penalty
	[ -n "$log_level" ] && echo $log_level > /sys/class/net/$mesh/mesh/log_level 2>&-
	[ -n "$aggregate_ogms" ] && echo $aggregate_ogms > /sys/class/net/$mesh/mesh/aggregate_ogms
	[ -n "$bonding" ] && echo $bonding > /sys/class/net/$mesh/mesh/bonding
	[ -n "$fragmentation" ] && echo $fragmentation > /sys/class/net/$mesh/mesh/fragmentation
	[ -n "$gw_bandwidth" ] && echo $gw_bandwidth > /sys/class/net/$mesh/mesh/gw_bandwidth
	[ -n "$gw_mode" ] && echo $gw_mode > /sys/class/net/$mesh/mesh/gw_mode
	[ -n "$gw_sel_class" ] && echo $gw_sel_class > /sys/class/net/$mesh/mesh/gw_sel_class
	[ -n "$vis_mode" ] && echo $vis_mode > /sys/class/net/$mesh/mesh/vis_mode
	[ -n "$ap_isolation" ] && echo $ap_isolation > /sys/class/net/$mesh/mesh/ap_isolation
	
}

bat_add_interface(){
	local mesh="$1"
	local interface="$2"
	local interfaces

	sleep 3s # some device (ath) is very lazy to start
	config_get interfaces $mesh interfaces
	for iface in $interfaces; do
		[ -f "/sys/class/net/$iface/batman_adv/mesh_iface" ] || {
			iface=$(uci -q -P/var/state get network.$iface.ifname)
			[ -f "/sys/class/net/$iface/batman_adv/mesh_iface" ] || continue
		}
	
		[ "$iface" = "$interface" ] && echo $mesh > /sys/class/net/$iface/batman_adv/mesh_iface
	done
}

bat_del_interface(){
	local mesh="$1"
	local interface="$2"
	local interfaces

	config_get interfaces $mesh interfaces
	for iface in $interfaces; do
		[ -f "/sys/class/net/$iface/batman_adv/mesh_iface" ] || {
			iface=$(uci -q -P/var/state get network.$iface.ifname)
			[ -f "/sys/class/net/$iface/batman_adv/mesh_iface" ] || continue
		}

		[ "$iface" = "$interface" ] && echo none > /sys/class/net/$iface/batman_adv/mesh_iface
	done
}
