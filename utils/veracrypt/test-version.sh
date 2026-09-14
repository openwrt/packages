#!/bin/sh
# Skip generic --version probing of mount.veracrypt (it is a mount helper).

case "$PKG_NAME" in
veracrypt)
	veracrypt --text --version 2>&1 | grep -F "$PKG_VERSION"
	;;
*)
	echo "test-version.sh: unhandled package '$PKG_NAME'" >&2
	exit 1
	;;
esac
