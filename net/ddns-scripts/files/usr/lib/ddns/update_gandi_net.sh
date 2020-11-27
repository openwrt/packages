#!/bin/sh
# Thanks goes to Alex Griffin who provided this script.

local __TTL=600
local __RRTYPE
local __ENDPOINT="https://dns.api.gandi.net/api/v5"

[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing subdomain as 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing API Key as 'password'"

[ $use_ipv6 -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

curl -s -X PUT "$__ENDPOINT/domains/$domain/records/$username/$__RRTYPE" \
	-H "X-Api-Key: $password" \
	-H "Content-Type: application/json" \
	-d "{\"rrset_ttl\": $__TTL, \"rrset_values\": [\"$__IP\"]}" >$DATFILE

write_log 7 "gandi.net answered: $(cat $DATFILE)"

return 0
