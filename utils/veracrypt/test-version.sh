#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=busybox
# Skip generic --version probing of mount.veracrypt (it is a mount helper).

case "$PKG_NAME" in
veracrypt)
	veracrypt --text --version 2>&1 | grep -F "$PKG_VERSION"
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
