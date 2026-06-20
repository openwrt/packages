#!/bin/sh

case "$1" in
luci-app-openthread)
	exit 0
	;;
openthread-br)
	/usr/sbin/otbr-agent --version | grep -F "0.3.0"
	;;
esac
