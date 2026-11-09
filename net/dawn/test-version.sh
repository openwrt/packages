#!/bin/sh

# shellcheck shell=busybox

case "$1" in
	dawn)
		# dawn has no version flag and daemonizes when run; just
		# verify the binary is present
		[ -x /usr/sbin/dawn ] || exit 1
		;;

	*)
		echo "Untested package: $1" >&2
		exit 1
		;;
esac
