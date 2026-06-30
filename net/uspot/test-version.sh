#!/bin/sh

# shellcheck shell=busybox

# uspot executables (radius-client, uspot, uspot-das) do not expose the
# package version via --version or --help. Skip the generic version probe.

case "$PKG_NAME" in
uspot|uspotfilter|uspot-www)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
