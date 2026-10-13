#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# DDNS update script (v2) for the netcup CloudDNS DynDNS API
# https://customercontrolpanel.de/wsDynDns.php
#
# For use with the OpenWrt ddns-scripts package.
# Sourced by dynamic_dns_updater.sh — do NOT call directly.
#
# v2 replaces the legacy CCP JSON API (ccp.netcup.net/.../endpoint.php) for
# domains that were migrated to netcup CloudDNS (the CCP shows a "CloudDNS"
# tab instead of a "DNS" tab for such domains).
#
# Configuration mapping (set in /etc/config/ddns):
#   username  = netcup customer number (required by the framework; not sent
#               to the API, only used for logging)
#   password  = netcup API key (generated in the CCP under "API-Keys",
#               NOT a "Legacy API key")
#   domain    = fully qualified name to update  (e.g. home.example.de)

. /usr/share/libubox/jshn.sh

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

__NETCUP_ENDPOINT="https://customercontrolpanel.de/wsDynDns.php"

# ---------------------------------------------------------------------------
# Validate required configuration variables
# ---------------------------------------------------------------------------

[ -z "$username" ]      && write_log 14 "netcup DDNS: 'username' (customer number) not set"
[ -z "$password" ]      && write_log 14 "netcup DDNS: 'password' (API key) not set"
[ -z "$domain" ]        && write_log 14 "netcup DDNS: 'domain' (FQDN to update) not set"
[ -z "$__IP" ]          && write_log 14 "netcup DDNS: __IP (current IP) not set by the framework"

# Require an HTTPS-capable client — the netcup endpoint is HTTPS only.
[ -z "$CURL_SSL" ] && [ -z "$WGET_SSL" ] && \
	write_log 14 "netcup DDNS: neither curl nor wget with HTTPS support is available"

# ---------------------------------------------------------------------------
# Derive FQDN and record type from configuration
# ---------------------------------------------------------------------------

# The API addresses the record by its FQDN, so the 'domain' option is used
# as is (a trailing dot is tolerated). No zone/hostname split is needed.
__FQDN="${domain%.}"

# DNS record type and API parameter derived from the ip-version setting.
if [ "${use_ipv6:-0}" -ne 0 ]; then
	__RRTYPE="AAAA"
	__IP_PARAM="ipv6Address"
else
	__RRTYPE="A"
	__IP_PARAM="ipv4Address"
fi

write_log 7 "netcup DDNS: fqdn='$__FQDN' type=$__RRTYPE target=$__IP"

# ---------------------------------------------------------------------------
# netcup_post()
#
# POST the update request (form data) to the netcup endpoint.
# The response body is written to the framework's $DATFILE.
# Stderr of the HTTP client goes to $ERRFILE.
# The HTTP status code is stored in $__HTTP_CODE (curl only, "0" with wget).
#
# Returns the exit code of the HTTP client (0 = transport OK).
# HTTP errors (e.g. 401) are not a transport failure: the API returns its
# error message in the body. Response status is not validated here; use
# netcup_check_response().
# ---------------------------------------------------------------------------

netcup_post() {
	__HTTP_CODE="0"

	# The API key is deliberately not written to the log.
	write_log 7 "netcup DDNS: POST action=update token=*** fqdn=$__FQDN $__IP_PARAM=$__IP"

	if [ -n "$CURL_SSL" ]; then
		# No -f: the JSON error message is in the body of 4xx/5xx responses.
		__HTTP_CODE="$($CURL -Ss \
			--data-urlencode "action=update" \
			--data-urlencode "token=$password" \
			--data-urlencode "fqdn=$__FQDN" \
			--data-urlencode "$__IP_PARAM=$__IP" \
			-o "$DATFILE" \
			-w '%{http_code}' \
			"$__NETCUP_ENDPOINT" 2>"$ERRFILE")"
	else
		# WGET_SSL is always GNU Wget, which supports --post-data and
		# --content-on-error (keeps the body of 4xx/5xx responses).
		local __enc_token __enc_fqdn __enc_ip
		urlencode __enc_token "$password"
		urlencode __enc_fqdn  "$__FQDN"
		urlencode __enc_ip    "$__IP"
		$WGET_SSL -q --content-on-error \
			--post-data="action=update&token=${__enc_token}&fqdn=${__enc_fqdn}&${__IP_PARAM}=${__enc_ip}" \
			-O "$DATFILE" \
			"$__NETCUP_ENDPOINT" 2>"$ERRFILE"
	fi
}

# ---------------------------------------------------------------------------
# netcup_check_response()
#
# Load $DATFILE as JSON and assert the API returned status "success".
# On failure the jshn state is cleared and 1 is returned.
#
# $1 — human-readable context string for the error log (e.g. "update")
#
# On success the jshn JSON state remains loaded so the caller can continue
# reading fields. The caller is responsible for calling json_cleanup().
# ---------------------------------------------------------------------------

netcup_check_response() {
	local __context="$1"
	local __status __message

	json_load_file "$DATFILE" 2>/dev/null
	json_get_var __status  "status"
	json_get_var __message "message"

	if [ "$__status" != "success" ]; then
		json_cleanup
		write_log 3 "netcup DDNS: $__context failed (status='$__status' http=$__HTTP_CODE): $__message"
		[ "$__HTTP_CODE" = "401" ] && \
			write_log 3 "netcup DDNS: HTTP 401 usually means a wrong API key — use a key from 'API-Keys', not a 'Legacy API key'"
		return 1
	fi

	__RESPONSE_MESSAGE="$__message"
	return 0
}

# ---------------------------------------------------------------------------
# Main update procedure
# ---------------------------------------------------------------------------

write_log 6 "netcup DDNS: starting update for customer $username — '$domain' → $__IP"

# --- Step 1: Send the update request ---------------------------------------
#
# One request replaces the former login / infoDnsRecords / updateDnsRecords
# sequence: the API compares the IP itself ("No record update needed."),
# creates a missing A/AAAA record and sets the TTL to 300 seconds.

if ! netcup_post; then
	write_log 3 "netcup DDNS: HTTP request failed during update: $(cat "$ERRFILE" 2>/dev/null)"
	return 1
fi

# --- Step 2: Check the response --------------------------------------------

netcup_check_response "update" || return 1
json_cleanup

write_log 6 "netcup DDNS: '$__FQDN' [$__RRTYPE] → $__IP: $__RESPONSE_MESSAGE"

return 0
