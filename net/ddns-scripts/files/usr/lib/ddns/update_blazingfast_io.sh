#!/bin/sh
#
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# Script for sending updates to blazingfast.io Anycast DNS
# API documentation: https://my.blazingfast.io/api
#
# May, 2026 - Fotios Kitsantas <fkitsantas@icloud.com>
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
#
# Features:
#   - JWT token caching: tokens are cached to disk for up to 270 seconds and
#     reused across update cycles, avoiding repeated login calls that can
#     trigger API rate limiting. Token expiry is detected automatically and
#     a fresh login is performed transparently.
#   - Configurable TTL: record TTL can be set via param_opt (ttl=SECONDS);
#     defaults to 300 seconds if not specified.
#   - Dual-stack support: A and AAAA records can be updated independently
#     using two DDNS service sections with the same hostname.
#   - Record type safety: the record type is verified against the configured
#     record_id before any update is attempted, preventing accidental
#     cross-type updates.
#
# using following options from /etc/config/ddns
# option username  - Your Blazingfast client area username (supports @ and
#                    other special characters)
# option password  - Your Blazingfast client area password
# option domain    - Full DNS record name to update, e.g. hostname.yourdomain.com
# option param_opt - Space-separated key=value pairs:
#                    service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID
#                    Optional: ttl=SECONDS (default: 300)
#
# For dual-stack IPv4 + IPv6, create two DDNS service sections:
#   - one with option use_ipv6 '0' and the A record_id
#   - one with option use_ipv6 '1' and the AAAA record_id
#
# The hostname may be the same for both records, for example:
#   hostname.yourdomain.com A    x.x.x.x
#   hostname.yourdomain.com AAAA xxxx:xxxx::xxxx
#
# Example /etc/config/ddns configuration
#
# IPv4 only, updates the A record:
#
# config service 'blazingfast_ipv4'
#	option enabled '1'
#	option service_name 'blazingfast.io'
#	option use_ipv6 '0'
#	option domain 'hostname.yourdomain.com'
#	option username 'YOUR_USERNAME'
#	option password 'YOUR_PASSWORD'
#	option param_opt 'service_id=SERVICE_ID zone_id=ZONE_ID record_id=A_RECORD_ID'
#
# IPv6 only, updates the AAAA record:
#
# config service 'blazingfast_ipv6'
#	option enabled '1'
#	option service_name 'blazingfast.io'
#	option use_ipv6 '1'
#	option domain 'hostname.yourdomain.com'
#	option username 'YOUR_USERNAME'
#	option password 'YOUR_PASSWORD'
#	option param_opt 'service_id=SERVICE_ID zone_id=ZONE_ID record_id=AAAA_RECORD_ID'
#
# Dual-stack IPv4 + IPv6:
#
# Use both sections above at the same time.
# The domain can be the same for both A and AAAA records.
# The record_id must be different:
#   - A_RECORD_ID for the A record
#   - AAAA_RECORD_ID for the AAAA record
#
# Custom TTL example (sets record TTL to 60 seconds):
#	option param_opt 'service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID ttl=60'
#
# How to find your service_id, zone_id, record_id:
#
#   1. Get your token:
#      TOKEN=$(curl -s -X POST 'https://my.blazingfast.io/api/login' \
#        --data-urlencode "username=USERNAME" \
#        --data-urlencode "password=PASSWORD" | jsonfilter -e "@.token")
#
#   2. List services to get service_id:
#      curl -s 'https://my.blazingfast.io/api/service' \
#        -H "Authorization: Bearer $TOKEN" | jsonfilter -e "@.services"
#
#   3. List DNS zones to get zone_id (replace SERVICE_ID):
#      curl -s 'https://my.blazingfast.io/api/service/SERVICE_ID/dns' \
#        -H "Authorization: Bearer $TOKEN" | jsonfilter -e "@.zones"
#
#   4. List records to get record_id values, including both A and AAAA records:
#      curl -s 'https://my.blazingfast.io/api/service/SERVICE_ID/dns/ZONE_ID' \
#        -H "Authorization: Bearer $TOKEN" | jsonfilter -e "@.records"
#
#   Then set param_opt to:
#      service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID
#
# variable __IP already defined with the ip-address to use for update
#

. /usr/share/libubox/jshn.sh

# ---------------------------------------------------------------------------
# Parameter validation
# ---------------------------------------------------------------------------
# $CURL_SSL is a framework boolean flag (non-empty = SSL supported); verified
# here to ensure the Blazingfast HTTPS-only API can be reached.
[ -z "$CURL_SSL" ] && write_log 14 "Blazingfast communication requires cURL with SSL support. Please install"
# $CURL is the actual binary path, set by dynamic_dns_functions.sh via
# `command -v curl`. Guard explicitly so a misconfigured framework produces
# a clear diagnostic rather than a silent empty-command failure.
[ -z "$CURL"     ] && write_log 14 "Cannot find curl binary — check ddns-scripts installation"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"
[ -z "$domain"   ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ "${use_https:-0}" -eq 0 ] && use_https=1	# force HTTPS

# $CURL_SSL is a framework boolean flag (non-empty = SSL supported); the actual
# binary path is always $CURL, set by dynamic_dns_functions.sh to `command -v curl`.
local __CURLBIN="$CURL"

# ---------------------------------------------------------------------------
# Parse param_opt — expects: service_id=X zone_id=Y record_id=Z [ttl=N]
#
# ttl is optional; defaults to 300 seconds if omitted. Exposing it here
# avoids hardcoding and lets users tune propagation vs. API call frequency
# without editing the script.
# ---------------------------------------------------------------------------
local __SERVICE_ID __ZONE_ID __RECORD_ID __TTL
if [ -n "$param_opt" ]; then
	for pair in $param_opt; do
		case $pair in
			service_id=*) __SERVICE_ID=${pair#*=}; write_log 7 "service_id: $__SERVICE_ID" ;;
			zone_id=*)    __ZONE_ID=${pair#*=};    write_log 7 "zone_id: $__ZONE_ID" ;;
			record_id=*)  __RECORD_ID=${pair#*=};  write_log 7 "record_id: $__RECORD_ID" ;;
			ttl=*)        __TTL=${pair#*=};        write_log 7 "ttl: $__TTL" ;;
			*) ;;
		esac
	done
fi

[ -z "$__SERVICE_ID" ] && write_log 14 "param_opt missing service_id=VALUE"
[ -z "$__ZONE_ID"    ] && write_log 14 "param_opt missing zone_id=VALUE"
[ -z "$__RECORD_ID"  ] && write_log 14 "param_opt missing record_id=VALUE"

# Validate __TTL is a positive integer before applying the default.
# json_add_int passes the value directly to jshn without type-checking;
# a non-numeric value would silently produce malformed JSON and cause
# the API to reject the update with an opaque error.
if [ -n "$__TTL" ]; then
	case "$__TTL" in
		*[!0-9]*)
			write_log 14 "param_opt ttl=VALUE must be a positive integer (got: '$__TTL')"
			;;
		0)
			write_log 14 "param_opt ttl=VALUE must be greater than 0 (got: '$__TTL')"
			;;
	esac
fi
# Default TTL to 300 seconds if not provided via param_opt.
__TTL="${__TTL:-300}"

# set record type based on use_ipv6 flag
local __TYPE __IPVERSION
if [ "${use_ipv6:-0}" -eq 0 ]; then
	__TYPE="A"
	__IPVERSION="4"
else
	__TYPE="AAAA"
	__IPVERSION="6"
fi

local __URLBASE="https://my.blazingfast.io/api"
# __TOKEN, __DATA, __RECTYPE: shared across steps.
# __DEVICE: set later from bind_network if configured.
# __PAYLOAD is intentionally NOT declared here — it is a short-lived
# intermediate used only in Step 4 and is declared there to keep its
# scope and intent clear.
local __TOKEN __DATA __RECTYPE __DEVICE
local __CURLCFG="${DATFILE}.curl"
local __CURLEXTRA="${DATFILE}.extra"
local __JSONFILE="${DATFILE}.json"
# Token cache — lives in /var/run/ddns/ and persists across invocations.
# Named per service_id so dual-stack or multi-zone setups don't collide.
# Format: "<unix_timestamp> <jwt_token>"
# Not removed on clean exit; the TTL check handles expiry naturally.
local __TOKENFILE="/var/run/ddns/blazingfast_${__SERVICE_ID}.token"
local __TOKEN_TTL=270  # seconds — 4.5 min; safely under any reasonable JWT expiry

# ---------------------------------------------------------------------------
# Explicit cleanup helper. We deliberately avoid `trap ... EXIT` because this
# script is sourced into the long-running ddns runtime, where a global trap
# would leak past this provider invocation and could clobber unrelated files
# or override traps installed by the framework / other providers.
# ---------------------------------------------------------------------------
blazingfast_cleanup() {
	rm -f "$__CURLCFG" "$__CURLEXTRA" "$__JSONFILE"
}

# ---------------------------------------------------------------------------
# blazingfast_do_login — performs the login API call, extracts the token,
# and writes it to the cache file atomically with restricted permissions.
#
# Atomic write (draft to __TOKENFILE.tmp.$$ then mv) prevents concurrent
# dual-stack instances from reading a partially-written file. The $$ PID
# suffix gives each concurrent instance its own temp filename so they never
# clobber each other's draft. The subshell confines umask 077 so the temp
# file is owner-readable only, without affecting the parent shell's umask.
#
# Sets __TOKEN on success. Clears the cache file and returns 1 on failure.
# ---------------------------------------------------------------------------
blazingfast_do_login() {
	: > "$__CURLEXTRA"
	echo "request = POST" >> "$__CURLEXTRA"
	echo "url = \"$__URLBASE/login\"" >> "$__CURLEXTRA"
	# Use data-urlencode so credentials containing reserved characters
	# (&, =, +, spaces, @, ...) are safely percent-encoded by curl.
	printf 'data-urlencode = "username=%s"\n' "$username" >> "$__CURLEXTRA"
	printf 'data-urlencode = "password=%s"\n' "$password" >> "$__CURLEXTRA"
	blazingfast_transfer || {
		write_log 4 "Blazingfast authentication request failed"
		return 1
	}

	__TOKEN=$(jsonfilter -i "$DATFILE" -e "@.token" 2>/dev/null)
	if [ -z "$__TOKEN" ]; then
		# Do NOT dump $DATFILE: a partial/successful response may contain a token.
		write_log 4 "Blazingfast authentication failed — check username/password"
		rm -f "$__TOKENFILE"
		return 1
	fi

	# Write atomically: draft to a per-PID temp file, then rename into place.
	# The rename is atomic on POSIX filesystems, so a concurrent reader either
	# sees the old complete file or the new complete file — never a partial write.
	# The subshell confines umask 077 so the temp file is owner-readable only.
	local __TMPTOK="${__TOKENFILE}.tmp.$$"
	( umask 077 && printf '%s %s\n' "$(date +%s)" "$__TOKEN" > "$__TMPTOK" ) && \
		mv "$__TMPTOK" "$__TOKENFILE" || {
			rm -f "$__TMPTOK"
			write_log 4 "Failed to write Blazingfast token cache"
			return 1
		}
	return 0
}

# ---------------------------------------------------------------------------
# blazingfast_fetch_zone — fetches all DNS records for the configured zone.
#
# Extracted into a helper to avoid duplicating the GET request block: it is
# called once during normal operation (Step 2) and again if a cached token
# is found to have expired mid-session and a fresh login has been performed.
# Result is written to $DATFILE for the caller to parse.
# ---------------------------------------------------------------------------
blazingfast_fetch_zone() {
	: > "$__CURLEXTRA"
	echo "request = GET" >> "$__CURLEXTRA"
	echo "url = \"$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID\"" >> "$__CURLEXTRA"
	echo "header = \"Authorization: Bearer $__TOKEN\"" >> "$__CURLEXTRA"
	echo "header = \"Content-Type: application/json\"" >> "$__CURLEXTRA"
	blazingfast_transfer
}

# ---------------------------------------------------------------------------
# blazingfast_transfer — invokes curl via config file.
# Avoids eval and shell injection from user-controlled values.
# Call-specific options (method, url, headers, data) are written
# to __CURLEXTRA before each call and appended to the base config.
# ---------------------------------------------------------------------------
blazingfast_transfer() {
	local __CNT=0
	local __ERR

	while : ; do
		: > "$DATFILE"
		: > "$ERRFILE"
		# Build fresh curl config for this attempt
		: > "$__CURLCFG"
		echo "silent" >> "$__CURLCFG"
		echo "show-error" >> "$__CURLCFG"
		echo "remote-time" >> "$__CURLCFG"
		echo "output = \"$DATFILE\"" >> "$__CURLCFG"
		echo "stderr = \"$ERRFILE\"" >> "$__CURLCFG"

		[ -n "$__DEVICE" ] && \
			echo "interface = \"$__DEVICE\"" >> "$__CURLCFG"

		[ "${force_ipversion:-0}" -eq 1 ] && {
			[ "${use_ipv6:-0}" -eq 0 ] \
				&& echo "ipv4" >> "$__CURLCFG" \
				|| echo "ipv6" >> "$__CURLCFG"
		}

		if [ "$cacert" = "IGNORE" ]; then
			echo "insecure" >> "$__CURLCFG"
		elif [ -f "$cacert" ]; then
			echo "cacert = \"$cacert\"" >> "$__CURLCFG"
		elif [ -d "$cacert" ]; then
			echo "capath = \"$cacert\"" >> "$__CURLCFG"
		elif [ -n "$cacert" ]; then
			write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
		fi

		if [ -z "$proxy" ]; then
			echo "noproxy = \"*\"" >> "$__CURLCFG"
		elif [ -z "$CURL_PROXY" ]; then
			write_log 13 "cURL: libcurl compiled without Proxy support"
		else
			echo "proxy = \"$proxy\"" >> "$__CURLCFG"
		fi

		# append call-specific options
		cat "$__CURLEXTRA" >> "$__CURLCFG"

		write_log 7 "#> $__CURLBIN --config $__CURLCFG"

		"$__CURLBIN" --config "$__CURLCFG"
		__ERR=$?
		[ "$__ERR" -eq 0 ] && return 0

		write_log 3 "cURL Error: '$__ERR'"
		write_log 7 "$(cat "$ERRFILE")"

		[ "${VERBOSE_MODE:-0}" -gt 1 ] && {
			write_log 4 "Transfer failed - Verbose Mode: ${VERBOSE_MODE:-0} - NO retry on error"
			return "$__ERR"
		}

		__CNT=$(( __CNT + 1 ))
		[ "${retry_max_count:-0}" -gt 0 ] && [ "$__CNT" -gt "${retry_max_count:-0}" ] && \
			write_log 14 "Transfer failed after ${retry_max_count:-0} retries"

		write_log 4 "Transfer failed - retry $__CNT/${retry_max_count:-0} in ${RETRY_SECONDS:-0} seconds"
		sleep "${RETRY_SECONDS:-0}" &
		PID_SLEEP=$!
		wait $PID_SLEEP
		PID_SLEEP=0
	done
}

# resolve bind_network to device name if set
if [ -n "$bind_network" ]; then
	network_get_device __DEVICE "$bind_network" || \
		write_log 13 "Cannot detect local device using 'network_get_device $bind_network' - Error: '$?'"
	write_log 7 "Force communication via device '$__DEVICE'"
fi

# ---------------------------------------------------------------------------
# Step 1 — Authenticate and obtain JWT token
#
# To prevent API rate-limiting, tokens are cached to disk and reused for up
# to __TOKEN_TTL seconds. The ddns framework retries the full send_update()
# cycle (including this script) on each failure, so without caching every
# retry would hit the login endpoint — exactly the pattern that triggers
# Blazingfast's abuse protection and locks the account out of the API.
#
# Cache hit:  reuse token, skip login request entirely.
# Cache miss: authenticate via blazingfast_do_login, which writes the token
#             atomically with restricted permissions.
# Expiry:     on a 401 from any subsequent API call the cache is invalidated
#             and blazingfast_do_login is called once more.
# ---------------------------------------------------------------------------
__TOKEN=""
if [ -f "$__TOKENFILE" ]; then
	local __CACHED_TS __CACHED_TOK __NOW __AGE
	# IFS=' ' and -r ensure the read is not affected by the current IFS value
	# or by backslash sequences that may appear in a corrupted cache file.
	IFS=' ' read -r __CACHED_TS __CACHED_TOK 2>/dev/null < "$__TOKENFILE"
	__NOW=$(date +%s)

	case "$__CACHED_TS" in
		''|*[!0-9]*)
			write_log 7 "Cached token timestamp is invalid — re-authenticating"
			rm -f "$__TOKENFILE"
			__CACHED_TS=""
			;;
	esac

	if [ -n "$__CACHED_TS" ] && [ "$__NOW" -ge "$__CACHED_TS" ]; then
		__AGE=$(( __NOW - __CACHED_TS ))
	else
		__AGE="$__TOKEN_TTL"
	fi

	if [ -n "$__CACHED_TOK" ] && [ "$__AGE" -lt "$__TOKEN_TTL" ]; then
		__TOKEN="$__CACHED_TOK"
		write_log 7 "Reusing cached Blazingfast token (age: ${__AGE}s / TTL: ${__TOKEN_TTL}s)"
	else
		write_log 7 "Cached token expired (age: ${__AGE}s) — re-authenticating"
		rm -f "$__TOKENFILE"
	fi
fi

if [ -z "$__TOKEN" ]; then
	write_log 7 "Authenticating with Blazingfast.io"
	blazingfast_do_login || { blazingfast_cleanup; return 1; }
	write_log 7 "Authentication successful — token cached"
fi

# ---------------------------------------------------------------------------
# Step 2 — Fetch all zone records and verify record type
#
# The Blazingfast API does not support single-record GET requests. All records
# for the zone are fetched and filtered by record_id. This ensures IPv4
# updates only target A records and IPv6 updates only target AAAA records.
#
# If the fetch returns a 401, the cached token expired between being written
# and used (e.g. the token's server-side TTL is shorter than __TOKEN_TTL).
# In that case the cache is wiped, a fresh login is performed via
# blazingfast_do_login, and the zone fetch is retried exactly once — this
# handles the race without hammering the login endpoint on other failures.
# ---------------------------------------------------------------------------
write_log 7 "Fetching zone records to verify record type is '$__TYPE'"
blazingfast_fetch_zone || {
	blazingfast_cleanup
	return 1
}

# record id may be returned as integer or string depending on endpoint
__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id=$__RECORD_ID].type" 2>/dev/null)
[ -z "$__RECTYPE" ] && \
	__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id='$__RECORD_ID'].type" 2>/dev/null)

if [ -z "$__RECTYPE" ]; then
	local __APIERR
	__APIERR=$(jsonfilter -i "$DATFILE" -e "@.error[0]" 2>/dev/null)
	if [ "$__APIERR" = "unauthorized" ] && [ -f "$__TOKENFILE" ]; then
		write_log 4 "Cached token rejected (expired) — clearing cache and re-authenticating"
		rm -f "$__TOKENFILE"
		blazingfast_do_login || { blazingfast_cleanup; return 1; }
		write_log 7 "Re-authentication successful — fetching zone records again"
		blazingfast_fetch_zone || {
			blazingfast_cleanup
			return 1
		}
		__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id=$__RECORD_ID].type" 2>/dev/null)
		[ -z "$__RECTYPE" ] && \
			__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id='$__RECORD_ID'].type" 2>/dev/null)
	fi
fi

if [ -z "$__RECTYPE" ]; then
	write_log 4 "Could not retrieve DNS record type from Blazingfast API"
	write_log 7 "$(cat "$DATFILE")"
	blazingfast_cleanup
	write_log 14 "Check service_id, zone_id and record_id"
fi

if [ "$__RECTYPE" != "$__TYPE" ]; then
	write_log 4 "Record type mismatch: expected '$__TYPE' for IPv$__IPVERSION but record '$__RECORD_ID' is '$__RECTYPE'"
	blazingfast_cleanup
	write_log 14 "Use the correct Blazingfast record_id for the IPv$__IPVERSION DNS record"
fi

write_log 7 "DNS record type confirmed: '$__RECTYPE'"

# ---------------------------------------------------------------------------
# Step 3 — GET_REGISTERED_IP mode
#
# Returns the IP currently stored in the DNS record, used by ddns-scripts to
# compare against the local IP before deciding whether an update is needed.
# The zone records were already fetched in Step 2, so $DATFILE is reused
# here without an additional API call.
# ---------------------------------------------------------------------------
if [ -n "$GET_REGISTERED_IP" ]; then
	__DATA=$(jsonfilter -i "$DATFILE" -e "@.records[@.id=$__RECORD_ID].content" 2>/dev/null)
	[ -z "$__DATA" ] && \
		__DATA=$(jsonfilter -i "$DATFILE" -e "@.records[@.id='$__RECORD_ID'].content" 2>/dev/null)
	if [ -n "$__DATA" ]; then
		write_log 7 "Registered IP '$__DATA' detected via Blazingfast API"
		REGISTERED_IP="$__DATA"
		blazingfast_cleanup
		return 0
	else
		write_log 4 "Could not extract IP from Blazingfast API response"
		write_log 7 "$(cat "$DATFILE")"
		blazingfast_cleanup
		return 127
	fi
fi

# ---------------------------------------------------------------------------
# Step 4 — Update the DNS record
#
# JSON payload is built with jshn.sh and written to a temp file, then
# referenced via curl's @file syntax. This avoids all quoting issues:
# embedding JSON inline in the curl config file breaks because the internal
# double-quotes in the JSON prematurely close the config file's quoted string.
#
# __PAYLOAD is declared here rather than in the shared locals block at the
# top because it is only used in this step. Keeping it local to its site of
# use makes the data flow easier to follow.
#
# TTL is taken from __TTL, which was parsed from param_opt and defaults to
# 300 seconds. This allows users to configure the TTL without editing the
# script by adding ttl=SECONDS to their param_opt value.
# ---------------------------------------------------------------------------
local __PAYLOAD
json_init
json_add_string "name"     "$domain"
json_add_int    "ttl"      "$__TTL"
json_add_int    "priority" 0
json_add_string "type"     "$__TYPE"
json_add_string "content"  "$__IP"
__PAYLOAD=$(json_dump)

printf '%s' "$__PAYLOAD" > "$__JSONFILE"

: > "$__CURLEXTRA"
echo "request = PUT" >> "$__CURLEXTRA"
echo "url = \"$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID/records/$__RECORD_ID\"" >> "$__CURLEXTRA"
echo "header = \"Authorization: Bearer $__TOKEN\"" >> "$__CURLEXTRA"
echo "header = \"Content-Type: application/json\"" >> "$__CURLEXTRA"
echo "data = \"@$__JSONFILE\"" >> "$__CURLEXTRA"
blazingfast_transfer || {
	write_log 4 "Blazingfast update request failed"
	blazingfast_cleanup
	return 1
}

# verify success from API response
__DATA=$(jsonfilter -i "$DATFILE" -e "@.info[0]" 2>/dev/null)
if echo "$__DATA" | grep -q "dnsrecordupdated"; then
	write_log 7 "Record updated: $domain $__TYPE -> $__IP (TTL: ${__TTL}s)"
	blazingfast_cleanup
	return 0
fi

write_log 4 "Blazingfast API reported an error:"
write_log 7 "$(cat "$DATFILE")"
blazingfast_cleanup
return 1
