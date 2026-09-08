#!/bin/sh

# shellcheck shell=busybox

case "$1" in
	domoticz)
		# domoticz has no flag that prints its version; just verify the
		# binary is present
		[ -x /usr/bin/domoticz ] || exit 1
		;;

	*)
		echo "Untested package: $1" >&2
		exit 1
		;;
esac
