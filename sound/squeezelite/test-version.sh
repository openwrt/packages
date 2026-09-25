#!/bin/sh

# shellcheck shell=busybox

# PKG_VERSION dots the build number for apk; squeezelite reports it hyphenated
version=$(echo "$PKG_VERSION" | sed 's/\.\([^.]*\)$/-\1/')

case "$PKG_NAME" in
squeezelite-full | squeezelite-dynamic | squeezelite-custom)
	squeezelite '-?' 2>&1 | grep -F "Squeezelite ${version},"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
