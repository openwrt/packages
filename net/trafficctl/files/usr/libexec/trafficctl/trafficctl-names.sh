#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Manual device names (aliases), keyed by IP.
#
# Aliases take precedence over DHCP lease names and reverse DNS, which is what
# makes routed devices nameable: they have no lease on this router, so without
# an alias (or a PTR record) they would only ever show as "*".
#
# Usage: trafficctl-names.sh list|set <ip> <name>|remove <ip>
# Storage: /etc/trafficctl/names — one "IP NAME" line per device.

. /usr/libexec/trafficctl/trafficctl-fw.sh

NAMES_FILE="/etc/trafficctl/names"

# Strip anything that could break the line format or the JSON output, and cap
# the length so a pathological name can't bloat every poll response.
sanitize_name() {
    printf '%s' "$1" | tr -d '\n\r\t' | tr -cd 'a-zA-Z0-9 _.()-' | cut -c1-32
}

do_list() {
    printf '['
    [ -f "$NAMES_FILE" ] || { printf ']\n'; return 0; }
    awk 'NF >= 2 {
        ip = $1
        name = $0
        sub(/^[^ ]+ +/, "", name)
        if (n++) printf ","
        printf "{\"ip\":\"%s\",\"name\":\"%s\"}", ip, name
    }' "$NAMES_FILE"
    printf ']\n'
}

do_set() {
    local ip="$1" name="$2" tmp
    tctl_validate_ip "$ip" || { echo '{"ok":false,"msg":"invalid IP address"}'; return 1; }
    name=$(sanitize_name "$name")
    [ -z "$name" ] && { echo '{"ok":false,"msg":"name is empty after sanitizing"}'; return 1; }

    mkdir -p "$(dirname "$NAMES_FILE")"
    [ -f "$NAMES_FILE" ] || : > "$NAMES_FILE"
    tmp="${NAMES_FILE}.tmp"
    awk -v ip="$ip" '$1 != ip' "$NAMES_FILE" > "$tmp"
    echo "$ip $name" >> "$tmp"
    mv "$tmp" "$NAMES_FILE"

    tctl_log "config_change" "$ip" "name=$name" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
    printf '{"ok":true,"msg":"named %s as %s"}\n' "$ip" "$name"
}

do_remove() {
    local ip="$1" tmp
    tctl_validate_ip "$ip" || { echo '{"ok":false,"msg":"invalid IP address"}'; return 1; }
    [ -f "$NAMES_FILE" ] || { echo '{"ok":true,"msg":"no aliases stored"}'; return 0; }
    tmp="${NAMES_FILE}.tmp"
    awk -v ip="$ip" '$1 != ip' "$NAMES_FILE" > "$tmp"
    mv "$tmp" "$NAMES_FILE"
    tctl_log "config_change" "$ip" "name cleared" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
    printf '{"ok":true,"msg":"name cleared for %s"}\n' "$ip"
}

case "$1" in
    list)   do_list ;;
    set)    do_set "$2" "$3" ;;
    remove) do_remove "$2" ;;
    *)      echo '{"ok":false,"msg":"usage: trafficctl-names.sh list|set <ip> <name>|remove <ip>"}'; exit 1 ;;
esac
