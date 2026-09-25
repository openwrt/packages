#!/bin/sh

# shellcheck shell=busybox

# The jp command-line tool takes a required expression argument and has no
# version flag, so the generic version check cannot detect the version from it.
# The version is covered by the import check in test.sh instead.
case "$PKG_NAME" in
python3-jmespath | python3-jmespath-src)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
