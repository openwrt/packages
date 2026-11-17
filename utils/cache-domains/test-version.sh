#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
cache-domains-mbedtls|cache-domains-openssl|cache-domains-wolfssl)
	# Shell script without version information
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
