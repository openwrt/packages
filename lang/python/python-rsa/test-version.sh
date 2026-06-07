#!/bin/sh

# shellcheck shell=busybox

# The pyrsa-* command-line tools use argparse and do not print the package
# version with any of the flags probed by the generic version check, so it
# cannot be detected from the executables. Functionality is covered by test.sh.
case "$PKG_NAME" in
python3-rsa | python3-rsa-src)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
