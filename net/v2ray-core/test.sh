#!/bin/sh

case "$1" in
	"v2ray-core")
		v2ray version 2>&1 | grep "$PKG_VERSION"
		;;
esac
