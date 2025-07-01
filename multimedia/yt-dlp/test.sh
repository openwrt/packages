#!/bin/sh

if [ "$1" = 'yt-dlp' ]; then
	yt-dlp --version | sed 's/\.0\+/./g' | grep -F "$PKG_VERSION"
fi
