#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

# shellckeck shell=busybox

case "$PKG_NAME" in
golang?.??-doc|\
golang?.??-misc|\
golang?.??-src|\
golang?.??-tests)
	exit 0
	;;

golang?.??)
	go version | grep -F " go$PKG_VERSION "
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
