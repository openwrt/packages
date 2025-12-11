#!/bin/sh
# captive portal auto-login script template with credentials as parameters
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

user="${1}"
password="${2}"
trm_domain="example.com"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
	exit 1
fi

# login with credentials
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --header "Content-Type:application/x-www-form-urlencoded" --data "username=${user}&password=${password}" "http://${trm_domain}")"
[ -z "${raw_html}" ] && exit 0 || exit 255

