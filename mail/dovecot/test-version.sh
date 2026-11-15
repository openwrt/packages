#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
dovecot[0-9]*)
	# The package name ends with the ABI version (dovecot2.3.21.1). Only
	# the dovecot binary reports a version. The services it starts and
	# the helper tools do not.
	dovecot --version | grep -F "$PKG_VERSION "
	;;

dovecot-utils)
	# doveadm has no version option. Check that it runs and look for the
	# ABI version string compiled into it, e.g. 2.3.ABIv21(2.3.21.1).
	doveadm pw -s SHA512-CRYPT -p test | grep -q '^{SHA512-CRYPT}' &&
		grep -aqF "($PKG_VERSION)" /usr/bin/doveadm
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
