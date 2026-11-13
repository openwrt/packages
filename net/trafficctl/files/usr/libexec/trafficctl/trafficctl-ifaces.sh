#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Per-interface byte counters for the global (bmon-style) overview.
#
# Output: JSON array
#   [{"dev":"eth1","label":"wan","role":"wan","tunnel":false,"primary":true,
#     "defroute":true,"enslaved":false,"up":true,"rx_bytes":N,"tx_bytes":N}]
#
# rx/tx are the kernel's own counters, i.e. relative to the INTERFACE, not to
# the client: rx on the WAN device is download, rx on br-lan is what the LAN
# sent upstream. Rates are not computed here — the frontend diffs two samples
# exactly as it already does for trafficctl-bytes.sh, so this script stays
# stateless and one sample cheap.
#
# Memory / fork discipline (128–512 MB routers; the dashboard polls this on
# its Poll interval, as often as every 2 s):
#   * the hot path is ONE read of /proc/net/dev and ONE awk — nothing else
#   * the role map is the expensive part (tctl_lan_subnets forks ubus and
#     jsonfilter per configured network, and merely sourcing trafficctl-fw.sh
#     runs `nft list tables`), so it is computed on a cold path and memoized
#     in tmpfs with a TTL, the same idiom the rdns and netify caches use.
#     trafficctl-fw.sh is therefore sourced ONLY inside build_cache()
#   * even the cold path classifies every interface in a SINGLE awk rather
#     than forking one per device out of a `while read` loop
#   * the cache is a few dozen bytes per interface and lives in /tmp, so
#     polling never touches flash
#
# Usage: trafficctl-ifaces.sh

CACHE="${TCTL_IFROLE_CACHE:-/tmp/trafficctl_ifroles}"
PROC_NET_DEV="${TCTL_PROC_NET_DEV:-/proc/net/dev}"
SYSFS="${TCTL_SYSFS_NET:-/sys/class/net}"
# 60 s: a WAN failover or a tunnel changing role shows up within a minute,
# which is 30 polls' worth of work saved at the default 2 s interval. A device
# that is entirely NEW does not wait for the TTL — see the #MISS retry below.
TTL="${TCTL_IFROLE_TTL:-60}"

build_cache() {
    # COLD PATH ONLY. Never call this from the per-poll path.
    . /usr/libexec/trafficctl/trafficctl-fw.sh

    # LAN = the L3 devices trafficctl already monitors (br-lan, br-guest,
    # eth0.20 …). Deliberately the L3 devices and not their bridge ports:
    # listing both would show the same bytes twice. Naming alone does not
    # achieve that — lan2/lan3/phy0-ap0 are ports of br-lan and look like
    # ordinary devices — so enslavement is detected from sysfs below.
    _lan=$(tctl_get_lan_devices 2>/dev/null | tr '\n' ' ')

    # Devices carrying a default route, v4 or v6. This is NOT the same as
    # "the WAN" — see the role rules in the awk below.
    _defroute=$( { ip -4 route show default; ip -6 route show default; } 2>/dev/null \
        | awk '{ for (i = 1; i < NF; i++) if ($i == "dev") print $(i + 1) }' \
        | sort -u | tr '\n' ' ')

    # Friendly labels: the uci/ubus interface name for each L3 device, so the
    # overview says "wan"/"lan"/"vpn_fi" instead of "eth1"/"br-lan"/"awg0".
    # One ubus call, parsed line-wise — "interface" always precedes
    # "l3_device" inside an entry, and the outer '"interface": [' line has no
    # string value so it cannot seed a stale name.
    #
    # Flattened to ONE space-separated "dev name dev name …" list, not kept as
    # lines: a multi-line value passed through `awk -v` is rejected outright by
    # some awks ("newline in string"), so the pairs are read positionally
    # below. Neither a device name nor a uci interface name can contain a
    # space, so the pairing is unambiguous.
    _labels=$(ubus call network.interface dump 2>/dev/null | awk '
    function val(line,   seg) {
        if (!match(line, /:[ \t]*"/)) return ""
        seg = substr(line, RSTART + RLENGTH)
        if (!match(seg, /"/)) return ""
        return substr(seg, 1, RSTART - 1)
    }
    /"interface"[ \t]*:/ { name = val($0); next }
    /"l3_device"[ \t]*:/ {
        dev = val($0)
        if (dev != "" && name != "") { print dev " " name; name = "" }
    }' | tr '\n' ' ')

    # Every device present in /proc/net/dev gets a line, even the ones with no
    # recognisable role. That is what makes the #MISS retry below terminate:
    # after a rebuild, a lookup can only miss if an interface appeared in the
    # meantime.
    _tmp="$CACHE.$$"
    {
        echo "# $(date +%s)"
        awk -v defroute="$_defroute" -v lan="$_lan" -v labels="$_labels" -v sysfs="$SYSFS" '
# Device-name patterns for tunnels. This is a LABEL as much as a role: it tells
# the UI how to group and badge the interface. ppp*/pppoe* is deliberately
# ABSENT — pppoe-wan is the standard OpenWrt DSL uplink, not a VPN, and badging
# it as one would be wrong on every PPPoE line.
function is_tun(d) {
    return (d ~ /^(wg|awg|tun|tap|gre|sit|vti|ipsec|ip6tnl|xfrm|zt|nordlynx|tailscale|l2tp|pptp)/)
}
# Which of several uci interfaces sharing one l3_device gives the device its
# name. A dual-stack uplink is three interfaces on one device — "wan", "wan6"
# and "wan6_alias0" — and whichever the ubus dump happened to emit last used to
# win, so a router could title its uplink row "wan6_alias0". Lower score wins;
# ties break on length then lexically, so the result never depends on dump
# order.
function lbl_score(n_,   s) {
    s = 0
    if (n_ ~ /_alias/) s += 4
    if (n_ ~ /6$/ || n_ ~ /6_/) s += 2
    return s
}
BEGIN {
    n = split(defroute, a, " ")
    for (i = 1; i <= n; i++) if (a[i] != "") isdef[a[i]] = 1
    n = split(lan, a, " ")
    for (i = 1; i <= n; i++) if (a[i] != "") islan[a[i]] = 1
    # "dev name dev name …" — read two at a time, see the flattening above.
    n = split(labels, a, " ")
    for (i = 1; i + 1 <= n; i += 2) {
        _d = a[i]; _n = a[i + 1]
        if (_d == "" || _n == "") continue
        # The uci network named wan/wan6 (or an alias on one) marks the uplink
        # even when something else currently owns the default route — and it is
        # taken from ANY of the device names, not just the one that wins below.
        if (_n == "wan" || _n == "wan6" || _n ~ /^wan6?_/) isuciwan[_d] = 1
        s = lbl_score(_n)
        if (lblset[_d] != 1) { lbl[_d] = _n; lblscore[_d] = s; lblset[_d] = 1; continue }
        if (s < lblscore[_d] || (s == lblscore[_d] && \
            (length(_n) < length(lbl[_d]) || \
             (length(_n) == length(lbl[_d]) && _n < lbl[_d])))) {
            lbl[_d] = _n; lblscore[_d] = s
        }
    }
}
NR > 2 {
    if (index($0, ":") == 0) next
    d = substr($0, 1, index($0, ":") - 1)
    gsub(/[ \t]/, "", d)
    if (d == "" || d == "lo") next
    devs[++nd] = d
    tun[d] = is_tun(d) ? 1 : 0

    # Enslaved = a port of a bridge (lan2, lan3, phy0-ap0 …), which reports the
    # very same bytes its bridge already reports. A sysfs lookup, because the
    # names give nothing away: "lan3" and "br-lan" look equally like top-level
    # devices. Reading master/ifindex rather than testing the symlink keeps it
    # to the one primitive awk has.
    ens[d] = 0
    if ((getline _x < (sysfs "/" d "/master/ifindex")) > 0) ens[d] = 1
    close(sysfs "/" d "/master/ifindex")

    # Role rules, in priority order.
    #
    # Every test below compares a VALUE, never `d in arr`. Referencing arr[d] in
    # an awk condition CREATES the element, so a later membership test would be
    # true for every device that merely reached the condition — which is exactly
    # how "defroute" came out true for every non-LAN, non-tunnel interface.
    #
    # Tunnels are checked before default routes because a full-tunnel router
    # (WireGuard/AmneziaWG, common on these boxes) has its default route via
    # awg0 while the physical uplink still carries every byte ENCAPSULATED.
    # Classifying awg0 as the WAN would both hide the real uplink under "other"
    # and double-count the same traffic, so a tunnel stays a tunnel and the
    # uplink stays the WAN; "defroute" records who actually holds the route.
    if (ens[d] == 1)          role[d] = "other"
    else if (islan[d] == 1)   role[d] = "lan"
    else if (tun[d] == 1)     role[d] = "vpn"
    else if (isuciwan[d] == 1 || isdef[d] == 1) { role[d] = "wan"; nwan++ }
    else                      role[d] = "other"
}
END {
    # Fallback: a router whose ONLY default route is a tunnel and which has no
    # uci "wan" would otherwise have no WAN row at all, leaving the overview
    # headline blank. Promote the route holder in that case only.
    if (!nwan) {
        for (i = 1; i <= nd; i++) {
            if (isdef[devs[i]] == 1 && ens[devs[i]] != 1) { role[devs[i]] = "wan"; nwan++ }
        }
    }
    # Exactly one interface is flagged primary — the headline graph shows that
    # one rather than a sum, because summing several WANs double-counts a
    # failover pair and mixes two unrelated links (see #28).
    for (i = 1; i <= nd && !prim; i++) {
        d = devs[i]
        if (role[d] == "wan" && isuciwan[d] == 1) prim = d
    }
    for (i = 1; i <= nd && !prim; i++) {
        d = devs[i]
        if (role[d] == "wan" && isdef[d] == 1) prim = d
    }
    for (i = 1; i <= nd && !prim; i++) {
        if (role[devs[i]] == "wan") prim = devs[i]
    }
    for (i = 1; i <= nd; i++) {
        d = devs[i]
        dfl = 0; if (isdef[d] == 1) dfl = 1
        pr  = 0; if (d == prim)     pr  = 1
        en  = 0; if (ens[d] == 1)   en  = 1
        lb = "-"; if (lblset[d] == 1) lb = lbl[d]
        printf "%s %s %d %d %d %d %s\n", d, role[d], tun[d], pr, dfl, en, lb
    }
}' "$PROC_NET_DEV" 2>/dev/null
    } > "$_tmp" 2>/dev/null
    # Rename into place so a concurrent poll never reads a half-written map.
    [ -s "$_tmp" ] && mv "$_tmp" "$CACHE" 2>/dev/null
    rm -f "$_tmp" 2>/dev/null
}

emit() {
    awk -v cache="$CACHE" -v sysfs="$SYSFS" '
BEGIN {
    while ((getline l < cache) > 0) {
        if (substr(l, 1, 1) == "#") continue
        if (split(l, f, " ") < 7) continue
        # known[] is a separate explicit flag rather than `f[1] in role`,
        # because the fields read below auto-vivify their own arrays and a
        # membership test on any of them would then be true for every device.
        known[f[1]] = 1
        role[f[1]] = f[2]; tun[f[1]] = f[3] + 0; prim[f[1]] = f[4] + 0
        dfr[f[1]] = f[5] + 0; ens[f[1]] = f[6] + 0; lbl[f[1]] = f[7]
    }
    close(cache)
    printf "["
}
NR > 2 {
    # Split on the COLON, not on whitespace. The kernel pads the name field to
    # a fixed width, so a long interface name or a counter wide enough to fill
    # it leaves no space before rx_bytes ("enp0s31f6:12345678") and every
    # positional field after it shifts by one.
    if (index($0, ":") == 0) next
    dev = substr($0, 1, index($0, ":") - 1)
    gsub(/[ \t]/, "", dev)
    if (dev == "" || dev == "lo") next
    rest = substr($0, index($0, ":") + 1)
    sub(/^[ \t]+/, "", rest)
    if (split(rest, c, /[ \t]+/) < 16) next

    # Written as if/else rather than a ternary on purpose: an awk line starting
    # "ident = (" trips the array-assignment bashism scanner in
    # tests/test_openwrt_compat.sh, which cannot tell shell from an embedded
    # awk program.
    r = "other"
    if (known[dev] == 1) { r = role[dev] } else { miss = 1 }

    # operstate is a sysfs read, not a fork, so it is cheap enough for the
    # poll path — and a tunnel that is down while still holding counters is
    # exactly what the overview needs to show.
    state = ""
    if ((getline state < (sysfs "/" dev "/operstate")) <= 0) state = ""
    close(sysfs "/" dev "/operstate")
    up = "false"
    if (state == "up" || state == "unknown") { up = "true" }

    name = dev; gsub(/["\\]/, "", name)
    label = name
    if (lbl[dev] != "" && lbl[dev] != "-") { label = lbl[dev] }
    gsub(/["\\]/, "", label)

    if (n++ > 0) printf ","
    # %.0f, never %d: these are 64-bit kernel counters and busybox awk formats
    # %d through a 32-bit int (see tests/test_byte_overflow.sh). /proc/net/dev
    # is the worst offender in the tree — an uptime of a few days puts any
    # active interface past 2 GiB.
    printf "{\"dev\":\"%s\",\"label\":\"%s\",\"role\":\"%s\",\"tunnel\":%s,\"primary\":%s,\"defroute\":%s,\"enslaved\":%s,\"up\":%s,\"rx_bytes\":%.0f,\"tx_bytes\":%.0f}", \
        name, label, r, \
        (tun[dev] ? "true" : "false"), (prim[dev] ? "true" : "false"), \
        (dfr[dev] ? "true" : "false"), (ens[dev] ? "true" : "false"), \
        up, c[1] + 0, c[9] + 0
}
END {
    printf "]"
    if (miss) printf "#MISS"
}' "$PROC_NET_DEV" 2>/dev/null
}

# Guard before anything else. awk still runs its BEGIN block when the input
# file is missing but never reaches END, so emit() would print a bare "[" —
# invalid JSON that the frontend surfaces as a dead panel rather than an empty
# one. Nothing below is worth doing without counters anyway.
[ -r "$PROC_NET_DEV" ] || { echo '[]'; exit 0; }

NOW=$(date +%s)
TS=0
if [ -f "$CACHE" ]; then
    # Builtin read, no fork: the header line is "# <epoch>".
    read -r _hash TS < "$CACHE" 2>/dev/null
    case "$TS" in ''|*[!0-9]*) TS=0 ;; esac
fi
[ $((NOW - TS)) -ge "$TTL" ] && build_cache

OUT=$(emit)
case "$OUT" in
*'#MISS')
    # An interface the cached map has never seen showed up — a tunnel came up,
    # a USB modem was plugged in, a guest bridge was created. Rebuild once and
    # re-emit so it is classified immediately instead of sitting in "other"
    # until the TTL expires. build_cache() enumerates /proc/net/dev itself, so
    # the retry always resolves and this cannot spin.
    build_cache
    OUT=$(emit)
    ;;
esac

[ -z "$OUT" ] && OUT="[]"
printf '%s\n' "${OUT%\#MISS}"
