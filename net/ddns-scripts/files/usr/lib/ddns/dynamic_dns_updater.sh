#!/bin/sh
# /usr/lib/ddns/dynamic_dns_updater.sh
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
# - DNS Server to retrieve registered IP including TCP transport
# - Proxy Server to send out updates
# - force_interval=0 to run once
# - the usage of BIND's host command instead of BusyBox's nslookup if installed
# - extended Verbose Mode and log file support for better error detection 
#
# variables in small chars are read from /etc/config/ddns
# variables in big chars are defined inside these scripts as global vars
# variables in big chars beginning with "__" are local defined inside functions only
#set -vx  	#script debugger

[ $# -lt 1 -o -n "${2//[0-3]/}" -o ${#2} -gt 1 ] && {
	echo -e "\n  USAGE:"
	echo -e "  $0 [SECTION] [VERBOSE_MODE]\n"
	echo    "  [SECTION]      - service section as defined in /etc/config/ddns"
	echo    "  [VERBOSE_MODE] - '0' NO output to console"
	echo    "                   '1' output to console"
	echo    "                   '2' output to console AND logfile"
	echo    "                       + run once WITHOUT retry on error"
	echo    "                   '3' output to console AND logfile"
	echo    "                       + run once WITHOUT retry on error"
	echo -e "                       + NOT sending update to DDNS service\n"
	exit 1
}

. /usr/lib/ddns/dynamic_dns_functions.sh	# global vars are also defined here

SECTION_ID="$1"
VERBOSE_MODE=${2:-1}	#default mode is log to console

# set file names
PIDFILE="$RUNDIR/$SECTION_ID.pid"	# Process ID file
UPDFILE="$RUNDIR/$SECTION_ID.update"	# last update successful send (system uptime)
LOGFILE="$LOGDIR/$SECTION_ID.log"	# log file

# VERBOSE_MODE > 1 delete logfile if exist to create an empty one
# only with this data of this run for easier diagnostic
# new one created by verbose_echo function
[ $VERBOSE_MODE -gt 1 -a -f $LOGFILE ] && rm -f $LOGFILE

################################################################################
# Leave this comment here, to clearly document variable names that are expected/possible
# Use load_all_config_options to load config options, which is a much more flexible solution.
#
# config_load "ddns"
# config_get <variable> $SECTION_ID <option]>
#
# defined options (also used as variable):
# 
# enable	self-explanatory
# interface 	network interface used by hotplug.d i.e. 'wan' or 'wan6'
#
# service_name	Which DDNS service do you use or "custom"
# update_url	URL to use to update your "custom" DDNS service
# update_script SCRIPT to use to update your "custom" DDNS service
#
# domain 	Your DNS name / replace [DOMAIN] in update_url
# username 	Username of your DDNS service account / replace [USERNAME] in update_url
# password 	Password of your DDNS service account / replace [PASSWORD] in update_url
#
# use_https	use HTTPS to update DDNS service
# cacert	file or directory where HTTPS can find certificates to verify server; 'IGNORE' ignore check of server certificate
#
# use_syslog	log activity to syslog
#
# ip_source	source to detect current local IP ('network' or 'web' or 'script' or 'interface')
# ip_network	local defined network to read IP from i.e. 'wan' or 'wan6'
# ip_url	URL to read local address from i.e. http://checkip.dyndns.com/ or http://checkipv6.dyndns.com/
# ip_script	full path and name of your script to detect local IP
# ip_interface	physical interface to use for detecting 
#
# check_interval	check for changes every  !!! checks below 10 minutes make no sense because the Internet 
# check_unit		'days' 'hours' 'minutes' !!! needs about 5-10 minutes to sync an IP-change for an DNS entry
#
# force_interval	force to send an update to your service if no change was detected
# force_unit		'days' 'hours' 'minutes' !!! force_interval="0" runs this script once for use i.e. with cron
#
# retry_interval	if error was detected retry in
# retry_unit		'days' 'hours' 'minutes' 'seconds'
# retry_count 		#NEW# number of retries before scripts stops
#
# use_ipv6		#NEW# detecting/sending IPv6 address
# force_ipversion	#NEW# force usage of IPv4 or IPv6 for the whole detection and update communication
# dns_server		#NEW# using a non default dns server to get Registered IP from Internet
# force_dnstcp		#NEW# force communication with DNS server via TCP instead of default UDP
# proxy			#NEW# using a proxy for communication !!! ALSO used to detect local IP via web => return proxy's IP !!!
# use_logfile		#NEW# self-explanatory "/var/log/ddns/$SECTION_ID.log"
#
# some functionality needs 
# - GNU Wget or cURL installed for sending updates to DDNS service
# - BIND host installed to detect Registered IP
#
################################################################################

# verify and load SECTION_ID is exists
[ "$(uci_get ddns $SECTION_ID)" != "service" ] && {
	[ $VERBOSE_MODE -le 1 ] && VERBOSE_MODE=2	# force console out and logfile output
	[ -f $LOGFILE ] && rm -f $LOGFILE		# clear logfile before first entry
	verbose_echo "\n ************** =: ************** ************** **************"
	verbose_echo "       STARTED =: PID '$$' at $(eval $DATE_PROG)"
	verbose_echo "    UCI CONFIG =:\n$(uci -q show ddns | grep '=service' | sort)"
	critical_error "Service '$SECTION_ID' not defined"
}
load_all_config_options "ddns" "$SECTION_ID"

verbose_echo "\n ************** =: ************** ************** **************"
verbose_echo "       STARTED =: PID '$$' at $(eval $DATE_PROG)"
case $VERBOSE_MODE in
	0) verbose_echo "  verbose mode =: '0' - run normal, NO console output";;
	1) verbose_echo "  verbose mode =: '1' - run normal, console mode";;
	2) verbose_echo "  verbose mode =: '2' - run once, NO retry on error";;
	3) verbose_echo "  verbose mode =: '3' - run once, NO retry on error, NOT sending update";;
	*) critical_error "ERROR detecting VERBOSE_MODE '$VERBOSE_MODE'"
esac
verbose_echo "    UCI CONFIG =:\n$(uci -q show ddns.$SECTION_ID | sort)"

# set defaults if not defined
[ -z "$enabled" ]	  && enabled=0
[ -z "$retry_count" ]	  && retry_count=5
[ -z "$use_syslog" ]      && use_syslog=0	# not use syslog
[ -z "$use_https" ]       && use_https=0	# not use https
[ -z "$use_logfile" ]     && use_logfile=1	# NEW - use logfile by default
[ -z "$use_ipv6" ]	  && use_ipv6=0		# NEW - use IPv4 by default
[ -z "$force_ipversion" ] && force_ipversion=0	# NEW - default let system decide
[ -z "$force_dnstcp" ]	  && force_dnstcp=0	# NEW - default UDP
[ -z "$ip_source" ]	  && ip_source="network"
[ "$ip_source" = "network" -a -z "$ip_network" -a $use_ipv6 -eq 0 ] && ip_network="wan"  # IPv4: default wan
[ "$ip_source" = "network" -a -z "$ip_network" -a $use_ipv6 -eq 1 ] && ip_network="wan6" # IPv6: default wan6
[ "$ip_source" = "web" -a -z "$ip_url" -a $use_ipv6 -eq 0 ] && ip_url="http://checkip.dyndns.com"
[ "$ip_source" = "web" -a -z "$ip_url" -a $use_ipv6 -eq 1 ] && ip_url="http://checkipv6.dyndns.com"
[ "$ip_source" = "interface" -a -z "$ip_interface" ] && ip_interface="eth1"

# check configuration and enabled state
[ -z "$domain" -o -z "$username" -o -z "$password" ] && critical_error "Service Configuration not correctly configured"
[ $enabled -eq 0 ] && critical_error "Service Configuration is disabled"

# verify script if configured and executable
if [ "$ip_source" = "script" ]; then
	[ -z "$ip_script" ] && critical_error "No script defined to detect local IP"
	[ -x "$ip_script" ] || critical_error "Script to detect local IP not found or not executable"
fi

# compute update interval in seconds
get_seconds CHECK_SECONDS ${check_interval:-10} ${check_unit:-"minutes"} # default 10 min
get_seconds FORCE_SECONDS ${force_interval:-72} ${force_unit:-"hours"}	 # default 3 days
get_seconds RETRY_SECONDS ${retry_interval:-60} ${retry_unit:-"seconds"} # default 60 sec
verbose_echo "check interval =: $CHECK_SECONDS seconds"
verbose_echo "force interval =: $FORCE_SECONDS seconds"
verbose_echo "retry interval =: $RETRY_SECONDS seconds"
verbose_echo " retry counter =: $retry_count times"

# determine what update url we're using if a service_name is supplied
# otherwise update_url is set inside configuration (custom service)
# or update_script is set inside configuration (custom update script)
[ -n "$service_name" ] && get_service_data update_url update_script
[ -z "$update_url" -a -z "$update_script" ] && critical_error "no update_url found/defined or no update_script found/defined"
[ -n "$update_script" -a ! -f "$update_script" ] && critical_error "custom update_script not found"

#kill old process if it exists & set new pid file
if [ -d $RUNDIR ]; then
	#if process is already running, stop it
	if [ -e "$PIDFILE" ]; then
		OLD_PID=$(cat $PIDFILE)
		ps | grep -q "^[\t ]*$OLD_PID" && {
			verbose_echo "   old process =: PID '$OLD_PID'"
			kill $OLD_PID
		} || verbose_echo "old process id =: PID 'none'"
	else
		verbose_echo "old process id =: PID 'none'"
	fi
else
	#make dir since it doesn't exist
	mkdir -p $RUNDIR
	verbose_echo "old process id =: PID 'none'"
fi
echo $$ > $PIDFILE

# determine when the last update was
# the following lines should prevent multiple updates if hotplug fires multiple startups 
# as described in Ticket #7820, but did not function if never an update take place
# i.e. after a reboot (/var is linked to /tmp)
# using uptime as reference because date might not be updated via NTP client 
get_uptime CURR_TIME
[ -e "$UPDFILE" ] && {
	LAST_TIME=$(cat $UPDFILE)
	# check also LAST > CURR because link of /var/run to /tmp might be removed
	# i.e. boxes with larger filesystems
	[ -z "$LAST_TIME" ] && LAST_TIME=0
	[ $LAST_TIME -gt $CURR_TIME ] && LAST_TIME=0
}
if [ $LAST_TIME -eq 0 ]; then
	verbose_echo "   last update =: never"
else
	EPOCH_TIME=$(( $(date +%s) - CURR_TIME + LAST_TIME ))
	EPOCH_TIME="date -d @$EPOCH_TIME +'$DATE_FORMAT'"
	verbose_echo "   last update =: $(eval $EPOCH_TIME)"
fi

# we need time here because hotplug.d is fired by netifd
# but IP addresses are not set by DHCP/DHCPv6 etc.
verbose_echo "       waiting =: 10 seconds for interfaces to fully come up"
sleep 10

# verify DNS server: 
# do with retry's because there might be configurations
# not directly could connect to outside dns when interface is already up
ERR_VERIFY=0	# reset err counter
while [ -n "$dns_server" ]; do
	[ $ERR_VERIFY -eq 0 ] && verbose_echo "******* VERIFY =: DNS server '$dns_server'"
	verify_dns "$dns_server"
	ERR_LAST=$?			# save return value
	[ $ERR_LAST -eq 0 ] && break	# everything ok leave while loop
	ERR_VERIFY=$(( $ERR_VERIFY + 1 ))
	# if error count > retry_count leave here with critical error
	[ $ERR_VERIFY -gt $retry_count ] && {
		case $ERR_LAST in
			2)	critical_error "Invalid DNS server Error: '2' - nslookup can not resolve host";;
			3)	critical_error "Invalid DNS server Error: '3' - nc (netcat) can not connect";;
			*)	critical_error "Invalid DNS server Error: '$ERR_LAST' - unspecific error";;
		esac
	}
	case $ERR_LAST in
		2)	syslog_err "Invalid DNS server Error: '2' - nslookup can not resolve host - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
		3)	syslog_err "Invalid DNS server Error: '3' - nc (netcat) can not connect - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
		*)	syslog_err "Invalid DNS server Error: '$ERR_LAST' - unspecific error - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
	esac
	[ $VERBOSE_MODE -gt 1 ] && {
		# VERBOSE_MODE > 1 then NO retry
		verbose_echo "\n!!!!!!!!! ERROR =: Verbose Mode - NO retry\n"
		break
	}
	verbose_echo "******** RETRY =: DNS server '$dns_server' - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds"
	sleep $RETRY_SECONDS
done

# verify Proxy server and set environment
# do with retry's because there might be configurations
# not directly could connect to outside dns when interface is already up
ERR_VERIFY=0	# reset err counter
[ -n "$proxy" ] && {
	[ $ERR_VERIFY -eq 0 ] && verbose_echo "******* VERIFY =: Proxy server 'http://$proxy'"
	verify_proxy "$proxy"
	ERR_LAST=$?			# save return value
	[ $ERR_LAST -eq 0 ] && {
		# everything ok set proxy and leave while loop
		export HTTP_PROXY="http://$proxy"
		export HTTPS_PROXY="http://$proxy"
		export http_proxy="http://$proxy"
		export https_proxy="http://$proxy"
		break
	}
	ERR_VERIFY=$(( $ERR_VERIFY + 1 ))
	# if error count > retry_count leave here with critical error
	[ $ERR_VERIFY -gt $retry_count ] && {
		case $ERR_LAST in
			2)	critical_error "Invalid Proxy server Error '2' - nslookup can not resolve host";;
			3)	critical_error "Invalid Proxy server Error '3' - nc (netcat) can not connect";;
			*)	critical_error "Invalid Proxy server Error '$ERR_LAST' - unspecific error";;
		esac
	}
	case $ERR_LAST in
		2)	syslog_err "Invalid Proxy server Error '2' - nslookup can not resolve host - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
		3)	syslog_err "Invalid Proxy server Error '3' - nc (netcat) can not connect - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
		*)	syslog_err "Invalid Proxy server Error '$ERR_LAST' - unspecific error - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds\n";;
	esac
	[ $VERBOSE_MODE -gt 1 ] && {
		# VERBOSE_MODE > 1 then NO retry
		verbose_echo "\n!!!!!!!!! ERROR =: Verbose Mode - NO retry\n"
		break
	}
	verbose_echo "******** RETRY =: Proxy server 'http://$proxy' - retry $ERR_VERIFY/$retry_count in $RETRY_SECONDS seconds"
	sleep $RETRY_SECONDS
}

# let's check if there is already an IP registered at the web
# but ignore errors if not
verbose_echo "******* DETECT =: Registered IP"
get_registered_ip REGISTERED_IP

# loop endlessly, checking ip every check_interval and forcing an updating once every force_interval
# NEW: ### Luci Ticket 538
# a "force_interval" of "0" will run this script only once
# the update is only done once when an interface goes up
# or you run /etc/init.d/ddns start or you can use a cron job
# it will force an update without check when lastupdate happen
# but it will verify after "check_interval" if update is seen in the web 
# and retries on error retry_count times
# CHANGES: ### Ticket 16363
# modified nslookup / sed / grep to detect registered ip
# NEW: ### Ticket 7820
# modified nslookup to support non standard dns_server (needs to be defined in /etc/config/ddns)
# support for BIND host command.
# Wait for interface to fully come up, before the first update is done
verbose_echo "*** START LOOP =: $(eval $DATE_PROG)"
# we run NOT once
[ $FORCE_SECONDS -gt 0 -o $VERBOSE_MODE -le 1 ] && syslog_info "Starting main loop"

while : ; do

	# read local IP
	verbose_echo "******* DETECT =: Local IP"
	get_local_ip LOCAL_IP
	ERR_LAST=$?	# save return value
	# Error in function
	[ $ERR_LAST -gt 0 ] && {
		if [ $VERBOSE_MODE -le 1 ]; then	# VERBOSE_MODE <= 1 then retry
			# we can't read local IP
			ERR_LOCAL_IP=$(( $ERR_LOCAL_IP + 1 ))
			[ $ERR_LOCAL_IP -gt $retry_count ] && critical_error "Can not detect local IP"
			verbose_echo "\n!!!!!!!!! ERROR =: detecting local IP - retry $ERR_LOCAL_IP/$retry_count in $RETRY_SECONDS seconds\n"
			syslog_err "Error detecting local IP - retry $ERR_LOCAL_IP/$retry_count in $RETRY_SECONDS seconds"
			sleep $RETRY_SECONDS
			continue	# jump back to the beginning of while loop
		else
			verbose_echo "\n!!!!!!!!! ERROR =: detecting local IP - NO retry\n"
		fi
	}
	ERR_LOCAL_IP=0	# reset err counter

	# prepare update
	# never updated or forced immediate then NEXT_TIME = 0 
	[ $FORCE_SECONDS -eq 0 -o $LAST_TIME -eq 0 ] \
		&& NEXT_TIME=0 \
		|| NEXT_TIME=$(( $LAST_TIME + $FORCE_SECONDS ))
	# get current uptime
	get_uptime CURR_TIME
	
	# send update when current time > next time or local ip different from registered ip (as loop on error)
	ERR_SEND=0
	while [ $CURR_TIME -ge $NEXT_TIME -o "$LOCAL_IP" != "$REGISTERED_IP" ]; do
		if [ $VERBOSE_MODE -gt 2 ]; then
			verbose_echo "  VERBOSE MODE =: NO UPDATE send to DDNS provider"
		elif [ "$LOCAL_IP" != "$REGISTERED_IP" ]; then
			verbose_echo "******* UPDATE =: LOCAL: '$LOCAL_IP' <> REGISTERED: '$REGISTERED_IP'"
		else
			verbose_echo "******* FORCED =: LOCAL: '$LOCAL_IP' == REGISTERED: '$REGISTERED_IP'"
		fi
		# only send if VERBOSE_MODE < 3
		ERR_LAST=0
		[ $VERBOSE_MODE -lt 3 ] && {
			send_update "$LOCAL_IP" 
			ERR_LAST=$?	# save return value
		}

		# Error in function 
		if [ $ERR_LAST -gt 0 ]; then
			if [ $VERBOSE_MODE -le 1 ]; then	# VERBOSE_MODE <=1 then retry
				# error sending local IP
				ERR_SEND=$(( $ERR_SEND + 1 ))
				[ $ERR_SEND -gt $retry_count ] && critical_error "can not send update to DDNS Provider"
				verbose_echo "\n!!!!!!!!! ERROR =: sending update - retry $ERR_SEND/$retry_count in $RETRY_SECONDS seconds\n"
				syslog_err "Error sending update - retry $ERR_SEND/$retry_count in $RETRY_SECONDS seconds"
				sleep $RETRY_SECONDS
				continue # re-loop
			else
				verbose_echo "\n!!!!!!!!! ERROR =: sending update to DDNS service - NO retry\n"
				break
			fi
		else
			# we send data so save "last time"
			get_uptime LAST_TIME
			echo $LAST_TIME > $UPDFILE	# save LASTTIME to file
			[ "$LOCAL_IP" != "$REGISTERED_IP" ] \
				&& syslog_notice "Changed IP: '$LOCAL_IP' successfully send" \
				|| syslog_notice "Forced Update: IP: '$LOCAL_IP' successfully send"
			break # leave while
		fi
	done

	# now we wait for check interval before testing if update was recognized
	# only sleep if VERBOSE_MODE <= 2 because nothing send so do not wait
	[ $VERBOSE_MODE -le 2 ] && {
		verbose_echo "****** WAITING =: $CHECK_SECONDS seconds (Check Interval) before continue"
		sleep $CHECK_SECONDS
	} || verbose_echo "  VERBOSE MODE =: NO WAITING for Check Interval\n"

	# read at DDNS service registered IP (in loop on error)
	REGISTERED_IP=""
	ERR_REG_IP=0
	while : ; do
		verbose_echo "******* DETECT =: Registered IP"
		get_registered_ip REGISTERED_IP
		ERR_LAST=$?	# save return value

		# No Error in function we leave while loop
		[ $ERR_LAST -eq 0  ] && break

		# we can't read Registered IP
		if [ $VERBOSE_MODE -le 1 ]; then	# VERBOSE_MODE <=1 then retry
			ERR_REG_IP=$(( $ERR_REG_IP + 1 ))
			[ $ERR_REG_IP -gt $retry_count ] && critical_error "can not detect registered local IP"
			verbose_echo "\n!!!!!!!!! ERROR =: detecting Registered IP - retry $ERR_REG_IP/$retry_count in $RETRY_SECONDS seconds\n"
			syslog_err "Error detecting Registered IP - retry $ERR_REG_IP/$retry_count in $RETRY_SECONDS seconds"
			sleep $RETRY_SECONDS
		else
			verbose_echo "\n!!!!!!!!! ERROR =: detecting Registered IP - NO retry\n"
			break	# leave while loop
		fi
	done

	# IP's are still different
	if [ "$LOCAL_IP" != "$REGISTERED_IP" ]; then
		if [ $VERBOSE_MODE -le 1 ]; then	# VERBOSE_MODE <=1 then retry
			ERR_UPDATE=$(( $ERR_UPDATE + 1 ))
			[ $ERR_UPDATE -gt $retry_count ] && critical_error "Registered IP <> Local IP - LocalIP: '$LOCAL_IP' - RegisteredIP: '$REGISTERED_IP'"
			verbose_echo "\n!!!!!!!!! ERROR =: Registered IP <> Local IP - starting retry $ERR_UPDATE/$retry_count\n"
			syslog_warn "Warning: Registered IP <> Local IP - starting retry $ERR_UPDATE/$retry_count"
			continue # loop to beginning
		else
			verbose_echo "\n!!!!!!!!! ERROR =: Registered IP <> Local IP - LocalIP: '$LOCAL_IP' - RegisteredIP: '$REGISTERED_IP' - NO retry\n"
		fi
	fi		

	# we checked successful the last update
	ERR_UPDATE=0			# reset error counter

	# force_update=0 or VERBOSE_MODE > 1 - leave the main loop
	[ $FORCE_SECONDS -eq 0 -o $VERBOSE_MODE -gt 1 ] && {
		verbose_echo "****** LEAVING =: $(eval $DATE_PROG)"
		syslog_info "Leaving"
		break
	}
	verbose_echo "********* LOOP =: $(eval $DATE_PROG)"
	syslog_info "Rerun IP check"
done

verbose_echo "****** STOPPED =: PID '$$' at $(eval $DATE_PROG)\n"
syslog_info "Done"

exit 0
