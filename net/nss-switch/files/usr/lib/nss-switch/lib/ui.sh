#!/usr/bin/env ash
# lib/ui.sh — UI helpers: TUI dashboard, colors, interactive prompts
# NSS-Switch — ASH compatible, BusyBox v1.37+
# Features: dynamic terminal size, btop-style layout, proper Ctrl+C handling

# ─── Column width configuration (unified for all tables) ─────────────────────
# IPv6 max compressed: 39 chars + []:port = ~45-50 chars
# FIXED widths - NO dynamic calculation that truncates IPv6
UI_SRC_WIDTH=40
UI_DST_WIDTH=40
UI_NUM_WIDTH=4
UI_PROTO_WIDTH=6
UI_IFACE_WIDTH=15
UI_NSS_WIDTH=4
UI_BYPASS_WIDTH=6


# ─── Terminal geometry ────────────────────────────────────────────────────────
ui_get_term_size() {
    local sz
    sz=$(stty size 2>/dev/null)
    if [ -n "$sz" ]; then
        TERM_ROWS=$(echo "$sz" | cut -d' ' -f1)
        TERM_COLS=$(echo "$sz" | cut -d' ' -f2)
    else
        TERM_ROWS=24
        TERM_COLS=80
    fi
    [ "$TERM_ROWS" -lt 10 ] && TERM_ROWS=10
    [ "$TERM_COLS" -lt 40 ] && TERM_COLS=40
}

# ─── ANSI escape shortcuts ────────────────────────────────────────────────────
ui_cursor_home()                { printf '\033[H'; }
ui_cursor_pos()                 { printf '\033[%d;%dH' "$1" "$2"; }
ui_cursor_hide()                { printf '\033[?25l'; }
ui_cursor_show()                { printf '\033[?25h'; }
ui_clear_screen()               { printf '\033[2J'; }
ui_clear_screen_scrollback()    { printf '\033[2J\033[3J'; }
ui_alt_screen_on()              { printf '\033[?1049h'; }
ui_alt_screen_off()             { printf '\033[?1049l'; }
ui_clear_eol()                  { printf '\033[K'; }
ui_clear_cursor_bellow()        { printf '\033[J'; }

# ─── Colors ───────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
    ESC=$(printf '\033')
    C_RED="${ESC}[0;31m"
    C_GREEN="${ESC}[0;32m"
    C_YELLOW="${ESC}[0;33m"
    C_BLUE="${ESC}[0;34m"
    C_MAGENTA="${ESC}[0;35m"
    C_CYAN="${ESC}[0;36m"
    C_BOLD="${ESC}[1m"
    C_DIM="${ESC}[2m"
    C_ITALIC="${ESC}[3m"
    C_UNDER="${ESC}[4m"
    C_INVERT="${ESC}[7m"
    C_RESET="${ESC}[0m"
    BG_DARK="${ESC}[48;2;12;18;28m"
    BG_MED="${ESC}[48;2;22;32;48m"
    BG_ACCENT="${ESC}[48;2;0;70;110m"
    BG_GREEN="${ESC}[48;2;0;70;35m"
    BG_RED="${ESC}[48;2;90;18;18m"
    BG_YELLOW="${ESC}[48;2;80;60;0m"
    FG_BRIGHT="${ESC}[38;2;200;225;255m"
    FG_DIM="${ESC}[38;2;70;90;115m"
    FG_ACCENT="${ESC}[38;2;60;190;255m"
    FG_GREEN="${ESC}[38;2;70;210;110m"
    FG_RED="${ESC}[38;2;255;90;90m"
    FG_YELLOW="${ESC}[38;2;255;195;70m"
    FG_ORANGE="${ESC}[38;2;255;135;35m"
else
    C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA=''
    C_CYAN='' C_BOLD='' C_DIM='' C_ITALIC='' C_UNDER='' C_INVERT='' C_RESET=''
    BG_DARK='' BG_MED='' BG_ACCENT='' BG_GREEN='' BG_RED='' BG_YELLOW=''
    FG_BRIGHT='' FG_DIM='' FG_ACCENT='' FG_GREEN='' FG_RED='' FG_YELLOW=''
    FG_ORANGE=''
fi

# ─── Box-drawing chars ────────────────────────────────────────────────────────
BOX_TL='╔' BOX_TR='╗' BOX_BL='╚' BOX_BR='╝'
BOX_H='═'  BOX_V='║'
BOX_ML='╠' BOX_MR='╣'
SLIM_TL='┌' SLIM_TR='┐' SLIM_BL='└' SLIM_BR='┘'
SLIM_H='─'  SLIM_V='│'
SLIM_ML='├' SLIM_MR='┤'
TICK='✓' CROSS='✗' WARN_SYM='⚠' INFO_SYM='ℹ' ARROW='▶' DOT='•'
BAR_FULL='█' BAR_EMPTY='░'

# ─── Internal: repeat char N times ───────────────────────────────────────────
_rep() {
    local char="$1" n="$2" i=0
    while [ "$i" -lt "$n" ]; do
        printf '%s' "$char"
        i=$((i+1))
    done
}

# ─── Print helpers ────────────────────────────────────────────────────────────
ui_info()  { printf "${FG_ACCENT}${INFO_SYM}${C_RESET}  %s\n" "$*"; }
ui_ok()    { printf "${FG_GREEN}${TICK}${C_RESET}  %s\n" "$*"; }
ui_warn()  { printf "${FG_YELLOW}${WARN_SYM}${C_RESET}  %s\n" "$*"; }
ui_error() { printf "${FG_RED}${CROSS}${C_RESET}  %s\n" "$*" >&2; }
ui_debug() { printf "${C_DIM}[DBG]  %s${C_RESET}\n" "$*"; }
ui_bold()  { printf "${C_BOLD}%s${C_RESET}\n" "$*"; }

ui_section() {
    ui_get_term_size 2>/dev/null || true
    local title="$*" w="${TERM_COLS:-80}"
    printf "\n${FG_ACCENT}${SLIM_ML}"
    _rep "$SLIM_H" 2
    printf " ${C_BOLD}${FG_BRIGHT}%s${C_RESET}${FG_ACCENT} " "$title"
    local used=$(( ${#title} + 6 ))
    local remain=$(( w - used - 1 ))
    [ "$remain" -gt 0 ] && _rep "$SLIM_H" "$remain"
    printf "${SLIM_MR}${C_RESET}\n"
}


# ─── Check terminal width ─────────────────────────────────────────────────────
ui_check_width() {
    ui_get_term_size
    local min_width=120

    if [ $TERM_COLS -lt $min_width ]; then
        ui_clear_screen
        ui_cursor_home


        printf " Buenísima idea pero mal aplicada aún..."
        printf "Sólo debería ver esto cuando la shell es >120px!"

        # Loop hasta que el ancho sea suficiente
        while [ $TERM_COLS -lt $min_width ]; do
            sleep 1
            ui_get_term_size
        done

        # Limpiar y continuar
        ui_clear_screen
        ui_cursor_home
        return 0
    fi

    return 0
}


# ─── Calculate total table width (sum of all columns + spaces) ────────────────
ui_table_width() {
    local num_spaces=6
    echo $(( UI_NUM_WIDTH + UI_PROTO_WIDTH + UI_SRC_WIDTH + UI_DST_WIDTH + UI_IFACE_WIDTH + UI_NSS_WIDTH + UI_BYPASS_WIDTH + num_spaces ))
}

# ─── Separator line matching table width (not terminal width) ─────────────────
ui_sep() {
    local w
    w=$(ui_table_width)
    printf "${FG_DIM}"
    _rep "$SLIM_H" "$w"
    printf "${C_RESET}\n"
}

ui_kv() {
    printf "  ${C_DIM}%-22s${C_RESET} ${C_BOLD}%s${C_RESET}\n" "${1}:" "$2"
}

# ─── Progress bar: value max width ───────────────────────────────────────────
ui_progress_bar() {
    local val="$1" max="$2" width="$3" label="${4:-}"
    [ "$max" -le 0 ] && max=1
    local filled=$(( val * width / max ))
    [ "$filled" -gt "$width" ] && filled="$width"
    local empty=$(( width - filled ))
    local pct=$(( val * 100 / max ))
    local color="$FG_GREEN"
    [ "$pct" -gt 60 ] && color="$FG_YELLOW"
    [ "$pct" -gt 85 ] && color="$FG_RED"
    printf "${C_DIM}[${C_RESET}${color}"
    _rep "$BAR_FULL" "$filled"
    printf "${C_DIM}"
    _rep "$BAR_EMPTY" "$empty"
    printf "]${C_RESET} ${C_BOLD}%3d%%${C_RESET}" "$pct"
    [ -n "$label" ] && printf " ${C_DIM}%s${C_RESET}" "$label"
}

# ─── Banner ───────────────────────────────────────────────────────────────────
ui_banner() {
    ui_get_term_size 2>/dev/null || true
    local w="${TERM_COLS:-80}" inner
    inner=$(( w - 2 ))

    printf "${FG_ACCENT}"
    printf '%s' "$BOX_TL"; _rep "$BOX_H" "$inner"; printf '%s\n' "$BOX_TR"

    local l1="NSS-Switch  v1.0" l2="Qualcomm NSS selective bypass"
    local p1=$(( (inner - ${#l1}) / 2 ))
    local p2=$(( (inner - ${#l2}) / 2 ))

    printf '%s' "$BOX_V"
    _rep ' ' "$p1"
    printf "${C_BOLD}${FG_BRIGHT}%s${C_RESET}${FG_ACCENT}" "$l1"
    _rep ' ' "$(( inner - p1 - ${#l1} ))"
    printf '%s\n' "$BOX_V"

    printf '%s' "$BOX_V"
    _rep ' ' "$p2"
    printf "${C_DIM}%s${C_RESET}${FG_ACCENT}" "$l2"
    _rep ' ' "$(( inner - p2 - ${#l2} ))"
    printf '%s\n' "$BOX_V"

    printf '%s' "$BOX_BL"; _rep "$BOX_H" "$inner"; printf '%s\n' "$BOX_BR"
    printf "${C_RESET}"
}

# ─── Header bar (usa el ancho de la tabla) ──────────────────────────────
ui_header_bar() {
    local title="$1" subtitle="$2" right="$3"
    local table_width
    table_width=$(ui_table_width)

    # Truncate title if too long for table width
    local max_title_len=$(( table_width / 3 ))
    [ ${#title} -gt $max_title_len ] && title="${title:0:$((max_title_len-3))}..."

    local left_len=$(( ${#title} + ${#subtitle} + 3 ))
    local right_len=${#right}
    local pad=$(( table_width - left_len - right_len - 2 ))
    [ "$pad" -lt 1 ] && pad=1

    printf '%b%b%b %s%b  %s%b' \
        "$BG_DARK" "$FG_ACCENT" "$C_BOLD" "$title" \
        "${C_RESET}${BG_DARK}${FG_DIM}" "$subtitle" "${C_RESET}${BG_DARK}"
    _rep ' ' "$pad"
    printf '%b%s %b\n' "$FG_BRIGHT" "$right" "$C_RESET"
}

# ─── Keybind hint bar - usa el ancho de la tabla ──────────────────────────────
ui_hint_bar() {
    local hints="$*"
    local table_width
    table_width=$(ui_table_width)

    printf "${BG_DARK}${FG_DIM} %s" "$hints"
    local used=$(( ${#hints} + 1 ))
    local pad=$(( table_width - used ))
    [ "$pad" -gt 0 ] && _rep ' ' "$pad"
    printf "${C_RESET}${C_DIM}%b" "$(ui_clear_eol)"
    printf "\n"
}

# ─── Watch stats panel ────────────────────────────────────────────────────────
ui_watch_stats_panel() {
    local total="$1" bypassed="$2" frontend="$3" engine="$4"
    local rules="$5" interval="$6"
    local normal=$(( total - bypassed ))

    ui_get_term_size
    # ui_calc_column_widths

    printf "\n"

    # Connections line - use full width
    printf "  ${FG_BRIGHT}${C_BOLD}%-14s${C_RESET}" "Connections"
    printf "  ${FG_GREEN}${C_BOLD}%d${C_RESET} total" "$total"
    printf "  ${FG_ACCENT}${C_BOLD}%d${C_RESET} NSS/HW" "$normal"
    printf "  ${FG_ORANGE}${C_BOLD}%d${C_RESET} CPU-bypass" "$bypassed"
    printf "   "
    if [ "$total" -gt 0 ]; then
        local prog_width=$(( TERM_COLS - 70 ))
        [ $prog_width -lt 10 ] && prog_width=10
        [ $prog_width -gt 30 ] && prog_width=30
        ui_progress_bar "$bypassed" "$total" $prog_width "bypass ratio"
    else
        printf "${C_DIM}no connections${C_RESET}"
    fi
    printf "\n"

    # ECM line
    printf "  ${FG_BRIGHT}${C_BOLD}%-14s${C_RESET}" "ECM"
    local fe_color="$FG_GREEN"
    case "$frontend" in SFE) fe_color="$FG_YELLOW" ;; UNKNOWN) fe_color="$FG_RED" ;; esac
    printf "  ${fe_color}${C_BOLD}%s${C_RESET}" "$frontend"
    printf "  ${C_DIM}engine=${C_RESET}${C_BOLD}%s${C_RESET}" "$engine"
    printf "  ${C_DIM}rules=${C_RESET}${FG_ACCENT}${C_BOLD}%s${C_RESET}" "$rules"
    printf "  ${C_DIM}refresh=${C_RESET}${C_BOLD}%ss${C_RESET}" "$interval"
    printf "\n\n"
}




# ─── Connection table header ──────────────────────────────────────────────────
ui_conn_header() {
    local total_width
    total_width=$(ui_table_width)

    printf "${BG_MED}${FG_DIM}"
    printf " %-${UI_NUM_WIDTH}s %-${UI_PROTO_WIDTH}s %-${UI_SRC_WIDTH}s %-${UI_DST_WIDTH}s %-${UI_IFACE_WIDTH}s %-${UI_NSS_WIDTH}s %-${UI_BYPASS_WIDTH}s" \
        "NUM" "PROTO" "SOURCE" "DESTINATION" "INTERFACE" "NSS" "BYPASS"
    printf "${C_RESET}\n"

    # Dibujar separador del mismo ancho
    printf "${FG_DIM}"
    _rep "$SLIM_H" "$total_width"
    printf "${C_RESET}\n"
}

# ─── Map port to service name (max 6 chars) ───────────────────────────────────
_proto_to_service() {
    local proto="$1"
    local port="$2"

    # Si es ICMP, mantener como está
    case "$proto" in
        icmp|icmpv6)
            echo "$proto"
            return
            ;;
    esac

    # Traducir por puerto
    case "$port" in
        22)   echo "SSH" ;;
        25)   echo "SMTP" ;;
        53)   echo "DNS" ;;
        80)   echo "HTTP" ;;
        110)  echo "POP3" ;;
        123)  echo "NTP" ;;
        143)  echo "IMAP" ;;
        194)  echo "IRC" ;;
        443)  echo "HTTPS" ;;
        465)  echo "SMTPS" ;;
        587)  echo "SMTP" ;;
        853)  echo "DNS" ;;
        993)  echo "IMAPS" ;;
        995)  echo "POP3S" ;;
        1433) echo "MSSQL" ;;
        1723) echo "PPTP" ;;
        2082) echo "CPANEL" ;;
        2083) echo "CPANEL" ;;
        2086) echo "WHM" ;;
        2087) echo "WHM" ;;
        2095) echo "WEBMAIL" ;;
        2096) echo "WEBMAIL" ;;
        3306) echo "MYSQL" ;;
        3389) echo "RDP" ;;
        5060) echo "SIP" ;;
        5061) echo "SIPS" ;;
        5222) echo "XMPP" ;;
        5228) echo "GCM" ;;
        5432) echo "PG" ;;
        5900) echo "VNC" ;;
        5901) echo "VNC" ;;
        5902) echo "VNC" ;;
        5903) echo "VNC" ;;
        5904) echo "VNC" ;;
        5905) echo "VNC" ;;
        5906) echo "VNC" ;;
        5907) echo "VNC" ;;
        5908) echo "VNC" ;;
        5909) echo "VNC" ;;
        5910) echo "VNC" ;;
        5911) echo "VNC" ;;
        5912) echo "VNC" ;;
        5913) echo "VNC" ;;
        5914) echo "VNC" ;;
        5915) echo "VNC" ;;
        6379) echo "REDIS" ;;
        6666) echo "IRC" ;;
        6667) echo "IRCssl" ;;
        8080) echo "HTTP" ;;
        8443) echo "HTTPS" ;;
        8888) echo "HTTP" ;;
        9000) echo "PHP" ;;
        9090) echo "HTTP" ;;
        9100) echo "PJL" ;;
        9200) echo "ES" ;;
        9418) echo "GIT" ;;
        11211) echo "MEMCACHE" ;;
        27017) echo "MONGO" ;;
        27018) echo "MONGO" ;;
        27019) echo "MONGO" ;;
        51820) echo "WG" ;;
        *)
            echo "$proto"
            ;;
    esac
}


# ─── Connection row ───────────────────────────────────────────────────────────
ui_conn_row() {
    local num="$1" proto="$2" src="$3" dst="$4"
    local iface="$5" nss="$6" bypass="$7"

    # Extraer puerto destino para la traducción
    # Tal y como funciona nuestro parser NECESITAMOS partirlo en #, pero ante otros casos ... switch case
    local dst_port
    case "$dst" in
        *'#'*)
            dst_port="${dst##*#}" ;;
        *']:'*)
            dst_port="${dst##*]:}" ;;
        *:*)
            dst_port="${dst##*:}" ;;
        *)
            dst_port="" ;;
    esac

    # Traducir protocolo a nombre de servicio (si aplica)
    local service_name
    service_name=$(_proto_to_service "$proto" "$dst_port")

    local proto_c="$C_RESET"
    case "$service_name" in
        HTTP|HTTPS)       proto_c="$FG_GREEN" ;;
        SSH|WG)           proto_c="$FG_CYAN" ;;
        DNS)              proto_c="$FG_YELLOW" ;;
        MYSQL|PG|MONGO|REDIS|MEMCACHE) proto_c="$FG_MAGENTA" ;;
        *)
            case "$proto" in
                tcp)   proto_c="$FG_ACCENT" ;;
                udp)   proto_c="$FG_YELLOW" ;;
                icmp*) proto_c="$FG_ORANGE" ;;
                *)     proto_c="$C_RESET" ;;
            esac
            ;;
    esac

    local nss_c
    case "$nss" in
        HW)  nss_c="$FG_GREEN"  ;;
        SFE) nss_c="$FG_YELLOW" ;;
        CPU) nss_c="$FG_RED"    ;;
        *)   nss_c="$C_DIM"     ;;
    esac

    local byp_c byp_s
    if [ "$bypass" = "YES" ]; then byp_c="$FG_ORANGE" byp_s="BYPASS"
    else                           byp_c="$C_DIM"     byp_s="-"
    fi

    local iface_c="$C_RESET"
    case "$iface" in local:*) iface_c="$C_DIM" ;; esac

    # Alternate row bg
    local row_bg=""
    [ $(( num % 2 )) -eq 0 ] && row_bg="$BG_MED"

    printf '%b %b%-*s%b%b %b%-*s%b%b' \
        "$row_bg" "$C_BOLD" "$UI_NUM_WIDTH" "$num" "$C_RESET" "$row_bg" \
        "$proto_c" "$UI_PROTO_WIDTH" "$service_name" "$C_RESET" "$row_bg"
    printf " %-*s %-*s " "$UI_SRC_WIDTH" "$src" "$UI_DST_WIDTH" "$dst"
    printf '%b%-*s%b%b %b%-*s%b%b %b%-*s%b\n' \
        "$iface_c" "$UI_IFACE_WIDTH" "$iface" "$C_RESET" "$row_bg" \
        "$nss_c" "$UI_NSS_WIDTH" "$nss" "$C_RESET" "$row_bg" \
        "$byp_c" "$UI_BYPASS_WIDTH" "$byp_s" "$C_RESET"
}

# ─── Rule list header/row ─────────────────────────────────────────────────────
ui_rule_header() {
    printf "${BG_MED}${FG_DIM}"
    printf " %-4s %-6s %-${UI_SRC_WIDTH}s %-${UI_DST_WIDTH}s %-7s %-7s %-12s %-8s %s" \
        "ID" "PROTO" "SRC_IP" "DST_IP" "SPORT" "DPORT" "IFACE" "PERSIST" "COMMENT"
    printf "${C_RESET}\n"
    ui_sep
}

ui_rule_row() {

    # echo "DEBUG: id='$1' proto='$2' src='$3' dst='$4'" >&2

    local id="$1" proto="$2" src="$3" dst="$4"
    local sport="$5" dport="$6" iface="$7" persist="$8" comment="$9"

    local pc="$C_DIM" ps="temp"
    [ "$persist" = "yes" ] && pc="$FG_GREEN" ps="persist"
    local row_bg=""
    [ $(( id % 2 )) -eq 0 ] && row_bg="$BG_MED"

    # DEBUG
    local src_fmt="%-${UI_SRC_WIDTH}s"
    local dst_fmt="%-${UI_DST_WIDTH}s"

    printf "%b %b%-4s%b%b %b%-6s%b%b ${src_fmt} ${dst_fmt} %-7s %-7s %-12s %b%-8s%b%b %b%s%b\n" \
        "$row_bg" \
        "$FG_ACCENT" "$C_BOLD" "$id" "$C_RESET" "$row_bg" \
        "$FG_YELLOW" "$proto" "$C_RESET" "$row_bg" \
        "$src" "$dst" \
        "$sport" "$dport" "$iface" \
        "$pc" "$ps" "$C_RESET" "$row_bg" \
        "$C_DIM" "$comment" "$C_RESET"
}

# DEBUG
# viene de rules.sh -> rules_list()  ... subyacente de ui_rule_row()
# Si funciona bien, lo exportaremos a watch y pick
ui_rule_row_dynamic() {
    local rule_id="$1" proto="$2" src="$3" dst="$4"
    local sport="$5" dport="$6" iface="$7" persist="$8" comment="$9"
    local max_id="${10}" max_proto="${11}" max_src="${12}" max_dst="${13}"
    local max_sport="${14}" max_dport="${15}" max_iface="${16}" max_persist="${17}"

    # Configurar colores para persist
    local pc="${C_MAGENTA}" ps="temp"
    [ "$persist" = "yes" ] && pc="${FG_GREEN}${C_BOLD}" ps="persist"
    local row_bg=""
    [ $(( rule_id % 2 )) -eq 0 ] && row_bg="$BG_MED"

    local id_fmt="%-${max_id}s"
    local proto_fmt="%-${max_proto}s"
    local src_fmt="%-${max_src}s"
    local dst_fmt="%-${max_dst}s"
    local sport_fmt="%-${max_sport}s"
    local dport_fmt="%-${max_dport}s"
    local iface_fmt="%-${max_iface}s"
    local persist_fmt="%-${max_persist}s"

    printf '%b' "$row_bg"

    # ID con color amarillo bold
    printf " ${FG_YELLOW}${C_BOLD}"
    printf "${id_fmt}" "$rule_id"
    printf "${C_RESET}"

    # PROTO sin color
    printf " ${proto_fmt}" "$proto"

    # SRC sin color
    printf " ${src_fmt}" "$src"

    # DST sin color
    printf " ${dst_fmt}" "$dst"

    # SPORT sin color
    printf " ${sport_fmt}" "$sport"

    # DPORT sin color
    printf " ${dport_fmt}" "$dport"

    # IFACE sin color
    printf " ${iface_fmt}" "$iface"

    # PERSIST: temp en magenta dim, persist en green bold
    printf " %b" "$pc"
    printf "${persist_fmt}" "$ps"
    printf "${C_RESET}"

    # COMMENT con color gris
    printf " %b%s%b\n" "$C_BLUE" "$comment" "$C_RESET"
}


# ─── Ctrl+C safe: write dump to tmpfile before rendering ─────────────────────
# The core problem in ash pipes: `cmd | while read` puts 'while' in a subshell.
# Ctrl+C kills the subshell but the parent continues. Solution: tmpfile.
# Pattern:
#   tmpfile=$(mktemp /tmp/nss-watch.XXXXXX)
#   ct_dump_all_full > "$tmpfile"       # dump outside the rendering loop
#   while IFS='|' read ... < "$tmpfile" # read from file, no subshell
#   rm -f "$tmpfile"

# ─── Watch exit flag management ───────────────────────────────────────────────
_UI_EXIT=0

ui_watch_init() {
    _UI_EXIT=0
    # ui_alt_screen_on
    ui_cursor_hide
}

ui_watch_cleanup() {
    ui_cursor_show      # Mostrar cursor
    ui_clear_screen_scrollback # Limpia screen y scrollback
    ui_cursor_home         # Ir a home
    rm -f /tmp/nss-switch-pick.* /tmp/nss-switch-watch.* 2>/dev/null
    rm -f /tmp/nss-iface.* 2>/dev/null
}

# ─── Pick display: show ALL connections, normal terminal mode ─────────────────
# NO alt_screen - terminal scroll works normally
ui_pick_display_normal() {
    local tmpfile="$1" total="$2"
    ui_get_term_size

    while true; do
        ui_clear_screen
        ui_cursor_home

        ui_header_bar "NSS-Switch" "Connection Picker" "$(date +'%H:%M:%S')"
        ui_hint_bar "${ARROW} q=cancel  •  type number + Enter to select — ${total} connections total"
        printf "\n"

        ui_conn_header

        # Read entire file - show ALL connections
        local _display_tmp
        _display_tmp=$(mktemp /tmp/nss-display.XXXXXX)
        cat "$tmpfile" > "$_display_tmp"

        while IFS='|' read -r n proto src dst iface nss bypass mark state; do
            local sip sp dip dp ss ds
            sip=$(echo "$src" | cut -d'#' -f1)
            sp=$(echo "$src"  | cut -d'#' -f2)
            dip=$(echo "$dst" | cut -d'#' -f1)
            dp=$(echo "$dst"  | cut -d'#' -f2)
            if echo "$sip" | grep -q ":"; then ss="[${sip}]:${sp}"; else ss="${sip}:${sp}"; fi
            if echo "$dip" | grep -q ":"; then ds="[${dip}]:${dp}"; else ds="${dip}:${dp}"; fi
            ui_conn_row "$n" "$proto" "$ss" "$ds" "$iface" "$nss" "$bypass"
        done < "$_display_tmp"
        rm -f "$_display_tmp"

        ui_sep

        # Warning if terminal too narrow for IPv6
        if [ $TERM_COLS -lt 120 ] && [ $total -gt 0 ]; then
            printf "  ${FG_YELLOW}${WARN_SYM}${C_RESET} ${C_DIM}Terminal narrow (${TERM_COLS}c), IPv6 addresses may be truncated.${C_RESET}\n"
        fi

        printf "  ${C_DIM}Total connections: %d${C_RESET}\n" "$total"
        printf "\n  ${FG_ACCENT}${ARROW}${C_RESET} ${C_BOLD}Enter connection number (or q to cancel):${C_RESET} "

        # Simple read - no filtering, just read normally
        # In normal terminal mode, PgUp/PgDown will NOT be captured - they will scroll
        read -r _input

        # Clean the input - remove any non-digit and non-q characters
        local _cleaned=""
        _cleaned=$(printf '%s' "$_input" | tr -d -c '0-9qQ')
        _cleaned=$(echo "$_cleaned" | tr 'Q' 'q')

        case "$_cleaned" in
            q|'')
                return 1
                ;;
            [0-9]*)
                if [ "$_cleaned" -ge 1 ] 2>/dev/null && [ "$_cleaned" -le "$total" ] 2>/dev/null; then
                    UI_NUM="$_cleaned"
                    return 0
                else
                    printf "  ${FG_RED}${CROSS}${C_RESET} Out of range [1-%d] — press Enter to continue" "$total"
                    read -r _dummy
                fi
                ;;
            *)
                if [ -n "$_cleaned" ]; then
                    printf "  ${FG_RED}${CROSS}${C_RESET} Invalid input '%s' — press Enter to continue" "$_cleaned"
                else
                    printf "  ${FG_RED}${CROSS}${C_RESET} Invalid input — press Enter to continue"
                fi
                read -r _dummy
                ;;
        esac
    done
}

# ─── Ask yes/no ───────────────────────────────────────────────────────────────
ui_ask_yn() {
    local question="$1" default="${2:-n}" hint ans
    local valid=0

    # Construir hint visual
    case "$default" in
        y|Y) hint="${C_BOLD}Y${C_RESET}/${C_DIM}n${C_RESET}" ;;
        n|N) hint="${C_DIM}y/${C_RESET}${C_BOLD}N${C_RESET}" ;;
        *)   hint="y/n" ;;
    esac

    while [ $valid -eq 0 ]; do
        printf "  ${FG_ACCENT}${ARROW}${C_RESET} ${C_BOLD}%s${C_RESET} [%b]: " "$question" "$hint"
        read -r ans

        # Permitir salir con q/Q
        case "$ans" in
            q|Q|quit|exit|cancel)
                ui_warn "Operation cancelled by user"
                exit 0
                ;;
        esac

        # Si está vacío, usar default
        [ -z "$ans" ] && ans="$default"

        # Validar respuesta
        case "$ans" in
            y|Y|yes|YES|Yes)
                return 0
                ;;
            n|N|no|NO|No)
                return 1
                ;;
            *)
                ui_error "Invalid answer: '$ans', please answer 'yes' or 'no' (or 'q' to cancel)"
                ;;
        esac
    done
}

# ─── Ask with option list ─────────────────────────────────────────────────────
ui_ask_choice() {
    local question="$1"; shift
    local i=1 opt ans
    printf "\n  ${C_BOLD}%s${C_RESET}\n" "$question"
    for opt in "$@"; do
        printf "    ${FG_ACCENT}%d)${C_RESET} %s\n" "$i" "$opt"
        i=$((i+1))
    done
    printf "  ${FG_ACCENT}${ARROW}${C_RESET} ${C_BOLD}Choice [1-%d]:${C_RESET} " "$(($#))"
    read -r ans
    if ! echo "$ans" | grep -qE '^[0-9]+$'; then
        ui_error "Invalid choice"; UI_CHOICE=""; return 1
    fi
    i=1
    for opt in "$@"; do
        [ "$i" = "$ans" ] && { UI_CHOICE="$opt"; return 0; }
        i=$((i+1))
    done
    ui_error "Choice out of range"; UI_CHOICE=""; return 1
}

# ─── Ask free text ────────────────────────────────────────────────────────────
ui_ask_input() {
    local question="$1" default="$2" type="${3:-string}"
    local input

    while true; do
        printf "  ${FG_ACCENT}${ARROW}${C_RESET} ${C_BOLD}%s${C_RESET} ${C_DIM}[%s]${C_RESET}: " "$question" "$default"
        read -r input
        [ -z "$input" ] && input="$default"

        case "$type" in
            port)
                if [ "$input" = "any" ] || (echo "$input" | grep -qE '^[0-9]{1,5}$' && [ "$input" -ge 1 ] && [ "$input" -le 65535 ]); then
                    UI_INPUT="$input"
                    return 0
                fi
                ui_error "Invalid port: $input (must be 1-65535 or 'any')"
                ;;
            ip)
                if [ "$input" = "any" ] || nft_validate_ip "$input"; then
                    UI_INPUT="$input"
                    return 0
                fi
                ui_error "Invalid IP/CIDR: $input"
                ;;
            proto)
                if [ "$input" = "any" ] || nft_validate_proto "$input"; then
                    UI_INPUT="$input"
                    return 0
                fi
                ui_error "Invalid protocol: $input (tcp, udp, icmp, icmpv6, any)"
                ;;
            *)
                UI_INPUT="$input"
                return 0
                ;;
        esac
    done
}

# ─── Ask numeric ──────────────────────────────────────────────────────────────
ui_ask_num() {
    local question="$1" min="$2" max="$3"
    printf "\n  ${FG_ACCENT}${ARROW}${C_RESET} ${C_BOLD}%s${C_RESET} ${C_DIM}[%d-%d]${C_RESET}: " \
        "$question" "$min" "$max"
    read -r UI_NUM
    if [ -z "$UI_NUM" ]; then ui_error "Cancelled"; return 1; fi
    if ! echo "$UI_NUM" | grep -qE '^[0-9]+$'; then
        ui_error "Not a number: $UI_NUM"; return 1
    fi
    if [ "$UI_NUM" -lt "$min" ] || [ "$UI_NUM" -gt "$max" ]; then
        ui_error "Out of range [$min-$max]"; return 1
    fi
    return 0
}

# ─── Confirm ─────────────────────────────────────────────────────────────────
ui_confirm() { ui_ask_yn "$1" "n"; }

# ─── Spinner ──────────────────────────────────────────────────────────────────
# ─── Spinner with color cycling ──────────────────────────────────────────────
ui_spinner_start() {
    export _SPINNER_MSG="$1" _SPINNER_PID=""
    (
        local i=0
        while true; do
            local c color
            case $((i % 4)) in
                0) c='⠋' ; color="$FG_ACCENT" ;;
                1) c='⠙' ; color="$FG_GREEN" ;;
                2) c='⠸' ; color="$FG_YELLOW" ;;
                3) c='⠴' ; color="$FG_BRIGHT" ;;
            esac
            printf "\r  ${color}%s${C_RESET} ${C_DIM}%s${C_RESET}   " "$c" "$_SPINNER_MSG"
            i=$((i + 1))
            sleep 1
        done
    ) &
    _SPINNER_PID=$!
}

ui_spinner_stop() {
    if [ -n "$_SPINNER_PID" ]; then
        kill "$_SPINNER_PID" 2>/dev/null
        wait "$_SPINNER_PID" 2>/dev/null
        printf "\r%${TERM_COLS:-80}s\r" ""
        _SPINNER_PID=""
    fi
}
