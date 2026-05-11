#!/bin/sh

# zstdgrep and zstdless are shell script wrappers; only the zstd binary reports
# a version string
[ "$1" = "zstd" ] || exit 0

/usr/bin/zstd --version | grep -qF "$2"
