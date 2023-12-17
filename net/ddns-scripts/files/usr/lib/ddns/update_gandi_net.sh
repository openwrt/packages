#!/bin/sh
# Thanks goes to Alex Griffin who provided this script.

. /usr/share/libubox/jshn.sh

local __TTL=600
local __RRTYPE
local __ENDPOINT="https://api.gandi.net/v5/livedns"
local __STATUS

[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing subdomain as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing API Key as 'password'"

[ $use_ipv6 -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

local _len
local _auth
_len=${#password}
if [ "$_len" -eq "24" ]; then
    _auth="Authorization: Apikey "
elif [ "$_len" -eq "40" ]; then
    _auth="Authorization: Bearer "
else
    write_log 14 "Password wasn't length 24 or 40, cannot determine type"
    return 1
fi;
#write_log 7 $_auth
   
# Construct JSON payload
json_init
json_add_int rrset_ttl "$__TTL"
json_add_array rrset_values
json_add_string "" "$__IP"
json_close_array

# Log the curl command
write_log 7 "curl -s -X PUT \"$__ENDPOINT/domains/$domain/records/$username/$__RRTYPE\" \
	-H \"$_auth $password\" \
	-H \"Content-Type: application/json\" \
	-d \"$(json_dump)\" \
	--connect-timeout 30"

__STATUS=$(curl -s -X PUT "$__ENDPOINT/domains/$domain/records/$username/$__RRTYPE" \
	-H "$_auth $password" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	--connect-timeout 30 \
	-w "%{http_code}\n" -o $DATFILE 2>$ERRFILE)

local __ERRNO=$?
if [ $__ERRNO -ne 0 ]; then
	write_log 14 "Curl failed with $__ERRNO: $(cat $ERRFILE)"
	return 1
elif [ -z $__STATUS ] || [ $__STATUS != 201 ]; then
	write_log 14 "LiveDNS failed: $__STATUS \ngandi.net answered: $(cat $DATFILE)"
	return 1
fi

write_log 7 "gandi.net answered: $(cat $DATFILE)"

return 0
