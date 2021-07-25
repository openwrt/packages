#!/bin/sh
# captive portal auto-login script for DB hotspots (DE)
# Copyright (c) 2020-2021 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2181,3040

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -o pipefail

# source function library if necessary
#
if [ -z "${_C}" ]; then
	. "/lib/functions.sh"
fi

trm_domain="wifi.bahn.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get all header information
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --silent --connect-timeout $((trm_maxwait / 6)) --include --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "http://${trm_domain}"
sec_token="$(awk 'BEGIN{FS="[ ;]"}/^Set-Cookie:/{print $2}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
location="$(awk '/^Location:/{print $2}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
if [ -z "${sec_token}" ] || [ -z "${location}" ]; then
	exit 1
fi

# post request to subscribe to the portal API
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "${location}" --silent --connect-timeout $((trm_maxwait / 6)) --include --cookie-jar "/tmp/${trm_domain}.cookie" --header "Cookie: ${sec_token}" --data "action=subscribe&type=one&connect_policy_accept=false&user_login=&user_password=&user_password_confirm=&email_address=&prefix=&phone=&policy_accept=false&gender=&interests=" --output /dev/null "https://${trm_domain}/portal_api.php"
login="$(awk 'BEGIN{FS="[\"]"}/^\{\"info/{print $12}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
password="$(awk 'BEGIN{FS="[\"]"}/^\{\"info/{print $16}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
if [ -z "${login}" ] && [ -z "${password}" ]; then
	exit 2
fi

# final post request to authenticate to the portal API
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "${location}" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: ${sec_token}" --data "action=authenticate&login=${login}&password=${password}&policy_accept=false&from_ajax=true&wispr_mode=false" "https://${trm_domain}/portal_api.php"
if [ "${?}" != "0" ]; then
	exit 3
fi
