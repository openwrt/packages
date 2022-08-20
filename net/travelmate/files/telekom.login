#!/bin/sh
# captive portal auto-login script for telekom hotspots (DE)
# Copyright (c) 2021-2022 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,3040,3043,3057

. "/lib/functions.sh"

# url encoding function
#
urlencode()
{
	local chr str="${1}" len="${#1}" pos=0

	while [ "${pos}" -lt "${len}" ]; do
		chr="${str:pos:1}"
		case "${chr}" in
			[a-zA-Z0-9.~_-])
				printf "%s" "${chr}"
				;;
			" ")
				printf "%%20"
				;;
			*)
				printf "%%%02X" "'${chr}"
				;;
		esac
		pos=$((pos + 1))
		done
}

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

username="$(urlencode "${1}")"
password="$(urlencode "${2}")"
trm_domain="telekom.portal.fon.com"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get redirect url
#
raw_html="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --location --silent --show-error "${trm_captiveurl}")"
redirect_url="$(printf "%s" "${raw_html}" | awk 'match(tolower($0),/<loginurl>.*<\/loginurl>/){printf "%s",substr($0,RSTART+10,RLENGTH-21)}' 2>/dev/null | awk '{gsub("&amp;","\\&");printf "%s",$0}' 2>/dev/null)"
[ -z "${redirect_url}" ] && exit 1

# final login request
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "https://${trm_domain}" --connect-timeout $((trm_maxwait / 6)) --header "content-type: application/x-www-form-urlencoded" --location --silent --show-error --data "UserName=${username}&Password=${password}&FNAME=0&button=Login&OriginatingServer=http%3A%2F%2F${trm_captiveurl}" "${redirect_url}")"
login_url="$(printf "%s" "${raw_html}" | awk 'match(tolower($0),/<logoffurl>.*<\/logoffurl>/){printf "%s",substr($0,RSTART+11,RLENGTH-23)}' 2>/dev/null)"
[ -n "${login_url}" ] && exit 0 || exit 255
