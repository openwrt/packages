#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
dovecot-pigeonhole)
	# PKG_VERSION starts with the Dovecot version, e.g. 2.3.21.1.0.5.21.1
	# for Pigeonhole 0.5.21.1. The Sieve tools print only their usage.
	# doveconf loads the Pigeonhole settings plugin and prints its version.
	DOVECOT_VERSION="$(dovecot --version | cut -d ' ' -f 1)"
	doveconf -n | grep -F "# Pigeonhole version ${PKG_VERSION#"$DOVECOT_VERSION".} "
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
