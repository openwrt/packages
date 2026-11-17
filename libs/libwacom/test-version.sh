#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
libwacom)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
