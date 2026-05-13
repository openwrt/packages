#!/bin/sh
# Perl script wrappers do not output the OpenWrt package version string
case "$1" in
	perlbase-archive|perlbase-pod|perlbase-test) exit 0 ;;
esac
