#!/bin/sh

case "$1" in
	checksec)
		# Analyze a known binary; output must include the binary path
		checksec --file=/usr/bin/checksec 2>&1 | grep -qF "checksec"
		;;
esac
