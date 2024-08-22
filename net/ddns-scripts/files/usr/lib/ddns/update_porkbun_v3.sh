#
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
# 2024 Ansel Horn <dev@cahorn.net>
#
# Script for DDNS support via Porkbun's v3 API for the OpenWRT ddns-scripts package.
#
# Will attempt to create a new or edit an existing A or AAAA record for the
# given domain and subdomain. Existing CNAME and ALIAS records WILL NOT BE
# EDITED OR DELETED!  "username" and "password" configurations should be set to
# Porkbun API key and secret key, respectively.
#
# Porkbun API documentation:
# https://porkbun.com/api/json/v3/documentation#DNS%20Create%20Record
#

# Source JSON parser
. /usr/share/libubox/jshn.sh

# Set API base URL
# Porkbun has warned it may change API hostname in the future:
# https://porkbun.com/api/json/v3/documentation#apiHost
__API="https://api.porkbun.com/api/json/v3"

# Check availability of cURL with SSL
[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "cURL with SSL support required! Please install"

# Validate configuration
[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

# Split FQDN into domain and subdomain(s)
__DOMAIN_REGEX='^\(\(.*\)\.\)\?\([^.]\+\.[^.]\+\)$'
echo $domain | grep "$__DOMAIN_REGEX" > /dev/null || write_log 14 "Invalid domain! Check 'domain' config"
__DOMAIN=$(echo $domain | sed -e "s/$__DOMAIN_REGEX/\3/")
__SUBDOMAIN=$(echo $domain | sed -e "s/$__DOMAIN_REGEX/\2/")

# Determine IPv4 or IPv6 address and record type
if [ "$use_ipv6" -eq 1 ]; then
	expand_ipv6 "$__IP" __ADDR
	__TYPE="AAAA"
else
	__ADDR="$__IP"
	__TYPE="A"
fi


# Inject authentication into API request JSON payload
function json_authenticate() {
	json_add_string "apikey" "$username"
	json_add_string "secretapikey" "$password"
}

# Make Porkbun API call
# $1 - Porkbun API endpoint
# $2 - request JSON payload
function api_call() {
	local response url
	url="$__API/$1"
	write_log 7 "API endpoint URL: $url"
	write_log 7 "API request JSON payload: $2"
	response=$($CURL --data "$2" "$url")
	write_log 7 "API response JSON payload: $response"
	echo "$response"


# Check Porkbun API response status
function json_check_status() {
	local status
	json_get_var status "status"
	[ "$status" == "SUCCESS" ] || write_log 14 "API request failed!"
}

# Review DNS record and, if it is the record we're looking for, get its id
function callback_review_record() {
	local id name type
	json_select "$2"
	json_get_var id "id"
	json_get_var name "name"
	json_get_var type "type"
	[ "$name" == "$domain" -a "$type" == "$__TYPE" ] && echo "$id"
	json_select ..
}

# Retrieve all DNS records, find the first appropriate A/AAAA record, and get its id
function find_existing_record_id() {
	local request response
	json_init
	json_authenticate
	request=$(json_dump)
	response=$(api_call "/dns/retrieve/$__DOMAIN" "$request")
	json_load "$response"
	json_check_status
	json_for_each_item callback_review_record "records"
}

# Create a new A/AAAA record
function create_record() {
	local request response
	json_init
	json_authenticate
	json_add_string "name" "$__SUBDOMAIN"
	json_add_string "type" "$__TYPE"
	json_add_string "content" "$__ADDR"
	request=$(json_dump)
	response=$(api_call "/dns/create/$__DOMAIN" "$request")
	json_load "$response"
	json_check_status
}

# Retrieve an existing record and get its content
# $1 - record id to retrieve
function retrieve_record_content() {
	local content request response
	json_init
	json_authenticate
	request=$(json_dump)
	response=$(api_call "/dns/retrieve/$__DOMAIN/$1" "$request")
	json_load "$response"
	json_check_status
	json_select "records"
	json_select 1
	json_get_var content "content"
	echo "$content"
}

# Edit an existing A/AAAA record
# $1 - record id to edit
function edit_record() {
	local request response
	json_init
	json_authenticate
	json_add_string "type" "$__TYPE"
	json_add_string "content" "$__ADDR"
	request=$(json_dump)
	response=$(api_call "/dns/edit/$__DOMAIN/$1" "$request")
	json_load "$response"
	json_check_status
}


# Try to identify an appropriate existing DNS record to update
if [ -z $rec_id]; then
	write_log 7 "Retrieving DNS $__TYPE record"
	__ID=$(find_existing_record_id)
else
	write_log 7 "Using user-supplied DNS record id: $rec_id"
	__ID=$rec_id
fi

# Create or update DNS record with current IP address
if [ -z "$__ID" ]; then
	write_log 7 "Creating new DNS $__TYPE record"
	create_record
else
	write_log 7 "Updating existing DNS $__TYPE record"
	if [ "$(retrieve_record_content $__ID)" == "$__ADDR" ]; then
		write_log 7 "Skipping Porkbun-unsupported forced noop update"
	else
		edit_record "$__ID"
	fi
fi
