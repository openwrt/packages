. /lib/functions.sh
. /lib/functions/network.sh

tunneldigger_get_bridge() {
	local variable="$1"
	local mtu="$2"

	# Overwrite the destination variable.
	unset $variable
	
	# Discover the configured bridge.
	unset _td_bridge
	_td_bridge=""
	config_cb() {
		local cfg="$CONFIG_SECTION"
		config_get configname "$cfg" TYPE
		if [ "$configname" != "bridge" ]; then
			return
		fi

		config_get cfg_mtu "$cfg" mtu
		config_get interface "$cfg" interface
		
		if [ "$cfg_mtu" != "$mtu" ]; then
			return
		fi

		_td_bridge="$interface"
	}

	config_load tunneldigger-broker
	reset_cb
	if [ -z "$_td_bridge" ]; then
		return
	fi

	eval $variable=$_td_bridge
	# network_get_device $variable $_td_bridge
}
