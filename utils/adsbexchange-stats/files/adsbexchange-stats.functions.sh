# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Dr Bill Mcilhargey
#
# shellcheck shell=sh
#
# Shared helpers for adsbexchange-stats. POSIX sh; sourced by both
# /etc/init.d/adsbexchange-stats and json-status-helpers.sh. Pulls in
# /usr/lib/readsb/functions.sh (guaranteed by DEPENDS) for readsb_is_uuid.
#
# shellcheck disable=SC2034  # ADSBX_* constants are consumed by callers
# shellcheck disable=SC3043  # busybox ash and dash both support `local`

# shellcheck disable=SC1091
. /usr/lib/readsb/functions.sh

: "${ADSBX_LOG_TAG:=adsbexchange-stats}"

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
adsbx_err()     { _adsbx_log err    "$@" >&2; }

# --- UUID -------------------------------------------------------------
# Single source of truth: readsb.main.uuid (managed by `readsb-uuid`).
adsbx_get_uuid() { uci -q get readsb.main.uuid; }

# Echo the UUID and return 0 on success; log + return nonzero on
# missing or malformed. Centralizes the gate used by start_instance,
# showurl, and write_env.
adsbx_require_uuid() {
	local uuid
	uuid=$(adsbx_get_uuid)
	if [ -z "$uuid" ]; then
		adsbx_err "no UUID in readsb.main.uuid; run 'readsb-uuid' to generate one"
		return 1
	fi
	if ! readsb_is_uuid "$uuid"; then
		adsbx_err "readsb.main.uuid='$uuid' is not 8-4-4-4-12 hex; refusing"
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
