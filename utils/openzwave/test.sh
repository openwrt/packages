#!/bin/sh
case "$1" in
	openzwave)
		[ -x /usr/bin/MinOZW ] || exit 1
		;;
esac
