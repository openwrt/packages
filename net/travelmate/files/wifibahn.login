#!/bin/sh
# captive portal auto-login script for bahn/ICE hotspots (DE)
# Copyright (c) 2020-2024 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_domain="wifi.bahn.de"
if ! nslookup "${trm_domain}" >/dev/null 2>&1; then
	trm_domain="login.wifionice.de"
	if ! nslookup "${trm_domain}" >/dev/null 2>&1; then
		exit 1
	fi
fi

trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get security token
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --silent --show-error --output /dev/null "https://${trm_domain}/en/"
sec_token="$(awk '/csrf/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
[ -z "${sec_token}" ] && exit 2

# final post request
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --connect-timeout $((trm_maxwait / 6)) --header "Cookie: csrf=${sec_token}" --data "login=true&CSRFToken=${sec_token}" --silent --show-error "https://${trm_domain}/en/")"
[ -z "${raw_html}" ] && exit 0 || exit 255
