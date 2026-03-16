#!/bin/sh
# captive portal auto-login script for vodafone hotspots (DE)
# Copyright (c) 2021-2026 Dirk Brenken (dev@brenken.org)
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

username="${1}"
password="${2}"
trm_domain="hotspot.vodafone.de"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
	exit 1
fi

# get sid
#
redirect_url="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --write-out "%{redirect_url}" --output /dev/null "${trm_captiveurl}")"
sid="$(printf "%s" "${redirect_url}" 2>/dev/null | "${trm_awkcmd}" 'BEGIN{FS="[=&]"}{printf "%s",$2}')"
[ -z "${sid}" ] && exit 1

# get session
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" "https://${trm_domain}/api/v4/session?sid=${sid}")"
session="$(printf "%s" "${raw_html}" 2>/dev/null | "${trm_jsoncmd}" -q -l1 -e '@.session')"
[ -z "${session}" ] && exit 2

ids="$(printf "%s" "${raw_html}" 2>/dev/null | "${trm_jsoncmd}" -q -e '@.loginProfiles[*].id' | "${trm_sortcmd}" -n | "${trm_awkcmd}" '{ORS=" ";print $0}')"
for id in ${ids}; do
	if [ "${id}" = "4" ]; then
		login_id="4"
		access_type="csc-community"
		account_type="csc"
		break
	fi
done
[ -z "${login_id}" ] && exit 3

# final login request
#
if [ "${login_id}" = "4" ] && [ -n "${username}" ] && [ -n "${password}" ]; then
	raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" --data "loginProfile=${login_id}&accessType=${access_type}&accountType=${account_type}&password=${password}&session=${session}&username=${username}" "https://${trm_domain}/api/v4/login?sid=${sid}")"
fi
success="$(printf "%s" "${raw_html}" 2>/dev/null | "${trm_jsoncmd}" -q -l1 -e '@.success')"
[ "${success}" = "true" ] && exit 0 || exit 255
