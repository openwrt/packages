#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
libzip-*)
	# library packages
	exit 0
	;;

zipcmp)
	zipcmp -V 2>&1 | grep -qF "libzip $PKG_VERSION"
	exit 0
	;;

zipmerge)
	zipmerge -V 2>&1 | grep -qF "libzip $PKG_VERSION"
	exit 0
	;;

ziptool)
	# does not provide -V or prints version on -h
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
