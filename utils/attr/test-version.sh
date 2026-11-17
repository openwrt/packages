#!/bin/sh

# shellcheck shell=busybox

case "$1" in
	attr)
		getfattr --version | grep -F "$2" || exit 1
		setfattr --version | grep -F "$2" || exit 1
		# attr does not implement --version; its getopt string is
		# "s:V:g:r:lqLRS", where -V takes a value, so just verify it
		# is present
		[ -x /usr/bin/attr ] || exit 1
		;;

	libattr)
		# ships no executable, nothing to assert
		exit 0
		;;

	*)
		echo "Untested package: $1" >&2
		exit 1
		;;
esac
