#!/bin/sh
# travelmate service script, a wlan connection manager for travel router
# Copyright (c) 2016-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

# initial defaults
#
export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
trm_funlib="/usr/lib/travelmate-functions.sh"
trm_action="${1}"
[ -z "${trm_bver}" ] && . "${trm_funlib}"
f_conf

# control travelmate actions
#
while :; do
	if [ "${trm_action}" = "stop" ]; then
		if [ -s "${trm_pidfile}" ]; then
			f_log "info" "travelmate instance stopped ::: action: ${trm_action}, pid: $(< ${trm_pidfile})"
			: >"${trm_rtfile}"
			: >"${trm_pidfile}"
		fi
		break
	elif [ -n "${trm_action}" ]; then
		f_log "info" "travelmate instance started ::: action: ${trm_action}, pid: ${$}"
		f_main
		trm_action=""
	fi
	while :; do
		sleep "${trm_timeout}" 0 >/dev/null 2>&1
		rc="${?}"
		if [ "${rc}" != "0" ]; then
			[ "$(f_getgw)" = "false" ] && rc="0"
		fi
		[ "${rc}" = "0" ] && break
	done
	json_cleanup
	f_conf
	f_main
done
