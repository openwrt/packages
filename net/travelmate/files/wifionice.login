#!/bin/sh
# captive portal auto-login script for ICE hotspots (DE)
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

trm_domain="www.wifionice.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get security token
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --silent --connect-timeout $((trm_maxwait / 6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "http://${trm_domain}/en/"
sec_token="$(awk '/csrf/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
if [ -z "${sec_token}" ]; then
	exit 1
fi

# final post request
#
"${trm_fetch}" --user-agent "${trm_useragent}" --silent --connect-timeout $((trm_maxwait / 6)) --header "Cookie: csrf=${sec_token}" --data "login=true&CSRFToken=${sec_token}&connect=" --output /dev/null "http://${trm_domain}/en/"
if [ "${?}" != "0" ]; then
	exit 2
fi
