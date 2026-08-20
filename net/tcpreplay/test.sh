#!/bin/sh

# shellcheck shell=busybox

# Exercise the suite through the meta-package, which installs every tool.
# Live replay (tcpreplay/tcpbridge/tcpliveplay) needs a real interface and
# cannot run under the QEMU runtime, so drive the file-processing core
# (dissect, rewrite, cache) instead; the version of every binary is asserted
# separately in test-version.sh.
[ "$1" = "tcpreplay-all" ] || exit 0

pcap="/tmp/tcpreplay-$$.pcap"
out="/tmp/tcpreplay-$$-out.pcap"
cache="/tmp/tcpreplay-$$.cache"
trap 'rm -f "$pcap" "$out" "$cache"' EXIT

# A minimal LINKTYPE_ETHERNET capture holding one Ethernet/IPv4/UDP frame
# (ports 4096->8080 so tcpprep does not attempt DNS parsing, plus payload so
# the frame clears tcpprep's minimum length), written byte-for-byte with
# printf octal escapes because base64 is not in the runtime busybox:
# 24-byte pcap header + 16-byte record + 60-byte frame.
printf '\324\303\262\241\002\000\004\000\000\000\000\000\000\000\000\000\377\377\000\000\001\000\000\000\000\000\000\000\000\000\000\000\074\000\000\000\074\000\000\000\377\377\377\377\377\377\000\021\042\063\104\125\010\000\105\000\000\056\000\001\000\000\100\021\000\000\012\000\000\001\012\000\000\002\020\000\037\220\000\032\000\000\164\143\160\162\145\160\154\141\171\055\164\145\163\164\000\000\000\000' >"$pcap"

# tcpcapinfo: the pcap dissector must read the header of the capture we wrote.
tcpcapinfo "$pcap" 2>&1 | grep -q "snaplen" || {
	echo "tcpcapinfo failed to dissect the capture"
	exit 1
}

# tcprewrite: remap the destination IP and fix checksums; a successful edit
# writes a non-empty output capture.
tcprewrite --infile="$pcap" --outfile="$out" \
	--dstipmap=0.0.0.0/0:192.168.9.0/24 --fixcsum || {
	echo "tcprewrite failed to rewrite the capture"
	exit 1
}
[ -s "$out" ] || {
	echo "tcprewrite produced no output capture"
	exit 1
}

# tcpprep: build a replay cache by auto-splitting the endpoints; the cache
# file must be created.
tcpprep --auto=bridge --pcap="$pcap" --cachefile="$cache" || {
	echo "tcpprep failed to build a cache file"
	exit 1
}
[ -s "$cache" ] || {
	echo "tcpprep produced no cache file"
	exit 1
}

echo "tcpreplay suite: functional test passed"
