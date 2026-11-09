#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Per-device byte counters using nftables maps.
# Works with software flow offload (hook priority -200, before flowtable at -150).
# Output: JSON array
#   [{"ip":"…","bytes_in":N,"bytes_out":N,"bytes_tcp":-1,"bytes_udp":-1,
#     "src":"nft","degraded":false}]
#
# "degraded" is always false here, and that is the entire point of this script:
# these counters sit ahead of the flowtable, so they keep moving under offload
# where conntrack freezes. If this path is unavailable, trafficctl-bytes.sh
# reports degraded:true instead of quietly handing back frozen numbers.
#
# The counters here are cumulative since the table was created, unlike the
# conntrack sums trafficctl-bytes.sh returns, which cover live flows only.
# "src" lets trafficctl-totals.sh notice the swap and rebaseline instead of
# accumulating the whole map as a single enormous delta.
#
# The protocol split is -1, i.e. "unknown", not 0: a `type ipv4_addr : counter`
# map is keyed by address alone, so there is nothing here to split TCP from UDP
# with. Reporting 0 would render as a device that sent no TCP at all.

. /usr/libexec/trafficctl/trafficctl-fw.sh

command -v nft >/dev/null 2>&1 || { echo '[]'; exit 0; }

# Create table/maps/chain/rules if not already present (idempotent).
#
# The gate matches the CURRENT rule orientation, not merely "some rule exists".
# Until 1.13.x the maps were keyed the other way round (bytes_in by saddr), so
# a router upgrading from that version already has the chain: a looser check
# would leave the old, inverted rules in place forever and the fix would only
# ever reach fresh installs.
#
# Direction convention, matching trafficctl-bytes.sh and docs/API.md:
#   bytes_in  = traffic toward the device  (download) -> keyed by ip daddr
#   bytes_out = traffic from the device    (upload)   -> keyed by ip saddr
if ! nft list chain inet trafficctl_mon mon_forward 2>/dev/null | grep -q "bytes_in.*daddr"; then
    # Drop the old table wholesale rather than appending to it — leaving the
    # previous pair of rules in place would double-count every packet. This
    # resets the counters once, on upgrade; they are only used for speed
    # deltas, so a single discarded sample is the whole cost.
    nft delete table inet trafficctl_mon 2>/dev/null

    nft add table inet trafficctl_mon 2>/dev/null
    nft add map inet trafficctl_mon bytes_in \
        '{ type ipv4_addr : counter; flags dynamic; }' 2>/dev/null
    nft add map inet trafficctl_mon bytes_out \
        '{ type ipv4_addr : counter; flags dynamic; }' 2>/dev/null
    nft add chain inet trafficctl_mon mon_forward \
        '{ type filter hook forward priority -200; policy accept; }' 2>/dev/null
    nft add rule inet trafficctl_mon mon_forward \
        'update @bytes_in { ip daddr counter }' 2>/dev/null
    nft add rule inet trafficctl_mon mon_forward \
        'update @bytes_out { ip saddr counter }' 2>/dev/null
fi

# Dynamic counter maps are unsupported on some kernels ("Not supported").
# Without this check the maps silently never exist, every rule fails, and the
# script returns [] forever — per-device speed just stops working.
if ! nft list map inet trafficctl_mon bytes_in >/dev/null 2>&1; then
    TCTL_FORCE_CONNTRACK=1 exec /usr/libexec/trafficctl/trafficctl-bytes.sh
fi

IN=$(nft list map inet trafficctl_mon bytes_in 2>/dev/null)
OUT=$(nft list map inet trafficctl_mon bytes_out 2>/dev/null)

# Parse: lines look like "192.168.0.100 : counter packets 584 bytes 892341[,]"
printf '%s\n__SEP__\n%s\n' "$IN" "$OUT" | awk '
/^__SEP__$/ { phase = 1; next }
/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ : counter/ {
    ip = ""; val = 0
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) ip = $i
        if ($i == "bytes") val = $(i+1) + 0
    }
    if (ip != "") {
        if (phase == 0) in_b[ip]  += val
        else            out_b[ip] += val
    }
}
END {
    printf "["
    n = 0
    for (ip in in_b) {
        if (n > 0) printf ","
        printf "{\"ip\":\"%s\",\"bytes_in\":%.0f,\"bytes_out\":%.0f,\"bytes_tcp\":-1,\"bytes_udp\":-1,\"src\":\"nft\",\"degraded\":false}", \
            ip, in_b[ip], out_b[ip]+0
        n++
    }
    for (ip in out_b) {
        if (!(ip in in_b)) {
            if (n > 0) printf ","
            printf "{\"ip\":\"%s\",\"bytes_in\":0,\"bytes_out\":%.0f,\"bytes_tcp\":-1,\"bytes_udp\":-1,\"src\":\"nft\",\"degraded\":false}", \
                ip, out_b[ip]
            n++
        }
    }
    printf "]\n"
}
'
