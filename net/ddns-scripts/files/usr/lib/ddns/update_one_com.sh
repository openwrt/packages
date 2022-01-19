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

COOKIEJAR=$(mktemp /tmp/one_com_cookiejar.XXXXXX) || exit 1

__SUBDOMAIN=$(echo $domain | sed -e 's/[^\.]*\.[^\.]*$//' -e 's/\.$//' )
__MAINDOMAIN=$(echo $domain | sed -e "s/${__SUBDOMAIN}\.//" )


# LOGGING IN
# GET LOGIN POST URL FROM FORM
__LOGINURL=$( $CURL \
<<<<<<< HEAD
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	"https://www.one.com/admin/" \
	| grep 'Login-form login autofill' \
	| sed -e 's/.*action="//' -e 's/".*//' -e 's/\&amp;/\&/g' \
=======
  -RsSL \
  --stderr $ERRFILE \
  -c $COOKIEJAR \
  "https://www.one.com/admin/" \
  | grep 'Login-form login autofill' \
  | sed -e 's/.*action="//' -e 's/".*//' -e 's/\&amp;/\&/g' \
>>>>>>> 0fb414e77cd0619334c29bff7f3fc0869c1fdc43
)

# POST LOGIN DATA
$CURL \
<<<<<<< HEAD
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
=======
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
>>>>>>> 0fb414e77cd0619334c29bff7f3fc0869c1fdc43
fi


# SETTING DOMAIN
$CURL -RsSL \
<<<<<<< HEAD
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	"https://www.one.com/admin/select-admin-domain.do?domain=${__MAINDOMAIN}" \
	| grep "<meta name=\"one.com:active-domain\" content=\"${__MAINDOMAIN}\"/>" > $DATFILE

if [ "$?" != "0" ] ; then
	write_log 14 "Failed to select domain '${__MAINDOMAIN}'"
	return 1
=======
  --stderr $ERRFILE \
  -c $COOKIEJAR \
  -b $COOKIEJAR \
  "https://www.one.com/admin/select-admin-domain.do?domain=${__MAINDOMAIN}" \
  | grep "<meta name=\"one.com:active-domain\" content=\"${__MAINDOMAIN}\"/>" > $DATFILE

if [ "$?" != "0" ] ; then
  write_log 14 "Failed to select domain '${__MAINDOMAIN}'"
  return 1
>>>>>>> 0fb414e77cd0619334c29bff7f3fc0869c1fdc43
fi


# GETTING RECORD ID
__RECORDID=$( $CURL \
<<<<<<< HEAD
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	"https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records" \
	| sed 's/,/\n/g' \
	| while read line ; do

		if ! [ "$(echo $line | grep '\"id\":\"' )" == "" ] ; then
			id=$(echo $line | sed -e 's/\"id\":\"//' -e 's/"//' )
		fi
		if ! [ "$(echo $line | grep "\"prefix\":\"${__SUBDOMAIN}\"" )" == "" ] ; then
			if [ "$id" == "" ] ; then
				echo "0"
			fi
			write_log 0 "record id: $id"
			echo $id
			break
		fi
	done \
)

if [ "${__RECORDID}" == "" ] ; then
	write_log 0 "domain record not found"
	return 1
fi

if [ "${__RECORDID}" == "0" ] ; then
	write_log 14 "no id for domain record found"
	return 1
=======
  -RsSL \
  --stderr $ERRFILE \
  -c $COOKIEJAR \
  -b $COOKIEJAR \
  "https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records" \
  | sed 's/,/\n/g' \
  | while read line ; do

    if ! [ "$(echo $line | grep '\"id\":\"' )" == "" ] ; then
      id=$(echo $line | sed -e 's/\"id\":\"//' -e 's/"//' )
    fi
    if ! [ "$(echo $line | grep "\"prefix\":\"${__SUBDOMAIN}\"" )" == "" ] ; then
      if [ "$id" == "" ] ; then
        echo "0"
      fi
      write_log 0 "record id: $id"
      echo $id
      break
    fi
  done \
)

if [ "${__RECORDID}" == "" ] ; then
  write_log 0 "domain record not found"
  return 1
fi

if [ "${__RECORDID}" == "0" ] ; then
  write_log 14 "no id for domain record found"
  return 1
>>>>>>> 0fb414e77cd0619334c29bff7f3fc0869c1fdc43
fi



# SENDING PATCH
$CURL \
<<<<<<< HEAD
	-RsSL \
	--stderr $ERRFILE \
	-c $COOKIEJAR \
	-b $COOKIEJAR \
	-X PATCH \
	-d "{\"type\":\"dns_service_records\",\"id\":\"${__RECORDID}\",\"attributes\":{\"type\":\"A\",\"prefix\":\"${__SUBDOMAIN}\",\"content\":\"${__IP}\",\"ttl\":${__TTL}}}" \
	-H "Content-Type: application/json" \
	"https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records/${__RECORDID}" \
	| grep "priority" > $DATFILE

if [ "$?" != "0" ] ; then
	write_log 14 "one.com gave an unexpected response"
	return 1
=======
  -RsSL \
  --stderr $ERRFILE \
  -c $COOKIEJAR \
  -b $COOKIEJAR \
  -X PATCH \
  -d "{\"type\":\"dns_service_records\",\"id\":\"${__RECORDID}\",\"attributes\":{\"type\":\"A\",\"prefix\":\"${__SUBDOMAIN}\",\"content\":\"${__IP}\",\"ttl\":${__TTL}}}" \
  -H "Content-Type: application/json" \
  "https://www.one.com/admin/api/domains/${__MAINDOMAIN}/dns/custom_records/${__RECORDID}" \
  | grep "priority" > $DATFILE

if [ "$?" != "0" ] ; then
  write_log 14 "one.com gave an unexpected response"
  return 1
>>>>>>> 0fb414e77cd0619334c29bff7f3fc0869c1fdc43
fi

rm $COOKIEJAR
write_log 0 "one.com ddns script finished without errors"

return 0
