#!/bin/sh

case "$PKG_NAME" in
corosync-qnetd)
	corosync-qnetd -v 2>&1 | grep -F "$PKG_VERSION"
	;;
*)
	echo "Unsupported package: $PKG_NAME" >&2
	exit 1
	;;
esac
