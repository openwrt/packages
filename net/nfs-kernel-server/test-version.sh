#!/bin/sh

# shellcheck shell=busybox

# The NFS utilities (sm-notify, rpc.nfsd, rpc.mountd, etc.) do not reliably
# report the package version in a way the generic CI probe can detect, and
# several require kernel/netlink support unavailable in the sandbox.
# Functionality is exercised by the companion test.sh.

case "$PKG_NAME" in
nfs-kernel-server|\
nfs-kernel-server-v4|\
nfs-kernel-server-utils|\
nfs-utils|\
nfs-utils-v4)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
