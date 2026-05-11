#!/bin/sh

# shellckeck shell=busybox

# checksec reported version doesn't match package version as of 3.1.0

case "$PKG_NAME" in
checksec)
	checksec --version 2>&1 | grep -qF "2.7.1"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
