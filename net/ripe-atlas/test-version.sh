#!/bin/sh
# /usr/sbin/ripe-atlas has no version flag (running it boots the probe), so
# accept the version for our packages and skip the generic per-exec probe.
case "$1" in
ripe-atlas-common|ripe-atlas-probe|ripe-atlas-anchor)
	exit 0
	;;
esac
exit 1
