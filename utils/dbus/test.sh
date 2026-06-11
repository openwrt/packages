#!/bin/sh

case "$1" in
	dbus-utils)
		# dbus-monitor, dbus-send, dbus-test-tool do not implement --version
		for bin in dbus-monitor dbus-send dbus-test-tool; do
			[ -x "/usr/bin/$bin" ] || exit 1
		done
		;;
esac
