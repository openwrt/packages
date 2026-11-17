#!/bin/sh

# shellcheck shell=busybox

# None of the ddns-scripts executables or scripts print the package version.
# Skip the generic version probe.

case "$PKG_NAME" in
ddns-scripts*)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
