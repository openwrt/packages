#!/bin/sh

# shellcheck shell=busybox

# netopeer2-cli has no -V flag; test.sh covers both subpackages.
case "$PKG_NAME" in
netopeer2-server|netopeer2-cli)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
