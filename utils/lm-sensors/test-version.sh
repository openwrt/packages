#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
lm-sensors)
	sensors --version | grep -F "$PKG_VERSION"
	;;

lm-sensors-detect)
	# Require user input
	exit 0
	;;

libsensors*)
	# Shared libraries
	exit 0
	;;

isadump|isaset)
	# Do not provide version information
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
