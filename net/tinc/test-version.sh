#!/bin/sh

# shellcheck shell=busybox

# PKG_VERSION is 1.1_pre18 for apk, while the binaries print the
# PKG_REALVERSION 1.1pre18.
case "$PKG_NAME" in
tinc)
	VERSION="$(echo "$PKG_VERSION" | tr -d '_')"
	tinc --version | grep -F "tinc version $VERSION" &&
		tincd --version | grep -F "tinc version $VERSION"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
