#!/bin/sh
#
# 2021 Martijn Atema <martijn@atema.one>
#
# This script sends ddns updates using the TransIP API (see https://api.transip.nl/)
# and is parsed by dynamic_dns_functions.sh inside send_update().
#
# The following options provided by ddns are used:
# username  - Username of account used for logging in to TransIP
# password  - Private key generated at https://www.transip.nl/cp/account/api/
#            (make sure to accept non-whitelisted IP addresses)
# domain    - Base domain name registered at TransIP
#             ('domain.tld' when updating 'hostname.domain.tld')
# param_enc - Name of DNS record to update
#             ('hostname' when updating 'hostname.domain.tld')
# param_opt - TTL of the DNS record to update (in seconds)
#
# Note: Make sure that there is exactly one record of type A (for IPv4) or
#       AAAA (for IPv6) with the specified name and TTL. That record will be
#       updated by this script.
#
# The script requires cURL with SSL and the openssl binary


[ -z "${username}" ] && write_log 14 "Service config is missing 'username'"
[ -z "${password}" ] && write_log 14 "Service config is missing 'password' (private key)"
[ -z "${domain}" ] && write_log 14 "Service config is missing 'domain' (base domain name)"
[ -z "${param_enc}" ] && write_log 14 "Service config is missing 'param_enc' (DNS record name)"
[ -z "${param_opt}" ] && write_log 14 "Service config is missing 'param_opt' (DNS record TTL)"

[ -z "${CURL_SSL}" ] && write_log 14 "TransIP update requires cURL with SSL"
[ -z "$(openssl version)" ] && write_log 14 "TransIP update requires openssl binary"

. /usr/share/libubox/jshn.sh


# Re-format the private key and write to a temporary file

__tmp_keyfile="$(mktemp -t ddns-transip.XXXXXX)"

echo "${password}" | \
        sed -e "s/-----BEGIN PRIVATE KEY-----\s*/&\n/" \
        -e "s/-----END PRIVATE KEY-----/\n&/" \
        -e "s/\S\{64\}\s*/&\n/g" \
        > "${__tmp_keyfile}"


# Create authentication request

json_init
json_add_string "login" "${username}"
json_add_string "label" "DDNS-script ($(openssl rand -hex 4))"
json_add_string "nonce" $(openssl rand -hex 16)
json_add_boolean "read_only" 0
json_add_boolean "global_key" 1
__auth_body="$(json_dump)"


# Sign body using the private key and encode with base64

__auth_signature=$(echo -n "${__auth_body}" | \
        openssl dgst -sha512 -sign "${__tmp_keyfile}" | \
        openssl base64 | \
        tr -d " \t\n\r")

rm "${__tmp_keyfile}"


# Send and parse request for a temporary authentication token

__auth_status=$(curl -s -X POST "https://api.transip.nl/v6/auth" \
        -H "Content-Type: application/json" \
        -H "Signature: ${__auth_signature}" \
        -d "${__auth_body}" \
        -w "%{http_code}\n" \
        -o "${DATFILE}" 2>"${ERRFILE}")


# Logging for error and debug

if [ $? -ne 0 ]; then
        write_log 14 "Curl failed: $(cat "${ERRFILE}")"
        return 1
fi

if [ -z ${__auth_status} ] || [ ${__auth_status} -ne 201 ]; then
        write_log 14 "TransIP authentication (status ${__auth_status}) failed: $(cat ${DATFILE})"
        return 1
fi

write_log 7 "TransIP authentication successful"


## Extract token from the response

__auth_token=$(cat ${DATFILE} | sed 's/^.*"token" *: *"\([^"]*\)".*$/\1/')


# Create request body for update

json_init
json_add_object "dnsEntry"
json_add_string "name" "${param_enc}"
json_add_string "type" "$([ $use_ipv6 -ne 0 ] && echo -n AAAA || echo -n A)"
json_add_int "expire" "${param_opt}"
json_add_string "content" "${__IP}"
json_close_object
__update_body="$(json_dump)"


# Send update request

__update_status=$(curl -s -X PATCH "https://api.transip.nl/v6/domains/${domain}/dns" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${__auth_token}" \
        -d "${__update_body}" \
        -w "%{http_code}\n" \
        -o "${DATFILE}" 2>"${ERRFILE}")


# Logging for error and debug

if [ $? -ne 0 ]; then
        write_log 14 "Curl failed: $(cat "${ERRFILE}")"
        return 1
fi

if [ -z ${__update_status} ] || [ ${__update_status} -ne 204 ]; then
        write_log 14 "TransIP DNS update (status ${__update_status}) failed: $(cat ${DATFILE})"
        return 1
fi

write_log 7 "TransIP DNS update successful"
return 0
