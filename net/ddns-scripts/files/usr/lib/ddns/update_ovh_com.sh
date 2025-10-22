# Script for sending user defined updates using the OVH Dynhost API
# 2025 David Andreoletti <david at andreoletti dot net>

# Options passed from /etc/config/ddns:
# Domain - the domain name managed by OVH (e.g. example.com)
# Username - the dynhost username of the domain (e.g. myrouter)
# Password -  the dynhost password of the domain

. /usr/share/libubox/jshn.sh

# base64 encoding
http_basic_encoding() {
	local user="$1"
	local password="$2"
	printf "${user}:${password}" | openssl base64 -in /dev/stdin
}

[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing domain name as 'Domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing username as 'Username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing password as 'Password'"

__STATUS=$(curl -Ss -X GET "https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=${domain}&myip=${__IP}" \
	-H "Authorization: Basic $(http_basic_encoding "$username" "$password")" \
	-w "%{response_code}\n" -o $DATFILE 2>$ERRFILE)

if [ $? -ne 0 ]; then
	write_log 14 "Curl failed: $(cat $ERRFILE)"
	return 1
elif [ -z $__STATUS ] || [ $__STATUS != 200 ]; then
	write_log 14 "Curl failed: $__STATUS \novh.com answered: $(cat $DATFILE)"
	return 1
fi
