#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# DDNS update script for the netcup DNS API
# https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON
#
# For use with the OpenWrt ddns-scripts package.
# Sourced by dynamic_dns_updater.sh — do NOT call directly.
#
# Configuration mapping (set in /etc/config/ddns):
#   username  = netcup customer number
#   password  = netcup API password
#   param_enc = netcup API key (generated in the CCP)
#   domain    = fully qualified subdomain to update  (e.g. home.example.de)
#   param_opt = (optional) root/zone domain override (e.g. example.de)
#               When omitted the root domain is derived by stripping the
#               leftmost label from 'domain'. This only works correctly for
#               a single subdomain level (e.g. "home.example.de").
#               param_opt MUST be set explicitly in two cases:
#               1. Deep subdomains: domain=test.internal.example.org
#                  → param_opt=example.org  (hostname becomes "test.internal")
#               2. ccSLD apex domains: domain=example.co.nz
#                  → param_opt=example.co.nz  (hostname becomes "@")
#                  Note: a subdomain of a ccSLD works without param_opt:
#                  domain=home.example.co.nz → zone "example.co.nz" is
#                  derived correctly by stripping the leftmost label.

. /usr/share/libubox/jshn.sh

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

readonly __NETCUP_ENDPOINT="https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON"

# ---------------------------------------------------------------------------
# Validate required configuration variables
# ---------------------------------------------------------------------------

[ -z "$username" ]      && write_log 14 "netcup DDNS: 'username' (customer number) not set"
[ -z "$password" ]      && write_log 14 "netcup DDNS: 'password' (API password) not set"
[ -z "$param_enc" ]     && write_log 14 "netcup DDNS: 'param_enc' (API key) not set"
[ -z "$domain" ]        && write_log 14 "netcup DDNS: 'domain' (subdomain to update) not set"
[ -z "$__IP" ]          && write_log 14 "netcup DDNS: __IP (current IP) not set by the framework"
[ -z "$REGISTERED_IP" ] && write_log 14 "netcup DDNS: REGISTERED_IP not set by the framework"

# Require an HTTPS-capable client — the netcup endpoint is HTTPS only.
[ -z "$CURL_SSL" ] && [ -z "$WGET_SSL" ] && \
	write_log 14 "netcup DDNS: neither curl nor wget with HTTPS support is available"

# ---------------------------------------------------------------------------
# Derive DNS zone and record hostname from configuration
# ---------------------------------------------------------------------------

# Use param_opt as an explicit zone override; otherwise strip the leftmost
# DNS label to obtain the root domain (e.g. "home.example.de" → "example.de").
# This automatic derivation only works for a single subdomain level — set
# param_opt explicitly for deep subdomains or ccSLD apex domains (see header).
if [ -n "$param_opt" ]; then
	__ZONE="$param_opt"
else
	__ZONE="${domain#*.}"
	# If the result contains no dot the input was already a root domain.
	case "$__ZONE" in
		*.*) : ;;
		*)   __ZONE="$domain" ;;
	esac
fi

# The record hostname is everything left of the zone name.
# For the zone apex itself use "@".
[ "$domain" = "$__ZONE" ] \
	&& __REC_HOSTNAME="@" \
	|| __REC_HOSTNAME="${domain%.${__ZONE}}"

# DNS record type derived from the ip-version setting.
[ "${use_ipv6:-0}" -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

write_log 7 "netcup DDNS: zone='$__ZONE' hostname='$__REC_HOSTNAME' type=$__RRTYPE target=$__IP"

# ---------------------------------------------------------------------------
# netcup_post()
#
# POST the JSON object currently held in jshn state to the netcup endpoint.
# The response body is written to the framework's $DATFILE.
# Stderr of the HTTP client goes to $ERRFILE.
#
# Returns the exit code of the HTTP client (0 = transport OK).
# Response status is not validated here; use netcup_check_response().
# ---------------------------------------------------------------------------

netcup_post() {
	local __payload
	__payload="$(json_dump)"
	write_log 7 "netcup DDNS: POST payload: $__payload"

	if [ -n "$CURL_SSL" ]; then
		$CURL -Ss \
			-H "Content-Type: application/json" \
			-d "$__payload" \
			-o "$DATFILE" 2>"$ERRFILE" \
			"$__NETCUP_ENDPOINT"
	else
		# WGET_SSL is always GNU Wget, which supports --header and --post-data.
		$WGET_SSL -q \
			--header="Content-Type: application/json" \
			--post-data="$__payload" \
			-O "$DATFILE" \
			"$__NETCUP_ENDPOINT" 2>"$ERRFILE"
	fi
}

# ---------------------------------------------------------------------------
# netcup_check_response()
#
# Load $DATFILE as JSON and assert the API returned status "success".
# On failure the jshn state is cleared and the script terminates.
#
# $1 — human-readable context string for the error log (e.g. "login")
#
# On success the jshn JSON state remains loaded so the caller can continue
# reading fields. The caller is responsible for calling json_cleanup().
# ---------------------------------------------------------------------------

netcup_check_response() {
	local __context="$1"
	local __status __statuscode __shortmsg

	json_load "$(cat "$DATFILE")"
	json_get_var __status     "status"
	json_get_var __statuscode "statuscode"
	json_get_var __shortmsg   "shortmessage"

	if [ "$__status" != "success" ]; then
		json_cleanup
		write_log 14 "netcup DDNS: $__context failed (status='$__status' code=$__statuscode): $__shortmsg"
	fi
}

# ---------------------------------------------------------------------------
# Main update procedure
# ---------------------------------------------------------------------------

write_log 6 "netcup DDNS: starting update — '$domain' → $__IP"

# --- Step 1: Authenticate and obtain a session ID --------------------------

json_init
json_add_string "action" "login"
json_add_object "param"
	json_add_string "customernumber" "$username"
	json_add_string "apikey"         "$param_enc"
	json_add_string "apipassword"    "$password"
json_close_object

netcup_post || write_log 14 "netcup DDNS: HTTP request failed during login"
netcup_check_response "login"

json_select "responsedata"
json_get_var __SESSION_ID "apisessionid"
json_select ".."
json_cleanup

[ -z "$__SESSION_ID" ] && \
	write_log 14 "netcup DDNS: login succeeded but no session ID was returned"

write_log 6 "netcup DDNS: login successful"

# --- Step 2: Fetch all DNS records for the zone ----------------------------

json_init
json_add_string "action" "infoDnsRecords"
json_add_object "param"
	json_add_string "domainname"     "$__ZONE"
	json_add_string "customernumber" "$username"
	json_add_string "apikey"         "$param_enc"
	json_add_string "apisessionid"   "$__SESSION_ID"
json_close_object

netcup_post || write_log 14 "netcup DDNS: HTTP request failed during infoDnsRecords"
netcup_check_response "infoDnsRecords"

# --- Step 3: Find the record matching our hostname and type ----------------
#
# The API returns ALL records of the zone (A, AAAA, MX, TXT, …).
# We iterate and look for the record where both hostname and type match
# the values derived from the 'domain' configuration option.
#
# The record ID is required by updateDnsRecords to address the exact record.

__MATCH_ID=""

json_select "responsedata"
json_select "dnsrecords"
json_get_keys __RECORD_KEYS

for __key in $__RECORD_KEYS; do
	json_select "$__key"
	json_get_var __rec_id          "id"
	json_get_var __rec_name        "hostname"
	json_get_var __rec_type        "type"
	json_get_var __rec_destination "destination"
	json_select ".."

	write_log 7 "netcup DDNS: examining record id=$__rec_id '$__rec_name' [$__rec_type] = '$__rec_destination'"

	if [ "$__rec_type" = "$__RRTYPE" ] \
	&& [ "$__rec_name" = "$__REC_HOSTNAME" ] \
	&& [ "$__rec_destination" = "$REGISTERED_IP" ]; then
		__MATCH_ID="$__rec_id"
		write_log 7 "netcup DDNS: matched record id=$__MATCH_ID"
		break
	fi
done

json_cleanup

[ -z "$__MATCH_ID" ] && \
	write_log 14 "netcup DDNS: no [$__RRTYPE] record found for hostname '$__REC_HOSTNAME' in zone '$__ZONE'"

# --- Step 4: Update the matched record with the new IP ---------------------

json_init
json_add_string "action" "updateDnsRecords"
json_add_object "param"
	json_add_string "domainname"      "$__ZONE"
	json_add_string "customernumber"  "$username"
	json_add_string "apikey"          "$param_enc"
	json_add_string "apisessionid"    "$__SESSION_ID"
	json_add_object "dnsrecordset"
		json_add_array "dnsrecords"
			json_add_object
				json_add_string "id"           "$__MATCH_ID"
				json_add_string "hostname"     "$__REC_HOSTNAME"
				json_add_string "type"         "$__RRTYPE"
				json_add_string "priority"     ""
				json_add_string "destination"  "$__IP"
				json_add_string "deleterecord" "false"
				json_close_object
		json_close_array
	json_close_object
json_close_object

netcup_post || write_log 14 "netcup DDNS: HTTP request failed during updateDnsRecords"
netcup_check_response "updateDnsRecords"
json_cleanup

write_log 6 "netcup DDNS: '$__REC_HOSTNAME.$__ZONE' [$__RRTYPE] updated to $__IP"

return 0
