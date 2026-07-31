#!/bin/sh

# shellcheck shell=busybox

# None of the giflib-utils executables print the package version.
# Skip the generic version probe.

case "$PKG_NAME" in
giflib|giflib-utils)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
