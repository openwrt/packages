#!/bin/sh

# shellcheck shell=busybox

# /usr/sbin/trafficctl is a ucode CLI that takes positional commands, and
# /usr/libexec/trafficctl/trafficctl-telegram.uc is the bot's process, run
# by its init script. Neither supports a --version flag.
case "$PKG_NAME" in
trafficctl | trafficctl-telegram)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
