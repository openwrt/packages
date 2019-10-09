#!/bin/sh

#
# Dual Channel Wi-Fi Startup Script
#
# This script creates the proper network bridge configuration
#  necessary for Dual Channel Wi-Fi, and starts the dcwapd daemon
#

verbose=1

uciconfig=dcwapd

result=

# NOTE: all functions write the result to the $result variable

get_channelsets()
{
	# default to empty
	result=
	channelsets=$(uci show $uciconfig | grep "=channel-set$")
	for channelset in $channelsets; do
		channelset=$(echo "$channelset" | sed -rn "s/$uciconfig\.(.*)=.*/\1/p")
		result="$result $channelset"
	done
	if [ $verbose -eq 1 ]; then
		echo "Channel Sets: $result" 2>&1 | logger
	fi
}

# $1 : the channel set name
get_channelset_enabled()
{
	# default to disabled
	result=0
	if [ -n "$1" ]; then
		result=$(uci get $uciconfig."$1".enabled)
	fi
	if [ $verbose -eq 1 ]; then
		echo "Channel Set \"$1\" Enabled: $result" 2>&1 | logger
	fi
}

# $1 : the channel set name
get_primary_bridge()
{
	result=
	if [ -n "$1" ]; then
		result=$(uci get $uciconfig."$1".bridge)
	fi
	if [ $verbose -eq 1 ]; then
		echo "Channel Set \"$1\" Primary Bridge: $result" 2>&1 | logger
	fi
}

# $1 : the channel set name
get_datachannels()
{
	# default to empty
	result=
	if [ -n "$1" ]; then
		result=$(uci get $uciconfig."$1".data_channels)
	fi
	if [ $verbose -eq 1 ]; then
		echo "Channel Set \"$1\" Data Channels: $result" 2>&1 | logger
	fi
}

# $1 : the wlan interface name
get_wifi_iface_num()
{
	result=
	if [ -n "$1" ];then
		#result=$(echo "$1" | sed -n "s/wlan//p")
		result=$(echo "$1" | sed -rn "s/wlan([0-9]*).*/\1/p")
	fi
}

# $1 : the bridge name
get_bridge_network_name()
{
	result=
	if [ -n "$1" ];then
		result=$(echo "$1" | sed -n "s/br-//p")
	fi
}

# $1 : the wlan interface name
set_iface_init_state()
{
	result=
	if [ -n "$1" ]; then
		iface=$1
		# need to extract the "X" from wlanX
		get_wifi_iface_num "$iface"
		iface_num=$result
		if [ -n "$iface_num" ]; then
			# get the iface network
			init_net=$(uci get wireless.@wifi-iface[$iface_num].network)
			if [ -n "$init_net" ]; then
				# if the iface network is a bridge, but doesn't start with "br-"
				#  I think we need to prepend it?
				net_type=$(uci get network."$init_net".type)
				if [ -n "$net_type" ] && [ "$net_type" = "bridge" ]; then
					prefix_ok=$(echo "$init_net" | grep "^br-")
					if [ -z "$prefix_ok" ]; then
						init_net="br-$init_net"
					fi
				fi
			fi

			# make sure that the init_net section exists
			init_net_section=$(uci get dcwapd.init_net)
			if [ "$init_net_section" != "init_net" ]; then
				# the section did not exist
				uci set dcwapd.init_net=init_net
			fi

			# save the initial network
			if [ $verbose -eq 1 ]; then
				echo "Saving '$iface' initial network '$init_net'" 2>&1 | logger
			fi
			uci set $uciconfig.init_net."$iface"="$init_net"
			uci commit

			# save the initial network in the result variable
			result=$init_net
		fi
	fi
}

# $1 : the wlan interface name
get_iface_init_state()
{
	result=
	if [ -n "$1" ];then
		init_net=$(uci get $uciconfig.init_net."$iface")

		# if the response starts with "uci: ", it was an error not the real result
		err=$(echo "$init_net" | grep "^uci: ")
		if [ -z "$err" ]; then
			# no error, set the result
			result=$init_net

			if [ $verbose -eq 1 ]; then
				echo "Got '$iface' initial network '$init_net'" 2>&1 | logger
			fi
		fi
	fi
}

# $1 : the name of the data channel name to bring up
datachannel_up()
{
	if [ -n "$1" ]; then
		bridge=$(uci get $uciconfig."$1".bridge)
		interfaces=$(uci get $uciconfig."$1".interfaces)
                if [ $verbose -eq 1 ]; then
			echo "Creating Data Channel Bridge: $bridge" 2>&1 | logger
		fi

		get_bridge_network_name "$bridge"
		netname=$result
		if [ -n "$netname" ]; then
		    uci set network."$netname"=interface
		    uci set network."$netname".type=bridge
		    uci set network."$netname".proto=static
		    uci set network."$netname".bridge_empty='1'
		fi

		# create the bridge
		uci commit
		/etc/init.d/network reload

		for iface in $interfaces; do
			# if iface is in a bridge, the bridge name should be stored in result
			set_iface_init_state "$iface"
			init_bridge=$result

			# update uci with the new bridge info
			get_wifi_iface_num "$iface"
			iface_num=$result
			if [ -n "$iface_num" ]; then
			    uci set wireless.@wifi-iface[$iface_num].network="$netname"
			fi

			# manually put the interface into the data bridge
			# if iface is in a bridge, remove it before adding it to the data bridge
			if [ -n "$init_bridge" ]; then
				brctl delif "$init_bridge" "$iface" 2>&1 | logger
			fi
			brctl addif "$bridge" "$iface" 2>&1 | logger
		done

		# commit uci changes and reload the network
		uci commit
		/etc/init.d/network reload
		#/etc/init.d/network restart
		# while [ 1 ]; do
		# 	ifconfig "$bridge" > /dev/null 2>&1
		# 	if [ $? == 0 ]; then
		# 		break;
		# 	fi
		# 	sleep 1
		# done
	fi
}

# $1 : the name of the data channel to bring down
datachannel_down()
{
	if [ -n "$1" ]; then
		bridge=$(uci get $uciconfig."$1".bridge)
		interfaces=$(uci get $uciconfig."$1".interfaces)
		for iface in $interfaces; do
			if [ $verbose -eq 1 ]; then
				echo "Deconfiguring Data Channel Interface: $iface" 2>&1 | logger
			fi

			# manually remove the interface from the data bridge
			brctl delif "$bridge" "$iface" 2>&1 | logger

			get_iface_init_state "$iface"
			init_bridge=$result
			if [ -n "$init_bridge" ]; then
				# manually move the interface back to the original bridge
				brctl addif "$init_bridge" "$iface" 2>&1 | logger

				# update uci with the new bridge and interface configuration
			        get_wifi_iface_num "$iface"
				iface_num=$result
				get_bridge_network_name "$init_bridge"
				netname=$result
				if [ -n "$iface_num" ] && [ -n "$netname" ]; then
				    uci set wireless.@wifi-iface[$iface_num].network="$netname"
				fi
			fi
		done
		if [ $verbose -eq 1 ]; then
			echo "Deconfiguring Data Channel Bridge: $bridge" 2>&1 | logger
		fi

		# delete the bridge from uci
		get_bridge_network_name "$bridge"
		netname=$result
		if [ -n "$netname" ]; then
		    uci delete network."$netname"
		fi

		# commit uci changes and reload the network
		uci commit
		/etc/init.d/network reload
		#`/etc/init.d/network restart`
	fi
}
