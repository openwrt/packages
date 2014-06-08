#!/bin/sh
# /usr/lib/dynamic_dns/dynamic_dns_updater.sh
#
# Written by Eric Paul Bishop, Janary 2008
# Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# This script is (loosely) based on the one posted by exobyte in the forums here:
# http://forum.openwrt.org/viewtopic.php?id=14040
#

. /usr/lib/ddns/dynamic_dns_functions.sh


service_id=$1
if [ -z "$service_id" ]
then
	echo "ERRROR: You must specify a service id (the section name in the /etc/config/ddns file) to initialize dynamic DNS."
	return 1
fi

#default mode is verbose_mode, but easily turned off with second parameter
verbose_mode="1"
if [ -n "$2" ]
then
	verbose_mode="$2"
fi

###############################################################
# Leave this comment here, to clearly document variable names
# that are expected/possible
#
# Now use load_all_config_options to load config
# options, which is a much more flexible solution.
#
#
#config_load "ddns"
#
#config_get enabled $service_id enabled
#config_get service_name $service_id service_name
#config_get update_url $service_id update_url
#
#
#config_get username $service_id username
#config_get password $service_id password
#config_get domain $service_id domain
#
#
#config_get use_https $service_id use_https
#config_get use_syslog $service_id use_syslog
#config_get cacert $service_id cacert
#
#config_get ip_source $service_id ip_source
#config_get ip_interface $service_id ip_interface
#config_get ip_network $service_id ip_network
#config_get ip_url $service_id ip_url
#
#config_get force_interval $service_id force_interval
#config_get force_unit $service_id force_unit
#
#config_get check_interval $service_id check_interval
#config_get check_unit $service_id check_unit
#########################################################
load_all_config_options "ddns" "$service_id"


#some defaults
if [ -z "$check_interval" ]
then
	check_interval=600
fi

if [ -z "$retry_interval" ]
then
	retry_interval=60
fi

if [ -z "$check_unit" ]
then
	check_unit="seconds"
fi

if [ -z "$force_interval" ]
then
	force_interval=72
fi

if [ -z "$force_unit" ]
then
	force_unit="hours"
fi

if [ -z $use_syslog ]
then
	use_syslog=0
fi

if [ -z "$use_https" ]
then
	use_https=0
fi


#some constants

retrieve_prog="/usr/bin/wget -O - ";
if [ "x$use_https" = "x1" ]
then
	/usr/bin/wget --version 2>&1 |grep -q "\+ssl"
	if [ $? -eq 0 ]
	then
		if [ -f "$cacert" ]
		then
			retrieve_prog="${retrieve_prog}--ca-certificate=${cacert} "
		elif [ -d "$cacert" ]
		then
			retrieve_prog="${retrieve_prog}--ca-directory=${cacert} "
		fi
	else
		retrieve_prog="/usr/bin/curl "
		if [ -f "$cacert" ]
		then
			retrieve_prog="${retrieve_prog}--cacert $cacert "
		elif [ -d "$cacert" ]
		then
			retrieve_prog="${retrieve_prog}--capath $cacert "
		fi
	fi
fi


service_file="/usr/lib/ddns/services"

ip_regex="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"

NEWLINE_IFS='
'

#determine what update url we're using if the service_name is supplied
if [ -n "$service_name" ]
then
	#remove any lines not containing data, and then make sure fields are enclosed in double quotes
	quoted_services=$(cat $service_file |  grep "^[\t ]*[^#]" |  awk ' gsub("\x27", "\"") { if ($1~/^[^\"]*$/) $1="\""$1"\"" }; { if ( $NF~/^[^\"]*$/) $NF="\""$NF"\""  }; { print $0 }' )


	#echo "quoted_services = $quoted_services"
	OLD_IFS=$IFS
	IFS=$NEWLINE_IFS
	for service_line in $quoted_services
	do
		#grep out proper parts of data and use echo to remove quotes
		next_name=$(echo $service_line | grep -o "^[\t ]*\"[^\"]*\"" | xargs -r -n1 echo)
		next_url=$(echo $service_line | grep -o "\"[^\"]*\"[\t ]*$" | xargs -r -n1 echo)

		if [ "$next_name" = "$service_name" ]
		then
			update_url=$next_url
		fi
	done
	IFS=$OLD_IFS
fi

if [ "x$use_https" = x1 ]
then
	update_url=$(echo $update_url | sed -e 's/^http:/https:/')
fi

verbose_echo "update_url=$update_url"

#if this service isn't enabled then quit
if [ "$enabled" != "1" ] 
then
	return 0
fi

#compute update interval in seconds
case "$force_unit" in
	"days" )
		force_interval_seconds=$(($force_interval*60*60*24))
		;;
	"hours" )
		force_interval_seconds=$(($force_interval*60*60))
		;;
	"minutes" )
		force_interval_seconds=$(($force_interval*60))
		;;
	"seconds" )
		force_interval_seconds=$force_interval
		;;
	* )
		#default is hours
		force_interval_seconds=$(($force_interval*60*60))
		;;
esac


#compute check interval in seconds
case "$check_unit" in
	"days" )
		check_interval_seconds=$(($check_interval*60*60*24))
		;;
	"hours" )
		check_interval_seconds=$(($check_interval*60*60))
		;;
	"minutes" )
		check_interval_seconds=$(($check_interval*60))
		;;
	"seconds" )
		check_interval_seconds=$check_interval
		;;
	* )
		#default is seconds
		check_interval_seconds=$check_interval
		;;
esac


#compute retry interval in seconds
case "$retry_unit" in
	"days" )
		retry_interval_seconds=$(($retry_interval*60*60*24))
		;;
	"hours" )
		retry_interval_seconds=$(($retry_interval*60*60))
		;;
	"minutes" )
		retry_interval_seconds=$(($retry_interval*60))
		;;
	"seconds" )
		retry_interval_seconds=$retry_interval
		;;
	* )
		#default is seconds
		retry_interval_seconds=$retry_interval
		;;
esac


verbose_echo "force seconds = $force_interval_seconds"
verbose_echo "check seconds = $check_interval_seconds"

#kill old process if it exists & set new pid file
if [ -d /var/run/dynamic_dns ]
then
	#if process is already running, stop it
	if [ -e "/var/run/dynamic_dns/$service_id.pid" ]
	then
		old_pid=$(cat /var/run/dynamic_dns/$service_id.pid)
		test_match=$(ps | grep "^[\t ]*$old_pid")
		verbose_echo "old process id (if it exists) = \"$test_match\""
		if [ -n  "$test_match" ]
		then
			kill $old_pid
		fi
	fi

else
	#make dir since it doesn't exist
	mkdir /var/run/dynamic_dns
fi
echo $$ > /var/run/dynamic_dns/$service_id.pid




#determine when the last update was
current_time=$(monotonic_time)
last_update=$(( $current_time - (2*$force_interval_seconds) ))
if [ -e "/var/run/dynamic_dns/$service_id.update" ]
then
	last_update=$(cat /var/run/dynamic_dns/$service_id.update)
fi
time_since_update=$(($current_time - $last_update))


human_time_since_update=$(( $time_since_update / ( 60 * 60 ) ))
verbose_echo "time_since_update = $human_time_since_update hours"



#do update and then loop endlessly, checking ip every check_interval and forcing an updating once every force_interval

while [ true ]
do
	registered_ip=$(echo $(nslookup "$domain" 2>/dev/null) |  grep -o "Name:.*" | grep -o "$ip_regex")
	current_ip=$(get_current_ip)


	current_time=$(monotonic_time)
	time_since_update=$(($current_time - $last_update))

	syslog_echo "Running IP check ..."
	verbose_echo "Running IP check..."
	verbose_echo "current system ip = $current_ip"
	verbose_echo "registered domain ip = $registered_ip"


	if [ "$current_ip" != "$registered_ip" ]  || [ $force_interval_seconds -lt $time_since_update ]
	then
		verbose_echo "update necessary, performing update ..."

		#do replacement
		final_url=$update_url
		for option_var in $ALL_OPTION_VARIABLES
		do
			if [ "$option_var" != "update_url" ]
			then
				replace_name=$(echo "\[$option_var\]" | tr 'a-z' 'A-Z')
				replace_value=$(eval echo "\$$option_var")
				replace_value=$(echo $replace_value | sed -f /usr/lib/ddns/url_escape.sed)
				final_url=$(echo $final_url | sed s^"$replace_name"^"$replace_value"^g )
			fi
		done
		final_url=$(echo $final_url | sed s^"\[HTTPAUTH\]"^"${username//^/\\^}${password:+:${password//^/\\^}}"^g )
		final_url=$(echo $final_url | sed s/"\[IP\]"/"$current_ip"/g )


		verbose_echo "updating with url=\"$final_url\""

		#here we actually connect, and perform the update
		update_output=$( $retrieve_prog "$final_url" )
		if [ $? -gt 0 ]
		then
			syslog_echo "update failed, retrying in $retry_interval_seconds seconds"
			verbose_echo "update failed"
			sleep $retry_interval_seconds
			continue
		fi
		syslog_echo "Update successful"
		verbose_echo "Update Output:"
		verbose_echo "$update_output"
		verbose_echo ""

		#save the time of the update
		current_time=$(monotonic_time)
		last_update=$current_time
		time_since_update='0'
		registered_ip=$current_ip

		human_time=$(date)
		verbose_echo "update complete, time is: $human_time"

		echo "$last_update" > "/var/run/dynamic_dns/$service_id.update"
	else
		human_time=$(date)
		human_time_since_update=$(( $time_since_update / ( 60 * 60 ) ))
		verbose_echo "update unnecessary"
		verbose_echo "time since last update = $human_time_since_update hours"
		verbose_echo "the time is now $human_time"
	fi

	#sleep for 10 minutes, then re-check ip && time since last update
	sleep $check_interval_seconds
done

#should never get here since we're a daemon, but I'll throw it in anyway
return 0




