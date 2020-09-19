#!/bin/sh
# captive portal auto-login script for german chs hotels
# Copyright (c) 2020 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

domain="hotspot.internet-for-guests.com"
cmd="$(command -v curl)"

# curl check
#
if [ ! -x "${cmd}" ]
then
	exit 1
fi

# initial get request to receive & extract valid security tokens
#
"${cmd}" "https://${domain}/logon/cgi/index.cgi" -c "/tmp/${domain}.cookie" -s -o /dev/null

if [ -r "/tmp/${domain}.cookie" ]
then
	lg_id="$(awk '/LGNSID/{print $7}' "/tmp/${domain}.cookie")"
	ta_id="$(awk '/ta_id/{print $7}' "/tmp/${domain}.cookie")"
	cl_id="$(awk '/cl_id/{print $7}' "/tmp/${domain}.cookie")"
	rm -f "/tmp/${domain}.cookie"
else
	exit 2
fi

# final post request/login with valid session cookie/security token
#
if [ -n "${lg_id}" ] && [ -n "${ta_id}" ] && [ -n "${cl_id}" ]
then
	"${cmd}" "https://${domain}/logon/cgi/index.cgi" -H "Referer: https://${domain}/logon/cgi/index.cgi" -H "Cookie: LGNSID=${lg_id}; lang=en_US; use_mobile_interface=0; ta_id=${ta_id}; cl_id=${cl_id}" -H 'Connection: keep-alive' --data 'accept_termsofuse=&freeperperiod=1&device_infos=1125:2048:1152:2048' -s -o /dev/null
else
	exit 3
fi
