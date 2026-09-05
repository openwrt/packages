#!/bin/sh

# shellcheck shell=busybox

# The shell runtime does not embed its release number, so the generic CI probe
# cannot discover PKG_VERSION through --version or --help. Restrict this
# override to the expected package. The generic executable check still verifies
# that the installed CLI exists and is executable.

case "$1" in
led-nightmode)
	exit 0
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
