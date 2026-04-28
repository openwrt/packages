#!/bin/sh

case "$1" in
	domoticz)
		[ -x /usr/bin/domoticz ] || exit 1
		;;
esac
