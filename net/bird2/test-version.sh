#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
bird2|bird2c|bird2cl)
	# birdc and birdcl do not report a version; check the daemon,
	# which both clients depend on anyway
	bird --version 2>&1 | grep -F "$PKG_VERSION"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
