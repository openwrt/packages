#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
olsrd)
	# The version of olsrd is derived from the source date and git
	# hash, which the binary does not report. Check that the binary
	# starts and prints its version banner instead.
	olsrd -v 2>&1 | grep -F "olsr.org"
	;;

olsrd-mod-*)
	# Plugins are libraries and do not provide version information
	exit 0
	;;

olsrd-utils)
	# Shell scripts only, no version information provided
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
