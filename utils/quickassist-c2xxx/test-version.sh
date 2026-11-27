#!/bin/sh

# shellcheck shell=busybox

# The vendor adf_ctl and icp_gige_watchdog only print their own usage text
# and never report a version, so the generic version check cannot match.
# Only quickassist-c2xxx itself is in the tested set here - the kmod-crypto-qat-c2xxx*
# packages built alongside it aren't staged into the test container's feed.
case "$PKG_NAME" in
quickassist-c2xxx)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
