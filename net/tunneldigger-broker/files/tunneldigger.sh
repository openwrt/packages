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
	handle_bridge() {
		local cfg="$1"

		config_get cfg_mtu "$cfg" mtu
		config_get interface "$cfg" interface
		
		if [ "$cfg_mtu" != "$mtu" ]; then
			return
		fi

		_td_bridge="$interface"
	}

	config_load tunneldigger-broker
	config_foreach handle_bridge bridge $mtu
	if [ -z "$_td_bridge" ]; then
		return
	fi

	variable="$_td_bridge"
	export ${NO_EXPORT:+-n} "$1=$variable"
}

# Get the isolation option for this bridge
tunneldigger_get_bridge_isolate() {
	local variable="$1"
	local mtr="$2"

        # Overwrite the destination variable.
        unset $variable

        # Discover the configured bridge.
        unset _isolate_bridge
        _isolate_bridge=""
        handle_bridge() {
                local cfg="$1"

                config_get cfg_mtu "$cfg" mtu
                config_get isolate "$cfg" isolate 0

                if [ "$cfg_mtu" != "$mtu" ]; then
                        return
                fi

                _isolate_bridge="$isolate"
        }

        config_load tunneldigger-broker
        config_foreach handle_bridge bridge $mtu
        if [ -z "$_isolate_bridge" ]; then
                return
        fi

        variable="$_isolate_bridge"
        export ${NO_EXPORT:+-n} "$1=$variable"

}
