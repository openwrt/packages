#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Every per-device restriction this app holds, whether or not the device is
# online (#128).
#
# Usage: trafficctl-rules.sh [list]
#
# The device table is built from conntrack, so a device with no flows has no
# row — and with it went the only way to see or lift its block, limit or shape.
# A restriction lives in up to two places, and this reads both:
#
#   type       live (kernel / radio)                    persisted
#   block      inet fw4 forward / iptables FORWARD,     rules.json (persist_rules)
#              comment tctl_block_<slug>[_mac]
#   ratelimit  netdev tm_ratelimit / mangle FORWARD     rules.json (persist_rules)
#              (via trafficctl-ratelimit-stats.sh)
#   shape      HTB class on the LAN device              shapes.json (always)
#   wifi       hostapd running ACL                      uci wireless maclist (deny)
#
# Each record says which of the two it was found in, so "saved but not in the
# kernel" (it comes back at the next ifup lan, or never if the hook failed)
# and "in the kernel but not saved" (lost on reboot) are visible rather than
# both reading as "active". Nothing here changes state: the view edits and
# removes through the same rpcd methods the device table uses.
#
# Output: {"fw":"nft|iptables","persist_rules":bool,"wifi_allow_ifaces":N,
#          "rules":[{"type","target","ip","mac","name","online",
#                    "applied","persisted","rate_kbit","rate_kbit_up","mode",
#                    "enforcement"}]}
# "online" and "applied" are null where the answer is unknown (a subnet has no
# single online state; a radio ACL that cannot be read back is not "off").

. /usr/libexec/trafficctl/trafficctl-fw.sh

SCRIPTS="/usr/libexec/trafficctl"
NAMES_FILE="/etc/trafficctl/names"
RDNS_CACHE_FILE="/tmp/trafficctl_rdns_cache"
CONNTRACK_FILE="/proc/net/nf_conntrack"

case "${1:-list}" in
    list) ;;
    *) echo '{"ok":false,"msg":"usage: trafficctl-rules.sh [list]"}'; exit 1 ;;
esac

PERSIST=0
tctl_persist_enabled && PERSIST=1

# ── naming and presence ───────────────────────────────────────────────────
# Same precedence as the device table: alias > DHCP lease > cached PTR.
emit_naming() {
    awk 'NF >= 3 { print "LEASE", tolower($2), $3, $4 }' "$TCTL_LEASES_FILE" 2>/dev/null
    awk 'NF >= 2 { ip = $1; sub(/^[^ ]+ +/, ""); print "ALIAS", ip, $0 }' "$NAMES_FILE" 2>/dev/null
    if [ "$(uci -q get trafficctl.main.resolve_names 2>/dev/null)" != "0" ]; then
        awk 'NF >= 2 && $2 != "-" { print "RDNS", $1, $2 }' "$RDNS_CACHE_FILE" 2>/dev/null
    fi
    ip neigh show 2>/dev/null | awk '
        $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {
            mac = "-"
            for (i = 2; i < NF; i++) if ($i == "lladdr") mac = tolower($(i+1))
            print "NEIGH", $1, mac, $NF
        }'
    # Online = has a flow right now, the same test that puts a device in the
    # device table. Only the original direction's source is taken.
    awk '{
        for (i = 1; i <= NF; i++) if (index($i, "src=") == 1) { print "ON", substr($i, 5); break }
    }' "$CONNTRACK_FILE" 2>/dev/null | sort -u
}

# ── blocks ────────────────────────────────────────────────────────────────
# Found by comment, not by "any drop rule naming the address": only rules this
# app wrote are its to list and to remove. The v6 half carries no address, so
# its comment slug is the way back to one (a slug of an IPv4 address only ever
# replaced dots).
emit_live_blocks() {
    if [ "$TCTL_FW" = "nft" ]; then
        nft list chain inet fw4 forward 2>/dev/null | awk '
        /comment "tctl_block_/ && /drop/ {
            ip = ""; mac = "-"
            for (i = 1; i < NF; i++) {
                if ($i == "saddr" && $(i-1) == "ip") ip = $(i+1)
                if ($i == "saddr" && $(i-1) == "ether") mac = tolower($(i+1))
            }
            if (ip == "" && match($0, /"tctl_block_[0-9_]+_mac"/)) {
                ip = substr($0, RSTART + 12, RLENGTH - 17)
                gsub(/_/, ".", ip)
            }
            sub(/\/32$/, "", ip)
            if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print "LB", ip, mac
        }'
    else
        iptables -S FORWARD 2>/dev/null | awk '
        /tctl_block_/ && /-j DROP/ {
            for (i = 1; i < NF; i++) if ($i == "-s") { ip = $(i+1); sub(/\/32$/, "", ip); print "LB", ip, "-" }
        }'
    fi
}

# ── rate limits ───────────────────────────────────────────────────────────
# Download ceiling and bucket layout come from the stats script, which already
# folds the per-LAN-device copies of a rule into one target; the upload
# ceiling is the "saddr" rule, read the way the device table reads it.
emit_live_limits() {
    local dump stats
    stats=$("$SCRIPTS/trafficctl-ratelimit-stats.sh" 2>/dev/null)
    [ -n "$stats" ] || return 0
    if [ "$TCTL_FW" = "nft" ]; then
        dump=$(nft list table netdev tm_ratelimit 2>/dev/null)
    else
        dump=$(iptables -t mangle -L FORWARD -nv 2>/dev/null | grep 'rl_ratelimit.*_ul')
    fi
    printf '%s\n' "$stats" | sed 's/},{/}\n{/g' | sed -n \
        's/.*"ip":"\([^"]*\)","mode":"\([a-z]*\)","rate_kbit":\([0-9]*\).*/\1 \2 \3/p' |
    while read -r ip mode rate; do
        if [ "$TCTL_FW" = "nft" ]; then
            up=$(printf '%s\n' "$dump" | tctl_rl_rate_kbit "$ip" saddr)
        else
            up=$(printf '%s\n' "$dump" | awk -v ip="$ip" "$TCTL_NFT_RATE_AWK"'
                { for (i = 1; i <= NF; i++) if ($i == ip || $i == ip "/32") {
                      r = tctl_ipt_first_rate(); if (r >= 0) { print r; exit } } }')
        fi
        echo "LR $ip $mode $rate ${up:-0}"
    done
}

# rules.json records only count while persist_rules is on: the restore hook
# skips the file otherwise, so a record left in it restricts nothing.
emit_persisted_rules() {
    [ "$PERSIST" = "1" ] || return 0
    grep -oE '\{[^{}]*\}' "$TCTL_RULES_FILE" 2>/dev/null | awk '
    function field(k,   re) {
        re = "\"" k "\":\"[^\"]*\""
        if (!match($0, re)) return ""
        return substr($0, RSTART + length(k) + 4, RLENGTH - length(k) - 5)
    }
    {
        t = field("type"); ip = field("ip")
        if (ip == "") next
        if (t == "block") print "PB", ip
        else if (t == "ratelimit") {
            p = field("param"); m = field("mode"); u = field("param_up")
            print "PR", ip, (p == "" ? 0 : p), (m == "" ? "-" : m), (u == "" ? 0 : u)
        }
    }'
}

# ── shapes ────────────────────────────────────────────────────────────────
# shapes.json is written on every add and remove, so it is the list of shapes;
# a class with that minor on the LAN device is what makes one live.
emit_shapes() {
    local lan ifb
    lan=$(tctl_get_lan_device)
    ifb=$(tctl_shape_ifb_dev)
    {
        tctl_tc_class_rates "$lan" | awk '{ print "TCDL", $1, $2 }'
        tctl_tc_class_rates "$ifb" | awk '{ print "TCUL", $1, $2 }'
        tctl_shape_classmap | awk '{ print "MAP", $1, $2 }'
        grep -oE '\{"ip":"[^"]+","rate_kbit":[0-9]+[^{}]*\}' "$TCTL_SHAPES_FILE" 2>/dev/null
    } | awk '
    $1 == "TCDL" { dl[$2] = $3; next }
    $1 == "TCUL" { ul[$2] = $3; next }
    $1 == "MAP"  { cls[$2] = $3; next }
    /^\{/ {
        if (!match($0, /"ip":"[^"]+"/)) next
        ip = substr($0, RSTART + 6, RLENGTH - 7)
        r = 0; u = 0
        if (match($0, /"rate_kbit":[0-9]+/)) r = substr($0, RSTART + 12, RLENGTH - 12)
        if (match($0, /"rate_kbit_up":[0-9]+/)) u = substr($0, RSTART + 15, RLENGTH - 15)
        if (r + 0 <= 0) next
        c = cls[ip]
        live = 0; if (c != "" && (c in dl)) live = 1
        print "PS", ip, r, u
        if (live) print "LS", ip, dl[c], ((c in ul) ? ul[c] : 0)
    }'
}

# ── WiFi MAC filter ───────────────────────────────────────────────────────
# Only deny-mode radios can be enumerated: on a whitelist radio a blocked
# device is one that is NOT listed, which names nobody. Those are counted so
# the view can say so instead of implying there is nothing to show.
emit_wifi() {
    local iface mode list mac ifaces state worst rank aif
    WIFI_ALLOW=0
    list=""
    for iface in $(tctl_get_wifi_interfaces); do
        mode=$(tctl_get_wifi_filter_mode "$iface")
        if [ "$mode" = "allow" ]; then
            WIFI_ALLOW=$((WIFI_ALLOW + 1))
            continue
        fi
        [ "$(uci -q get "wireless.${iface}.macfilter" 2>/dev/null)" = "deny" ] || continue
        list="$list $(uci -q get "wireless.${iface}.maclist" 2>/dev/null)"
    done
    echo "WALLOW $WIFI_ALLOW"
    # shellcheck disable=SC2086 # one MAC per word, split on purpose
    list=$(printf '%s\n' $list | tr 'A-F' 'a-f' | grep -E '^([0-9a-f]{2}:){5}[0-9a-f]{2}$' | sort -u)
    [ -n "$list" ] || return 0

    # The running ACL, read back per radio as the macfilter scripts do. With an
    # allow-mode radio in the mix, which running AP carries which policy is not
    # known here, so the answer is "unknown" rather than a guess.
    if [ "$WIFI_ALLOW" -gt 0 ]; then
        ifaces=""; aif="unknown"
    elif ifaces=$(tctl_get_hostapd_ifaces); then
        [ -z "$ifaces" ] && aif="no-radio" || aif=""
    else
        ifaces=""; aif="unknown"
    fi
    for mac in $list; do
        if [ -n "$aif" ]; then
            echo "W $mac $aif"
            continue
        fi
        worst=3
        for iface in $ifaces; do
            if tctl_hostapd_cli_alive "$iface" && tctl_hostapd_acl_blocks "$iface" "$mac" deny; then
                state=acl
            elif tctl_hostapd_ubus_banned "$iface" "$mac"; then
                state=ban
            else
                state=none
            fi
            rank=$(tctl_enforce_rank "$state")
            [ "$rank" -lt "$worst" ] && worst="$rank"
        done
        case "$worst" in 3) state=acl ;; 2) state=ban ;; *) state=none ;; esac
        echo "W $mac $state"
    done
}

# ── merge ─────────────────────────────────────────────────────────────────
{
    emit_naming
    emit_live_blocks
    emit_live_limits
    emit_persisted_rules
    emit_shapes
    emit_wifi
} | awk -v fw="$TCTL_FW" -v persist="$PERSIST" '
function esc(s) {
    gsub(/[\001-\037]/, "", s)
    gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s)
    return s
}
function add(t, target,   k) {
    k = t SUBSEP target
    if (!(k in seen)) { seen[k] = 1; order[++n] = k; typ[k] = t; tgt[k] = target }
    return k
}
function rest(from,   s, i) {
    s = $from
    for (i = from + 1; i <= NF; i++) s = s " " $i
    return s
}
function jnum(v) { return (v == "" ? 0 : v + 0) }
function jbool(v) { return (v == "" ? "null" : (v ? "true" : "false")) }
$1 == "LEASE" { if (!($3 in lmac)) lmac[$3] = $2; if (!($2 in lip)) lip[$2] = $3
                if ($4 != "" && $4 != "*" && !($3 in lname)) lname[$3] = $4; next }
$1 == "ALIAS" { alias[$2] = rest(3); next }
$1 == "RDNS"  { if (!($2 in rdns)) rdns[$2] = $3; next }
$1 == "NEIGH" { if ($3 != "-") { if (!($2 in nmac)) nmac[$2] = $3; if (!($3 in nip)) nip[$3] = $2 }
                if ($4 == "REACHABLE" || $4 == "DELAY" || $4 == "PROBE" || $4 == "PERMANENT") reach[$2] = 1
                next }
$1 == "ON"    { on[$2] = 1; next }
$1 == "WALLOW" { wallow = $2 + 0; next }
$1 == "LB" { k = add("block", $2); live[k] = 1; if ($3 != "-") bmac[k] = $3; next }
$1 == "PB" { k = add("block", $2); saved[k] = 1; next }
$1 == "LR" { k = add("ratelimit", $2); live[k] = 1; mode[k] = $3; rate[k] = $4; up[k] = $5; next }
$1 == "PR" { k = add("ratelimit", $2); saved[k] = 1
             if (!(k in live)) { rate[k] = $3; mode[k] = ($4 == "-" ? "" : $4); up[k] = ($5 + 0 > 0 ? $5 : $3) }
             next }
$1 == "PS" { k = add("shape", $2); saved[k] = 1; rate[k] = $3; up[k] = ($4 + 0 > 0 ? $4 : $3); next }
$1 == "LS" { k = add("shape", $2); live[k] = 1; rate[k] = $3; if ($4 + 0 > 0) up[k] = $4; next }
$1 == "W"  { k = add("wifi", $2); saved[k] = 1; enf[k] = $3; next }
END {
    printf "{\"fw\":\"%s\",\"persist_rules\":%s,\"wifi_allow_ifaces\":%d,\"rules\":[", \
        fw, (persist == "1" ? "true" : "false"), wallow
    for (i = 1; i <= n; i++) {
        k = order[i]; t = typ[k]; target = tgt[k]
        ip = ""; mac = ""; name = ""; online = ""; applied = ""
        if (t == "wifi") {
            mac = target
            if (mac in lip) ip = lip[mac]; else if (mac in nip) ip = nip[mac]
            e = enf[k]
            if (e == "acl" || e == "ban") applied = 1; else if (e == "none") applied = 0
        } else {
            applied = 0; if (k in live) applied = 1
            if (target ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) ip = target
            if (ip != "") mac = (ip in lmac) ? lmac[ip] : ((ip in nmac) ? nmac[ip] : "")
            if (mac == "" && (k in bmac)) mac = bmac[k]
        }
        if (ip != "") {
            if (ip in alias) name = alias[ip]; else if (ip in lname) name = lname[ip]; else if (ip in rdns) name = rdns[ip]
            online = 0; if ((ip in on) || (ip in reach)) online = 1
        }
        printf "%s{\"type\":\"%s\",\"target\":\"%s\",\"ip\":\"%s\",\"mac\":\"%s\",\"name\":\"%s\",\"online\":%s,\"applied\":%s,\"persisted\":%s", \
            (i > 1 ? "," : ""), t, esc(target), esc(ip), esc(mac), esc(name), \
            jbool(online), jbool(applied), ((k in saved) ? "true" : "false")
        if (t == "ratelimit" || t == "shape")
            printf ",\"rate_kbit\":%d,\"rate_kbit_up\":%d", jnum(rate[k]), jnum(up[k] == "" || up[k] + 0 == 0 ? rate[k] : up[k])
        # A record written before modes were stored has none; it gets the
        # default the restore hook gives it (tctl_ratelimit_default_mode).
        if (t == "ratelimit" && mode[k] == "")
            mode[k] = (target ~ /\// && target !~ /\/32$/) ? "each" : "shared"
        if (t == "ratelimit")
            printf ",\"mode\":\"%s\"", esc(mode[k])
        if (t == "wifi")
            printf ",\"enforcement\":\"%s\"", esc(enf[k])
        printf "}"
    }
    printf "]}\n"
}'
