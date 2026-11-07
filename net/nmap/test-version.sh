#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
nmap|\
nmap-ssl|\
nmap-full)
	nmap --version 2>&1 | grep -F "$PKG_VERSION"
	;;
ncat|\
ncat-ssl|\
ncat-full)
	ncat --version 2>&1 | grep -F "$PKG_VERSION"
	;;
nping|\
nping-ssl)
	nping --version 2>&1 | grep -F "$PKG_VERSION"
	;;

#ndiff has no version information
ndiff|\
ndiff-src)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
