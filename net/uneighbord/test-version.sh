#!/bin/sh

# shellcheck shell=busybox

# uneighbord is a daemon and does not support a --version flag.
case "$PKG_NAME" in
uneighbord)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
