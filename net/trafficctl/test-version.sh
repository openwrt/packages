#!/bin/sh

# shellcheck shell=busybox

# The programs in /usr/libexec/trafficctl are helper scripts run by the init
# scripts, the hotplug hooks and the LuCI rpcd plugin. They take positional
# commands and do not support a --version flag.
case "$PKG_NAME" in
trafficctl)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
