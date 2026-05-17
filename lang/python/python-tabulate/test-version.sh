#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
python3-tabulate|\
python3-tabulate-src)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
