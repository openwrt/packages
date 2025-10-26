#!/bin/sh
# captive portal auto-login script template with credentials as parameters
# Copyright (c) 2020-2022 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2039,3040

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

user="${1}"
password="${2}"
success="Thank you!"
trm_domain="example.com"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# add trm_iface as a source of all fetch calls.
trm_iface="$(uci_get travelmate global trm_iface "")"
if [ "${trm_iface}" != "" ]; then
	trm_device="$(ifstatus "${trm_iface}" | jsonfilter -q -l1 -e '@.device')"
	[ "${trm_device}" != "" ] && trm_fetch="${trm_fetch} --interface ${trm_device} "
fi

# login with credentials
#
raw_html="$( ${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --connect-timeout $((trm_maxwait / 6)) --silent --show-error --header "Content-Type:application/x-www-form-urlencoded" --data "username=${user}&password=${password}" "http://${trm_domain}")"
[ -z "${raw_html##*${success}*}" ] && exit 0 || exit 255
