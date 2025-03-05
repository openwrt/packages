#!/bin/sh
# captive portal auto-login script for hotspots in h+hotels (DE)
# Copyright (c) 2020-2024 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_domain="hotspot.netcontrol365.com"
if ! nslookup "${trm_domain}" >/dev/null 2>&1; then
	trm_domain="hotspot.t-mobile.net"
	if ! nslookup "${trm_domain}" >/dev/null 2>&1; then
		exit 1
	fi
fi

trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

if [ "${trm_domain}" = "hotspot.netcontrol365.com" ]; then
	raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --silent --show-error --header "Content-Type:application/x-www-form-urlencoded" --data "dst=&popup=false&username=hhotel&accept=on&login=" --output /dev/null "http://${trm_domain}/login")"
	[ -z "${raw_html}" ] && exit 0 || exit 255
else
	"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --silent --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "https://${trm_domain}/wlan/rest/freeLogin"
	ses_id="$(awk '/JSESSIONID/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
	sec_id="$(awk '/DT_H/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
	dev_id="$(sha256sum /etc/config/wireless 2>/dev/null | awk '{printf "%s",substr($1,1,13)}' 2>/dev/null)"
	rm -f "/tmp/${trm_domain}.cookie"
	{ [ -z "${ses_id}" ] || [ -z "${sec_id}" ] || [ -z "${dev_id}" ]; } && exit 2

	"${trm_fetch}" --user-agent "${trm_useragent}" --referer "https://${trm_domain}/TD/hotspot/H_Hotels/en_GB/index.html" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: JSESSIONID=${ses_id}; DT_DEV_ID=${dev_id}; DT_H=${sec_id}" --data "rememberMe=true" --output /dev/null "https://${trm_domain}/wlan/rest/freeLogin"
	[ "${?}" = "0" ] && exit 0 || exit 255
fi
