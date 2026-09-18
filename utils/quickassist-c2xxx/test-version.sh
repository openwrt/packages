#!/bin/sh

# shellcheck shell=busybox

# The vendor adf_ctl and icp_gige_watchdog only print their own usage text
# and never report a version, so the generic version check cannot match.
case "$PKG_NAME" in
quickassist-c2xxx | kmod-crypto-qat-c2xxx | kmod-crypto-qat-c2xxx-usdm)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
