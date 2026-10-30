#!/bin/sh

# shellcheck shell=busybox

set -e

case "$1" in
starlink-dish)
	starlink-dish --version | grep -F "$2"

	# No dish in CI: an unreachable address must return a JSON error
	# promptly instead of hanging.
	timeout 30 starlink-dish -d http://127.0.0.1:1 dish | grep -F '"available":false'
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
