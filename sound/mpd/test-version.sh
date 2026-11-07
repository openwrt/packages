#!/bin/sh

# shellcheck shell=busybox

# mpd 0.24 refuses to start when /proc/self/status reports more than one
# thread before main() runs, which it does under qemu-user, so the binary
# cannot be asked for its version on the emulated CI targets. Match the
# version string compiled into it instead.
case "$1" in
mpd-full | mpd-mini)
	grep -aqF "$2" /usr/bin/mpd
	;;
mpd-avahi-service)
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
