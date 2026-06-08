#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
quickjs)
	qjs --eval 'console.log(2 ** 8)' | grep 256
	;;
esac
