#
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# script for sending updates to cloudflare.com
#.2014-2015 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
#.2016 Markus Reiter <me@reitermark.us>
# many thanks to Paul for testing and feedback during development
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
#
# using following options from /etc/config/ddns
# option username - your cloudflare e-mail
# option password - cloudflare api key, you can get it from cloudflare.com/my-account/
# option domain   - your full hostname to update, in cloudflare its subdomain.domain
#                   i.e. myhost.example.com where myhost is the subdomain and example.com is your domain
#
# variable __IP already defined with the ip-address to use for update
#
[ "$use_https" -eq 0 ] && write_log 14 "CloudFlare only supports updates via HTTPS. Please correct configuration!"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'."
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'."

local __ZONEID __RECID __OLDIP __TYPE __SUBDOM __DOMAIN __TLD

# split given Host/Domain into TLD, registrable domain, and subdomain
split_FQDN $domain __TLD __DOMAIN __SUBDOM
[ $? -ne 0 -o -z "$__DOMAIN" ] && \
  write_log 14 "Wrong host/domain configuration ($domain). Please correct configuration!"
# put together what we need
__DOMAIN="$__DOMAIN.$__TLD"

# parse OpenWrt script with
# functions for parsing and generating json
. /usr/share/libubox/jshn.sh

# function copied from /usr/share/libubox/jshn.sh
# from BB14.09 for backward compatibility to AA12.09
grep -i "json_get_keys" /usr/share/libubox/jshn.sh >/dev/null 2>&1 || json_get_keys() {
  local __dest="$1"
  local _tbl_cur

  if [ -n "$2" ]; then
    json_get_var _tbl_cur "$2"
  else
    _json_get_var _tbl_cur JSON_CUR
  fi
  local __var="${JSON_PREFIX}KEYS_${_tbl_cur}"
  eval "export -- \"$__dest=\${$__var}\"; [ -n \"\${$__var+x}\" ]"
}

# function to "sed" unwanted string parts from DATFILE
cleanup() {
  # based on the sample output on cloudflare.com homepage we need to do some cleanup
  sed -i 's/^[ \t]*//;s/[ \t]*$//' $DATFILE  # remove invisible chars at beginning and end of lines
  sed -i '/^-$/d' $DATFILE                   # remove lines with "-" (dash)
  sed -i '/^$/d' $DATFILE                    # remove empty lines
  sed -i "#'##g" $DATFILE                    # remove "'" (single quote)
}

do_request() {
  local method data url success messages args
  method="$1"
  shift

  if [ "$method" != "GET" ]; then
    data="$1"
    shift
  fi

  url="$@"

  set -- \
    --quiet \
    --header "Content-Type: application/json" \
    --header "X-Auth-Email: $username" \
    --header "X-Auth-Key: $password" \
    "$@"

  if [ -n "$WGET_SSL" -a $USE_CURL -eq 0 ]; then
    [ -n "$data" ] && set -- --body-data="$data" "$@"
    "$WGET_SSL" -O "$DATFILE" --method="$method" "$@"
  elif [ -n "$CURL_SSL" ]; then
    [ -n "$data" ] && set -- --data="$data" "$@"
    "$CURL_SSL" -o "$DATFILE" -X "$method" "$@"
  else
    write_log 14 "CloudFlare only supports updates via HTTPS. 'wget-ssl' or 'curl-ssl' has to be installed!"
  fi
  cleanup

  json_init
  json_load "$(cat $DATFILE)"
  json_get_var success "success" && [ $success -eq 1 ] || {
    json_get_values messages "messages"
    write_log 4 "'$url' failed with error: \n$messages"
    return 1
  }

  return 0
}


# GET ZONE

do_request GET "https://api.cloudflare.com/client/v4/zones?name=$__DOMAIN" || return 1

json_get_keys result "result"
json_select "result"

for zone in $result; do
  json_select "$zone"
  json_get_var __ZONEID "id"
  json_select ..
  break
done

if [ -z "$__ZONEID" ]; then
  write_log 14 "No valid Zone found on CloudFlare. Please create one first!"
else
  write_log 7 "Zone ID '$__ZONEID' detected for domain '$__DOMAIN'."
fi


# GET DNS RECORD

do_request GET "https://api.cloudflare.com/client/v4/zones/$__ZONEID/dns_records?name=$domain" || return 1

json_get_keys result "result"
json_select "result"

for record in $result; do
  json_select "$record"
  json_get_var __TYPE "type"
  if [ \( "$use_ipv6" -eq 0 -a "$__TYPE" = "A" \) -o \( "$use_ipv6" -eq 1 -a "$__TYPE" = "AAAA" \) ]; then
    json_get_var __RECID "id"
    json_get_var __OLDIP "content"
    break
  fi
  json_select ..
done

if [ -z "$__RECID" ]; then
  write_log 14 "No valid DNS record found on CloudFlare. Please create one first!"
else
  write_log 7 "Record ID '$__RECID' detected for host/domain '$domain'."
fi


# UPDATE IP

if [ "$__OLDIP" = "$__IP" ]; then
  return 0
fi

do_request PUT "{\"type\":\"$__TYPE\",\"name\":\"$domain\",\"content\":\"$__IP\"}" \
  "https://api.cloudflare.com/client/v4/zones/$__ZONEID/dns_records/$__RECID" || return 1

write_log 7 "DNS record with ID '$__RECID' updated successfully."

return 0
