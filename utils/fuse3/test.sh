#!/bin/sh

case "$1" in
	fuse3-utils)
		[ -x /usr/sbin/mount.fuse3 ]
		;;
	libfuse3)
		ls /usr/lib/libfuse3.so.* > /dev/null
		;;
esac
