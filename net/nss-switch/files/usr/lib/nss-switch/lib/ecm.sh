#!/usr/bin/env ash
# lib/ecm.sh — ECM / NSS / SFE / MTK-PPE / SW-FlowOffload interaction via debugfs
# NSS-Switch — ASH compatible, BusyBox v1.37+
#
# Compatibnle engines:
#   NSS      - Qualcomm NSS under ECM (kmod-qca-nss-ecm)
#   SFE_ECM  - Qualcomm SFE as ECM frontend (ecm + shortcut-fe)
#   SFE      - Qualcomm SFE standalone (no ECM layer, /dev/sfe)
#   MTK_PPE  - MediaTek PPE/HNAT (mt7621/mt7622/mt7986/mt7988)
#   SW_FLOW  - Linux nf_flow_table software flow offload (nft flowtable)
#   NONE     - No offload detected

# ─── Internal cache ───────────────────────────────────────────────────────────
_ECM_OFFLOAD_ENGINE=""

# ─── Detect active offload engine (result is cached) ─────────────────────────
offload_detect() {
    if [ -n "$_ECM_OFFLOAD_ENGINE" ]; then
        echo "$_ECM_OFFLOAD_ENGINE"
        return 0
    fi

    local engine="NONE"

    # 1, NSS      - Qualcomm NSS under ECM (kmod-qca-nss-ecm)
    if [ -d "$ECM_DEBUGFS/ecm_nss_ipv4" ]; then
        engine="NSS"

    # 2. SFE_ECM  - Qualcomm SFE as ECM frontend (ecm + shortcut-fe)
    elif [ -d "$ECM_DEBUGFS/ecm_sfe_ipv4" ]; then
        engine="SFE_ECM"

    # 3. SFE      - Qualcomm SFE standalone (no ECM layer, /dev/sfe)
    elif [ -c /dev/sfe ] || lsmod 2>/dev/null | grep -q "^shortcut_fe"; then
        engine="SFE"

    # 4. MTK_PPE  - MediaTek PPE/HNAT (mt7621/mt7622/mt7986/mt7988)
    elif [ -d /sys/kernel/debug/ppe0 ]; then
        engine="MTK_PPE"

    # 5. SW_FLOW  - Linux nf_flow_table software flow offload (nft flowtable)
    elif lsmod 2>/dev/null | grep -q "^nf_flow_table"; then
        engine="SW_FLOW"
    fi

    _ECM_OFFLOAD_ENGINE="$engine"
    dbg "offload_detect: $engine"
    echo "$engine"
}

# ─── Check offload is loaded and usable ───────────────────────────────────────
ecm_check() {
    # NEDDED for NSS, SFE_ECM, MTK_PPE
    if ! mount | grep -q debugfs; then
        dbg "debugfs not mounted, attempting mount"
        mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null || true
    fi

    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            if [ ! -d "$ECM_DEBUGFS" ]; then
                ui_error "ECM debugfs not found at $ECM_DEBUGFS"
                ui_error "Is kmod-qca-nss-ecm loaded?"
                return 1
            fi
            ;;
        SFE)
            if ! [ -c /dev/sfe ] && ! lsmod 2>/dev/null | grep -q "^shortcut_fe"; then
                ui_error "SFE standalone: module not loaded and /dev/sfe missing"
                return 1
            fi
            ;;
        MTK_PPE)
            if [ ! -d /sys/kernel/debug/ppe0 ]; then
                ui_error "MTK PPE: /sys/kernel/debug/ppe0 not found"
                return 1
            fi
            ;;
        SW_FLOW)
            if ! lsmod 2>/dev/null | grep -q "^nf_flow_table"; then
                ui_error "SW flow offload: nf_flow_table module not loaded"
                return 1
            fi
            ;;
        NONE)
            ui_error "No hardware or software offload engine detected!"
            return 1
            ;;
    esac

    dbg "ecm_check: OK (engine=$engine)"
    return 0
}

# ─── Check Mark Classifier is available ───────────────────────────────────────
# ONLY NSS
ecm_mark_classifier_available() {
    [ -d "$ECM_DEBUGFS/ecm_classifier_mark" ]
}

# ─── Get current frontend  ────────────────────────────────────────────────────
ecm_frontend() {
    local engine
    engine=$(offload_detect)
    case "$engine" in
        NSS)     echo "NSS"     ;;
        SFE_ECM) echo "SFE"     ;;
        SFE)     echo "SFE"     ;;
        MTK_PPE) echo "MTK_PPE" ;;
        SW_FLOW) echo "SW_FLOW" ;;
        *)       echo "UNKNOWN"; return 1 ;;
    esac
    return 0
}

# ─── Get acceleration engine from UCI ─────────────────────────────────────────
ecm_engine() {
    local engine
    engine=$(grep -A2 "config ecm 'global'" /etc/config/ecm 2>/dev/null | \
             grep "acceleration_engine" | \
             awk '{print $3}' | tr -d "'")
    echo "${engine:-auto}"
}

# ─── Stop IPv4 frontend ────────────────────────────────────────────────────────
ecm_stop_ipv4() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/front_end_ipv4_stop"
            if [ ! -f "$f" ]; then
                ui_error "front_end_ipv4_stop not found"
                return 1
            fi
            dbg "Writing 1 to $f"
            echo 1 > "$f" 2>/dev/null
            ui_ok "ECM IPv4 frontend stopped"
            ;;
        SFE|MTK_PPE|SW_FLOW)
            # No per-protocol stop API: flush IPv4 conntrack so connections exit offload
            dbg "$engine: flushing IPv4 conntrack"
            conntrack -F -f ipv4 2>/dev/null
            ui_ok "$engine: IPv4 connections flushed (will re-accelerate on demand)"
            ;;
        *)
            ui_error "No offload engine detected"
            return 1
            ;;
    esac
    return 0
}

# ─── Stop IPv6 frontend ────────────────────────────────────────────────────────
ecm_stop_ipv6() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/front_end_ipv6_stop"
            if [ ! -f "$f" ]; then
                ui_error "front_end_ipv6_stop not found"
                return 1
            fi
            dbg "Writing 1 to $f"
            echo 1 > "$f" 2>/dev/null
            ui_ok "ECM IPv6 frontend stopped"
            ;;
        SFE|MTK_PPE|SW_FLOW)
            dbg "$engine: flushing IPv6 conntrack"
            conntrack -F -f ipv6 2>/dev/null
            ui_ok "$engine: IPv6 connections flushed (will re-accelerate on demand)"
            ;;
        *)
            ui_error "No offload engine detected"
            return 1
            ;;
    esac
    return 0
}

# ─── Restart offload service ───────────────────────────────────────────────────
ecm_restart() {
    local engine
    engine=$(offload_detect)
    _ECM_OFFLOAD_ENGINE=""

    case "$engine" in
        NSS)
            if [ -f /etc/init.d/qca-nss-ecm ]; then
                dbg "Restarting qca-nss-ecm"
                /etc/init.d/qca-nss-ecm restart 2>/dev/null
            else
                dbg "qca-nss-ecm init script not found"
            fi
            ;;
        SFE_ECM)
            if [ -f /etc/init.d/sfe-ecm ]; then
                dbg "Restarting sfe-ecm"
                /etc/init.d/sfe-ecm restart 2>/dev/null
            elif [ -f /etc/init.d/ecm ]; then
                dbg "Restarting ecm"
                /etc/init.d/ecm restart 2>/dev/null
            else
                dbg "No SFE_ECM init script found"
            fi
            ;;
        SFE)
            # Standalone SFE: reload kernel module
            dbg "Reloading shortcut_fe module"
            rmmod shortcut_fe 2>/dev/null
            modprobe shortcut_fe 2>/dev/null
            ;;
        MTK_PPE)
            # PPE is embedded in the Ethernet driver; restart via firewall
            dbg "MTK PPE: restarting firewall to re-init PPE bindings"
            conntrack -F
            # DEBUG: if defunct does NOT work for PPE, will try restarting fw:
            # /etc/init.d/firewall restart 2>/dev/null
            ;;
        SW_FLOW)
            dbg "SW_FLOW: restarting firewall"
            # DEBUG: Mandatory restarting
            /etc/init.d/firewall restart 2>/dev/null
            ;;
        *)
            dbg "No offload service found to restart"
            ;;
    esac
    return 0
}

# ─── Defunct ALL connections ───────────────────────────────────────────────────
ecm_defunct_all() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/ecm_db/defunct_all"
            if [ ! -f "$f" ]; then
                ui_error "defunct_all not found at $f"
                return 1
            fi
            dbg "Writing 1 to defunct_all"
            echo 1 > "$f" 2>/dev/null
            ui_ok "All ECM connections defuncted (will be re-evaluated)"
            ;;
        SFE|MTK_PPE|SW_FLOW)
            dbg "$engine: flushing all conntrack entries"
            conntrack -F 2>/dev/null
            ui_ok "$engine: all connections flushed (will re-accelerate on demand)"
            ;;
        *)
            ui_error "No offload engine detected"
            return 1
            ;;
    esac
    return 0
}

# ─── Defunct connections by port ──────────────────────────────────────────────
ecm_defunct_by_port() {
    local port="$1"
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/ecm_db/defunct_by_port"
            if [ -f "$f" ]; then
                dbg "defunct_by_port: $port"
                echo "$port" > "$f" 2>/dev/null
                ui_ok "ECM connections on port $port defuncted"
            else
                dbg "defunct_by_port not available, falling back to defunct_all"
                ecm_defunct_all
            fi
            ;;
        SFE|MTK_PPE|SW_FLOW)
            dbg "$engine: flushing conntrack for port $port"
            conntrack -D -p tcp --dport "$port" 2>/dev/null
            conntrack -D -p udp --dport "$port" 2>/dev/null
            conntrack -D -p tcp --sport "$port" 2>/dev/null
            conntrack -D -p udp --sport "$port" 2>/dev/null
            ui_ok "$engine: connections on port $port flushed"
            ;;
        *)
            ui_error "No offload engine detected"
            return 1
            ;;
    esac
    return 0
}

# ─── Get connection list ───────────────────────────────────────────────────────
ecm_connections() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local dump_bin
            dump_bin=$(command -v ecm_dump.sh 2>/dev/null)
            if [ -z "$dump_bin" ]; then
                dbg "ecm_dump.sh not found"
                return 1
            fi
            # Real ecm_dump.sh output is key=value, grouped by connection index:
            #   conns.conn.N.sip_address=...  conns.conn.N.protocol=6  etc.
            # Connection boundary = index N changes.
            # accel_mode: 0=CPU  1=PENDING  2=accelerated (NSS or SFE)
            ecm_dump.sh 2>/dev/null | awk -F= '
                function emit() {
                    ps = (proto=="6")?"tcp":(proto=="17")?"udp":proto
                    as = (am=="2")?"NSS":(am=="1")?"PENDING":"CPU"
                    print ps"|"src"|"sport"|"dst"|"dport"|"as
                }
                /^conns\.conn\.[0-9]+\./ {
                    split($1, p, ".")
                    n = p[3]
                    if (n != cur) {
                        if (cur != "") emit()
                        proto="?"; src="?"; sport="?"; dst="?"; dport="?"; am="0"
                        cur = n
                    }
                    key = $1; sub(/^conns\.conn\.[0-9]+\./, "", key)
                    val = $2
                    if      (key == "protocol")              proto = val
                    else if (key == "sip_address")           src   = val
                    else if (key == "sport")                 sport = val
                    else if (key == "dip_address")           dst   = val
                    else if (key == "dport")                 dport = val
                    else if (key ~ /\.ported\.accel_mode$/)  am    = val
                }
                END { if (cur != "") emit() }
            '
            ;;
        SFE)
            # /dev/sfe outputs XML-ish per-connection data
            if [ ! -c /dev/sfe ]; then
                dbg "/dev/sfe not found"
                return 1
            fi
            # /dev/sfe is XML-ish; use 2-arg match + RSTART/RLENGTH
            cat /dev/sfe 2>/dev/null | awk '
                function xtag(tag,    pat) {
                    pat = "<" tag ">[^<]+"
                    if (match($0, pat))
                        return substr($0, RSTART+length(tag)+2, RLENGTH-length(tag)-2)
                    return "?"
                }
                /<connection>/  { in_c=1; proto="?"; src="?"; sport="?"; dst="?"; dport="?" }
                /<\/connection>/{ if (in_c) print proto"|"src"|"sport"|"dst"|"dport"|""SFE""; in_c=0 }
                in_c && /<protocol>/ { proto = xtag("protocol") }
                in_c && /<src_ip>/   { src   = xtag("src_ip")   }
                in_c && /<src_port>/ { sport = xtag("src_port") }
                in_c && /<dest_ip>/  { dst   = xtag("dest_ip")  }
                in_c && /<dest_port>/{ dport = xtag("dest_port")}
            '
            ;;
        MTK_PPE)
            # PPE entries: one per line, BND = hardware-bound (actively offloaded)
            # Format: [idx] BND  proto src=IP:port dst=IP:port ...
            local f="/sys/kernel/debug/ppe0/entries"
            if [ ! -f "$f" ]; then
                dbg "ppe0/entries not found"
                return 1
            fi
            cat "$f" 2>/dev/null | awk '
                /BND/ {
                    proto="?"; src="?"; sport="?"; dst="?"; dport="?"
                    # proto=VALUE
                    if (match($0, /proto=[^ ]+/))
                        proto = substr($0, RSTART+6, RLENGTH-6)
                    # src=IP:port
                    if (match($0, /src=[^ ]+/)) {
                        pair = substr($0, RSTART+4, RLENGTH-4)
                        n = split(pair, a, ":"); src = a[1]
                        if (n > 1) sport = a[2]
                    }
                    # dst=IP:port
                    if (match($0, /dst=[^ ]+/)) {
                        pair = substr($0, RSTART+4, RLENGTH-4)
                        n = split(pair, a, ":"); dst = a[1]
                        if (n > 1) dport = a[2]
                    }
                    print proto"|"src"|"sport"|"dst"|"dport"|""HW_OFFLOAD""
                }
            '
            ;;
        SW_FLOW)
            # No flowtable-specific connection list exposed to userspace.
            # Use conntrack as proxy for established (potentially offloaded) flows.
            # Format: ipv4 2 tcp 6 TTL ESTABLISHED src=.. dst=.. sport=.. dport=..
            # nf_conntrack format: ipv4 2 tcp 6 TTL STATE src=.. dst=.. sport=.. dport=.. [reply] ...
            # $3 = proto name (tcp/udp/...), first src=/dst=/sport=/dport= = forward direction
            cat /proc/net/nf_conntrack 2>/dev/null | awk '
                {
                    proto=$3; src="?"; sport="?"; dst="?"; dport="?"
                    if (match($0, /src=[^ ]+/))   src   = substr($0, RSTART+4,  RLENGTH-4)
                    if (match($0, /dst=[^ ]+/))   dst   = substr($0, RSTART+4,  RLENGTH-4)
                    if (match($0, /sport=[^ ]+/)) sport = substr($0, RSTART+6,  RLENGTH-6)
                    if (match($0, /dport=[^ ]+/)) dport = substr($0, RSTART+6,  RLENGTH-6)
                    print proto"|"src"|"sport"|"dst"|"dport"|""SW_OFFLOAD""
                }
            '
            ;;
        *)
            dbg "No offload engine detected!"
            return 1
            ;;
    esac
}

# ─── Get stats summary ────────────────────────────────────────────────────────
ecm_stats() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/stats"
            if [ -f "$f" ]; then
                cat "$f"
                return 0
            fi
            ui_warn "No stats file found in ECM debugfs"
            return 1
            ;;
        SFE)
            if [ -c /dev/sfe ]; then
                cat /dev/sfe 2>/dev/null
                return 0
            fi
            ui_warn "SFE: /dev/sfe not available"
            return 1
            ;;
        MTK_PPE)
            if [ -f /sys/kernel/debug/ppe0/entries ]; then
                echo "=== PPE0 ==="
                cat /sys/kernel/debug/ppe0/entries 2>/dev/null
                # Dual-PPE SoCs (mt7986, mt7988)
                if [ -f /sys/kernel/debug/ppe1/entries ]; then
                    echo "=== PPE1 ==="
                    cat /sys/kernel/debug/ppe1/entries 2>/dev/null
                fi
                return 0
            fi
            ui_warn "MTK PPE: entries file not found"
            return 1
            ;;
        SW_FLOW)
            local total
            total=$(wc -l < /proc/net/nf_conntrack 2>/dev/null || echo 0)
            echo "Total conntrack entries: $total"
            if command -v nft >/dev/null 2>&1; then
                nft list flowtables 2>/dev/null || true
            fi
            return 0
            ;;
        *)
            ui_warn "No offload engine detected"
            return 1
            ;;
    esac
}

# ─── Check if a connection (by mark) is being bypassed ────────────────────────
ecm_is_bypassed_by_mark() {
    local src_ip="$1"
    cat /proc/net/nf_conntrack 2>/dev/null | \
        grep "src=$src_ip " | \
        grep -c "mark=$NSS_MARK" 2>/dev/null; true
}

# ─── Get accel_delay_pkts ─────────────────────────────────────────────────────
ecm_accel_delay_pkts() {
    local engine
    engine=$(offload_detect)

    case "$engine" in
        NSS|SFE_ECM)
            local f="$ECM_DEBUGFS/ecm_classifier_default/accel_delay_pkts"
            if [ -f "$f" ]; then
                cat "$f"
                return 0
            fi
            ;;
    esac
    echo "N/A (for MTK-PPP, SW Flow or SFE standalone)"
}

# ─── Full environment dump for debug ──────────────────────────────────────────
ecm_debug_dump() {
    local engine
    engine=$(offload_detect)

    ui_section "Offload Environment"
    ui_kv "Offload engine"    "$engine"
    ui_kv "Frontend (compat)" "$(ecm_frontend)"
    ui_kv "Engine (UCI)"      "$(ecm_engine)"
    ui_kv "accel_delay_pkts"  "$(ecm_accel_delay_pkts)"

    ui_section "Engine Details"
    case "$engine" in
        NSS|SFE_ECM)
            ui_kv "ECM debugfs"     "$ECM_DEBUGFS"
            ui_kv "ECM loaded"      "$([ -d "$ECM_DEBUGFS" ] && echo YES || echo NO)"
            ui_kv "Mark classifier" "$(ecm_mark_classifier_available && echo AVAILABLE || echo MISSING)"
            ui_kv "Debugfs dirs"    "$(ls "$ECM_DEBUGFS" 2>/dev/null | tr '\n' ' ')"
            if [ -d "$ECM_DEBUGFS/ecm_db" ]; then
                ui_section "ECM DB Files"
                ls -la "$ECM_DEBUGFS/ecm_db/" 2>/dev/null
            fi
            ui_section "ECM Stats (first 40 lines)"
            ecm_stats 2>/dev/null | head -40
            if [ "$engine" = "NSS" ] && ecm_mark_classifier_available; then
                ui_section "Mark Classifier State"
                ls -la "$ECM_DEBUGFS/ecm_classifier_mark/" 2>/dev/null
                for f in "$ECM_DEBUGFS/ecm_classifier_mark/"*; do
                    [ -f "$f" ] && printf "  %s = %s\n" "$(basename "$f")" "$(cat "$f" 2>/dev/null)"
                done
            fi
            ;;
        SFE)
            ui_kv "/dev/sfe"  "$([ -c /dev/sfe ] && echo PRESENT || echo MISSING)"
            ui_kv "Module"    "$(lsmod 2>/dev/null | grep "^shortcut_fe" | awk '{print $1" (size="$2")"}')"
            ui_section "SFE Stats (first 40 lines)"
            ecm_stats 2>/dev/null | head -40
            ;;
        MTK_PPE)
            local bound
            bound=$(grep -c "BND" /sys/kernel/debug/ppe0/entries 2>/dev/null || echo 0)
            ui_kv "PPE0 bound flows" "$bound"
            if [ -f /sys/kernel/debug/ppe1/entries ]; then
                bound=$(grep -c "BND" /sys/kernel/debug/ppe1/entries 2>/dev/null || echo 0)
                ui_kv "PPE1 bound flows" "$bound"
            fi
            ui_section "PPE0 Entries (first 40 lines)"
            cat /sys/kernel/debug/ppe0/entries 2>/dev/null | head -40
            ;;
        SW_FLOW)
            ui_kv "nf_flow_table" "$(lsmod 2>/dev/null | grep "^nf_flow_table" | awk '{print "loaded (size="$2")"}')"
            ui_kv "UCI config"    "$(grep -A5 'config defaults' /etc/config/firewall 2>/dev/null | \
                                     grep 'flow_offloading' | sed 's/^\s*//' | tr '\n' ' ')"
            ui_section "Active Flowtables"
            if command -v nft >/dev/null 2>&1; then
                nft list flowtables 2>/dev/null || ui_warn "nft: no flowtables found"
            else
                ui_warn "nft not available"
            fi
            ui_kv "Conntrack entries" "$(wc -l < /proc/net/nf_conntrack 2>/dev/null || echo 0)"
            ;;
        *)
            ui_warn "No offload engine detected"
            ;;
    esac
}
