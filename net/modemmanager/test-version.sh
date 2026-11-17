#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
modemmanager)
	ModemManager --version | grep -F "$PKG_VERSION"
	;;

modemmanager-rpcd)
	# no version to check
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
