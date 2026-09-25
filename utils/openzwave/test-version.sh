#!/bin/sh

# shellcheck shell=busybox

case "$1" in
	openzwave)
		# MinOZW prints "OpenZWave Version 1.6-1965-g3fff11d2", which never
		# matches PKG_VERSION (1.6.1965); just verify the binary is present
		[ -x /usr/bin/MinOZW ] || exit 1
		;;

	libopenzwave|openzwave-config)
		# ship no executable, nothing to assert
		exit 0
		;;

	*)
		echo "Untested package: $1" >&2
		exit 1
		;;
esac
