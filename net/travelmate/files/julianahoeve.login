#!/bin/sh
# captive portal auto-login script for Julianahoeve beach resort (NL)
# Copyright (c) 2021 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2039,2181,3040

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -o pipefail

# source function library if necessary
#
if [ -z "${_C}" ]; then
	. "/lib/functions.sh"
fi

trm_domain="n23.network-auth.com"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get redirect url
#
redirect_url="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --write-out "%{redirect_url}" --silent --show-error --output /dev/null "${trm_captiveurl}")"
if [ -z "${redirect_url}" ]; then
	exit 1
fi

# get session cookie
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://${trm_domain}" --silent --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "${redirect_url}"
session_id="$(awk '/p_splash_session/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
if [ -z "${session_id}" ]; then
	exit 2
fi

# final login request
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "${redirect_url}" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: p_splash_session=${session_id};" --output /dev/null "https://${trm_domain}/Camping-Julianah/hi/IHYW9cx/grant"
if [ "${?}" != "0" ]; then
	exit 3
fi
