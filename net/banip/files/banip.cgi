#!/bin/sh
# banIP cgi remote logging script - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# output HTTP response header
#
cat <<EOF
Status: 202 Accepted
Content-Type: text/plain; charset=UTF-8

EOF

# read up to 256 bytes from POST data, otherwise use QUERY_STRING, and filter out unwanted characters
#
post_string="$(head -c 256)"
request="${post_string//[^[:alnum:]=\.\:]/}"
[ -z "${request}" ] && request="${QUERY_STRING//[^[:alnum:]=\.\:]/}"

# decode the request
#
request_decode() {
	local key value token

	# parse request
	#
	key="${request%%=*}"
	value="${request#*=}"
	token="$(uci -q get banip.global.ban_remotetoken)"

	# validate value as an IP address, otherwise ignore the request
	#
	case "${value}" in
		[0-9]*.[0-9]*.[0-9]*.[0-9]*)
			;;
		[0-9A-Fa-f]*:*[0-9A-Fa-f])
			;;
		*)
			return
			;;
	esac

	# only log if token matches and banip is running, otherwise ignore the request
	#
	if [ -n "${token}" ] && [ -n "${key}" ] && [ -n "${value}" ] && [ "${key}" = "${token}" ] && /etc/init.d/banip running; then
		if [ -r "/usr/lib/banip-functions.sh" ]; then
			. "/usr/lib/banip-functions.sh"
			f_conf
			if [ "${ban_remotelog}" = "1" ] && [ -x "${ban_logreadcmd}" ] && [ -n "${ban_logterm}" ] && [ "${ban_loglimit}" != "0" ]; then
				f_log "info" "received a suspicious remote IP '${value}'"
			fi
		fi
	fi
}

# call the request decoder
#
request_decode
