#!/bin/sh
# The CI sandbox has no wireguard module, no rpcd session and no peer, so
# only exercise what runs before a tunnel is created.

case "$1" in
wg-installer-server)
	/usr/libexec/rpcd/wginstaller list | grep '"register"'
	;;
wg-installer-server-hotplug-olsrd|wg-installer-server-hotplug-babeld)
	h=/etc/hotplug.d/net/99-mesh-${1#wg-installer-server-hotplug-}
	# a non-wireguard device and a wireguard device outside the wg_ name
	# space must both be ignored without touching ubus
	DEVTYPE=bridge ACTION=add INTERFACE=wg_1 sh "$h" &&
	DEVTYPE=wireguard ACTION=add INTERFACE=wg0 sh "$h"
	;;
wg-installer-client)
	sh -n /usr/bin/wg-client-installer &&
	sh -n /usr/share/wginstaller/rpcd_ubus.sh &&
	sh -n /usr/share/wginstaller/wg.sh
	;;
*)
	exit 1
	;;
esac
