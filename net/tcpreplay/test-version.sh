#!/bin/sh

# shellcheck shell=busybox

# tcpreplay and tcpreplay-edit probe a network interface's link state while
# parsing their options, so under the QEMU runtime running any of these tools
# with --version is unreliable: tcpreplay/tcpreplay-edit either abort
# ("eth0: SIOCETHTOOL(ETHTOOL_GLINK) ioctl failed: Not a tty") or hang forever
# (observed on big-endian mips). Do not execute the binaries here at all;
# assert the version string compiled into each one instead. Actually running
# the file-processing tools is covered by test.sh. The presence of this script
# also disables the generic per-executable probe, which would otherwise run
# the same hanging --version.

version="$2"

check() {
	bin="/usr/bin/$1"
	[ -x "$bin" ] || {
		echo "missing executable: $bin" >&2
		return 1
	}
	grep -qaF "$version" "$bin" || {
		echo "version $version not found in $bin" >&2
		return 1
	}
}

case "$1" in
tcpbridge | tcpcapinfo | tcpliveplay | tcpprep | tcpreplay | tcpreplay-edit | tcprewrite)
	check "$1"
	;;
tcpreplay-all)
	# Meta-package: ships no binary of its own, the modules arrive as
	# dependencies. Validate a representative always-present module.
	check tcprewrite
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
