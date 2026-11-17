#!/bin/sh

# shellcheck shell=busybox

#xsltproc doesn't say it's own version but only depends
case "$PKG_NAME" in
xsltproc|libxslt|libexslt)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
