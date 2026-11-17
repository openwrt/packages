#!/bin/sh

case "$1" in
	libyang)
		[ -e /usr/lib/libyang.so ] || {
			echo "libyang.so not found" >&2
			exit 1
		}
		[ -e /usr/lib/libyang.so.5 ] || {
			echo "libyang.so.5 not found" >&2
			exit 1
		}
		;;
	yanglint)
		yanglint --version | grep -F "$2"
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
