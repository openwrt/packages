#!/bin/sh
# Derived from update_gandi_net.sh

. /usr/share/libubox/jshn.sh

local __ENDPOINT="https://api.nsone.net/v1"
local __TTL=600
local __RRTYPE
local __URL
local __STATUS

[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing zone as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing API Key as 'password'"

[ $use_ipv6 -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

# Construct JSON payload
json_init
# {"answers":[{"answer":["1.1.1.1"]}]}
json_add_array answers
json_add_object
json_add_array answer
json_add_string "" "$__IP"
json_close_array
json_close_object
json_close_array

__URL="$__ENDPOINT/zones/$username/$domain/$__RRTYPE"

__STATUS=$(curl -s -X POST "$__URL" \
	-H "X-NSONE-Key: $password" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	-w "%{http_code}\n" -o $DATFILE 2>$ERRFILE)

if [ $? -ne 0 ]; then
	write_log 14 "Curl failed: $(cat $ERRFILE)"
	return 1
elif [ -z $__STATUS ] || [ $__STATUS != 200 ]; then
	write_log 4 "Request failed: $__STATUS, NS1 answered: $(cat $DATFILE)"
	if [ $__STATUS = 404 ]; then
		write_log 4 "Status is 404, trying to create a DNS record"

		json_init
		json_add_string "zone" "$username"
		json_add_string "domain" "$domain"
		json_add_string "type" "$__RRTYPE"
		json_add_string "ttl" "$__TTL"
		json_add_array answers
		json_add_object
		json_add_array answer
		json_add_string "" "$__IP"
		json_close_array
		json_close_object
		json_close_array

		__STATUS=$(curl -s -X PUT "$__URL" \
			-H "X-NSONE-Key: $password" \
			-H "Content-Type: application/json" \
			-d "$(json_dump)" \
			-w "%{http_code}\n" -o $DATFILE 2>$ERRFILE)

		if [ $? -ne 0 ]; then
			write_log 14 "Curl failed: $(cat $ERRFILE)"
			return 1
		elif [ -z $__STATUS ] || [ $__STATUS != 200 ]; then
			write_log 14 "Request failed: $__STATUS, NS1 answered: $(cat $DATFILE)"
			return 1
		fi
	else
		return 1
	fi
fi

write_log 7 "NS1 answered: $(cat $DATFILE)"

return 0
