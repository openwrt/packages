#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
openthread-br)
	# The feed uses the snapshot date and hash. The daemon reports its
	# upstream project version from the pinned ot-br-posix source.
	expected=0.3.0
	actual=$(/usr/sbin/otbr-agent --version) || exit 1
	if [ "$actual" != "$expected" ]; then
		printf 'Expected otbr-agent version %s, got %s\n' "$expected" "$actual" >&2
		exit 1
	fi
	;;
luci-app-openthread)
	# This package provides LuCI files and has no executable to check.
	;;
*)
	printf 'Untested package: %s\n' "$PKG_NAME" >&2
	exit 1
	;;
esac
