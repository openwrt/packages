#!/bin/sh

case "$1" in
libqb)
	ls /usr/lib/libqb.so.* > /dev/null
	;;
esac
