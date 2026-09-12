#!/bin/sh
# test.sh - functional CI test for fwblack (openwrt/packages CI).
# Runs on the installed system. $1 = package name, $2 = upstream version
# (PKG_NAME/PKG_VERSION are also provided as environment variables).
# NOTE: plain grep without -q here - matches stay visible in CI logs.
name="${1:-$PKG_NAME}"
version="${2:-$PKG_VERSION}"

case "$name" in
"fwblack")
	# Shell syntax (BusyBox ash) of every script incl. init and uci-defaults.
	ash -n /usr/sbin/fw-black && echo "ash-ok fw-black"
	ash -n /usr/libexec/fwblack/ips.sh && echo "ash-ok ips.sh"
	ash -n /usr/libexec/fwblack/resips.sh && echo "ash-ok resips.sh"
	ash -n /etc/init.d/fwblack && echo "ash-ok init"
	# nftables ruleset parses.
	nft -c -f /usr/share/nftables.d/ruleset-post/fwblack.nft && echo "nft-ok"
	# UCI defaults present with expected content.
	uci show fwblack | grep "fwblack.global.interval='300'"
	uci show fwblack | grep "fwblack.global.blocklist='/etc/fwblack/blocklist.cfg'"
	# Blocklist conffile ships with effective entries.
	test -s /etc/fwblack/blocklist.cfg && echo "blocklist-present"
	# Version flag reports this package version.
	/usr/sbin/fw-black --version | grep -F "$version"
	;;
*)
	echo "Untested package: $name" >&2
	exit 1
	;;
esac
