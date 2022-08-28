#!/bin/sh
# captive portal auto-login script for TP-Link Omada (authType=0 only)
# Copyright (c) 2022 Sebastian Muszynski <basti@linkt.de>
# This is free software, licensed under the GNU General Public License v3

# set (s)hellcheck exceptions
# shellcheck disable=1091,2181,3037,3043,3057

. "/lib/functions.sh"
. "/usr/share/libubox/jshn.sh"

urlencode()
{
	local chr str="${1}" len="${#1}" pos=0

	while [ "${pos}" -lt "${len}" ]; do
		chr="${str:pos:1}"
		case "${chr}" in
			[a-zA-Z0-9.~_-])
				printf "%s" "${chr}"
				;;
			" ")
				printf "%%20"
				;;
			*)
				printf "%%%02X" "'${chr}"
				;;
		esac
		pos=$((pos + 1))
	done
}

urldecode()
{
	echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

request_parameter()
{
	grep -oE "$1=[^&]+" | cut -d= -f2
}

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl) --connect-timeout $((trm_maxwait / 6)) --silent"

raw_html="$(${trm_fetch} --show-error "${trm_captiveurl}")"

if [ $? -ne 0 ];
then
	echo "The captive portal didn't respond"
	exit 1
fi

if [ "$raw_html" = "success" ];
then
	echo "Internet access already available"
	exit 0
fi

redirect_url=$(echo "$raw_html" | grep -oE 'location.href="[^\"]+"' | cut -d\" -f2)

portal_baseurl=$(echo "$redirect_url" | cut -d/ -f1-4)
client_mac=$(echo "$redirect_url" | request_parameter cid)
ap_mac=$(echo "$redirect_url" | request_parameter ap)
ssid=$(echo "$redirect_url" | request_parameter ssid | urldecode)
radio_id=$(echo "$redirect_url" | request_parameter rid)
url=$(echo "$redirect_url" | request_parameter u | urldecode)

${trm_fetch} "${portal_baseurl}/pubKey" | jsonfilter -e '@.result.key' > /tmp/trm-omada-pub.key
if [ $? -ne 0 ];
then
	exit 2
fi

json_init
json_add_string "clientMac" "$client_mac"
json_add_string "apMac" "$ap_mac"
json_add_string "ssidName" "$ssid"
json_add_int "radioId" "$radio_id"
json_add_string "originUrl" "$url"
json_close_object
incomplete_auth_request="$(json_dump)"

auth_type=$(${trm_fetch} "${portal_baseurl}/getPortalPageSetting" \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-H 'X-Requested-With: XMLHttpRequest' \
	--data-raw "$incomplete_auth_request" | jsonfilter -e '@.result.authType')

if [ "$auth_type" -ne 0 ];
then
	echo "Unsupported auth type: $auth_type"
	exit 3
fi

aes_key=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)
aes_key_hex=$(printf "%s" "$aes_key" | hexdump -e '16/1 "%02x"')
aes_vi=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)
aes_vi_hex=$(printf "%s" "$aes_vi" | hexdump -e '16/1 "%02x"')

rsa_encrypted_aes_secrets=$(printf "%s" "${aes_key}${aes_vi}" | openssl rsautl -encrypt -pubin -inkey /tmp/trm-omada-pub.key | base64 -w 0)
rsa_encrypted_aes_secrets_urlencoded=$(urlencode "$rsa_encrypted_aes_secrets")

json_load "$incomplete_auth_request"
json_add_int "authType" "$auth_type"
json_close_object
auth_request="$(json_dump)"

aes_encrypted_auth_request="$(echo "$auth_request" | openssl enc -aes-128-cbc -K "$aes_key_hex" -iv "$aes_vi_hex" -a -A)"

auth_response=$(${trm_fetch} "${portal_baseurl}/auth?key=$rsa_encrypted_aes_secrets_urlencoded" \
	-H 'Content-Type: text/plain' \
	-H 'X-Requested-With: XMLHttpRequest' \
	--data-raw "$aes_encrypted_auth_request" \
	--insecure)

if echo "$auth_response" | grep -q '{"errorCode":0}';
then
	exit 0
fi

exit 255
