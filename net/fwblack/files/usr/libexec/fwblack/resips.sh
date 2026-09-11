#!/bin/sh
# resips.sh - reverse-resolve candidate IPs and append blocklist matches.
#
# Reads IPs from $CONNTRACK_FILE (default /tmp/ips), nslookup each public IP,
# and appends it to $BLKIPS (default /tmp/blacklist.ips) when the PTR hostname
# contains any entry from $BLACKLIST (default /etc/fwblack/blocklist.cfg,
# legacy fallback /etc/fw.black/blocklist.cfg).
# Matching is literal substring (case ... *...*), not regex, so dots in
# domains are safe. Env vars may override all three paths (set by procd from
# UCI — see /etc/config/fwblack + /etc/init.d/fwblack).
#
# Performance: skips already-blocked IPs (no DNS), caches resolutions in
# $CACHE_FILE with TTL (positive $CACHE_TTL_POS, negative $CACHE_TTL_NEG),
# and loads the blocklist once instead of re-reading it per IP.
# Installed to /usr/libexec/fwblack/resips.sh by the fwblack OpenWrt package.
set -eu

# Keep in sync with PKG_VERSION (Makefile) and VERSION (repo root).
VERSION='1.0.1'

case "${1:-}" in
	-V|--version)
		echo "fw-black-resips $VERSION"
		exit 0
		;;
	-h|--help)
		echo "Usage: resips.sh [OPTION]"
		echo "Reverse-resolve candidate IPs and append blocklist matches to \$BLKIPS."
		exit 0
		;;
esac

CONNTRACK_FILE="${CONNTRACK_FILE:-/tmp/ips}"
if [ -z "${BLACKLIST:-}" ]; then
	if [ -f /etc/fwblack/blocklist.cfg ]; then
		BLACKLIST=/etc/fwblack/blocklist.cfg
	elif [ -f /etc/fw.black/blocklist.cfg ]; then
		BLACKLIST=/etc/fw.black/blocklist.cfg
	else
		BLACKLIST=/etc/fwblack/blocklist.cfg
	fi
fi
BLKIPS="${BLKIPS:-/tmp/blacklist.ips}"
CACHE_FILE="${CACHE_FILE:-/tmp/fwblack.dnscache}"
CACHE_TTL_POS="${CACHE_TTL_POS:-86400}"
CACHE_TTL_NEG="${CACHE_TTL_NEG:-3600}"
CACHE_MAX="${CACHE_MAX:-5000}"
case "$CACHE_TTL_POS" in
	"" | *[!0-9]*) CACHE_TTL_POS=86400 ;;
esac
case "$CACHE_TTL_NEG" in
	"" | *[!0-9]*) CACHE_TTL_NEG=3600 ;;
esac
case "$CACHE_MAX" in
	"" | *[!0-9]*) CACHE_MAX=5000 ;;
esac

if [ ! -r "$CONNTRACK_FILE" ]; then
	echo "resips.sh: $CONNTRACK_FILE does not exist or is not readable." >&2
	exit 0
fi
if [ ! -r "$BLACKLIST" ]; then
	echo "resips.sh: $BLACKLIST not readable, nothing to match." >&2
	exit 0
fi
: >> "$BLKIPS"
: >> "$CACHE_FILE"

now="$(date +%s 2>/dev/null || echo 0)"
case "$now" in
	"" | *[!0-9]*) now=0 ;;
esac

# Drop expired entries and cap size (cheapest pruning that stays correct).
if [ -s "$CACHE_FILE" ] && [ "$now" -gt 0 ]; then
	pruned="$CACHE_FILE.pruned"
	awk -F'|' -v now="$now" '$1 > now' "$CACHE_FILE" 2>/dev/null | tail -n "$CACHE_MAX" > "$pruned" 2>/dev/null || true
	if [ -f "$pruned" ]; then
		mv "$pruned" "$CACHE_FILE"
	fi
fi

is_local() {
	case "$1" in
		"" | \#*) return 0 ;;
	esac
	case "$1" in
		127.* | 10.* | 192.168.* | 0.* | 169.254.* | 224.* | 255.*) return 0 ;;
		172.1[6-9].* | 172.2[0-9].* | 172.3[0-1].*) return 0 ;;
		"::1" | "::" | fe80:* | FE80:* | fc*:* | FC*:* | fd*:* | FD*:* | ff*:* | FF*:*) return 0 ;;
	esac
	return 1
}

lookup_names() {
	ip="$1"
	if command -v timeout >/dev/null 2>&1; then
		timeout 5 nslookup "$ip" 2>/dev/null || return 0
	else
		nslookup "$ip" 2>/dev/null || return 0
	fi
}

# cache_get IP: prints cached hostnames (maybe empty) and returns 0 on fresh
# hit, 1 on miss/expired. Cache line format: expiry|ip|hostnames...
cache_get() {
	entry="$(grep -m1 -F "|$1|" "$CACHE_FILE" 2>/dev/null || true)"
	[ -n "$entry" ] || return 1
	exp="${entry%%|*}"
	case "$exp" in
		"" | *[!0-9]*) return 1 ;;
	esac
	if [ "$now" -gt 0 ] && [ "$exp" -le "$now" ]; then
		return 1
	fi
	rest="${entry#*|}"
	printf '%s' "${rest#*|}"
	return 0
}

cache_put() {
	# $1=ip $2=hostnames $3=ttl
	exp=0
	if [ "$now" -gt 0 ]; then
		exp=$((now + $3))
	else
		exp=9999999999
	fi
	printf '%s|%s|%s\n' "$exp" "$1" "$2" >> "$CACHE_FILE"
}

# Load + normalize the blocklist once (lowercase, strip CR/space/tab,
# permit full-line and trailing "# comment").
blocklist_norm=""
while IFS= read -r black || [ -n "$black" ]; do
	black="${black%%#*}"
	black="$(printf '%s' "$black" | tr -d '\r \t' | tr 'A-Z' 'a-z')"
	[ -n "$black" ] || continue
	blocklist_norm="${blocklist_norm}${black}
"
done < "$BLACKLIST"
[ -n "$blocklist_norm" ] || exit 0

while IFS= read -r line || [ -n "$line" ]; do
	line="$(printf '%s' "$line" | tr -d '\r \t')"
	[ -n "$line" ] || continue
	case "$line" in
		\#*) continue ;;
	esac
	if is_local "$line"; then
		continue
	fi
	# Already blocked: no DNS, nothing to do.
	if grep -Fxq "$line" "$BLKIPS" 2>/dev/null; then
		continue
	fi
	if cached="$(cache_get "$line")"; then
		src_hostnames="$cached"
	else
		src_hostnames="$(lookup_names "$line" | awk 'tolower($0) ~ /name[ =:]/ {print $NF}' | sed 's/\.$//' | tr 'A-Z' 'a-z' || true)"
		if [ -n "$src_hostnames" ]; then
			cache_put "$line" "$src_hostnames" "$CACHE_TTL_POS"
		else
			cache_put "$line" "" "$CACHE_TTL_NEG"
			continue
		fi
	fi
	[ -n "$src_hostnames" ] || continue
	while IFS= read -r black || [ -n "$black" ]; do
		[ -n "$black" ] || continue
		matched=0
		while IFS= read -r host || [ -n "$host" ]; do
			[ -n "$host" ] || continue
			case "$host" in
				*"$black"*)
					matched=1
					break
					;;
			esac
		done <<EOF
$src_hostnames
EOF
		if [ "$matched" -eq 1 ]; then
			if ! grep -Fxq "$line" "$BLKIPS" 2>/dev/null; then
				printf '%s\n' "$line" >> "$BLKIPS"
			fi
			break
		fi
	done <<EOF
$blocklist_norm
EOF
done < "$CONNTRACK_FILE"
