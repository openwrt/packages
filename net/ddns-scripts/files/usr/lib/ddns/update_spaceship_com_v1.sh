#!/bin/sh
#
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# update_spaceship_com_v1.sh sends dynamic DNS record updates with spaceship.com's v1 API.
# spaceship.com API documentaion, section 'DNS records' can be found at https://docs.spaceship.dev/#tag/DNS-records/
#
# Any pregenerated API Key derived from spaceship.com's "API Manager" must
# atleast have Read/Write permissions for the DNS Records scope. API Access for
# that individual key can be configured to exclusively bear the previoulsy
# mentioned permissions, which is both admissable and recommended.
#
# update_spaceship_com_v1.sh is parsed(not executed) by dynamic_dns_function.sh
# and the 'send_update()' function
# 
# options from /etc/config/ddns:
#	option username - your access key for spaceship.com v1 API (with
#	                  dnsrecords:write permission)
#	option password - your private secret, created with the access key
#	option domain   - the base domain to update (eg. host.<example.com>)
#	option param_opt - the name of the DNS resource record to update (eg. <host>.example.com) (optional)
#	option param_enc - the TTL in seconds of the DNS resource record to update
#	                   (must be between 60-3600(1m-1h))  (optional)
#

. /usr/share/libubox/jshn.sh

[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "Spaceship.com requires cURL with SSL support. Please install"
[ -z "$username" ] && write_log 14 "Service section not configured correctly. Missing key as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly. Missing secret as 'password'"
[ -z "$domain" ] && write_log 14 "Service section not configured correctly. Missing domain as 'domain'"

local __URL __STATUS __HOST __TTL __TYPE __CERT
__URL=https://spaceship.dev/api/v1/dns/records/${domain}

[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA" # set record
[ -z $param_opt ] && __HOST="@" || __HOST="$param_opt" # set hostname

__TTL=$param_enc
if [ $__TTL -lt 60 ] || [ $__TTL -gt 3600 ]; then
	__TTL=1800 # 30min
	write_log 4 "No TTL, defaulting to 30m(1800s)"
fi

# force HTTPS
use_https=1
if [ -f "$cacert" ]; then
	__CERT="--cacert $cacert"
elif [ -d "$cacert"]; then
	__CERT="--capath $cacert"
elif [ "$cacert" = "IGNORE" ]; then
	__CERT="--insecure"
	write_log 4 "IGNORE certificate(s) at '$cacert'. Proceed with insecure HTTP communication."
elif [ -n "$cacert" ]; then
	write_log 14 "No certificate(s) at '$cacert'. Terminate."
fi

json_init;
json_add_boolean 'force' 1;
json_add_array 'items';
json_add_object '0';
json_add_string 'type' "$__TYPE"
json_add_string 'address' "$__IP";
json_add_string 'name' "$__HOST";
json_add_int 'ttl' "$__TTL";
json_close_object;
json_close_array;

__STATUS=$(curl -Ss $__CERT -X PUT "$__URL" \
	-H "X-API-Key: ${username}" \
	-H "X-API-Secret: ${password}" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	-w "%{http_code}\n" \
	-o $DATFILE 2>$ERRFILE)
