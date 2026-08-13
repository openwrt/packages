#!/bin/sh
# There is no SMB server or kmod-fs-cifs in the CI sandbox, so exercise the
# argument/usage paths that run before any mount syscall or SMB I/O.

case "$1" in
cifsmount)
	# mount.cifs ships with its mount.smb3 alias and prints usage (rather
	# than crashing) when invoked with no target and mountpoint.
	[ -x /usr/sbin/mount.cifs ] || { echo "FAIL: mount.cifs not installed"; exit 1; }
	[ -L /usr/sbin/mount.smb3 ] || { echo "FAIL: mount.smb3 alias missing"; exit 1; }
	[ "$(readlink /usr/sbin/mount.smb3)" = "mount.cifs" ] || { echo "FAIL: mount.smb3 points elsewhere"; exit 1; }
	out="$(mount.cifs 2>&1)"
	echo "$out" | grep -qi usage || { echo "FAIL: no usage from mount.cifs: $out"; exit 1; }
	echo "cifsmount: usage/alias OK"
	;;
smbinfo)
	# smbinfo lists its subcommands when run without arguments.
	[ -x /usr/bin/smbinfo ] || { echo "FAIL: smbinfo not installed"; exit 1; }
	out="$(smbinfo 2>&1)"
	echo "$out" | grep -qiE 'usage|command' || { echo "FAIL: no usage from smbinfo: $out"; exit 1; }
	echo "smbinfo: usage OK"
	;;
*)
	exit 0
	;;
esac
