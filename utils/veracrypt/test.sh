#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=busybox

case "$1" in
veracrypt)
	test -x /usr/bin/veracrypt || exit 1
	test -x /sbin/mount.veracrypt || exit 1
	veracrypt --text --version 2>&1 | grep -F "$2" || exit 1
	veracrypt --text --help 2>&1 | grep -F -- '--stdin' || exit 1
	# Algorithm self-tests (skipped at build time: cross-compiled).
	veracrypt --text --test
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
