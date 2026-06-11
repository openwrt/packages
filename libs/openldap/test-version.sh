#!/bin/sh                                                                                                                                   

# shellcheck shell=busybox

case "$PKG_NAME" in
openldap-server)
	slapd -V 2>&1 | grep -F "$PKG_VERSION"
	;;

openldap-utils)
	ldapsearch -VV 2>&1 | grep -F "$PKG_VERSION"
	;;

libopenldap)
	# Shared library.
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
