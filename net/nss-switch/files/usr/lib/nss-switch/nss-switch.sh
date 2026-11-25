#!/usr/bin/env ash
# nss-switch.sh — Qualcomm NSS selective bypass manager
# /usr/lib/nss-switch/nss-switch.sh symlinked to /usr/bin/nss-switch
# ASH compatible — BusyBox v1.37+
# Usage: nss-switch <command> [options]

# set -e

# ─── Resolve our own directory ────────────────────────────────────────────────
SELF_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# ─── UCI cinfig handler  ────────────────────────
uci_load_config() {
    local section="settings"
    local uci_file="/etc/config/nss-switch"

    if [ ! -f "$uci_file" ]; then
        uci -q set nss-switch.$section=settings
        uci -q set nss-switch.$section.persist_default="no"
        uci -q set nss-switch.$section.nss_mark="0x00010000"
        uci -q set nss-switch.$section.nss_mark_mask="0x00010000"
        uci -q set nss-switch.$section.ecm_debugfs="/sys/kernel/debug/ecm"
        uci -q set nss-switch.$section.nft_table="inet fw4"
        uci -q set nss-switch.$section.nft_chain_pre="nss_bypass_pre"
        uci -q set nss-switch.$section.nft_chain_post="nss_bypass_post"
        uci -q set nss-switch.$section.rules_file="/etc/nss-switch/rules.conf"
        uci -q set nss-switch.$section.debug_log="/tmp/nss-switch.log"
        uci -q set nss-switch.$section.fw_script="/etc/firewall.d/nss-bypass-rules"
        uci -q set nss-switch.$section.watch_interval="3"
        uci -q set nss-switch.$section.debug_mode="no"
        uci commit nss-switch
        dbg "Created default UCI config: $uci_file"
    fi

    PERSIST_DEFAULT=$(uci -q get nss-switch.$section.persist_default || echo "no")
    NSS_MARK=$(uci -q get nss-switch.$section.nss_mark || echo "0x00010000")
    NSS_MARK_MASK=$(uci -q get nss-switch.$section.nss_mark_mask || echo "0x00010000")
    ECM_DEBUGFS=$(uci -q get nss-switch.$section.ecm_debugfs || echo "/sys/kernel/debug/ecm")
    NFT_TABLE=$(uci -q get nss-switch.$section.nft_table || echo "inet fw4")
    NFT_CHAIN_PRE=$(uci -q get nss-switch.$section.nft_chain_pre || echo "nss_bypass_pre")
    NFT_CHAIN_POST=$(uci -q get nss-switch.$section.nft_chain_post || echo "nss_bypass_post")
    RULES_FILE=$(uci -q get nss-switch.$section.rules_file || echo "/etc/nss-switch/rules.conf")
    DEBUG_LOG=$(uci -q get nss-switch.$section.debug_log || echo "/tmp/nss-switch.log")
    FW_SCRIPT=$(uci -q get nss-switch.$section.fw_script || echo "/etc/firewall.d/nss-bypass-rules")
    WATCH_INTERVAL=$(uci -q get nss-switch.$section.watch_interval || echo "3")
    DEBUG_MODE=$(uci -q get nss-switch.$section.debug_mode || echo "no")
}

uci_load_config

# ─── Debug logging helper (available before libs load) ────────────────────────
dbg() {
    # Solo proceder si debug está activado
    if [ "${DEBUG:-0}" != "1" ] && [ "$DEBUG_MODE" != "yes" ]; then
        return 0
    fi

    [ -f "$DEBUG_LOG" ] || return 0

    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[DBG ] %s\n" "$*" >&2
    printf "%s [DBG] %s\n" "$ts" "$*" >> "$DEBUG_LOG" 2>/dev/null || true
}

# ─── Load libraries ───────────────────────────────────────────────────────────
for lib in chandler ui ecm conntrack nft detect rules; do
    lib_file="$SELF_DIR/lib/${lib}.sh"
    if [ ! -f "$lib_file" ]; then
        echo "[ERR ] Missing lib: $lib_file" >&2
        exit 1
    fi
    . "$lib_file"
done
# ─── Load debug monitor  ────────────────────────
DEBUG_LIB="$SELF_DIR/lib/debug.sh"
if [ -f "$DEBUG_LIB" ]; then
    . "$DEBUG_LIB"
fi

# ─── Root check ───────────────────────────────────────────────────────────────
check_root() {
    [ "$(id -u)" = "0" ] || { ui_error "Must be run as root"; exit 1; }
}

# ─── Log every invocation ────────────────────────────────────────────────────
dbg "Invoked: $0 $*"

# ─── Clean tmp files ─────────────────────────────────────────────────────────
_clean_tmp() {
    rm -f /tmp/nss-switch-pick.* 2>/dev/null
    rm -f /tmp/nss-switch-watch.* 2>/dev/null
    rm -f /tmp/nss-ifmap.* 2>/dev/null
    rm -f /tmp/nss-switch-exit.* 2>/dev/null
    rm -f /tmp/nss-iface.* 2>/dev/null
    rm -f /tmp/nss-display.* 2>/dev/null
    rm -f /tmp/nss-page.* 2>/dev/null
}
trap '_clean_tmp' EXIT

# ─── COMMAND: watch ───────────────────────────────────────────────────────────
cmd_watch() {
    check_root

    # PENDING
    # ui_check_width

    local sort_mode=1
    local interval="${1:-$WATCH_INTERVAL}"
    local once=0
    [ "$1" = "--once" ] && { once=1; interval=0; }

    # ── Ctrl+C fix ──────────────────────────────────────────────────────────
    local _watch_exit=0
    local _watch_tmp
    _watch_tmp=$(mktemp /tmp/nss-switch-watch.XXXXXX)

    # Trap: clean up and exit
    trap '
        _watch_exit=1
        # Show cursor again
        ui_cursor_show
        # ui_watch_cleanup
        rm -f "$_watch_tmp"
        rm -f /tmp/nss-iface.* 2>/dev/null
        printf "\n"
        trap - INT TERM
        exit 0
    ' INT TERM

    # HAVE cursor (but NO alt_screen)
    ui_cursor_show

    # Helper: flush all pending input from stdin (non-blocking)
    _flush_input() {
        local dummy
        while read -s -t 0 -n 1 dummy 2>/dev/null; do
            : # consume and discard
        done
    }

    # ── First run: show loading indicator ───────────────────────────────────
    ui_clear_screen
    ui_cursor_home
    ui_header_bar "NSS-Switch" "NSS Conntrack Live Monitor" "$(date +'%a %d %b  %H:%M:%S')"
    printf "\n"
    ui_spinner_start "Loading connections ..."

    # Dump outside any pipe — fills tmpfile, no subshell issues
    ct_dump_all_full > "$_watch_tmp" 2>/dev/null

    ui_spinner_stop
    printf "\n"

    local total bypassed rules
    total=$(ct_count)
    bypassed=$(ct_count_bypassed)
    rules=$(rules_count 2>/dev/null || echo 0)

    # Subfunction to render the full display (with optional sorting)
    _render_watch() {
        local input_file="$1"
        local current_sort="$2"

        # Map sort mode to readable name
        local sort_name=""
        case "$current_sort" in
            1) sort_name="ID" ;;
            2) sort_name="PROTO" ;;
            3) sort_name="SRC" ;;
            4) sort_name="DST" ;;
            5) sort_name="IFACE" ;;
            6) sort_name="NSS" ;;
            *) sort_name="ID" ;;
        esac

        # Apply sorting if a sort mode is specified
        local display_file="$input_file"
        if [ -n "$current_sort" ] && [ "$current_sort" -ge 1 ] && [ "$current_sort" -le 6 ]; then
            local sorted_tmp="/tmp/nss-watch-sorted.$$"
            case "$current_sort" in
                1) sort -t'|' -k1 -n "$input_file" > "$sorted_tmp" ;;
                2) sort -t'|' -k2 "$input_file" > "$sorted_tmp" ;;
                3) sort -t'|' -k3 "$input_file" > "$sorted_tmp" ;;
                4) sort -t'|' -k4 "$input_file" > "$sorted_tmp" ;;
                5) sort -t'|' -k5 "$input_file" > "$sorted_tmp" ;;
                6) sort -t'|' -k6 "$input_file" > "$sorted_tmp" ;;
            esac
            display_file="$sorted_tmp"
        fi

        ui_clear_screen_scrollback
        ui_cursor_home

        ui_header_bar "NSS-Switch" "NSS Conntrack Live Monitor" "$(date +'%a %d %b  %H:%M:%S')"
        ui_hint_bar "Ctrl+C / q exit  •  refresh every ${interval}s  •  Sorted by: ${sort_name}  •  1-6: Sort column"

        ui_watch_stats_panel "$total" "$bypassed" \
            "$(ecm_frontend)" "$(ecm_engine)" "$rules" "$interval"

        ui_conn_header

        while IFS='|' read -r n proto src dst iface nss bypass mark state; do
            local sip sp dip dp ss ds
            sip=$(echo "$src" | cut -d'#' -f1)
            sp=$(echo "$src"  | cut -d'#' -f2)
            dip=$(echo "$dst" | cut -d'#' -f1)
            dp=$(echo "$dst"  | cut -d'#' -f2)
            if echo "$sip" | grep -q ":"; then ss="[${sip}]:${sp}"; else ss="${sip}:${sp}"; fi
            if echo "$dip" | grep -q ":"; then ds="[${dip}]:${dp}"; else ds="${dip}:${dp}"; fi
            ui_conn_row "$n" "$proto" "$ss" "$ds" "$iface" "$nss" "$bypass"
        done < "$display_file"

        [ "$display_file" != "$input_file" ] && rm -f "$display_file"

        ui_sep

        local file_total
        file_total=$(wc -l < "$input_file" 2>/dev/null || echo 0)

        local table_width
        table_width=$(ui_table_width)

        if [ $TERM_COLS -lt $((table_width + 10)) ] && [ $file_total -gt 0 ]; then
            printf "${FG_DIM}%*s${C_RESET}\n" "$table_width" " "
            printf "  ${FG_YELLOW}${WARN_SYM}${C_RESET} ${C_DIM}Terminal narrow (${TERM_COLS}c), long IPv6 addresses may be truncated. Use wider terminal (125c) for full visibility.${C_RESET}\n"
        else
            printf "${C_DIM}Total connections: %d  •  Use PgUp/PgDown or mouse to scroll${C_RESET}\n" "$file_total"
        fi

        ui_clear_cursor_bellow
    }

    # Render first time
    _render_watch "$_watch_tmp" "$sort_mode"

    [ "$_watch_exit" -eq 1 ] && { ui_cursor_show; rm -f "$_watch_tmp"; rm -f /tmp/nss-iface.* 2>/dev/null; trap - INT TERM; return 0; }
    [ "$once"        -eq 1 ] && { ui_cursor_show; rm -f "$_watch_tmp"; rm -f /tmp/nss-iface.* 2>/dev/null; trap - INT TERM; return 0; }

    # ── Main loop (subsequent refreshes) ────────────────────────────────────
    while [ "$_watch_exit" -eq 0 ]; do
        # Read one key with timeout (waits up to interval seconds)
        key=""
        read -s -t "$interval" -n 1 key 2>/dev/null

        # Process valid keys
        case "$key" in
            1|2|3|4|5|6)
                sort_mode="$key"
                _render_watch "$_watch_tmp" "$sort_mode"
                _flush_input
                ;;
            q|Q)
                _watch_exit=1
                break
                ;;
            *)
                if [ -n "$key" ]; then
                    _flush_input
                fi
                ;;
        esac

        [ "$_watch_exit" -eq 1 ] && break

        ui_get_term_size

        ct_dump_all_full > "$_watch_tmp" 2>/dev/null
        total=$(ct_count)
        bypassed=$(ct_count_bypassed)
        rules=$(rules_count 2>/dev/null || echo 0)

        _render_watch "$_watch_tmp" "$sort_mode"

        [ "$once" -eq 1 ] && break
    done

    ui_cursor_show
    rm -f "$_watch_tmp"
    rm -f /tmp/nss-iface.* 2>/dev/null
    trap - INT TERM
}

# ─── COMMAND: pick ────────────────────────────────────────────────────────────
cmd_pick() {
    check_root

    local _pick_tmp
    _pick_tmp=$(mktemp /tmp/nss-switch-pick.XXXXXX)

    local _selection_tmp
    _selection_tmp=$(mktemp /tmp/nss-switch-selection.XXXXXX)

    # Trap for cleanup only... NO alt_screen tricks
    trap '
        rm -f "$_pick_tmp" "$_selection_tmp" 2>/dev/null
        rm -f /tmp/nss-iface.* 2>/dev/null
        printf "\n"
        # Ensure cursor is visible
        ui_cursor_show
        trap - INT TERM
        exit 0
    ' INT TERM

    # NO ui_watch_init() that enables alt_screen NOT needed for pick
    # Just clear screen and show the picker normally

    ui_clear_screen
    ui_cursor_home
    ui_header_bar "NSS-Switch" "Connection Picker" "$(date +'%H:%M:%S')"
    printf "\n"
    ui_spinner_start "Loading connections ..."

    ct_dump_all_full > "$_pick_tmp" 2>/dev/null

    ui_spinner_stop
    printf "\n"

    local total
    total=$(wc -l < "$_pick_tmp" 2>/dev/null || echo 0)

    if [ "$total" -eq 0 ]; then
        rm -f "$_pick_tmp" "$_selection_tmp" 2>/dev/null
        rm -f /tmp/nss-iface.* 2>/dev/null
        trap - INT TERM
        ui_warn "No connections found in conntrack"
        return 0
    fi

    # Make a permanent copy for the selection phase
    cp "$_pick_tmp" "$_selection_tmp"


    # Display ALL connections (uses normal terminal mode, scroll works!)
    if ! ui_pick_display_normal "$_pick_tmp" "$total"; then
        rm -f "$_pick_tmp" "$_selection_tmp" 2>/dev/null
        rm -f /tmp/nss-iface.* 2>/dev/null
        trap - INT TERM
        ui_warn "Cancelled"
        return 0
    fi

    local sel="$UI_NUM"

    # Now read from the SELECTION tmpfile
    local conn_line
    conn_line=$(awk -F'|' -v n="$sel" '$1==n {print; exit}' "$_selection_tmp" 2>/dev/null)
    # Clean up tmpfiles
    rm -f "$_pick_tmp" "$_selection_tmp" 2>/dev/null
    rm -f /tmp/nss-iface.* 2>/dev/null
    trap - INT TERM

    if [ -z "$conn_line" ]; then
        ui_error "Connection $sel not found"
        return 1
    fi

    local num proto src dst iface nss bypass mark state
    num=$(echo "$conn_line"   | cut -d'|' -f1)
    proto=$(echo "$conn_line" | cut -d'|' -f2)
    src=$(echo "$conn_line"   | cut -d'|' -f3)
    dst=$(echo "$conn_line"   | cut -d'|' -f4)
    iface=$(echo "$conn_line" | cut -d'|' -f5)
    nss=$(echo "$conn_line"   | cut -d'|' -f6)
    bypass=$(echo "$conn_line"| cut -d'|' -f7)
    mark=$(echo "$conn_line"  | cut -d'|' -f8)
    state=$(echo "$conn_line" | cut -d'|' -f9)

    local src_ip src_port dst_ip dst_port
    src_ip=$(echo "$src" | cut -d'#' -f1)
    src_port=$(echo "$src" | cut -d'#' -f2)
    dst_ip=$(echo "$dst" | cut -d'#' -f1)
    dst_port=$(echo "$dst" | cut -d'#' -f2)

    ui_section "Selected Connection"
    ui_kv "Protocol"  "$proto"
    ui_kv "Source"    "$src_ip : $src_port"
    ui_kv "Dest"      "$dst_ip : $dst_port"
    ui_kv "Interface" "$iface"
    ui_kv "NSS state" "$nss"
    ui_kv "Bypassed"  "$bypass"
    ui_sep

    ui_section "What should the bypass rule match on? "
    ui_bold "You can combine multiple criteria. Answer each: "
    printf "\n"

    local r_proto="any" r_src_ip="any" r_dst_ip="any"
    local r_sport="any" r_dport="any" r_iface="any"

    # PRTOTOCOL
    if ui_ask_yn "Match on protocol ($proto)?" y; then
        r_proto="$proto"
    fi

    # SRC-IP
    if ui_ask_yn "Match on source IP ($src_ip)?" n; then
        ui_ask_input "Enter source IP/CIDR (or press Enter to keep '$src_ip')" "$src_ip" "ip"
        r_src_ip="$UI_INPUT"
    fi

    # DST-IP
    if ui_ask_yn "Match on destination IP ($dst_ip)?" n; then
        ui_ask_input "Enter destination IP/CIDR (or press Enter to keep '$dst_ip')" "$dst_ip" "ip"
        r_dst_ip="$UI_INPUT"
    fi

    # PORT
    if [ "$proto" = "tcp" ] || [ "$proto" = "udp" ]; then
        if ui_ask_yn "Match on source port ($src_port)?" n; then
            ui_ask_input "Source port" "$src_port" "port"
            r_sport="$UI_INPUT"
        fi
        if ui_ask_yn "Match on destination port ($dst_port)?" n; then
            ui_ask_input "Destination port" "$dst_port" "port"
            r_dport="$UI_INPUT"
        fi
    fi

    # IFACE
    if [ "$iface" != "?" ] && [ -n "$iface" ]; then
        case "$iface" in
            local:*)
                local real_iface="${iface#local:}"
                ui_warn "Router-generated traffic (not a LAN device)"
                if ui_ask_yn "Match by output interface ($real_iface)?" y; then
                    r_iface="out:$real_iface"
                fi
                ;;
            *)
                if ui_ask_yn "Match on interface ($iface)?" n; then
                    r_iface="$iface"
                fi
                ;;
        esac
    fi

    # PERSISTANCE
    local persist="$PERSIST_DEFAULT"
    if ui_ask_yn "Make this rule persistent (survive reboot)?" "$([ "$PERSIST_DEFAULT" = "yes" ] && echo y || echo n)"; then
        persist="yes"
    else
        persist="no"
    fi

    # COMMENT
    local default_comment="bypass from pick: $src_ip -> $dst_ip"
    ui_ask_input "Comment for this rule" "$default_comment" "string"
    local comment="$UI_INPUT"

    ui_section "Rule Preview"
    ui_kv "Protocol"   "$r_proto"
    ui_kv "Src IP"     "$r_src_ip"
    ui_kv "Dst IP"     "$r_dst_ip"
    ui_kv "Src Port"   "$r_sport"
    ui_kv "Dst Port"   "$r_dport"
    ui_kv "Interface"  "$r_iface"
    ui_kv "Persistent" "$persist"
    ui_kv "Comment"    "$comment"
    ui_sep

    rm -f /tmp/nss-iface.* 2>/dev/null

    # VALIDATE ALL
    if ! rules_validate "$r_proto" "$r_src_ip" "$r_dst_ip" "$r_sport" "$r_dport" "$r_iface" "$comment"; then
        ui_error "Validation failed — rule not added"
        return 1
    fi

    ui_confirm "Apply this bypass rule?" || { ui_warn "Aborted"; return 0; }

    local new_id
    new_id=$(rules_add "$r_proto" "$r_src_ip" "$r_dst_ip" \
        "$r_sport" "$r_dport" "$r_iface" "$persist" "$comment")
    ui_ok "Rule $new_id saved"

    nft_apply

    ui_info "Flushing matched connections..."
    ct_clear_rule_marks "$r_proto" "$r_src_ip" "$r_dst_ip" \
        "$r_sport" "$r_dport" "$r_iface"

    ui_ok "Done. Connection will be handled by CPU (not NSS) going forward."
}

# ─── COMMAND: add ─────────────────────────────────────────────────────────────
cmd_add() {
    check_root
    local proto="any" src_ip="any" dst_ip="any"
    local sport="any" dport="any" iface="any"
    local persist="$PERSIST_DEFAULT" comment="manual rule"
    local defunct_after=1

    while [ $# -gt 0 ]; do
        case "$1" in
            --proto)      proto="$2";    shift 2 ;;
            --src-ip)     src_ip="$2";   shift 2 ;;
            --dst-ip)     dst_ip="$2";   shift 2 ;;
            --src-port)   sport="$2";    shift 2 ;;
            --dst-port)   dport="$2";    shift 2 ;;
            --iface)      iface="$2";    shift 2 ;;
            --persist)    persist="yes"; shift   ;;
            --temp)       persist="no";  shift   ;;
            --comment)    comment="$2";  shift 2 ;;
            --no-defunct) defunct_after=0; shift ;;
            *)
                ui_error "Unknown option: $1"
                cmd_help
                return 1
                ;;
        esac
    done

    ui_banner
    ui_section "Add Manual Bypass Rule"
    ui_kv "Protocol"   "$proto"
    ui_kv "Src IP"     "$src_ip"
    ui_kv "Dst IP"     "$dst_ip"
    ui_kv "Src Port"   "$sport"
    ui_kv "Dst Port"   "$dport"
    ui_kv "Interface"  "$iface"
    ui_kv "Persistent" "$persist"
    ui_kv "Comment"    "$comment"
    [ "$defunct_after" = "0" ] && ui_kv "Defunct" "SKIP"

    # DEBUG PR1
    rules_validate "$proto" "$src_ip" "$dst_ip" "$sport" "$dport" "$iface" "$comment" || return 1

    local new_id
    new_id=$(rules_add "$proto" "$src_ip" "$dst_ip" "$sport" "$dport" "$iface" "$persist" "$comment")
    ui_ok "Rule $new_id added to $RULES_FILE"

    nft_apply

    if [ "$defunct_after" = "1" ]; then
        ui_info "Flushing matched connections..."
        ct_clear_rule_marks "$proto" "$src_ip" "$dst_ip" "$sport" "$dport" "$iface"
    else
        ui_info "Skipped connection flush (--no-defunct)"
        ui_info "New connections will be affected, existing ones will keep their state"
    fi

    ui_ok "Bypass rule $new_id is active"
}

# ─── COMMAND: list ────────────────────────────────────────────────────────────
cmd_list() {
    ui_banner
    ui_section "Active NSS Bypass Rules"
    rules_list
    echo ""
    ui_kv "Rules file" "$RULES_FILE"
    ui_kv "Firewall script" "$FW_SCRIPT"
    if nft_chains_exist 2>/dev/null; then
        ui_ok "NSS-Switch chains are live in nftables"
    else
        ui_warn "NSS-Switch chains NOT in live ruleset — run: nss-switch apply"
    fi
}

# ─── COMMAND: remove ──────────────────────────────────────────────────────────
cmd_remove() {

    # DEBUG PR 1
    # echo "DEBUG: $# arguments: $@" >&2

    check_root
    local id="$1"

    # DEBUG PR 1
    # echo "DEBUG: id=$id" >&2

    if [ -z "$id" ]; then
        ui_error "Usage: nss-switch remove <rule-id>"
        return 1
    fi
    ui_banner
    ui_section "Remove Rule $id"

    local line
    line=$(rules_get "$id") || { ui_error "Rule $id not found"; return 1; }
    rules_parse "$line"
    ui_kv "ID"      "$RULE_ID"
    ui_kv "Proto"   "$RULE_PROTO"
    ui_kv "Src IP"  "$RULE_SRC_IP"
    ui_kv "Dst IP"  "$RULE_DST_IP"
    ui_kv "Sport"   "$RULE_SPORT"
    ui_kv "Dport"   "$RULE_DPORT"
    ui_kv "Iface"   "$RULE_IFACE"
    ui_kv "Comment" "$RULE_COMMENT"

    ui_confirm "Remove this rule?" || { ui_warn "Aborted"; return 0; }

    rules_remove "$id"
    nft_apply

    ui_info "Clearing conntrack entries for this rule..."
    ct_clear_rule_marks "$RULE_PROTO" "$RULE_SRC_IP" "$RULE_DST_IP" \
        "$RULE_SPORT" "$RULE_DPORT" "$RULE_IFACE"

    ui_info "Defuncting ECM so NSS can re-accelerate..."
    ecm_defunct_all

    ui_ok "Rule $id removed. ECM will re-evaluate and re-accelerate those flows."
}

# ─── COMMAND: flush ───────────────────────────────────────────────────────────
cmd_flush() {
    check_root
    local mode="${1:---rules}"
    ui_banner
    ui_section "Flush NSS-Switch Rules"

    case "$mode" in
        --rules)
            ui_info "Removing all bypass rules from nftables (keeping rules.conf)"
            ui_confirm "Continue?" || return 0
            # Clear rules.conf, regenerate (empty) script, reload
            rules_clear
            nft_apply
            ecm_defunct_all
            ui_ok "All rules flushed from nftables. ECM will re-accelerate all flows."
            ;;
        # DEBUG PR-1
        --all)
            ui_warn "This removes ALL NSS-Switch configuration including persistent rules"
            ui_confirm "Are you sure?" || return 0
            rules_clear
            nft_apply
            ecm_defunct_all
            # Remove fw4 include
            _nft_remove_uci_include

            # DEBUG PR-1
            rm -f "$FW_SCRIPT" 2>/dev/null || true
            conntrack -D -m "$NSS_MARK" 2>/dev/null

            ui_ok "NSS-Switch fully removed. Reload firewall to clean live rules."
            ;;
        --temp)
            ui_info "Removing only non-persistent (temporary) rules"
            ui_confirm "Continue?" || return 0
            rules_clear_temp
            nft_apply
            ecm_defunct_all
            ui_ok "Temporary rules flushed"
            ;;
        *)
            ui_error "Usage: nss-switch flush [--rules|--all|--temp]"
            return 1
            ;;
    esac
}

# ─── COMMAND: apply ───────────────────────────────────────────────────────────
# Re-generate script and reload firewall (useful after manual edits)
cmd_apply() {
    check_root
    ui_banner
    ui_info "Regenerating firewall script from rules.conf and reloading..."
    nft_apply
    ui_ok "Applied. Current rules:"
    rules_list
}

# ─── COMMAND: debug ───────────────────────────────────────────────────────────
cmd_debug() {
    local subcmd="${1:-env}"
    shift 2>/dev/null || true

    ui_banner
    case "$subcmd" in
        env)
            detect_check_all
            ;;
        ecm)
            ecm_debug_dump
            ;;
        nft)
            nft_show_our_rules
            ;;
        conntrack)
            ct_debug_raw
            ;;
        mark)
            ct_debug_mark
            ;;
        defunct-all)
            check_root
            ui_warn "This will defunct ALL connections in ECM — they will be re-evaluated"
            ui_confirm "Proceed?" || return 0
            ecm_defunct_all
            ;;
        frontend-stop)
            check_root
            local fam="${1:-both}"
            case "$fam" in
                ipv4) ecm_stop_ipv4 ;;
                ipv6) ecm_stop_ipv6 ;;
                both) ecm_stop_ipv4; ecm_stop_ipv6 ;;
                *)    ui_error "Usage: debug frontend-stop [ipv4|ipv6|both]"; return 1 ;;
            esac
            ;;
        frontend-restart)
            check_root
            ecm_restart
            ui_ok "ECM service restarted"
            ;;
        log)
            cmd_debug_log
            ;;
        log-clear)
            if [ -f "$DEBUG_LOG" ]; then
                > "$DEBUG_LOG"
                ui_ok "Debug log cleared"
            else
                ui_warn "Debug log not active or not found"
            fi
            ;;
        rules-raw)
            ui_section "Raw rules.conf"
            cat "$RULES_FILE" 2>/dev/null || ui_warn "No rules file"
            ;;
        script-raw)
            ui_section "Raw generated firewall script"
            cat "$FW_SCRIPT" 2>/dev/null || ui_warn "No script generated yet"
            ;;
        monitor)
            cmd_debug_monitor "$@"
            ;;
        *)
            ui_error "Unknown debug subcommand: $subcmd"
            cmd_debug_help
            return 1
            ;;
    esac
}

cmd_debug_help() {
    printf "\n${C_BOLD}debug subcommands:${C_RESET}\n"
    printf "  %-25s %s\n" "env"              "Full environment check"
    printf "  %-25s %s\n" "ecm"              "ECM/NSS state dump"
    printf "  %-25s %s\n" "nft"              "Show our live nftables chains"
    printf "  %-25s %s\n" "conntrack"        "Dump raw /proc/net/nf_conntrack"
    printf "  %-25s %s\n" "mark"             "Show conntrack entries with our bypass mark"
    printf "  %-25s %s\n" "defunct-all"      "Force defunct ALL connections in ECM"
    printf "  %-25s %s\n" "frontend-stop [ipv4|ipv6|both]" "Stop NSS frontend(s)"
    printf "  %-25s %s\n" "frontend-restart" "Restart ECM service"
    printf "  %-25s %s\n" "log"              "Enable/Disable debugging log"
    printf "  %-25s %s\n" "log-clear"        "Clear debug log"
    printf "  %-25s %s\n" "rules-raw"        "Show raw rules.conf content"
    printf "  %-25s %s\n" "script-raw"       "Show raw generated firewall script"
}

# ─── COMMAND: config ──────────────────────────────────────────────────────────
cmd_config() {
    local key="$1" val="$2"
    ui_banner
    ui_section "NSS-Switch Configuration"

    # DEBUG PR-1 UCI show config
    if [ -z "$key" ]; then
        uci show nss-switch.settings 2>/dev/null | sed 's/^nss-switch\.settings\.//'
        return 0
    fi

    # Set a config value
    case "$key" in
        PERSIST_DEFAULT) uci_key="persist_default" ;;
        DEBUG_MODE)      uci_key="debug_mode" ;;
        WATCH_INTERVAL)  uci_key="watch_interval" ;;
        *)
            ui_error "Unknown config key: $key"
            ui_info "Valid keys: PERSIST_DEFAULT, DEBUG_MODE, WATCH_INTERVAL"
            return 1
            ;;
    esac

    uci set nss-switch.settings."$uci_key"="$val"
    uci commit nss-switch
    ui_ok "Set $key=$val"
}

# ─── COMMAND: status ──────────────────────────────────────────────────────────
cmd_status() {
    ui_banner

    ui_section "NSS-Switch Status"
    local r_total r_temp r_persist
    r_total=$(rules_count)
    r_temp=$(grep -c '|no|'  "$RULES_FILE" 2>/dev/null || echo 0)
    r_persist=$(grep -c '|yes|' "$RULES_FILE" 2>/dev/null || echo 0)

    ui_kv "Rules defined"  "$r_total  (${r_persist} persist, ${r_temp} temp)"
    ui_kv "Rules file"     "$RULES_FILE"

    echo ""
    local fe eng mark_avail
    fe=$(ecm_frontend)
    eng=$(ecm_engine)
    mark_avail=$(ecm_mark_classifier_available && echo "AVAILABLE" || echo "MISSING")
    local fe_color="$FG_GREEN"
    case "$fe" in SFE) fe_color="$FG_YELLOW";; UNKNOWN) fe_color="$FG_RED";; esac
    local mk_color="$FG_GREEN"
    [ "$mark_avail" = "MISSING" ] && mk_color="$FG_RED"

    printf "  ${C_DIM}%-22s${C_RESET} %b${C_BOLD}%s${C_RESET}  ${C_DIM}engine=%s${C_RESET}\n" \
        "ECM frontend:" "$fe_color" "$fe" "$eng"
    printf "  ${C_DIM}%-22s${C_RESET} %b${C_BOLD}%s${C_RESET}\n" \
        "Mark classifier:" "$mk_color" "$mark_avail"

    echo ""
    local ct_total ct_bypass
    ct_total=$(ct_count)
    ct_bypass=$(ct_count_bypassed)
    ui_kv "Conntrack total"  "$ct_total"
    printf "  ${C_DIM}%-22s${C_RESET} ${FG_ORANGE}${C_BOLD}%s${C_RESET}" "Bypassed (CPU):" "$ct_bypass"
    if [ "$ct_total" -gt 0 ]; then
        printf "  "
        local prog_width=20
        [ $TERM_COLS -gt 80 ] && prog_width=30
        ui_progress_bar "$ct_bypass" "$ct_total" $prog_width "of total"
    fi
    printf "\n"

    echo ""
    if nft_chains_exist 2>/dev/null; then
        ui_ok "NSS-Switch nft chains: ${FG_GREEN}LIVE${C_RESET}"
    else
        ui_warn "NSS-Switch nft chains: NOT ACTIVE — run: nss-switch apply"
    fi
    ui_kv "Our ct mark" "$NSS_MARK"

    ui_section "Active Rules"
    rules_list
}

# ─── HELP ─────────────────────────────────────────────────────────────────────
cmd_help() {
    ui_banner
    printf "\n${C_BOLD}Usage:${C_RESET}  ${FG_ACCENT}nss-switch${C_RESET} ${C_BOLD}<command>${C_RESET} [options]\n\n"

    printf "${C_BOLD}${FG_BRIGHT}Commands:${C_RESET}\n"
    _help_cmd "watch [--once] [interval]"       "Live connection monitor  ${C_DIM}(btop-style, Ctrl+C to exit, use terminal scroll)${C_RESET}"
    _help_cmd "pick"                             "Interactive: browse connections and bypass one"
    _help_cmd "add [options]"                    "Manually add a bypass rule"
    _help_cmd "list"                             "List all defined bypass rules"
    _help_cmd "remove <id>"                      "Remove a bypass rule by ID"
    _help_cmd "flush [--rules|--all|--temp]"     "Remove rules from nftables"
    _help_cmd "apply"                            "Re-apply rules.conf to nftables"
    _help_cmd "status"                           "Full status dashboard"
    _help_cmd "config [KEY] [VALUE]"             "View or set configuration"
    _help_cmd "debug <subcommand>"               "Debug and diagnostic tools"
    printf "\n"

    printf "${C_BOLD}${FG_BRIGHT}add options:${C_RESET}\n"
    _help_opt "--proto tcp|udp|icmp|any"  "Match protocol"
    _help_opt "--src-ip <IP/CIDR>"        "Match source IP or subnet"
    _help_opt "--dst-ip <IP/CIDR>"        "Match destination IP or subnet"
    _help_opt "--src-port <port>"         "Match source port (tcp/udp)"
    _help_opt "--dst-port <port>"         "Match destination port"
    _help_opt "--iface <interface>"       "Match input interface  (out:<iface> for egress)"
    _help_opt "--persist"                 "Survive reboot"
    _help_opt "--temp"                    "Temporary, lost on reboot (default)"
    _help_opt "--comment <text>"          "Human-readable label"
    _help_opt "--no-defunct"             "Skip ECM defunct after adding"
    printf "\n"

    printf "${C_BOLD}${FG_BRIGHT}Examples:${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch add --iface lan2 --persist --comment 'Deco off NSS'${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch add --src-ip 192.168.1.50 --comment 'PC off NSS'${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch add --proto tcp --dst-port 22 --temp${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch watch${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch pick${C_RESET}\n"
    printf "  ${FG_ACCENT}nss-switch debug env${C_RESET}\n"
    printf "\n"
    cmd_debug_help
    printf "\n"
}

_help_cmd() {
    printf "  ${FG_ACCENT}${C_BOLD}%-36s${C_RESET}  %b\n" "$1" "$2"
}

_help_opt() {
    printf "  ${C_DIM}%-32s${C_RESET}  %s\n" "$1" "$2"
}

# ─── MAIN DISPATCHER ──────────────────────────────────────────────────────────
COMMAND="${1:-help}"
shift 1 2>/dev/null || true

case "$COMMAND" in
    watch)           cmd_watch "$@"   ;;
    pick)            cmd_pick  "$@"   ;;
    add)             cmd_add   "$@"   ;;
    list)            cmd_list  "$@"   ;;
    remove|rm)       cmd_remove "$@"  ;;
    flush)           cmd_flush "$@"   ;;
    apply)           cmd_apply "$@"   ;;
    status)          cmd_status "$@"  ;;
    config)          cmd_config "$@"  ;;
    debug)           cmd_debug "$@"   ;;
    help|-h|--help)  cmd_help         ;;
    *)
        ui_error "Unknown command: $COMMAND"
        cmd_help
        exit 1
        ;;
esac
