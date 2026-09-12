#!/bin/sh
# WireGuard Obfuscator Configuration Generator
# This script generates wg-obfuscator.conf from UCI configuration
# Copyright (C) 2024-2025 Alexey Cluster <cluster@cluster.wtf>
# Licensed under GPLv3

# Kept on tmpfs: the file is fully regenerated on every start, and writing it
# to flash on each boot would wear the router storage out.
CONFIG_FILE="/var/etc/wg-obfuscator.conf"
UCI_CONFIG="wg-obfuscator"

# Allow override of the UCI config directory for testing. uci only takes this
# as the -c option, it does not look at the environment.
UCI="uci -q"
if [ -n "$UCI_CONFIG_DIR" ]; then
    UCI="uci -q -c $UCI_CONFIG_DIR"
fi

# Function to get UCI value with default
get_uci_value() {
    local section="$1"
    local option="$2"
    local default="$3"

    local value=$($UCI get "${UCI_CONFIG}.${section}.${option}")
    if [ -z "$value" ]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# ash and dash exit with status 2 and print their own diagnostic when a
# non-numeric operand reaches -lt or -gt. That status makes the enclosing test
# fall through rather than fail, so every value has to be screened first.
is_number() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac
    return 0
}

# Same input the daemon accepts for --fwmark: decimal or a 0x-prefixed hex
# value, 0..65535. The kernel's SO_MARK is 32-bit; this program is not.
# Prints the decimal form on stdout so the caller can compare without
# feeding a hex string to [ -gt ].
fwmark_to_dec() {
    local raw="$1"
    local digits

    case "$raw" in
        0[xX]*)
            digits=${raw#0[xX]}
            case "$digits" in
                ''|*[!0-9a-fA-F]*) return 1 ;;
            esac
            ;;
        ''|*[!0-9]*)
            return 1
            ;;
    esac

    printf '%d' "$raw"
}

# Function to validate port number
validate_port() {
    local port="$1"
    if ! is_number "$port" || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "ERROR: Invalid port number: $port (must be 1-65535)" >&2
        return 1
    fi
    return 0
}

# Function to validate target format (host:port)
validate_target() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "ERROR: Target cannot be empty" >&2
        return 1
    fi
    if ! echo "$target" | grep -qE '^.+:[0-9]+$'; then
        echo "ERROR: Invalid target format: $target (expected host:port)" >&2
        return 1
    fi
    local port=$(echo "$target" | sed 's/.*://')
    validate_port "$port" || return 1
    return 0
}

# Function to validate key
validate_key() {
    local key="$1"
    if [ -z "$key" ]; then
        echo "ERROR: Obfuscation key cannot be empty" >&2
        return 1
    fi
    if [ ${#key} -lt 4 ]; then
        echo "WARNING: Key is very short (less than 4 characters)" >&2
    fi
    return 0
}

# Function to generate config for a single instance
generate_instance_config() {
    local section="$1"
    local enabled=$(get_uci_value "$section" "enabled" "0")

    if [ "$enabled" = "0" ]; then
        return 0
    fi

    # Nothing is printed until every value has been checked: a stanza cut short
    # by a failed check still looks like a complete instance to the daemon.
    local source_if=$(get_uci_value "$section" "source_if" "0.0.0.0")

    local source_lport=$(get_uci_value "$section" "source_lport" "13255")
    if ! validate_port "$source_lport"; then
        echo "ERROR: Invalid source port for section '$section'" >&2
        return 1
    fi

    local target=$(get_uci_value "$section" "target" "10.13.1.100:13255")
    if ! validate_target "$target"; then
        echo "ERROR: Invalid target for section '$section'" >&2
        return 1
    fi

    # No fallback for the key: a guessable shared secret is worse than a
    # configuration error the administrator gets told about.
    local key=$(get_uci_value "$section" "key" "")
    if ! validate_key "$key"; then
        echo "ERROR: Invalid key for section '$section'" >&2
        return 1
    fi

    local masking=$(get_uci_value "$section" "masking" "AUTO")
    local verbose=$(get_uci_value "$section" "verbose" "INFO")

    local static_bindings=$(get_uci_value "$section" "static_bindings" "")
    if [ -n "$static_bindings" ]; then
        # Normalize CRLF/whitespace, drop empty lines, join with single comma
        static_bindings=$(printf "%s\n" "$static_bindings" \
            | sed 's/\r//g' \
            | awk 'BEGIN{FS="\n"} {gsub(/^ +| +$/,"",$0)} NF{a[++n]=$0} END{for(i=1;i<=n;i++){printf "%s%s", (i>1?",":""), a[i]}}')
    fi

    local max_clients=$(get_uci_value "$section" "max_clients" "1024")
    if ! is_number "$max_clients" || [ "$max_clients" -lt 1 ] || [ "$max_clients" -gt 65535 ]; then
        echo "WARNING: Invalid max-clients value for section '$section', using default 1024" >&2
        max_clients=1024
    fi

    local idle_timeout=$(get_uci_value "$section" "idle_timeout" "300")
    if ! is_number "$idle_timeout"; then
        echo "WARNING: Invalid idle-timeout value for section '$section', using default 300" >&2
        idle_timeout=300
    fi

    local in_timeout=$(get_uci_value "$section" "in_timeout" "0")
    if ! is_number "$in_timeout"; then
        echo "WARNING: Invalid in-timeout value for section '$section', using default 0" >&2
        in_timeout=0
    fi

    local resolve_interval=$(get_uci_value "$section" "resolve_interval" "0")
    if ! is_number "$resolve_interval"; then
        echo "WARNING: Invalid resolve-interval value for section '$section', using default 0" >&2
        resolve_interval=0
    fi

    local max_dummy=$(get_uci_value "$section" "max_dummy" "4")
    if ! is_number "$max_dummy" || [ "$max_dummy" -gt 255 ]; then
        echo "WARNING: Invalid max-dummy value for section '$section', using default 4" >&2
        max_dummy=4
    fi

    local fwmark=$(get_uci_value "$section" "fwmark" "0")
    local fwmark_n
    fwmark_n=$(fwmark_to_dec "$fwmark") || fwmark_n=""
    if [ -z "$fwmark_n" ] || [ "$fwmark_n" -gt 65535 ]; then
        echo "WARNING: Invalid fwmark value for section '$section', using default 0" >&2
        fwmark=0
        fwmark_n=0
    fi

    local allow_clean=$(get_uci_value "$section" "allow_clean" "0")
    local log_file=$(get_uci_value "$section" "log_file" "")
    local log_timestamps=$(get_uci_value "$section" "log_timestamps" "AUTO")

    emitted=$((emitted + 1))
    echo "[$section]"

    if [ "$source_if" != "0.0.0.0" ]; then
        echo "source-if = $source_if"
    fi

    echo "source-lport = $source_lport"
    echo "target = $target"
    echo "key = $key"
    echo "masking = $masking"

    if [ -n "$static_bindings" ]; then
        echo "static-bindings = $static_bindings"
    fi

    echo "verbose = $verbose"
    echo "max-clients = $max_clients"
    echo "idle-timeout = $idle_timeout"

    # Omit when disabled: the daemon rejects in-timeout <= 0
    if [ "$in_timeout" -gt 0 ]; then
        echo "in-timeout = $in_timeout"
    fi

    if [ "$resolve_interval" -gt 0 ]; then
        echo "resolve-interval = $resolve_interval"
    fi

    echo "max-dummy = $max_dummy"

    if [ "$fwmark_n" -ne 0 ]; then
        echo "fwmark = $fwmark"
    fi

    if [ "$allow_clean" = "1" ]; then
        echo "allow-clean = true"
    fi

    # Omit when empty: the log goes to stderr and is picked up by procd/logread
    if [ -n "$log_file" ]; then
        echo "log-file = $log_file"
    fi

    if [ "$log_timestamps" != "AUTO" ]; then
        echo "log-timestamps = $log_timestamps"
    fi

    echo ""
}

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_FILE")"

# The generated file holds the shared obfuscation key in cleartext
umask 077

# Check if UCI configuration exists before generating
# Only get sections of type wg_obfuscator
sections=$($UCI show "$UCI_CONFIG" | grep "^$UCI_CONFIG\.[^.]*=wg_obfuscator$" | cut -d. -f2 | cut -d= -f1 | sort -u)

if [ -z "$sections" ]; then
    echo "No UCI configuration found"
    exit 1
fi

# Built next to the target and renamed into place, so a failed run can neither
# leave a half-written config behind nor hand a stale mode to the new file.
CONFIG_TMP="${CONFIG_FILE}.tmp"
status=0
# The four-line header is always written, so [ -s ] cannot tell a run with
# no enabled instances from a real config.
emitted=0

# Generate configuration file
{
    echo "# WireGuard Obfuscator Configuration"
    # Deliberately without a timestamp: the init script tracks this file with
    # procd_set_param, so a line that changed on every run would restart the
    # daemon on every reload and drop live sessions.
    echo "# Generated from UCI configuration"
    echo "# Do not edit this file manually - use UCI instead"
    echo ""

    # Generate config for each section
    for section in $sections; do
        generate_instance_config "$section" || status=1
    done
} > "$CONFIG_TMP"

if [ "$status" -ne 0 ] || [ "$emitted" -eq 0 ]; then
    rm -f "$CONFIG_TMP"
    echo "Failed to generate configuration file" >&2
    exit 1
fi

mv "$CONFIG_TMP" "$CONFIG_FILE"
echo "Configuration generated: $CONFIG_FILE"
