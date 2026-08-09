#!/bin/sh

case "$1" in
uradvd)
	# The binary is built with VERSION=$(PKG_SOURCE_DATE) and prints
	# "uradvd 2025-09-20", while PKG_VERSION is 2025.09.20~<short hash>.
	version=$(echo "${2%%~*}" | tr . -)
	uradvd --version | grep -Fx "uradvd $version"
	;;

*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
