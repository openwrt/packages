#!/bin/sh
# captive portal auto-login script for telekom hotspots (DE)
# Copyright (c) 2021-2025 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

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

trm_funlib="/usr/lib/travelmate-functions.sh"
if [ -z "${trm_bver}" ]; then
	. "${trm_funlib}"
	f_conf
fi

username="$(urlencode "${1}")"
password="$(urlencode "${2}")"
trm_domain="hotspot.t-mobile.net"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
	exit 1
fi

# get redirect url
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" "${trm_captiveurl}")"
redirect_url="$(printf "%s" "${raw_html}" | "${trm_awkcmd}" 'match(tolower($0),/<loginurl>.*<\/loginurl>/){printf "%s",substr($0,RSTART+10,RLENGTH-21)}' 2>/dev/null | "${trm_awkcmd}" '{gsub("&amp;","\\&");printf "%s",$0}' 2>/dev/null)"
[ -z "${redirect_url}" ] && exit 1

# final login request
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --referer "https://${trm_domain}/wlan/rest/freeLogin" --header "content-type: application/x-www-form-urlencoded" --data "UserName=${username}&Password=${password}&FNAME=0&button=Login&OriginatingServer=http%3A%2F%2F${trm_captiveurl}" "${redirect_url}")"
login_url="$(printf "%s" "${raw_html}" | "${trm_awkcmd}" 'match(tolower($0),/<logoffurl>.*<\/logoffurl>/){printf "%s",substr($0,RSTART+11,RLENGTH-23)}' 2>/dev/null)"
[ -n "${login_url}" ] && exit 0 || exit 255
