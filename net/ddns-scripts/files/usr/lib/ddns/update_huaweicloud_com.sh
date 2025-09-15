#!/bin/sh
#
# script for sending updates to huaweicloud.com
# 2023-2024 sxlehua <sxlehua at qq dot com>
# API documentation at https://support.huaweicloud.com/api-dns/dns_api_62003.html
# API signature documentation at https://support.huaweicloud.com/api-dns/dns_api_30003.html
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
# 
# useage:
# using following options from /etc/config/ddns
# option username  - huaweicloud Access Key Id
# option password  - huaweicloud Secret Access Key，AK、SK documentation from https://support.huaweicloud.com/devg-apisign/api-sign-provide-aksk.html
# option domain    - "hostname@yourdomain.TLD"
# 

# Check inputs
[ -z "$username" ] && write_log 14 "Configuration error! [username] cannot be empty"
[ -z "$password" ] && write_log 14 "Configuration error! [password] cannot be empty"

[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "huaweicloud API require cURL with SSL support. Please install"
command -v openssl >/dev/null 2>&1 || write_log 14 "huaweicloud API require openssl-util support. Please install"

# public variable
local __HOST __DOMAIN __TYPE __ZONE_ID __RECORD_ID
local __ENDPOINT="dns.cn-north-1.myhuaweicloud.com"
local __TTL=120
[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA"

# Get host and domain from $domain
[ "${domain:0:2}" == "@." ] && domain="${domain/./}"        # host
[ "$domain" == "${domain/@/}" ] && domain="${domain/./@}"   # host with no sperator
__HOST="${domain%%@*}"
__DOMAIN="${domain#*@}"
[ -z "$__HOST" -o "$__HOST" == "$__DOMAIN" ] && __HOST="@"

hcloud_transfer() {
	local method=$1
	local path=$2
	local query=$3
	local body=$4

	local timestamp=$(date -u +'%Y%m%dT%H%M%SZ')
	local contentType=""
	if [ ! "$method" = "GET" ]; then
		contentType="application/json"
	fi
	local _H_Content_Type=""

	local canonicalUri="${path}"
	# add / if need
	echo $canonicalUri | grep -qE "/$" || canonicalUri="$canonicalUri/"
	local canonicalQuery="$query" # for extend

	local canonicalHeaders="host:$__ENDPOINT\nx-sdk-date:$timestamp\n"
	local signedHeaders="host;x-sdk-date"

	if [ ! "$contentType" = "" ]; then
		canonicalHeaders="content-type:$contentType\n${canonicalHeaders}"
		signedHeaders="content-type;$signedHeaders"
		_H_Content_Type="Content-Type: ${contentType}"
	fi

	local hexencode=$(printf "%s" "$body" | openssl dgst -sha256 -hex 2>/dev/null | sed 's/^.* //')
	local canonicalRequest="$method\n$canonicalUri\n$canonicalQuery\n$canonicalHeaders\n$signedHeaders\n$hexencode"
	canonicalRequest="$(printf "$canonicalRequest%s")"

	local stringToSign="SDK-HMAC-SHA256\n$timestamp\n$(printf "%s" "$canonicalRequest" | openssl dgst -sha256 -hex 2>/dev/null | sed 's/^.* //')"
	stringToSign="$(printf "$stringToSign%s")"

	local signature=$(printf "%s" "$stringToSign" | openssl dgst -sha256 -hmac "$password" 2>/dev/null | sed 's/^.* //')
	authorization="SDK-HMAC-SHA256 Access=$username, SignedHeaders=$signedHeaders, Signature=$signature"

	reqUrl="$__ENDPOINT$path"
	if [ ! -z "$query" ]; then
		reqUrl="$reqUrl""?$query"
	fi

	curl -s -X "${method}" \
		-H "Host: $__ENDPOINT" \
		-H "$_H_Content_Type" \
		-H "Authorization: $authorization" \
		-H "X-Sdk-Date: $timestamp" \
		-d "${body}" \
		"https://$reqUrl"

	if [ $? -ne 0 ]; then
		write_log 4 "rest api error"
	fi
}

get_zone() {
	local resp=`hcloud_transfer GET /v2/zones "name=$__DOMAIN.&search_mode=equal" ""`
	__ZONE_ID=`printf "%s" $resp |  grep -Eo '"id":"[a-z0-9]+"' | cut -d':' -f2 | tr -d '"'`
	if [ "$__ZONE_ID" = "" ]; then
		write_log 4 "query zone error [$resp]"
		return 1
	fi
	return 0
}

upd_record() {
	local body="{\"name\":\"$__HOST.$__DOMAIN.\",\"type\":\"$__TYPE\",\"records\":[\"$__IP\"],\"ttl\":$__TTL}"
	local resp=`hcloud_transfer PUT /v2/zones/"$__ZONE_ID"/recordsets/$__RECORD_ID "" "$body"`
	local recordId=`printf "%s" $resp |  grep -Eo '"id":"[a-z0-9]+"' | cut -d':' -f2 | tr -d '"'`
	if [ ! "$recordId" = "" ]; then
		write_log 7 "upd [$recordId] success [$__TYPE] [$__IP]"
	else
		write_log 4 "upd ecord error [$resp]"
		return 1
	fi
	return 0
}

add_record() {
	local body="{\"name\":\"$__HOST.$__DOMAIN.\",\"type\":\"$__TYPE\",\"records\":[\"$__IP\"],\"ttl\":$__TTL}"
	local resp=`hcloud_transfer POST /v2/zones/"$__ZONE_ID"/recordsets "" "$body"`
	local recordId=`printf "%s" $resp |  grep -Eo '"id":"[a-z0-9]+"' | cut -d':' -f2 | tr -d '"'`
	if [ ! "$recordId" = "" ]; then
		write_log 7 "add [$recordId] success [$__TYPE] [$__IP]"
	else
		write_log 4 "add record error [$resp]"
		return 1
	fi
	return 0
}

# Get DNS record
get_record() {
	local ret=0
	local resp=`hcloud_transfer GET /v2/zones/$__ZONE_ID/recordsets "name=$__HOST.$__DOMAIN.&search_mode=equal" ""`
	__RECORD_ID=`printf "%s" $resp |  grep -Eo '"id":"[a-z0-9]+"' | cut -d':' -f2 | tr -d '"' | head -1`
	if [ "$__RECORD_ID" = "" ]; then
		# Record needs to be add
		ret=1
	else
		local remoteIp=`printf "%s" $resp | grep -Eo '"records":\[[^]]+]' | cut -d ':' -f 2-10 | tr -d '[' | tr -d ']' | tr -d '"' | head -1`
		if [ ! "$remoteIp" = "$__IP" ]; then
		# Record needs to be updated
		ret=2
		fi
	fi
	return $ret
}

get_zone || return 1
get_record

ret=$?
if [ $ret -eq 0 ]; then
	write_log 7 "nochg [$__IP]"
fi

if [ $ret -eq 1 ]; then
	add_record
fi

if [ $ret -eq 2 ]; then
	upd_record
fi
