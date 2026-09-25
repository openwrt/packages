#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Script to update Hetzner DNS Records using the Cloud API (api.hetzner.cloud)
#
# 2026 Christopher Obbard <obbardc@gmail.com>
#
# Options passed from /etc/config/ddns:
# Domain   - the zone name in Hetzner Console (e.g. `example.com`)
# Username - the RRset name within the zone (e.g. `www`)
# Password - Hetzner Console API token (Bearer token)
#
# Reference: https://docs.hetzner.cloud/reference/cloud#tag/zone-rrset-actions/set_zone_rrset_records

# Hetzner API base URL
__API="https://api.hetzner.cloud/v1"

# Hetzner API requires a comment. An empty string is fine.
comment=""

. /usr/share/libubox/jshn.sh

# Check CURL exists
[ -z "$CURL" ] || [ -z "$CURL_SSL" ] && {
	write_log 14 "Hetzner Cloud DDNS script requires cURL with SSL support"
	return 1
}

# Check options
[ -z "$username" ] && write_log 14 "Hetzner Cloud DDNS: 'username' (rrset name) not set" && return 1
[ -z "$password" ] && write_log 14 "Hetzner Cloud DDNS: 'password' (API Token) not set" && return 1
[ -z "$domain" ] && write_log 14 "Hetzner Cloud DDNS: 'domain' not set (Zone name)" && return 1
[ "$use_ipv6" -eq 1 ] && type="AAAA" || type="A"

__TYPE="A"
[ "$use_ipv6" -ne 0 ] && __TYPE="AAAA"

# Create JSON payload for set_records API call
# Payload:
# { "records": [ { "value": "<ip>", "comment": "" } ] }
json_init
json_add_array "records"
	json_add_object
		json_add_string "value" "$__IP"
		json_add_string "comment" "$comment"
	json_close_object
json_close_array

__URL="${__API}/zones/${domain}/rrsets/${username}/${__TYPE}/actions/set_records"

__STATUS=$(curl -Ss -X POST "$__URL" \
	-H "Authorization: Bearer ${password}" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	-w "%{http_code}\n" -o "$DATFILE" 2>"$ERRFILE")

if [ $? -ne 0 ]; then
	write_log 14 "Curl failed (set_records): $(cat "$ERRFILE")"
	return 1
fi

# Treat any 2xx as success; otherwise error.
case "$__STATUS" in
	200|201|202) return 0 ;;
	*)
		write_log 14 "Curl failed (set_records): $__STATUS\nresponse body: $(cat "$DATFILE")"
		return 1
		;;
esac
