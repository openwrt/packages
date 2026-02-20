#!/bin/sh
# /usr/lib/ddns/dynamic_dns_functions.sh
#
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
# Original written by Eric Paul Bishop, January 2008
# (Loosely) based on the script on the one posted by exobyte in the forums here:
# http://forum.openwrt.org/viewtopic.php?id=14040
# extended and partial rewritten
#.2014-2018 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
#
# 2026 Wayne King
# Added use_api_check option for providers with proxied records (e.g., Cloudflare)
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
if [ -f "/usr/share/ddns/version" ]; then
	VERSION="$(cat "/usr/share/ddns/version")"
else
	VERSION="unknown"
fi
SECTION_ID=""		# hold config's section name
VERBOSE=0		# default mode is log to console, but easily changed with parameter
DRY_RUN=0		# run without actually doing (sending) any changes
MYPROG=$(basename $0)	# my program call name

LOGFILE=""		# logfile - all files are set in dynamic_dns_updater.sh
PIDFILE=""		# pid file
UPDFILE=""		# store UPTIME of last update
DATFILE=""		# save stdout data of WGet and other external programs called
ERRFILE=""		# save stderr output of WGet and other external programs called
IPFILE=""		# store registered IP for read by LuCI status

CHECK_SECONDS=0		# calculated seconds out of given
FORCE_SECONDS=0		# interval and unit
RETRY_SECONDS=0		# in configuration

LAST_TIME=0		# holds the uptime of last successful update
CURR_TIME=0		# holds the current uptime
NEXT_TIME=0		# calculated time for next FORCED update
EPOCH_TIME=0		# seconds since 1.1.1970 00:00:00

CURRENT_IP=""		# holds the current IP read from the box
REGISTERED_IP=""	# holds the IP read from DNS

URL_USER=""		# url encoded $username from config file
URL_PASS=""		# url encoded $password from config file
URL_PENC=""		# url encoded $param_enc from config file

UPD_ANSWER=""		# Answer given by service on success

ERR_LAST=0		# used to save $? return code of program and function calls
RETRY_COUNT=0		# error counter on different current and registered IPs

PID_SLEEP=0		# ProcessID of current background "sleep"

# regular expression to detect IPv4 / IPv6
# IPv4       0-9   1-3x "." 0-9  1-3x "." 0-9  1-3x "." 0-9  1-3x
IPV4_REGEX="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
# IPv6       ( ( 0-9a-f  1-4char ":") min 1x) ( ( 0-9a-f  1-4char   )optional) ( (":" 0-9a-f 1-4char  ) min 1x)
IPV6_REGEX="\(\([0-9A-Fa-f]\{1,4\}:\)\{1,\}\)\(\([0-9A-Fa-f]\{1,4\}\)\{0,1\}\)\(\(:[0-9A-Fa-f]\{1,4\}\)\{1,\}\)"

# characters that are dangerous to pass to a shell command line
SHELL_ESCAPE="[\"\'\`\$\!();><{}?|\[\]\*\\\\]"

# dns character set. "-" must be the last character
DNS_CHARSET="[@a-zA-Z0-9.:_-]"

# domains can have * for wildcard. "-" must be the last character
DNS_CHARSET_DOMAIN="[@a-zA-Z0-9._*-]"

# detect if called by ddns-lucihelper.sh script, disable retrys (empty variable == false)
LUCI_HELPER=$(printf %s "$MYPROG" | grep -i "luci")

# Name Server Lookup Programs
BIND_HOST=$(command -v host)
KNOT_HOST=$(command -v khost)
DRILL=$(command -v drill)
HOSTIP=$(command -v hostip)
NSLOOKUP=$(command -v nslookup)
RESOLVEIP=$(command -v resolveip)
jsonfilter=$(command -v jsonfilter)

# Transfer Programs
WGET=$(command -v wget)
$WGET -V 2>/dev/null | grep -F -q +https && WGET_SSL=$WGET

CURL=$(command -v curl)
# CURL_SSL not empty then SSL support available
CURL_SSL=$($CURL -V 2>/dev/null | grep -F "https")
# CURL_PROXY not empty then Proxy support available
CURL_PROXY=$(find /lib /usr/lib -name libcurl.so* -exec strings {} 2>/dev/null \; | grep -im1 "all_proxy")

UCLIENT_FETCH=$(command -v uclient-fetch)

# Global configuration settings
# allow NON-public IP's
upd_privateip=$(uci -q get ddns.global.upd_privateip) || upd_privateip=0

# directory to store run information to.
ddns_rundir=$(uci -q get ddns.global.ddns_rundir) || ddns_rundir="/var/run/ddns"
[ -d $ddns_rundir ] || mkdir -p -m755 $ddns_rundir

# directory to store log files
ddns_logdir=$(uci -q get ddns.global.ddns_logdir) || ddns_logdir="/var/log/ddns"
[ -d $ddns_logdir ] || mkdir -p -m755 $ddns_logdir

# number of lines to before rotate logfile
ddns_loglines=$(uci -q get ddns.global.ddns_loglines) || ddns_loglines=250
ddns_loglines=$((ddns_loglines + 1))	# correct sed handling

# format to show date information in log and luci-app-ddns default ISO 8601 format
ddns_dateformat=$(uci -q get ddns.global.ddns_dateformat) || ddns_dateformat="%F %R"
DATE_PROG="date +'$ddns_dateformat'"

# USE_CURL if GNU Wget and cURL installed normally Wget is used by do_transfer()
# to change this use global option use_curl '1'
USE_CURL=$(uci -q get ddns.global.use_curl) || USE_CURL=0	# read config
[ -n "$CURL" ] || USE_CURL=0					# check for cURL

# loads all options for a given package and section
# also, sets all_option_variables to a list of the variable names
# $1 = ddns, $2 = SECTION_ID
load_all_config_options()
{
	local pkg_name section_id tmp_var all_opt_vars
	pkg_name="$1"
	section_id="$2"

	# this callback loads all the variables in the $section_id section when we do
	# config_load. We need to redefine the option_cb for different sections
	# so that the active one isn't still active after we're done with it.  For reference
	# the $1 variable is the name of the option and $2 is the name of the section
	config_cb()
	{
		if [ ."$2" = ."$section_id" ]; then
			option_cb()
			{
				all_opt_vars="$all_opt_vars $1"
			}
		else
			option_cb() { return 0; }
		fi
	}

	config_load "$pkg_name"

	# Given SECTION_ID not found so no data, so return 1
	[ -z "$all_opt_vars" ] && return 1

	for tmp_var in $all_opt_vars
	do
		config_get "$tmp_var" "$section_id" "$tmp_var"
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
# used by /etc/hotplug.d/iface/95-ddns on IFUP
# and by /etc/init.d/ddns start
start_daemon_for_all_ddns_sections()
{
	local event_if sections section_id configured_if
	event_if="$1"

	load_all_service_sections sections
	for section_id in $sections; do
		config_get configured_if "$section_id" interface "wan"
		[ -z "$event_if" ] || [ "$configured_if" = "$event_if" ] || continue
		/usr/lib/ddns/dynamic_dns_updater.sh -v "$VERBOSE" -S "$section_id" -- start &
	done
}

# stop sections process incl. childs (sleeps)
# $1 = section
stop_section_processes() {
	local pid_file
	pid_file="$ddns_rundir/$1.pid"
	[ $# -ne 1 ] && write_log 12 "Error: 'stop_section_processes()' requires exactly one parameter"

	[ -e "$pid_file" ] && {
		xargs kill < "$pid_file" 2>/dev/null && return 1
	}
	return 0 # nothing killed
}

# stop updater script for all defines sections or only for one given
# $1 = interface (optional)
# used by /etc/hotplug.d/iface/95-ddns on 'ifdown'
# and by /etc/init.d/ddns stop
# needed because we also need to kill "sleep" child processes
stop_daemon_for_all_ddns_sections() {
	local event_if sections section_id configured_if
	event_if="$1"

	load_all_service_sections sections
	for section_id in $sections;	do
		config_get configured_if "$section_id" interface "wan"
		[ -z "$event_if" ] || [ "$configured_if" = "$event_if" ] || continue
		stop_section_processes "$section_id"
	done
}

# reports to console, logfile, syslog
# $1	loglevel 7 == Debug to 0 == EMERG
#	value +10 will exit the scripts
# $2..n	text to report
write_log() {
	local __LEVEL __EXIT __CMD __MSG __MSE
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
	[ $VERBOSE -gt 0 -o $__EXIT -gt 0 ] && echo -e "$__MSG"
	# write to logfile
	if [ ${use_logfile:-1} -eq 1 -o $VERBOSE -gt 1 ]; then
		if [ -n "$password" ]; then
			# url encode __MSG, password already done
			urlencode __MSE "$__MSG"
			# replace encoded password inside encoded message
			# and url decode (newline was encoded as %00)
			__MSG=$( echo -e "$__MSE" \
				| sed -e "s/$URL_PASS/***PW***/g" \
				| sed -e "s/+/ /g; s/%00/\n/g; s/%/\\\\x/g" | xargs -0 printf "%b" )
		fi
		printf "%s\n" "$__MSG" >> $LOGFILE
		# VERBOSE > 1 then NO loop so NO truncate log to $ddns_loglines lines
		[ $VERBOSE -gt 1 ] || sed -i -e :a -e '$q;N;'$ddns_loglines',$D;ba' $LOGFILE
	fi
	[ -n "$LUCI_HELPER" ] && return	# nothing else todo when running LuCI helper script
	[ $__LEVEL -eq 7 ] && return	# no syslog for debug messages
	__CMD=$(echo -e "$__CMD" | tr -d '\n' | tr '\t' '     ')        # remove \n \t chars
	[ $__EXIT  -eq 1 ] && {
		eval '$__CMD'	# force syslog before exit
		exit 1
	}
	[ $use_syslog -eq 0 ] && return
	[ $((use_syslog + __LEVEL)) -le 7 ] && eval '$__CMD'

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
	local __ENC

	[ $# -ne 2 ] && write_log 12 "Error calling 'urlencode()' - wrong number of parameters"

	__ENC="$(awk -v str="$2" 'BEGIN{ORS="";for(i=32;i<=127;i++)lookup[sprintf("%c",i)]=i
		for(k=1;k<=length(str);++k){enc=substr(str,k,1);if(enc!~"[-_.~a-zA-Z0-9]")enc=sprintf("%%%02x", lookup[enc]);print enc}}')"

	eval "$1=\"$__ENC\""	# transfer back to variable
	return 0
}

# extract url or script for given DDNS Provider from
# $1	Name of the provider
# $2	Provider directory
# $3	Name of Variable to store url to
# $4	Name of Variable to store script to
# $5	Name of Variable to store service answer to
get_service_data() {
	local provider="$1"
	shift
	local dir="$1"
	shift

	. /usr/share/libubox/jshn.sh
	local name data url answer script

	[ $# -ne 3 ] && write_log 12 "Error calling 'get_service_data()' - wrong number of parameters"

	[ -f "${dir}/${provider}.json" ] || {
		eval "$1=\"\""
		eval "$2=\"\""
		eval "$3=\"\""
		return 1
	}

	json_load_file "${dir}/${provider}.json"
	json_get_var name "name"
	if [ "$use_ipv6" -eq "1" ]; then
		json_select "ipv6"
	else
		json_select "ipv4"
	fi
	json_get_var data "url"
	json_get_var answer "answer"
	json_select ".."
	json_cleanup

	# check if URL or SCRIPT is given
	url=$(echo "$data" | grep "^http")
	[ -z "$url" ] && script="/usr/lib/ddns/${data}"

	eval "$1=\"$url\""
	eval "$2=\"$script\""
	eval "$3=\"$answer\""
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

# sanitize a variable
# $1	variable name
# $2	allowed shell pattern
# $3	disallowed shell pattern
sanitize_variable() {
	local __VAR=$1
	eval __VALUE=\$$__VAR
	local __ALLOWED=$2
	local __REJECT=$3

	# removing all allowed should give empty string
	if [ -n "$__ALLOWED" ]; then
		[ -z "${__VALUE//$__ALLOWED}" ] || write_log 12 "sanitize on $__VAR found characters outside allowed subset"
	fi

	# removing rejected pattern should give the same string as the input
	if [ -n "$__REJECT" ]; then
		[ "$__VALUE" = "${__VALUE//$__REJECT}" ] || write_log 12 "sanitize on $__VAR found rejected characters"
	fi
}

# Verify host and port connectivity
# $1: Host/IP
# $2: Port
verify_host_port() {
	# return codes
	# 1	system specific error
	# 2	nslookup/host error
	# 3	nc (netcat) error
	# 4	unmatched IP version
	local host port ipv4 ipv6 nc_cmd err_code
	host=$1
	port=$2
	nc_cmd=$(command -v nc)
	err_code=0

	# Validate input parameters
	[ $# -ne 2 ] && { write_log 12 "Error: verify_host_port() requires exactly 2 arguments"; return 1; }

	# Resolve IP address
	ipv4=$("$RESOLVEIP" -4 "$host")
	ipv6=$("$RESOLVEIP" -6 "$host")
	if [ -z "$ipv4" ] && [ -z "$ipv6" ]; then
		write_log 3 "Failed to resolve any IPv4/6 for host: $host"
		return 2
	fi

	# check for forced IP version inconsistency
	if [ "$force_ipversion" != 0 ]; then 
		[ "$use_ipv6" = 0 ] && [ -z "$ipv4" ] && err_code=4
		[ "$use_ipv6" = 1 ] && [ -z "$ipv6" ] && err_code=6
		[ $err_code -gt 0 ] && {
			[ -n "$LUCI_HELPER" ] && write_log 14 "Error: verify_host_port(): no usable IP for the IP family that was forced"
			return 4
		}
	fi

	# Check connectivity using nc
	if [ -n "$nc_cmd" ]; then
		write_log 7 "#> $RESOLVEIP"
		if [ -n "$ipv4" ]; then
			timeout 3 "$nc_cmd" "$ipv4" "$port" >/dev/null 2>&1
		else
			timeout 3 "$nc_cmd" "$ipv6" "$port" >/dev/null 2>&1
		fi
		err_code=$?
		if [ $err_code -eq 0 ]; then

			write_log 7 "Successfully connected to $host:$port"
			return 0

		else

			write_log 3 "DNS Resolver Error - $RESOLVEIP (Error: $err_code)"
			write_log 7 "$(cat "$ERRFILE")"
			return 3

		fi
	else
		write_log 3 "Netcat (nc) command not found."
		return 1
	fi
}

# Verify whether a given DNS server is reachable
# $1	DNS server to verify
verify_dns() {
	local err attempt
	err=255   # Last error code
	attempt=0 # Retry attempt counter

	[ "$#" -ne 1 ] && { write_log 12 "Error: 'verify_dns()' requires exactly 1 argument."; return 1; }

	local dns_server="$1"
	write_log 7 "Verifying DNS server: '$dns_server'"

	while [ "$err" -ne 0 ]; do
		# Check connectivity to the DNS server on port 53
		verify_host_port "$dns_server" "53"
		err=$?

		# Exit immediately if called by LuCI helper script
		[ -n "$LUCI_HELPER" ] && return "$err"

		if [ "$err" -ne 0 ]; then
			# If in verbose mode and connection fails, do not retry
			if [ "$VERBOSE" -gt 1 ]; then
				write_log 4 "Verification failed for DNS server '$dns_server' - Verbose Mode: $VERBOSE - No retries."
				return "$err"
			fi

			# Increment attempt counter and handle retry
			attempt=$((attempt + 1))

			# If max retries are exceeded, exit with failure
			if [ "$retry_max_count" -gt 0 ] && [ "$attempt" -gt "$retry_max_count" ]; then
				write_log 14 "Verification failed for DNS server '$dns_server' after $retry_max_count retries."
				return "$err"
			fi

			# Log the retry attempt and wait before retrying
			write_log 4 "Verification failed for DNS server '$dns_server' - Retry $attempt/$retry_max_count in $RETRY_SECONDS seconds."
			sleep "$RETRY_SECONDS" &
			wait $!  # Enable trap handler during sleep
		fi
	done

	# Return success if the loop exits without errors
	return 0
}

# analyse and verify given proxy string
# $1	Proxy-String to verify
verify_proxy() {
	#	complete entry		user:password@host:port
	# 				inside user and password NO '@' of ":" allowed
	#	host and port only	host:port
	#	host only		host		ERROR unsupported
	#	IPv4 address instead of host	123.234.234.123
	#	IPv6 address instead of host	[xxxx:....:xxxx]	in square brackets
	# local user password
	local host port rest error_count err_code

	err_code=255	# last error buffer
	error_count=0	# error counter

	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_proxy()' - wrong number of parameters"
	write_log 7 "Verify Proxy server 'http://$1'"

	if [ "${1#*'@'}" != "$1" ]; then
		# Format: user:password@host:port or user:password@[ipv6]:port
		# user="${1%%:*}" # currently unused
		# rest="${1#*:}"
		# password="${rest%%@*}" # currently unused

		# Extract the host:port part
		rest="${rest#*@}"
	else
		# Format: host:port or [ipv6]:port
		rest="$1"
	fi

	if [ "${rest#*'['}" != "$rest" ]; then
		# Format: [ipv6]:port
		host="${rest%%]*}"
		host="${host#[}"  # Remove the leading '['

		port="${rest##*:}"
	else
		host="${rest%%:*}"
		port="${rest#*:}"
	fi
	# No Port detected - EXITING
	[ -z "$port" ] && {
		[ -n "$LUCI_HELPER" ] && return 5
		write_log 14 "Invalid Proxy server Error '5' - proxy port missing"
	}

	while [ "$err_code" -gt 0 ]; do
		verify_host_port "$host" "$port"
		err_code=$?
		[ -n "$LUCI_HELPER" ] && return "$err_code"	# no retry if called by LuCI helper script

		if [ "$err_code" -gt 0 ]; then
			[ "$VERBOSE" -gt 1 ] && {
				write_log 4 "Verify Proxy server '$1' failed - Verbose Mode: $VERBOSE - NO retry on error"
				return "$err_code"				
			}

			error_count=$(( error_count + 1 ))
			# if error count > retry_max_count leave here
			[ "$retry_max_count" -gt 0 ] && [ $error_count -gt "$retry_max_count" ] && \
				write_log 14 "Verify Proxy server '$1' failed after $retry_max_count retries"

			write_log 4 "Verify Proxy server '$1' failed - retry $error_count/$retry_max_count in $RETRY_SECONDS seconds"
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
	local __URL_HOST __DNS_HAS_AAAA=0

	[ $# -ne 1 ] && write_log 12 "Error in 'do_transfer()' - wrong number of parameters"

	# Use ip_network as default for bind_network if not separately specified
	[ -z "$bind_network" ] && [ "$ip_source" = "network" ] && [ "$ip_network" ] && bind_network="$ip_network"

	# Check if URL host supports IPv6 when use_ipv6 is enabled
	if [ "$use_ipv6" -eq 1 ]; then
		# Extract hostname from URL
		__URL_HOST=$(echo "$__URL" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|:.*$||')
		__DNS_HAS_AAAA=0
		
		# Try to resolve IPv6 address for the host
		if [ -n "$BIND_HOST" ]; then
			$BIND_HOST -t AAAA "$__URL_HOST" >"$DATFILE" 2>"$ERRFILE" && grep -q "has IPv6 address" "$DATFILE" && __DNS_HAS_AAAA=1
		elif [ -n "$KNOT_HOST" ]; then
			$KNOT_HOST -t AAAA "$__URL_HOST" >"$DATFILE" 2>"$ERRFILE" && grep -q "has IPv6 address" "$DATFILE" && __DNS_HAS_AAAA=1
		elif [ -n "$DRILL" ]; then
			$DRILL AAAA "$__URL_HOST" >"$DATFILE" 2>"$ERRFILE" && grep -E "^$__URL_HOST\.|^$__URL_HOST[[:space:]]" "$DATFILE" | grep -q "$IPV6_REGEX" && __DNS_HAS_AAAA=1
		elif [ -n "$HOSTIP" ]; then
			$HOSTIP -6 "$__URL_HOST" >"$DATFILE" 2>"$ERRFILE" && grep -q "$IPV6_REGEX" "$DATFILE" && __DNS_HAS_AAAA=1
		elif [ -n "$NSLOOKUP" ]; then
			$NSLOOKUP "$__URL_HOST" >"$DATFILE" 2>"$ERRFILE" && grep -q "$IPV6_REGEX" "$DATFILE" && __DNS_HAS_AAAA=1
		fi
		
		# If host doesn't support IPv6, we'll use IPv4 instead
		if [ $__DNS_HAS_AAAA -eq 0 ]; then
			write_log 6 "Update URL host '$__URL_HOST' does not support IPv6, using IPv4 for transfer"
		fi
	fi

	# lets prefer GNU Wget because it does all for us - IPv4/IPv6/HTTPS/PROXY/force IP version
	if [ -n "$WGET_SSL" ] && [ $USE_CURL -eq 0 ]; then 			# except global option use_curl is set to "1"
		__PROG="$WGET --hsts-file=/tmp/.wget-hsts -nv -t 1 -O $DATFILE -o $ERRFILE"	# non_verbose no_retry outfile errfile
		# force network/ip to use for communication
		if [ -n "$bind_network" ]; then
			local __BINDIP
			# set correct program to detect IP
			[ $use_ipv6 -eq 0 ] && __RUNPROG="network_get_ipaddr" || __RUNPROG="network_get_ipaddr6"
			eval "$__RUNPROG __BINDIP $bind_network" || \
				write_log 13 "Can not detect current IP using '$__RUNPROG $bind_network' - Error: '$?'"
			write_log 7 "Force communication via IP '$__BINDIP'"
			__PROG="$__PROG --bind-address=$__BINDIP"
		fi
		# forced IP version
		if [ "$force_ipversion" -eq 1 ]; then
			if [ "$use_ipv6" -eq 0 ]; then
				__PROG="$__PROG -4"
			elif [ $__DNS_HAS_AAAA -eq 1 ]; then
				__PROG="$__PROG -6"	# only force IPv6 if host supports it
			else
				__PROG="$__PROG -4"	# fallback to IPv4 if host doesn't support IPv6
			fi
		# unforced IP version	
		elif [ "$use_ipv6" -eq 1 ] && [ $__DNS_HAS_AAAA -eq 1 ]; then
			__PROG="$__PROG -6"	# use IPv6 if available
		fi
		# set certificate parameters
		if [ $use_https -eq 1 ]; then
			if [ "$cacert" = "IGNORE" ]; then	# idea from Ticket #15327 to ignore server cert
				__PROG="$__PROG --no-check-certificate"
			elif [ -f "$cacert" ]; then
				__PROG="$__PROG --ca-certificate=${cacert}"
			elif [ -d "$cacert" ]; then
				__PROG="$__PROG --ca-directory=${cacert}"
			elif [ -n "$cacert" ]; then		# it's not a file and not a directory but given
				write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		[ -z "$proxy" ] && __PROG="$__PROG --no-proxy"

		# user agent string if provided
		if [ -n "$user_agent" ]; then
			# replace single and double quotes
			user_agent=$(echo $user_agent | sed "s/'/ /g" | sed 's/"/ /g')
			__PROG="$__PROG --user-agent='$user_agent'"
		fi

		__RUNPROG="$__PROG '$__URL'"	# build final command
		__PROG="GNU Wget"		# reuse for error logging

	# 2nd choice is cURL IPv4/IPv6/HTTPS
	# libcurl might be compiled without Proxy or HTTPS Support
	elif [ -n "$CURL" ]; then
		__PROG="$CURL -RsS -o $DATFILE --stderr $ERRFILE"
		# check HTTPS support
		[ -z "$CURL_SSL" -a $use_https -eq 1 ] && \
			write_log 13 "cURL: libcurl compiled without https support"
		# force network/interface-device to use for communication
		if [ -n "$bind_network" ]; then
			local __DEVICE
			network_get_device __DEVICE $bind_network || \
				write_log 13 "Can not detect local device using 'network_get_device $bind_network' - Error: '$?'"
			write_log 7 "Force communication via device '$__DEVICE'"
			__PROG="$__PROG --interface $__DEVICE"
		fi
		# forced IP version
		if [ "$force_ipversion" -eq 1 ]; then
			if [ "$use_ipv6" -eq 0 ]; then
				__PROG="$__PROG -4"
			elif [ $__DNS_HAS_AAAA -eq 1 ]; then
				__PROG="$__PROG -6"	# only force IPv6 if host supports it
			else
				__PROG="$__PROG -4"	# fallback to IPv4 if host doesn't support IPv6
			fi
		# unforced IP version	
		elif [ "$use_ipv6" -eq 1 ] && [ $__DNS_HAS_AAAA -eq 1 ]; then
			__PROG="$__PROG -6"	# use IPv6 if available
		fi
		# set certificate parameters
		if [ $use_https -eq 1 ]; then
			if [ "$cacert" = "IGNORE" ]; then	# idea from Ticket #15327 to ignore server cert
				__PROG="$__PROG --insecure"	# but not empty better to use "IGNORE"
			elif [ -f "$cacert" ]; then
				__PROG="$__PROG --cacert $cacert"
			elif [ -d "$cacert" ]; then
				__PROG="$__PROG --capath $cacert"
			elif [ -n "$cacert" ]; then		# it's not a file and not a directory but given
				write_log 14 "No valid certificate(s) found at '$cacert' for HTTPS communication"
			fi
		fi
		# disable proxy if no set (there might be .wgetrc or .curlrc or wrong environment set)
		# or check if libcurl compiled with proxy support
		if [ -z "$proxy" ]; then
			__PROG="$__PROG --noproxy '*'"
		elif [ -z "$CURL_PROXY" ]; then
			# if libcurl has no proxy support and proxy should be used then force ERROR
			write_log 13 "cURL: libcurl compiled without Proxy support"
		fi

		__RUNPROG="$__PROG '$__URL'"	# build final command
		__PROG="cURL"			# reuse for error logging

	# uclient-fetch possibly with ssl support if /lib/libustream-ssl.so installed
	elif [ -n "$UCLIENT_FETCH" ]; then
		# UCLIENT_FETCH_SSL not empty then SSL support available
		UCLIENT_FETCH_SSL=$(find /lib /usr/lib -name libustream-ssl.so* 2>/dev/null)
		__PROG="$UCLIENT_FETCH -q -O $DATFILE"
		# force network/ip not supported
		[ -n "$__BINDIP" ] && \
			write_log 14 "uclient-fetch: FORCE binding to specific address not supported"
		# forced IP version
		if [ "$force_ipversion" -eq 1 ]; then
			if [ "$use_ipv6" -eq 0 ]; then
				__PROG="$__PROG -4"
			elif [ $__DNS_HAS_AAAA -eq 1 ]; then
				__PROG="$__PROG -6"	# only force IPv6 if host supports it
			else
				__PROG="$__PROG -4"	# fallback to IPv4 if host doesn't support IPv6
			fi
		# unforced IP version	
		elif [ "$use_ipv6" -eq 1 ] && [ $__DNS_HAS_AAAA -eq 1 ]; then
			__PROG="$__PROG -6"	# use IPv6 if available
		fi
		# https possibly not supported
		[ $use_https -eq 1 -a -z "$UCLIENT_FETCH_SSL" ] && \
			write_log 14 "uclient-fetch: no HTTPS support! Additional install one of ustream-ssl packages"
		# proxy support
		[ -z "$proxy" ] && __PROG="$__PROG -Y off" || __PROG="$__PROG -Y on"
		# https & certificates
		if [ $use_https -eq 1 ]; then
			if [ "$cacert" = "IGNORE" ]; then
				__PROG="$__PROG --no-check-certificate"
			elif [ -f "$cacert" ]; then
				__PROG="$__PROG --ca-certificate=$cacert"
			elif [ -n "$cacert" ]; then		# it's not a file; nothing else supported
				write_log 14 "No valid certificate file '$cacert' for HTTPS communication"
			fi
		fi
		__RUNPROG="$__PROG '$__URL' 2>$ERRFILE"		# build final command
		__PROG="uclient-fetch"				# reuse for error logging

	# Busybox Wget or any other wget in search $PATH (did not support neither IPv6 nor HTTPS)
	elif [ -n "$WGET" ]; then
		__PROG="$WGET -q -O $DATFILE"
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
		write_log 13 "Neither 'Wget' nor 'cURL' nor 'uclient-fetch' installed or executable"
	fi

	while : ; do
		write_log 7 "#> $__RUNPROG"
		eval $__RUNPROG			# DO transfer
		__ERR=$?			# save error code
		[ $__ERR -eq 0 ] && return 0	# no error leave
		[ -n "$LUCI_HELPER" ] && return 1	# no retry if called by LuCI helper script

		write_log 3 "$__PROG Error: '$__ERR'"
		write_log 7 "$(cat $ERRFILE)"		# report error

		[ $VERBOSE -gt 1 ] && {
			# VERBOSE > 1 then NO retry
			write_log 4 "Transfer failed - Verbose Mode: $VERBOSE - NO retry on error"
			return 1
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
	# we should never come here there must be a programming error
	write_log 12 "Error in 'do_transfer()' - program coding error"
}

send_update() {
	# $1	# IP to set at DDNS service provider
	local __IP

	[ $# -ne 1 ] && write_log 12 "Error calling 'send_update()' - wrong number of parameters"

	if [ $upd_privateip -eq 0 ]; then
		# verify given IP / no private IPv4's / no IPv6 addr starting with fxxx of with ":"
		[ $use_ipv6 -eq 0 ] && __IP=$(echo $1 | grep -v -E "(^0|^10\.|^100\.6[4-9]\.|^100\.[7-9][0-9]\.|^100\.1[0-1][0-9]\.|^100\.12[0-7]\.|^127|^169\.254|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-1]\.|^192\.168)")
		[ $use_ipv6 -eq 1 ] && __IP=$(echo $1 | grep "^[0-9a-eA-E]")
	else
		__IP=$(echo $1 | grep -m 1 -o "$IPV4_REGEX")		# valid IPv4 or
		[ -z "$__IP" ] && __IP=$(echo $1 | grep -m 1 -o "$IPV6_REGEX")	# IPv6
	fi
	[ -z "$__IP" ] && {
		write_log 3 "No or private or invalid IP '$1' given! Please check your configuration"
		return 127
	}

	if [ -n "$update_script" ]; then
		write_log 7 "parsing script '$update_script'"
		. $update_script
	else
		local __URL __ERR

		# do replaces in URL
		__URL=$(echo $update_url | sed -e "s#\[USERNAME\]#$URL_USER#g"	-e "s#\[PASSWORD\]#$URL_PASS#g" \
					       -e "s#\[PARAMENC\]#$URL_PENC#g"	-e "s#\[PARAMOPT\]#$param_opt#g" \
					       -e "s#\[DOMAIN\]#$domain#g"	-e "s#\[IP\]#$__IP#g")
		[ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')

		do_transfer "$__URL" || return 1

		write_log 7 "DDNS Provider answered:${N}$(cat $DATFILE)"

		[ -z "$UPD_ANSWER" ] && return 0	# not set then ignore

		grep -i -E "$UPD_ANSWER" $DATFILE >/dev/null 2>&1
		return $?	# "0" if found
	fi
}

get_current_ip () {
	# $1	Name of Variable to store current IP
	local ip_var data retries
	ip_var="$1"
	data=""
	retries=0

	# Validate input
	if [ -z "$ip_var" ]; then
		write_log 12 "get_current_ip: Missing variable name for IP storage"
		return 1
	fi

	write_log 7 "Detecting current IP using source: $ip_source"

	while :; do
		case "$ip_source" in
		"network")
			network_flush_cache
			[ -z "$ip_network" ] && { write_log 12 "get_current_ip: 'ip_network' not set for source 'network'"; return 2; }
			[ "$use_ipv6" -eq 0 ] && network_get_ipaddr  data "$ip_network" 2>/dev/null
			[ "$use_ipv6" -eq 1 ] && network_get_ipaddr6 data "$ip_network" 2>/dev/null
			[ -n "$data" ] && write_log 7 "Current IP '$data' detected on network '$ip_network'"
			;;
		"interface")
			[ -z "$ip_interface" ] && { write_log 12 "get_current_ip: 'ip_interface' not set for source 'interface'"; return 2; }
			# Test for alias interfaces e.g. "@wan6"; get the effective layer 3 interface
			[ "${ip_interface#*'@'}" != "$ip_interface" ] && network_get_device ip_interface "$ip_interface"
			write_log 7 "#> ip -o -br -js addr show dev '$ip_interface' scope global | $jsonfilter -e '@[0].addr_info[0].local'"
			[ "$use_ipv6" -eq 0 ] && data=$(ip -o -4 -br -js addr show dev "$ip_interface" scope global | "$jsonfilter" -e '@[0].addr_info[0].local')
			[ "$use_ipv6" -eq 1 ] && data=$(ip -o -6 -br -js addr show dev "$ip_interface" scope global | "$jsonfilter" -e '@[0].addr_info[0].local')
			[ -n "$data" ] && write_log 7 "Current IP '$data' detected on interface '$ip_interface'"
			;;
		"script")
			[ -z "$ip_script" ] && { write_log 12 "get_current_ip: 'ip_script' not set for source 'script'"; return 2; }
			write_log 7 "#> $ip_script >'$DATFILE' 2>'$ERRFILE'"
			data=$(eval "$ip_script" 2>"$ERRFILE")
			[ -n "$data" ] && write_log 7 "Current IP '$data' detected via script '$ip_script'"
			;;
		"web")
			[ -z "$ip_url" ] && { write_log 12 "get_current_ip: 'ip_url' not set for source 'web'"; return 2; }
			do_transfer "$ip_url"
			# bug: do_transfer does not output to DATFILE
			[ $use_ipv6 -eq 0 ] && data=$(grep -m 1 -o "$IPV4_REGEX" "$DATFILE")
			[ $use_ipv6 -eq 1 ] && data=$(grep -m 1 -o "$IPV6_REGEX" "$DATFILE")
			[ -n "$data" ] && write_log 7 "Current IP '$data' detected via web at '$ip_url'"
			;;
		*)
			write_log 12 "get_current_ip: Unsupported source '$ip_source'"
			return 3
			;;
		esac

		# Check if valid IP was found
		if [ -n "$data" ]; then
			eval "$1=\"$data\""
			write_log 7 "Detected IP: $data"
			return 0
		fi

		[ -n "$LUCI_HELPER" ] && return 1	# no retry if called by LuCI helper script
		[ $VERBOSE -gt 1 ] && write_log 4 "Verbose Mode: $VERBOSE - NO retry on error" && return 1;

		# Retry logic
		retries=$((retries + 1))
		if [ "$retry_max_count" -gt 0 ] && [ "$retries" -ge "$retry_max_count" ]; then
			write_log 14 "get_current_ip: Failed to detect IP after $retry_max_count retries"
			return 4
		fi

		write_log 4 "Retrying IP detection ($retries/$retry_max_count) in $RETRY_SECONDS seconds..."
		sleep "$RETRY_SECONDS" &
		PID_SLEEP=$!
		wait $PID_SLEEP	# enable trap-handler
		PID_SLEEP=0
	done
	write_log 12 "Error in 'get_current_ip()' - program coding error"
}

get_registered_ip() {
	# $1	Name of Variable to store public IP (REGISTERED_IP)
	# $2	(optional) if set, do not retry on error
	local __CNT=0	# error counter
	local __ERR=255
	local __REGEX  __PROG  __RUNPROG  __DATA  __IP
	# return codes
	# 1	no IP detected

	[ $# -lt 1 -o $# -gt 2 ] && write_log 12 "Error calling 'get_registered_ip()' - wrong number of parameters"
	[ $is_glue -eq 1 -a -z "$BIND_HOST" ] && write_log 14 "Lookup of glue records is only supported using BIND host"
	write_log 7 "Detect registered/public IP"

	# Ensure use_api_check defaults to 0 if not set
	[ -z "$use_api_check" ] && use_api_check=0

	# set correct regular expression
	[ $use_ipv6 -eq 0 ] && __REGEX="$IPV4_REGEX" || __REGEX="$IPV6_REGEX"

	# Attempt API check if enabled
	if [ "$use_api_check" -eq 1 ]; then
		local __SCRIPT
		if [ -n "$update_script" ]; then
			__SCRIPT="$update_script"
		elif [ "$service_name" != "custom" ] && [ -n "$service_name" ]; then
			local __SANITIZED
			__SANITIZED=$(echo "$service_name" | sed 's/[.-]/_/g')
			__SCRIPT="/usr/lib/ddns/update_${__SANITIZED}.sh"
		fi
		if [ -n "$__SCRIPT" ] && [ -f "$__SCRIPT" ]; then
			write_log 7 "Using provider API for registered IP check via '$__SCRIPT'"
			REGISTERED_IP=""
			GET_REGISTERED_IP=1
			. "$__SCRIPT"
			__ERR=$?
			unset GET_REGISTERED_IP
			if [ $__ERR -eq 0 ] && [ -n "$REGISTERED_IP" ]; then
				write_log 7 "Registered IP '$REGISTERED_IP' detected via provider API"
				[ -z "$IPFILE" ] || echo "$REGISTERED_IP" > "$IPFILE"
				eval "$1=\"$REGISTERED_IP\""
				return 0
			else
				write_log 4 "API check failed (error: '$__ERR') - falling back to DNS lookup"
			fi
		fi
	fi

	if [ -n "$BIND_HOST" ]; then
		__PROG="$BIND_HOST"
		[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -t A"  || __PROG="$__PROG -t AAAA"
		if [ $force_ipversion -eq 1 ]; then			# force IP version
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4"  || __PROG="$__PROG -6"
		fi
		[ $force_dnstcp -eq 1 ] && __PROG="$__PROG -T"	# force TCP
		[ $is_glue -eq 1 ] && __PROG="$__PROG -v" # use verbose output to get additional section

		__RUNPROG="$__PROG $lookup_host $dns_server >$DATFILE 2>$ERRFILE"
		__PROG="BIND host"
	elif [ -n "$KNOT_HOST" ]; then
		__PROG="$KNOT_HOST"
		[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -t A"  || __PROG="$__PROG -t AAAA"
		if [ $force_ipversion -eq 1 ]; then			# force IP version
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4"  || __PROG="$__PROG -6"
		fi
		[ $force_dnstcp -eq 1 ] && __PROG="$__PROG -T"	# force TCP

		__RUNPROG="$__PROG $lookup_host $dns_server >$DATFILE 2>$ERRFILE"
		__PROG="Knot host"
	elif [ -n "$DRILL" ]; then
		__PROG="$DRILL -V0"			# drill options name @server type
		if [ $force_ipversion -eq 1 ]; then			# force IP version
			[ $use_ipv6 -eq 0 ] && __PROG="$__PROG -4"  || __PROG="$__PROG -6"
		fi
		[ $force_dnstcp -eq 1 ] && __PROG="$__PROG -t" || __PROG="$__PROG -u"	# force TCP
		__PROG="$__PROG $lookup_host"
		[ -n "$dns_server" ] && __PROG="$__PROG @$dns_server"
		[ $use_ipv6 -eq 0 ] && __PROG="$__PROG A"  || __PROG="$__PROG AAAA"

		__RUNPROG="$__PROG >$DATFILE 2>$ERRFILE"
		__PROG="drill"
	elif [ -n "$HOSTIP" ]; then	# hostip package installed
		__PROG="$HOSTIP"
		[ $force_dnstcp -ne 0 ] && \
			write_log 14 "hostip - no support for 'DNS over TCP'"

		# is IP given as dns_server ?
		__IP=$(echo $dns_server | grep -m 1 -o "$IPV4_REGEX")
		[ -z "$__IP" ] && __IP=$(echo $dns_server | grep -m 1 -o "$IPV6_REGEX")

		# we got NO ip for dns_server, so build command
		[ -z "$__IP" -a -n "$dns_server" ] && {
			__IP="\`$HOSTIP"
			[ $use_ipv6 -eq 1 -a $force_ipversion -eq 1 ] && __IP="$__IP -6"
			__IP="$__IP $dns_server | grep -m 1 -o"
			[ $use_ipv6 -eq 1 -a $force_ipversion -eq 1 ] \
				&& __IP="$__IP '$IPV6_REGEX'" \
				|| __IP="$__IP '$IPV4_REGEX'"
			__IP="$__IP \`"
		}

		[ $use_ipv6 -eq 1 ] && __PROG="$__PROG -6"
		[ -n "$dns_server" ] && __PROG="$__PROG -r $__IP"
		__RUNPROG="$__PROG $lookup_host >$DATFILE 2>$ERRFILE"
		__PROG="hostip"
	elif [ -n "$NSLOOKUP" ]; then	# last use BusyBox nslookup
		NSLOOKUP_MUSL=$($(command -v nslookup) localhost 2>&1 | grep -F "(null)")	# not empty busybox compiled with musl
		[ $force_dnstcp -ne 0 ] && \
			write_log 14 "Busybox nslookup - no support for 'DNS over TCP'"
		[ -n "$NSLOOKUP_MUSL" -a -n "$dns_server" ] && \
			write_log 14 "Busybox compiled with musl - nslookup don't support the use of DNS Server"
		[ $force_ipversion -ne 0 ] && \
			write_log 5 "Busybox nslookup - no support to 'force IP Version' (ignored)"

		__RUNPROG="$NSLOOKUP $lookup_host $dns_server >$DATFILE 2>$ERRFILE"
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
			if [ -n "$BIND_HOST" -o -n "$KNOT_HOST" ]; then
				if [ $is_glue -eq 1 ]; then
					__DATA=$(cat $DATFILE | grep "^$lookup_host" | grep -om1 "$__REGEX" )
				else
					__DATA=$(cat $DATFILE | awk -F "address " '/has/ {print $2; exit}' )
				fi
			elif [ -n "$DRILL" ]; then
				__DATA=$(cat $DATFILE | awk '/^'"$lookup_host"'/ {print $5; exit}' )
			elif [ -n "$HOSTIP" ]; then
				__DATA=$(cat $DATFILE | grep -om1 "$__REGEX")
			elif [ -n "$NSLOOKUP" ]; then
				__DATA=$(cat $DATFILE | sed -ne "/^Name:/,\$ { s/^Address[0-9 ]\{0,\}: \($__REGEX\).*$/\\1/p }" )
			fi
			[ -n "$__DATA" ] && {
				write_log 7 "Registered IP '$__DATA' detected"
				[ -z "$IPFILE" ] || echo "$__DATA" > $IPFILE
				eval "$1=\"$__DATA\""	# valid data found
				return 0		# leave here
			}
			write_log 4 "NO valid IP found"
			__ERR=127
		fi
		[ -z "$IPFILE" ] || echo "" > $IPFILE

		[ -n "$LUCI_HELPER" ] && return $__ERR	# no retry if called by LuCI helper script
		[ -n "$2" ] && return $__ERR		# $2 is given -> no retry
		[ $VERBOSE -gt 1 ] && {
			# VERBOSE > 1 then NO retry
			write_log 4 "Get registered/public IP for '$lookup_host' failed - Verbose Mode: $VERBOSE - NO retry on error"
			return $__ERR
		}

		__CNT=$(( $__CNT + 1 ))	# increment error counter
		# if error count > retry_max_count leave here
		[ $retry_max_count -gt 0 -a $__CNT -gt $retry_max_count ] && \
			write_log 14 "Get registered/public IP for '$lookup_host' failed after $retry_max_count retries"

		write_log 4 "Get registered/public IP for '$lookup_host' failed - retry $__CNT/$retry_max_count in $RETRY_SECONDS seconds"
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
	[ $# -ne 1 ] && write_log 12 "Error calling 'get_uptime()' - requires exactly 1 argument."
	read -r uptime < /proc/uptime
	eval "$1=\"${uptime%%.*}\""
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
				write_log 5 "PID '$$' exit normal at $(eval $DATE_PROG)${N}"
			else
				write_log 4 "PID '$$' exit WITH ERROR '$__ERR' at $(eval $DATE_PROG)${N}"
			fi ;;
		 1)	write_log 6 "PID '$$' received 'SIGHUP' at $(eval $DATE_PROG)"
			# reload config via starting the script again
			/usr/lib/ddns/dynamic_dns_updater.sh -v "0" -S "$__SECTIONID" -- start || true
			exit 0 ;;	# and leave this one
		 2)	write_log 5 "PID '$$' terminated by 'SIGINT' at $(eval $DATE_PROG)${N}";;
		 3)	write_log 5 "PID '$$' terminated by 'SIGQUIT' at $(eval $DATE_PROG)${N}";;
		15)	write_log 5 "PID '$$' terminated by 'SIGTERM' at $(eval $DATE_PROG)${N}";;
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

expand_ipv6() {
	# Original written for bash by
	#.Author:  Florian Streibelt <florian@f-streibelt.de>
	# Date:    08.04.2012
	# License: Public Domain, but please be fair and
	#          attribute the original author(s) and provide
	#          a link to the original source for corrections:
	#.         https://github.com/mutax/IPv6-Address-checks

	# $1	IPv6 to expand
	# $2	name of variable to store expanded IPv6
	[ $# -ne 2 ] && write_log 12 "Error calling 'expand_ipv6()' - wrong number of parameters"

	INPUT="$(echo "$1" | tr 'A-F' 'a-f')"
	[ "$INPUT" = "::" ] && INPUT="::0"	# special case ::

	O=""

	while [ "$O" != "$INPUT" ]; do
		O="$INPUT"

		# fill all words with zeroes
		INPUT=$( echo "$INPUT" | sed	-e 's|:\([0-9a-f]\{3\}\):|:0\1:|g' \
						-e 's|:\([0-9a-f]\{3\}\)$|:0\1|g' \
						-e 's|^\([0-9a-f]\{3\}\):|0\1:|g' \
						-e 's|:\([0-9a-f]\{2\}\):|:00\1:|g' \
						-e 's|:\([0-9a-f]\{2\}\)$|:00\1|g' \
						-e 's|^\([0-9a-f]\{2\}\):|00\1:|g' \
						-e 's|:\([0-9a-f]\):|:000\1:|g' \
						-e 's|:\([0-9a-f]\)$|:000\1|g' \
						-e 's|^\([0-9a-f]\):|000\1:|g' )

	done

	# now expand the ::
	ZEROES=""

	echo "$INPUT" | grep -qs "::"
	if [ "$?" -eq 0 ]; then
		GRPS="$( echo "$INPUT" | sed  's|[0-9a-f]||g' | wc -m )"
		GRPS=$(( GRPS-1 ))		# remove carriage return
		MISSING=$(( 8-GRPS ))
		while [ $MISSING -gt 0 ]; do
			ZEROES="$ZEROES:0000"
			MISSING=$(( MISSING-1 ))
		done

		# be careful where to place the :
		INPUT=$( echo "$INPUT" | sed	-e 's|\(.\)::\(.\)|\1'$ZEROES':\2|g' \
						-e 's|\(.\)::$|\1'$ZEROES':0000|g' \
						-e 's|^::\(.\)|'$ZEROES':0000:\1|g;s|^:||g' )
	fi

	# an expanded address has 39 chars + CR
	if [ $(echo $INPUT | wc -m) != 40 ]; then
		write_log 4 "Error in 'expand_ipv6()' - invalid IPv6 found: '$1' expanded: '$INPUT'"
		eval "$2='invalid'"
		return 1
	fi

	# echo the fully expanded version of the address
	eval "$2=$INPUT"
	return 0
}
