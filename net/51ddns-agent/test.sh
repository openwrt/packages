#!/bin/sh

case "$1" in
	51ddns-agent)
		51ddns-agent --version | grep -F "$2"
		;;
esac
