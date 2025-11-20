#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only

if [ "$1" = 'sqlite3-cli' ]; then
	sqlite3 -version | grep -F "$PKG_VERSION"
fi
