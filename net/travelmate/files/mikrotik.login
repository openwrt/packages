#!/bin/sh
# This script will login to Mikrotik captive portals
# Arguments:
#    username - user name for login
#    password - password for login

# check arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments."
    echo "usage: mikrotik.login <username> <password>"
    exit 1
fi

cmd="$(command -v curl)"
# curl check
if [ ! -x "${cmd}" ]
then
	echo "Error: this script depends on curl. Please install this first."
    exit 2
fi

username=$1
password=$2
login_success="You are logged in"

# Get login domain from redirection information
domain=$(curl -I -s -X GET connectivity-check.ubuntu.com | grep Location | grep -o 'http://[^/]*')
if [ "${domain}" = "" ] 
then
    echo "Error getting captive portal domain. Are you already logged in?"
    exit 3
fi

# Login via username/password
response=$(${cmd} -s -X POST -d "username=${username}&password=${password}&dst=&popup=true" ${domain}/login)
if [ -n "$(printf "%s" "${response}" | grep "${login_success}")" ]
then
    echo "Login successful."
	exit 0
else
    echo "Error: login failed."
	exit 4
fi