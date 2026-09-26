#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=busybox
# Skip generic --version probing of mount.veracrypt (it is a mount helper).
# CI runs: test-version.sh PKG_NAME PKG_VERSION  (PKG_VERSION includes PKG_RELEASE)

case "$1" in
veracrypt)
	veracrypt --text --version 2>&1 | grep -F "${2%%-*}"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
