#!/bin/sh
# captive portal auto-login script for german DB hotspots via portal login API
# Copyright (c) 2020 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

trm_fetch="$(command -v curl)"
trm_domain="wifi.bahn.de"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:80.0) Gecko/20100101 Firefox/80.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"

# initial get request to receive all header information
#
"${trm_fetch}" -A "${trm_useragent}" "https://${trm_domain}" -si > "/tmp/${trm_domain}.cookie"

# extract the session cookie and the hotspot location
#
if [ -s "/tmp/${trm_domain}.cookie" ]
then
	php_token="$(awk 'BEGIN{FS="[ ;]"}/^Set-Cookie:/{print $2}' "/tmp/${trm_domain}.cookie")"
	location="$(awk '/^Location:/{print $2}' "/tmp/${trm_domain}.cookie")"
	rm -f "/tmp/${trm_domain}.cookie"
else
	exit 2
fi

# post request to subscribe to the portal API
#
if [ -n "${php_token}" ] && [ -n "${location}" ]
then
	"${trm_fetch}" -A "${trm_useragent}" "https://${trm_domain}/portal_api.php" -H "Connection: keep-alive" -H "Referer: ${location}" -H "Cookie: ${php_token}" --data "action=subscribe&type=one&connect_policy_accept=false&user_login=&user_password=&user_password_confirm=&email_address=&prefix=&phone=&policy_accept=false&gender=&interests=" -si > "/tmp/${trm_domain}.cookie"
else
	exit 3
fi

# extract additional login and password information from the portal API
#
if [ -s "/tmp/${trm_domain}.cookie" ]
then
	login="$(awk 'BEGIN{FS="[\"]"}/^\{\"info/{print $12}' "/tmp/${trm_domain}.cookie")"
	password="$(awk 'BEGIN{FS="[\"]"}/^\{\"info/{print $16}' "/tmp/${trm_domain}.cookie")"
	rm -f "/tmp/${trm_domain}.cookie"
else
	exit 4
fi

# final post request to authenticate to the portal API
#
if [ -n "${login}" ] && [ -n "${password}" ]
then
	"${trm_fetch}" -A "${trm_useragent}" "https://${trm_domain}/portal_api.php" -H "Connection: keep-alive" -H "Referer: ${location}" -H "Cookie: ${php_token}" --data "action=authenticate&login=${login}&password=${password}&policy_accept=false&from_ajax=true&wispr_mode=false"
else
	exit 5
fi
