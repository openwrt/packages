#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
krb5-libs|\
krb5-server|\
krb5-server-extras|\
krb5-client)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
