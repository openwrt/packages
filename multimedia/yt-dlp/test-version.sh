#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

# shellcheck shell=busybox

case "$PKG_NAME" in
yt-dlp)
	yt-dlp --version | sed 's/\.0\+/./g' | grep -F "$PKG_VERSION"
	;;

yt-dlp-src)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
