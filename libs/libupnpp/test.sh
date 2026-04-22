#!/bin/sh

case "$1" in
libupnpp)
	ls /usr/lib/libupnpp.so.* >/dev/null 2>&1 || {
		echo "FAIL: libupnpp shared library not found in /usr/lib"
		exit 1
	}
	echo "libupnpp.so: OK"
	;;
esac
