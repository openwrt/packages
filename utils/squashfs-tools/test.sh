#!/bin/sh

case "$1" in
	squashfs-tools-mksquashfs)
		mksquashfs -version 2>&1 | grep -F "$2"
		;;
	squashfs-tools-unsquashfs)
		unsquashfs -version 2>&1 | grep -F "$2"
		;;
esac
