#!/bin/sh
# Derived from update_gandi_net.sh
. /usr/share/libubox/jshn.sh

local __TTL=600
local __RRTYPE
local __STATUS
local __RNAME

[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing subdomain as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing API Key as 'password'"
[ -z "$param_opt" ] && write_log 14 "Service section not configured correctly! Missing PowerDNS URL as 'Optional Parameter'(param_opt)"

# Create endpoint from $param_opt
# e.g. param_opt=http://127.0.0.1:8081
local __ENDPOINT="$param_opt/api/v1/servers/localhost/zones"

[ $use_ipv6 -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

# Make sure domain is period terminated
if [ ${domain: -1} != '.' ]; then
	domain="${domain}."
fi
if [ $username == '@' ]; then
	__RNAME="$domain"
else
	__RNAME="$username.$domain"
fi

# Build JSON payload
json_init
json_add_array rrsets
json_add_object
	json_add_string name "$__RNAME"
	json_add_string type "$__RRTYPE"
	json_add_int ttl $__TTL
	json_add_string changetype "REPLACE"
	json_add_array records
	json_add_object
		json_add_string content "$__IP"
		json_add_boolean disabled 0
	json_close_object
	json_close_array
json_close_object
json_close_array

__STATUS=$(curl -Ss -X PATCH "$__ENDPOINT/$domain" \
	-H "X-Api-Key: $password" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	-w "%{http_code}\n" \
	-o $DATFILE 2>$ERRFILE)


if [ $? -ne 0 ]; then
	write_log 14 "Curl failed: $(cat $ERRFILE)"
	return 1
elif [ -z $__STATUS ] || [ $__STATUS != 204 ]; then
	write_log 14 "PowerDNS request failed: $__STATUS \n$(cat $DATFILE)"
	return 1
fi

return 0
