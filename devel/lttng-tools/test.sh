#!/bin/sh

case "$1" in
lttng-tools)
	lttng --version 2>&1 | grep -qF "$2" || {
		echo "FAIL: lttng --version did not print expected version '$2'"
		exit 1
	}
	echo "lttng version: OK"

	# Library must be present
	[ -e /usr/lib/liblttng-ctl.so.4 ] || \
	ls /usr/lib/liblttng-ctl.so.* >/dev/null 2>&1 || {
		echo "FAIL: liblttng-ctl.so not found"
		exit 1
	}
	echo "liblttng-ctl: OK"
	;;
esac
