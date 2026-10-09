# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Dr Bill Mcilhargey
#
# shellcheck shell=sh
#
# Helpers sourced by json-status (via $ADSBX_ENV_FILE). OpenWrt
# ash-compatible sh, also tested with dash; the host script is Bash. Adds a
# periodic upload-stats summary and a curl wrapper that captures
# per-request metrics (and full curl -v at debug log level).
#
# Set by /etc/init.d/adsbexchange-stats (env file):
#   ADSBX_LOG_TAG          syslog tag
#   ADSBX_LOG_LEVEL        0 errors only | 1 +summary | 2 +per-cycle | 3 +curl-v
#   ADSBX_SUMMARY_INTERVAL summary cadence (sec) at level >= 1
#
# shellcheck disable=SC3043  # `local` is an ash/dash extension, not POSIX

# Shared logging + constants. Idempotent if already sourced by the init.
# shellcheck disable=SC1091
. /usr/lib/adsbexchange-stats/functions.sh

: "${ADSBX_LOG_LEVEL:=0}"
: "${ADSBX_SUMMARY_INTERVAL:=300}"
: "${MAX_CURL_TIME:=10}"
: "${UUID:=}"
: "${REMOTE_URL:=}"
: "${CURL_EXTRA:=}"

# Rolling counters; reset each summary window.
ADSBX_CYCLE=0 ADSBX_OK=0 ADSBX_FAIL=0
ADSBX_AC_TOTAL=0 ADSBX_BYTES_TOTAL=0
ADSBX_LAST_SUMMARY=0
ADSBX_HTTP_LAST=000 ADSBX_ELAPSED_LAST=0

_adsbx_normalize_log_level() {
	case ${ADSBX_LOG_LEVEL:-} in
		0|1|2|3) ;;
		*) ADSBX_LOG_LEVEL=0 ;;
	esac
}

# One UCI process per upload; keyed show output tolerates missing options
# without relying on batch get's version-dependent blank-line behavior.
adsbx_upload_uuid() {
	local feeder=${ADSBX_FEEDER:-} snapshot uuid rc
	if ! wiz_v_uci_name "$feeder"; then
		adsbx_warn "no valid feeder selection; reload adsbexchange-stats before uploading"
		return 1
	fi
	snapshot=$(uci -q batch <<EOF
show adsbexchange-stats.main
show readsb.$feeder
show readsb.main.uuid
EOF
	) || {
		adsbx_err "could not read the upload configuration snapshot"
		return 1
	}
	uuid=$(printf '%s\n' "$snapshot" | awk -v feeder="$feeder" '
		function enabled(value) { return value ~ /^(1|on|true|yes|enabled)$/ }
		{
			separator = index($0, "=")
			if (!separator) next
			key = substr($0, 1, separator - 1)
			value = substr($0, separator + 1)
			if (value ~ /^\047.*\047$/) value = substr(value, 2, length(value) - 2)
			settings[key] = value
		}
		END {
			uploader = "adsbexchange-stats.main"
			selected = "readsb." feeder
			if (settings[uploader] != "adsbexchange-stats" ||
			    !enabled(settings[uploader ".enabled"])) exit 1
			if (settings[uploader ".feeder"] != feeder) exit 2
			if (settings[selected] != "feeder" ||
			    settings[selected ".preset"] != "adsbexchange" ||
			    !enabled(settings[selected ".enabled"])) exit 3
			uuid = settings[selected ".uuid"]
			if (uuid == "") uuid = settings["readsb.main.uuid"]
			print uuid
		}
	')
	rc=$?
	case $rc in
		0) ;;
		1) adsbx_warn "statistics uploads are disabled or unconfigured"; return 1 ;;
		2) adsbx_warn "selected feeder changed; reload adsbexchange-stats before uploading"; return 1 ;;
		3) adsbx_warn "selected ADSBexchange feeder is missing or disabled"; return 1 ;;
		*) adsbx_err "could not interpret the upload configuration snapshot"; return 1 ;;
	esac
	if ! readsb_is_uuid "$uuid"; then
		adsbx_err "selected feeder has no valid upload UUID"
		return 1
	fi
	printf '%s\n' "$uuid"
}

adsbx_log_curl_diagnostics() {
	awk -v uuid="${UUID:-}" '
		{
			if (match(tolower($0), /(adsbx-uuid|authorization|proxy-authorization|cookie|set-cookie):[[:space:]]*/)) {
				$0 = substr($0, 1, RSTART + RLENGTH - 1) "[redacted]"
			}
			while (uuid != "" && (position = index(tolower($0), tolower(uuid))) > 0) {
				$0 = substr($0, 1, position - 1) "[redacted]" substr($0, position + length(uuid))
			}
			print
		}
	' "$2" | logger -t "$ADSBX_LOG_TAG" -p "daemon.$1"
}

# adsbx_curl_upload <gz_payload>
#
# POST the payload and capture HTTP code and elapsed seconds. Redacted
# curl stderr is logged at debug level, or warn on transport failure.
# Returns curl's exit status.
adsbx_curl_upload() {
	local payload="$1" rv=0 t0 t1 errfile http current_uuid
	_adsbx_normalize_log_level
	ADSBX_HTTP_LAST=000 ADSBX_ELAPSED_LAST=0
	current_uuid=$(adsbx_upload_uuid) || return 1
	if [ "$current_uuid" != "$UUID" ]; then
		adsbx_warn "selected feeder UUID changed; reload adsbexchange-stats before uploading"
		return 1
	fi

	# $@ is function-local in POSIX; CURL_EXTRA is intentionally split.
	# shellcheck disable=SC2086
	set -- \
		-m "$MAX_CURL_TIME" \
		$CURL_EXTRA \
		-sS \
		-X POST \
		-H "adsbx-uuid: $UUID" \
		-H "Content_Encoding: gzip" \
		-o /dev/null \
		-w '%{http_code}' \
		--data-binary @- \
		"$REMOTE_URL"
	[ "$ADSBX_LOG_LEVEL" -ge 3 ] && set -- -v "$@"

	errfile=$(mktemp -t adsbx-curl.XXXXXX 2>/dev/null)
	if [ -z "$errfile" ]; then
		# Keep diagnostics available even when mktemp fails.
		mkdir -p "$ADSBX_RUNTIME_DIR" 2>/dev/null
		errfile="$ADSBX_RUNTIME_DIR/curl.stderr"
		: >"$errfile" 2>/dev/null || errfile=/dev/null
	fi
	t0=$(date +%s)
	http=$(curl "$@" < "$payload" 2>"$errfile") || rv=$?
	t1=$(date +%s)
	ADSBX_HTTP_LAST=${http:-000}
	ADSBX_ELAPSED_LAST=$((t1 - t0))

	if [ "$errfile" != /dev/null ] && [ -s "$errfile" ]; then
		if [ "$rv" -ne 0 ]; then
			adsbx_log_curl_diagnostics warn "$errfile"
		elif [ "$ADSBX_LOG_LEVEL" -ge 3 ]; then
			adsbx_log_curl_diagnostics debug "$errfile"
		fi
	fi
	[ "$errfile" != /dev/null ] && rm -f "$errfile"
	return "$rv"
}

# adsbx_record_upload <aircraft> <bytes>
#
# Update counters and emit per-cycle line (level >= 2) plus periodic
# summary (level >= 1). 200 OK counts as success; anything else as fail.
adsbx_record_upload() {
	local aircraft bytes now avg_ac=0 avg_bytes=0
	_adsbx_normalize_log_level
	aircraft=$(adsbx_uint "${1:-}" 0 "aircraft count")
	bytes=$(adsbx_uint "${2:-}" 0 "payload byte count")

	ADSBX_CYCLE=$((ADSBX_CYCLE + 1))
	if [ "$ADSBX_HTTP_LAST" = 200 ]; then
		ADSBX_OK=$((ADSBX_OK + 1))
		ADSBX_AC_TOTAL=$((ADSBX_AC_TOTAL + aircraft))
		ADSBX_BYTES_TOTAL=$((ADSBX_BYTES_TOTAL + bytes))
	else
		ADSBX_FAIL=$((ADSBX_FAIL + 1))
	fi

	[ "$ADSBX_LOG_LEVEL" -ge 2 ] && adsbx_info \
		"upload aircraft=$aircraft http=$ADSBX_HTTP_LAST bytes=$bytes time=${ADSBX_ELAPSED_LAST}s"

	now=$(date +%s)
	[ "$ADSBX_LAST_SUMMARY" -eq 0 ] && ADSBX_LAST_SUMMARY=$now
	if [ "$ADSBX_LOG_LEVEL" -ge 1 ] && \
	   [ $((now - ADSBX_LAST_SUMMARY)) -ge "$ADSBX_SUMMARY_INTERVAL" ]; then
		if [ "$ADSBX_OK" -gt 0 ]; then
			avg_ac=$((ADSBX_AC_TOTAL / ADSBX_OK))
			avg_bytes=$((ADSBX_BYTES_TOTAL / ADSBX_OK))
		fi
		adsbx_info \
			"summary uploads=$ADSBX_OK/$ADSBX_CYCLE fails=$ADSBX_FAIL aircraft_avg=$avg_ac bytes_avg=$avg_bytes window=$((now - ADSBX_LAST_SUMMARY))s"
		ADSBX_CYCLE=0 ADSBX_OK=0 ADSBX_FAIL=0
		ADSBX_AC_TOTAL=0 ADSBX_BYTES_TOTAL=0
		ADSBX_LAST_SUMMARY=$now
	fi
}
