#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
	acl)
		getfacl --version | grep -F "$PKG_VERSION" || exit 1
		setfacl --version | grep -F "$PKG_VERSION" || exit 1
		# chacl does not implement --version, so just verify it is present
		[ -x /usr/bin/chacl ] || exit 1
		;;

	libacl)
		# ships no executable, nothing to assert
		exit 0
		;;

	*)
		echo "Untested package: $1" >&2
		exit 1
		;;
esac
