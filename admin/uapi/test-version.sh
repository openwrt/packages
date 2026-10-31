#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
uapi)
	grep -Fx "$PKG_VERSION" /usr/share/uapi/VERSION
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
