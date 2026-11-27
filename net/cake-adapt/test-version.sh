#!/bin/sh

case "$1" in
cake-adapt|cake-adapt-mqtt|cake-adapt-mqtt-ssl)
	cake-adapt -v | grep -F "$2"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
