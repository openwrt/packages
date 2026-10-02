#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# shellcheck shell=busybox

case "$1" in
veracrypt)
	veracrypt --text --version 2>&1 | grep -F "$2"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
