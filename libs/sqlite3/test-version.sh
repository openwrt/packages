#!/bin/sh

# shellcheck shell=busybox

# PKG_VERSION uses the upstream download format, for example 3530100,
# while sqlite3 prints 3.53.1
VERSION="$(echo "$PKG_VERSION" | sed -E \
	-e 's/^([0-9])([0-9]{2})([0-9]{2})([0-9]{2})$/\1.\2.\3/' \
	-e 's/\.0([0-9])/.\1/g')"

case "$PKG_NAME" in
sqlite3-cli)
	sqlite3 --version | grep -F "$VERSION "
	;;

libsqlite3*)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
