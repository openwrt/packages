# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Dr Bill Mcilhargey
#
# shellcheck shell=sh
#
# Shared helpers for adsbexchange-stats. OpenWrt ash-compatible sh;
# also tested with dash and Bash. Sourced by both
# /etc/init.d/adsbexchange-stats and json-status-helpers.sh. Pulls in
# /usr/lib/readsb/functions.sh (guaranteed by DEPENDS) for readsb_is_uuid.
#
# shellcheck disable=SC2034  # ADSBX_* constants are consumed by callers
# shellcheck disable=SC3043  # `local` is an ash/dash extension, not POSIX

# shellcheck disable=SC1091
. /usr/lib/readsb/functions.sh

: "${ADSBX_LOG_TAG:=adsbexchange-stats}"
READSB_LOG_TAG=$ADSBX_LOG_TAG

ADSBX_RUNTIME_DIR=/var/run/adsbexchange-stats
ADSBX_ENV_FILE=$ADSBX_RUNTIME_DIR/env
ADSBX_UUID_FILE=$ADSBX_RUNTIME_DIR/uuid
ADSBX_UPLOADER=/usr/share/adsbexchange-stats/json-status

# Fallback aircraft.json search list when neither the UCI override nor
# readsb.main.write_json is set.
ADSBX_FALLBACK_PATHS='/var/run/readsb /run/adsbexchange-feed /run/dump1090 /run/dump1090-fa'

# Public per-station stats URL template (mirrors readsb-wiedehopf's
# adsbexchange preset entry).
ADSBX_FEED_URL_BASE='https://www.adsbexchange.com/api/feeders/?feed='

# --- logging ----------------------------------------------------------
# Daemon-facility logger; tag overridable via ADSBX_LOG_TAG.
# `--` defends against messages starting with `-`.
_adsbx_log()    { local p="$1"; shift; logger -t "$ADSBX_LOG_TAG" -p "daemon.$p" -- "$@"; }
adsbx_info()    { _adsbx_log info   "$@"; }
adsbx_notice()  { _adsbx_log notice "$@"; }
adsbx_warn()    { _adsbx_log warn   "$@"; }
adsbx_err() {
	printf '%s: %s\n' "$ADSBX_LOG_TAG" "$*" >&2
	_adsbx_log err "$@"
}

# Normalize decimal input before shell arithmetic, including leading zeros.
adsbx_uint() {
	local number
	number=$(awk -v value="$1" 'BEGIN {
		if (value !~ /^[0-9]+$/ || value+0 > 2147483647) exit 1
		printf "%.0f\n", value+0
	}') || {
		adsbx_warn "${3:-value} is not an unsigned integer in 0..2147483647; using $2"
		number=$2
	}
	printf '%s\n' "$number"
}

# --- UUID -------------------------------------------------------------
adsbx_get_uuid() {
	local feeder=${1:-} preset enabled uuid
	[ -n "$feeder" ] || feeder=$(uci -q get adsbexchange-stats.main.feeder)
	if [ -z "$feeder" ] || ! wiz_v_uci_name "$feeder" \
	   || ! readsb_feeder_section_exists "$feeder"; then
		adsbx_err "select an existing feeder with 'readsb-feeder --setup-companions <name>'"
		return 1
	fi
	preset=$(uci -q get "readsb.$feeder.preset")
	enabled=$(uci -q get "readsb.$feeder.enabled")
	if [ "$preset" != adsbexchange ]; then
		adsbx_err "feeder '$feeder' is not an adsbexchange preset"
		return 1
	fi
	case $enabled in
		1|on|true|yes|enabled) ;;
		*) adsbx_err "feeder '$feeder' is disabled; statistics uploads are suspended"; return 1 ;;
	esac
	uuid=$(uci -q get "readsb.$feeder.uuid")
	[ -n "$uuid" ] || uuid=$(uci -q get readsb.main.uuid)
	printf '%s\n' "$uuid"
}

# Echo the UUID and return 0 on success; log + return nonzero on
# missing or malformed. Centralizes the gate used by start_instance,
# showurl, and write_env.
adsbx_require_uuid() {
	local uuid
	uuid=$(adsbx_get_uuid "${1:-}") || return $?
	if [ -z "$uuid" ]; then
		adsbx_err "selected feeder has no UUID; set its override or run 'readsb-uuid'"
		return 1
	fi
	if ! readsb_is_uuid "$uuid"; then
		adsbx_err "selected feeder's UUID is not 8-4-4-4-12 hex; refusing"
		return 2
	fi
	echo "$uuid"
}

# Public per-station stats URL for a given UUID.
adsbx_feed_url() { echo "${ADSBX_FEED_URL_BASE}$1"; }

# --- aircraft.json path resolution ------------------------------------
# Token is safe to embed verbatim in a shell-sourced file when it
# contains only [A-Za-z0-9/_.+-]. Stricter than POSIX paths but covers
# every real write_json directory and prevents shell-meta injection.
_adsbx_safe_path() {
	case $1 in
		''|*[!A-Za-z0-9/_.+-]*) return 1 ;;
		*) return 0 ;;
	esac
}

# Resolve aircraft.json search paths in priority order:
#   1. adsbexchange-stats.main.json_paths_override (UCI)
#   2. readsb.main.write_json + ADSBX_FALLBACK_PATHS
#   3. ADSBX_FALLBACK_PATHS alone
#
# Subshell so `set -f` (disable globbing while word-splitting UCI input)
# does not leak to the caller.
adsbx_resolve_json_paths() (
	set -f
	local override readsb_dir clean p out
	override=$(uci -q get adsbexchange-stats.main.json_paths_override)
	if [ -n "$override" ]; then
		clean=
		for p in $override; do
			if _adsbx_safe_path "$p"; then
				clean="${clean:+$clean }$p"
			else
				adsbx_warn "ignoring unsafe json_paths_override token: $p"
			fi
		done
		[ -n "$clean" ] && { echo "$clean"; return; }
	fi
	readsb_dir=$(uci -q get readsb.main.write_json)
	if [ -n "$readsb_dir" ] && _adsbx_safe_path "$readsb_dir"; then
		# Emit readsb_dir first, then fallbacks excluding readsb_dir, so
		# the merged list stays in priority order without a duplicate
		# when readsb_dir matches a fallback (the readsb-wiedehopf default
		# write_json=/var/run/readsb is also the first fallback).
		out=$readsb_dir
		for p in $ADSBX_FALLBACK_PATHS; do
			[ "$p" = "$readsb_dir" ] && continue
			out="$out $p"
		done
		echo "$out"
		return
	fi
	[ -n "$readsb_dir" ] && \
		adsbx_warn "readsb.main.write_json contains unsafe chars; using fallbacks only"
	echo "$ADSBX_FALLBACK_PATHS"
)
