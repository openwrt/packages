#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in #luajit2 use build number at -v but releases are named by date
luajit2)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
