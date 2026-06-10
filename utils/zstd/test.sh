#!/bin/sh

case "$1" in
	zstd)
		# zstdgrep and zstdless are shell script wrappers; they do not output a version
		[ -x /usr/bin/zstdgrep ] || exit 1
		[ -x /usr/bin/zstdless ] || exit 1
		;;
esac
