#!/bin/sh

case "$1" in
	prosody)
		grep -qF "$2" /usr/lib/prosody/prosody.version || exit 1
		;;
esac
