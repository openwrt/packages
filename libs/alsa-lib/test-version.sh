#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
alsa-lib)
	# Shared library
	exit 0
	;;

aserver)
	# aserver does not implement --version
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
