#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
mdnsresponder)
	# Meta package, no executables
	exit 0
	;;

mdnsd|mdns-utils)
	# None of the shipped binaries print the package version on --help;
	# upstream just dumps usage. Skip the generic version probe.
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
