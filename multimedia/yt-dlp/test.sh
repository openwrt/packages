#!/bin/sh

if [ "$1" = 'yt-dlp' ]; then
	yt-dlp --version 2>&1 | sed 's/\.0\+/./g' | grep -x "$PKG_VERSION"
fi
