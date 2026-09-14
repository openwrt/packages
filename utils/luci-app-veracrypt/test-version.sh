#!/bin/sh
case "$PKG_NAME" in
luci-app-veracrypt)
	exit 0
	;;
*)
	echo "test-version.sh: unhandled package '$PKG_NAME'" >&2
	exit 1
	;;
esac
