#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only

case "$1" in
v2raya)
	/usr/bin/v2raya --version | grep -F "$2"
	;;
*)
	exit 1
	;;
esac
