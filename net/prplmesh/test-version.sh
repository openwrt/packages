#!/bin/sh

# shellcheck shell=busybox

set -eu

case "$PKG_NAME" in
prplmesh)
	grep -F "prplmesh_version=$PKG_VERSION" /usr/share/prplmesh/config/version
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
