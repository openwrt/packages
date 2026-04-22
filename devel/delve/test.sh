#!/bin/sh

case "$1" in
delve)
	dlv version 2>&1 | grep -qF "$2" || {
		echo "FAIL: dlv version did not print expected version '$2'"
		exit 1
	}
	echo "dlv version: OK"

	# Verify the binary is executable and responds to --help
	dlv help 2>&1 | grep -qi "usage\|debugger\|help" || {
		echo "FAIL: dlv help produced no usage output"
		exit 1
	}
	echo "dlv help: OK"
	;;
esac
