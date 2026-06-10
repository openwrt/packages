#!/bin/sh

case "$1" in
libminiupnpc)
	# Verify the shared library is installed
	ls /usr/lib/libminiupnpc.so.* > /dev/null
	;;
miniupnpc)
	# upnpc without args exits non-zero but prints usage including port
	# redirection operations and the discover (-l) option
	upnpc 2>&1 | grep -qi "Add port redirection\|port redirection\|upnp"
	;;
*)
	exit 0
	;;
esac
