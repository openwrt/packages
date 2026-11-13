#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

# shellcheck shell=busybox

case "$PKG_NAME" in
onvif-simple-server)
	# The executables do not report a version
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
