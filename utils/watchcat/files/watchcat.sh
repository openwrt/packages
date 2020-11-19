#!/bin/sh
#
# Copyright (C) 2010 segal.di.ubi.pt
#
# This is free software, licensed under the GNU General Public License v2.
#

reboot_now() {
	reboot &

	[ "$1" -ge 1 ] && {
		sleep "$1"
		echo 1 > /proc/sys/kernel/sysrq
		echo b > /proc/sysrq-trigger # Will immediately reboot the system without syncing or unmounting your disks.
	}
}

watchcat_always() {
	local period="$1"; local forcedelay="$2"

	sleep "$period" && reboot_now "$forcedelay"
}

watchcat_ping() {
	local period="$1"; local forcedelay="$2"; local pinghosts="$3"; local pingperiod="$4"; local nopingtime="$5"

	local time_now="$(cat /proc/uptime)";time_now="${time_now%%.*}"

	[ "$time_now" -lt "$nopingtime" ] && sleep "$((nopingtime-time_now))"

	time_now="$(cat /proc/uptime)";time_now="${time_now%%.*}"
	local time_lastcheck="$time_now"
	local time_lastcheck_withinternet="$time_now"

	while true
	do
		# account for the time ping took to return. With a ping time of 5s, ping might take more than that, so it is important to avoid even more delay.
		time_now="$(cat /proc/uptime)"; time_now="${time_now%%.*}"
		local time_diff="$((time_now-time_lastcheck))"

		[ "$time_diff" -lt "$pingperiod" ] && sleep "$((pingperiod-time_diff))"

		time_now="$(cat /proc/uptime)";time_now="${time_now%%.*}"
		time_lastcheck="$time_now"

		for host in $pinghosts
		do
			if ping -c 1 "$host" &> /dev/null
			then
				time_lastcheck_withinternet="$time_now"
			else								
				logger -p daemon.info -t "watchcat[$$]" "no internet connectivity for $((time_now-time_lastcheck_withinternet)). Reseting when reaching $period"
			fi
		done
		
		[ "$((time_now-time_lastcheck_withinternet))" -ge "$period" ] && reboot_now "$forcedelay"
	done
}

if [ "$1" = "always" ]
then
	watchcat_always "$2" "$3"
else
	watchcat_ping "$2" "$3" "$4" "$5" "$6"
fi
