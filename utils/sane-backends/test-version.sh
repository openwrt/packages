#!/bin/sh

# shellcheck shell=busybox

# saned (sane-daemon) and the scanner backend plugins do not print the package
# version when run, which causes the generic version probe to fail.
# Skip the generic version probe for all sane-backends subpackages.

case "$PKG_NAME" in
libsane|sane-*)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
