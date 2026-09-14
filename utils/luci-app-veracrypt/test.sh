#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
case "$PKG_NAME" in
luci-app-veracrypt)
	exit 0
	;;
*)
	echo "test.sh: unhandled package '$PKG_NAME'" >&2
	exit 1
	;;
esac
