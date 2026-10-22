#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only

case "$1" in
ble-service)
	/usr/libexec/rpcd/ble --version | grep -F "$2" || exit 1
	/usr/libexec/rpcd/ble list | grep -Fx \
		'{"connect":{"address":""},"disconnect":{"address":""},"scan":{"seconds":32},"start":{},"status":{},"stop":{}}' || exit 1
	printf '%s\n' '{"seconds":4}' | /usr/libexec/rpcd/ble call scan |
		grep -F '"code":"INVALID_REQUEST"'
	;;
*)
	exit 1
	;;
esac
