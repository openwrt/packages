#!/bin/sh
# pre-test.sh - ensure nftables tooling for the CI runtime test.
# (Our fwblack DEPENDS already pulls it via firewall4; this covers
# minimal CI images. Works with both apk and opkg based systems.)
if ! command -v nft >/dev/null 2>&1; then
	if command -v apk >/dev/null 2>&1; then
		apk add nftables
	elif command -v opkg >/dev/null 2>&1; then
		opkg update && opkg install nftables
	fi
fi
