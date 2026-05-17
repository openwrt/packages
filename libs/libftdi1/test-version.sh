#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
ftdi_eeprom)
	ftdi_eeprom --version 2>&1 | grep -F "$PKG_VERSION"
	;;

libftdi1)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
