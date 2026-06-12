#!/usr/bin/env ash
# lib/conntrack.sh — Parse /proc/net/nf_conntrack, correlate with NSS state
# NSS-Switch — ASH compatible, BusyBox v1.37+
# ct_dump_all_full migrado a C, cambio en rendimiento brutal

. "$SELF_DIR/lib/chandler.sh"
CONNTRACK_FILE=/proc/net/nf_conntrack
# ─── Check conntrack available ────────────────────────────────────────────────
ct_check() {
    [ -f "$CONNTRACK_FILE" ] || { ui_error "conntrack not available"; return 1; }
}
# ─── IP to decimal ────────────────────────────────────────────────────────────
_ip_to_dec() {
    local ip="$1"
    local a b c d
    a=$(echo "$ip" | cut -d'.' -f1)
    b=$(echo "$ip" | cut -d'.' -f2)
    c=$(echo "$ip" | cut -d'.' -f3)
    d=$(echo "$ip" | cut -d'.' -f4)
    echo $(( (a<<24) + (b<<16) + (c<<8) + d ))
}
# ─── Check if IP is in CIDR ───────────────────────────────────────────────────
_ct_ip_in_cidr() {
    local ip="$1" cidr="$2"
    local net prefix
    net=$(echo "$cidr" | cut -d'/' -f1)
    prefix=$(echo "$cidr" | cut -d'/' -f2)
    local ip_dec net_dec mask_dec
    ip_dec=$(_ip_to_dec "$ip")
    net_dec=$(_ip_to_dec "$net")
    if [ "$prefix" -eq 0 ]; then
        mask_dec=0
    else
        mask_dec=$(( ( (1<<31) | ( (1<<31)-1 ) ) ^ ( (1<<(32-prefix))-1 ) ))
    fi
    [ $(( ip_dec & mask_dec )) -eq $(( net_dec & mask_dec )) ]
}

# ─── Build interface map from ip addr show ────────────────────────────────────
# Writes to a tmpfile: "ip cidr iface" per line
_ct_build_iface_map() {
    local tmpfile="$1"
    ip addr show 2>/dev/null | awk '
        /^[0-9]+: / { iface=$2; gsub(/:$/,"",iface) }
        /inet / {
            if ($0 ~ /peer/) {
                print $2, $2"/32", iface
            } else {
                split($2, a, "/")
                print a[1], $2, iface
            }
        }
    ' > "$tmpfile"
}
# ─── Normalizar nombres de interfaz para mostrar ──────────────────────────────
_normalize_iface_display() {
    local iface="$1"
    case "$iface" in
        local:pppoe-wan|pppoe-wan)
            echo "wan"
            ;;
        local:br-lan|br-lan)
            echo "lan"
            ;;
        local:lo|lo)
            echo "lo"
            ;;
        local:lan2|lan2)
            echo "lan2"
            ;;
        local:lan3|lan3)
            echo "lan3"
            ;;
        wan.20|wan)
            echo "wan"
            ;;
        wan_6)
            echo "wan6"
            ;;
        ?)
            echo "?"
            ;;
        *)
            echo "$iface"
            ;;
    esac
}
# ─── Normalizar nombres de interfaz para reglas (nftables) ────────────────────
_normalize_iface_rule() {
    local iface="$1"
    case "$iface" in
        *:*) iface="${iface#*:}" ;;
    esac
    [ -z "$iface" ] && echo "any" && return

    echo "$iface"
}

# ─── Compress IPv6 address RFC 5952 ──────────────────────────────────────────
_ipv6_compress() {
    echo "$1" | awk '{
        split($0, a, ":")
        for(i=1;i<=8;i++) {
            gsub(/^0+/,"",a[i])
            if(a[i]=="") a[i]="0"
        }
        max_len=0; max_start=0; cur_len=0; cur_start=0
        for(i=1;i<=8;i++) {
            if(a[i]=="0") {
                if(cur_len==0) cur_start=i
                cur_len++
                if(cur_len>max_len) { max_len=cur_len; max_start=cur_start }
            } else { cur_len=0 }
        }
        result=""
        i=1
        while(i<=8) {
            if(max_len>1 && i==max_start) {
                if(i==1) result="::"
                else result=result"::"
                i+=max_len
            } else {
                if(result!="" && substr(result,length(result),1)!=":") result=result":"
                result=result a[i]
                i++
            }
        }
        print result
    }'
}

# ─── Get interface for a src IP ───────────────────────────────────────────────
# Returns: iface name, "local:iface" for router-own IPs, or "?"
ct_iface_for_src() {
    local src="$1"
    local found=""
    if echo "$src" | grep -q ":"; then
        local dev
        dev=$(ip -6 route get "$src" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')
        if [ -z "$dev" ] || [ "$dev" = "lo" ]; then
            local own_iface
            own_iface=$(ip -6 addr show 2>/dev/null | awk -v src="$src" '
                /^[0-9]+: / { iface=$2; gsub(/:$/,"",iface) }
                /inet6 / {
                    split($2, a, "/")
                    if(a[1]==src) print iface
                }
            ')
            [ -n "$own_iface" ] && echo "local:$own_iface" || echo "local:pppoe-wan"
        else
            echo "$dev"
        fi
        return
    fi
    local tmp
    tmp=$(mktemp /tmp/nss-iface.XXXXXX)
    _ct_build_iface_map "$tmp"
    while IFS=' ' read -r ip cidr iface; do
        if [ "$src" = "$ip" ]; then
            rm -f "$tmp"
            echo "local:$iface"
            return
        fi
        if _ct_ip_in_cidr "$src" "$cidr" 2>/dev/null; then
            found="$iface"
        fi
    done < "$tmp"
    rm -f "$tmp"
    [ -n "$found" ] && echo "$found" && return
    echo "?"
}

# ─── Parse one conntrack line into variables ──────────────────────────────────
# Sets: CT_PROTO CT_SRC CT_SPORT CT_DST CT_DPORT CT_MARK CT_STATE CT_STATUS
ct_parse_line() {
    local line="$1"
    CT_PROTO=""
    CT_SRC="" CT_SPORT="" CT_DST="" CT_DPORT=""
    CT_MARK=0 CT_STATE="" CT_STATUS=""
    CT_PROTO=$(echo "$line" | awk '{print $3}')
    case "$CT_PROTO" in
        tcp|6)   CT_STATE=$(echo "$line" | awk '{print $4}') ;;
        udp|17)  CT_STATE="stateless" ;;
        *)       CT_STATE="?" ;;
    esac
    CT_SRC=$(echo "$line"   | grep -oE 'src=[^ ]+' | head -1 | cut -d= -f2)
    CT_DST=$(echo "$line"   | grep -oE 'dst=[^ ]+' | head -1 | cut -d= -f2)
    CT_SPORT=$(echo "$line" | grep -oE 'sport=[^ ]+' | head -1 | cut -d= -f2)
    CT_DPORT=$(echo "$line" | grep -oE 'dport=[^ ]+' | head -1 | cut -d= -f2)
    CT_MARK=$(echo "$line"  | grep -oE 'mark=[^ ]+' | head -1 | cut -d= -f2)
    CT_STATUS=$(echo "$line"| grep -oE 'status=[^ ]+' | head -1 | cut -d= -f2)
    CT_SPORT="${CT_SPORT:-?}"
    CT_DPORT="${CT_DPORT:-?}"
    CT_MARK="${CT_MARK:-0}"
}

# ─── Check if mark has our NSS bypass bit set ─────────────────────────────────
ct_is_bypassed() {
    local mark="$1"
    local mark_dec nss_dec
    mark_dec=$(printf '%d' "$mark" 2>/dev/null) || mark_dec=0
    nss_dec=$(printf '%d' "$NSS_MARK" 2>/dev/null) || nss_dec=65536
    [ $(( mark_dec & nss_dec )) -ne 0 ]
}

# ─── Determine NSS status for a connection ────────────────────────────────────
ct_nss_status() {
    local mark="$1"
    if ct_is_bypassed "$mark"; then
        echo "CPU"
        return
    fi
    if [ -d "$ECM_DEBUGFS/ecm_nss_ipv4" ]; then
        echo "HW"
    elif [ -d "$ECM_DEBUGFS/ecm_sfe_ipv4" ]; then
        echo "SFE"
    else
        echo "CPU"
    fi
}


# ─── Dump ALL connections including router-local ──────────────────────────────
ct_dump_all_full() {

    if [ "$HAS_CT_DUMP" = "yes" ]; then
        "$BIN_DIR/nss-ct-dump"
    else
        _ct_dump_all_full_shell
    fi
}
_ct_dump_all_full_shell() {

    ct_check || return 1

    local num=0
    while IFS= read -r line; do
        ct_parse_line "$line"
        [ -z "$CT_SRC" ] && continue
        local iface
        iface=$(ct_iface_for_src "$CT_SRC")
        [ -z "$iface" ] && iface="?"
        iface=$(_normalize_iface_display "$iface")
        num=$((num+1))
        local nss_status bypassed
        nss_status=$(ct_nss_status "$CT_MARK")
        bypassed="NO"
        ct_is_bypassed "$CT_MARK" && bypassed="YES"
        local display_src display_dst
        if echo "$CT_SRC" | grep -q ":"; then
            display_src=$(_ipv6_compress "$CT_SRC")
        else
            display_src="$CT_SRC"
        fi
        if echo "$CT_DST" | grep -q ":"; then
            display_dst=$(_ipv6_compress "$CT_DST")
        else
            display_dst="$CT_DST"
        fi
        printf "%d|%s|%s#%s|%s#%s|%s|%s|%s|%s|%s\n" \
            "$num" "$CT_PROTO" \
            "$display_src" "$CT_SPORT" \
            "$display_dst" "$CT_DPORT" \
            "$iface" "$nss_status" "$bypassed" \
            "$CT_MARK" "$CT_STATE"
    done < "$CONNTRACK_FILE"

}

# ─── Get single connection by NUM ─────────────────────────────────────────────
ct_get_by_num() {
    local target="$1"
    ct_dump_all_full | awk -F'|' -v n="$target" '$1==n {print; exit}'
}

# ─── Count total connections ──────────────────────────────────────────────────
ct_count() {
    wc -l < "$CONNTRACK_FILE" 2>/dev/null || echo 0
}

# ─── Count bypassed connections ───────────────────────────────────────────────
ct_count_bypassed() {
    local nss_dec
    nss_dec=$(printf '%d' "$NSS_MARK" 2>/dev/null) || nss_dec=65536
    local count=0
    while IFS= read -r line; do
        local mark mark_dec
        mark=$(echo "$line" | grep -oE 'mark=[^ ]+' | head -1 | cut -d= -f2)
        mark_dec=$(printf '%d' "${mark:-0}" 2>/dev/null) || mark_dec=0
        [ $(( mark_dec & nss_dec )) -ne 0 ] && count=$((count+1))
    done < "$CONNTRACK_FILE"
    echo "$count"
}

# ─── Clear conntrack entries matching rule criteria ───────────────────────────
ct_clear_rule_marks() {
    local proto="$1" src_ip="$2" dst_ip="$3"
    local sport="$4" dport="$5" iface="$6"
    dbg "Flushing connections for rule: proto=$proto src=$src_ip dst=$dst_ip sport=$sport dport=$dport iface=$iface"
    local filter=""
    [ "$proto"  != "any" ] && filter="$filter -p $proto"
    if [ "$src_ip" != "any" ] && [ "$dst_ip" != "any" ]; then
        filter="$filter -s $src_ip -d $dst_ip"
    elif [ "$src_ip" != "any" ]; then
        filter="$filter -s $src_ip"
    elif [ "$dst_ip" != "any" ]; then
        filter="$filter -d $dst_ip"
    fi
    if [ "$sport" != "any" ] && [ "$dport" != "any" ]; then
        filter="$filter --sport $sport --dport $dport"
    elif [ "$sport" != "any" ]; then
        filter="$filter --sport $sport"
    elif [ "$dport" != "any" ]; then
        filter="$filter --dport $dport"
    fi
    local src_net=""
    if [ "$iface" != "any" ] && [ "$src_ip" = "any" ]; then
        case "$iface" in
            out:*)
                local out_iface="${iface#out:}"
                src_net=$(ip addr show "$out_iface" 2>/dev/null | \
                        grep -E 'inet |inet6 ' | head -1 | awk '{print $2}')
                ;;
            *)
                src_net=$(ip route show dev "$iface" 2>/dev/null | \
                        grep -v default | head -1 | awk '{print $1}')
                ;;
        esac
        [ -n "$src_net" ] && filter="$filter -s $src_net"
    fi
    if [ -n "$filter" ]; then
        dbg "conntrack -D $filter"
        conntrack -D $filter 2>/dev/null
        ui_ok "Matching conntrack entries flushed"
    else
        ui_warn "Rule matches ALL connections - flushing entire conntrack"
        conntrack -F 2>/dev/null
        ui_ok "All conntrack entries flushed"
    fi
    ecm_defunct_all
}

# ─── Debug: show conntrack entries with our mark ─────────────────────────────
ct_debug_mark() {
    ui_section "Conntrack entries with NSS-Switch mark ($NSS_MARK)"
    local found=0
    while IFS= read -r line; do
        local mark mark_dec nss_dec
        mark=$(echo "$line" | grep -oE 'mark=[^ ]+' | head -1 | cut -d= -f2)
        mark_dec=$(printf '%d' "${mark:-0}" 2>/dev/null) || mark_dec=0
        nss_dec=$(printf '%d' "$NSS_MARK" 2>/dev/null) || nss_dec=65536
        if [ $(( mark_dec & nss_dec )) -ne 0 ]; then
            echo "  $line"
            found=$((found+1))
        fi
    done < "$CONNTRACK_FILE"
    [ "$found" -eq 0 ] && ui_warn "No entries with our mark found"
    ui_kv "Total bypassed" "$found"
}

# ─── Debug: dump raw conntrack ────────────────────────────────────────────────
ct_debug_raw() {
    ui_section "Raw /proc/net/nf_conntrack"
    cat "$CONNTRACK_FILE" 2>/dev/null || ui_error "Cannot read conntrack"
}
