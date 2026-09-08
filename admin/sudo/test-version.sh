#!/bin/sh

# shellcheck shell=busybox

# PKG_VERSION substitutes p->_p for a valid apk version (1.9.17_p2); the binary
# embeds the real 1.9.17p2. Executing sudo just to read its version hangs under
# QEMU emulation (e.g. mips_24kc), so match the version string compiled into the
# binary instead of running it.
case "$1" in
sudo)
	grep -aqF "$(echo "$2" | tr -d '_')" /usr/bin/sudo
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
