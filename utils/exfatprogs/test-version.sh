#!/bin/sh

# fsck.exfat and mkfs.exfat print the version but exit non-zero when called
# with -V (FSCK_EXIT_SYNTAX_ERROR / EXIT_FAILURE), so the generic per-file
# version check skips their output.  Check the version here instead.
case "$1" in
exfat-fsck)
	fsck.exfat -V 2>&1 | grep -qF "$2"
	;;
exfat-mkfs)
	mkfs.exfat -V 2>&1 | grep -qF "$2"
	;;
*)
	exit 0
	;;
esac
