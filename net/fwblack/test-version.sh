#!/bin/sh
# test-version.sh - version check override for fwblack.
# The generic CI version check is skipped when this file exists.
# NOTE: plain grep without -q here - matches stay visible in CI logs.
case "$PKG_NAME" in
fwblack)
	/usr/sbin/fw-black --version | grep -F "$PKG_VERSION"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
