#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
ksmbd-server)
	/usr/sbin/ksmbd.mountd -V 2>&1 | grep -F "$PKG_VERSION"
	;;

ksmbd-avahi-service|\
ksmbd-hotplug)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
