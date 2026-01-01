#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

[ "$1" = 'golang1.25' ] || exit 0

go version | grep -F " go$PKG_VERSION "
