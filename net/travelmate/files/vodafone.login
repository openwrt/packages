#!/bin/sh
# captive portal auto-login script for vodafone hotspots (DE)
# Copyright (c) 2021-2022 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,3040

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

username="${1}"
password="${2}"
trm_domain="hotspot.vodafone.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get sid
#
redirect_url="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --write-out "%{redirect_url}" --silent --show-error --output /dev/null "${trm_captiveurl}")"
sid="$(printf "%s" "${redirect_url}" 2>/dev/null | awk 'BEGIN{FS="[=&]"}{printf "%s",$2}')"
[ -z "${sid}" ] && exit 1

# get session
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" --silent --connect-timeout $((trm_maxwait / 6)) "https://${trm_domain}/api/v4/session?sid=${sid}")"
session="$(printf "%s" "${raw_html}" 2>/dev/null | jsonfilter -q -l1 -e '@.session')"
[ -z "${session}" ] && exit 2

ids="$(printf "%s" "${raw_html}" 2>/dev/null | jsonfilter -q -e '@.loginProfiles[*].id' | sort -n | awk '{ORS=" ";print $0}')"
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
	raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" --silent --connect-timeout $((trm_maxwait / 6)) --data "loginProfile=${login_id}&accessType=${access_type}&accountType=${account_type}&password=${password}&session=${session}&username=${username}" "https://${trm_domain}/api/v4/login?sid=${sid}")"
fi
success="$(printf "%s" "${raw_html}" 2>/dev/null | jsonfilter -q -l1 -e '@.success')"
[ "${success}" = "true" ] && exit 0 || exit 255
