#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
nsd|nsd-nossl)
	nsd -v 2>&1 | grep -F "$PKG_VERSION" &&
	nsd-checkconf -h 2>&1 | grep -F "$PKG_VERSION"
	;;

nsd-control)
	nsd-control -h 2>&1 | grep -F "$PKG_VERSION"
	;;

nsd-control-setup)
	# Shell script without version information
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
