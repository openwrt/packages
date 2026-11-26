#!/bin/sh

# shellcheck shell=busybox

# targetctl has no version option and only prints its usage, so the generic
# per-executable version check cannot find the version. Check the version in
# the installed distribution metadata instead.
case "$1" in
python3-rtslib-fb)
	grep -x "Version: $2" /usr/lib/python3*/site-packages/rtslib_fb-*.dist-info/METADATA
	;;
python3-rtslib-fb-src)
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
