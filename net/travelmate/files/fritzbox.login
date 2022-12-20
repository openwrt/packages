#!/bin/sh
# captive portal auto-login script template with credentials as parameters
# Copyright (c) 2020-2022 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2039,3040

. "/lib/functions.sh"

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

success="Anmeldung erfolgreich"
trm_domain="192.168.179.1:8186"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

# confirm via static URL with parameter
#
raw_html="$("${trm_fetch}" --user-agent "${trm_useragent}" --connect-timeout $((trm_maxwait / 6)) --silent --show-error --header "Content-Type:application/x-www-form-urlencoded" "http://${trm_domain}/trustme.lua?accept=yes")"
[ "${?}" = "0" ] && exit 0 || exit 255
