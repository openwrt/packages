#!/bin/sh

# shellcheck shell=busybox

# The binaries print PKG_REALVERSION (4.4.3-P1), PKG_VERSION is 4.4.3_p1.
PKG_REALVERSION=$(echo "$PKG_VERSION" | sed 's/_p/-P/')

case "$PKG_NAME" in
isc-dhcp-client-ipv4|isc-dhcp-client-ipv6)
	dhclient --version 2>&1 | grep -F "$PKG_REALVERSION"
	;;

isc-dhcp-relay-ipv4|isc-dhcp-relay-ipv6)
	dhcrelay --version 2>&1 | grep -F "$PKG_REALVERSION"
	;;

isc-dhcp-server-ipv4|isc-dhcp-server-ipv6)
	dhcpd --version 2>&1 | grep -F "$PKG_REALVERSION"
	;;

isc-dhcp-omshell-ipv4|isc-dhcp-omshell-ipv6)
	# Does not provide version information
	exit 0
	;;

isc-dhcp-dyndns)
	# Meta package
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
