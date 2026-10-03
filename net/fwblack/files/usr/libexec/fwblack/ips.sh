#!/bin/sh
# ips.sh - print unique IPs seen in the conntrack table (IPv4 + IPv6).
# Portable to BusyBox ash/awk/grep; no gawk-only match(RSTART) usage.
# Installed to /usr/libexec/fwblack/ips.sh by the fwblack OpenWrt package.
set -eu

# Keep in sync with PKG_VERSION (Makefile) and VERSION (repo root).
VERSION='1.0.1'

case "${1:-}" in
	-V|--version)
		echo "fw-black-ips $VERSION"
		exit 0
		;;
	-h|--help)
		echo "Usage: ips.sh [OPTION]"
		echo "Print unique IPs seen in the conntrack table (IPv4 + IPv6)."
		exit 0
		;;
esac

CONNTRACK_FILE="${CONNTRACK_FILE:-/proc/net/nf_conntrack}"
if [ ! -r "$CONNTRACK_FILE" ]; then
	if [ -r /proc/net/ip_conntrack ]; then
		CONNTRACK_FILE=/proc/net/ip_conntrack
	else
		echo "ips.sh: $CONNTRACK_FILE not readable" >&2
		exit 1
	fi
fi

# BusyBox grep supports -oE; fall back to awk token scan if it does not.
# Single pass over the conntrack file (was two greps) to halve disk I/O.
if printf 'test\n' | grep -oE 'test' >/dev/null 2>&1; then
	{ grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f:.]+' "$CONNTRACK_FILE" 2>/dev/null || true; } | awk '
		function valid_v4(ip,   n, o) {
			n = split(ip, o, ".")
			if (n != 4) return 0
			for (i = 1; i <= 4; i++) {
				if (o[i] !~ /^[0-9]+$/) return 0
				if (o[i] < 0 || o[i] > 255) return 0
			}
			return 1
		}
		{
			# Strip trailing colons/dots picked up with ports (e.g. "[::1]:443").
			sub(/[:.]+$/, "", $0)
			sub(/^\[+/, "", $0)
			if ($0 == "") next
			if ($0 ~ /:/) {
				if ($0 ~ /^[0-9A-Fa-f:.]+$/ && !seen[$0]++) print $0
			} else if (valid_v4($0)) {
				if (!seen[$0]++) print $0
			}
		}'
else
	awk '
		function valid_v4(ip,   n, o) {
			n = split(ip, o, ".")
			if (n != 4) return 0
			for (i = 1; i <= 4; i++) {
				if (o[i] !~ /^[0-9]+$/) return 0
				if (o[i] < 0 || o[i] > 255) return 0
			}
			return 1
		}
		{
			for (i = 1; i <= NF; i++) {
				tok = $i
				gsub(/^\[+|\]+$/, "", tok)
				sub(/^.*=/, "", tok)
				gsub(/^[^0-9A-Fa-f:.]+|[^0-9A-Fa-f:.]+$/, "", tok)
				if (tok ~ /^([0-9]+\.){3}[0-9]+$/ && valid_v4(tok)) {
					if (!seen[tok]++) print tok
				} else if (tok ~ /:/ && tok ~ /^[0-9A-Fa-f:.]+$/) {
					if (!seen[tok]++) print tok
				}
			}
		}' "$CONNTRACK_FILE"
fi
