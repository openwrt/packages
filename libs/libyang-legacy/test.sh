#!/bin/sh

case "$1" in
	libyang-legacy)
		# Runtime-only; the unversioned symlink belongs to libyang 5.x.
		[ -e /usr/lib/libyang.so.3 ] || {
			echo "libyang.so.3 not found" >&2
			exit 1
		}
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
