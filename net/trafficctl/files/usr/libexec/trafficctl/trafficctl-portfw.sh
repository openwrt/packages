#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Inbound traffic control for port forwards and WAN-open ports.
#
# Usage:
#   trafficctl-portfw.sh list
#   trafficctl-portfw.sh pause  <scope> <proto> <ip> <port>
#   trafficctl-portfw.sh resume <scope> <proto> <ip> <port>
#   trafficctl-portfw.sh limit  <scope> <proto> <ip> <port> <rate_kbit>   (0 removes)
#
# scope: "forward" for a DNAT port forward (ip = internal destination),
#        "input"   for a router-local open port (ip is ignored, pass "-").
# proto: "tcp", "udp" or "tcpudp" (applies to both).
#
# Rules live in our own table (inet tctl_pfw) hooked at forward/input
# priority -190 — after DNAT (prerouting) so the internal address is
# matchable, and before the flowtable offload rule so drops/limits keep
# working with software offload enabled.

. /usr/libexec/trafficctl/trafficctl-fw.sh

PFW_PRIO="-190"

# ── validation helpers ──────────────────────────────────────────────────────

# iptables spells a port range lo:hi. Truncating to the low port (as this did)
# left every other port in the range open while reporting the whole range paused.
iptables_dport() {
    case "$1" in
        *-*) echo "${1%%-*}:${1##*-}" ;;
        *) echo "$1" ;;
    esac
}

# hashlimit names are capped at 15 characters, so a range cannot be spelled out
# in full: 8000-8100 as "pfw_8000_8100_tcp" would be silently truncated into a
# collision with a neighbouring range.
hashlimit_name() {
    local proto="$1" port="$2" lo
    lo="${port%%-*}"
    case "$port" in
        *-*) echo "pfwr${lo}_${proto}" ;;
        *) echo "pfw${lo}_${proto}" ;;
    esac
}

valid_port() {
    case "$1" in
        [0-9]*-[0-9]*)
            local lo="${1%%-*}" hi="${1##*-}"
            case "$lo$hi" in *[!0-9]*) return 1 ;; esac
            [ "$lo" -ge 1 ] && [ "$lo" -le 65535 ] && \
            [ "$hi" -ge 1 ] && [ "$hi" -le 65535 ] && [ "$lo" -le "$hi" ]
            ;;
        *)
            case "$1" in ''|*[!0-9]*) return 1 ;; esac
            [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
            ;;
    esac
}

# Expand "tcpudp" / "tcp udp" to individual proto tokens
proto_tokens() {
    case "$1" in
        tcpudp|"tcp udp"|"udp tcp"|all|"") echo "tcp udp" ;;
        tcp) echo "tcp" ;;
        udp) echo "udp" ;;
        *) return 1 ;;
    esac
}

pfw_comment() {
    # kind proto ip port -> stable rule comment
    printf 'tctl_pfw_%s_%s_%s_%s' "$1" "$2" "$3" "$4"
}

# ── nft/iptables plumbing ───────────────────────────────────────────────────

ensure_pfw_table() {
    [ "$TCTL_FW" = "nft" ] || return 0
    nft add table inet tctl_pfw 2>/dev/null
    nft add chain inet tctl_pfw pfw_forward \
        "{ type filter hook forward priority $PFW_PRIO; policy accept; }" 2>/dev/null
    nft add chain inet tctl_pfw pfw_input \
        "{ type filter hook input priority $PFW_PRIO; policy accept; }" 2>/dev/null
}

pfw_chain_for_scope() {
    [ "$1" = "input" ] && echo "pfw_input" || echo "pfw_forward"
}

# Delete every rule in our table/chains carrying the given comment
pfw_delete_by_comment() {
    local cmt="$1" chain h
    if [ "$TCTL_FW" = "nft" ]; then
        for chain in pfw_forward pfw_input; do
            for h in $(nft -a list chain inet tctl_pfw "$chain" 2>/dev/null | \
                       grep "\"$cmt\"" | grep -o 'handle [0-9]*' | awk '{print $2}'); do
                nft delete rule inet tctl_pfw "$chain" handle "$h" 2>/dev/null
            done
        done
    else
        for chain in FORWARD INPUT; do
            # Re-evaluate the first matching rule spec each pass until none
            # with the comment is left (empty spec makes iptables -D fail).
            # shellcheck disable=SC2046 # rule spec is intentionally re-split
            while iptables -D "$chain" $(iptables -S "$chain" 2>/dev/null | \
                    grep -m1 -- "--comment $cmt " | sed 's/^-A [A-Z]* //') 2>/dev/null; do :; done
        done
    fi
}

pfw_add_pause() {
    local scope="$1" proto="$2" ip="$3" port="$4"
    local cmt chain
    cmt=$(pfw_comment "pause" "$proto" "${ip:-local}" "$port")
    if [ "$TCTL_FW" = "nft" ]; then
        ensure_pfw_table
        chain=$(pfw_chain_for_scope "$scope")
        if [ "$scope" = "input" ]; then
            nft insert rule inet tctl_pfw "$chain" \
                "$proto" dport "$port" counter drop comment "\"$cmt\""
        else
            nft insert rule inet tctl_pfw "$chain" \
                ip daddr "$ip" "$proto" dport "$port" counter drop comment "\"$cmt\""
        fi
    else
        if [ "$scope" = "input" ]; then
            iptables -I INPUT -p "$proto" --dport "$(iptables_dport "$port")" -j DROP \
                -m comment --comment "$cmt" 2>/dev/null
        else
            iptables -I FORWARD -d "$ip" -p "$proto" --dport "$(iptables_dport "$port")" -j DROP \
                -m comment --comment "$cmt" 2>/dev/null
        fi
    fi
}

pfw_add_limit() {
    local scope="$1" proto="$2" ip="$3" port="$4" kbit="$5"
    local cmt chain rate_b
    rate_b=$(tctl_rate_bytes "$kbit")
    cmt=$(pfw_comment "limit" "$proto" "${ip:-local}" "$port")
    if [ "$TCTL_FW" = "nft" ]; then
        ensure_pfw_table
        chain=$(pfw_chain_for_scope "$scope")
        if [ "$scope" = "input" ]; then
            nft add rule inet tctl_pfw "$chain" \
                "$proto" dport "$port" limit rate over "$rate_b" bytes/second \
                counter drop comment "\"$cmt\""
        else
            nft add rule inet tctl_pfw "$chain" \
                ip daddr "$ip" "$proto" dport "$port" limit rate over "$rate_b" bytes/second \
                counter drop comment "\"$cmt\""
        fi
    else
        if [ "$scope" = "input" ]; then
            # shellcheck disable=SC2046 # deliberate split into the option words
            iptables -I INPUT -p "$proto" --dport "$(iptables_dport "$port")" -m hashlimit \
                $(tctl_ipt_limit_args "$kbit") \
                --hashlimit-mode dstport --hashlimit-name "$(hashlimit_name "$proto" "$port")" \
                -j DROP -m comment --comment "$cmt" 2>/dev/null
        else
            # shellcheck disable=SC2046 # deliberate split into the option words
            iptables -I FORWARD -d "$ip" -p "$proto" --dport "$(iptables_dport "$port")" -m hashlimit \
                $(tctl_ipt_limit_args "$kbit") \
                --hashlimit-mode dstip --hashlimit-name "$(hashlimit_name "$proto" "$port")" \
                -j DROP -m comment --comment "$cmt" 2>/dev/null
        fi
    fi
}

# Flush established conntrack entries so a pause takes effect immediately,
# even for flows already offloaded to the flowtable. Best effort.
pfw_flush_conntrack() {
    local proto="$1" ip="$2" port="$3" lo hi p
    command -v conntrack >/dev/null 2>&1 || return 0
    if [ -n "$ip" ] && [ "$ip" != "-" ]; then
        conntrack -D -p "$proto" --reply-src "$ip" 2>/dev/null
        return 0
    fi
    # conntrack takes one port at a time, so a range is walked. Wide ranges are
    # left to expire on their own rather than spending thousands of calls here.
    lo="${port%%-*}"
    hi="${port##*-}"
    if [ "$lo" = "$hi" ] || [ "$((hi - lo))" -gt 64 ] 2>/dev/null; then
        conntrack -D -p "$proto" --dport "$lo" 2>/dev/null
        return 0
    fi
    p="$lo"
    while [ "$p" -le "$hi" ]; do
        conntrack -D -p "$proto" --dport "$p" 2>/dev/null
        p=$((p + 1))
    done
    return 0
}

# ── list ────────────────────────────────────────────────────────────────────

do_list() {
    # Current control rules (one dump, grepped below):
    # comments look like tctl_pfw_<kind>_<proto>_<ip|local>_<port>
    local CTL_DUMP=""
    if [ "$TCTL_FW" = "nft" ]; then
        CTL_DUMP=$(nft list table inet tctl_pfw 2>/dev/null)
    else
        CTL_DUMP=$(printf '%s\n%s' "$(iptables -S FORWARD 2>/dev/null)" "$(iptables -S INPUT 2>/dev/null)")
    fi

    # Monitored subnets — used to keep router-local (input) stats to
    # external clients only (LAN hits on router ports are not "inbound").
    local MATCH_SPEC
    MATCH_SPEC=$(tctl_monitored_subnets | awk '{printf "%s%s:%s",(NR>1?" ":""),$2,$3}')

    # Enumerate rules first: "id|kind|protos|ip|port|extport|name|enabled|zone"
    local entries=""
    local i=0 name src dport dest_ip dest_port proto enabled target
    while uci -q get "firewall.@redirect[$i]" >/dev/null 2>&1; do
        name=$(uci -q get "firewall.@redirect[$i].name")
        src=$(uci -q get "firewall.@redirect[$i].src")
        dport=$(uci -q get "firewall.@redirect[$i].src_dport")
        dest_ip=$(uci -q get "firewall.@redirect[$i].dest_ip")
        dest_port=$(uci -q get "firewall.@redirect[$i].dest_port")
        proto=$(uci -q get "firewall.@redirect[$i].proto")
        enabled=$(uci -q get "firewall.@redirect[$i].enabled")
        target=$(uci -q get "firewall.@redirect[$i].target")
        i=$((i + 1))
        [ -n "$target" ] && [ "$target" != "DNAT" ] && continue
        [ -n "$dest_ip" ] && [ -n "$dport" ] || continue
        [ -z "$dest_port" ] && dest_port="$dport"
        proto=$(proto_tokens "$proto") || proto="tcp udp"
        name=$(printf '%s' "$name" | tr -cd 'a-zA-Z0-9 _.()-')
        entries="${entries}r$((i-1))|forward|${proto}|${dest_ip}|${dest_port}|${dport}|${name:-forward $dport}|${enabled:-1}|${src:-wan}
"
    done

    i=0
    local rsrc rdest
    while uci -q get "firewall.@rule[$i]" >/dev/null 2>&1; do
        name=$(uci -q get "firewall.@rule[$i].name")
        rsrc=$(uci -q get "firewall.@rule[$i].src")
        rdest=$(uci -q get "firewall.@rule[$i].dest")
        dport=$(uci -q get "firewall.@rule[$i].dest_port")
        proto=$(uci -q get "firewall.@rule[$i].proto")
        enabled=$(uci -q get "firewall.@rule[$i].enabled")
        target=$(uci -q get "firewall.@rule[$i].target")
        i=$((i + 1))
        # Router-local open ports: accept rules from a wan zone with no dest zone
        case "$rsrc" in *wan*) ;; *) continue ;; esac
        [ -n "$rdest" ] && continue
        [ "$target" = "ACCEPT" ] || continue
        [ -n "$dport" ] || continue
        proto=$(proto_tokens "$proto") || continue
        name=$(printf '%s' "$name" | tr -cd 'a-zA-Z0-9 _.()-')
        entries="${entries}a$((i-1))|open|${proto}|-|${dport}|${dport}|${name:-open $dport}|${enabled:-1}|${rsrc}
"
    done

    if [ -z "$entries" ]; then
        echo '[]'
        return 0
    fi

    # Single conntrack pass: per-entry conns / distinct clients / bytes.
    # forward: reply src == dest_ip && reply sport in dest_port && DNAT
    #          happened (orig dst != reply src)
    # open:    orig dport in port && no NAT (reply src == orig dst) && the
    #          client is not on a monitored subnet
    local STATS
    local ENTRY_FILE="/tmp/.trafficctl_pfw_entries.$$"
    printf '%s' "$entries" > "$ENTRY_FILE"
    STATS=$(awk -v ef="$ENTRY_FILE" -v spec="$MATCH_SPEC" '
    function ip2int(ip,   a) {
        split(ip, a, ".")
        return a[1]*16777216 + a[2]*65536 + a[3]*256 + a[4]
    }
    function is_internal(ip,   si, k) {
        if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) return 0
        si = ip2int(ip)
        for (k = 1; k <= ns; k++)
            if (si - (si % blk[k]) == base[k]) return 1
        return 0
    }
    function port_in(p, range,   lo, hi, sep) {
        sep = index(range, "-")
        if (sep == 0) return (p + 0) == (range + 0)
        lo = substr(range, 1, sep - 1) + 0
        hi = substr(range, sep + 1) + 0
        return (p + 0) >= lo && (p + 0) <= hi
    }
    BEGIN {
        ns = split(spec, sp, " ")
        for (k = 1; k <= ns; k++) {
            split(sp[k], kv, ":")
            base[k] = kv[1] + 0; blk[k] = kv[2] + 0
        }
        n = 0
        while ((getline line < ef) > 0) {
            if (line == "") continue
            n++
            split(line, f, "|")
            eid[n] = f[1]; ekind[n] = f[2]; eproto[n] = f[3]
            eip[n] = f[4]; eport[n] = f[5]
        }
        close(ef)
    }
    {
        proto = ""
        for (i = 1; i <= NF; i++) {
            if ($i == "tcp") proto = "tcp"
            else if ($i == "udp") proto = "udp"
        }
        if (proto == "") next
        t = 0
        osrc = ""; odst = ""; odport = ""; ob = 0
        rsrc = ""; rsport = ""; rb = 0
        for (i = 1; i <= NF; i++) {
            if (index($i, "src=") == 1) {
                t++
                if (t == 1) osrc = substr($i, 5)
                else if (t == 2) rsrc = substr($i, 5)
            } else if (index($i, "dst=") == 1) {
                if (t == 1 && odst == "") odst = substr($i, 5)
            } else if (index($i, "dport=") == 1) {
                if (t == 1 && odport == "") odport = substr($i, 7)
            } else if (index($i, "sport=") == 1) {
                if (t == 2 && rsport == "") rsport = substr($i, 7)
            } else if (index($i, "bytes=") == 1) {
                if (t == 1) ob = substr($i, 7) + 0
                else if (t == 2) rb = substr($i, 7) + 0
            }
        }
        if (osrc == "" || rsrc == "") next
        for (k = 1; k <= n; k++) {
            if (index(eproto[k], proto) == 0) continue
            if (ekind[k] == "forward") {
                if (rsrc != eip[k]) continue
                if (!port_in(rsport, eport[k])) continue
                if (odst == rsrc) continue      # LAN-direct, not DNATed
            } else {
                if (rsrc != odst) continue      # NATed => not router-local
                if (!port_in(odport, eport[k])) continue
                if (is_internal(osrc)) continue # LAN client, not inbound
            }
            conns[k]++
            bin[k] += ob
            bout[k] += rb
            if (!((k, osrc) in seen)) { seen[k, osrc] = 1; clients[k]++ }
            break
        }
    }
    END {
        for (k = 1; k <= n; k++)
            printf "%s %d %d %d %d\n", eid[k], conns[k]+0, clients[k]+0, bin[k]+0, bout[k]+0
    }' "${TCTL_CT_FILE:-/proc/net/nf_conntrack}" 2>/dev/null)
    rm -f "$ENTRY_FILE"

    # Emit JSON
    printf '['
    local first=1 id kind protos ip port extport ename en zone
    local st conns clients b_in b_out paused limit_kbit cmt_ip p
    printf '%s' "$entries" | while IFS='|' read -r id kind protos ip port extport ename en zone; do
        [ -z "$id" ] && continue
        # shellcheck disable=SC2046 # deliberate split of stats fields
        set -- $(printf '%s\n' "$STATS" | awk -v id="$id" '$1==id{print $2,$3,$4,$5; exit}')
        conns="${1:-0}"; clients="${2:-0}"; b_in="${3:-0}"; b_out="${4:-0}"

        cmt_ip="$ip"
        [ "$kind" = "open" ] && cmt_ip="local"
        paused=false
        limit_kbit=0
        for p in $protos; do
            printf '%s' "$CTL_DUMP" | grep -q "$(pfw_comment pause "$p" "$cmt_ip" "$port")" && paused=true
            if [ "$limit_kbit" = "0" ]; then
                st=$(printf '%s' "$CTL_DUMP" | grep "$(pfw_comment limit "$p" "$cmt_ip" "$port")" | \
                     awk "$TCTL_NFT_RATE_AWK"'{ for (i = 1; i < NF - 1; i++) if ($i == "over") { printf "%.0f\n", tctl_rate_kbit($(i+1), $(i+2)); exit } }')
                [ -z "$st" ] && st=$(printf '%s' "$CTL_DUMP" | grep "$(pfw_comment limit "$p" "$cmt_ip" "$port")" | \
                     awk "$TCTL_NFT_RATE_AWK"'{ r = tctl_ipt_first_rate(); if (r >= 0) { print r; exit } }')
                [ -n "$st" ] && limit_kbit="$st"
            fi
        done

        if [ "$first" = "1" ]; then first=0; else printf ','; fi
        printf '{"id":"%s","kind":"%s","name":"%s","zone":"%s","proto":"%s","ext_port":"%s","ip":"%s","port":"%s","enabled":%s,"paused":%s,"limit_kbit":%d,"conns":%d,"clients":%d,"bytes_in":%.0f,"bytes_out":%.0f}' \
            "$id" "$kind" "$ename" "$zone" "$protos" "$extport" "$ip" "$port" \
            "$([ "$en" != "0" ] && echo true || echo false)" \
            "$paused" "$limit_kbit" "$conns" "$clients" "$b_in" "$b_out"
    done
    printf ']\n'
}

# ── control actions ─────────────────────────────────────────────────────────

check_args() {
    # scope proto ip port
    case "$1" in forward|input) ;; *) return 1 ;; esac
    proto_tokens "$2" >/dev/null || return 1
    if [ "$1" = "forward" ]; then
        tctl_validate_ip "$3" || return 1
    fi
    valid_port "$4" || return 1
    return 0
}

do_pause() {
    local scope="$1" proto="$2" ip="$3" port="$4" p cmt_ip
    cmt_ip="$ip"
    [ "$scope" = "input" ] && cmt_ip="local"
    for p in $(proto_tokens "$proto"); do
        pfw_delete_by_comment "$(pfw_comment pause "$p" "$cmt_ip" "$port")"
        pfw_add_pause "$scope" "$p" "$ip" "$port" || {
            echo "{\"ok\":false,\"msg\":\"failed to pause $p port $port\"}"
            return 1
        }
        pfw_flush_conntrack "$p" "$([ "$scope" = "input" ] && echo "-" || echo "$ip")" "$port"
    done
    tctl_persist_enabled && tctl_persist_save "pfw_pause" "${scope}/${proto}/${cmt_ip}/${port}" "1"
    tctl_log "block" "pfw:${cmt_ip}:${port}" "pause ${proto}" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
    echo "{\"ok\":true,\"msg\":\"paused ${proto} port ${port}\"}"
}

do_resume() {
    local scope="$1" proto="$2" ip="$3" port="$4" p cmt_ip
    cmt_ip="$ip"
    [ "$scope" = "input" ] && cmt_ip="local"
    for p in $(proto_tokens "$proto"); do
        pfw_delete_by_comment "$(pfw_comment pause "$p" "$cmt_ip" "$port")"
    done
    tctl_persist_enabled && tctl_persist_remove "pfw_pause" "${scope}/${proto}/${cmt_ip}/${port}"
    tctl_log "unblock" "pfw:${cmt_ip}:${port}" "resume ${proto}" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
    echo "{\"ok\":true,\"msg\":\"resumed ${proto} port ${port}\"}"
}

do_limit() {
    local scope="$1" proto="$2" ip="$3" port="$4" kbit="$5" p cmt_ip
    case "$kbit" in ''|*[!0-9]*)
        echo '{"ok":false,"msg":"invalid rate"}'
        return 1
    esac
    cmt_ip="$ip"
    [ "$scope" = "input" ] && cmt_ip="local"
    for p in $(proto_tokens "$proto"); do
        pfw_delete_by_comment "$(pfw_comment limit "$p" "$cmt_ip" "$port")"
        if [ "$kbit" != "0" ]; then
            pfw_add_limit "$scope" "$p" "$ip" "$port" "$kbit" || {
                echo "{\"ok\":false,\"msg\":\"failed to limit $p port $port\"}"
                return 1
            }
        fi
    done
    if [ "$kbit" = "0" ]; then
        tctl_persist_enabled && tctl_persist_remove "pfw_limit" "${scope}/${proto}/${cmt_ip}/${port}"
        tctl_log "ratelimit_remove" "pfw:${cmt_ip}:${port}" "" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
        echo "{\"ok\":true,\"msg\":\"limit removed for port ${port}\"}"
    else
        tctl_persist_enabled && tctl_persist_save "pfw_limit" "${scope}/${proto}/${cmt_ip}/${port}" "$kbit"
        tctl_log "ratelimit_set" "pfw:${cmt_ip}:${port}" "${kbit}kbit" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
        echo "{\"ok\":true,\"msg\":\"limit ${kbit} kbit/s set for port ${port}\"}"
    fi
}

# ── main ────────────────────────────────────────────────────────────────────

ACTION="$1"
case "$ACTION" in
    list)
        do_list
        ;;
    pause|resume)
        if ! check_args "$2" "$3" "$4" "$5"; then
            echo '{"ok":false,"msg":"usage: trafficctl-portfw.sh pause|resume <forward|input> <tcp|udp|tcpudp> <ip|-> <port>"}'
            exit 1
        fi
        "do_$ACTION" "$2" "$3" "$4" "$5"
        ;;
    limit)
        if ! check_args "$2" "$3" "$4" "$5"; then
            echo '{"ok":false,"msg":"usage: trafficctl-portfw.sh limit <forward|input> <tcp|udp|tcpudp> <ip|-> <port> <rate_kbit>"}'
            exit 1
        fi
        do_limit "$2" "$3" "$4" "$5" "$6"
        ;;
    *)
        echo '{"ok":false,"msg":"usage: trafficctl-portfw.sh <list|pause|resume|limit> ..."}'
        exit 1
        ;;
esac
