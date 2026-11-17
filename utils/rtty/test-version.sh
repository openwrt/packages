#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
rtty-mbedtls|rtty-nossl|rtty-openssl|rtty-wolfssl)
	# rtty -V logs the version to syslog unless stdout is a terminal, so
	# there is no output to check. Match the version string built into the
	# binary instead. It also holds source paths like rtty-9.1.0/src/main.c,
	# so compare whole NUL-terminated strings.
	tr '\0' '\n' < /usr/sbin/rtty | grep -Fx "$PKG_VERSION"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
