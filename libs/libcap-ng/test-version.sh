#!/bin/sh

# shellckeck shell=busybox

case "$1" in
libcap-ng|\
libcap-ng-bin)
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
