#!/bin/sh

# shellcheck shell=busybox

case "$1" in
rustdesk-server)
	hbbs --version | grep -F "$2" && hbbr --version | grep -F "$2"
	;;

rustdesk-utils)
	echo "rustdesk-utils has no version flag"
	;;

*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
