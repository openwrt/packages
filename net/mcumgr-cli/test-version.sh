#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
mcumgr-cli)
	# Upstream hardcodes 0.0.0-dev in a struct initialized by main, so the
	# package version cannot be injected with GO_PKG_LDFLAGS_X.
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
