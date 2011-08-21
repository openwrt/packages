#!/bin/sh
# Copyright (C) 2011 OpenWrt.org

is_module_loaded() {

	if [ ! -d "/sys/module/batman_adv" ]; then
		echo "batman-adv module directory not found - was the kernel module loaded ?" >&2
		return 0
	fi

	return 1
}

start_mesh () {
	local meshif="$1"
	local interfaces aggregated_ogms bonding fragmentation gw_bandwidth gw_mode gw_sel_class log_level orig_interval vis_mode

	is_module_loaded
	[ $? -ne 1 ] && return

	config_get interfaces "$meshif" interfaces
	config_get aggregated_ogms "$meshif" aggregated_ogms
	config_get bonding "$meshif" bonding
	config_get fragmentation "$meshif" fragmentation
	config_get gw_bandwidth "$meshif" gw_bandwidth
	config_get gw_mode "$meshif" gw_mode
	config_get gw_sel_class "$meshif" gw_sel_class
	config_get log_level "$meshif" log_level
	config_get orig_interval "$meshif" orig_interval
	config_get vis_mode "$meshif" vis_mode

	if [ "$interfaces" = "" ]; then
		echo Error, you must specify at least a network interface
		return
	fi
	
	for interface in $interfaces
	   do
	      ifname=$(uci -P /var/state get network.$interface.ifname 2>&-)
	      [ ! -f "/sys/class/net/$ifname/batman_adv/mesh_iface" ] && {
	         ifname=${interface}
	         [ ! -f "/sys/class/net/$ifname/batman_adv/mesh_iface" ] && echo "Can't add interface $ifname - ignoring" && continue
	      }

	      echo $meshif > /sys/class/net/$ifname/batman_adv/mesh_iface
	   done

	if [ $orig_interval ]; then
		echo $orig_interval > /sys/class/net/$meshif/mesh/orig_interval
	fi

	if [ $log_level ]; then
		echo $log_level > /sys/class/net/$meshif/mesh/log_level 2>&-
	fi

	if [ $aggregated_ogms ]; then
		echo $aggregated_ogms > /sys/class/net/$meshif/mesh/aggregated_ogms
	fi
	
	if [ $bonding ]; then
		echo $bonding > /sys/class/net/$meshif/mesh/bonding
	fi
	
	if [ $fragmentation ]; then
		echo $fragmentation > /sys/class/net/$meshif/mesh/fragmentation
	fi
	
	if [ $gw_bandwidth ]; then
		echo $gw_bandwidth > /sys/class/net/$meshif/mesh/gw_bandwidth
	fi
	
	if [ $gw_mode ]; then 
		echo $gw_mode > /sys/class/net/$meshif/mesh/gw_mode
	fi
	
	if [ $gw_sel_class ]; then
		echo $gw_sel_class > /sys/class/net/$meshif/mesh/gw_sel_class
	fi

	if [ $vis_mode ]; then
		echo $vis_mode > /sys/class/net/$meshif/mesh/vis_mode
	fi
}

stop_mesh() {
	local meshif="$1"

	is_module_loaded
	[ $? -ne 1 ] && return

	for iface in $(ls /sys/class/net/*)
	   do
		 [ ! -f "$iface/batman_adv/mesh_iface" ] && continue
		 [ "$(head -1 $iface/batman_adv/mesh_iface)" != "$meshif" ] && continue

		 echo "none" > $iface/batman_adv/mesh_iface
	   done
}
