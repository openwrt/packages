#!/bin/sh
# /usr/lib/ddns/dynamic_dns_functions.sh
#
# Original written by Eric Paul Bishop, January 2008
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
# (Loosely) based on the script on the one posted by exobyte in the forums here:
# http://forum.openwrt.org/viewtopic.php?id=14040
#
# extended and partial rewritten in August 2014 
# by Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
# to support:
# - IPv6 DDNS services
# - setting DNS Server to retrieve current IP including TCP transport
# - Proxy Server to send out updates or retrieving WEB based IP detection
# - force_interval=0 to run once (usefull for cron jobs etc.)
# - the usage of BIND's host instead of BusyBox's nslookup if installed (DNS via TCP)
# - extended Verbose Mode and log file support for better error detection 
#
# function __timeout
# copied from http://www.ict.griffith.edu.au/anthony/software/timeout.sh
# @author Anthony Thyssen  6 April 2011
#
# variables in small chars are read from /etc/config/ddns
# variables in big chars are defined inside these scripts as global vars
# variables in big chars beginning with "__" are local defined inside functions only
#set -vx  	#script debugger

. /lib/functions.sh
. /lib/functions/network.sh

# GLOBAL VARIABLES #
SECTION_ID=""		# hold config's section name
VERBOSE_MODE=1		# default mode is log to console, but easily changed with parameter
LUCI_HELPER=""		# set by dynamic_dns_lucihelper.sh, if filled supress all error logging

PIDFILE=""		# pid file
UPDFILE=""		# store UPTIME of last update

# directory to store run information to. 
RUNDIR=$(uci -q get ddns.global.run_dir) || RUNDIR="/var/run/ddns"
# NEW # directory to store log files
LOGDIR=$(uci -q get ddns.global.log_dir) || LOGDIR="/var/log/ddns"
LOGFILE=""		# NEW # logfile can be enabled as new option
# number of lines to before rotate logfile
LOGLINES=$(uci -q get ddns.global.log_lines) || LOGLINES=250

CHECK_SECONDS=0		# calculated seconds out of given
FORCE_SECONDS=0		# interval and unit
RETRY_SECONDS=0		# in configuration

OLD_PID=0		# Holds the PID of already running process for the same config section

LAST_TIME=0		# holds the uptime of last successful update
CURR_TIME=0		# holds the current uptime
NEXT_TIME=0		# calculated time for next FORCED update
EPOCH_TIME=0		# seconds since 1.1.1970 00:00:00

REGISTERED_IP=""	# holds the IP read from DNS
LOCAL_IP=""		# holds the local IP read from the box

ERR_LAST=0		# used to save $? return code of program and function calls
ERR_LOCAL_IP=0		# error counter on getting local ip
ERR_REG_IP=0		# error counter on getting DNS registered ip
ERR_SEND=0		# error counter on sending update to DNS provider
ERR_UPDATE=0		# error counter on different local and registered ip
ERR_VERIFY=0		# error counter verifying proxy- and dns-servers

# format to show date information in log and luci-app-ddns default ISO 8601 format
DATE_FORMAT=$(uci -q get ddns.global.date_format) || DATE_FORMAT="%F %R"
DATE_PROG="date +'$DATE_FORMAT'"

# regular expression to detect IPv4 / IPv6
# IPv4       0-9   1-3x "." 0-9  1-3x "." 0-9  1-3x "." 0-9  1-3x
IPV4_REGEX="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
# IPv6       ( ( 0-9a-f  1-4char ":") min 1x) ( ( 0-9a-f  1-4char   )optional) ( (":" 0-9a-f 1-4char  ) min 1x)
IPV6_REGEX="\(\([0-9A-Fa-f]\{1,4\}:\)\{1,\}\)\(\([0-9A-Fa-f]\{1,4\}\)\{0,1\}\)\(\(:[0-9A-Fa-f]\{1,4\}\)\{1,\}\)"

# loads all options for a given package and section
# also, sets all_option_variables to a list of the variable names
# $1 = ddns, $2 = SECTION_ID
load_all_config_options()
{
	local __PKGNAME="$1"
	local __SECTIONID="$2"
	local __VAR
	local __ALL_OPTION_VARIABLES=""

	# this callback loads all the variables in the __SECTIONID section when we do
	# config_load. We need to redefine the option_cb for different sections
	# so that the active one isn't still active after we're done with it.  For reference
	# the $1 variable is the name of the option and $2 is the name of the section
	config_cb()
	{
		if [ ."$2" = ."$__SECTIONID" ]; then
			option_cb()
			{
				__ALL_OPTION_VARIABLES="$__ALL_OPTION_VARIABLES $1"
			}
		else
			option_cb() { return 0; }
		fi
	}

	config_load "$__PKGNAME"
	
	# Given SECTION_ID not found so no data, so return 1
	[ -z "$__ALL_OPTION_VARIABLES" ] && return 1

	for __VAR in $__ALL_OPTION_VARIABLES
	do
		config_get "$__VAR" "$__SECTIONID" "$__VAR"
	done
	return 0
}

# starts updater script for all given sections or only for the one given
# $1 = interface (Optional: when given only scripts are started
# configured for that interface)
start_daemon_for_all_ddns_sections()
{
	local __EVENTIF="$1"
	local __SECTIONS=""
	local __SECTIONID=""
	local __IFACE=""

	config_cb()
	{
		# only look for section type "service", ignore everything else
		[ "$1" = "service" ] && __SECTIONS="$__SECTIONS $2"
	}
	config_load "ddns"

	for __SECTIONID in $__SECTIONS
	do
		config_get __IFACE "$__SECTIONID" interface "wan"
		[ -z "$__EVENTIF" -o "$__IFACE" = "$__EVENTIF" ] || continue
		/usr/lib/ddns/dynamic_dns_updater.sh $__SECTIONID 0 > /dev/null 2>&1 &
	done
}

verbose_echo()
{
	[ -n "$LUCI_HELPER" ] && return	# nothing to report when used by LuCI helper script
	[ $VERBOSE_MODE -gt 0 ] && echo -e " $*"
	if [ ${use_logfile:-0} -eq 1 -o $VERBOSE_MODE -gt 1 ]; then
		[ -d $LOGDIR ] || mkdir -p -m 755 $LOGDIR
		echo -e " $*" >> $LOGFILE
		# VERBOSE_MODE > 1 then NO loop so NO truncate log to $LOGLINES lines
		[ $VERBOSE_MODE -gt 1 ] || sed -i -e :a -e '$q;N;'$LOGLINES',$D;ba' $LOGFILE
	fi
	return
}

syslog_info(){
	[ $use_syslog -eq 1 ] && logger -p user.info -t ddns-scripts[$$] "$SECTION_ID: $*"
	return
}
syslog_notice(){
	[ $use_syslog -ge 1 -a $use_syslog -le 2 ] && logger -p user.notice -t ddns-scripts[$$] "$SECTION_ID: $*"
	return
}
syslog_warn(){
	[ $use_syslog -ge 1 -a $use_syslog -le 3 ] && logger -p user.warn -t ddns-scripts[$$] "$SECTION_ID: $*"
	return
}
syslog_err(){
	[ $use_syslog -ge 1 ] && logger -p user.err -t ddns-scripts[$$] "$SECTION_ID: $*"
	return
}

critical_error() {
	[ -n "$LUCI_HELPER" ] && return	# nothing to report when used by LuCI helper script
	verbose_echo "\n CRITICAL ERROR =: $* - EXITING\n"
	[ $VERBOSE_MODE -eq 0 ] && echo -e "\n$SECTION_ID: CRITICAL ERROR - $* - EXITING\n"
	logger -t ddns-scripts[$$] -p user.crit "$SECTION_ID: CRITICAL ERROR - $* - EXITING"
	exit 1		# critical error -> leave here
}

# replace all special chars to their %hex value
# used for USERNAME and PASSWORD in update_url
# unchanged: "-"(minus) "_"(underscore) "."(dot) "~"(tilde)
# to verify: "'"(single quote) '"'(double quote)	# because shell delimiter
#            "$"(Dollar)				# because used as variable output
# tested with the following string stored via Luci Application as password / username
# A B!"#AA$1BB%&'()*+,-./:;<=>?@[\]^_`{|}~	without problems at Dollar or quotes
__urlencode() {
	# $1	Name of Variable to store encoded string to
	# $2	string to encode
	local __STR __LEN __CHAR __OUT
	local __ENC=""
	local __POS=1

	__STR="$2"		# read string to encode
	__LEN=${#__STR}		# get string length

	while [ $__POS -le $__LEN ]; do
		# read one chat of the string
		__CHAR=$(expr substr "$__STR" $__POS 1)

		case "$__CHAR" in
		        [-_.~a-zA-Z0-9] )
				# standard char
				__OUT="${__CHAR}"
				;;
		        * )
				# special char get %hex code
		               __OUT=$(printf '%%%02x' "'$__CHAR" )
				;;
		esac
		__ENC="${__ENC}${__OUT}"	# append to encoded string
		__POS=$(( $__POS + 1 ))		# increment position
	done

	eval "$1='$__ENC'"	# transfer back to variable
	return 0
}

# extract url or script for given DDNS Provider from
# file /usr/lib/ddns/services for IPv4 or from
# file /usr/lib/ddns/services_ipv6 for IPv6
get_service_data() {
	# $1	Name of Variable to store url to
	# $2	Name of Variable to store script to
	local __LINE __FILE __NAME __URL __SERVICES __DATA
	local __SCRIPT=""
	local __OLD_IFS=$IFS
	local __NEWLINE_IFS='
' #__NEWLINE_IFS

	__FILE="/usr/lib/ddns/services"					# IPv4
	[ $use_ipv6 -ne 0 ] && __FILE="/usr/lib/ddns/services_ipv6"	# IPv6

	#remove any lines not containing data, and then make sure fields are enclosed in double quotes
	__SERVICES=$(cat $__FILE | grep "^[\t ]*[^#]" | \
		awk ' gsub("\x27", "\"") { if ($1~/^[^\"]*$/) $1="\""$1"\"" }; { if ( $NF~/^[^\"]*$/) $NF="\""$NF"\""  }; { print $0 }')

	IFS=$__NEWLINE_IFS
	for __LINE in $__SERVICES
	do
		#grep out proper parts of data and use echo to remove quotes
		__NAME=$(echo $__LINE | grep -o "^[\t ]*\"[^\"]*\"" | xargs -r -n1 echo)
		__DATA=$(echo $__LINE | grep -o "\"[^\"]*\"[\t ]*$" | xargs -r -n1 echo)

		if [ "$__NAME" = "$service_name" ]; then
			break			# found so leave for loop
		fi
	done
	IFS=$__OLD_IFS

	# check is URL or SCRIPT is given
	__URL=$(echo "$__DATA" | grep "^http:")
	[ -z "$__URL" ] && __SCRIPT="/usr/lib/ddns/$__DATA"
	
	eval "$1='$__URL'"
	eval "$2='$__SCRIPT'"
	return 0
}

get_seconds() {
	# $1	Name of Variable to store result in
	# $2	Number and
	# $3	Unit of time interval
	case "$3" in
		"days" )	eval "$1=$(( $2 * 86400 ))";;
		"hours" )	eval "$1=$(( $2 * 3600 ))";;
		"minutes" )	eval "$1=$(( $2 * 60 ))";;
		* )		eval "$1=$2";;
	esac
	return 0
}

__timeout() {
	# copied from http://www.ict.griffith.edu.au/anthony/software/timeout.sh
	# only did the folloing changes
	#	- commented out "#!/bin/bash" and usage section
	#	- replace exit by return for usage as function
	#	- some reformating
	#
	# timeout [-SIG] time [--] command args...
	#
	# Run the given command until completion, but kill it if it runs too long.
	# Specifically designed to exit immediatally (no sleep interval) and clean up
	# nicely without messages or leaving any extra processes when finished.
	#
	# Example use
	#    timeout 5 countdown
	#
	###
	#
	# Based on notes in my "Shell Script Hints", section "Command Timeout"
	#   http://www.ict.griffith.edu.au/~anthony/info/shell/script.hints
	#
	# This script uses a lot of tricks to terminate both the background command,
	# the timeout script, and even the sleep process.  It also includes trap
	# commands to prevent sub-shells reporting expected "Termination Errors".
	#
	# It took years of occasional trials, errors and testing to get a pure bash
	# timeout command working as well as this does.
	#
	###
	#
	# Anthony Thyssen     6 April 2011
	#
#	PROGNAME=$(type $0 | awk '{print $3}')	# search for executable on path
#	PROGDIR=$(dirname $PROGNAME)		# extract directory of program
#	PROGNAME=$(basename $PROGNAME)		# base name of program

	# output the script comments as docs
#	Usage() {
#		echo >&2 "$PROGNAME:" "$@"
#		sed >&2 -n '/^###/q; /^#/!q; s/^#//; s/^ //; 3s/^/Usage: /; 2,$ p' "$PROGDIR/$PROGNAME"
#		exit 10;
#	}

	SIG=-TERM

	while [  $# -gt 0 ]; do
		case "$1" in
			--)
				# forced end of user options
				shift;
				break ;;
#			-\?|--help|--doc*)
#				Usage ;;
			[0-9]*)
				TIMEOUT="$1" ;;
			-*)
				SIG="$1" ;;
			*)
				# unforced  end of user options
				break ;;
		esac
		shift	# next option
	done

	# run main command in backgrouds and get its pid
	"$@" &
	command_pid=$!

	# timeout sub-process abort countdown after ABORT seconds! also backgrounded
	sleep_pid=0
	(
		# cleanup sleep process
		trap 'kill -TERM $sleep_pid; return 1' 1 2 3 15
		# sleep timeout period in background
		sleep $TIMEOUT &
		sleep_pid=$!
		wait $sleep_pid
		# Abort the command
		kill $SIG $command_pid >/dev/null 2>&1
		return 1
	) &
	timeout_pid=$!

	# Wait for main command to finished or be timed out
	wait $command_pid
	status=$?

	# Clean up timeout sub-shell - if it is still running!
	kill $timeout_pid 2>/dev/null
	wait $timeout_pid 2>/dev/null

	# Uncomment to check if a LONG sleep still running (no sleep should be)
	# sleep 1
	# echo "-----------"
	# /bin/ps j  # uncomment to show if abort "sleep" is still sleeping

	return $status
}

__verify_host_port() {
	# $1	Host/IP to verify
	# $2	Port to verify
	local __HOST=$1
	local __PORT=$2
	local __TMP __IP __IPV4 __IPV6 __RUNPROG __ERRPROG __ERR
	# return codes
	# 1	system specific error
	# 2	nslookup error
	# 3	nc (netcat) error
	# 4	unmatched IP version

	__RUNPROG="nslookup $__HOST 2>/dev/null"
	__ERRPROG="nslookup $__HOST 2>&1"
	verbose_echo " resolver prog =: '$__RUNPROG'"
	__TMP=$(eval $__RUNPROG)	# test if nslookup runs without errors
	__ERR=$?
	# command error
	[ $__ERR -gt 0 ] && {
		verbose_echo "\n!!!!!!!!! ERROR =: BusyBox nslookup Error '$__ERR'\n$(eval $__ERRPROG)\n"
		syslog_err "DNS Resolver Error - BusyBox nslookup Error '$__ERR'"
		return 2
	} || {
		# we need to run twice because multi-line output needs to be directly piped to grep because
		# pipe returns return code of last prog in pipe but we need errors from nslookup command
		__IPV4=$(eval $__RUNPROG | sed -ne "3,\$ { s/^Address [0-9]*: \($IPV4_REGEX\).*$/\\1/p }")
		__IPV6=$(eval $__RUNPROG | sed -ne "3,\$ { s/^Address [0-9]*: \($IPv6_REGEX\).*$/\\1/p }")
	}

	# check IP version if forced
	if [ $force_ipversion -ne 0 ]; then
		__ERR=0
		[ $use_ipv6 -eq 0 -a -z "$__IPV4" ] && __ERR=4
		[ $use_ipv6 -eq 1 -a -z "$__IPV6" ] && __ERR=6
		[ $__ERR -gt 0 ] && critical_error "Invalid host: Error '4' - Force IP Version IPv$__ERR not supported"
	fi

	# verify nc command
	# busybox nc compiled without -l option "NO OPT l!" -> critical error
	nc --help 2>&1 | grep -iq "NO OPT l!" && \
		critical_error "Busybox nc: netcat compiled without -l option, error 'NO OPT l!'"
	# busybox nc compiled with extensions
	nc --help 2>&1 | grep -q "\-w" && __NCEXT="TRUE"

	# connectivity test
	# run busybox nc to HOST PORT
	# busybox might be compiled with "FEATURE_PREFER_IPV4_ADDRESS=n"
	# then nc will try to connect via IPv6 if there is an IPv6 availible for host
	# not worring if there is an IPv6 wan address
	# so if not "forced_ipversion" to use ipv6 then connect test via ipv4 if availible
	[ $force_ipversion -ne 0 -a $use_ipv6 -ne 0 -o -z "$__IPV4" ] && {
		# force IPv6
		__IP=$__IPV6
	} || __IP=$__IPV4

	if [ -n "$__NCEXT" ]; then	# nc compiled with extensions (timeout support)
		__RUNPROG="nc -w 1 $__IP $__PORT </dev/null >/dev/null 2>&1"
		__ERRPROG="nc -vw 1 $__IP $__PORT </dev/null 2>&1"
		verbose_echo "  connect prog =: '$__RUNPROG'"
		eval $__RUNPROG
		__ERR=$?
		[ $__ERR -eq 0 ] && return 0
		verbose_echo "\n!!!!!!!!! ERROR =: BusyBox nc Error '$__ERR'\n$(eval $__ERRPROG)\n"
		syslog_err "host verify Error - BusyBox nc Error '$__ERR'"
		return 3
	else		# nc compiled without extensions (no timeout support)
		__RUNPROG="__timeout 2 -- nc $__IP $__PORT </dev/null >/dev/null 2>&1"
		verbose_echo "  connect prog =: '$__RUNPROG'"
		eval $__RUNPROG
		__ERR=$?
		[ $__ERR -eq 0 ] && return 0
		verbose_echo "\n!!!!!!!!! ERROR =: BusyBox nc Error '$__ERR' (timeout)"
		syslog_err "host verify Error - BusyBox nc Error '$__ERR' (timeout)"
		return 3
	fi
}

verify_dns() {
	# $1	DNS server to verify
	# we need DNS server to verify otherwise exit with ERROR 1
	[ -z "$1" ] && return 1

	# DNS uses port 53
	__verify_host_port "$1" "53"
}

verify_proxy() {
	# $1	Proxy-String to verify
	#		complete entry		user:password@host:port
	# 					inside user and password NO '@' of ":" allowed 
	#		host and port only	host:port
	#		host only		host		ERROR unsupported
	#		IPv4 address instead of host	123.234.234.123
	#		IPv6 address instead of host	[xxxx:....:xxxx]	in square bracket
	local __TMP __HOST __PORT

	# we need Proxy-Sting to verify otherwise exit with ERROR 1
	[ -z "$1" ] && return 1

	# try to split user:password "@" host:port
	__TMP=$(echo $1 | awk -F "@" '{print $2}')
	# no "@" found - only host:port is given
	[ -z "$__TMP" ] && __TMP="$1"
	# now lets check for IPv6 address
	__HOST=$(echo $__TMP | grep -m 1 -o "$IPV6_REGEX")
	# IPv6 host address found read port
	if [ -n "$__HOST" ]; then
		# IPv6 split at "]:"
		__PORT=$(echo $__TMP | awk -F "]:" '{print $2}')
	else
		__HOST=$(echo $__TMP | awk -F ":" '{print $1}')
		__PORT=$(echo $__TMP | awk -F ":" '{print $2}')
	fi
	# No Port detected
	[ -z "$__PORT" ] && critical_error "Invalid Proxy server Error '5' - proxy port missing"

	__verify_host_port "$__HOST" "$__PORT"
}

__do_transfer() {
	# $1	# Variable to store Answer of transfer
	# $2	# URL to use
	local __URL="$2"
	local __ERR=0
	local __PROG  __RUNPROG  __ERRPROG  __DATA

	# lets prefer GNU Wget because it does all for us - IPv4/IPv6/HTTPS/PROXY/force IP version
	if /usr/bin/wget --version 2>&1 | grep -q "\+ssl"; then
		__PROG="/usr/bin/wget -t 2 -O -"	# standard output only 2 retrys on error
		# force ip version to use
		if [ $force_ipversion -eq 1 ]; then	
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4" || __PROG="$__PROG -6"	# force IPv4/IPv6
		fi
		# set certificate parameters
		if [ $use_https -eq 1 ]; then
			if [ "$cacert" = "IGNORE" ]; then	# idea from Ticket #15327 to ignore server cert
				__PROG="$__PROG --no-check-certificate"
			elif [ -f "$cacert" ]; then
				__PROG="$__PROG --ca-certificate=${cacert}"
			elif [ -d "$cacert" ]; then
				__PROG="$__PROG --ca-directory=${cacert}"
			else	# exit here because it makes no sense to start loop
				critical_error "Wget: No valid certificate(s) found for running HTTPS"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		[ -z "$proxy" ] && __PROG="$__PROG --no-proxy"

		__RUNPROG="$__PROG -q '$__URL' 2>/dev/null"	# do transfer with "-q" to suppress not needed output
		__ERRPROG="$__PROG -d '$__URL' 2>&1"		# do transfer with "-d" for debug mode
		verbose_echo " transfer prog =: $__RUNPROG"
		__DATA=$(eval $__RUNPROG)
		__ERR=$?
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: GNU Wget Error '$__ERR'\n$(eval $__ERRPROG)\n"
			syslog_err "Communication Error - GNU Wget Error: '$__ERR'"
			return 1
		}

	# 2nd choice is cURL IPv4/IPv6/HTTPS
	# libcurl might be compiled without Proxy Support (default in trunk)
	elif [ -x /usr/bin/curl ]; then
		__PROG="/usr/bin/curl"
		# force ip version to use
		if [ $force_ipversion -eq 1 ]; then	
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4" || __PROG="$__PROG -6"	# force IPv4/IPv6
		fi
		# set certificate parameters
		if [ $use_https -eq 1 ]; then
			if [ "$cacert" = "IGNORE" ]; then	# idea from Ticket #15327 to ignore server cert
				__PROG="$__PROG --insecure"	# but not empty better to use "IGNORE"
			elif [ -f "$cacert" ]; then
				__PROG="$__PROG --cacert $cacert"
			elif [ -d "$cacert" ]; then
				__PROG="$__PROG --capath $cacert"
			else	# exit here because it makes no sense to start loop
				critical_error "cURL: No valid certificate(s) found for running HTTPS"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		# or check if libcurl compiled with proxy support
		if [ -z "$proxy" ]; then
			__PROG="$__PROG --noproxy '*'"
		else
			# if libcurl has no proxy support and proxy should be used then force ERROR
			# libcurl currently no proxy support by default
			grep -iq all_proxy /usr/lib/libcurl.so* || \
				critical_error "cURL: libcurl compiled without Proxy support"
		fi

		__RUNPROG="$__PROG -q '$__URL' 2>/dev/null"	# do transfer with "-s" to suppress not needed output
		__ERRPROG="$__PROG -v '$__URL' 2>&1"		# do transfer with "-v" for verbose mode
		verbose_echo " transfer prog =: $__RUNPROG"
		__DATA=$(eval $__RUNPROG)
		__ERR=$?
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: cURL Error '$__ERR'\n$(eval $__ERRPROG)\n"
			syslog_err "Communication Error - cURL Error: '$__ERR'"
			return 1
		}

	# busybox Wget (did not support neither IPv6 nor HTTPS)
	elif [ -x /usr/bin/wget ]; then
		__PROG="/usr/bin/wget -O -"
		# force ip version not supported
		[ $force_ipversion -eq 1 ] && \
			critical_error "BusyBox Wget: can not force IP version to use"
		# https not supported
		[ $use_https -eq 1 ] && \
			critical_error "BusyBox Wget: no HTTPS support"
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		[ -z "$proxy" ] && __PROG="$__PROG -Y off"
		
		__RUNPROG="$__PROG -q '$__URL' 2>/dev/null"	# do transfer with "-q" to suppress not needed output
		__ERRPROG="$__PROG '$__URL' 2>&1"
		verbose_echo " transfer prog =: $__RUNPROG"
		__DATA=$(eval $__RUNPROG)
		__ERR=$?
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: BusyBox Wget Error '$__ERR'\n$(eval $__ERRPROG)\n"
			syslog_err "Communication Error - BusyBox Wget Error: '$__ERR'"
			return 1
		}

	else
		critical_error "Program not found - Neither 'Wget' nor 'cURL' installed or executable"
	fi

	eval "$1='$__DATA'"
	return 0
}

send_update() {
	# $1	# IP to set at DDNS service provider
	local __IP

	# verify given IP / no private IPv4's / no IPv6 addr starting with fxxx of with ":"
	[ $use_ipv6 -eq 0 ] && __IP=$(echo $1 | grep -v -E "(^0|^10\.|^127|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-1]\.|^192\.168)")
	[ $use_ipv6 -eq 1 ] && __IP=$(echo $1 | grep "^[0-9a-eA-E]")
	[ -z "$__IP" ] && critical_error "Private or invalid or no IP '$1' given"

	if [ -n "$update_script" ]; then
		verbose_echo "        update =: parsing script '$update_script'"
		. $update_script
	else
		local __URL __ANSWER __ERR __USER __PASS

		# do replaces in URL
		__urlencode __USER "$username"	# encode username, might be email or something like this
		__urlencode __PASS "$password"	# encode password, might have special chars for security reason
		__URL=$(echo $update_url | sed -e "s#\[USERNAME\]#$__USER#g" -e "s#\[PASSWORD\]#$__PASS#g" \
					       -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__IP#g")
		[ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')

		__do_transfer __ANSWER "$__URL"
		__ERR=$?
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: Error sending update to DDNS Provider\n"
			return 1
		}
		verbose_echo "   update send =: DDNS Provider answered\n$__ANSWER"
		return 0
	fi
}

get_local_ip () {
	# $1	Name of Variable to store local IP (LOCAL_IP)
	local __RUNPROG __IP __URL __ANSWER

	case $ip_source in
		network )
			# set correct program
			[ $use_ipv6 -eq 0 ] && __RUNPROG="network_get_ipaddr" \
					    || __RUNPROG="network_get_ipaddr6"
			$__RUNPROG __IP "$ip_network"
			verbose_echo "      local ip =: '$__IP' detected on network '$ip_network'"
			;;
		interface )
			if [ $use_ipv6 -eq 0 ]; then
				__IP=$(ifconfig $ip_interface | awk '
					/inet addr:/ {	# Filter IPv4
					#   inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
					$1="";		# remove inet
					$3="";		# remove Bcast: ...
					$4="";		# remove Mask: ...
					FS=":";		# separator ":"
					$0=$0;		# reread to activate separator
					$1="";		# remove addr
					FS=" ";		# set back separator to default " "
					$0=$0;		# reread to activate separator (remove whitespaces)
					print $1;	# print IPv4 addr
					}'
				)
			else
				__IP=$(ifconfig $ip_interface | awk '
					/inet6/ && /: [0-9a-eA-E]/ && !/\/128/ {	# Filter IPv6 exclude fxxx and /128 prefix
					#   inet6 addr: 2001:db8::xxxx:xxxx/32 Scope:Global
					FS="/";		# separator "/"
					$0=$0;		# reread to activate separator
					$2="";		# remove everything behind "/"
					FS=" ";		# set back separator to default " "
					$0=$0;		# reread to activate separator
					print $3;	# print IPv6 addr
					}'
				)
			fi
			verbose_echo "      local ip =: '$__IP' detected on interface '$ip_interface'"
			;;
		script )
			# get ip from script
			__IP=$($ip_script)
			verbose_echo "      local ip =: '$__IP' detected via script '$ip_script'"
			;;
		* )
			for __URL in $ip_url; do
				__do_transfer __ANSWER "$__URL"
				[ -n "$__IP" ] && break	# Answer detected, leave for loop
			done
			# use correct regular expression
			[ $use_ipv6 -eq 0 ] \
				&& __IP=$(echo "$__ANSWER" | grep -m 1 -o "$IPV4_REGEX") \
				|| __IP=$(echo "$__ANSWER" | grep -m 1 -o "$IPV6_REGEX")
			verbose_echo "      local ip =: '$__IP' detected via web at '$__URL'"
			;;
	esac

	# if NO IP was found
	[ -z "$__IP" ] && return 1

	eval "$1='$__IP'"
	return 0
}

get_registered_ip() {
	# $1	Name of Variable to store public IP (REGISTERED_IP)
	local __IP  __REGEX  __PROG  __RUNPROG  __ERRPROG  __ERR
	# return codes
	# 1	no IP detected

	# set correct regular expression
	[ $use_ipv6 -eq 0 ] && __REGEX="$IPV4_REGEX" || __REGEX="$IPV6_REGEX"

	if [ -x /usr/bin/host ]; then		# otherwise try to use BIND host
		__PROG="/usr/bin/host"
		[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -t A"  || __PROG="$__PROG -t AAAA"
		if [ $force_ipversion -eq 1 ]; then			# force IP version
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4"  || __PROG="$__PROG -6"
		fi			
		[ $force_dnstcp -eq 1 ] && __PROG="$__PROG -T"	# force TCP

		__RUNPROG="$__PROG $domain $dns_server 2>/dev/null"
		__ERRPROG="$__PROG -v $domain $dns_server 2>&1"
		verbose_echo " resolver prog =: $__RUNPROG"
		__IP=$(eval $__RUNPROG)
		__ERR=$?
		# command error
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: BIND host Error '$__ERR'\n$(eval $__ERRPROG)\n"
			syslog_err "DNS Resolver Error - BIND host Error: '$__ERR'"
			return 1
		} || {
			# we need to run twice because multi-line output needs to be directly piped to grep because
			# pipe returns return code of last prog in pipe but we need errors from host command
			__IP=$(eval $__RUNPROG | awk -F "address " '/has/ {print $2; exit}' )
		}

	elif [ -x /usr/bin/nslookup ]; then	# last use BusyBox nslookup
		[ $force_ipversion -ne 0 -o $force_dnstcp -ne 0 ] && \
			critical_error "nslookup - no support to 'force IP Version' or 'DNS over TCP'"

		__RUNPROG="nslookup $domain $dns_server 2>/dev/null"
		__ERRPROG="nslookup $domain $dns_server 2>&1"
		verbose_echo " resolver prog =: $__RUNPROG"
		__IP=$(eval $__RUNPROG)
		__ERR=$?
		# command error
		[ $__ERR -gt 0 ] && {
			verbose_echo "\n!!!!!!!!! ERROR =: BusyBox nslookup Error '$__ERR'\n$(eval $__ERRPROG)\n"
			syslog_err "DNS Resolver Error - BusyBox nslookup Error: '$__ERR'"
			return 1
		} || {
			# we need to run twice because multi-line output needs to be directly piped to grep because
			# pipe returns return code of last prog in pipe but we need errors from nslookup command
			__IP=$(eval $__RUNPROG | sed -ne "3,\$ { s/^Address [0-9]*: \($__REGEX\).*$/\\1/p }" )
		}

	else					# there must be an error
		critical_error "No program found to request public registered IP"
	fi

	verbose_echo "   resolved ip =: '$__IP'"

	# if NO IP was found
	[ -z "$__IP" ] && return 1

	eval "$1='$__IP'"
	return 0
}

get_uptime() {
	# $1	Variable to store result in
	local __UPTIME=$(cat /proc/uptime)
	eval "$1='${__UPTIME%%.*}'"
}
