#!/bin/sh

case "$1" in
	attr)
		# attr does not implement --version; just verify it is present
		[ -x /usr/bin/attr ] || exit 1
		;;
esac
