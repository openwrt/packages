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
# option domain    - Full DNS record name to update, e.g. uk.nightmare.gr
# option param_opt - Space-separated key=value pairs:
#                    service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID
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
#   4. List records to get record_id (replace SERVICE_ID and ZONE_ID):
#      curl -s 'https://my.blazingfast.io/api/service/SERVICE_ID/dns/ZONE_ID' \
#        -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
#
#   Then set param_opt to "service_id=SERVICE_ID zone_id=ZONE_ID record_id=RECORD_ID"
#
# variable __IP already defined with the ip-address to use for update
#

# check parameters
[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "Blazingfast communication requires cURL with SSL support. Please install"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"
[ -z "$domain"   ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ $use_https -eq 0 ] && use_https=1	# force HTTPS

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

# set record type
local __TYPE
[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA"

local __URLBASE="https://my.blazingfast.io/api"
local __PRGBASE __RUNPROG __TOKEN __DATA

# transfer function — mirrors Cloudflare's pattern for retry/error handling
blazingfast_transfer() {
	local __CNT=0
	local __ERR
	while : ; do
		write_log 7 "#> $__RUNPROG"
		eval "$__RUNPROG"
		__ERR=$?
		[ $__ERR -eq 0 ] && break

		write_log 3 "cURL Error: '$__ERR'"
		write_log 7 "$(cat $ERRFILE)"

		[ $VERBOSE_MODE -gt 1 ] && {
			write_log 4 "Transfer failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			break
		}

		__CNT=$(( $__CNT + 1 ))
		[ $retry_max_count -gt 0 -a $__CNT -gt $retry_max_count ] && \
			write_log 14 "Transfer failed after $retry_max_count retries"

		write_log 4 "Transfer failed - retry $__CNT/$retry_max_count in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP
		PID_SLEEP=0
	done
}

# build base curl command — handles SSL, proxy, interface, certificates
# exactly as other providers do
__PRGBASE="$CURL -RsS -o $DATFILE --stderr $ERRFILE"

if [ -n "$bind_network" ]; then
	local __DEVICE
	network_get_device __DEVICE $bind_network || \
		write_log 13 "Cannot detect local device using 'network_get_device $bind_network' - Error: '$?'"
	write_log 7 "Force communication via device '$__DEVICE'"
	__PRGBASE="$__PRGBASE --interface $__DEVICE"
fi

if [ $force_ipversion -eq 1 ]; then
	[ $use_ipv6 -eq 0 ] && __PRGBASE="$__PRGBASE -4" || __PRGBASE="$__PRGBASE -6"
fi

if [ "$cacert" = "IGNORE" ]; then
	__PRGBASE="$__PRGBASE --insecure"
elif [ -f "$cacert" ]; then
	__PRGBASE="$__PRGBASE --cacert $cacert"
elif [ -d "$cacert" ]; then
	__PRGBASE="$__PRGBASE --capath $cacert"
elif [ -n "$cacert" ]; then
	write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
fi

if [ -z "$proxy" ]; then
	__PRGBASE="$__PRGBASE --noproxy '*'"
elif [ -z "$CURL_PROXY" ]; then
	write_log 13 "cURL: libcurl compiled without Proxy support"
fi

# -------------------------------------------------------------------
# Step 1 — Authenticate and obtain JWT token
# -------------------------------------------------------------------
write_log 7 "Authenticating with Blazingfast.io"

__RUNPROG="$__PRGBASE --request POST '$__URLBASE/login'"
__RUNPROG="$__RUNPROG --data 'username=$username'"
__RUNPROG="$__RUNPROG --data 'password=$password'"
blazingfast_transfer

__TOKEN=$(jsonfilter -i "$DATFILE" -e "@.token" 2>/dev/null)
[ -z "$__TOKEN" ] && {
	write_log 4 "Blazingfast authentication failed — check username/password"
	write_log 7 "$(cat $DATFILE)"
	return 1
}
write_log 7 "Authentication successful"

# add auth header to base command for all subsequent calls
__PRGBASE="$__PRGBASE --header 'Authorization: Bearer $__TOKEN'"
__PRGBASE="$__PRGBASE --header 'Content-Type: application/json'"

# -------------------------------------------------------------------
# Step 2 — GET_REGISTERED_IP mode
# Returns the IP currently stored in the DNS record
# (used by ddns-scripts to compare before deciding to update)
# -------------------------------------------------------------------
if [ -n "$GET_REGISTERED_IP" ]; then
	__RUNPROG="$__PRGBASE --request GET '$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID/records/$__RECORD_ID'"
	blazingfast_transfer

	__DATA=$(jsonfilter -i "$DATFILE" -e "@.record.content" 2>/dev/null)
	if [ -n "$__DATA" ]; then
		write_log 7 "Registered IP '$__DATA' detected via Blazingfast API"
		REGISTERED_IP="$__DATA"
		return 0
	else
		write_log 4 "Could not extract IP from Blazingfast API response"
		write_log 7 "$(cat $DATFILE)"
		return 127
	fi
fi

# -------------------------------------------------------------------
# Step 3 — Update the DNS record
# -------------------------------------------------------------------
cat > $DATFILE << EOF
{"name":"$domain","ttl":300,"priority":0,"type":"$__TYPE","content":"$__IP"}
EOF

__RUNPROG="$__PRGBASE --request PUT --data @$DATFILE"
__RUNPROG="$__RUNPROG '$__URLBASE/service/$__SERVICE_ID/dns/$__ZONE_ID/records/$__RECORD_ID'"
blazingfast_transfer

# verify success from API response
__DATA=$(jsonfilter -i "$DATFILE" -e "@.info[0]" 2>/dev/null)
echo "$__DATA" | grep -q "dnsrecordupdated" && {
	write_log 7 "Record updated: $domain -> $__IP"
	return 0
}

write_log 4 "Blazingfast API reported an error:"
write_log 7 "$(cat $DATFILE)"
return 1
