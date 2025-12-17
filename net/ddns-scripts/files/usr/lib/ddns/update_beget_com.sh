#!/bin/sh
# following script was referenced: https://github.com/openwrt/packages/blob/master/net/ddns-scripts/files/usr/lib/ddns/update_gandi_net.sh

. /usr/share/libubox/jshn.sh

# Beget API description: https://beget.com/en/kb/api/dns-administration-functions#changerecords
__CHANGE_ENDPOINT_API="https://api.beget.com/api/dns/changeRecords"

[ -z "$domain" ]   && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

[ "$use_ipv6" -ne 0 ] && __RRTYPE="AAAA" || __RRTYPE="A"

json_init

json_add_string "fqdn" "$domain"

json_add_object "records"
json_add_array "$__RRTYPE"
json_add_object ""
json_add_string "value" "$__IP"
json_close_object
json_close_array
json_close_object

json_payload=$(json_dump)

__STATUS=$(curl -X POST "$__CHANGE_ENDPOINT_API" \
		-d "input_format=json" \
		-d "output_format=json" \
		--data-urlencode "login=$username" \
		--data-urlencode "passwd=$password" \
		--data-urlencode "input_data=$json_payload" \
		-w "%{http_code}\n" \
		-o $DATFILE 2>$ERRFILE)

__ERRNO=$?
if [[ $__ERRNO -ne 0 ]]; then
	write_log 14 "Curl failed with $__ERRNO: $(cat $ERRFILE)"
	return 1
elif [[ -z $__STATUS || $__STATUS != 200 ]]; then
	write_log 14 "Beget reponded with non-200 status \"$__STATUS\": $(cat $ERRFILE)"
	return 1
fi

json_load "$DATFILE"
json_getvar beget_resp_status "status"

if [[ -z $beget_resp_status || $beget_resp_status != "success" ]]; then
	write_log 14 "Beget response status was \"$beget_resp_status\" != \"success\". $(cat $DATFILE)"
	return 1
fi

write_log 7 "Success. Beget API curl response: $(cat $DATFILE)"

return 0
