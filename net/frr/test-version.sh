#!/bin/sh

# shellcheck shell=busybox

case "$1" in
frr)
	vtysh --version | grep -F "$2" || exit 1
	mgmtd --version | grep -F "$2"
	;;
frr-pythontools)
	# Python scripts only, no version information provided
	exit 0
	;;
frr-*)
	"/usr/sbin/${1#frr-}" --version | grep -F "$2"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
