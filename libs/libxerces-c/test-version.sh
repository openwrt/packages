#!/bin/sh

pkg=$1
ver=$2

case "$pkg" in
libxerces-c)
	exit 0
	;;
libxerces-c-samples)
	exit 0
	;;
*)
	echo "test-version.sh: unhandled sub-package '$pkg'" >&2
	exit 1
	;;
esac
