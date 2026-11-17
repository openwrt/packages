#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
librrd1 | rrdcgi1)
	# rrdcgi has no version or help option, and neither rrdcgi nor librrd
	# contains the version string, so there is nothing to check. The version
	# is covered by rrdtool1, built from the same source.
	exit 0
	;;
rrdtool1)
	rrdtool 2>&1 | grep -F "$PKG_VERSION"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
