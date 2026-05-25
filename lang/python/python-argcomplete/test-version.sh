#!/bin/sh
#
case "$1" in
python3-argcomplete|python3-argcomplete-src)
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
