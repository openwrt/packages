#!/bin/sh

case "$1" in
	fwupdmgr|fwupdtool) "$1" --version 2>&1 | grep "runtime\s*org.freedesktop.fwupd\s*$2" ;;
esac
