#!/bin/sh

case "$1" in
	"fvpn")
		fvpn --version 2>&1 | grep "$PKG_VERSION"
		;;
esac
