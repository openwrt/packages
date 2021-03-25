#!/bin/sh
# This script will login to Mikrotik captive portals
# Arguments:
#    username - user name for login
#    password - password for login

username="${1}"
password="${2}"
login_success="You are logged in"
cmd="$(command -v curl)"

if [ "$#" -ne 2 ]
then
	exit 1
fi

if [ ! -x "${cmd}" ]
then
	exit 2
fi

# Get login domain from redirection information
domain="$("${cmd}" -I -s -X GET connectivity-check.ubuntu.com | grep Location | grep -o 'http://[^/]*')"
if [ "${domain}" = "" ]
then
	exit 3
fi

# Login via username/password
response="$("${cmd}" -s -X POST -d "username=${username}&password=${password}&dst=&popup=true" "${domain}"/login)"
if [ -n "$(printf "%s" "${response}" | grep "${login_success}")" ]
then
	exit 0
else
	exit 4
fi
