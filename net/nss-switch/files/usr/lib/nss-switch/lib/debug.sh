#!/usr/bin/env ash
# lib/debug.sh - Real-time monitoring panel for NSS-Switch
# Usage: nss-switch debug monitor [interface]
DEBUG_SESSION_START=$(date +%Y%m%d_%H%M%S)
DEBUG_LOG_FILE="/tmp/nss-debug-${DEBUG_SESSION_START}.log"
MON_GREEN='\033[0;32m'
MON_RED='\033[0;31m'
MON_YELLOW='\033[0;33m'
MON_CYAN='\033[0;36m'
MON_BOLD='\033[1m'
MON_DIM='\033[2m'
MON_RESET='\033[0m'
PREV_FILE="/tmp/nss-debug-prev-$$"
RULES_SNAPSHOT="/tmp/nss-debug-rules-$$"
PID_FILE="/tmp/nss-debug-monitor.pid"
total_conn_prev=0
bypassed_prev=0
_debug_cleanup() {
    rm -f "$PREV_FILE" "$RULES_SNAPSHOT" "$PID_FILE" 2>/dev/null
    echo "[$(date '+%H:%M:%S')] Monitor stopped" >> "$DEBUG_LOG_FILE"
    exit 0
}
_format_bytes() {
    local bytes=$1
    [ -z "$bytes" ] && bytes=0

    if [ "$bytes" -ge 1073741824 ]; then
        echo "$((bytes / 1073741824))G"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$((bytes / 1048576))M"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$((bytes / 1024))K"
    else
        echo "${bytes}B"
    fi
}
_debug_init() {
    rm -f "$PREV_FILE" "$RULES_SNAPSHOT" 2>/dev/null
    for iface in lan2 lan3 br-lan pppoe-wan; do
        local stats=$(ip -s link show "$iface" 2>/dev/null)
        if [ -n "$stats" ]; then
            local rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
            local tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
            local rx_packets=$(echo "$stats" | awk '/RX:/{getline; print $2}')
            local tx_packets=$(echo "$stats" | awk '/TX:/{getline; print $2}')
            echo "${iface}_rx_pkts=$rx_packets" >> "$PREV_FILE"
            echo "${iface}_tx_pkts=$tx_packets" >> "$PREV_FILE"
            echo "${iface}_rx_bytes=$rx_bytes" >> "$PREV_FILE"
            echo "${iface}_tx_bytes=$tx_bytes" >> "$PREV_FILE"
        fi
    done
    nft list chain inet fw4 nss_bypass_pre 2>/dev/null | grep "comment \"NSS-Switch" > "$RULES_SNAPSHOT"
    echo "[$(date '+%H:%M:%S')] Monitor started" >> "$DEBUG_LOG_FILE"
}
_get_prev() {
    grep "^${1}=" "$PREV_FILE" 2>/dev/null | cut -d'=' -f2
}
_update_prev() {
    if grep -q "^${1}=" "$PREV_FILE" 2>/dev/null; then
        sed -i "s/^${1}=.*/${1}=${2}/" "$PREV_FILE"
    else
        echo "${1}=${2}" >> "$PREV_FILE"
    fi
}
_check_rule_changes() {
    local new_rules="/tmp/nss-debug-newrules-$$"
    nft list chain inet fw4 nss_bypass_pre 2>/dev/null | grep "comment \"NSS-Switch" > "$new_rules"

    if ! cmp -s "$RULES_SNAPSHOT" "$new_rules" 2>/dev/null; then
        local added=$(comm -13 "$RULES_SNAPSHOT" "$new_rules" 2>/dev/null | wc -l)
        local removed=$(comm -23 "$RULES_SNAPSHOT" "$new_rules" 2>/dev/null | wc -l)
        echo "[$(date '+%H:%M:%S')] RULES CHANGED: +$added -$removed" >> "$DEBUG_LOG_FILE"
        comm -13 "$RULES_SNAPSHOT" "$new_rules" 2>/dev/null | while read line; do
            local comment=$(echo "$line" | sed -n 's/.*comment "NSS-Switch id=\([0-9]\+\): \(.*\)".*/\1: \2/p')
            [ -n "$comment" ] && echo "[$(date '+%H:%M:%S')]   ADDED: $comment" >> "$DEBUG_LOG_FILE"
        done
        comm -23 "$RULES_SNAPSHOT" "$new_rules" 2>/dev/null | while read line; do
            local comment=$(echo "$line" | sed -n 's/.*comment "NSS-Switch id=\([0-9]\+\): \(.*\)".*/\1: \2/p')
            [ -n "$comment" ] && echo "[$(date '+%H:%M:%S')]   REMOVED: $comment" >> "$DEBUG_LOG_FILE"
        done
        cp "$new_rules" "$RULES_SNAPSHOT"
    fi
    rm -f "$new_rules"
}
cmd_debug_monitor() {
    local focus_iface="${1:-lan3}"
    command -v nss_stats >/dev/null 2>&1 || { echo "nss_stats not found"; return 1; }
    trap '_debug_cleanup; exit 0' INT TERM EXIT
    echo $$ > "$PID_FILE"
    echo -e "${MON_BOLD}Starting NSS-Switch Real-Time Monitor${MON_RESET}"
    echo "Log file: $DEBUG_LOG_FILE"
    echo "Focus interface: $focus_iface"
    echo -e "${MON_DIM}Press Ctrl+C to exit${MON_RESET}"
    _debug_init
    total_conn_prev=$(wc -l < /proc/net/nf_conntrack 2>/dev/null)
    bypassed_prev=$(ct_count_bypassed 2>/dev/null)
    while true; do
        clear

        # Banner
        echo -e "${MON_BOLD}${MON_CYAN}"
        echo "╔═══════════════════════════════════════════════════════════════════════════════════╗"
        echo "║                         NSS-Switch Real-Time Monitor                              ║"
        echo "╚═══════════════════════════════════════════════════════════════════════════════════╝"
        echo -e "${MON_RESET}"
        echo "  Session: $(basename "$DEBUG_LOG_FILE")"
        echo "  Time:    $(date '+%Y-%m-%d %H:%M:%S')"
        echo -e "  Focus:   ${focus_iface}"
        echo ""

        # === SECCIÓN 1: Resumen rápido con cambios ===
        echo -e "${MON_BOLD}${MON_CYAN}═══ 1. Quick Summary ═══${MON_RESET}"

        local total_conn=$(wc -l < /proc/net/nf_conntrack 2>/dev/null)
        local bypassed=$(ct_count_bypassed 2>/dev/null)
        local frontend=$(ecm_frontend 2>/dev/null)

        # Detectar cambios
        local conn_diff=$((total_conn - total_conn_prev))
        local bypass_diff=$((bypassed - bypassed_prev))

        printf "  %-25s %s" "Total connections:" "$total_conn"
        if [ "$conn_diff" -ne 0 ]; then
            echo -e " (${MON_GREEN}+$conn_diff${MON_RESET})"
            echo "[$(date '+%H:%M:%S')] CONN COUNT: $total_conn_prev → $total_conn ($([ $conn_diff -gt 0 ] && echo "+$conn_diff" || echo "$conn_diff"))" >> "$DEBUG_LOG_FILE"
        else
            echo ""
        fi

        printf "  %-25s %s" "Bypassed (CPU):" "$bypassed"
        if [ "$bypass_diff" -ne 0 ]; then
            echo -e " (${MON_GREEN}+$bypass_diff${MON_RESET})"
            echo "[$(date '+%H:%M:%S')] BYPASSED: $bypassed_prev → $bypassed ($([ $bypass_diff -gt 0 ] && echo "+$bypass_diff" || echo "$bypass_diff"))" >> "$DEBUG_LOG_FILE"
        else
            echo ""
        fi

        printf "  %-25s %s\n" "ECM Frontend:" "$frontend"
        echo ""

        # Actualizar previos
        total_conn_prev=$total_conn
        bypassed_prev=$bypassed

        # === SECCIÓN 2: Tráfico por interfaz (con KB/MB) ===
        echo -e "${MON_BOLD}${MON_CYAN}═══ 2. Interface Traffic (delta) ═══${MON_RESET}"
        echo -e "  ${MON_DIM}IFACE        RX_PKTS    RX_DATA    TX_PKTS    TX_DATA${MON_RESET}"

        for iface in lan2 lan3 br-lan pppoe-wan; do
            local stats=$(ip -s link show "$iface" 2>/dev/null)
            if [ -n "$stats" ]; then
                local rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
                local tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
                local rx_packets=$(echo "$stats" | awk '/RX:/{getline; print $2}')
                local tx_packets=$(echo "$stats" | awk '/TX:/{getline; print $2}')

                local prev_rx_pkt=$(_get_prev "${iface}_rx_pkts")
                local prev_tx_pkt=$(_get_prev "${iface}_tx_pkts")
                local prev_rx_byte=$(_get_prev "${iface}_rx_bytes")
                local prev_tx_byte=$(_get_prev "${iface}_tx_bytes")

                [ -z "$prev_rx_pkt" ] && prev_rx_pkt=0
                [ -z "$prev_tx_pkt" ] && prev_tx_pkt=0
                [ -z "$prev_rx_byte" ] && prev_rx_byte=0
                [ -z "$prev_tx_byte" ] && prev_tx_byte=0

                local delta_rx_pkt=$((rx_packets - prev_rx_pkt))
                local delta_tx_pkt=$((tx_packets - prev_tx_pkt))
                local delta_rx_data=$(_format_bytes $((rx_bytes - prev_rx_byte)))
                local delta_tx_data=$(_format_bytes $((tx_bytes - prev_tx_byte)))

                if [ "$iface" = "$focus_iface" ]; then
                    printf "  ${MON_GREEN}%-10s${MON_RESET} %-8s %-8s %-8s %-8s\n" \
                        "$iface" "$delta_rx_pkt" "$delta_rx_data" "$delta_tx_pkt" "$delta_tx_data"
                else
                    printf "  %-10s %-8s %-8s %-8s %-8s\n" \
                        "$iface" "$delta_rx_pkt" "$delta_rx_data" "$delta_tx_pkt" "$delta_tx_data"
                fi

                _update_prev "${iface}_rx_pkts" "$rx_packets"
                _update_prev "${iface}_tx_pkts" "$tx_packets"
                _update_prev "${iface}_rx_bytes" "$rx_bytes"
                _update_prev "${iface}_tx_bytes" "$tx_bytes"
            fi
        done
        echo ""

        # === SECCIÓN 3: Conexiones activas por interfaz ===
        echo -e "${MON_BOLD}${MON_CYAN}═══ 3. Active Connections (by interface) ═══${MON_RESET}"
        printf "  %-10s %8s %8s\n" "IFACE" "TOTAL" "BYPASSED"

        for iface in lan2 lan3 br-lan pppoe-wan; do
            local tmp_conn="/tmp/nss-debug-conn-$$"
            ct_dump_all_full 2>/dev/null | grep "|${iface}|" > "$tmp_conn"
            local total=$(wc -l < "$tmp_conn")
            local bypass_count=$(grep -c "|YES|" "$tmp_conn")
            rm -f "$tmp_conn"

            if [ "$iface" = "$focus_iface" ]; then
                printf "  ${MON_GREEN}%-10s${MON_RESET} %8s %8s\n" "$iface" "$total" "$bypass_count"
            else
                printf "  %-10s %8s %8s\n" "$iface" "$total" "$bypass_count"
            fi
        done
        echo ""

        # === SECCIÓN 4: Top conexiones (focus interface) ===
        echo -e "${MON_BOLD}${MON_CYAN}═══ 4. Top Connections (${focus_iface}) ═══${MON_RESET}"
        echo -e "  ${MON_DIM}PROTO  SRC:PORT -> DST:PORT                              BYPASS${MON_RESET}"

        ct_dump_all_full 2>/dev/null | grep "|${focus_iface}|" | head -8 | while IFS='|' read -r num proto src dst iface nss bypass mark state; do
            local src_ip=$(echo "$src" | cut -d'#' -f1 | cut -c1-30)
            local src_port=$(echo "$src" | cut -d'#' -f2)
            local dst_ip=$(echo "$dst" | cut -d'#' -f1 | cut -c1-30)
            local dst_port=$(echo "$dst" | cut -d'#' -f2)

            local bypass_color=""
            [ "$bypass" = "YES" ] && bypass_color="$MON_YELLOW"

            if [ "$bypass" = "YES" ]; then
                echo -e "  ${MON_DIM}${proto}${MON_RESET} ${MON_YELLOW}${src_ip}:${src_port} -> ${dst_ip}:${dst_port} BYPASS${MON_RESET}"
            else
                echo -e "  ${MON_DIM}${proto}${MON_RESET} ${src_ip}:${src_port} -> ${dst_ip}:${dst_port}"
            fi
        done
        echo ""

        # === SECCIÓN 5: Reglas activas ===
        echo -e "${MON_BOLD}${MON_CYAN}═══ 5. Active Bypass Rules ═══${MON_RESET}"

        # Guardar reglas en archivo temporal para evitar subshell
        local rules_tmp="/tmp/nss-debug-rules-display-$$"
        nft list chain inet fw4 nss_bypass_pre 2>/dev/null | grep "comment \"NSS-Switch" > "$rules_tmp"
        local rule_count=$(wc -l < "$rules_tmp")

        if [ "$rule_count" -gt 0 ]; then
            while read line; do
                local comment=$(echo "$line" | sed -n 's/.*comment "NSS-Switch id=\([0-9]\+\): \(.*\)".*/\1: \2/p')
                if [ -n "$comment" ]; then
                    echo -e "  • $comment"
                fi
            done < "$rules_tmp"
        else
            echo -e "  ${MON_DIM}No active rules${MON_RESET}"
        fi
        rm -f "$rules_tmp"
        echo ""


        echo -e "${MON_DIM}Press Ctrl+C to exit | Refreshing every 2 seconds${MON_RESET}"

        # === LOGGING: Registrar TODO el snapshot ===
        {
            echo "=== SNAPSHOT $(date '+%Y-%m-%d %H:%M:%S') ==="
            echo "═══ 1. Quick Summary ═══"
            echo "  Total connections:        $total_conn ($([ $conn_diff -ge 0 ] && echo "+$conn_diff" || echo "$conn_diff"))"
            echo "  Bypassed (CPU):           $bypassed ($([ $bypass_diff -ge 0 ] && echo "+$bypass_diff" || echo "$bypass_diff"))"
            echo "  ECM Frontend:             $frontend"
            echo ""
            echo "═══ 2. Interface Traffic (delta) ═══"
            echo "  IFACE        RX_PKTS    RX_DATA    TX_PKTS    TX_DATA"

            for iface in lan2 lan3 br-lan pppoe-wan; do
                local stats=$(ip -s link show "$iface" 2>/dev/null)
                if [ -n "$stats" ]; then
                    local rx_bytes=$(echo "$stats" | awk '/RX:/{getline; print $1}')
                    local tx_bytes=$(echo "$stats" | awk '/TX:/{getline; print $1}')
                    local rx_packets=$(echo "$stats" | awk '/RX:/{getline; print $2}')
                    local tx_packets=$(echo "$stats" | awk '/TX:/{getline; print $2}')

                    local prev_rx_pkt=$(_get_prev "${iface}_rx_pkts")
                    local prev_tx_pkt=$(_get_prev "${iface}_tx_pkts")
                    local prev_rx_byte=$(_get_prev "${iface}_rx_bytes")
                    local prev_tx_byte=$(_get_prev "${iface}_tx_bytes")

                    [ -z "$prev_rx_pkt" ] && prev_rx_pkt=0
                    [ -z "$prev_tx_pkt" ] && prev_tx_pkt=0
                    [ -z "$prev_rx_byte" ] && prev_rx_byte=0
                    [ -z "$prev_tx_byte" ] && prev_tx_byte=0

                    local delta_rx_pkt=$((rx_packets - prev_rx_pkt))
                    local delta_tx_pkt=$((tx_packets - prev_tx_pkt))
                    local delta_rx_data=$(_format_bytes $((rx_bytes - prev_rx_byte)))
                    local delta_tx_data=$(_format_bytes $((tx_bytes - prev_tx_byte)))

                    echo "  $iface       $delta_rx_pkt    $delta_rx_data     $delta_tx_pkt    $delta_tx_data"

                    _update_prev "${iface}_rx_pkts" "$rx_packets"
                    _update_prev "${iface}_tx_pkts" "$tx_packets"
                    _update_prev "${iface}_rx_bytes" "$rx_bytes"
                    _update_prev "${iface}_tx_bytes" "$tx_bytes"
                fi
            done
            echo ""
            echo "═══ 3. Active Connections (by interface) ═══"
            echo "  IFACE         TOTAL BYPASSED"

            for iface in lan2 lan3 br-lan pppoe-wan; do
                local tmp_conn="/tmp/nss-debug-conn-$$"
                ct_dump_all_full 2>/dev/null | grep "|${iface}|" > "$tmp_conn"
                local total=$(wc -l < "$tmp_conn")
                local bypass_count=$(grep -c "|YES|" "$tmp_conn")
                rm -f "$tmp_conn"
                echo "  $iface            $total       $bypass_count"
            done
            echo ""
            echo "═══ 4. Top Connections (${focus_iface}) ═══"

            ct_dump_all_full 2>/dev/null | grep "|${focus_iface}|" | head -8 | while IFS='|' read -r num proto src dst iface nss bypass mark state; do
                local src_ip=$(echo "$src" | cut -d'#' -f1 | cut -c1-30)
                local src_port=$(echo "$src" | cut -d'#' -f2)
                local dst_ip=$(echo "$dst" | cut -d'#' -f1 | cut -c1-30)
                local dst_port=$(echo "$dst" | cut -d'#' -f2)

                if [ "$bypass" = "YES" ]; then
                    echo "  $proto $src_ip:$src_port -> $dst_ip:$dst_port BYPASS"
                else
                    echo "  $proto $src_ip:$src_port -> $dst_ip:$dst_port"
                fi
            done
            echo ""
            echo "═══ 5. Active Bypass Rules ═══"

            nft list chain inet fw4 nss_bypass_pre 2>/dev/null | grep "comment \"NSS-Switch" | while read line; do
                local comment=$(echo "$line" | sed -n 's/.*comment "NSS-Switch id=\([0-9]\+\): \(.*\)".*/\1: \2/p')
                [ -n "$comment" ] && echo "  • $comment"
            done
            echo ""
            echo "=========================================="
            echo ""
        } >> "$DEBUG_LOG_FILE"

        # Detectar cambios en reglas (opcional, ya que el snapshot completo ya lo muestra todo)
        _check_rule_changes

        sleep 2
    done

}

# DEBUG PR-1
cmd_debug_log() {
    local log_exists=0
    if [ -f "$DEBUG_LOG" ]; then
        log_exists=1
    fi
    ui_section "Debug Log Status"
    ui_kv "Status" "$([ $log_exists -eq 1 ] && echo "enabled" || echo "disabled")"
    ui_kv "Log file" "$DEBUG_LOG"
    if [ $log_exists -eq 1 ]; then
        echo ""
        ui_info "Last 5 lines:"
        tail -5 "$DEBUG_LOG" 2>/dev/null | while read line; do
            printf "  ${C_DIM}%s${C_RESET}\n" "$line"
        done
        echo ""
        if ui_ask_yn "Show full debug log? " n; then
            cat "$DEBUG_LOG"
            echo ""
        fi
        if ui_ask_yn "Disable debug logging? (log will be deleted) " n; then
            rm -f "$DEBUG_LOG"

            # DEBUG PR-1: Usar UCI para desactivar debug
            uci set nss-switch.settings.debug_mode="no"
            uci commit nss-switch

            ui_ok "Debug logging disabled, log file deleted"
        fi
    else
        ui_info "Debug logging is currently disabled"
        echo ""
        if ui_ask_yn "Enable debug logging?" y; then
            echo "=== NSS-Switch Debug Log ===" > "$DEBUG_LOG"
            echo "=== Started: $(date) ===" >> "$DEBUG_LOG"

            # DEBUG PR-1: Usar UCI para activar debug
            uci set nss-switch.settings.debug_mode="yes"
            uci commit nss-switch

            ui_ok "Debug logging enabled at $DEBUG_LOG"
            ui_info "Use 'nss-switch debug log' again to disable"
        fi
    fi
}
