# Script for sending user defined updates using Porkbun API v3
# Bohdan Flower <code at bohdan dot com>
#
# API Reference: https://porkbun.com/api/json/v3/documentation
#
# activated inside /etc/config/ddns by setting porkbun.com-3
#
# IMPORTANT: RecordID will need to be manually retrieved via PorkBun API and stored in param_opt
#            OR jq needs ot be installed "opkg install jq"
#
# REQUIRED Options from /etc/config/ddns:
#   name (Lookup Hostname) - Full record to update (e.g. myddns.example.com)
#   domain (Domain) - the domain managed by Porkbun (e.g. example.com)
#   username (Username) - apikey (starts with pk1_)
#   password (Password) - secretapikey (starts with sk1_)
#
# OPTIONAL Options from /etc/config/ddns:
#  param_opt (Optional Parameter) - The ReocrdID of the DNS Record in the Porkbun API structure (Only needed if jq is not installed)
#
# Notes:  Using param_opt will disable the API lookup to get the RecordID
#        TTL is hard coded to 600 seconds, this is the minimum value allowed when using web editor

local __HOST __DOMAIN __RECORDID __RECORDTYPE
local __EDITURL="https://porkbun.com/api/json/v3/dns/edit/[DOMAIN]/[RECORDID]"
local __RETRIEVEURL="https://porkbun.com/api/json/v3/dns/retrieve/[DOMAIN]"
local __CREATEURL="https://porkbun.com/api/json/v3/dns/create/[DOMAIN]"
local __HEADER="Accept: application/json"
local __HEADER_CONTENT="Content-Type: application/json"
local __EDITBODY='{"secretapikey": "[PASSWORD]","apikey": "[USERNAME]","name": "[NAME]","type": "[RECORDTYPE]","content": "[IP]","ttl": "600"}'
local __RETRIEVEBODY='{"secretapikey": "[PASSWORD]","apikey": "[USERNAME]"}'

# Check we have all the information we require
[ -z "$lookup_host" ] && write_log 14 "Missing name, Please enter FQDN in name (Lookup Hostname) field"
[ -z "$domain" ] && write_log 14 "Missing Domain, Please enter domain in domain (Domain) field"
[ -z "$username" ] && write_log 14 "Missing apikey, Please enter apikey in username (Username) fieled"
[ -z "$password" ] && write_log 14 "Missing secretapikey, Please enter secretapikey in password (Password) field"

# If not using HTTPS
if [ -z $use_https ] || [ $use_https = '0' ]; then
    write_log 14 "Porkbun API only supports HTTPS"
fi

# IPv4 or IPv6
if [ $use_ipv6 = '1' ]; then
    # Use IPv6
    __RECORDTYPE="AAAA"
else
    # Use IPv4 for any other value
    __RECORDTYPE="A"
fi

# Split __HOST from $domain
__HOST=$(printf %s "$lookup_host" | cut -d. -f1)

# If param_opt is NOT set then do API lookup to get RecordID
if [ -z "$param_opt" ]; then
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        # IF jq not installed and param_opt not set then exit with error
        write_log 14 "Missing RecordID, Please enter RecordID in param_opt (Optional Parameter) OR install jq to retrieve it via API"
    fi
    # Do value replaces in URL, header and body for retrieve
    __RETRIEVEURL=$(echo $__RETRIEVEURL | sed -e "s#\[DOMAIN\]#$domain#g")
    __RETRIEVEBODY=$(echo $__RETRIEVEBODY | sed -e "s#\[PASSWORD\]#$password#g" -e "s#\[USERNAME\]#$username#g")
    curl -X POST -H "$__HEADER_CONTENT" -H "$__HEADER" -d "$__RETRIEVEBODY" "$__RETRIEVEURL" | jq -r '.records[] | select(.name == "'$lookup_host'" and .type == "'$__RECORDTYPE'") | .id' >$DATFILE
    if [ -z `cat $DATFILE` ]; then
        write_log 7 "No RecordID Retrieved, Creating new record instead of editing existing record"
        __EDITURL=$__CREATEURL
    fi
    write_log 7 "RecordID Retrieved via API: $(cat $DATFILE)"
    __RECORDID=`cat $DATFILE`
else
    __RECORDID=$param_opt
fi

# Do value replaces in URL, header and body for edit:
__EDITURL=$(echo $__EDITURL | sed -e "s#\[RECORDID\]#$__RECORDID#g" -e "s#\[DOMAIN\]#$domain#g")
__EDITBODY=$(echo $__EDITBODY | sed -e "s#\[PASSWORD\]#$password#g" -e "s#\[USERNAME\]#$username#g" -e "s#\[NAME\]#$__HOST#g" -e "s#\[IP\]#$__IP#g"  -e "s#\[RECORDTYPE\]#$__RECORDTYPE#g")

#Send POST request
curl -X POST -H "$__HEADER_CONTENT" -H "$__HEADER" -d "$__EDITBODY" "$__EDITURL" >$DATFILE

write_log 7 "DDNS Provider answered: $(cat $DATFILE)"

# Analyse provider answers
# If SUCCESS is contained in the returned, API call was successful
# If "Edit error: We were unable to edit the DNS record." is returned, no change needed
grep -E "SUCCESS|Edit error: We were unable to edit the DNS record." $DATFILE >/dev/null 2>&1
return $?      # "0" if IP has been changed or no change is needed
