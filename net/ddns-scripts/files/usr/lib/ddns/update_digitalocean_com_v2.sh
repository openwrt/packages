# Script for sending user defined updates using the DigitalOcean API
# 2015 Artem Yakimenko <code at temik dot me>
# 2021 George Giannou <giannoug at gmail dot com>

# Options passed from /etc/config/ddns:
# Domain - the domain name managed by DigitalOcean (e.g. example.com)
# Username - the hostname of the domain (e.g. myrouter)
# Password - DigitalOcean personal access token (API key)
# Optional Parameter - the API domain record ID of the hostname (e.g. 21694203)

# Use the following command to find your API domain record ID (replace TOKEN and DOMAIN with your own):
# curl -X GET -H 'Content-Type: application/json' \
# 	-H "Authorization: Bearer TOKEN" \
# 	"https://api.digitalocean.com/v2/domains/DOMAIN/records"

. /usr/share/libubox/jshn.sh

[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing domain name as 'Domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing hostname as 'Username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing personal access token as 'Password'"
[ -z "$param_opt" ] && write_log 14 "Service section not configured correctly! Missing API domain record ID as 'Optional Parameter'"

# Construct JSON payload
json_init
json_add_string name "$username"
json_add_string data "$__IP"

__STATUS=$(curl -Ss -X PUT "https://api.digitalocean.com/v2/domains/${domain}/records/${param_opt}" \
	-H "Authorization: Bearer ${password}" \
	-H "Content-Type: application/json" \
	-d "$(json_dump)" \
	-w "%{http_code}\n" -o $DATFILE 2>$ERRFILE)

if [ $? -ne 0 ]; then
	write_log 14 "Curl failed: $(cat $ERRFILE)"
	return 1
elif [ -z $__STATUS ] || [ $__STATUS != 200 ]; then
	write_log 14 "Curl failed: $__STATUS \ndigitalocean.com answered: $(cat $DATFILE)"
	return 1
fi
