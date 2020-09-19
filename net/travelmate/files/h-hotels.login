#!/bin/sh
# captive portal auto-login script for Telekom hotspots in german h+hotels
# Copyright (c) 2020 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

domain="hotspot.t-mobile.net"
cmd="$(command -v curl)"

# curl check
#
if [ ! -x "${cmd}" ]
then
	exit 1
fi

# initial get request to receive & extract valid security tokens
#
"${cmd}" "https://${domain}/wlan/rest/freeLogin" -c "/tmp/${domain}.cookie" -s -o /dev/null

if [ -r "/tmp/${domain}.cookie" ]
then
	ses_id="$(awk '/JSESSIONID/{print $7}' "/tmp/${domain}.cookie")"
	sec_id="$(awk '/DT_H/{print $7}' "/tmp/${domain}.cookie")"
	dev_id="$(sha256sum /etc/config/wireless | awk '{printf "%s",substr($1,1,13)}')"
	rm -f "/tmp/${domain}.cookie"
else
	exit 2
fi

# final post request/login with valid session cookie/security token
#
if [ -n "${ses_id}" ] && [ -n "${sec_id}" ] && [ -n "${dev_id}" ]
then
	"${cmd}" "https://${domain}/wlan/rest/freeLogin" -H "Referer: https://${domain}/TD/hotspot/H_Hotels/en_GB/index.html" -H "Cookie: JSESSIONID=${ses_id}; DT_DEV_ID=${dev_id}; DT_H=${sec_id}" -H 'Connection: keep-alive' --data "rememberMe=true" -s -o /dev/null
else
	exit 3
fi
