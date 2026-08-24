#!/bin/sh

# shellcheck shell=busybox

# cffi 2.x ships the cffi-gen-src console tool, a subcommand CLI with no version
# flag, so the generic per-executable version check cannot read the version from
# it. The version is asserted by the import check in test.sh instead.
case "$PKG_NAME" in
python3-cffi | python3-cffi-src)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
