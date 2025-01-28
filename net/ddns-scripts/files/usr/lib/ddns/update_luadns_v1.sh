#!/bin/sh
#
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.2023 Jihoon Han <rapid_renard@renard.ga>
#
#.based on Christian Schoenebeck's update_cloudflare_com_v4.sh
#.and on Neilpang's acme.sh found at https://github.com/acmesh-official/acme.sh
#
# Script for sending DDNS updates using the LuaDNS API
# See: https://luadns.com/api
#
# using following options from /etc/config/ddns
# option username - "Emaii" as registered on LuaDNS
# option password - "API Key" as generated at https://api.luadns.com/api_keys
# option domain   - The domain to update (e.g. my.example.com)
#

# check parameters
[ -z "$CURL" ] && [ -z "$CURL_SSL" ] && write_log 14 "LuaDNS API require cURL with SSL support. Please install"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing e-mail as 'Username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing personal API key as 'Password'"
[ $use_https -eq 0 ] && use_https=1	# force HTTPS

# used variables
local __HOST __DOMAIN __TYPE __URLBASE __PRGBASE __RUNPROG __DATA __IPV6 __ZONEID __RECID
local __URLBASE="https://api.luadns.com/v1"
local __TTL=300

# set record type
[ $use_ipv6 -eq 0 ] && __TYPE="A" || __TYPE="AAAA"

# transfer function to use for LuaDNS
# all needed variables are set global here
# so we can use them directly
luadns_transfer() {
	local __CNT=0
	local __STATUS __ERR
	while : ; do
		write_log 7 "#> $__RUNPROG"
		__STATUS=$(eval "$__RUNPROG")
		__ERR=$?			# save communication error
		[ $__ERR -eq 0 ] && break	# no error break while

		write_log 3 "cURL Error: '$__ERR'"
		write_log 7 "$(cat $ERRFILE)"		# report error

		[ $VERBOSE_MODE -gt 1 ] && {
			# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Transfer failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			break
		}

		__CNT=$(( $__CNT + 1 ))	# increment error counter
		# if error count > retry_max_count leave here
		[ $retry_max_count -gt 0 -a $__CNT -gt $retry_max_count ] && \
			write_log 14 "Transfer failed after $retry_max_count retries"

		write_log 4 "Transfer failed - retry $__CNT/$retry_max_count in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP	# enable trap-handler
		PID_SLEEP=0
	done

	# handle HTTP error
	[ $__STATUS -ne 200 ] && {
		write_log 4 "LuaDNS reported an error:"
		write_log 7 "$(cat $DATFILE)"
		return 1
	}
	return 0
}

# Build base command to use
__PRGBASE="$CURL -RsS -w '%{http_code}' -o $DATFILE --stderr $ERRFILE"
# force network/interface-device to use for communication
if [ -n "$bind_network" ]; then
	local __DEVICE
	network_get_device __DEVICE $bind_network || \
		write_log 13 "Can not detect local device using 'network_get_device $bind_network' - Error: '$?'"
	write_log 7 "Force communication via device '$__DEVICE'"
	__PRGBASE="$__PRGBASE --interface $__DEVICE"
fi
# force ip version to use
if [ $force_ipversion -eq 1 ]; then
	[ $use_ipv6 -eq 0 ] && __PRGBASE="$__PRGBASE -4" || __PRGBASE="$__PRGBASE -6"	# force IPv4/IPv6
fi
# set certificate parameters
if [ "$cacert" = "IGNORE" ]; then	# idea from Ticket #15327 to ignore server cert
	__PRGBASE="$__PRGBASE --insecure"	# but not empty better to use "IGNORE"
elif [ -f "$cacert" ]; then
	__PRGBASE="$__PRGBASE --cacert $cacert"
elif [ -d "$cacert" ]; then
	__PRGBASE="$__PRGBASE --capath $cacert"
elif [ -n "$cacert" ]; then		# it's not a file and not a directory but given
	write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
fi
# disable proxy if not set (there might be .wgetrc or .curlrc or wrong environment set)
# or check if libcurl compiled with proxy support
if [ -z "$proxy" ]; then
	__PRGBASE="$__PRGBASE --noproxy '*'"
elif [ -z "$CURL_PROXY" ]; then
	# if libcurl has no proxy support and proxy should be used then force ERROR
	write_log 13 "cURL: libcurl compiled without Proxy support"
fi
# set headers
__PRGBASE="$__PRGBASE --user '$username:$password' "
__PRGBASE="$__PRGBASE --header 'Accept: application/json' "

if [ -n "$zone_id" ]; then
	__ZONEID="$zone_id"
else
	# read zone id for registered domain.TLD
	__RUNPROG="$__PRGBASE --request GET '$__URLBASE/zones'"
	luadns_transfer || return 1
	# extract zone id
	i=1
	while : ; do
		h=$(printf "%s" "$domain" | cut -d . -f $i-100 -s)
		[ -z "$h" ] && {
			write_log 4 "Could not detect 'Zone ID' for the domain provided: '$domain'"
			return 127
		}

		__ZONEID=$(grep -o -e "\"id\":[^,]*,\"name\":\"$h\"" $DATFILE | cut -d : -f 2 | cut -d , -f 1)
		[ -n "$__ZONEID" ] && {
			# LuaDNS API needs:
			# __DOMAIN = the base domain i.e. example.com
			# __HOST   = the FQDN of record to modify
			# i.e. example.com for the "domain record" or host.sub.example.com for "host record"
			__HOST="$domain"
			__DOMAIN="$h"
			write_log 7 "Domain : '$__DOMAIN'"
			write_log 7 "Zone ID : '$__ZONEID'"
			write_log 7 "Host : '$__HOST'"
			break
		}
		i=$(expr "$i" + 1)
	done
fi

# read record id for A or AAAA record of host.domain.TLD
__RUNPROG="$__PRGBASE --request GET '$__URLBASE/zones/$__ZONEID/records'"
luadns_transfer || return 1
# extract record id
__RECID=$(grep -o -e "\"id\":[^,]*,\"name\":\"$__HOST.\",\"type\":\"$__TYPE\"" $DATFILE | head -n 1 | cut -d : -f 2 | cut -d , -f 1)
[ -z "$__RECID" ] && {
	write_log 4 "Could not detect 'Record ID' for the domain provided: '$__HOST'"
	return 127
}
write_log 7 "Record ID : '$__RECID'"

# extract current stored IP
__DATA=$(grep -o -e "\"id\":$__RECID,\"name\":\"$__HOST.\",\"type\":\"$__TYPE\",\"content\":[^,]*" $DATFILE | grep -o '[^"]*' | tail -n 1)

# check data
[ $use_ipv6 -eq 0 ] \
	&& __DATA=$(printf "%s" "$__DATA" | grep -m 1 -o "$IPV4_REGEX") \
	|| __DATA=$(printf "%s" "$__DATA" | grep -m 1 -o "$IPV6_REGEX")

# we got data so verify
[ -n "$__DATA" ] && {
	# expand IPv6 for compare
	if [ $use_ipv6 -eq 1 ]; then
		expand_ipv6 $__IP __IPV6
		expand_ipv6 $__DATA __DATA
		[ "$__DATA" = "$__IPV6" ] && {		# IPv6 no update needed
			write_log 7 "IPv6 at LuaDNS already up to date"
			return 0
		}
	else
		[ "$__DATA" = "$__IP" ] && {		# IPv4 no update needed
			write_log 7 "IPv4 at LuaDNS already up to date"
			return 0
		}
	fi
}

# update is needed
# let's build data to send

# use file to work around " needed for json
cat > $DATFILE << EOF
{"name":"$__HOST.","type":"$__TYPE","content":"$__IP","ttl":$__TTL}
EOF

# let's complete transfer command
__RUNPROG="$__PRGBASE --request PUT --data @$DATFILE '$__URLBASE/zones/$__ZONEID/records/$__RECID'"
luadns_transfer || return 1

return 0
