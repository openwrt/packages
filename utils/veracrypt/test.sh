#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=busybox
# CI runs: test.sh PKG_NAME PKG_VERSION  (PKG_VERSION includes PKG_RELEASE)

case "$1" in
veracrypt)
	test -x /usr/bin/veracrypt || exit 1
	test -x /sbin/mount.veracrypt || exit 1
	veracrypt --text --help 2>&1 | grep -F -- '--stdin'
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
