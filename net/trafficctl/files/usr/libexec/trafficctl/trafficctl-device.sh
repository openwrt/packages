#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Detailed device info with connections.
# Usage: trafficctl-device.sh <ip> [--rdns] [--proto tcp|udp|all]

. /usr/libexec/trafficctl/trafficctl-fw.sh

LAN_DEV=$(tctl_get_lan_device)

# Parse arguments
IP=""
DO_RDNS=0
PROTO_FILTER="all"

while [ $# -gt 0 ]; do
    case "$1" in
        --rdns) DO_RDNS=1 ;;
        --proto) shift; PROTO_FILTER="$1" ;;
        *) [ -z "$IP" ] && IP="$1" ;;
    esac
    shift
done

if [ -z "$IP" ]; then
    echo '{"ok":false,"msg":"usage: trafficctl-device.sh <ip> [--rdns] [--proto tcp|udp|all]"}'
    exit 1
fi

if ! tctl_validate_ip "$IP"; then
    echo '{"ok":false,"msg":"invalid IP address"}'
    exit 1
fi

# Get device name from DHCP leases
NAME=""
MAC=""
if [ -f /tmp/dhcp.leases ]; then
    NAME=$(awk -v ip="$IP" '$3 == ip {print $4}' /tmp/dhcp.leases | head -1)
    MAC=$(awk -v ip="$IP" '$3 == ip {print $2}' /tmp/dhcp.leases | head -1)
fi
if [ -z "$MAC" ]; then
    MAC=$(ip neigh show "$IP" 2>/dev/null | grep -oE '[0-9a-fA-F:]{17}' | head -1)
fi
MAC=$(echo "$MAC" | tr 'A-F' 'a-f')
[ "$NAME" = "*" ] && NAME=""

# Same precedence as the summary: manual alias wins, then the lease name above,
# then cached reverse DNS (the only automatic source for routed devices).
ALIAS=$(awk -v ip="$IP" '$1 == ip {sub(/^[^ ]+ +/, ""); print; exit}' /etc/trafficctl/names 2>/dev/null)
[ -n "$ALIAS" ] && NAME="$ALIAS"
if [ -z "$NAME" ] && [ "$(uci -q get trafficctl.main.resolve_names 2>/dev/null)" != "0" ]; then
    NAME=$(awk -v ip="$IP" '$1 == ip && $2 != "-" {print $2; exit}' /tmp/trafficctl_rdns_cache 2>/dev/null)
fi
[ -z "$NAME" ] && NAME="*"

# Detect connection type — specific interface or band
CONN_TYPE=""
CONN_LAST=""
CONN_CACHE="/tmp/trafficctl_conn_cache"
[ -f "$CONN_CACHE" ] || : > "$CONN_CACHE"

if ! tctl_ip_in_lan "$IP"; then
    # Not on any connected LAN subnet — reached via a downstream router.
    CONN_TYPE="routed"
elif [ -n "$MAC" ]; then
    _wifi_stations=$(
        for _wi in $(iw dev 2>/dev/null | awk '/Interface/{print $2}'); do
            _ch=$(iw dev "$_wi" info 2>/dev/null | awk '/channel/{print $2}')
            _band=""
            if [ -n "$_ch" ]; then
                if [ "$_ch" -le 14 ] 2>/dev/null; then _band="2.4G"
                elif [ "$_ch" -le 177 ] 2>/dev/null; then _band="5G"
                else _band="6G"; fi
            fi
            iw dev "$_wi" station dump 2>/dev/null | awk -v iface="$_wi" -v band="$_band" \
                '/Station/{print tolower($2), iface, band}'
        done
    )
    WIFI_LINE=$(echo "$_wifi_stations" | grep -i "$MAC")
    if [ -n "$WIFI_LINE" ]; then
        CONN_TYPE=$(echo "$WIFI_LINE" | awk '{print $3}')
        [ -z "$CONN_TYPE" ] && CONN_TYPE="wifi"
    else
        BR_PORT=$(brctl showmacs "$LAN_DEV" 2>/dev/null | awk -v mac="$MAC" '
            NR>1 && $3=="no" && tolower($2)==mac {print $1; exit}')
        if [ -n "$BR_PORT" ]; then
            PORT_IFACE=""
            for pdir in /sys/class/net/"$LAN_DEV"/brif/*/; do
                [ -d "$pdir" ] || continue
                pno=$(cat "${pdir}port_no" 2>/dev/null)
                [ -z "$pno" ] && continue
                if [ $(( pno )) -eq "$BR_PORT" ] 2>/dev/null; then
                    PORT_IFACE=$(basename "$pdir")
                    break
                fi
            done
            case "$PORT_IFACE" in
                phy*|wlan*) CONN_TYPE="wifi" ;;
                "") ;;
                *) CONN_TYPE="$PORT_IFACE" ;;
            esac
        fi
    fi
fi

if [ -n "$CONN_TYPE" ]; then
    sed -i "/^$IP /d" "$CONN_CACHE" 2>/dev/null
    echo "$IP $CONN_TYPE $(date +%s)" >> "$CONN_CACHE"
else
    _arp_state=$(ip neigh show "$IP" 2>/dev/null | awk '{print $NF}')
    case "$_arp_state" in
        REACHABLE|STALE|DELAY|PROBE) CONN_TYPE="ethernet" ;;
        *)
            CONN_TYPE="?"
            _cached=$(grep "^$IP " "$CONN_CACHE" 2>/dev/null | tail -1)
            if [ -n "$_cached" ]; then
                CONN_LAST=$(echo "$_cached" | awk '{print $2 "@" $3}')
            fi
            ;;
    esac
fi

# Check blocked status
BLOCKED=false
BLOCK_PACKETS=0
BLOCK_BYTES=0
if tctl_is_blocked "$IP"; then
    BLOCKED=true
    if [ "$TCTL_FW" = "nft" ]; then
        # A block is two rules — the v4 one keyed on the address and the v6 one
        # keyed on the MAC (see tctl_block_add) — so the counters are summed
        # across both. The v6 rule carries no address, only its "_mac" comment.
        block_line=$(nft list chain inet fw4 forward 2>/dev/null \
            | grep -e "ip saddr $IP.*drop" -e "comment \"$(tctl_block_comment "$IP")_mac\"")
        BLOCK_PACKETS=$(echo "$block_line" | grep -oE 'packets [0-9]+' | awk '{ t += $2 } END { printf "%.0f", t }')
        BLOCK_BYTES=$(echo "$block_line" | grep -oE 'bytes [0-9]+' | awk '{ t += $2 } END { printf "%.0f", t }')
    else
        block_line=$(iptables -L FORWARD -nvx 2>/dev/null | grep "DROP" | grep "$IP")
        BLOCK_PACKETS=$(echo "$block_line" | awk '{print $1}')
        BLOCK_BYTES=$(echo "$block_line" | awk '{print $2}')
    fi
fi
[ -z "$BLOCK_PACKETS" ] && BLOCK_PACKETS=0
[ -z "$BLOCK_BYTES" ] && BLOCK_BYTES=0

# Check wifi blocked
WIFI_BLOCKED=false
if [ -n "$MAC" ]; then
    IFACES=$(tctl_get_wifi_interfaces)
    for iface in $IFACES; do
        maclist=$(uci -q get "wireless.${iface}.maclist")
        listed=0
        echo "$maclist" | grep -qi "$MAC" && listed=1
        # Being listed means the opposite thing per policy: on a deny radio a
        # listed MAC is blocked, on an allow (whitelist) radio an UNlisted one is.
        if [ "$(tctl_get_wifi_filter_mode "$iface")" = "allow" ]; then
            [ "$listed" = "0" ] && { WIFI_BLOCKED=true; break; }
        else
            [ "$listed" = "1" ] && { WIFI_BLOCKED=true; break; }
        fi
    done
fi

# Get rate limit, each direction: upload has its own ceiling since #83.
RATE_LIM=0; RATE_LIM_UP=0
if [ "$TCTL_FW" = "nft" ]; then
    RL_DUMP=$(nft list table netdev tm_ratelimit 2>/dev/null)
    RATE_LIM=$(echo "$RL_DUMP" | tctl_rl_rate_kbit "$IP")
    RATE_LIM_UP=$(echo "$RL_DUMP" | tctl_rl_rate_kbit "$IP" saddr)
else
    # The address as a whole field, not a substring (see tctl_rl_rate_kbit).
    # The download rule is listed first; the upload one is the "_ul" name.
    RL_DUMP=$(iptables -t mangle -L FORWARD -nv 2>/dev/null | grep "rl_ratelimit" \
        | awk -v ip="$IP" '{ for (i = 1; i <= NF; i++) if ($i == ip || $i == ip "/32") { print; next } }')
    RATE_LIM=$(echo "$RL_DUMP" | awk "$TCTL_NFT_RATE_AWK"'{ r = tctl_ipt_first_rate(); if (r >= 0) { print r; exit } }')
    RATE_LIM_UP=$(echo "$RL_DUMP" | grep -E 'rl_ratelimit.*_ul' \
        | awk "$TCTL_NFT_RATE_AWK"'{ r = tctl_ipt_first_rate(); if (r >= 0) { print r; exit } }')
fi
[ -z "$RATE_LIM" ] && RATE_LIM=0
[ -z "$RATE_LIM_UP" ] && RATE_LIM_UP=0

# Get shape rate. The classid is looked up in shapes.json, never derived from
# the address: minors are allocated (see lookup_shape_kbit in
# trafficctl-summary.sh). Download is the class on the LAN device, upload the
# one with the same classid on the IFB.
SHAPE_KBIT=0; SHAPE_KBIT_UP=0
classid=$(tctl_shape_classmap | awk -v ip="$IP" '$1==ip{print $2; exit}')
if [ -n "$classid" ]; then
    SHAPE_KBIT=$(tctl_tc_class_rates "$LAN_DEV" | awk -v c="$classid" '$1==c{print $2; exit}')
    SHAPE_KBIT_UP=$(tctl_tc_class_rates "$(tctl_shape_ifb_dev)" | awk -v c="$classid" '$1==c{print $2; exit}')
fi
[ -z "$SHAPE_KBIT" ] && SHAPE_KBIT=0
[ -z "$SHAPE_KBIT_UP" ] && SHAPE_KBIT_UP=0

# Parse conntrack for connections and totals
TIMESTAMP=$(date +%s)
CONNTRACK_DATA=$(cat /proc/net/nf_conntrack 2>/dev/null | grep "src=$IP ")

# Compute metadata (totals + states)
META_LINE=$(echo "$CONNTRACK_DATA" | awk -v ip="$IP" -v pf="$PROTO_FILTER" '
BEGIN { total=0; n_tcp=0; n_udp=0; n_other=0; est=0; tw=0; ss=0; cw=0 }
{
    proto=""
    for (i=1; i<=NF; i++) {
        if ($i == "tcp") proto="tcp"
        else if ($i == "udp") proto="udp"
        else if ($i == "icmp") proto="icmp"
    }
    if (pf != "all" && proto != pf) next

    dst=""; bytes=0; state=""
    src_key = "src=" ip
    seen_src=0; got_dst=0
    for (i=1; i<=NF; i++) {
        if ($i == src_key && !seen_src) { seen_src=1; continue }
        if (seen_src && !got_dst && index($i, "dst=") == 1) { dst=substr($i, 5); got_dst=1 }
        if (seen_src && !got_dst) continue
        if (seen_src && index($i, "bytes=") == 1 && bytes == 0) { bytes=substr($i, 7)+0 }
        if ($i == "ESTABLISHED") state="ESTABLISHED"
        else if ($i == "TIME_WAIT") state="TIME_WAIT"
        else if ($i == "SYN_SENT") state="SYN_SENT"
        else if ($i == "CLOSE_WAIT") state="CLOSE_WAIT"
    }
    if (dst == "" || dst == ip) next
    total += bytes
    if (proto == "tcp") n_tcp++
    else if (proto == "udp") n_udp++
    else n_other++
    if (state == "ESTABLISHED") est++
    else if (state == "TIME_WAIT") tw++
    else if (state == "SYN_SENT") ss++
    else if (state == "CLOSE_WAIT") cw++
}
END { printf "%.0f %d %d %d %d %d %d %d", total, n_tcp, n_udp, n_other, est, tw, ss, cw }
')

TOTAL=$(echo "$META_LINE" | awk '{print $1}')
N_TCP=$(echo "$META_LINE" | awk '{print $2}')
N_UDP=$(echo "$META_LINE" | awk '{print $3}')
N_OTHER=$(echo "$META_LINE" | awk '{print $4}')
EST=$(echo "$META_LINE" | awk '{print $5}')
TW=$(echo "$META_LINE" | awk '{print $6}')
SS=$(echo "$META_LINE" | awk '{print $7}')
CW=$(echo "$META_LINE" | awk '{print $8}')

[ -z "$TOTAL" ] && TOTAL=0
[ -z "$N_TCP" ] && N_TCP=0
[ -z "$N_UDP" ] && N_UDP=0
[ -z "$N_OTHER" ] && N_OTHER=0
[ -z "$EST" ] && EST=0
[ -z "$TW" ] && TW=0
[ -z "$SS" ] && SS=0
[ -z "$CW" ] && CW=0

# Build connections JSON array
# Resolve egress interface per destination for policy-routed connections
# (mwan3 etc.). Only connections carrying a NON-zero conntrack mark are
# resolved: `ip route get <dst> mark <mark>` honours the fwmark ip-rules, so it
# reports the WAN that mwan3 actually selected. mark=0 connections (no policy
# routing, e.g. plain single-WAN or podkop) are left blank instead of showing a
# misleading main-table egress.
OIF_MAP="/tmp/trafficctl_oif_$$"
: > "$OIF_MAP"
if command -v ip >/dev/null 2>&1; then
    echo "$CONNTRACK_DATA" | awk -v ip="$IP" '
    { dst=""; mark="0"; sk="src=" ip; seen=0; got=0
      for (i=1; i<=NF; i++) {
          if ($i==sk && !seen) { seen=1; continue }
          if (seen && !got && index($i,"dst=")==1) { dst=substr($i,5); got=1 }
          if (index($i,"mark=")==1) mark=substr($i,6)
      }
      if (dst!="" && dst!=ip && mark!="0" && mark!="") print dst, mark
    }' | sort -u | while read -r dip dmark; do
        [ -n "$dip" ] || continue
        dev=$(ip route get "$dip" mark "$dmark" 2>/dev/null | grep -oE 'dev [^ ]+' | head -1 | cut -d' ' -f2)
        case "$dev" in lo|"") continue ;; esac
        echo "$dip $dev" >> "$OIF_MAP"
    done
fi

# The kernel device is not what the user named the interface: mwan3 egress is
# "awg3", the network is "Finland" (#10). The uci name comes from the role map
# trafficctl-ifaces.sh already memoizes in tmpfs — the overview polls it, so it
# is normally warm. Built here only when it is missing and there is something
# to label, never per connection.
IFROLE_CACHE="${TCTL_IFROLE_CACHE:-/tmp/trafficctl_ifroles}"
if [ -s "$OIF_MAP" ] && [ ! -s "$IFROLE_CACHE" ]; then
    /usr/libexec/trafficctl/trafficctl-ifaces.sh >/dev/null 2>&1
fi

CONNS_OUT=$(echo "$CONNTRACK_DATA" | awk -v ip="$IP" -v pf="$PROTO_FILTER" -v oifmap="$OIF_MAP" -v ifroles="$IFROLE_CACHE" '
BEGIN {
    n=0
    while ((getline line < oifmap) > 0) { split(line, p, " "); oifdev[p[1]] = p[2] }
    close(oifmap)
    # "dev role tunnel primary defroute enslaved label", label "-" when the
    # device has no uci interface. Header lines start with "#".
    while ((getline line < ifroles) > 0) {
        if (substr(line, 1, 1) == "#") continue
        if (split(line, f, " ") < 7 || f[7] == "-") continue
        oiflbl[f[1]] = f[7]
    }
    close(ifroles)
}
{
    proto=""
    for (i=1; i<=NF; i++) {
        if ($i == "tcp") proto="tcp"
        else if ($i == "udp") proto="udp"
        else if ($i == "icmp") proto="icmp"
    }
    if (pf != "all" && proto != pf) next

    dst=""; dport=""; bytes=0; state=""
    src_key = "src=" ip
    seen_src=0; got_dst=0
    for (i=1; i<=NF; i++) {
        if ($i == src_key && !seen_src) { seen_src=1; continue }
        if (seen_src && !got_dst && index($i, "dst=") == 1) { dst=substr($i, 5); got_dst=1 }
        if (seen_src && !got_dst) continue
        if (seen_src && index($i, "dport=") == 1 && dport == "") dport=substr($i, 7)
        if (seen_src && index($i, "bytes=") == 1 && bytes == 0) bytes=substr($i, 7)+0
        if ($i == "ESTABLISHED") state="ESTABLISHED"
        else if ($i == "TIME_WAIT") state="TIME_WAIT"
        else if ($i == "SYN_SENT") state="SYN_SENT"
        else if ($i == "CLOSE_WAIT") state="CLOSE_WAIT"
        else if ($i == "FIN_WAIT") state="FIN_WAIT"
    }
    if (dst == "" || dst == ip) next
    if (dport == "") dport = "0"

    # Service name lookup
    svc=""
    if (dport == "80") svc="http"
    else if (dport == "443") svc="https"
    else if (dport == "53") svc="dns"
    else if (dport == "22") svc="ssh"
    else if (dport == "123") svc="ntp"
    else if (dport == "5353") svc="mdns"
    else if (dport == "21") svc="ftp"
    else if (dport == "25") svc="smtp"
    else if (dport == "993") svc="imaps"
    else if (dport == "8080") svc="http-alt"

    odev = ""; oif = ""
    if (dst in oifdev) { odev = oifdev[dst]; oif = odev }
    if (odev in oiflbl) oif = oiflbl[odev]
    if (n > 0) printf ","
    printf "{\"proto\":\"%s\",\"dst\":\"%s\",\"host\":\"\",\"port\":%s,\"service\":\"%s\",\"bytes\":%.0f,\"state\":\"%s\",\"oif\":\"%s\",\"oif_dev\":\"%s\"}", proto, dst, dport, svc, bytes, state, oif, odev
    n++
}
')
rm -f "$OIF_MAP"

# Optionally resolve DNS for connection destinations
if [ "$DO_RDNS" = "1" ]; then
    DST_IPS=$(echo "$CONNTRACK_DATA" | grep -oE 'dst=[0-9.]+' | sed 's/dst=//' | sort -u | grep -v "^$IP$")
    if [ -n "$DST_IPS" ]; then
        RDNS_MAP="/tmp/trafficctl_rdns_$$"
        # shellcheck disable=SC2064
        trap "rm -f '$RDNS_MAP'" EXIT INT TERM
        : > "$RDNS_MAP"
        RDNS_DONE=0
        # Batch resolve via ubus network.rrdns (same as LuCI frontend; no extra packages needed)
        if command -v ubus >/dev/null 2>&1; then
            ADDRS_JSON=$(echo "$DST_IPS" | awk '{printf "%s\"%s\"", (NR>1?",":""), $1}')
            RDNS_RESULT=$(ubus call network.rrdns lookup \
                "{\"addrs\":[$ADDRS_JSON],\"timeout\":3000,\"limit\":64}" 2>/dev/null)
            if [ -n "$RDNS_RESULT" ]; then
                RDNS_DONE=1
                for dip in $DST_IPS; do
                    host=$(printf '%s' "$RDNS_RESULT" | jsonfilter -e "@[\"$dip\"]" 2>/dev/null)
                    case "$host" in
                        *[!a-zA-Z0-9._-]*|"") continue ;;
                    esac
                    echo "$dip $host" >> "$RDNS_MAP"
                done
            fi
        fi
        # Fallback: per-IP nslookup (BusyBox, always available on OpenWrt)
        if [ "$RDNS_DONE" = "0" ] && command -v nslookup >/dev/null 2>&1; then
            for dip in $DST_IPS; do
                host=$(nslookup "$dip" 2>/dev/null | sed -n 's/.*name = \(.*\)\.$/\1/p' | head -1)
                case "$host" in
                    *[!a-zA-Z0-9._-]*|"") continue ;;
                esac
                echo "$dip $host" >> "$RDNS_MAP"
            done
        fi
        if [ -s "$RDNS_MAP" ]; then
            # Build sed expression from map
            SED_EXPR=$(awk '{printf "s|\"dst\":\"%s\",\"host\":\"\"|\"dst\":\"%s\",\"host\":\"%s\"|g\n", $1, $1, $2}' "$RDNS_MAP")
            CONNS_OUT=$(printf "%s" "$CONNS_OUT" | sed "$SED_EXPR")
        fi
        rm -f "$RDNS_MAP"
    fi
fi

# Listed as blocked yet associated right now = the radio never got the block.
WIFI_PENDING=false
tctl_wifi_block_pending "$([ "$WIFI_BLOCKED" = "true" ] && echo 1 || echo 0)" "$CONN_TYPE" \
    && WIFI_PENDING=true

# none / temporary / full: lets the view hide or qualify the WiFi block button
# on routers without radios or without the optional hostapd-utils.
WIFI_FILTER=$(tctl_wifi_filter_support)

# Output final JSON
printf '{"ip":"%s","name":"%s","mac":"%s","conn_type":"%s","conn_last":"%s","timestamp":%d,"blocked":%s,"block_packets":%d,"block_bytes":%.0f,"wifi_blocked":%s,"wifi_block_pending":%s,"wifi_filter":"%s","total":%.0f,"protocols":{"tcp":%d,"udp":%d,"other":%d},"tcp_states":{"established":%d,"time_wait":%d,"syn_sent":%d,"close_wait":%d},"connections":[%s],"rate_limit_kbit":%d,"rate_limit_kbit_up":%d,"shape_kbit":%d,"shape_kbit_up":%d}\n' \
    "$IP" "$NAME" "$MAC" "$CONN_TYPE" "$CONN_LAST" "$TIMESTAMP" "$BLOCKED" "$BLOCK_PACKETS" "$BLOCK_BYTES" \
    "$WIFI_BLOCKED" "$WIFI_PENDING" "$WIFI_FILTER" "$TOTAL" "$N_TCP" "$N_UDP" "$N_OTHER" \
    "$EST" "$TW" "$SS" "$CW" "$CONNS_OUT" "$RATE_LIM" "$RATE_LIM_UP" "$SHAPE_KBIT" "$SHAPE_KBIT_UP"
