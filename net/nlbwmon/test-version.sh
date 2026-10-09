#!/bin/sh

case "$1" in
nlbwmon)
	# nlbwmon has no --version flag and is versioned by a git snapshot
	# (PKG_SOURCE_DATE + commit hash), so the binary emits no string that
	# matches PKG_VERSION. Skip the generic version check for this package.
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
