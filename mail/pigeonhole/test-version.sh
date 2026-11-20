#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
dovecot-pigeonhole)
	# The Sieve tools print only their usage. doveconf loads the
	# Pigeonhole settings plugin and prints its version.
	doveconf -n | grep -F "# Pigeonhole version $PKG_VERSION "
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
