#!/bin/sh

case "$1" in
corosync-qdevice)
	corosync-qnetd -v 2>&1 | grep -F "$2"
	;;
esac
