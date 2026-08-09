#!/bin/sh
#
# Version check override for the prosody package.
#
# Neither prosody nor prosodyctl reports its version on any of the flags the
# generic tests probe; the version is only recorded in prosody.version.

case "$1" in
prosody)
	grep -F "$2" /usr/lib/prosody/prosody.version
	;;

*)
	echo "test-version.sh: unknown subpackage '$1' — refusing to silently pass" >&2
	echo "test-version.sh: update net/prosody/test-version.sh to cover it" >&2
	exit 1
	;;
esac
