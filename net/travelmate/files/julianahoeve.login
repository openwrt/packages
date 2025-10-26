#!/bin/sh
# captive portal auto-login script for Julianahoeve beach resort (NL)
# Copyright (c) 2021-2022 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2039,2181,3040

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_domain="n23.network-auth.com"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# add trm_iface as a source of all fetch calls.
trm_iface="$(uci_get travelmate global trm_iface "")"
if [ "${trm_iface}" != "" ]; then
	trm_device="$(ifstatus "${trm_iface}" | jsonfilter -q -l1 -e '@.device')"
	[ "${trm_device}" != "" ] && trm_fetch="${trm_fetch} --interface ${trm_device} "
fi

# get redirect url
#
redirect_url="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --write-out "%{redirect_url}" --silent --show-error --output /dev/null "${trm_captiveurl}")"
[ -z "${redirect_url}" ] && exit 1

# get session cookie
#
${trm_fetch} --user-agent "${trm_useragent}" --referer "http://${trm_domain}" --silent --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "${redirect_url}"
session_id="$(awk '/p_splash_session/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
[ -z "${session_id}" ] && exit 2

# final login request
#
${trm_fetch} --user-agent "${trm_useragent}" --referer "${redirect_url}" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: p_splash_session=${session_id};" --output /dev/null "https://${trm_domain}/Camping-Julianah/hi/IHYW9cx/grant"
[ "${?}" = "0" ] && exit 0 || exit 255
