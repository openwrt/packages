#!/bin/sh

cmd="$(command -v curl)"
url="http://example.com/"
success_string="Thank you!"

if [ ! -x "${cmd}" ]
then
	exit 1
fi


response="$("${cmd}" $url -d "password=$2&pwd=$2&username=$1" \
	--header "Content-Type:application/x-www-form-urlencoded" -s)"

if echo "${response}" | grep -q "${success_string}";
then
	exit 0
else
	exit 2
fi
