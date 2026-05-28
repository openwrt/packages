#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
bind-check)
	named-checkconf -v 2>&1 | grep -F "$PKG_VERSION"
	named-checkzone -v 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-client)
	nsupdate -V 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-dig)
	dig -v 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-dnssec)
	dnssec-keygen -V 2>&1 | grep -F "$PKG_VERSION"
	dnssec-settime -V 2>&1 | grep -F "$PKG_VERSION"
	dnssec-signzone -V 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-host)
	host -V 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-nslookup)
	nslookup -version 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-rndc)
	rndc -help 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-server)
	named -v 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-tools)
	delv -v 2>&1 | grep -F "$PKG_VERSION"
	;;

bind-ddns-confgen|\
bind-libs|\
bind-server-filter-aaaa)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
