#!/bin/sh

case "$1" in
	"rclone")
		rclone version | grep "$2"
		;;
esac
