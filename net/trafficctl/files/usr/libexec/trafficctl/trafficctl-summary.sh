#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Summary of all active LAN devices with traffic control status.
# Output: JSON array with per-device info.
#
# Performance: all firewall/tc/conntrack state is fetched ONCE up front and
# reused per device, instead of re-dumping nft chains / re-reading conntrack
# inside the per-IP loop. On a router with many devices this turns O(N) heavy
# forks (one full conntrack read + two nft chain dumps + a tc call PER device)
# into a constant handful of calls.

. /usr/libexec/trafficctl/trafficctl-fw.sh

CONN_CACHE="/tmp/trafficctl_conn_cache"
[ -f "$CONN_CACHE" ] || : > "$CONN_CACHE"

PORT_MAP_FILE="/tmp/.trafficctl_portmap.$$"
# shellcheck disable=SC2064
trap "rm -f '$PORT_MAP_FILE'" EXIT INT TERM

# Enumerate every LAN subnet (multi-bridge / multi-VLAN aware), once.
LAN_SUBNETS=$(tctl_lan_subnets)
[ -z "$LAN_SUBNETS" ] && { echo '[]'; exit 0; }
LAN_DEVS=$(echo "$LAN_SUBNETS" | awk '{print $1}' | sort -u)
# Monitored = connected LANs + subnets routed via LAN next-hops (downstream
# routers) + trafficctl.main.extra_subnets. Membership spec for awk:
# "netbase:block:routerint ..." — routerint 0 marks a routed (not directly
# connected) subnet, no awk bit-ops needed.
ALL_SUBNETS=$(tctl_monitored_subnets)
MATCH_SPEC=$(echo "$ALL_SUBNETS" | awk '{printf "%s%s:%s:%s",(NR>1?" ":""),$2,$3,$4}')
# Device that carries the tc/HTB shaper (shaping is single-bridge by design).
PRIMARY_LAN_DEV=$(tctl_get_lan_device)

# Get WiFi station→interface mapping: "mac iface_name band"
get_wifi_stations() {
    iw dev 2>/dev/null | awk '/Interface/{print $2}' | while read -r iface; do
        local band=""
        local ch
        ch=$(iw dev "$iface" info 2>/dev/null | awk '/channel/{print $2}')
        if [ -n "$ch" ]; then
            if [ "$ch" -le 14 ] 2>/dev/null; then
                band="2.4G"
            elif [ "$ch" -le 177 ] 2>/dev/null; then
                band="5G"
            else
                band="6G"
            fi
        fi
        iw dev "$iface" station dump 2>/dev/null | awk -v iface="$iface" -v band="$band" \
            '/Station/{print tolower($2), iface, band}'
    done
}

# Get bridge MAC→port interface mapping across all LAN bridges: "mac port_iface"
get_bridge_macs() {
    local dev
    for dev in $LAN_DEVS; do
        [ -d "/sys/class/net/$dev/brif" ] || continue
        for pdir in /sys/class/net/"$dev"/brif/*/; do
            [ -d "$pdir" ] || continue
            local iface pno
            iface=$(basename "$pdir")
            pno=$(cat "${pdir}port_no" 2>/dev/null)
            [ -z "$pno" ] && continue
            printf "%d %s\n" "$(( pno ))" "$iface"
        done > "$PORT_MAP_FILE"
        brctl showmacs "$dev" 2>/dev/null | awk -v pmf="$PORT_MAP_FILE" '
        BEGIN { while ((getline line < pmf) > 0) { split(line, p, " "); portname[p[1]] = p[2] } }
        NR > 1 && $3 == "no" {
            mac = tolower($2)
            port = $1 + 0
            if (port in portname) print mac, portname[port]
        }'
    done
    rm -f "$PORT_MAP_FILE"
}

# All IPv4 addresses owned by the router itself (any interface) — excluded
# from the NAT-based device detection below so the router never shows up.
LOCAL_IPS=$(ip -4 addr show 2>/dev/null | awk '/inet /{split($2,a,"/");print a[1]}' | tr '\n' ' ')

# ── Single conntrack pass ──────────────────────────────────────────────────
# Emit "ip total tcp udp conns kind" for every active source in one read.
# A source qualifies when it belongs to a monitored subnet (kind l=LAN,
# r=routed), or — regardless of subnet — when the flow was SNAT/masqueraded
# by this router (reply dst != original src), which catches every forwarded
# client behind downstream routers without any configuration (kind r).
CT_SUMMARY=$(awk -v spec="$MATCH_SPEC" -v localips="$LOCAL_IPS" '
function ip2int(ip,   a) {
    split(ip, a, ".")
    return a[1]*16777216 + a[2]*65536 + a[3]*256 + a[4]
}
# Return the index of the LAN subnet that contains ip, or 0.
function lan_idx(ip,   si, k) {
    si = ip2int(ip)
    for (k = 1; k <= ns; k++)
        if (si - (si % blk[k]) == base[k]) return k
    return 0
}
BEGIN {
    ns = split(spec, parts, " ")
    for (k = 1; k <= ns; k++) {
        split(parts[k], kv, ":")
        base[k] = kv[1] + 0; blk[k] = kv[2] + 0; rtr[k] = kv[3] + 0
    }
    nl = split(localips, lp, " ")
    for (k = 1; k <= nl; k++) if (lp[k] != "") islocal[lp[k]] = 1
}
{
    proto=""
    for (i=1; i<=NF; i++) {
        if ($i == "tcp") proto="tcp"
        else if ($i == "udp") proto="udp"
    }
    # first src= field that belongs to one of our monitored subnets
    srcidx=0; src=""; sk=0
    for (i=1; i<=NF; i++) {
        if (index($i, "src=") == 1) {
            v=substr($i, 5)
            k=lan_idx(v)
            if (k > 0) { src=v; srcidx=i; sk=k; break }
        }
    }
    if (src != "") {
        si=ip2int(src)
        # skip the router itself, the network address and the broadcast address
        # (routed /31 and /32 entries have no network/broadcast hosts to skip)
        if (rtr[sk] && si == rtr[sk]) next
        if (blk[sk] > 2 && (si == base[sk] || si == base[sk] + blk[sk] - 1)) next
        if (rtr[sk]) knd = "l"; else knd = "r"
    } else {
        # No subnet matched. NAT fallback: if the reply-direction dst differs
        # from the original src, this router SNAT/masqueraded the flow, so the
        # original src is an internal client (e.g. behind a downstream router
        # on a subnet we have no route entry for).
        osrc=""; oidx=0; nsrc=0; rdst=""
        for (i=1; i<=NF; i++) {
            if (index($i, "src=") == 1) {
                nsrc++
                if (nsrc == 1) { osrc=substr($i, 5); oidx=i }
            } else if (nsrc == 2 && rdst == "" && index($i, "dst=") == 1) {
                rdst=substr($i, 5)
            }
        }
        if (osrc == "" || rdst == "" || rdst == osrc) next
        if (osrc !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) next
        if (osrc in islocal) next
        src=osrc; srcidx=oidx; knd="r"
    }
    seen=0; got_dst=0; found=0; b=0
    for (i=srcidx; i<=NF; i++) {
        if (i == srcidx) { seen=1; continue }
        if (seen && !got_dst && index($i, "dst=") == 1) {
            dst=substr($i, 5)
            if (dst != src) { got_dst=1 } else next
        }
        if (seen && got_dst && index($i, "bytes=") == 1) {
            b=substr($i, 7) + 0; found=1; break
        }
    }
    if (got_dst) {
        conns[src]++
        kind[src] = knd
        if (found) {
            total[src]+=b
            if (proto == "tcp") tcp[src]+=b
            else if (proto == "udp") udp[src]+=b
        }
    }
}
END {
    for (ip in conns)
        printf "%s %.0f %.0f %.0f %d %s\n", ip, total[ip]+0, tcp[ip]+0, udp[ip]+0, conns[ip], kind[ip]
}' /proc/net/nf_conntrack 2>/dev/null)

ACTIVE_IPS=$(echo "$CT_SUMMARY" | awk 'NF{print $1}' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n)
[ -z "$ACTIVE_IPS" ] && { echo '[]'; exit 0; }

# ── Prefetch all shared state once ─────────────────────────────────────────
NOW=$(date +%s)
LEASES=$(cat /tmp/dhcp.leases 2>/dev/null)
NEIGH=$(ip neigh show 2>/dev/null)

# Manual aliases (highest precedence) and the reverse-DNS name cache. Devices
# behind a downstream router have no lease here, so these two are the only way
# they get a name instead of "*".
ALIASES=$(cat /etc/trafficctl/names 2>/dev/null)
RDNS_CACHE_FILE="/tmp/trafficctl_rdns_cache"
RDNS_CACHE=$(cat "$RDNS_CACHE_FILE" 2>/dev/null)
RDNS_ENABLED=$(uci -q get trafficctl.main.resolve_names 2>/dev/null)
RDNS_TTL=$(uci -q get trafficctl.main.rdns_ttl 2>/dev/null)
[ "$RDNS_TTL" -gt 0 ] 2>/dev/null || RDNS_TTL=300
# IPs needing a (re)lookup, filled in during the emit loop and handed to the
# detached refresher at the end so this poll never blocks on DNS.
RDNS_PENDING=""

# Optional netifyd (DPI) application labels. Absent unless the agent is
# installed and running — the column simply stays empty otherwise.
NETIFY_CACHE_FILE="/tmp/trafficctl_netify.json"
NETIFY_APPS=""
if [ "$(uci -q get trafficctl.main.netify_enabled 2>/dev/null)" != "0" ] && [ -S "$(uci -q get trafficctl.main.netify_socket 2>/dev/null || echo /var/run/netifyd/netifyd.sock)" ]; then
    # Flatten "ip top-app" pairs once so the per-device lookup stays a
    # string match instead of a JSON parse per row.
    NETIFY_APPS=$(sed 's/},{/}\n{/g' "$NETIFY_CACHE_FILE" 2>/dev/null | \
        sed -n 's/.*"ip":"\([^"]*\)","top":"\([^"]*\)".*/\1 \2/p')
    NETIFY_AGE=$(( NOW - $(date -r "$NETIFY_CACHE_FILE" +%s 2>/dev/null || echo 0) ))
    NETIFY_INTERVAL=$(uci -q get trafficctl.main.netify_interval 2>/dev/null)
    [ "$NETIFY_INTERVAL" -gt 0 ] 2>/dev/null || NETIFY_INTERVAL=45
    if [ "$NETIFY_AGE" -ge "$NETIFY_INTERVAL" ]; then
        /usr/libexec/trafficctl/trafficctl-netify.sh collect >/dev/null 2>&1 &
    fi
fi

# Firewall dumps (IP-independent — fetched once, grepped per device below)
if [ "$TCTL_FW" = "nft" ]; then
    FWD_DUMP=$(nft list chain inet fw4 forward 2>/dev/null)
    RL_DUMP=$(nft list table netdev tm_ratelimit 2>/dev/null)
else
    FWD_DUMP=$(iptables -L FORWARD -nvx 2>/dev/null)
    RL_DUMP=$(iptables -t mangle -L FORWARD -nv 2>/dev/null)
fi

# tc HTB classes → "classid rate_kbit" maps (one tc call per device, parsed
# once): download on the LAN device, upload on the IFB.
TC_MAP=$(tctl_tc_class_rates "$PRIMARY_LAN_DEV")
TC_MAP_UP=$(tctl_tc_class_rates "$(tctl_shape_ifb_dev)")

# address → classid, from shapes.json (see tctl_shape_classmap).
SHAPE_MAP=$(tctl_shape_classmap)

# Wifi ACL state, split by policy, because "listed" means opposite things in the
# two modes: on a deny (blacklist) radio a listed MAC is blocked, on an allow
# (whitelist) radio a listed MAC is the only kind permitted. Collected once here
# and matched fork-free per device below.
WIFI_DENY_MACS=""
WIFI_ALLOW_MACS=""
WIFI_HAS_ALLOW=0
for _wif in $(tctl_get_wifi_interfaces); do
    _wlist=$(uci -q get "wireless.${_wif}.maclist" 2>/dev/null)
    if [ "$(tctl_get_wifi_filter_mode "$_wif")" = "allow" ]; then
        WIFI_HAS_ALLOW=1
        WIFI_ALLOW_MACS="$WIFI_ALLOW_MACS $_wlist"
    else
        WIFI_DENY_MACS="$WIFI_DENY_MACS $_wlist"
    fi
done
WIFI_DENY_MACS=" $(echo "$WIFI_DENY_MACS" | tr 'A-F' 'a-f') "
WIFI_ALLOW_MACS=" $(echo "$WIFI_ALLOW_MACS" | tr 'A-F' 'a-f') "

WIFI_STATIONS=$(get_wifi_stations)
BRIDGE_MACS=$(get_bridge_macs)

# ── Per-device helpers (operate on prefetched blobs, no new forks of nft/tc) ─
# Name precedence: manual alias > DHCP lease > cached reverse DNS.
lookup_name() {
    local ip="$1" name
    name=$(echo "$ALIASES" | awk -v ip="$ip" '$1 == ip {sub(/^[^ ]+ +/, ""); print; exit}')
    [ -n "$name" ] && { echo "$name"; return; }
    name=$(echo "$LEASES" | awk -v ip="$ip" '$3 == ip && $4 != "*" {print $4; exit}')
    [ -n "$name" ] && { echo "$name"; return; }
    [ "$RDNS_ENABLED" = "0" ] && return
    echo "$RDNS_CACHE" | awk -v ip="$ip" '$1 == ip && $2 != "-" {print $2; exit}'
}

lookup_app() {
    [ -z "$NETIFY_APPS" ] && return
    echo "$NETIFY_APPS" | awk -v ip="$1" '$1 == ip {print $2; exit}'
}

# True when the cache holds no fresh entry for this IP (hit or negative), so
# the caller should queue a background lookup.
rdns_stale() {
    local ip="$1" ts
    [ "$RDNS_ENABLED" = "0" ] && return 1
    ts=$(echo "$RDNS_CACHE" | awk -v ip="$ip" '$1 == ip {print $3; exit}')
    [ -z "$ts" ] && return 0
    [ $(( NOW - ts )) -ge "$RDNS_TTL" ]
}

lookup_mac() {
    local ip="$1" mac
    mac=$(echo "$LEASES" | awk -v ip="$ip" '$3 == ip {print $2; exit}')
    [ -z "$mac" ] && mac=$(echo "$NEIGH" | awk -v ip="$ip" '$1 == ip {for(i=1;i<=NF;i++)if($i=="lladdr"){print $(i+1);exit}}')
    echo "$mac" | tr 'A-F' 'a-f'
}

# Addresses are matched as whole fields throughout: an unanchored match reports
# 192.168.1.10's block as belonging to 192.168.1.1.
lookup_blocked() {
    local ip="$1"
    if [ "$TCTL_FW" = "nft" ]; then
        echo "$FWD_DUMP" | grep -q "ip saddr $ip .*drop" && { echo 1; return; }
        # The IPv6 half of a block matches a MAC and carries no address, so it
        # is found by its own full comment. Without this the table reports "not
        # blocked" for a device whose v6 rule is the only one left standing.
        echo "$FWD_DUMP" | grep -qF "comment \"$(tctl_block_comment "$ip")_mac\"" \
            && echo 1 || echo 0
    else
        echo "$FWD_DUMP" | awk -v ip="$ip" '
            $3 == "DROP" {
                for (i = 4; i <= NF; i++) {
                    src = $i
                    sub(/\/32$/, "", src)
                    if (src == ip) { found = 1; exit }
                }
            }
            END { print (found ? 1 : 0) }'
    fi
}

lookup_block_bytes() {
    local ip="$1" b
    if [ "$TCTL_FW" = "nft" ]; then
        # Both halves of the block, summed: the v4 rule keyed on the address
        # and the v6 rule keyed on the MAC. Counting only the first would make
        # a dual-stack device's dropped bytes read low for the same reason the
        # traffic used to escape entirely.
        b=$(echo "$FWD_DUMP" | grep -e "ip saddr $ip " \
                -e "comment \"$(tctl_block_comment "$ip")_mac\"" \
            | grep -oE 'bytes [0-9]+' | awk '{ t += $2 } END { printf "%.0f", t }')
    else
        b=$(echo "$FWD_DUMP" | awk -v ip="$ip" '
            $3 == "DROP" {
                for (i = 4; i <= NF; i++) {
                    src = $i
                    sub(/\/32$/, "", src)
                    if (src == ip) { print $2; exit }
                }
            }' | head -1)
    fi
    echo "${b:-0}"
}

# $2 "up" reads the upload ceiling instead of the download one.
lookup_rate_limit() {
    local ip="$1" r fld=daddr pat='rl_ratelimit'
    [ "$2" = "up" ] && { fld=saddr; pat='rl_ratelimit.*_ul'; }
    if [ "$TCTL_FW" = "nft" ]; then
        r=$(echo "$RL_DUMP" | tctl_rl_rate_kbit "$ip" "$fld")
    else
        # The address as a whole field, not a substring (see tctl_rl_rate_kbit).
        # The download rule is listed first, so it is the first match either
        # way; the upload one is the only "_ul" name.
        r=$(echo "$RL_DUMP" | grep -E "$pat" \
            | awk -v ip="$ip" '{ for (i = 1; i <= NF; i++) if ($i == ip || $i == ip "/32") { print; next } }' \
            | awk "$TCTL_NFT_RATE_AWK"'{ r = tctl_ipt_first_rate(); if (r >= 0) { print r; exit } }')
    fi
    echo "${r:-0}"
}

# The classid is looked up, never derived from the address: minors are
# allocated, so deriving put the first shaped device's rate on 192.168.x.2 and
# showed 0 for the device actually shaped — and the Telegram bot built its
# "Shape — Remove" button from this field.
#
# $2 "up" reads the upload class on the IFB. 0 there with a download shape set
# means upload is not shaped at all (no kmod-ifb), not that it matches.
lookup_shape_kbit() {
    local ip="$1" classid r map="$TC_MAP"
    [ "$2" = "up" ] && map="$TC_MAP_UP"
    classid=$(echo "$SHAPE_MAP" | awk -v ip="$ip" '$1==ip{print $2; exit}')
    [ -n "$classid" ] || { echo 0; return; }
    r=$(echo "$map" | awk -v c="$classid" '$1==c{print $2; exit}')
    echo "${r:-0}"
}

lookup_wifi_blocked() {
    local mac="$1"
    [ -z "$mac" ] && { echo 0; return; }
    # Listed on a deny radio -> blocked there.
    case "$WIFI_DENY_MACS" in *" $mac "*) echo 1; return ;; esac
    # Absent from a whitelist radio -> cannot associate there, so also blocked.
    if [ "$WIFI_HAS_ALLOW" = "1" ]; then
        case "$WIFI_ALLOW_MACS" in
            *" $mac "*) ;;
            *) echo 1; return ;;
        esac
    fi
    echo 0
}

# ── Emit JSON ──────────────────────────────────────────────────────────────
printf "["
FIRST=1
for ip in $ACTIVE_IPS; do
    # shellcheck disable=SC2046 # deliberate split into 5 positional fields
    set -- $(echo "$CT_SUMMARY" | awk -v ip="$ip" '$1==ip{print $2,$3,$4,$5,$6; exit}')
    TOTAL="${1:-0}"; TCP="${2:-0}"; UDP="${3:-0}"; CONNS="${4:-0}"; KIND="${5:-l}"

    NAME=$(lookup_name "$ip")
    MAC=$(lookup_mac "$ip")
    BLOCKED=$(lookup_blocked "$ip")
    BLOCK_BYTES=$(lookup_block_bytes "$ip")
    WIFI_BLK=$(lookup_wifi_blocked "$MAC")
    RATE_LIM=$(lookup_rate_limit "$ip")
    RATE_LIM_UP=$(lookup_rate_limit "$ip" up)
    SHAPE=$(lookup_shape_kbit "$ip")
    SHAPE_UP=$(lookup_shape_kbit "$ip" up)
    APP=$(lookup_app "$ip")
    if [ -z "$NAME" ]; then
        NAME="*"
        rdns_stale "$ip" && RDNS_PENDING="$RDNS_PENDING $ip"
    fi
    # A DHCP hostname is client-controlled: a quote or backslash in it would
    # break this JSON document for every consumer (the LuCI table, the bot,
    # the exporter). Keep only characters that are safe unquoted.
    NAME=$(printf '%s' "$NAME" | tr -d '"\\' | tr -d '\n\r\t')

    CONN_TYPE=""
    CONN_LAST=""
    if [ "$KIND" = "r" ]; then
        # Behind a downstream router — no local MAC / bridge port / ARP entry.
        CONN_TYPE="routed"
    else
        if [ -n "$MAC" ]; then
            _wl=$(echo "$WIFI_STATIONS" | grep -i "$MAC")
            if [ -n "$_wl" ]; then
                _band=$(echo "$_wl" | awk '{print $3}')
                CONN_TYPE="${_band:-wifi}"
            else
                _bl=$(echo "$BRIDGE_MACS" | grep -i "$MAC")
                if [ -n "$_bl" ]; then
                    _piface=$(echo "$_bl" | awk '{print $2}')
                    case "$_piface" in
                        phy*|wlan*) CONN_TYPE="wifi" ;;
                        *) CONN_TYPE="$_piface" ;;
                    esac
                fi
            fi
        fi
        if [ -n "$CONN_TYPE" ]; then
            sed -i "/^$ip /d" "$CONN_CACHE" 2>/dev/null
            echo "$ip $CONN_TYPE $NOW" >> "$CONN_CACHE"
        else
            _arp_state=$(echo "$NEIGH" | awk -v ip="$ip" '$1==ip{print $NF; exit}')
            case "$_arp_state" in
                REACHABLE|STALE|DELAY|PROBE) CONN_TYPE="ethernet" ;;
                *)
                    CONN_TYPE="?"
                    _cached=$(grep "^$ip " "$CONN_CACHE" 2>/dev/null | tail -1)
                    if [ -n "$_cached" ]; then
                        CONN_LAST=$(echo "$_cached" | awk '{print $2 "@" $3}')
                    fi
                    ;;
            esac
        fi
    fi

    # Needs CONN_TYPE, so it is decided here rather than next to WIFI_BLK.
    WIFI_PENDING=0
    tctl_wifi_block_pending "$WIFI_BLK" "$CONN_TYPE" && WIFI_PENDING=1

    if [ "$FIRST" = "1" ]; then
        FIRST=0
    else
        printf ","
    fi
    printf '{"ip":"%s","name":"%s","mac":"%s","conn_type":"%s","conn_last":"%s","app":"%s","conns":%d,"total":%.0f,"tcp":%.0f,"udp":%.0f,"blocked":%s,"block_bytes":%.0f,"wifi_blocked":%s,"wifi_block_pending":%s,"rate_limit_kbit":%.0f,"rate_limit_kbit_up":%.0f,"shape_kbit":%.0f,"shape_kbit_up":%.0f}' \
        "$ip" "$NAME" "$MAC" "$CONN_TYPE" "$CONN_LAST" "$APP" "$CONNS" "$TOTAL" "$TCP" "$UDP" \
        "$([ "$BLOCKED" = "1" ] && echo true || echo false)" \
        "$BLOCK_BYTES" \
        "$([ "$WIFI_BLK" = "1" ] && echo true || echo false)" \
        "$([ "$WIFI_PENDING" = "1" ] && echo true || echo false)" \
        "$RATE_LIM" "$RATE_LIM_UP" "$SHAPE" "$SHAPE_UP"
done
printf "]\n"

# Kick off name resolution for whatever is still unnamed. Detached and capped:
# the results land in the cache and show up on the next poll.
if [ -n "$RDNS_PENDING" ]; then
    # shellcheck disable=SC2086 # deliberate word-splitting into arguments
    set -- $RDNS_PENDING
    [ $# -gt 8 ] && shift $(( $# - 8 ))
    /usr/libexec/trafficctl/trafficctl-rdns-refresh.sh "$@" >/dev/null 2>&1 &
fi
