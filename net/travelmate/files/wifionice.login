#!/bin/sh
# captive portal auto-login script for german ICE hotspots
# Copyright (c) 2020 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

trm_domain="www.wifionice.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:80.0) Gecko/20100101 Firefox/80.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# initial get request to receive & extract a valid security token
#
"${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://www.example.com" --silent --connect-timeout $((trm_maxwait/6)) --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "http://${trm_domain}/en/"
if [ -f "/tmp/${trm_domain}.cookie" ]
then
	sec_token="$(awk '/csrf/{print $7}' "/tmp/${trm_domain}.cookie")"
	rm -f "/tmp/${trm_domain}.cookie"
else
	exit 2
fi

# final post request/login with valid session cookie/security token
#
if [ -n "${sec_token}" ]
then
	"${trm_fetch}" --user-agent "${trm_useragent}" --silent --connect-timeout $((trm_maxwait/6)) --header "Cookie: csrf=${sec_token}" --data "login=true&CSRFToken=${sec_token}&connect=" --output /dev/null "http://${trm_domain}/en/"
else
	exit 3
fi
