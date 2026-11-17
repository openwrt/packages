#!/bin/sh

case "$1" in
	libnetconf2)
		[ -e /usr/lib/libnetconf2.so ] || {
			echo "libnetconf2.so not found" >&2
			exit 1
		}
		[ -e /usr/lib/libnetconf2.so.5 ] || {
			echo "libnetconf2.so.5 not found" >&2
			exit 1
		}
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
