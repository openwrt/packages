#!/bin/sh

# shellcheck disable=SC2039

__FILE__="$(basename "$0")"

KEEPALIVED_USER=keepalived
KEEPALIVED_DEBUG=0

__function__() {
	type "$1" > /dev/null 2>&1
}

log() {
	local facility=$1
	shift
	logger -t "${__FILE__}[$$]" -p "$facility" "$*"
}

log_info() {
	log info "$*"
}

log_debug() {
	[ "$KEEPALIVED_DEBUG" = "0" ] && return
	log debug "$*"
}

log_notice() {
	log notice "$*"
}

log_warn() {
	log warn "$*"
}

log_err() {
	log err "$*"
}

get_rsync_user() {
	echo "$KEEPALIVED_USER"
}

get_rsync_user_home() {
	awk -F: "/^$KEEPALIVED_USER/{print \$6}" /etc/passwd
}
