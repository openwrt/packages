#!/bin/sh
# /usr/lib/ddns/dynamic_dns_functions.sh
#
# Original written by Eric Paul Bishop, January 2008
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
# (Loosely) based on the script on the one posted by exobyte in the forums here:
# http://forum.openwrt.org/viewtopic.php?id=14040
#
# extended and partial rewritten in August 2014 by
#.Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
# to support:
# - IPv6 DDNS services
# - setting DNS Server to retrieve current IP including TCP transport
# - Proxy Server to send out updates or retrieving WEB based IP detection
# - force_interval=0 to run once (useful for cron jobs etc.)
# - the usage of BIND's host instead of BusyBox's nslookup if installed (DNS via TCP)
# - extended Verbose Mode and log file support for better error detection
#
# function timeout
# copied from http://www.ict.griffith.edu.au/anthony/software/timeout.sh
# @author Anthony Thyssen  6 April 2011
#
# variables in small chars are read from /etc/config/ddns
# variables in big chars are defined inside these scripts as global vars
# variables in big chars beginning with "__" are local defined inside functions only
# set -vx  	#script debugger

. /lib/functions.sh
. /lib/functions/network.sh

# GLOBAL VARIABLES #
SECTION_ID=""		# hold config's section name
VERBOSE_MODE=1		# default mode is log to console, but easily changed with parameter

LOGFILE=""		# logfile - all files are set in dynamic_dns_updater.sh
PIDFILE=""		# pid file
UPDFILE=""		# store UPTIME of last update
DATFILE=""		# save stdout data of WGet and other external programs called
ERRFILE=""		# save stderr output of WGet and other external programs called
TLDFILE=/usr/lib/ddns/tld_names.dat.gz	# TLD file used by split_FQDN

CHECK_SECONDS=0		# calculated seconds out of given
FORCE_SECONDS=0		# interval and unit
RETRY_SECONDS=0		# in configuration

LAST_TIME=0		# holds the uptime of last successful update
CURR_TIME=0		# holds the current uptime
NEXT_TIME=0		# calculated time for next FORCED update
EPOCH_TIME=0		# seconds since 1.1.1970 00:00:00

REGISTERED_IP=""	# holds the IP read from DNS
LOCAL_IP=""		# holds the local IP read from the box

URL_USER=""		# url encoded $username from config file
URL_PASS=""		# url encoded $password from config file

ERR_LAST=0		# used to save $? return code of program and function calls
ERR_UPDATE=0		# error counter on different local and registered ip

PID_SLEEP=0		# ProcessID of current background "sleep"

# allow NON-public IP's
ALLOW_LOCAL_IP=$(uci -q get ddns.global.allow_local_ip) || ALLOW_LOCAL_IP=0

# directory to store run information to.
RUNDIR=$(uci -q get ddns.global.run_dir) || RUNDIR="/var/run/ddns"
[ -d $RUNDIR ] || mkdir -p -m755 $RUNDIR

# directory to store log files
LOGDIR=$(uci -q get ddns.global.log_dir) || LOGDIR="/var/log/ddns"
[ -d $LOGDIR ] || mkdir -p -m755 $LOGDIR

# number of lines to before rotate logfile
LOGLINES=$(uci -q get ddns.global.log_lines) || LOGLINES=250
LOGLINES=$((LOGLINES + 1))	# correct sed handling

# format to show date information in log and luci-app-ddns default ISO 8601 format
DATE_FORMAT=$(uci -q get ddns.global.date_format) || DATE_FORMAT="%F %R"
DATE_PROG="date +'$DATE_FORMAT'"

# regular expression to detect IPv4 / IPv6
# IPv4       0-9   1-3x "." 0-9  1-3x "." 0-9  1-3x "." 0-9  1-3x
IPV4_REGEX="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
# IPv6       ( ( 0-9a-f  1-4char ":") min 1x) ( ( 0-9a-f  1-4char   )optional) ( (":" 0-9a-f 1-4char  ) min 1x)
IPV6_REGEX="\(\([0-9A-Fa-f]\{1,4\}:\)\{1,\}\)\(\([0-9A-Fa-f]\{1,4\}\)\{0,1\}\)\(\(:[0-9A-Fa-f]\{1,4\}\)\{1,\}\)"

# detect if called by dynamic_dns_lucihelper.sh script, disable retrys (empty variable == false)
[ "$(basename $0)" = "dynamic_dns_lucihelper.sh" ] && LUCI_HELPER="TRUE" || LUCI_HELPER=""

# USE_CURL if GNU Wget and cURL installed normally Wget is used by do_transfer()
# to change this use global option use_curl '1'
USE_CURL=$(uci -q get ddns.global.use_curl) || USE_CURL=0	# read config
[ -x /usr/bin/curl ] || USE_CURL=0				# check for cURL

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

# read's all service sections from ddns config
# $1 = Name of variable to store
load_all_service_sections() {
	local __DATA=""
	config_cb()
	{
		# only look for section type "service", ignore everything else
		[ "$1" = "service" ] && __DATA="$__DATA $2"
	}
	config_load "ddns"

	eval "$1=\"$__DATA\""
	return
}

# starts updater script for all given sections or only for the one given
# $1 = interface (Optional: when given only scripts are started
# configured for that interface)
# used by /etc/hotplug.d/iface/25-ddns on IFUP
# and by /etc/init.d/ddns start
start_daemon_for_all_ddns_sections()
{
	local __EVENTIF="$1"
	local __SECTIONS=""
	local __SECTIONID=""
	local __IFACE=""

	load_all_service_sections __SECTIONS
	for __SECTIONID in $__SECTIONS; do
		config_get __IFACE "$__SECTIONID" interface "wan"
		[ -z "$__EVENTIF" -o "$__IFACE" = "$__EVENTIF" ] || continue
		/usr/lib/ddns/dynamic_dns_updater.sh $__SECTIONID 0 >/dev/null 2>&1 &
	done
}

# stop sections process incl. childs (sleeps)
# $1 = section
stop_section_processes() {
	local __PID=0
	local __PIDFILE="$RUNDIR/$1.pid"
	[ $# -ne 1 ] && write_log 12 "Error calling 'stop_section_processes()' - wrong number of parameters"

	[ -e "$__PIDFILE" ] && {
		__PID=$(cat $__PIDFILE)
		ps | grep "^[\t ]*$__PID" >/dev/null 2>&1 && kill $__PID || __PID=0	# terminate it
	}
	[ $__PID -eq 0 ] # report if process was running
}

# stop updater script for all defines sections or only for one given
# $1 = interface (optional)
# used by /etc/hotplug.d/iface/25-ddns on 'ifdown'
# and by /etc/init.d/ddns stop
# needed because we also need to kill "sleep" child processes
stop_daemon_for_all_ddns_sections() {
	local __EVENTIF="$1"
	local __SECTIONS=""
	local __SECTIONID=""
	local __IFACE=""

	load_all_service_sections __SECTIONS
	for __SECTIONID in $__SECTIONS;	do
		config_get __IFACE "$__SECTIONID" interface "wan"
		[ -z "$__EVENTIF" -o "$__IFACE" = "$__EVENTIF" ] || continue
		stop_section_processes "$__SECTIONID"
	done
}

# reports to console, logfile, syslog
# $1	loglevel 7 == Debug to 0 == EMERG
#	value +10 will exit the scripts
# $2..n	text to report
write_log() {
	local __LEVEL __EXIT __CMD __MSG
	local __TIME=$(date +%H%M%S)
	[ $1 -ge 10 ] && {
		__LEVEL=$(($1-10))
		__EXIT=1
	} || {
		__LEVEL=$1
		__EXIT=0
	}
	shift	# remove loglevel
	[ $__EXIT -eq 0 ] && __MSG="$*" || __MSG="$* - TERMINATE"
	case $__LEVEL in		# create log message and command depending on loglevel
		0)	__CMD="logger -p user.emerg -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME EMERG : $__MSG" ;;
		1)	__CMD="logger -p user.alert -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME ALERT : $__MSG" ;;
		2)	__CMD="logger -p user.crit -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME  CRIT : $__MSG" ;;
		3)	__CMD="logger -p user.err -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME ERROR : $__MSG" ;;
		4)	__CMD="logger -p user.warn -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME  WARN : $__MSG" ;;
		5)	__CMD="logger -p user.notice -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME  note : $__MSG" ;;
		6)	__CMD="logger -p user.info -t ddns-scripts[$$] $SECTION_ID: $__MSG"
			__MSG=" $__TIME  info : $__MSG" ;;
		7)	__MSG=" $__TIME       : $__MSG";;
		*) 	return;;
	esac

	# verbose echo
	[ $VERBOSE_MODE -gt 0 -o $__EXIT -gt 0 ] && echo -e "$__MSG"
	# write to logfile
	if [ ${use_logfile:-1} -eq 1 -o $VERBOSE_MODE -gt 1 ]; then
		echo -e "$__MSG" >> $LOGFILE
		# VERBOSE_MODE > 1 then NO loop so NO truncate log to $LOGLINES lines
		[ $VERBOSE_MODE -gt 1 ] || sed -i -e :a -e '$q;N;'$LOGLINES',$D;ba' $LOGFILE
	fi
	[ $LUCI_HELPER ]   && return	# nothing else todo when running LuCI helper script
	[ $__LEVEL -eq 7 ] && return	# no syslog for debug messages
	__CMD=$(echo -e "$__CMD" | tr -d '\n' | tr '\t' '     ')        # remove \n \t chars
	[ $__EXIT  -eq 1 ] && {
		$__CMD		# force syslog before exit
		exit 1
	}
	[ $use_syslog -eq 0 ] && return
	[ $((use_syslog + __LEVEL)) -le 7 ] && $__CMD
	return
}

# replace all special chars to their %hex value
# used for USERNAME and PASSWORD in update_url
# unchanged: "-"(minus) "_"(underscore) "."(dot) "~"(tilde)
# to verify: "'"(single quote) '"'(double quote)	# because shell delimiter
#            "$"(Dollar)				# because used as variable output
# tested with the following string stored via Luci Application as password / username
# A B!"#AA$1BB%&'()*+,-./:;<=>?@[\]^_`{|}~	without problems at Dollar or quotes
urlencode() {
	# $1	Name of Variable to store encoded string to
	# $2	string to encode
	local __STR __LEN __CHAR __OUT
	local __ENC=""
	local __POS=1

	[ $# -ne 2 ] && write_log 12 "Error calling 'urlencode()' - wrong number of parameters"

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

	eval "$1=\"$__ENC\""	# transfer back to variable
	return 0
}

# extract url or script for given DDNS Provider from
# file /usr/lib/ddns/services for IPv4 or from
# file /usr/lib/ddns/services_ipv6 for IPv6
# $1	Name of Variable to store url to
# $2	Name of Variable to store script to
get_service_data() {
	local __LINE __FILE __NAME __URL __SERVICES __DATA
	local __SCRIPT=""
	local __OLD_IFS=$IFS
	local __NEWLINE_IFS='
' # __NEWLINE_IFS
	[ $# -ne 2 ] && write_log 12 "Error calling 'get_service_data()' - wrong number of parameters"

	__FILE="/usr/lib/ddns/services"					# IPv4
	[ $use_ipv6 -ne 0 ] && __FILE="/usr/lib/ddns/services_ipv6"	# IPv6

	# remove any lines not containing data, and then make sure fields are enclosed in double quotes
	__SERVICES=$(cat $__FILE | grep "^[\t ]*[^#]" | \
		awk ' gsub("\x27", "\"") { if ($1~/^[^\"]*$/) $1="\""$1"\"" }; { if ( $NF~/^[^\"]*$/) $NF="\""$NF"\""  }; { print $0 }')

	IFS=$__NEWLINE_IFS
	for __LINE in $__SERVICES; do
		# grep out proper parts of data and use echo to remove quotes
		__NAME=$(echo $__LINE | grep -o "^[\t ]*\"[^\"]*\"" | xargs -r -n1 echo)
		__DATA=$(echo $__LINE | grep -o "\"[^\"]*\"[\t ]*$" | xargs -r -n1 echo)

		if [ "$__NAME" = "$service_name" ]; then
			break			# found so leave for loop
		fi
	done
	IFS=$__OLD_IFS

	# check if URL or SCRIPT is given
	__URL=$(echo "$__DATA" | grep "^http")
	[ -z "$__URL" ] && __SCRIPT="/usr/lib/ddns/$__DATA"

	eval "$1=\"$__URL\""
	eval "$2=\"$__SCRIPT\""
	return 0
}

# Calculate seconds from interval and unit
# $1	Name of Variable to store result in
# $2	Number and
# $3	Unit of time interval
get_seconds() {
	[ $# -ne 3 ] && write_log 12 "Error calling 'get_seconds()' - wrong number of parameters"
	case "$3" in
		"days" )	eval "$1=$(( $2 * 86400 ))";;
		"hours" )	eval "$1=$(( $2 * 3600 ))";;
		"minutes" )	eval "$1=$(( $2 * 60 ))";;
		* )		eval "$1=$2";;
	esac
	return 0
}

timeout() {
	#.copied from http://www.ict.griffith.edu.au/anthony/software/timeout.sh
	# only did the following changes
	#	- commented out "#!/bin/bash" and usage section
	#	- replace exit by return for usage as function
	#	- some reformatting
	#
	# timeout [-SIG] time [--] command args...
	#
	# Run the given command until completion, but kill it if it runs too long.
	# Specifically designed to exit immediately (no sleep interval) and clean up
	# nicely without messages or leaving any extra processes when finished.
	#
	# Example use
	#    timeout 5 countdown
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
	#.Anthony Thyssen     6 April 2011
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

	while [ $# -gt 0 ]; do
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

	# run main command in backgrounds and get its pid
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

# verify given host and port is connectable
# $1	Host/IP to verify
# $2	Port to verify
verify_host_port() {
	local __HOST=$1
	local __PORT=$2
	local __IP __IPV4 __IPV6 __RUNPROG __PROG __ERR
	# return codes
	# 1	system specific error
	# 2	nslookup/host error
	# 3	nc (netcat) error
	# 4	unmatched IP version

	[ $# -ne 2 ] && write_log 12 "Error calling 'verify_host_port()' - wrong number of parameters"

	# check if ip or FQDN was given
	__IPV4=$(echo $__HOST | grep -m 1 -o "$IPV4_REGEX$")	# do not detect ip in 0.0.0.0.example.com
	__IPV6=$(echo $__HOST | grep -m 1 -o "$IPV6_REGEX")
	# if FQDN given get IP address
	[ -z "$__IPV4" -a -z "$__IPV6" ] && {
		if [ -x /usr/bin/host ]; then	# use BIND host if installed
			__PROG="BIND host"
			__RUNPROG="/usr/bin/host -t ANY $__HOST >$DATFILE 2>$ERRFILE"
		else	# use BusyBox nslookup
			__PROG="BusyBox nslookup"
			__RUNPROG="/usr/bin/nslookup $__HOST >$DATFILE 2>$ERRFILE"
		fi
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG
		__ERR=$?
		# command error
		[ $__ERR -gt 0 ] && {
			write_log 3 "DNS Resolver Error - $__PROG Error '$__ERR'"
			write_log 7 "$(cat $ERRFILE)"
			return 2
		}
		# extract IP address
		if [ -x /usr/bin/host ]; then	# use BIND host if installed
			__IPV4=$(cat $DATFILE | awk -F "address " '/has address/ {print $2; exit}' )
			__IPV6=$(cat $DATFILE | awk -F "address " '/has IPv6/ {print $2; exit}' )
		else	# use BusyBox nslookup
			__IPV4=$(cat $DATFILE | sed -ne "/^Name:/,\$ { s/^Address[0-9 ]\{0,\}: \($IPV4_REGEX\).*$/\\1/p }")
			__IPV6=$(cat $DATFILE | sed -ne "/^Name:/,\$ { s/^Address[0-9 ]\{0,\}: \($IPV6_REGEX\).*$/\\1/p }")
		fi
	}

	# check IP version if forced
	if [ $force_ipversion -ne 0 ]; then
		__ERR=0
		[ $use_ipv6 -eq 0 -a -z "$__IPV4" ] && __ERR=4
		[ $use_ipv6 -eq 1 -a -z "$__IPV6" ] && __ERR=6
		[ $__ERR -gt 0 ] && {
			[ $LUCI_HELPER ] && return 4
			write_log 14 "Verify host Error '4' - Forced IP Version IPv$__ERR don't match"
		}
	fi

	# verify nc command
	# busybox nc compiled without -l option "NO OPT l!" -> critical error
	/usr/bin/nc --help 2>&1 | grep -i "NO OPT l!" >/dev/null 2>&1 && \
		write_log 12 "Busybox nc (netcat) compiled without '-l' option, error 'NO OPT l!'"
	# busybox nc compiled with extensions
	/usr/bin/nc --help 2>&1 | grep "\-w" >/dev/null 2>&1 && __NCEXT="TRUE"

	# connectivity test
	# run busybox nc to HOST PORT
	# busybox might be compiled with "FEATURE_PREFER_IPV4_ADDRESS=n"
	# then nc will try to connect via IPv6 if there is any IPv6 available on any host interface
	# not worrying, if there is an IPv6 wan address
	# so if not "force_ipversion" to use_ipv6 then connect test via ipv4, if available
	[ $force_ipversion -ne 0 -a $use_ipv6 -ne 0 -o -z "$__IPV4" ] && __IP=$__IPV6 || __IP=$__IPV4

	if [ -n "$__NCEXT" ]; then	# BusyBox nc compiled with extensions (timeout support)
		__RUNPROG="/usr/bin/nc -w 1 $__IP $__PORT </dev/null >$DATFILE 2>$ERRFILE"
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG
		__ERR=$?
		[ $__ERR -eq 0 ] && return 0
		write_log 3 "Connect error - BusyBox nc (netcat) Error '$__ERR'"
		write_log 7 "$(cat $ERRFILE)"
		return 3
	else		# nc compiled without extensions (no timeout support)
		__RUNPROG="timeout 2 -- /usr/bin/nc $__IP $__PORT </dev/null >$DATFILE 2>$ERRFILE"
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG
		__ERR=$?
		[ $__ERR -eq 0 ] && return 0
		write_log 3 "Connect error - BusyBox nc (netcat) timeout Error '$__ERR'"
		return 3
	fi
}

# verify given DNS server if connectable
# $1	DNS server to verify
verify_dns() {
	local __ERR=255	# last error buffer
	local __CNT=0	# error counter

	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_dns()' - wrong number of parameters"
	write_log 7 "Verify DNS server '$1'"

	while [ $__ERR -ne 0 ]; do
		# DNS uses port 53
		verify_host_port "$1" "53"
		__ERR=$?
		if [ $LUCI_HELPER ]; then	# no retry if called by LuCI helper script
			return $__ERR
		elif [ $__ERR -ne 0 -a $VERBOSE_MODE -gt 1 ]; then	# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Verify DNS server '$1' failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return $__ERR
		elif [ $__ERR -ne 0 ]; then
			__CNT=$(( $__CNT + 1 ))	# increment error counter
			# if error count > retry_count leave here
			[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
				write_log 14 "Verify DNS server '$1' failed after $retry_count retries"

			write_log 4 "Verify DNS server '$1' failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
			sleep $RETRY_SECONDS &
			PID_SLEEP=$!
			wait $PID_SLEEP	# enable trap-handler
			PID_SLEEP=0
		fi
	done
	return 0
}

# analyze and verify given proxy string
# $1	Proxy-String to verify
verify_proxy() {
	#	complete entry		user:password@host:port
	# 				inside user and password NO '@' of ":" allowed
	#	host and port only	host:port
	#	host only		host		ERROR unsupported
	#	IPv4 address instead of host	123.234.234.123
	#	IPv6 address instead of host	[xxxx:....:xxxx]	in square bracket
	local __TMP __HOST __PORT
	local __ERR=255	# last error buffer
	local __CNT=0	# error counter

	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_proxy()' - wrong number of parameters"
	write_log 7 "Verify Proxy server 'http://$1'"

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
	# No Port detected - EXITING
	[ -z "$__PORT" ] && {
		[ $LUCI_HELPER ] && return 5
		write_log 14 "Invalid Proxy server Error '5' - proxy port missing"
	}

	while [ $__ERR -gt 0 ]; do
		verify_host_port "$__HOST" "$__PORT"
		__ERR=$?
		if [ $LUCI_HELPER ]; then	# no retry if called by LuCI helper script
			return $__ERR
		elif [ $__ERR -gt 0 -a $VERBOSE_MODE -gt 1 ]; then	# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Verify Proxy server '$1' failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return $__ERR
		elif [ $__ERR -gt 0 ]; then
			__CNT=$(( $__CNT + 1 ))	# increment error counter
			# if error count > retry_count leave here
			[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
				write_log 14 "Verify Proxy server '$1' failed after $retry_count retries"

			write_log 4 "Verify Proxy server '$1' failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
			sleep $RETRY_SECONDS &
			PID_SLEEP=$!
			wait $PID_SLEEP	# enable trap-handler
			PID_SLEEP=0
		fi
	done
	return 0
}

do_transfer() {
	# $1	# URL to use
	local __URL="$1"
	local __ERR=0
	local __CNT=0	# error counter
	local __PROG  __RUNPROG

	[ $# -ne 1 ] && write_log 12 "Error in 'do_transfer()' - wrong number of parameters"

	# lets prefer GNU Wget because it does all for us - IPv4/IPv6/HTTPS/PROXY/force IP version
	grep -i "\+ssl" /usr/bin/wget >/dev/null 2>&1	# check for Wget with SSL support
	if [ $? -eq 0 -a $USE_CURL -eq 0 ]; then 	# except global option use_curl is set to "1"
		__PROG="/usr/bin/wget -nv -t 1 -O $DATFILE -o $ERRFILE"	# non_verbose no_retry outfile errfile
		# force network/ip to use for communication
		if [ -n "$bind_network" ]; then
			local __BINDIP
			# set correct program to detect IP
			[ $use_ipv6 -eq 0 ] && __RUNPROG="network_get_ipaddr" || __RUNPROG="network_get_ipaddr6"
			eval "$__RUNPROG __BINDIP $bind_network" || \
				write_log 13 "Can not detect local IP using '$__RUNPROG $bind_network' - Error: '$?'"
			write_log 7 "Force communication via IP '$__BINDIP'"
			__PROG="$__PROG --bind-address=$__BINDIP"
		fi
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
				write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		[ -z "$proxy" ] && __PROG="$__PROG --no-proxy"

		__RUNPROG="$__PROG '$__URL'"	# build final command
		__PROG="GNU Wget"		# reuse for error logging

	# 2nd choice is cURL IPv4/IPv6/HTTPS
	# libcurl might be compiled without Proxy Support (default in trunk)
	elif [ -x /usr/bin/curl ]; then
		__PROG="/usr/bin/curl -RsS -o $DATFILE --stderr $ERRFILE"
		# force network/interface-device to use for communication
		if [ -n "$bind_network" ]; then
			local __DEVICE
			network_get_physdev __DEVICE $bind_network || \
				write_log 13 "Can not detect local device using 'network_get_physdev $bind_network' - Error: '$?'"
			write_log 7 "Force communication via device '$__DEVICE'"
			__PROG="$__PROG --interface $__DEVICE"
		fi
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
				write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		# or check if libcurl compiled with proxy support
		if [ -z "$proxy" ]; then
			__PROG="$__PROG --noproxy '*'"
		else
			# if libcurl has no proxy support and proxy should be used then force ERROR
			# libcurl currently no proxy support by default
			grep -i "all_proxy" /usr/lib/libcurl.so* >/dev/null 2>&1 || \
				write_log 13 "cURL: libcurl compiled without Proxy support"
		fi

		__RUNPROG="$__PROG '$__URL'"	# build final command
		__PROG="cURL"			# reuse for error logging

	# busybox Wget (did not support neither IPv6 nor HTTPS)
	elif [ -x /usr/bin/wget ]; then
		__PROG="/usr/bin/wget -q -O $DATFILE"
		# force network/ip not supported
		[ -n "$__BINDIP" ] && \
			write_log 14 "BusyBox Wget: FORCE binding to specific address not supported"
		# force ip version not supported
		[ $force_ipversion -eq 1 ] && \
			write_log 14 "BusyBox Wget: Force connecting to IPv4 or IPv6 addresses not supported"
		# https not supported
		[ $use_https -eq 1 ] && \
			write_log 14 "BusyBox Wget: no HTTPS support"
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		[ -z "$proxy" ] && __PROG="$__PROG -Y off"

		__RUNPROG="$__PROG '$__URL' 2>$ERRFILE"		# build final command
		__PROG="Busybox Wget"				# reuse for error logging

	else
		write_log 13 "Neither 'Wget' nor 'cURL' installed or executable"
	fi

	while : ; do
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG			# DO transfer
		__ERR=$?			# save error code
		[ $__ERR -eq 0 ] && return 0	# no error leave
		[ $LUCI_HELPER ] && return 1	# no retry if called by LuCI helper script

		write_log 3 "$__PROG Error: '$__ERR'"
		write_log 7 "$(cat $ERRFILE)"		# report error

		[ $VERBOSE_MODE -gt 1 ] && {
			# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Transfer failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return 1
		}

		__CNT=$(( $__CNT + 1 ))	# increment error counter
		# if error count > retry_count leave here
		[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
			write_log 14 "Transfer failed after $retry_count retries"

		write_log 4 "Transfer failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP	# enable trap-handler
		PID_SLEEP=0
	done
	# we should never come here there must be a programming error
	write_log 12 "Error in 'do_transfer()' - program coding error"
}

send_update() {
	# $1	# IP to set at DDNS service provider
	local __IP

	[ $# -ne 1 ] && write_log 12 "Error calling 'send_update()' - wrong number of parameters"

	if [ $ALLOW_LOCAL_IP -eq 0 ]; then
		# verify given IP / no private IPv4's / no IPv6 addr starting with fxxx of with ":"
		[ $use_ipv6 -eq 0 ] && __IP=$(echo $1 | grep -v -E "(^0|^10\.|^100\.6[4-9]\.|^100\.[7-9][0-9]\.|^100\.1[0-1][0-9]\.|^100\.12[0-7]\.|^127|^169\.254|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-1]\.|^192\.168)")
		[ $use_ipv6 -eq 1 ] && __IP=$(echo $1 | grep "^[0-9a-eA-E]")
		[ -z "$__IP" ] && write_log 14 "Private or invalid or no IP '$1' given! Please check your configuration"
	else
		__IP="$1"
	fi

	if [ -n "$update_script" ]; then
		write_log 7 "parsing script '$update_script'"
		. $update_script
	else
		local __URL __ERR

		# do replaces in URL
		__URL=$(echo $update_url | sed -e "s#\[USERNAME\]#$URL_USER#g" -e "s#\[PASSWORD\]#$URL_PASS#g" \
					       -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__IP#g")
		[ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')

		do_transfer "$__URL" || return 1

		write_log 7 "DDNS Provider answered:\n$(cat $DATFILE)"

		return 0
		# TODO analyze providers answer
		# "good" or "nochg"		= dyndns.com compatible API
		# grep -i -E "good|nochg" $DATFILE >/dev/null 2>&1
		# return $?	# "0" if found
	fi
}

get_local_ip () {
	# $1	Name of Variable to store local IP (LOCAL_IP)
	local __CNT=0	# error counter
	local __RUNPROG __DATA __URL __ERR

	[ $# -ne 1 ] && write_log 12 "Error calling 'get_local_ip()' - wrong number of parameters"
	write_log 7 "Detect local IP on '$ip_source'"

	while : ; do
		case $ip_source in
			network)
				# set correct program
				[ $use_ipv6 -eq 0 ] && __RUNPROG="network_get_ipaddr" \
						    || __RUNPROG="network_get_ipaddr6"
				eval "$__RUNPROG __DATA $ip_network" || \
					write_log 13 "Can not detect local IP using $__RUNPROG '$ip_network' - Error: '$?'"
				[ -n "$__DATA" ] && write_log 7 "Local IP '$__DATA' detected on network '$ip_network'"
				;;
			interface)
				write_log 7 "#> ifconfig $ip_interface >$DATFILE 2>$ERRFILE"
				ifconfig $ip_interface >$DATFILE 2>$ERRFILE
				__ERR=$?
				if [ $__ERR -eq 0 ]; then
					if [ $use_ipv6 -eq 0 ]; then
						__DATA=$(awk '
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
							}' $DATFILE
						)
					else
						__DATA=$(awk '
							/inet6/ && /: [0-9a-eA-E]/ && !/\/128/ {	# Filter IPv6 exclude fxxx and /128 prefix
							#   inet6 addr: 2001:db8::xxxx:xxxx/32 Scope:Global
							FS="/";		# separator "/"
							$0=$0;		# reread to activate separator
							$2="";		# remove everything behind "/"
							FS=" ";		# set back separator to default " "
							$0=$0;		# reread to activate separator
							print $3;	# print IPv6 addr
							}' $DATFILE
						)
					fi
					[ -n "$__DATA" ] && write_log 7 "Local IP '$__DATA' detected on interface '$ip_interface'"
				else
					write_log 3 "ifconfig Error: '$__ERR'"
					write_log 7 "$(cat $ERRFILE)"		# report error
				fi
				;;
			script)
				write_log 7 "#> $ip_script >$DATFILE 2>$ERRFILE"
				eval $ip_script >$DATFILE 2>$ERRFILE
				__ERR=$?
				if [ $__ERR -eq 0 ]; then
					__DATA=$(cat $DATFILE)
					[ -n "$__DATA" ] && write_log 7 "Local IP '$__DATA' detected via script '$ip_script'"
				else
					write_log 3 "$ip_script Error: '$__ERR'"
					write_log 7 "$(cat $ERRFILE)"		# report error
				fi
				;;
			web)
				do_transfer "$ip_url"
				# use correct regular expression
				[ $use_ipv6 -eq 0 ] \
					&& __DATA=$(grep -m 1 -o "$IPV4_REGEX" $DATFILE) \
					|| __DATA=$(grep -m 1 -o "$IPV6_REGEX" $DATFILE)
				[ -n "$__DATA" ] && write_log 7 "Local IP '$__DATA' detected on web at '$ip_url'"
				;;
			*)
				write_log 12 "Error in 'get_local_ip()' - unhandled ip_source '$ip_source'"
				;;
		esac
		# valid data found return here
		[ -n "$__DATA" ] && {
			eval "$1=\"$__DATA\""
			return 0
		}

		[ $LUCI_HELPER ] && return 1	# no retry if called by LuCI helper script

		write_log 7 "Data detected:\n$(cat $DATFILE)"

		[ $VERBOSE_MODE -gt 1 ] && {
			# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Get local IP via '$ip_source' failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return 1
		}

		__CNT=$(( $__CNT + 1 ))	# increment error counter
		# if error count > retry_count leave here
		[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
			write_log 14 "Get local IP via '$ip_source' failed after $retry_count retries"
		write_log 4 "Get local IP via '$ip_source' failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP	# enable trap-handler
		PID_SLEEP=0
	done
	# we should never come here there must be a programming error
	write_log 12 "Error in 'get_local_ip()' - program coding error"
}

get_registered_ip() {
	# $1	Name of Variable to store public IP (REGISTERED_IP)
	# $2	(optional) if set, do not retry on error
	local __CNT=0	# error counter
	local __ERR=255
	local __REGEX  __PROG  __RUNPROG  __DATA
	# return codes
	# 1	no IP detected

	[ $# -lt 1 -o $# -gt 2 ] && write_log 12 "Error calling 'get_registered_ip()' - wrong number of parameters"
	write_log 7 "Detect registered/public IP"

	# set correct regular expression
	[ $use_ipv6 -eq 0 ] && __REGEX="$IPV4_REGEX" || __REGEX="$IPV6_REGEX"

	if [ -x /usr/bin/host ]; then
		__PROG="/usr/bin/host"
		[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -t A"  || __PROG="$__PROG -t AAAA"
		if [ $force_ipversion -eq 1 ]; then			# force IP version
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4"  || __PROG="$__PROG -6"
		fi
		[ $force_dnstcp -eq 1 ] && __PROG="$__PROG -T"	# force TCP

		__RUNPROG="$__PROG $domain $dns_server >$DATFILE 2>$ERRFILE"
		__PROG="BIND host"
	elif [ -x /usr/bin/nslookup ]; then	# last use BusyBox nslookup
		[ $force_ipversion -ne 0 -o $force_dnstcp -ne 0 ] && \
			write_log 14 "Busybox nslookup - no support to 'force IP Version' or 'DNS over TCP'"

		__RUNPROG="/usr/bin/nslookup $domain $dns_server >$DATFILE 2>$ERRFILE"
		__PROG="BusyBox nslookup"
	else	# there must be an error
		write_log 12 "Error in 'get_registered_ip()' - no supported Name Server lookup software accessible"
	fi

	while : ; do
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG
		__ERR=$?
		if [ $__ERR -ne 0 ]; then
			write_log 3 "$__PROG error: '$__ERR'"
			write_log 7 "$(cat $ERRFILE)"
		else
			if [ "$__PROG" = "BIND host" ]; then
				__DATA=$(cat $DATFILE | awk -F "address " '/has/ {print $2; exit}' )
			else
				__DATA=$(cat $DATFILE | sed -ne "/^Name:/,\$ { s/^Address[0-9 ]\{0,\}: \($__REGEX\).*$/\\1/p }" )
			fi
			[ -n "$__DATA" ] && {
				write_log 7 "Registered IP '$__DATA' detected"
				eval "$1=\"$__DATA\""	# valid data found
				return 0		# leave here
			}
			write_log 4 "NO valid IP found"
			__ERR=127
		fi

		[ $LUCI_HELPER ] && return $__ERR	# no retry if called by LuCI helper script
		[ -n "$2" ] && return $__ERR		# $2 is given -> no retry
		[ $VERBOSE_MODE -gt 1 ] && {
			# VERBOSE_MODE > 1 then NO retry
			write_log 4 "Get registered/public IP for '$domain' failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return $__ERR
		}

		__CNT=$(( $__CNT + 1 ))	# increment error counter
		# if error count > retry_count leave here
		[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
			write_log 14 "Get registered/public IP for '$domain' failed after $retry_count retries"

		write_log 4 "Get registered/public IP for '$domain' failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
		sleep $RETRY_SECONDS &
		PID_SLEEP=$!
		wait $PID_SLEEP	# enable trap-handler
		PID_SLEEP=0
	done
	# we should never come here there must be a programming error
	write_log 12 "Error in 'get_registered_ip()' - program coding error"
}

get_uptime() {
	# $1	Variable to store result in
	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_host_port()' - wrong number of parameters"
	local __UPTIME=$(cat /proc/uptime)
	eval "$1=\"${__UPTIME%%.*}\""
}

trap_handler() {
	# $1	trap signal
	# $2	optional (exit status)
	local __PIDS __PID
	local __ERR=${2:-0}
	local __OLD_IFS=$IFS
	local __NEWLINE_IFS='
' # __NEWLINE_IFS

	[ $PID_SLEEP -ne 0 ] && kill -$1 $PID_SLEEP 2>/dev/null	# kill pending sleep if exist

	case $1 in
		 0)	if [ $__ERR -eq 0 ]; then
				write_log 5 "PID '$$' exit normal at $(eval $DATE_PROG)\n"
			else
				write_log 4 "PID '$$' exit WITH ERROR '$__ERR' at $(eval $DATE_PROG)\n"
			fi ;;
		 1)	write_log 6 "PID '$$' received 'SIGHUP' at $(eval $DATE_PROG)"
			# reload config via starting the script again
			eval "/usr/lib/ddns/dynamic_dns_updater.sh $SECTION_ID $VERBOSE_MODE &"
			exit 0 ;;	# and leave this one
		 2)	write_log 5 "PID '$$' terminated by 'SIGINT' at $(eval $DATE_PROG)\n";;
		 3)	write_log 5 "PID '$$' terminated by 'SIGQUIT' at $(eval $DATE_PROG)\n";;
		15)	write_log 5 "PID '$$' terminated by 'SIGTERM' at $(eval $DATE_PROG)\n";;
		 *)	write_log 13 "Unhandled signal '$1' in 'trap_handler()'";;
	esac

	__PIDS=$(pgrep -P $$)	# get my childs (pgrep prints with "newline")
	IFS=$__NEWLINE_IFS
	for __PID in $__PIDS; do
		kill -$1 $__PID	# terminate it
	done
	IFS=$__OLD_IFS

	# remove out and err file
	[ -f $DATFILE ] && rm -f $DATFILE
	[ -f $ERRFILE ] && rm -f $ERRFILE

	# exit with correct handling:
	# remove trap handling settings and send kill to myself
	trap - 0 1 2 3 15
	[ $1 -gt 0 ] && kill -$1 $$
}

split_FQDN() {
	# $1	FQDN to split
	# $2	name of variable to store TLD
	# $3	name of variable to store (reg)Domain
	# $4	name of variable to store Host/Subdomain

	[ $# -ne 4 ] && write_log 12 "Error calling 'split_FQDN()' - wrong number of parameters"
	[ -z "$1"  ] && write_log 12 "Error calling 'split_FQDN()' - missing FQDN to split"
	[ -f $TLDFILE ] || write_log 12 "Error calling 'split_FQDN()' - missing file '$TLDFILE'"

	local _HOST _FDOM _CTLD _FTLD
	local _SET="$@"					# save given function parameters

	local _PAR=$(echo "$1" | tr [A-Z] [a-z] | tr "." " ")	# to lower and replace DOT with SPACE
	set -- $_PAR					# set new as function parameters
	_PAR=""						# clear variable for later reuse
	while [ -n "$1" ] ; do				# as long we have parameters
		_PAR="$1 $_PAR"				# invert order of parameters
		shift
	done
	set -- $_PAR					# use new as function parameters
	_PAR=""						# clear variable

	while [ -n "$1" ] ; do				# as long we have parameters
		if [ -z "$_CTLD" ]; then 		# first loop
			_CTLD="$1"			# CURRENT TLD to look at
			shift
		else
			_CTLD="$1.$_CTLD"		# Next TLD to look at
			shift
		fi
		# check if TLD exact match in tld_names.dat, save TLD
		zcat $TLDFILE | grep -E "^$_CTLD$" >/dev/null 2>&1 && {
			_FTLD="$_CTLD"		# save found
			_FDOM="$1"		# save domain next step might be invalid
			continue
		}
		# check if match any "*" in tld_names.dat,
		zcat $TLDFILE | grep -E "^\*.$_CTLD$" >/dev/null 2>&1 && {
			[ -z "$1" ] && break	# no more data break
			# check if next level TLD match excludes "!" in tld_names.dat
			if zcat $TLDFILE | grep -E "^!$1.$_CTLD$" >/dev/null 2>&1 ; then
				_FTLD="$_CTLD"	# Yes
			else
				_FTLD="$1.$_CTLD"
				shift
			fi
			_FDOM="$1"; shift
		}
		[ -n "$_FTLD" ] && break	# we have something valid, break
	done

	# the leftover parameters are the HOST/SUBDOMAIN
	while [ -n "$1" ]; do
		_HOST="$1 $HOST"		# remember we need to invert
		shift
	done
	_HOST=$(echo $_HOST | tr " " ".")	# insert DOT

	set -- $_SET				# set back parameters from function call
	[ -n "$_FTLD" ] && {
		eval "$2=$_FTLD"		# set TLD
		eval "$3=$_FDOM"		# set registrable domain
		eval "$4=$_HOST"		# set HOST/SUBDOMAIN
		return 0
	}
	eval "$2=''"		# clear TLD
	eval "$3=''"		# clear registrable domain
	eval "$4=''"		# clear HOST/SUBDOMAIN
	return 1
}
