#!/bin/sh

# shellcheck shell=busybox

# The collector is a daemon without a version option, which the generic
# version check would start instead: check that it compiles.
case "$1" in
bird-babel-collector)
	ucode -c -o /dev/null /usr/sbin/bird-babel-collector && echo "$1 $2 compiles"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
