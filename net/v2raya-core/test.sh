#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only

case "$1" in
v2raya-core)
	/usr/bin/v2raya_core version | grep -F "$2"
	;;
*)
	exit 1
	;;
esac
