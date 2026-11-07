#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
duperemove)
	# btrfs-extent-same has no --version/--help, so it cannot use the
	# generic per-executable version check; override it here and
	# verify the two binaries that do report a version.
	duperemove --version 2>&1 | grep -F "$PKG_VERSION" || exit 1
	hashstats --version 2>&1 | grep -F "$PKG_VERSION" || exit 1
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
