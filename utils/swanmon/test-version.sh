#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
swanmon)
	swanmon help 2>&1 | grep 'Usage: swanmon'
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
