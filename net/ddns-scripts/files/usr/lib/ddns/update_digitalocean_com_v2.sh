# Script for sending user defined updates using DO API
# 2015 Artem Yakimenko <code at temik dot me>
#
# activated inside /etc/config/ddns by setting
#
# option update_script '/usr/lib/ddns/update_do.sh'
#
# the script is parsed (not executed) inside send_update() function
# of /usr/lib/ddns/dynamic_dns_functions.sh
# so you can use all available functions and global variables inside this script
# already defined in dynamic_dns_updater.sh and dynamic_dns_functions.sh
#
# It make sence to define the update url ONLY inside this script
# because it's anyway unique to the update script
# otherwise it should work with the default scripts
#
# Options are passed from /etc/config/ddns:

# Username - the record name DO Zone
# Password - API Token
# Domain - the domain managed by DO
# Parm_opt - The Record ID in the DO API structure

local __URL="https://api.digitalocean.com/v2/domains/[DOMAIN]/records/[RECORD_ID]"
local __HEADER="Authorization: Bearer [PASSWORD]"
local __HEADER_CONTENT="Content-Type: application/json"
local __BODY='{"name":"[NAME]","data": "[IP]"}'
# inside url we need username and password

[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'Zone name in Username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"
[ -z "$param_opt" ] && write_log 14 "Service section not configured correctly! Missing 'Zone ID in Optional Parameter'"

# do replaces in URL, header and body:
__URL=$(echo $__URL | sed -e "s#\[RECORD_ID\]#$param_opt#g"  \
                               -e "s#\[DOMAIN\]#$domain#g")
__HEADER=$(echo $__HEADER| sed -e "s#\[PASSWORD\]#$password#g")
__HEADER_CONTENT=$(echo $__HEADER_CONTENT)
__BODY=$(echo $__BODY | sed -e "s#\[NAME\]#$username#g" -e "s#\[IP\]#$__IP#g")

#Send PUT request

curl -X PUT -H "$__HEADER_CONTENT" -H "$__HEADER" -d "$__BODY" "$__URL"

write_log 7 "DDNS Provider answered:\n$(cat $DATFILE)"

# analyse provider answers
# If IP is contained in the returned datastructure - API call was sucessful
grep -E "$__IP" $DATFILE >/dev/null 2>&1
return $?      # "0" if IP has been changed or no change is needed
