#!/bin/sh

case "$1" in
lttng-ust)
	ls /usr/lib/liblttng-ust.so.* >/dev/null 2>&1 || {
		echo "FAIL: liblttng-ust.so not found in /usr/lib"
		exit 1
	}
	echo "liblttng-ust: OK"

	ls /usr/lib/liblttng-ust-tracepoint.so.* >/dev/null 2>&1 || {
		echo "FAIL: liblttng-ust-tracepoint.so not found in /usr/lib"
		exit 1
	}
	echo "liblttng-ust-tracepoint: OK"
	;;
esac
