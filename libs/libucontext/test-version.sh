#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
libucontext|\
libucontext-tests)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
