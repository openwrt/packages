#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
syslog-ng)
	# The daemon is the only executable that reports a version. The tools
	# shipped next to it (dqtool, loggen, pdbtool, persist-tool,
	# syslog-ng-ctl, syslog-ng-debun, update-patterndb) only print their
	# usage, so the generic probe cannot read a version from them.
	syslog-ng --version | grep -F "$PKG_VERSION"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
