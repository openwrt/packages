#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

case "$1" in
	golang*doc|golang*misc|golang*src|golang*test) exit ;;
esac

go version | grep -F " go$PKG_VERSION "
