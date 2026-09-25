#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
modemmanager)
	exit 0
	;;

modemmanager-rpcd)
	/usr/libexec/rpcd/modemmanager list ""
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
