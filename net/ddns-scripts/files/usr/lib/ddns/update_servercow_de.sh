#!/bin/sh
# Based on update_gandi_net.sh script
# New servercow.de DNS-API https://wiki.servercow.de/de/domains/dns_api/api-syntax/

. /usr/share/libubox/jshn.sh

local __TTL=600
local __RRTYPE
local __ENDPOINT="https://api.servercow.de/dns/v1/domains"
local __STATUS

[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing username"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing password"

[ $use_ipv6 -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

# Get host and domain from $domain
__RECORD="${domain%%.*}"
__DOMAIN="${domain#*.}"

# Construct JSON payload
json_init
json_add_string "type" "$__RRTYPE"
json_add_string "name" "$__RECORD"
json_add_string "content" "$__IP"
json_add_string "ttl" "60"
json_close_array

# Log the curl command
write_log 7 "curl -s -X POST \"$__ENDPOINT/$__DOMAIN\" \
		-H \"X-Auth-Username: $username\" \
		-H \"X-Auth-Password: $password\" \
		-H \"Content-Type: application/json\" \
		-d \"$(json_dump)\" \
		--connect-timeout 30"

__STATUS=$(curl -s -X POST "$__ENDPOINT/$__DOMAIN" \
		-H "X-Auth-Username: $username" \
		-H "X-Auth-Password: $password" \
		-H "Content-Type: application/json" \
		-d "$(json_dump)" \
		--connect-timeout 30 \
		-w "%{http_code}\n" -o $DATFILE 2>$ERRFILE)

local __ERRNO=$?
if [ $__ERRNO -ne 0 ]; then
		write_log 14 "Curl failed with $__ERRNO: $(cat $ERRFILE)"
		return 1
elif [ -z $__STATUS ] || [ $__STATUS != 200 ]; then
		write_log 14 "DNS API Update failed: $__STATUS \napi.servercow.de answered: $(cat $DATFILE)"
		return 1
fi

write_log 7 "api.servercow.de answered: $(cat $DATFILE)"

return 0
