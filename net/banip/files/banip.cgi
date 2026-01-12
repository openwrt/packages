#!/bin/sh
# banIP cgi remote logging script - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# handle post/get requests
#
post_string="$(cat)"
request="${post_string//[^[:alnum:]=\.\:]/}"
[ -z "${request}" ] && request="${QUERY_STRING//[^[:alnum:]=\.\:]/}"

request_decode() {
	local key value token

	key="${request%=*}"
	value="${request#*=}"
	token="$(uci -q get banip.global.ban_remotetoken)"

	if [ -n "${key}" ] && [ -n "${value}" ] && [ "${key}" = "${token}" ] && /etc/init.d/banip running; then
		[ -r "/usr/lib/banip-functions.sh" ] && { . "/usr/lib/banip-functions.sh"; f_conf; }
		if [ "${ban_remotelog}" = "1" ] && [ -x "${ban_logreadcmd}" ] && [ -n "${ban_logterm%%??}" ] && [ "${ban_loglimit}" != "0" ]; then
			f_log "info" "received a suspicious remote IP '${value}'"
		fi
	fi
}

cat <<EOF
Status: 202 Accepted
Content-Type: text/plain; charset=UTF-8

EOF

request_decode
