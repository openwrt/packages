#!/bin/sh

# shellcheck shell=busybox

# airsaned does not print the package version.
# Skip the generic version probe.

case "$PKG_NAME" in
airsaned)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
