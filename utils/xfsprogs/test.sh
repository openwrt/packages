#!/bin/sh

case "$1" in
xfs-mkfs)
	mkfs.xfs -V 2>&1 | grep -F "$2"
	;;
xfs-fsck)
	xfs_repair -V 2>&1 | grep -F "$2"
	;;
xfs-admin)
	xfs_admin --help 2>&1 | grep -qi "xfs_admin\|usage" || \
	xfs_db --help 2>&1 | grep -qi "xfs_db\|usage"
	;;
xfs-growfs)
	xfs_growfs --help 2>&1 | grep -qi "xfs_growfs\|usage"
	;;
esac
