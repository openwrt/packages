#!/bin/sh
# captive portal auto-login script for vodafone hotspots (DE)
# Copyright (c) 2021 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,3040

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -o pipefail

# source function library if necessary
#
if [ -z "${_C}" ]; then
	. "/lib/functions.sh"
fi

username="${1}"
password="${2}"
trm_domain="hotspot.vodafone.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_captiveurl="$(uci_get travelmate global trm_captiveurl "http://detectportal.firefox.com")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# get sid
#
raw_html="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --write-out "%{redirect_url}" --silent --show-error --output /dev/null "${trm_captiveurl}")"
sid="$(printf "%s" "${raw_html}" 2>/dev/null | awk 'BEGIN{FS="[=&]"}{printf "%s",$2}')"
if [ -z "${sid}" ]; then
	exit 1
fi

# get session
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" --silent --connect-timeout $((trm_maxwait / 6)) "https://${trm_domain}/api/v4/session?sid=${sid}")"
session="$(printf "%s" "${raw_html}" 2>/dev/null | jsonfilter -q -l1 -e '@.session')"
if [ -z "${session}" ]; then
	exit 2
fi

# final login request
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --referer "http://${trm_domain}/portal/?sid=${sid}" --silent --connect-timeout $((trm_maxwait / 6)) --data "accessType=csc-community&accountType=csc&loginProfile=4&password=${password}&session=${session}&username=${username}&save=true" "https://${trm_domain}/api/v4/login?sid=${sid}")"
success="$(printf "%s" "${raw_html}" 2>/dev/null | jsonfilter -q -l1 -e '@.success')"
if [ "${success}" != "true" ]; then
	exit 3
fi
