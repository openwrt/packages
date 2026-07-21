#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
quickjs)
	qjs --help | grep -F "${PKG_VERSION//./-}"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
