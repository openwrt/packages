# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Dr Bill Mcilhargey
#
# shellcheck shell=sh
#
# Helpers sourced by json-status (via $ADSBX_ENV_FILE). POSIX so the same
# file works under ash even though the host script is bash. Adds a
# periodic upload-stats summary and a curl wrapper that captures
# per-request metrics (and full curl -v at debug log level).
#
# Set by /etc/init.d/adsbexchange-stats (env file):
#   ADSBX_LOG_TAG          syslog tag
#   ADSBX_LOG_LEVEL        0 errors only | 1 +summary | 2 +per-cycle | 3 +curl-v
#   ADSBX_SUMMARY_INTERVAL summary cadence (sec) at level >= 1
#
# shellcheck disable=SC3043  # busybox ash and dash both support `local`

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

# adsbx_curl_upload <gz_payload>
#
# POST the payload, capture HTTP code into ADSBX_HTTP_LAST and elapsed
# seconds into ADSBX_ELAPSED_LAST. curl stderr (incl. -v at debug) is
# captured to a tempfile and either logged at debug priority (level 3)
# or, on transport failure, drained at warn priority. Returns curl's rv.
adsbx_curl_upload() {
	local payload="$1" rv=0 t0 t1 errfile http

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

	errfile=$(mktemp -t adsbx-curl.XXXXXX) || errfile=/dev/null
	t0=$(date +%s)
	http=$(curl "$@" < "$payload" 2>"$errfile") || rv=$?
	t1=$(date +%s)
	ADSBX_HTTP_LAST=${http:-000}
	ADSBX_ELAPSED_LAST=$((t1 - t0))

	if [ "$errfile" != /dev/null ] && [ -s "$errfile" ]; then
		if [ "$rv" -ne 0 ]; then
			logger -t "$ADSBX_LOG_TAG" -p daemon.warn < "$errfile"
		elif [ "$ADSBX_LOG_LEVEL" -ge 3 ]; then
			logger -t "$ADSBX_LOG_TAG" -p daemon.debug < "$errfile"
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
	local aircraft="$1" bytes="$2" now avg_ac=0 avg_bytes=0

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
