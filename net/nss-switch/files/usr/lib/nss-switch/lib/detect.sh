#!/usr/bin/env ash
# lib/detect.sh — Environment detection for NSS-Switch
# ASH compatible, BusyBox v1.37+

# ─── Detect firewall backend ──────────────────────────────────────────────────
detect_fw_backend() {
    if grep -q "fw4" /etc/init.d/firewall 2>/dev/null; then
        echo "fw4"
    elif grep -q "fw3" /etc/init.d/firewall 2>/dev/null; then
        echo "fw3"
    else
        echo "unknown"
    fi
}
# ─── List all network interfaces ─────────────────────────────────────────────
detect_interfaces() {
    ip link show 2>/dev/null | grep -E '^[0-9]+:' | \
        awk '{print $2}' | sed 's/://' | grep -v '^lo$'
}
# ─── Detect if interface is WAN ───────────────────────────────────────────────
detect_is_wan() {
    local iface="$1"
    # Check UCI network config
    grep -l "option ifname.*$iface\|option device.*$iface" /etc/config/network 2>/dev/null | \
        xargs grep -l "wan\|pppoe\|dhcp" 2>/dev/null | head -1 | grep -q . && return 0
    # Fallback: check if it's the default route interface
    ip route | grep "^default" | grep -q "$iface"
}
# ─── Detect if NAT/masquerade applies on an interface ────────────────────────
detect_has_nat() {
    local iface="$1"
    # Check if masquerade or dnat rules exist for this interface in live nft
    nft list ruleset 2>/dev/null | grep -q "oifname \"$iface\".*masquerade\|iifname \"$iface\".*dnat"
}
# ─── Detect if DNAT applies on an interface ───────────────────────────────────
detect_has_dnat() {
    local iface="$1"
    nft list ruleset 2>/dev/null | grep -q "iifname \"$iface\".*dnat"
}
# ─── Get zone name for an interface from fw4 chains ──────────────────────────
detect_zone_for_iface() {
    local iface="$1"
    # fw4 names chains like input_lan, forward_lan, etc.
    # Look for iifname matches in chain jumps
    nft list ruleset 2>/dev/null | \
        grep "iifname \"$iface\".*jump" | \
        grep -oE 'jump [a-z_]+' | \
        head -1 | awk '{print $2}' | sed 's/input_//;s/forward_//;s/output_//'
}
# ─── Get all interfaces that have DNAT rules ──────────────────────────────────
detect_dnat_ifaces() {
    nft list ruleset 2>/dev/null | \
        grep "iifname.*dnat" | \
        grep -oE '"[^"]+"' | head -1 | tr -d '"'
}
# ─── Full environment check ───────────────────────────────────────────────────
detect_check_all() {
    local ok=0 warn=0 err=0
    local frontend=$(ecm_frontend)

    ui_section "System Environment"
    ui_kv "Kernel" "$(uname -r)"
    ui_kv "BusyBox" "$(awk 2>&1 | head -1 | sed 's/^BusyBox //')"
    ui_kv "nft" "$(nft --version 2>/dev/null | head -1)"

    ui_section "Firewall"
    local fw
    fw=$(detect_fw_backend)
    ui_kv "Backend" "$fw"
    if [ "$fw" != "fw4" ]; then
        ui_warn "NSS-Switch is designed for fw4/nftables"
        warn=$((warn+1))
    else
        ui_ok "fw4 detected"
        ok=$((ok+1))
    fi

    ui_section "nftables Tables"
    nft list tables 2>/dev/null | while IFS= read -r t; do
        ui_kv "table" "$t"
    done

    ui_section "fw4 Mangle Chains (our injection points)"
    for chain in mangle_prerouting mangle_postrouting raw_prerouting; do
        if nft list chain inet fw4 "$chain" >/dev/null 2>&1; then
            ui_ok "$chain — present"
            ok=$((ok+1))
        else
            ui_warn "$chain — NOT present (unexpected)"
            warn=$((warn+1))
        fi
    done

    ui_section "Offload Engine"
    case "$frontend" in
        NSS)
            ui_ok "Qualcomm NSS hardware offload detected"
            ok=$((ok+1))

            if [ -d "$ECM_DEBUGFS" ]; then
                ui_ok "ECM debugfs present at $ECM_DEBUGFS"
                ok=$((ok+1))
            else
                ui_error "ECM debugfs NOT found — NSS offload may not be active"
                err=$((err+1))
            fi

            if ecm_mark_classifier_available; then
                ui_ok "ecm_classifier_mark — AVAILABLE (ct mark bypass will work)"
                ok=$((ok+1))
            else
                ui_error "ecm_classifier_mark — NOT AVAILABLE (bypass via ct mark will NOT work!)"
                err=$((err+1))
            fi

            ui_kv "accel_delay_pkts" "$(ecm_accel_delay_pkts)"
            ;;
        SFE)
            ui_ok "Shortcut Forwarding Engine (SFE) detected"
            ok=$((ok+1))
            ui_info "ct mark bypass support depends on SFE implementation"
            ;;
        MTK_PPE)
            ui_ok "MediaTek PPE/HNAT hardware offload detected"
            ok=$((ok+1))
            ui_info "ct mark bypass not applicable for PPE hardware"
            ;;
        SW_FLOW)
            ui_ok "Linux nf_flow_table software offload detected"
            ok=$((ok+1))
            ui_info "ct mark bypass not applicable for software flow offload"
            ;;
        *)
            ui_warn "No offload engine detected"
            warn=$((warn+1))
            ;;
    esac

    ui_kv "ECM frontend" "$frontend"
    ui_kv "ECM engine (UCI)" "$(ecm_engine)"

    ui_section "Conntrack"
    if [ -f /proc/net/nf_conntrack ]; then
        ui_ok "nf_conntrack available"
        ui_kv "Total connections" "$(wc -l < /proc/net/nf_conntrack)"
        ok=$((ok+1))
    else
        ui_error "nf_conntrack not available"
        err=$((err+1))
    fi

    ui_section "NSS-Switch State"
    if [ -f "$RULES_FILE" ]; then
        local rule_count
        rule_count=$(grep -cv -e '^#' -e '^$' "$RULES_FILE" 2>/dev/null)
        ui_kv "Rules file" "$RULES_FILE"
        ui_kv "Active rules" "$rule_count"
    else
        ui_warn "No rules file yet (no rules defined)"
    fi

    if nft_chains_exist 2>/dev/null; then
        ui_ok "NSS-Switch nft chains present in live ruleset"
    else
        ui_warn "NSS-Switch chains NOT in live ruleset (firewall not reloaded yet?)"
    fi

    ui_section "NSS-Switch Mark"
    ui_kv "Our ct mark" "$NSS_MARK"
    ui_kv "QoS mark range" "0x000000ff (no conflict)"
    ui_kv "Bypassed connections" "$(ct_count_bypassed)"

    ui_section "Interfaces"
    detect_interfaces | while IFS= read -r iface; do
        local nat_flag="" dnat_flag="" zone
        detect_has_nat  "$iface" && nat_flag=" [NAT]"
        detect_has_dnat "$iface" && dnat_flag=" [DNAT]"
        zone=$(detect_zone_for_iface "$iface")
        [ -z "$zone" ] && zone="?"
        printf "  %-15s zone=%-10s%s%s\n" "$iface" "$zone" "$nat_flag" "$dnat_flag"
    done

    ui_section "Summary"
    printf "  ${C_GREEN}OK: %d${C_RESET}  ${C_YELLOW}WARN: %d${C_RESET}  ${C_RED}ERR: %d${C_RESET}\n" \
        "$ok" "$warn" "$err"
    [ "$err" -gt 0 ] && return 1 || return 0
}
