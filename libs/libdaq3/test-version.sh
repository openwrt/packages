#!/bin/sh

# shellcheck shell=busybox

# daqtest does not print the library version.
# Skip the generic version probe.

case "$PKG_NAME" in
libdaq3)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
