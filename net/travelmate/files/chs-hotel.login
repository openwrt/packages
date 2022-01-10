#!/bin/sh
# captive portal auto-login script for chs hotels (DE)
# Copyright (c) 2020-2021 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2181,3040

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -o pipefail

trm_domain="hotspot.internet-for-guests.com"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get security tokens
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --silent --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "https://${trm_domain}/logon/cgi/index.cgi"
lg_id="$(awk '/LGNSID/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
ta_id="$(awk '/ta_id/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
cl_id="$(awk '/cl_id/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
{ [ -z "${lg_id}" ] || [ -z "${ta_id}" ] || [ -z "${cl_id}" ]; } && exit 1

# final login request
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "https://${trm_domain}/logon/cgi/index.cgi" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: LGNSID=${lg_id}; lang=en_US; use_mobile_interface=0; ta_id=${ta_id}; cl_id=${cl_id}" --data "accept_termsofuse=&freeperperiod=1&device_infos=1125:2048:1152:2048" --output /dev/null "https://${trm_domain}/logon/cgi/index.cgi"
[ "${?}" = "0" ] && exit 0 || exit 255
