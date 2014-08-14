#!/bin/sh 

mode="$1"

shutdown_now() {
	local forcedelay="$1"

	reboot &

	[ "$forcedelay" -ge 1 ] && {
		sleep "$forcedelay"

		echo b > /proc/sysrq-trigger # Will immediately reboot the system without syncing or unmounting your disks.
	}
}

watchcat_allways() {
	local period="$1"; local forcedelay="$2"

	sleep "$period" && shutdown_now "$forcedelay"
}

watchcat_ping() {
	local period="$1"; local forcedelay="$2"; local pinghosts="$3"; local pingperiod="$4"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"
	time_lastcheck="$time_now"
	time_lastcheck_withinternet="$time_now"

	while true
	do
		# account for the time ping took to return. With a ping time of 5s, ping might take more than that, so it is important to avoid even more delay.
		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_diff="$((time_now-time_lastcheck))"

		[ "$time_diff" -lt "$pingperiod" ] && {
			sleep_time="$((pingperiod-time_diff))"
			sleep "$sleep_time"
		}

		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_lastcheck="$time_now"

		for host in "$pinghosts"
		do
			if ping -c 1 "$host" &> /dev/null 
			then 
				time_lastcheck_withinternet="$time_now"
			else
				time_diff="$((time_now-time_lastcheck_withinternet))"
				logger -p daemon.info -t "watchcat[$$]" "no internet connectivity for $time_diff seconds. Reseting when reaching $period"       
			fi
		done

		time_diff="$((time_now-time_lastcheck_withinternet))"
		[ "$time_diff" -ge "$period" ] && shutdown_now "$forcedelay"

	done
}

	if [ "$mode" = "allways" ]
	then
		watchcat_allways "$2" "$3"
	else
		watchcat_ping "$2" "$3" "$4" "$5"
	fi
