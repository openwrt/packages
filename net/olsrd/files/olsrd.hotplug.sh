#!/bin/sh

olsrd_list_configured_interfaces()
{
	local i=0
	local interface

	while interface="$( uci -q get $OLSRD.@Interface[$i].interface )"; do {
		case "$( uci -q get $OLSRD.@Interface[$i].ignore )" in
			1|on|true|enabled|yes)
				# is disabled
			;;
			*)
				echo "$interface"	# e.g. 'lan'
			;;
		esac

		i=$(( i + 1 ))
	} done
}

olsrd_interface_already_in_config()
{
	# e.g.: 'Interface "eth0.1" "eth0.2" "wlan0"'
	if grep -s ^'Interface ' "/var/etc/$OLSRD.conf" | grep -q "\"$DEVICE\""; then
		logger -t olsrd_hotplug -p daemon.debug "[OK] already_active: '$INTERFACE' => '$DEVICE'"
		return 0
	else
		logger -t olsrd_hotplug -p daemon.info "[OK] ifup: '$INTERFACE' => '$DEVICE'"
		return 1
	fi
}

olsrd_interface_needs_adding()
{
	local interface

	# likely and cheap operation:
	olsrd_interface_already_in_config && return 1

	for interface in $(olsrd_list_configured_interfaces); do {
		[ "$interface" = "$INTERFACE" ] && {
			olsrd_interface_already_in_config || return 0
		}
	} done

	logger -t olsrd_hotplug -p daemon.debug "[OK] interface '$INTERFACE' => '$DEVICE' not used for $OLSRD"
	return 1
}

case "$ACTION" in
	ifup)
		# only work after the first normal startup
		# also: no need to test, if enabled
	        OLSRD=olsrd
		[ -e "/var/etc/$OLSRD.conf" ] && {
			# INTERFACE = e.g. 'wlanadhocRADIO1' or 'cfg144d8f'
			# DEVICE    = e.g. 'wlan1-1'
			olsrd_interface_needs_adding && {
				. /etc/rc.common /etc/init.d/$OLSRD restart
			}
		}

	        OLSRD=olsrd6
		[ -e "/var/etc/$OLSRD.conf" ] && {
			olsrd_interface_needs_adding && {
				. /etc/rc.common /etc/init.d/$OLSRD restart
			}
		}
	;;
esac
