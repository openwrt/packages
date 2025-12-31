#!/bin/sh
# captive portal auto-login script for bahn/ICE hotspots (DE)
# Copyright (c) 2020-2025 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_funlib="/usr/lib/travelmate-functions.sh"
if [ -z "${trm_bver}" ]; then
	. "${trm_funlib}"
	f_conf
fi

trm_domain="wifi.bahn.de"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
	trm_domain="login.wifionice.de"
	if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
		exit 1
	fi
fi

# get security token
#
"${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --cookie-jar "/tmp/${trm_domain}.cookie" --output /dev/null "https://${trm_domain}/en/"
sec_token="$("${trm_awkcmd}" '/csrf/{print $7}' "/tmp/${trm_domain}.cookie" 2>/dev/null)"
rm -f "/tmp/${trm_domain}.cookie"
[ -z "${sec_token}" ] && exit 2

# final post request
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --header "Cookie: csrf=${sec_token}" --data "login=true&CSRFToken=${sec_token}" "https://${trm_domain}/en/")"
[ -z "${raw_html}" ] && exit 0 || exit 255
