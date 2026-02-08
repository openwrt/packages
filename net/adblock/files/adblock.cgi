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
query_mac="$(printf "%s" "${query_str}" | sed -n 's/.*mac=\([^&]*\).*/\1/p' 2>/dev/null)"
query_mode="$(printf "%s" "${query_str}" | sed -n 's/.*mode=\([^&]*\).*/\1/p' 2>/dev/null)"

# determine MAC if not provided
#
if [ -z "${query_mac}" ]; then
	query_ip="${REMOTE_ADDR}"
	query_mac="$(ip neigh show 2>/dev/null | awk -v ip="${query_ip}" '$1==ip {print $5}' 2>/dev/null)"
fi

# validate MAC address
#
printf '%s\n' "${query_mac}" | grep -Eq '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$' 2>/dev/null \
	&& query_mac="$(printf '%s\n' "${query_mac}" | awk '{ print tolower($0) }' 2>/dev/null)" \
	|| query_mac=""

# validate mode
#
[ "${query_mode}" = "renew" ] || query_mode=""

# output header and start html
#
printf "%s\n\n" "Content-Type: text/html"
printf "%s\n" "<!DOCTYPE html>
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

function setStatus(mac) {
	window.location.href = '?mac=' + mac;
}

function showSpinner() {
	var s = document.getElementById('spinner');
	if (s) s.style.display = 'block';
}
</script>

</head>
<body>
<div class=\"container\">
<h1>Adblock Remote Allow</h1>
"

# check if remote allow is enabled
#
if [ "${nft_remote}" != "1" ] || [ -z "${nft_macremote}" ]; then
	printf "%s\n" "<div class=\"msg err\">Remote allow is not enabled or no MAC addresses configured</div></div></body></html>"
	exit 0
fi
if [ -z "${query_mac}" ]; then
	printf "%s\n" "<div class=\"msg err\">Could not determine MAC address</div></div></body></html>"
	exit 0
fi

# check MAC authorization
#
for mac in ${nft_macremote}; do
	mac="$(printf '%s' "${mac}" | awk '{ print tolower($0) }')"
	if [ "${mac}" = "${query_mac}" ]; then
		nft_authorized="1"
		break
	fi
done
if [ "${nft_authorized}" = "0" ]; then
	printf "%s\n" "<div class=\"msg err\">MAC ${query_mac} is not authorized to use remote allow</div></div></body></html>"
	exit 0
fi

# extract remaining timeout
#
# extract remaining timeout (strip ms part)
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
	printf "%s\n" "<script>stopRefresh();</script>
		<div class=\"msg ok\">
			MAC ${query_mac} is currently not in the remote allow Set<br><br>
			<a class=\"btn\" href=\"?mac=${query_mac}&mode=renew\">Renew Set Entry</a>
		</div>
	</div></body></html>"
	exit 0
fi

# add MAC
#
if [ -z "${remaining}" ]; then
	printf "%s\n" "
		<div class=\"msg ok\">
			Renewing remote allow for MAC ${query_mac}<br><br>
			<div class=\"spinner\"></div>
		</div>
	</div></body></html>"
	nft add element inet adblock mac_remote "{ ${query_mac} }" >/dev/null 2>&1
	printf "%s\n" "<script>setStatus('${query_mac}');</script>"
fi

# success message
#
printf "%s\n" "
	<div class=\"msg ok\">
		MAC ${query_mac} is temporarily allowed<br>
		Remaining time: ${remaining:-${nft_remotetimeout}m}
	</div>
	<script>startRefresh();</script>
</div></body></html>"
exit 0
