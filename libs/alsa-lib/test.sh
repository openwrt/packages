#!/bin/sh

case "$1" in
	aserver)
		# aserver does not implement --version; just verify it is present
		[ -x /usr/bin/aserver ] || exit 1
		;;
esac
