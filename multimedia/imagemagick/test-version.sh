#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
imagemagick)
	# PKG_VERSION is X.Y.Z.R but the binaries print X.Y.Z-R.
	magick -version | grep -F "$(echo "$PKG_VERSION" | sed 's/\.\([0-9]*\)$/-\1/')"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
