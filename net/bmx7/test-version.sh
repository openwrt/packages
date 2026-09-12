#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
bmx7)
	# The version of bmx7 is derived from the source date, which the
	# binary does not report. `bmx7 -v` is not an alternative: the
	# key path option is applied before the version option, so a
	# missing node key gets generated first - "Creating RSA2048
	# private key. This can take a while", as bmx7 puts it.
	exit 0
	;;

bmx7-*)
	# Plugins are libraries and do not provide version information
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
