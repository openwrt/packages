#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
rpcbind)
	# The -v flag is implemented in version 1.2.8+
	# rpcbind -v 2>&1 | grep -F "$PKG_VERSION"
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
