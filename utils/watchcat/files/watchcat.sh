#!/bin/sh
#
# Copyright (C) 2010 segal.di.ubi.pt
#
# This is free software, licensed under the GNU General Public License v2.
#

get_ping_size() {
	ps=$1
	case "$ps" in
	small)
		ps="1"
		;;
	windows)
		ps="32"
		;;
	standard)
		ps="56"
		;;
	big)
		ps="248"
		;;
	huge)
		ps="1492"
		;;
	jumbo)
		ps="9000"
		;;
	*)
		echo "Error: invalid ping_size. ping_size should be either: small, windows, standard, big, huge or jumbo"
		echo "Cooresponding ping packet sizes (bytes): small=1, windows=32, standard=56, big=248, huge=1492, jumbo=9000"
		;;
	esac
	echo $ps
}

reboot_now() {
	reboot &

	[ "$1" -ge 1 ] && {
		sleep "$1"
		echo 1 >/proc/sys/kernel/sysrq
		echo b >/proc/sysrq-trigger # Will immediately reboot the system without syncing or unmounting your disks.
	}
}

watchcat_periodic() {
	local period="$1"
	local force_delay="$2"

	sleep "$period" && reboot_now "$force_delay"
}

watchcat_ping() {
	local period="$1"
	local force_delay="$2"
	local ping_hosts="$3"
	local ping_period="$4"
	local no_ping_time="$5"
	local ping_size="$6"

	local time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"

	[ "$time_now" -lt "$no_ping_time" ] && sleep "$((no_ping_time - time_now))"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"
	local time_lastcheck="$time_now"
	local time_lastcheck_withinternet="$time_now"
	local ping_size="$(get_ping_size "$ping_size")"

	while true; do
		# account for the time ping took to return. With a ping time of 5s, ping might take more than that, so it is important to avoid even more delay.
		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		local time_diff="$((time_now - time_lastcheck))"

		[ "$time_diff" -lt "$ping_period" ] && sleep "$((ping_period - time_diff))"

		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_lastcheck="$time_now"

		for host in $ping_hosts; do
			if ping -s "$ping_size" -c 1 "$host" &>/dev/null; then
				time_lastcheck_withinternet="$time_now"
			else
				logger -p daemon.info -t "watchcat[$$]" "no internet connectivity for $((time_now - time_lastcheck_withinternet)). Reseting when reaching $period"
			fi
		done

		[ "$((time_now - time_lastcheck_withinternet))" -ge "$period" ] && reboot_now "$force_delay"
	done
}

case "$mode" in
periodic_reboot)
	watchcat_periodic "$2" "$3"
	;;
ping_reboot)
	watchcat_ping "$2" "$3" "$4" "$5" "$6" "$7"
	;;
*)
	echo "Error: invalid mode selected: $mode"
	;;
esac
