#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
sane-frontends)
	sane-config --version | grep -F "$PKG_VERSION"
	;;
sane-daemon)
	# saned has no version option; it only prints its usage, so there is
	# nothing to check. The version is covered by sane-frontends.
	exit 0
	;;
libsane | sane-backends | sane-backends-all | sane-*)
	# The library, the backend modules and the meta packages contain no
	# executables that report a version.
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
