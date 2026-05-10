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
# using following options from /etc/config/ddns
# option username  - Your Blazingfast client area username
# option password  - Your Blazingfast client area password
# option domain    - Full DNS record name to update, e.g. hostname.yourdomain.com
# option param_opt - Space-separated key=value pairs:
#                    service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID
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
# How to find your service_id, zone_id, record_id:
#
#   1. Get your token:
#      TOKEN=$(curl -s -X POST 'https://my.blazingfast.io/api/login' \
#        -d "username=USERNAME" \
#        -d "password=PASSWORD" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
#
#   2. List services to get service_id:
#      curl -s 'https://my.blazingfast.io/api/service' \
#        -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
#
#   3. List DNS zones to get zone_id (replace SERVICE_ID):
#      curl -s 'https://my.blazingfast.io/api/service/SERVICE_ID/dns' \
#        -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
#
#   4. List records to get record_id values, including both A and AAAA records:
#      curl -s 'https://my.blazingfast.io/api/service/SERVICE_ID/dns/ZONE_ID' \
#        -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
#
#   Then set param_opt to:
#      service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID
#
# variable __IP already defined with the ip-address to use for update
#

. /usr/share/libubox/jshn.sh

# check parameters
[ -z "$CURL_SSL" ] && write_log 14 "Blazingfast communication requires cURL with SSL support. Please install"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"
[ -z "$domain"   ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ "${use_https:-0}" -eq 0 ] && use_https=1	# force HTTPS

# Always use the SSL-capable curl binary because the Blazingfast API is HTTPS-only.
# $CURL may be unset if the framework only detected an SSL-enabled curl.
local __CURLBIN="$CURL_SSL"

# parse param_opt — expects: service_id=X zone_id=Y record_id=Z
local __SERVICE_ID __ZONE_ID __RECORD_ID
if [ -n "$param_opt" ]; then
	for pair in $param_opt; do
		case $pair in
			service_id=*) __SERVICE_ID=${pair#*=}; write_log 7 "service_id: $__SERVICE_ID" ;;
			zone_id=*)    __ZONE_ID=${pair#*=};    write_log 7 "zone_id: $__ZONE_ID" ;;
			record_id=*)  __RECORD_ID=${pair#*=};  write_log 7 "record_id: $__RECORD_ID" ;;
			*) ;;
		esac
	done
fi

[ -z "$__SERVICE_ID" ] && write_log 14 "param_opt missing service_id=VALUE"
[ -z "$__ZONE_ID"    ] && write_log 14 "param_opt missing zone_id=VALUE"
[ -z "$__RECORD_ID"  ] && write_log 14 "param_opt missing record_id=VALUE"

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
local __TOKEN __DATA __RECTYPE __DEVICE __PAYLOAD
local __CURLCFG="${DATFILE}.curl"
local __CURLEXTRA="${DATFILE}.extra"

# Explicit cleanup helper. We deliberately avoid `trap ... EXIT` because this
# script is sourced into the long-running ddns runtime, where a global trap
# would leak past this provider invocation and could clobber unrelated files
# or override traps installed by the framework / other providers.
blazingfast_cleanup() {
	rm -f "$__CURLCFG" "$__CURLEXTRA"
}

# -------------------------------------------------------------------
# blazingfast_transfer — invokes curl via config file
# Avoids eval and shell injection from user-controlled values.
# Call-specific options (method, url, headers, data) are written
# to __CURLEXTRA before each call and appended to the base config.
# -------------------------------------------------------------------
blazingfast_transfer() {
	local __CNT=0
	local __ERR

	while : ; do
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
		[ "$__ERR" -eq 0 ] && break

		write_log 3 "cURL Error: '$__ERR'"
		write_log 7 "$(cat "$ERRFILE")"

		[ "${VERBOSE_MODE:-0}" -gt 1 ] && {
			write_log 4 "Transfer failed - Verbose Mode: ${VERBOSE_MODE:-0} - NO retry on error"
			break
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

# -------------------------------------------------------------------
# Step 1 — Authenticate and obtain JWT token
# -------------------------------------------------------------------
write_log 7 "Authenticating with Blazingfast.io"

: > "$__CURLEXTRA"
echo "request = POST" >> "$__CURLEXTRA"
echo "url = \"$__URLBASE/login\"" >> "$__CURLEXTRA"
# Use data-urlencode so credentials containing reserved characters
# (&, =, +, spaces, ...) are safely percent-encoded by curl.
printf 'data-urlencode = "username=%s"\n' "$username" >> "$__CURLEXTRA"
printf 'data-urlencode = "password=%s"\n' "$password" >> "$__CURLEXTRA"
blazingfast_transfer

__TOKEN=$(jsonfilter -i "$DATFILE" -e "@.token" 2>/dev/null)
if [ -z "$__TOKEN" ]; then
	# Do NOT dump $DATFILE: a partial/successful response may contain a token.
	write_log 4 "Blazingfast authentication failed — check username/password"
	blazingfast_cleanup
	return 1
fi
write_log 7 "Authentication successful"

# -------------------------------------------------------------------
# Step 2 — Fetch all zone records and verify record type
# The Blazingfast API does not support single-record GET requests.
# All records for the zone are fetched and filtered by record_id.
# Ensures IPv4 updates only target A records and IPv6 updates only
# target AAAA records.
# -------------------------------------------------------------------
write_log 7 "Fetching zone records to verify record type is '$__TYPE'"

: > "$__CURLEXTRA"
echo "request = GET" >> "$__CURLEXTRA"
echo "url = \"$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID\"" >> "$__CURLEXTRA"
echo "header = \"Authorization: Bearer $__TOKEN\"" >> "$__CURLEXTRA"
echo "header = \"Content-Type: application/json\"" >> "$__CURLEXTRA"
blazingfast_transfer

# record id may be returned as integer or string depending on endpoint
__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id=$__RECORD_ID].type" 2>/dev/null)
[ -z "$__RECTYPE" ] && \
	__RECTYPE=$(jsonfilter -i "$DATFILE" -e "@.records[@.id='$__RECORD_ID'].type" 2>/dev/null)

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

# -------------------------------------------------------------------
# Step 3 — GET_REGISTERED_IP mode
# Returns the IP currently stored in the DNS record,
# used by ddns-scripts to compare before deciding to update.
#
# The zone records were already fetched during type verification,
# so reuse the existing API response from $DATFILE.
# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
# Step 4 — Update the DNS record
# JSON payload is built with jshn.sh so values are properly escaped
# and written inline to the curl config. This avoids any quoting or
# escaping issues when domain or IP contain special characters.
# -------------------------------------------------------------------
json_init
json_add_string "name"     "$domain"
json_add_int    "ttl"      300
json_add_int    "priority" 0
json_add_string "type"     "$__TYPE"
json_add_string "content"  "$__IP"
__PAYLOAD=$(json_dump)

: > "$__CURLEXTRA"
echo "request = PUT" >> "$__CURLEXTRA"
echo "url = \"$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID/records/$__RECORD_ID\"" >> "$__CURLEXTRA"
echo "header = \"Authorization: Bearer $__TOKEN\"" >> "$__CURLEXTRA"
echo "header = \"Content-Type: application/json\"" >> "$__CURLEXTRA"
printf 'data = "%s"\n' "$__PAYLOAD" >> "$__CURLEXTRA"
blazingfast_transfer

# verify success from API response
__DATA=$(jsonfilter -i "$DATFILE" -e "@.info[0]" 2>/dev/null)
if echo "$__DATA" | grep -q "dnsrecordupdated"; then
	write_log 7 "Record updated: $domain $__TYPE -> $__IP"
	blazingfast_cleanup
	return 0
fi

write_log 4 "Blazingfast API reported an error:"
write_log 7 "$(cat "$DATFILE")"
blazingfast_cleanup
return 1
