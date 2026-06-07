#!/bin/sh
case "$PKG_NAME" in
perl)
	perl -v 2>&1 | grep -q "v$PKG_VERSION"
	;;
perlbase-archive|perlbase-pod|perlbase-test)
	# Perl script wrappers do not output the OpenWrt package version string
	exit 0
	;;
esac
