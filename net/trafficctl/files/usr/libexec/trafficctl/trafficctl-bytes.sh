#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Per-device byte counters from conntrack (for speed calculation).
# Output: JSON array
#   [{"ip":"…","bytes_in":N,"bytes_out":N,"bytes_tcp":N,"bytes_udp":N,
#     "src":"ct","degraded":false}]
#
# "src" names the counter source. trafficctl-totals.sh accumulates these into
# lifetime totals and the two sources have unrelated magnitudes (conntrack
# reports only live flows, the nft maps count since the table was built), so it
# has to be able to tell a source switch from a burst of traffic.
#
# "degraded" says whether the numbers can be believed AT ALL — see below. It is
# separate from "src" on purpose: src is about magnitude (and drives the
# rebaseline), degraded is about trust, and conflating them would make a change
# in trust look like a change of counter and throw away a delta for nothing.
#
# bytes_tcp / bytes_udp carry both directions summed, and exist only on the
# conntrack path — nft counter maps are keyed by address alone and cannot split
# by protocol, so trafficctl-bytes-nft.sh reports -1 there. -1 rather than 0:
# "unknown" and "no TCP traffic" must not render as the same number.

. /usr/libexec/trafficctl/trafficctl-fw.sh

# Any offload mode (software, hardware, hardware-counter) bypasses conntrack counters
# for fast-path packets. Use nftables counters at forward priority -200 (before the
# flowtable at -150) which capture every packet regardless of offload state.
# Only pure "none" mode has accurate conntrack counters.
# Modes whose counters ARE synced back to conntrack ("*-counter") keep the
# conntrack path accurate; only the uncountered ones need the nft fallback.
# TCTL_FORCE_CONNTRACK is set by that fallback when the kernel lacks dynamic
# counter maps, so we don't bounce between the two.
_offload=$(tctl_get_offload_mode)
_uncountered=0
case "$_offload" in
    none|*-counter) ;;
    *)
        _uncountered=1
        [ "$TCTL_FW" = "nft" ] && [ -z "$TCTL_FORCE_CONNTRACK" ] && \
            exec /usr/libexec/trafficctl/trafficctl-bytes-nft.sh
        ;;
esac

# Reaching here with uncountered offload means the nft fallback was unavailable
# and we are about to read counters the forwarding path does not update.
#
# Two ways in, and the second is easy to miss:
#   * TCTL_FORCE_CONNTRACK — bytes-nft.sh bounced back because the kernel has
#     no dynamic counter map support. Observed on real hardware.
#   * fw3/iptables — there is no nft fallback to reach in the first place.
#
# The numbers that follow are not merely imprecise, they are FROZEN for every
# offloaded flow: they stop moving while traffic continues. Left unflagged, a
# lifetime total accumulated from them looks authoritative and simply stalls,
# which reads as stale statistics rather than as a broken counter — the same
# shape as the 2 GiB %d freeze (#56), and harder to notice than the tiny live
# values that prompted #26, because the number is plausible.
_degraded=false
[ "$_uncountered" = "1" ] && _degraded=true

# All monitored subnets (connected LANs + routed downstream subnets +
# trafficctl.main.extra_subnets), as awk membership spec.
MATCH_SPEC=$(tctl_monitored_subnets | awk '{printf "%s%s:%s:%s",(NR>1?" ":""),$2,$3,$4}')
[ -z "$MATCH_SPEC" ] && { echo '[]'; exit 0; }

# Router-owned IPv4 addresses, excluded from the NAT fallback below.
LOCAL_IPS=$(ip -4 addr show 2>/dev/null | awk '/inet /{split($2,a,"/");print a[1]}' | tr '\n' ' ')

cat /proc/net/nf_conntrack 2>/dev/null | awk -v spec="$MATCH_SPEC" -v localips="$LOCAL_IPS" -v degraded="$_degraded" '
function ip2int(ip,   a) {
    split(ip, a, ".")
    return a[1]*16777216 + a[2]*65536 + a[3]*256 + a[4]
}
function is_lan(ip,   si, k) {
    si = ip2int(ip)
    for (k = 1; k <= ns; k++)
        if (si - (si % blk[k]) == base[k]) return 1
    return 0
}
BEGIN {
    printf "["
    ns = split(spec, parts, " ")
    for (k = 1; k <= ns; k++) {
        split(parts[k], kv, ":")
        base[k] = kv[1] + 0; blk[k] = kv[2] + 0
    }
    nl = split(localips, lp, " ")
    for (k = 1; k <= nl; k++) if (lp[k] != "") islocal[lp[k]] = 1
}
{
    src=""; osrc=""; rdst=""; nsrc=0; bytes_orig=0; bytes_reply=0; bc=0; proto=""
    for (i=1; i<=NF; i++) {
        # The L4 protocol is a bare word in the header fields ("ipv4 2 tcp 6 …"),
        # before any key=value pair, so it is matched by value like summary.sh.
        if ($i == "tcp") proto="tcp"
        else if ($i == "udp") proto="udp"
        if ($i ~ /^src=/) {
            v = substr($i, 5)
            nsrc++
            if (nsrc == 1) osrc = v
            if (src == "" && is_lan(v)) src = v
        }
        if (nsrc == 2 && rdst == "" && $i ~ /^dst=/) rdst = substr($i, 5)
        if ($i ~ /^bytes=/) {
            v = substr($i, 7) + 0
            bc++
            if (bc == 1) bytes_orig = v
            else if (bc == 2) bytes_reply = v
        }
    }
    # NAT fallback: flow was SNAT/masqueraded here (reply dst != original
    # src), so the original src is a forwarded client even though it is not
    # in any monitored subnet (e.g. behind a downstream router).
    if (src == "" && osrc != "" && rdst != "" && rdst != osrc && \
        osrc ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && !(osrc in islocal))
        src = osrc
    if (src != "") {
        key = src
        in_total[key] += bytes_reply
        out_total[key] += bytes_orig
        # Both directions, unlike the per-direction sums above: the protocol
        # split answers how much of the traffic for this device was TCP, which
        # is not a question about direction.
        if (proto == "tcp") tcp_total[key] += bytes_orig + bytes_reply
        else if (proto == "udp") udp_total[key] += bytes_orig + bytes_reply
    }
}
END {
    n = 0
    for (ip in in_total) {
        if (n > 0) printf ","
        printf "{\"ip\":\"%s\",\"bytes_in\":%.0f,\"bytes_out\":%.0f,\"bytes_tcp\":%.0f,\"bytes_udp\":%.0f,\"src\":\"ct\",\"degraded\":%s}", \
            ip, in_total[ip], out_total[ip], tcp_total[ip]+0, udp_total[ip]+0, degraded
        n++
    }
    printf "]\n"
}
'
