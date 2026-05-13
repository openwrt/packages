#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
libunbound)
	exit 0
	;;

unbound-anchor|\
unbound-checkconf|\
unbound-control|\
unbound-host)
	$PKG_NAME -h 2>&1 | grep -F "$PKG_VERSION"
	;;

unbound-control-setup)
	exit 0
	;;

unbound-daemon)
	unbound -V 2>&1 | grep -F "$PKG_VERSION"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
