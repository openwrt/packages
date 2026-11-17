#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
libudns)
	# dns_version() returns this string
	grep -aqF "$PKG_VERSION" /usr/lib/libudns.so.0
	;;
udns-dnsget)
	dnsget -h 2>&1 | grep -F "udns version $PKG_VERSION"
	;;
udns-rblcheck)
	rblcheck -h 2>&1 | grep -F "udns-rblcheck $PKG_VERSION"
	;;
udns-ex-rdns)
	# ex-rdns is an example program and has no version or help output;
	# check the library it runs against instead.
	grep -aqF "$PKG_VERSION" /usr/lib/libudns.so.0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
