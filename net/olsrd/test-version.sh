#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
olsrd)
	# olsrd leaves through olsr_exit(), which ends the process with
	# raise(SIGTERM) even for -v, so the shell reports "Terminated"
	# after the banner. The pipeline status comes from grep, so the
	# check is unaffected.
	olsrd -v 2>&1 | grep -F "$PKG_VERSION"
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
