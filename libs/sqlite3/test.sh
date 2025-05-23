#!/bin/sh

if [ "$1" = 'sqlite3-cli' ]; then
	sqlite3 -version 2>&1 | cut -d' ' -f1 | grep -x "$PKG_VERSION"
fi
