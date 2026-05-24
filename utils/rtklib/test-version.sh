#!/bin/sh
#
# Generic version-check override.
#
# RTKLIB's command-line tools (convbin, pos2kml, rnx2rtkp, rtkrcv, str2str)
# don't expose a --version flag; they print only a usage/synopsis block on
# unrecognized options, with no PKG_VERSION string anywhere in the output.
# The companion test.sh exercises actual invocation, so the generic version
# probe has no value here. Emit a line containing PKG_VERSION so the CI
# framework's "Version check override" passes.

case "$1" in
convbin|pos2kml|rnx2rtkp|rtkrcv|str2str)
	echo "$1 $PKG_VERSION"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
