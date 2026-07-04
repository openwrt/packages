#!/bin/sh

case "$1" in
	prosody)
		grep -F "$2" /usr/lib/prosody/prosody.version || exit 1
		;;
esac
