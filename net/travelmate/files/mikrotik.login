#!/bin/sh
# This script will login to Mikrotik captive portals
# Arguments:
#    username - user name for login
#    password - password for login

set -eu
username=$1
password=$2
domain=$(curl -I -s -X GET connectivity-check.ubuntu.com | grep Location | grep -o 'http://[^/]*')

# Login via username/password
echo "Logging in via username/password."
response=$(curl -s -X POST -d "username=${username}&password=${password}&dst=&popup=true" ${domain}/login)
