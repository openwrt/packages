#!/bin/sh

# Check inputs
[ -z "$username" ] && write_log 14 "Configuration error! [User name] cannot be empty"
[ -z "$password" ] && write_log 14 "Configuration error! [Password] cannot be empty"

# Check external tools
[ -n "$CURL_SSL" ] || write_log 13 "Dnspod communication require cURL with SSL support. Please install"
[ -n "$CURL_PROXY" ] || write_log 13 "cURL: libcurl compiled without Proxy support"

# Declare variables
#local __URLBASE __HOST __DOMAIN __TYPE __CMDBASE __POST __POST1 __RECIP __RECID __TTL
__URLBASE="https://dnsapi.cn"

# Get host and domain from $domain
[ "${domain:0:2}" = "@." ] && domain="${domain/./}"      # host
[ "$domain" = "${domain/@/}" ] && domain="${domain/./@}" # host with no sperator
__HOST="${domain%%@*}"
__DOMAIN="${domain#*@}"
[ -z "$__HOST" -o "$__HOST" = "$__DOMAIN" ] && __HOST=@

# Set record type
[ $use_ipv6 = 0 ] && __TYPE=A || __TYPE=AAAA

# Build base command
build_command() {
	__CMDBASE="$CURL -Ss"
	# bind host/IP
	if [ -n "$bind_network" ]; then
		local __DEVICE
		network_get_device __DEVICE $bind_network || write_log 13 "Can not detect local device using 'network_get_device $bind_network' - Error: '$?'"
		write_log 7 "Force communication via device '$__DEVICE'"
		__CMDBASE="$__CMDBASE --interface $__DEVICE"
	fi
	# Force IP version
	if [ $force_ipversion = 1 ]; then
		[ $use_ipv6 = 0 ] && __CMDBASE="$__CMDBASE -4" || __CMDBASE="$__CMDBASE -6"
	fi
	# Set CA
	if [ $use_https = 1 ]; then
		if [ "$cacert" = IGNORE ]; then
			__CMDBASE="$__CMDBASE --insecure"
		elif [ -f "$cacert" ]; then
			__CMDBASE="$__CMDBASE --cacert $cacert"
		elif [ -d "$cacert" ]; then
			__CMDBASE="$__CMDBASE --capath $cacert"
		elif [ -n "$cacert" ]; then
			write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
		fi
	fi
	# Set if no proxy (might be an error with .wgetrc or env)
	[ -z "$proxy" ] && __CMDBASE="$__CMDBASE --noproxy '*'"
	__CMDBASE="$__CMDBASE -d"
}

# Dnspod API
dnspod_transfer() {
	__CNT=0
	case "$1" in
	0) __A="$__CMDBASE '$__POST' $__URLBASE/Record.List" ;;
	1) __A="$__CMDBASE '$__POST1' $__URLBASE/Record.Create" ;;
	2) __A="$__CMDBASE '$__POST1&record_id=$__RECID&ttl=$__TTL' $__URLBASE/Record.Modify" ;;
	esac

	write_log 7 "#> $__A"
	while ! __TMP=$(eval $__A 2>&1); do
		write_log 3 "[$__TMP]"
		if [ $VERBOSE -gt 1 ]; then
			write_log 4 "Transfer failed - detailed mode: $VERBOSE - Do not try again after an error"
			return 1
		fi
		__CNT=$(($__CNT + 1))
		[ $retry_max_count -gt 0 -a $__CNT -gt $retry_max_count ] && write_log 14 "Transfer failed after $retry_max_count retries"
		write_log 4 "Transfer failed - $__CNT Try again in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP
		PID_SLEEP=0
	done
	__ERR=$(jsonfilter -s "$__TMP" -e "@.status.code")
	[ $__ERR = 1 ] && return 0
	[ $__ERR = 10 ] && [ $1 = 0 ] && return 0
	__TMP=$(jsonfilter -s "$__TMP" -e "@.status.message")
	local A="$(date +%H%M%S) ERROR : [$__TMP] - Terminate process"
	logger -p user.err -t ddns-scripts[$$] $SECTION_ID: ${A:15}
	printf "%s\n" " $A" >>$LOGFILE
	exit 1
}

# Add record
add_domain() {
	dnspod_transfer 1
	printf "%s\n" " $(date +%H%M%S)       : Record add successfully: [$([ "$__HOST" = @ ] || echo $__HOST.)$__DOMAIN],[IP:$__IP]" >>$LOGFILE
	return 0
}

# Modify record
update_domain() {
	dnspod_transfer 2
	printf "%s\n" " $(date +%H%M%S)       : Record modified successfully: [$([ "$__HOST" = @ ] || echo $__HOST.)$__DOMAIN],[IP:$__IP],[TTL:$__TTL]" >>$LOGFILE
	return 0
}

# Get DNS record
describe_domain() {
	ret=0
	__POST="login_token=$username,$password&format=json&domain=$__DOMAIN&sub_domain=$__HOST"
	__POST1="$__POST&value=$__IP&record_type=$__TYPE&record_line_id=0"
	dnspod_transfer 0
	__TMP=$(jsonfilter -s "$__TMP" -e "@.records[@.type='$__TYPE' && @.line_id='0']")
	if [ -z "$__TMP" ]; then
		printf "%s\n" " $(date +%H%M%S)       : Record not exist: [$([ "$__HOST" = @ ] || echo $__HOST.)$__DOMAIN]" >>$LOGFILE
		ret=1
	else
		__RECIP=$(jsonfilter -s "$__TMP" -e "@.value")
		if [ "$__RECIP" != "$__IP" ]; then
			__RECID=$(jsonfilter -s "$__TMP" -e "@.id")
			__TTL=$(jsonfilter -s "$__TMP" -e "@.ttl")
			printf "%s\n" " $(date +%H%M%S)       : Record needs to be updated: [Record IP:$__RECIP] [Local IP:$__IP]" >>$LOGFILE
			ret=2
		fi
	fi
}

build_command
describe_domain
if [ $ret = 1 ]; then
	sleep 3
	add_domain
elif [ $ret = 2 ]; then
	sleep 3
	update_domain
else
	printf "%s\n" " $(date +%H%M%S)       : Record needs not update: [Record IP:$__RECIP] [Local IP:$__IP]" >>$LOGFILE
fi

return 0
