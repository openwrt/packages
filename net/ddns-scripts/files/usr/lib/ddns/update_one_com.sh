#!/bin/sh

# ONE.COM DDNS SCRIPT
# REQUIRES CURL
# $ opkg install curl

# SCRIPT BY LUGICO
# CONTACT: main@lugico.de

[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "one.com communication require cURL with SSL support. Please install"
[ -z "$domain" ]   && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

write_log 0 "one.com ddns script started"

local __SUBDOMAIN __MAINDOMAIN __LOGINURL __RECORDID
local __TTL=3600

__SUBDOMAIN=$(echo $domain | sed -e 's/[^\.]*\.[^\.]*$//' -e 's/\.$//' )
__MAINDOMAIN=$(echo $domain | sed -e "s/$__SUBDOMAIN\.//" )


# LOGGING IN
__LOGINURL=$( $CURL \
  -RsSL \
  --stderr $ERRFILE \
  -c /tmp/one_com_cookiejar \
  "https://www.one.com/admin/" \
  | grep 'Login-form login autofill' \
  | sed -e 's/.*action="//' -e 's/".*//' -e 's/\&amp;/\&/g' \
)

if ! [ "$( $CURL \
  -RsSL \
  --stderr $ERRFILE \
  -c /tmp/one_com_cookiejar \
  -b /tmp/one_com_cookiejar \
  "$__LOGINURL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -X POST \
  -d "username=$username&password=$password&credentialId=" \
  | grep "Invalid username or password.")" == "" ] ; then
  write_log 14 "Invalid credentials"
  return 1
fi


# SETTING DOMAIN
$CURL -RsSL \
  --stderr $ERRFILE \
  -o $DATFILE \
  -c /tmp/one_com_cookiejar \
  -b /tmp/one_com_cookiejar \
  "https://www.one.com/admin/select-admin-domain.do?domain=$__MAINDOMAIN"


# GETTING RECORD ID
__RECORDID=$( $CURL \
  -RsSL \
  --stderr $ERRFILE \
  -c /tmp/one_com_cookiejar \
  -b /tmp/one_com_cookiejar \
  "https://www.one.com/admin/api/domains/$__MAINDOMAIN/dns/custom_records" \
  | sed 's/,/\n/g' \
  | while read line ; do

    if ! [ "$(echo $line | grep '\"id\":\"' )" == "" ] ; then
      id=$(echo $line | sed -e 's/\"id\":\"//' -e 's/"//' )
    fi
    if ! [ "$(echo $line | grep "\"prefix\":\"$__SUBDOMAIN\"" )" == "" ] ; then
      if [ "$id" == "" ] ; then
        echo "0"
      fi
      write_log 0 "record id: $id"
      echo $id
      break
    fi
  done \
)

if [ "$__RECORDID" == "" ] ; then
  write_log 0 "domain record not found"
  return 1
fi

if [ "$__RECORDID" == "0" ] ; then
  write_log 14 "no id for domain record found"
  return 1
fi



# SENDING PATCH
if [ "$( $CURL \
  -RsSL \
  --stderr $ERRFILE \
  -c /tmp/one_com_cookiejar \
  -b /tmp/one_com_cookiejar \
  -X PATCH \
  -d "{\"type\":\"dns_service_records\",\"id\":\"$__RECORDID\",\"attributes\":{\"type\":\"A\",\"prefix\":\"$__SUBDOMAIN\",\"content\":\"$__IP\",\"ttl\":$__TTL}}" \
  -H "Content-Type: application/json" \
  "https://www.one.com/admin/api/domains/$__MAINDOMAIN/dns/custom_records/$__RECORDID" \
  | grep "priority")" == "" ] ; then
  echo $result
  write_log 14 "one.com gave an unexpected response"
  return 1
fi

write_log 0 "one.com ddns script finished without errors"

return 0
