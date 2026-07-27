#!/bin/sh
#
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
# 2026 Jorge Gallegos <kad@blegh.net>
#
# Script for DDNS support via DNSimple's v2 API for the OpenWRT ddns-scripts package.
#
# Will attempt to create a new or edit an existing A or AAAA record for the
# given lookup host and domain. "password" configuration should be set to
# DNSimple API token. "username" should be set to the DNSimple account ID.
# "domain" should be set to the DNSimple zone. Optionally, "param_opt" can
# be set to an existing DNSimple record
#
# DNSimple API documentation:
# https://developer.dnsimple.com/v2/zones/records/

# Source JSON parser
. /usr/share/libubox/jshn.sh

# Set API base URL
__API="https://api.dnsimple.com/v2"
__CONNECT_TIMEOUT=5  # cURL connect timeout in seconds

# Check availability of cURL with SSL
[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "cURL with SSL support required! Please install"

# Validate configuration
[ -z "$lookup_host" ] && write_log 14 "Service section not configured correctly! Missing 'lookup_host' (Hostname)"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username' (Account ID)"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password' (API token)"
[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing 'domain' (DNS Zone)"

__ACCOUNT_ID="$username"
__RECORD_ID="$param_opt"  # if provided, saves 1 API call to retrieve the record ID

# Get record name by substracting zone from lookup host
# if they are equal (i.e. root record) blank it
if [ "$lookup_host" = "$domain" ]; then
	__SUBDOMAIN=""
else
	__SUBDOMAIN="$(echo "$lookup_host" | sed -e "s/\.$domain\$//")"
fi
__DOMAIN="$domain"

# Determine IPv4 or IPv6 address and record type
if [ "$use_ipv6" -eq 1 ]; then
	expand_ipv6 "$__IP" __ADDR
	__RECORD_TYPE="AAAA"
else
	__ADDR="$__IP"
	__RECORD_TYPE="A"
fi


# Make DNSimple API call
# $1 - HTTP method (GET, POST, PATCH, DELETE)
# $2 - DNSimple API endpoint path
# $3 - request JSON payload (optional)
api_call() {
	local response url method payload
	method="$1"
	url="$__API/$2"
	payload="$3"

	write_log 7 "API endpoint URL: $url"
	write_log 7 "API request method: $method"
	[ -n "$payload" ] && write_log 7 "API request JSON payload: $payload"

	if [ -n "$payload" ]; then
		"$CURL" -s -X "$method" "$url" \
			-H "Authorization: Bearer $password" \
			-H "Accept: application/json" \
			-H "Content-Type: application/json" \
			--fail-with-body \
			--connect-timeout "$__CONNECT_TIMEOUT" \
			--data "$payload" \
			-o "$DATFILE" 2>"$ERRFILE"
	else
		"$CURL" -s -X "$method" "$url" \
			-H "Authorization: Bearer $password" \
			-H "Accept: application/json" \
			--fail-with-body \
			--connect-timeout "$__CONNECT_TIMEOUT" \
			-o "$DATFILE" 2>"$ERRFILE"
	fi

	if [ -s "$ERRFILE" ]; then
		write_log 14 "API response error: $(cat "$ERRFILE")"
	fi

	write_log 7 "API response JSON payload: $(cat "$DATFILE")"
	cat "$DATFILE"
}

# Check DNSimple API response for errors
# DNSimple returns HTTP error codes, but we also check for error messages in response
json_check_response() {
	local message
	json_get_var message "message" 2>/dev/null
	[ -n "$message" ] && write_log 14 "API request failed: $message"
}

# Review DNS record and, if it is the record we're looking for, get its id
callback_review_record() {
	local id name type
	json_select "$1"
	json_get_var id "id"
	json_get_var name "name"
	json_get_var type "type"

	[ "$name" = "$__SUBDOMAIN" ] && [ "$type" = "$__RECORD_TYPE" ] && echo "$id"
	json_select ..
}

# Retrieve all DNS records, find the first appropriate A/AAAA record, and get its id
find_existing_record_id() {
	local response

	# Call API with filters
	response=$(api_call "GET" "$__ACCOUNT_ID/zones/$__DOMAIN/records?name=$__SUBDOMAIN&type=$__RECORD_TYPE")
	json_load "$response"
	json_check_response

	# Check if data array exists and iterate through it
	json_select "data" 2>/dev/null || return
	json_get_keys keys
	for key in $keys; do
		local found_id
		found_id=$(callback_review_record "$key")
		if [ -n "$found_id" ]; then
			echo "$found_id"
			return
		fi
	done
}

# Create a new record
create_record() {
	local request response
	json_init
	json_add_string "name" "$__SUBDOMAIN"
	json_add_string "type" "$__RECORD_TYPE"
	json_add_string "content" "$__ADDR"
	request=$(json_dump)
	response=$(api_call "POST" "$__ACCOUNT_ID/zones/$__DOMAIN/records" "$request")
	json_load "$response"
	json_check_response
}

# Retrieve an existing record and get its content
# $1 - record id to retrieve
retrieve_record_content() {
	local content response
	response=$(api_call "GET" "$__ACCOUNT_ID/zones/$__DOMAIN/records/$1")
	json_load "$response"
	json_check_response
	json_select "data"
	json_get_var content "content"
	echo "$content"
}

# Edit an existing A/AAAA record
# $1 - record id to edit
edit_record() {
	local request response
	json_init
	json_add_string "content" "$__ADDR"
	request=$(json_dump)
	response=$(api_call "PATCH" "$__ACCOUNT_ID/zones/$__DOMAIN/records/$1" "$request")
	json_load "$response"
	json_check_response
}


# Try to identify an appropriate existing DNS record to update
if [ -z "$__RECORD_ID" ]; then
	write_log 7 "Retrieving DNS $__RECORD_TYPE record"
	__ID=$(find_existing_record_id)
else
	write_log 7 "Using user-supplied DNS record id: $__RECORD_ID"
	__ID="$__RECORD_ID"
fi

# Create or update DNS record with current IP address
if [ -z "$__ID" ]; then
	write_log 7 "Creating new DNS $__RECORD_TYPE record"
	create_record
else
	write_log 7 "Updating existing DNS $__RECORD_TYPE record"
	if [ "$use_ipv6" -eq 1 ]; then
		__IPV6=$(retrieve_record_content "$__ID")
		expand_ipv6 "$__IPV6" __CURRENT_ADDR
		write_log 7 "Expanded ipv6 from $__IPV6 to $__CURRENT_ADDR"
	else
		__CURRENT_ADDR=$(retrieve_record_content "$__ID")
	fi
	write_log 7 "$__CURRENT_ADDR == $__ADDR ?"
	if [ "$__CURRENT_ADDR" = "$__ADDR" ]; then
		write_log 7 "DNS record already has the correct IP address, skipping update"
	else
		edit_record "$__ID"
	fi
fi

