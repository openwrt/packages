#!/bin/sh

# shellcheck shell=busybox

# Every executable in these packages is a shell script without a version
# flag, so nothing can print PKG_VERSION for the generic check.
case "$1" in
wg-installer-server|wg-installer-server-hotplug-*|wg-installer-client)
	echo "$1: shell scripts without a version flag, version $2 not probed"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
