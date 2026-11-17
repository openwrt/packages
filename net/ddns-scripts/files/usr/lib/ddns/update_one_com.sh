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

. /usr/share/libubox/jshn.sh

write_log 0 "one.com ddns script started"

local __SUBDOMAIN __MAINDOMAIN __LOGINURL __RECORDID
local __TTL=3600

COOKIEJAR=$(mktemp /tmp/one_com_cookiejar.XXXXXX) || exit 1

__SUBDOMAIN=$(echo $domain | sed -e 's/[^\.]*\.[^\.]*$//' -e 's/\.$//' )
__MAINDOMAIN=$(echo $domain | sed -e "s/${__SUBDOMAIN}\.//" )


# LOGGING IN
# GET LOGIN POST URL FROM FORM
__LOGINURL=$( $CURL \
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	"https://www.one.com/admin/" \
	| grep 'Login-form login autofill' \
	| sed -e 's/.*action="//' -e 's/".*//' -e 's/\&amp;/\&/g' \
)

# POST LOGIN DATA
$CURL \
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	"${__LOGINURL}" \
	-H "Content-Type: application/x-www-form-urlencoded" \
	-X POST \
	-d "username=${username}&password=${password}&credentialId=" \
	| grep "Invalid username or password." > $DATFILE

if [ "$?" == "0" ] ; then
	write_log 14 "Invalid credentials"
	return 1
fi


# SETTING DOMAIN
$CURL -RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	"https://www.one.com/admin/select-admin-domain.do?domain=${__MAINDOMAIN}" \
	| grep "<meta name=\"one.com:active-domain\" content=\"${__MAINDOMAIN}\"/>" > $DATFILE

if [ "$?" != "0" ] ; then
	write_log 14 "Failed to select domain '${__MAINDOMAIN}'"
	return 1
fi


# GETTING RECORD ID
records=$( $CURL \
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	"https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records"
)

json_load "$records"

if json_is_a "result" "object" && \
	json_select "result" && \
	json_is_a "data" "array"
then
	json_select "data"
	i=1
	while json_is_a ${i} "object" ; do
		json_select "${i}"
		json_select "attributes"
		json_get_var "prefix" "prefix"
		json_close_object
		if [ "$prefix" == "$__SUBDOMAIN" ] ; then
			json_get_var "__RECORDID" "id"
			write_log 0 "Found record id : ${__RECORDID}"
			break
		fi
		json_close_object
		i=$(($i + 1))
	done
fi


if [ "${__RECORDID}" == "" ] ; then
	write_log 14 "domain record not found"
	return 1
fi


# CREATING PATCH DATA
json_init
json_add_string "type" "dns_service_records"
json_add_string "id" "${__RECORDID}"
json_add_object "attributes"
json_add_string "type" "A"
json_add_string "prefix" "${__SUBDOMAIN}"
json_add_string "content" "${__IP}"
json_add_int "ttl" ${__TTL}
patchdata=$(json_dump)


# SENDING PATCH
$CURL \
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	-X PATCH \
	-d "$patchdata" \
	-H "Content-Type: application/json" \
	"https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records/${__RECORDID}" \
	| grep "priority" > $DATFILE

if [ "$?" != "0" ] ; then
	write_log 14 "one.com gave an unexpected response"
	return 1
fi

rm $COOKIEJAR
write_log 0 "one.com ddns script finished without errors"

return 0
