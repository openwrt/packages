#!/bin/sh

case "$PKG_NAME" in
cifsmount)
	# mount.cifs -V prints "mount.cifs version: X.Y".
	mount.cifs -V 2>&1 | grep -F "$PKG_VERSION"
	;;
*)
	# smbinfo is a python sub-command tool with no version flag, so the
	# generic probe cannot read a version from it; nothing to assert.
	exit 0
	;;
esac
