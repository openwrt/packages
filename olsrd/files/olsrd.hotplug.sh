#!/bin/sh

olsrd_list_configured_interfaces()
{
	local i=0
	local interface

	while interface="$( uci -q get olsrd.@Interface[$i].interface )"; do {
		case "$( uci -q get olsrd.@Interface[$i].ignore )" in
			1|on|true|enabled|yes)
				# is disabled
			;;
			*)
				echo "$interface"
			;;
		esac

		i=$(( $i + 1 ))
	} done
}

olsrd_interface_needs_adding()
{
	local interface="$1"	# e.g. wlanadhocRADIO1
	local device="$2"	# e.g. wlan1-1
	local myif
	local config="/var/etc/olsrd.conf"

	for myif in $(olsrd_list_configured_interfaces); do {
		[ "$myif" = "$interface" ] && {
			if grep -s ^'Interface ' "$config" | grep -q "\"$device\""; then
				logger -t olsrd_hotplug -p daemon.debug "[OK] already_active: $INTERFACE => $DEVICE"
				return 1
			else
				logger -t olsrd_hotplug -p daemon.info "[OK] ifup: $INTERFACE => $DEVICE"
				return 0
			fi
		}
	} done

	logger -t olsrd_hotplug -p daemon.debug "[OK] interface $INTERFACE not used for olsrd"
	return 1
}

case "$ACTION" in
	ifup)
		/etc/init.d/olsrd enabled && {
			olsrd_interface_needs_adding "$INTERFACE" "$DEVICE" && {
				/etc/init.d/olsrd restart
			}
		}
	;;
esac
