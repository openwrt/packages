#!/bin/sh
# adblock cgi remote script - dns based ad/abuse domain blocking
# Copyright (c) 2026 Dirk Brenken
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# load relevant uci options
#
nft_remote="$(uci -q get adblock.global.adb_nftremote)"
nft_macremote="$(uci -q get adblock.global.adb_nftmacremote)"
nft_remotetimeout="$(uci -q get adblock.global.adb_nftremotetimeout)"
nft_authorized="0"

# parse query
#
query_str="${QUERY_STRING}"
query_mac="${query_str#*mac=}"
query_mac="${query_mac%%&*}"
query_mode="${query_str#*mode=}"
query_mode="${query_mode%%&*}"
[ "${query_mac}" = "${query_str}" ] && query_mac=""
[ "${query_mode}" = "${query_str}" ] && query_mode=""

# URL decode helper
#
urldecode() {
	printf '%b' "${1//%/\\x}"
}

# lowercase helper
#
tolower() {
	local low="${1}"

	low="${low//A/a}"
	low="${low//B/b}"
	low="${low//C/c}"
	low="${low//D/d}"
	low="${low//E/e}"
	low="${low//F/f}"
	printf '%s' "${low}"
}

# determine MAC if not provided
#
if [ -z "${query_mac}" ]; then
	query_ip="${REMOTE_ADDR}"
	query_mac="$(ip neigh show 2>/dev/null | awk -v ip="${query_ip}" '$1==ip {print $5; exit}' 2>/dev/null)"
else
	query_mac="$(urldecode "${query_mac}")"
fi

# validate MAC address
#
case "${query_mac}" in
	[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f])
		query_mac="$(tolower "${query_mac}")"
		;;
	*)
		query_mac=""
		;;
esac

# validate mode
#
[ "${query_mode}" = "renew" ] || query_mode=""

# output header and start html
#
printf '%s\n\n' "Content-Type: text/html"
printf '%s\n' "<!DOCTYPE html>
<html>
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>Adblock Remote Allow</title>

<style>
	body {
		margin: 0;
		padding: 0;
		background: #1a1a1a;
		color: #e5e5e5;
		font-family: 'Open Sans', sans-serif;
		text-align: center;
	}

	.container {
		max-width: 600px;
		margin: 2rem auto;
		padding: 1.5rem;
		background: #2b2b2b;
		border-radius: 10px;
		box-shadow: 0 0 10px rgba(0,0,0,0.4);
	}

	h1 {
		font-size: 1.6rem;
		margin-bottom: 1rem;
		color: #5fa8ff;
	}

	.msg {
		padding: 1rem;
		border-radius: 8px;
		margin-bottom: 1.5rem;
		font-size: 1.2rem;
		line-height: 1.5;
	}

	.ok {
		background: #223344;
		color: #8fc7ff;
	}

	.err {
		background: #442222;
		color: #ff8f8f;
	}

	.btn {
		display: inline-block;
		padding: 0.8rem 1.2rem;
		background: #4da3ff;
		color: #1a1a1a;
		border-radius: 8px;
		text-decoration: none;
		font-size: 1.1rem;
		font-weight: bold;
		margin-top: 1rem;
	}

	.btn:hover {
		background: #6bb6ff;
	}
	.spinner {
		margin: 1.5rem auto;
		width: 40px;
		height: 40px;
		border: 4px solid #4da3ff33;
		border-top-color: #4da3ff;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}
</style>

<script>
let refreshTimer = null;

function startRefresh() {
	stopRefresh();
	refreshTimer = setTimeout(function() { window.location.reload(); }, 5000);
}

function stopRefresh() {
	if (refreshTimer !== null) {
		clearTimeout(refreshTimer);
		refreshTimer = null;
	}
}
</script>

</head>
<body>
<div class=\"container\">
<h1>Adblock Remote Allow</h1>
"

# check if remote allow is enabled and MAC addresses are configured
#
if [ "${nft_remote}" != "1" ] || [ -z "${nft_macremote}" ]; then
	printf '%s\n' "
		<div class=\"msg err\">
			Adblock Remote Allow is not enabled or no MAC addresses configured
		</div>
	</div></body></html>"
	exit 0
fi
if [ -z "${query_mac}" ]; then
	printf '%s\n' "
		<div class=\"msg err\">
			MAC address could not be determined
		</div>
	</div></body></html>"
	exit 0
fi

# check MAC authorization
#
nft_macremote="$(tolower "${nft_macremote}")"
case " ${nft_macremote} " in
	*" ${query_mac} "*)
		nft_authorized="1"
		;;
esac
if [ "${nft_authorized}" = "0" ]; then
	printf '%s\n' "
		<div class=\"msg err\">
			This device (${query_mac}) is not registered for Adblock Remote Allow
		</div>
	</div></body></html>"
	exit 0
fi

# extract remaining timeout
#
remaining="$(nft list set inet adblock mac_remote 2>/dev/null | \
	awk -v mac="${query_mac}" '
		$0 ~ mac {
			for (i = 1; i <= NF; i++) {
				if ($i == "expires") {
					val = $(i+1)
					gsub(/[,}]/, "", val)
					sub(/s.*/, "s", val)
					print val
					exit
				}
			}
		}
	')"

# show renew option
#
if [ -z "${query_mode}" ] && [ -z "${remaining}" ]; then
	printf '%s\n' "<script>stopRefresh();</script>
		<div class=\"msg ok\">
			This device currently does not bypass ad blocking<br>
			<a class=\"btn\" href=\"?mac=${query_mac}&mode=renew\">Bypass</a>
		</div>
	</div></body></html>"
	exit 0
fi

# add MAC and redirect to main page to show remaining time
#
if [ -z "${remaining}" ] && [ "${query_mode}" = "renew" ]; then
	printf '%s\n' "
		<div class=\"msg ok\">
			Adding device...<br>
			<div class=\"spinner\"></div>
		</div>
	</div></body></html>"
	nft add element inet adblock mac_remote "{ ${query_mac//[!0-9a-f:]} }" >/dev/null 2>&1
	printf '%s\n' "<script>window.location.href='?mac=${query_mac}';</script>"
	exit 0
fi

# show remaining time
#
printf '%s\n' "
	<div class=\"msg ok\">
		This device temporarily bypasses ad blocking<br>
		Remaining time: ${remaining:-${nft_remotetimeout}m}
	</div>
	<script>startRefresh();</script>
</div></body></html>"
exit 0
