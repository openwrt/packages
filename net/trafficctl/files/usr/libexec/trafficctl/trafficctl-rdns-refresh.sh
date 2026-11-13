#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Populate the reverse-DNS name cache for the given IPs.
#
# Runs detached from the summary poll: resolving is slow and must never block
# the device table. The summary reads whatever the cache already holds and
# spawns this to fill in the gaps for the next poll.
#
# Names for devices behind a downstream router (MikroTik etc.) are not in this
# router's DHCP leases, so PTR is the only automatic source. trafficctl.main.
# rdns_server takes a space-separated list of resolvers tried in order — point
# it at the downstream router so its lease names get used.
#
# Usage: trafficctl-rdns-refresh.sh <ip> [ip ...]
# Cache: /tmp/trafficctl_rdns_cache — "IP HOST TIMESTAMP", HOST "-" = no record.

. /usr/libexec/trafficctl/trafficctl-fw.sh

CACHE="/tmp/trafficctl_rdns_cache"
LOCK="/tmp/trafficctl_rdns.lock"

# Only one refresher at a time: concurrent runs would fight over the cache file
# and hammer the resolvers with duplicate queries.
mkdir "$LOCK" 2>/dev/null || exit 0
# shellcheck disable=SC2064
trap "rmdir '$LOCK' 2>/dev/null" EXIT INT TERM

SERVERS=$(uci -q get trafficctl.main.rdns_server 2>/dev/null)

resolve_one() {
    local ip="$1" host="" srv

    for srv in $SERVERS; do
        host=$(nslookup "$ip" "$srv" 2>/dev/null | \
            sed -n -e 's/.*name = \([^ ]*\)\.$/\1/p' -e 's/^Name:[ 	]*\(.*\)$/\1/p' | head -1)
        [ -n "$host" ] && break
    done

    # System resolver (dnsmasq knows this router's own leases and any
    # PTR forwarding configured for downstream subnets).
    if [ -z "$host" ] && command -v ubus >/dev/null 2>&1; then
        host=$(ubus call network.rrdns lookup \
            "{\"addrs\":[\"$ip\"],\"timeout\":2000,\"limit\":1}" 2>/dev/null \
            | jsonfilter -e "@[\"$ip\"]" 2>/dev/null)
    fi
    if [ -z "$host" ] && command -v nslookup >/dev/null 2>&1; then
        host=$(nslookup "$ip" 2>/dev/null | \
            sed -n -e 's/.*name = \([^ ]*\)\.$/\1/p' -e 's/^Name:[ 	]*\(.*\)$/\1/p' | head -1)
    fi

    # Reject anything that isn't a plain hostname, and drop the reverse-zone
    # echo some resolvers return instead of NXDOMAIN.
    case "$host" in
        *in-addr.arpa*|*[!a-zA-Z0-9._-]*|"") host="" ;;
    esac
    # Bare hostname only — "phone.lan" is more useful than the full FQDN in a table.
    printf '%s' "${host%%.*}"
}

NOW=$(date +%s)
TMP="${CACHE}.tmp"

for ip in "$@"; do
    tctl_validate_ip "$ip" || continue
    HOST=$(resolve_one "$ip")
    [ -z "$HOST" ] && HOST="-"
    # Rewrite this IP's entry, keeping every other line.
    [ -f "$CACHE" ] || : > "$CACHE"
    awk -v ip="$ip" '$1 != ip' "$CACHE" > "$TMP"
    echo "$ip $HOST $NOW" >> "$TMP"
    mv "$TMP" "$CACHE"
done
