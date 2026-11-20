#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
lcd4linux-custom|lcd4linux-full)
	# lcd4linux prints its own version 0.11.0-SVN-1193. PKG_VERSION is the
	# date and hash of the git snapshot, which the binary does not contain.
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
