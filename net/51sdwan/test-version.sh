#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later

case "$PKG_NAME" in
51sdwan)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
