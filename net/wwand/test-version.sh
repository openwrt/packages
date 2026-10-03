#!/bin/sh

# shellcheck shell=busybox

# wwand's installed executables — the daemon (/usr/sbin/wwand), the wwandctl CLI
# (/usr/bin/wwandctl) and the migrate helper (/usr/libexec/wwand/migrate) — do
# not print PKG_VERSION, so the generic runtime version check cannot match it.
# Opt out for every package defined in this Makefile.
case "$PKG_NAME" in
wwand|wwand-qmi|wwand-mbim|wwand-ncm|wwand-mhi|wwand-esim)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
