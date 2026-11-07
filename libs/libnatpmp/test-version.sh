#!/bin/sh

case "$1" in
libnatpmp1|natpmpc)
	exit 0
	;;
*)
	echo "test-version.sh: unhandled sub-package '$1'" >&2
	exit 1
	;;
esac
