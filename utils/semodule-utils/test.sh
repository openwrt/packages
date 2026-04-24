#!/bin/sh

case "$1" in
semodule-expand|semodule-link|semodule-package|semodule-unpackage)
	# All semodule tools print usage to stderr and exit non-zero with no args.
	# Just verify they are present and executable.
	tool="semodule_${1#semodule-}"
	if ! command -v "$tool" > /dev/null 2>&1; then
		echo "ERROR: $tool not found"
		exit 1
	fi
	echo "$1 OK"
	;;
*)
	exit 0
	;;
esac
