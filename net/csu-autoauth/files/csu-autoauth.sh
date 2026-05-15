#!/bin/sh

. /lib/functions.sh

CONFIG_SECTION="${CONFIG_SECTION:-main}"

USERNAME=""
PASSWORD=""
TYPE=""
INTERVAL=""

LOG_DIR="${LOG_DIR:-/tmp/log}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/csu-autoauth.log}"

get_time() {
    date '+%Y-%m-%d %H:%M:%S'
}

init_log_file() {
    mkdir -p "$LOG_DIR"
    : > "$LOG_FILE"
}

log() {
    message="[$(get_time)] $1"
    echo "$message"
    printf '%s\n' "$message" >> "$LOG_FILE"
}

load_config() {
    config_load csu-autoauth || return 1
    config_get USERNAME "$CONFIG_SECTION" username
    config_get PASSWORD "$CONFIG_SECTION" password
    config_get TYPE "$CONFIG_SECTION" type "1"
    config_get INTERVAL "$CONFIG_SECTION" interval "10"

    case "$TYPE" in
        "1") NET_SUFFIX="cmccn" ;;
        "2") NET_SUFFIX="unicomn" ;;
        "3") NET_SUFFIX="telecomn" ;;
        "4") NET_SUFFIX="" ;;
        *)   NET_SUFFIX="" ;;
    esac
}

validate_config() {
    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
        log "Missing username or password in /etc/config/csu-autoauth"
        return 1
    fi

    case "$INTERVAL" in
        ''|*[!0-9]*)
            log "Invalid interval '$INTERVAL', expected a positive integer"
            return 1
            ;;
    esac
}

is_online() {
    curl -s --max-time 5 http://captive.apple.com | grep -q "Success"
}

login() {
    if [ -n "$NET_SUFFIX" ]; then
        USER_ACCOUNT="${USERNAME}@${NET_SUFFIX}"
    else
        USER_ACCOUNT="$USERNAME"
    fi

    URL="https://10.1.1.1:802/eportal/portal/login"
    log "Authenticating as: $USER_ACCOUNT"
    response=$(curl -k -s -G "$URL" \
        -d "user_account=$USER_ACCOUNT" \
        -d "user_password=$PASSWORD")
    log "Login response: $response"
}

init_log_file
load_config || {
    log "Failed to load UCI config: /etc/config/csu-autoauth"
    exit 1
}
validate_config || exit 1
log "Start monitoring network status (every ${INTERVAL}s)..."
LAST_STATUS=""
while true; do
    if is_online; then
        CURRENT_STATUS="up"
        if [ "$LAST_STATUS" != "$CURRENT_STATUS" ]; then
            log "Network up"
            LAST_STATUS="$CURRENT_STATUS"
        fi
    else
        CURRENT_STATUS="down"
        if [ "$LAST_STATUS" != "$CURRENT_STATUS" ]; then
            log "Network down"
            LAST_STATUS="$CURRENT_STATUS"
        fi
        log "Triggering authentication..."
        login
    fi
    sleep "$INTERVAL"
done
