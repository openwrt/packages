#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
rrsync|\
rsyncd)
	exit 0
	;;

rsync)
	rsync --version | grep -F "$PKG_VERSION"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
