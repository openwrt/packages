#!/bin/sh
# test-version.sh - version check override for fwblack packages.
# The generic CI version check is skipped when this file exists.
# NOTE: plain grep without -q here - matches stay visible in CI logs.
case "$PKG_NAME" in
fwblack)
	/usr/sbin/fw-black --version | grep -F "$PKG_VERSION"
	;;
luci-app-fwblack)
	# UI-assets-only package, no version-reporting executable.
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
