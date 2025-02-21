#!/bin/sh
#
# Script for sending updates to cloud.tencent.com, modified based on
# "update_cloudflare_com_v4.sh" and "update_dnspod_cn.sh".
#
# You can found them from:
# - github.com/openwrt/packages for "update_cloudflare_com_v4.sh"
#	- at: net/ddns-scripts/files/usr/lib/ddns/update_cloudflare_com_v4.sh
# - github.com/nixonli/ddns-scripts_dnspod for "update_dnspod_cn.sh"
#
# v1.2.0:
#   - Migrate retry_count to retry_max_count
#   - Fix signature expiration during retries
# v1.1.0: Publish script
#
# 2024 FriesI23 <FriesI23@outlook.com>
#
# API documentation at https://cloud.tencent.com/document/api/1427/84627
# API signature documentation at https://cloud.tencent.com/document/api/1427/56189
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
#
# using following options from /etc/config/ddns
# you can get your own secret values from console.cloud.tencent.com/cam/capi
# option username  - api secretId
# option password  - api secretKey
# option domain    - "hostname@yourdomain.TLD"
# option record_id - record id for special record
#
# variable __IP already defined with the ip-address to use for update
#

local OPENSSL=$(command -v openssl)

# check parameters
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing key as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing secret as 'password'"
[ -z "$CURL_SSL" ] && write_log 13 "Dnspod communication require cURL with SSL support. Please install"
[ -z "$OPENSSL" ] && write_log 13 "Dnspod communication require openssl. Please install"
[ $use_https -eq 0 ] && use_https=1

# variables
local __HOST __DOMAIN __TYPE
local __RUNPROG
local __RECID __RECLINE __DATA __IPV6
local __URLHOST="dnspod.tencentcloudapi.com"
local __URLBASE="https://$__URLHOST"
local __METHOD="POST"
local __CONTENT_TYPE="application/json"
local __RETRY_COUNT=${retry_count:-$retry_max_count}

# Build base command to use
local __PRGBASE="$CURL -RsS -o $DATFILE --stderr $ERRFILE"
local __PRGEXTA=""

# split __HOST __DOMAIN from $domain
# given data:
# @example.com for "domain record"
# host.sub@example.com for a "host record"
__HOST=$(printf %s "$domain" | cut -d@ -f1)
__DOMAIN=$(printf %s "$domain" | cut -d@ -f2)

# set record type
[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA"

tencentcloud_transfer() {
	local __CNT=0
	local __ERR __CODE

	while :; do
		__RUNPROG="$__PRGBASE $($__PRGEXTA)"
		write_log 7 "#> $__RUNPROG"
		eval "$__RUNPROG"
		__ERR=$? # save communication error

		if [ $__ERR -eq 0 ]; then
			if grep -q '"Error"' "$DATFILE"; then
				__CODE=$(grep -o '"Code":\s*"[^"]*' $DATFILE | grep -o '[^"]*$' | head -1)
				[[ $__CODE == "ResourceNotFound.NoDataOfRecord" ]] && break
				write_log 3 "cURL Response Error: '$__CODE'"
				write_log 7 "$(cat $DATFILE)" # report error
			else
				break
			fi
		else
			write_log 3 "cURL Error: '$__ERR'"
			write_log 7 "$(cat $ERRFILE)" # report error
		fi

		[ $VERBOSE -gt 1 ] && {
			# VERBOSE > 1 then NO retry
			write_log 4 "Transfer failed - Verbose Mode: $VERBOSE - NO retry on error"
			break
		}

		__CNT=$(($__CNT + 1)) # increment error counter
		# if error count > __RETRY_COUNT leave here
		[ $__RETRY_COUNT -gt 0 -a $__CNT -gt $__RETRY_COUNT ] &&
			write_log 14 "Transfer failed after $__RETRY_COUNT retries"

		write_log 4 "Transfer failed - retry $__CNT/$__RETRY_COUNT in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP # enable trap-handler
		PID_SLEEP=0
	done

	# check for error
	if grep -q '"Error":' $DATFILE; then
		__CODE=$(grep -o '"Code":\s*"[^"]*' $DATFILE | grep -o '[^"]*$' | head -1)
		[[ $__CODE == "ResourceNotFound.NoDataOfRecord" ]] && return 0
		write_log 4 "TecentCloud reported an error:"
		write_log 7 "$(cat $DATFILE)" # report error
		return 1
	fi

	return 0
}

# force network/interface-device to use for communication
if [ -n "$bind_network" ]; then
	local __DEVICE
	network_get_device __DEVICE $bind_network ||
		write_log 13 "Can not detect local device using 'network_get_device $bind_network' - Error: '$?'"
	write_log 7 "Force communication via device '$__DEVICE'"
	__PRGBASE="$__PRGBASE --interface $__DEVICE"
fi

# force ip version to use
if [ $force_ipversion -eq 1 ]; then
	[ $use_ipv6 -eq 0 ] && __PRGBASE="$__PRGBASE -4" || __PRGBASE="$__PRGBASE -6" # force IPv4/IPv6
fi

# set certificate parameters
if [ "$cacert" = "IGNORE" ]; then     # idea from Ticket #15327 to ignore server cert
	__PRGBASE="$__PRGBASE --insecure" # but not empty better to use "IGNORE"
elif [ -f "$cacert" ]; then
	__PRGBASE="$__PRGBASE --cacert $cacert"
elif [ -d "$cacert" ]; then
	__PRGBASE="$__PRGBASE --capath $cacert"
elif [ -n "$cacert" ]; then # it's not a file and not a directory but given
	write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
fi

# disable proxy if not set (there might be .wgetrc or .curlrc or wrong environment set)
# or check if libcurl compiled with proxy support
if [ -z "$proxy" ]; then
	__PRGBASE="$__PRGBASE --noproxy '*'"
elif [ -z "$CURL_PROXY" ]; then
	# if libcurl has no proxy support and proxy should be used then force ERROR
	write_log 13 "cURL: libcurl compiled without Proxy support"
fi

# Signature Method v3
# get more information from github.com/TencentCloud/signature-process-demo,
# at signature-v3/bash/signv3_no_xdd.sh
# usage: build_authorization <action> <version> <timestamp> <payload>
build_authorization() {
	local __SECRET_ID=$username
	local __SECRET_KEY=$password

	local __SERVICE=$(printf %s "$__URLHOST" | cut -d '.' -f1)
	local __REGION=""
	local __ACTION=$1
	local __VERSION=$2
	local __ALGORITHM="TC3-HMAC-SHA256"
	local __TIMESTAMP=$3
	local __DATE=$(date -u -d @$__TIMESTAMP +"%Y-%m-%d")
	local __PAYLOAD=$4

	# Step 1: Concatenate request string
	local __CANONICAL_URI="/"
	local __CANONICAL_QUERYSTRING=""
	local __CANONICAL_HEADERS=$(
		cat <<EOF
content-type:$__CONTENT_TYPE
host:$__URLHOST
x-tc-action:$(echo $__ACTION | awk '{print tolower($0)}')
EOF
	)
	local __SIGNED_HEADERS="content-type;host;x-tc-action"
	local __HASHED_REQUEST_PAYLOAD=$(echo -n "$__PAYLOAD" | $OPENSSL sha256 -hex | awk '{print $2}')
	local __CANONICAL_REQEUST=$(
		cat <<EOF
$__METHOD
$__CANONICAL_URI
$__CANONICAL_QUERYSTRING
$__CANONICAL_HEADERS

$__SIGNED_HEADERS
$__HASHED_REQUEST_PAYLOAD
EOF
	)

	# Step 2: Concatenate signed string
	local __CREDENTIAL_SCOPE="$__DATE/$__SERVICE/tc3_request"
	local __HASHED_CANONICAL_REQUEST=$(printf "$__CANONICAL_REQEUST" |
		$OPENSSL sha256 -hex | awk '{print $2}')
	local __STRING_TO_SIGN=$(
		cat <<EOF
$__ALGORITHM
$__TIMESTAMP
$__CREDENTIAL_SCOPE
$__HASHED_CANONICAL_REQUEST
EOF
	)

	# Step 3: Calculate signature
	local __SECRET_DATE=$(printf "$__DATE" |
		$OPENSSL sha256 -hmac "TC3$__SECRET_KEY" | awk '{print $2}')
	local __SECRET_SERVICE=$(printf $__SERVICE |
		$OPENSSL dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_DATE" | awk '{print $2}')
	local __SECRET_SIGNING=$(printf "tc3_request" |
		$OPENSSL dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_SERVICE" | awk '{print $2}')
	local __SIGNATURE=$(printf "$__STRING_TO_SIGN" |
		$OPENSSL dgst -sha256 -mac hmac -macopt hexkey:"$__SECRET_SIGNING" | awk '{print $2}')

	# Step 4: Concatenate Authorization
	local __AUTHORIZATION="$__ALGORITHM Credential=$__SECRET_ID/$__CREDENTIAL_SCOPE, \
SignedHeaders=$__SIGNED_HEADERS, Signature=$__SIGNATURE"

	printf '%s' "$__AUTHORIZATION"
}

# Common Parameters for Signature Method v3
# usage: build_header <action> <version> <payload>
build_header() {
	local __ACTION=$1
	local __VERSION=$2
	local __TIMESTAMP=$(date +%s)
	local __PAYLOAD=$3

	local __AUTHORIZATION=$(build_authorization $__ACTION $__VERSION $__TIMESTAMP $__PAYLOAD)

	printf '%s' "--header 'HOST: $__URLHOST' "
	printf '%s' "--header 'Content-Type: $__CONTENT_TYPE' "
	printf '%s' "--header 'X-TC-Action: $__ACTION' "
	printf '%s' "--header 'X-TC-Version: $__VERSION' "
	printf '%s' "--header 'X-TC-Timestamp: $__TIMESTAMP' "
	printf '%s' "--header 'Authorization: $__AUTHORIZATION' "
}

# API: DescribeRecordList。
# https://cloud.tencent.com/document/api/1427/56166
build_describe_record_list_request_param() {
	local __PAYLOAD="{\"Domain\":\"$__DOMAIN\""
	__PAYLOAD="$__PAYLOAD,\"Offset\":0"
	__PAYLOAD="$__PAYLOAD,\"Limit\":1"
	__PAYLOAD="$__PAYLOAD,\"RecordType\":\"$__TYPE\""
	if [[ -n "$__HOST" ]]; then
		__PAYLOAD="$__PAYLOAD,\"Subdomain\":\"$__HOST\""
	fi
	__PAYLOAD="$__PAYLOAD}"

	printf '%s' "--request POST "
	printf '%s' "$__URLBASE "
	printf '%s' "--data '$__PAYLOAD' "
	build_header "DescribeRecordList" "2021-03-23" $__PAYLOAD
}

# API: CreateRecord
# https://cloud.tencent.com/document/api/1427/56180
build_create_record_request_param() {
	local __VALUE=$1
	local __RECLINE=${2:-默认}

	local __PAYLOAD="{\"Domain\":\"$__DOMAIN\""
	__PAYLOAD="$__PAYLOAD,\"RecordType\":\"$__TYPE\""
	__PAYLOAD="$__PAYLOAD,\"RecordLine\":\"$__RECLINE\""
	__PAYLOAD="$__PAYLOAD,\"Value\":\"$__VALUE\""
	if [[ -n "$__HOST" ]]; then
		__PAYLOAD="$__PAYLOAD,\"SubDomain\":\"$__HOST\""
	fi
	__PAYLOAD="$__PAYLOAD}"

	printf '%s' "--request POST "
	printf '%s' "$__URLBASE "
	printf '%s' "--data '$__PAYLOAD' "
	build_header "CreateRecord" "2021-03-23" $__PAYLOAD
}

# API: ModifyRecord
# https://cloud.tencent.com/document/api/1427/56157
build_modify_record_request_param() {
	local __VALUE=$1
	local __RECLINE=${2:-默认}
	local __RECID=$3

	local __PAYLOAD="{\"Domain\":\"$__DOMAIN\""
	__PAYLOAD="$__PAYLOAD,\"RecordType\":\"$__TYPE\""
	__PAYLOAD="$__PAYLOAD,\"RecordLine\":\"$__RECLINE\""
	__PAYLOAD="$__PAYLOAD,\"RecordId\":$__RECID"
	__PAYLOAD="$__PAYLOAD,\"Value\":\"$__VALUE\""
	if [[ -n "$__HOST" ]]; then
		__PAYLOAD="$__PAYLOAD,\"SubDomain\":\"$__HOST\""
	fi
	__PAYLOAD="$__PAYLOAD}"

	printf '%s' "--request POST "
	printf '%s' "$__URLBASE "
	printf '%s' "--data '$__PAYLOAD' "
	build_header "ModifyRecord" "2021-03-23" $__PAYLOAD
}

if [ -n "$record_id" ]; then
	__RECID="$record_id"
else
	# read record id for A or AAAA record of host.domain.TLD
	__PRGEXTA="build_describe_record_list_request_param"
	# extract zone id
	tencentcloud_transfer || return 1
	__RECID=$(grep -o '"RecordId":[[:space:]]*[0-9]*' $DATFILE | grep -o '[0-9]*' | head -1)
fi

[ $VERBOSE -gt 1 ] && write_log 7 "Got record id: $__RECID"

# extract current stored IP
__RECLINE=$(grep -o '"Line":\s*"[^"]*' $DATFILE | grep -o '[^"]*$' | head -1)
__DATA=$(grep -o '"Value":\s*"[^"]*' $DATFILE | grep -o '[^"]*$' | head -1)

# check data
[ $use_ipv6 -eq 0 ] &&
	__DATA=$(printf "%s" "$__DATA" | grep -m 1 -o "$IPV4_REGEX") ||
	__DATA=$(printf "%s" "$__DATA" | grep -m 1 -o "$IPV6_REGEX")

# we got data so verify
[ -n "$__DATA" ] && {
	# expand IPv6 for compare
	if [ $use_ipv6 -eq 1 ]; then
		expand_ipv6 $__IP __IPV6
		expand_ipv6 $__DATA __DATA
		[ "$__DATA" = "$__IPV6" ] && { # IPv6 no update needed
			write_log 7 "IPv6 at cloud.tencent.com already up to date"
			return 0
		}
	else
		[ "$__DATA" = "$__IP" ] && { # IPv4 no update needed
			write_log 7 "IPv4 at cloud.tencent.com already up to date"
			return 0
		}
	fi
}

if [ -z "$__RECID" ]; then
	# create new record if record id not found
	__PRGEXTA="build_create_record_request_param $__IP $__RECLINE"
	tencentcloud_transfer || return 1
	return 0
fi

__PRGEXTA="build_modify_record_request_param $__IP $__RECLINE $__RECID"
tencentcloud_transfer || return 1
return
