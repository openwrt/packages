#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
tor|tor-basic)
	tor --version | grep -F "$PKG_VERSION"
	;;

tor-gencert)
	# Do not provide version information
	exit 0
	;;

tor-resolve)
	tor-resolve --version | grep -F "$PKG_VERSION"
	;;

tor-geoip)
	# Databases
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
