#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
dbus)
	dbus-cleanup-sockets --version 2>&1 | grep -F "$PKG_VERSION"
	dbus-daemon --version 2>&1 | grep -F "$PKG_VERSION"
	dbus-launch --version 2>&1 | grep -F "$PKG_VERSION"
	dbus-uuidgen --version 2>&1 | grep -F "$PKG_VERSION"
	;;

dbus-utils|\
libdbus)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
