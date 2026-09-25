#!/bin/sh

case "$1" in
	sispmctl)
		# Help output works without a USB device connected
		sispmctl -? 2>&1 | grep -qiF "sispmctl"
		;;
	libsispmctl)
		ls /usr/lib/libsispmctl.so.* > /dev/null
		;;
esac
