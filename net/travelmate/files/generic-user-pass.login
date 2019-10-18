#!/bin/sh

cmd="$(command -v curl)"
url="http://example.com/"
success_string="Thank you!"

if [ ! -x "${cmd}" ]
then
	exit 1
fi

response="$("${cmd}" $url -d "username=${1}&password=${2}" \
	--header "Content-Type:application/x-www-form-urlencoded" -s)"

if [ -n "$(printf "%s" "${response}" | grep "${success_string}")" ]
then
	exit 0
else
	exit 2
fi
