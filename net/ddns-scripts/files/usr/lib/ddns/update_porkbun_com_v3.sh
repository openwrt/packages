# Script for sending user defined updates using Porkbun API v3
# Bohdan Flower <code at bohdan dot com>
#
# API Reference: https://porkbun.com/api/json/v3/documentation
#
# activated inside /etc/config/ddns by setting porkbun.com-3
#
# REQUIRED Options from /etc/config/ddns:
#   lookup_host (Lookup Hostname) - Full record to update (e.g. myddns.example.com)
#   domain (Domain) - the domain managed by Porkbun (e.g. example.com)
#   username (Username) - apikey (starts with pk1_)
#   password (Password) - secretapikey (starts with sk1_)
#
# Notes:  Using param_opt will disable the API lookup to get the RecordID
#         TTL minimum is 600 seconds, anything less will revert to 600

local __SUBDOMAIN __RECORDTYPE __TTL
local __URL="https://porkbun.com/api/json/v3/dns/editByNameType/[DOMAIN]/[RECORDTYPE]/[SUBDOMAIN]"
local __HEADER="Accept: application/json"
local __HEADER_CONTENT="Content-Type: application/json"
local __BODY='{"secretapikey": "[PASSWORD]","apikey": "[USERNAME]","content": "[IP]","ttl": "[TTL]"}'

# Check we have all the information we require
[ -z "$lookup_host" ] && write_log 14 "Missing Hostname, Please enter FQDN in name (Lookup Hostname) field"
[ -z "$domain" ] && write_log 14 "Missing Domain, Please enter domain in domain (Domain) field"
[ -z "$username" ] && write_log 14 "Missing apikey, Please enter apikey in username (Username) fieled"
[ -z "$password" ] && write_log 14 "Missing secretapikey, Please enter secretapikey in password (Password) field"

# Exit with Warning if not using HTTPS
if [ -z $use_https ] || [ $use_https = '0' ]; then
    write_log 14 "Porkbun API only supports HTTPS"
fi

# IPv4 or IPv6
if [ $use_ipv6 = '1' ]; then
    __RECORDTYPE="AAAA"
else
    __RECORDTYPE="A"
fi

# Use Check Interval as TTL for record if configured, mimimum TTL is 600 and limited by API
if [ -z "$CHECK_SECONDS" ]; then
    __TTL='600'
else
    write_log 7 "Using Check Interval as TTL (min 600): $CHECK_SECONDS"
    __TTL=$CHECK_SECONDS
fi


# Split __SUBDOMAIN from $lookup_host
__SUBDOMAIN=$(printf %s "$lookup_host" | cut -d. -f1)

# Do value replaces in URL and body:
__URL=$(echo $__URL | sed -e "s#\[DOMAIN\]#$domain#g" -e "s#\[RECORDTYPE\]#$__RECORDTYPE#g" -e "s#\[SUBDOMAIN\]#$__SUBDOMAIN#g")
__BODY=$(echo $__BODY | sed -e "s#\[PASSWORD\]#$password#g" -e "s#\[USERNAME\]#$username#g" -e "s#\[IP\]#$__IP#g"  -e "s#\[TTL\]#$__TTL#g")

#Send POST request
curl -X POST -H "$__HEADER_CONTENT" -H "$__HEADER" -d "$__BODY" "$__URL" >$DATFILE

write_log 7 "DDNS Provider answered: $(cat $DATFILE)"

# Analyse provider answers
# If SUCCESS is contained in the returned, API call was successful
# If "Edit error: We were unable to edit the DNS record." is returned, no change needed
grep -E "SUCCESS|Edit error: We were unable to edit the DNS record." $DATFILE >/dev/null 2>&1
return $?      # "0" if IP has been changed or no change is needed
