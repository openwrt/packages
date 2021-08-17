# Script for sending user defined updates using Porkbun API v3
# Bohdan Flower <code at bohdan dot com>
# Based on update_digitalocean_com_v2.sh by 2015 Artem Yakimenko <code at temik dot me>
#
# TO DO // Do a lookup to get record ID
#
# Notes:
# Minimum TTL for records is 600s and is hard coded in script
#
# Options are passed from /etc/config/ddns:
# Hostname - dns record
# Username - apikey (public)
# Password - secretapikey (secret)
# Domain - the domain managed by Porkbun
# Parm_opt - The ID of the DNS Record in the Porkbun API structure

local __HOST
local __URL="https://porkbun.com/api/json/v3/dns/edit/[DOMAIN]/[RECORD_ID]"
local __HEADER="Accept: application/json"
local __HEADER_CONTENT="Content-Type: application/json"
local __BODY='{"secretapikey": "[SK]","apikey": "[PK]","name": "[NAME]","type": "A","content": "[IP]","ttl": "600"}'

# split __HOST from $domain
__HOST=$(printf %s "$lookup_host" | cut -d. -f1)

# inside url we need username and password

[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'apikey in username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'secretapikey in password'"
[ -z "$param_opt" ] && write_log 14 "Service section not configured correctly! Missing 'Record ID in Optional Parameter'"

# do replaces in URL, header and body:
__URL=$(echo $__URL | sed -e "s#\[RECORD_ID\]#$param_opt#g"  \
                               -e "s#\[DOMAIN\]#$domain#g")
__BODY=$(echo $__BODY | sed -e "s#\[SK\]#$password#g" -e "s#\[PK\]#$username#g" -e "s#\[NAME\]#$__HOST#g" -e "s#\[IP\]#$__IP#g")

#Send POST request
curl -X POST -H "$__HEADER_CONTENT" -H "$__HEADER" -d "$__BODY" "$__URL">$DATFILE

write_log 7 "DDNS Provider answered:\n$(cat $DATFILE)"

# analyse provider answers
# If SUCCESS is contained in the returned datastructure - API call was sucessful
grep -E "SUCCESS" $DATFILE >/dev/null 2>&1
return $?      # "0" if IP has been changed or no change is needed
