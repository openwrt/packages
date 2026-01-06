#!/bin/sh
#
# Copyright (C) 2010 segal.di.ubi.pt
# Copyright (C) 2020 nbembedded.com
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
		echo "Error: invalid ping_size. ping_size should be either: small, windows, standard, big, huge or jumbo" 1>&2
		echo "Corresponding ping packet sizes (bytes): small=1, windows=32, standard=56, big=248, huge=1492, jumbo=9000" 1>&2
		;;
	esac
	echo $ps
}

get_ping_family_flag() {
	family=$1
	case "$family" in
	any)
		family=""
		;;
	ipv4)
		family="-4"
		;;
	ipv6)
		family="-6"
		;;
	*)
		echo "Error: invalid address_family \"$family\". address_family should be one of: any, ipv4, ipv6" 1>&2
		;;
	esac
	echo $family
}

reboot_now() {
	reboot &

	[ "$1" -ge 1 ] && {
		sleep "$1"
		echo 1 > /proc/sys/kernel/sysrq
		echo b > /proc/sysrq-trigger # Will immediately reboot the system without syncing or unmounting your disks.
	}
}

watchcat_periodic() {
	failure_period="$1"
	force_reboot_delay="$2"

	sleep "$failure_period" && reboot_now "$force_reboot_delay"
}

watchcat_restart_modemmanager_iface() {
	[ "$2" -gt 0 ] && {
		logger -p daemon.info -t "watchcat[$$]" "Resetting current-bands to 'any' on modem: \"$1\" now."
		/usr/bin/mmcli -m any --set-current-bands=any
	}
	logger -p daemon.info -t "watchcat[$$]" "Reconnecting modem: \"$1\" now."
	/etc/init.d/modemmanager restart
	ifup "$1"
}

watchcat_restart_network_iface() {
	logger -p daemon.info -t "watchcat[$$]" "Restarting network interface: \"$1\"."
	ip link set "$1" down
	ip link set "$1" up
}

watchcat_run_script() {
	logger -p daemon.info -t "watchcat[$$]" "Running script \"$1\" for network interface: \"$2\"."
	"$1" "$2"
}

watchcat_restart_all_network() {
	logger -p daemon.info -t "watchcat[$$]" "Restarting networking now by running: /etc/init.d/network restart"
	/etc/init.d/network restart
}

watchcat_monitor_network() {
	failure_period="$1"
	ping_hosts="$2"
	ping_frequency_interval="$3"
	ping_size="$4"
	iface="$5"
	mm_iface_name="$6"
	mm_iface_unlock_bands="$7"
	address_family="$8"
	script="$9"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"

	[ "$time_now" -lt "$failure_period" ] && sleep "$((failure_period - time_now))"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"
	time_lastcheck="$time_now"
	time_lastcheck_withinternet="$time_now"

	ping_size="$(get_ping_size "$ping_size")"

	ping_family="$(get_ping_family_flag "$address_family")"

	about_to_restart_iface=1
	while true; do
		# account for the time ping took to return. With a ping time of 5s, ping might take more than that, so it is important to avoid even more delay.
		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_diff="$((time_now - time_lastcheck))"

		[ "$time_diff" -lt "$ping_frequency_interval" ] && sleep "$((ping_frequency_interval - time_diff))"

		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_lastcheck="$time_now"

		end_result=1
		for host in $ping_hosts; do
			if [ "$iface" != "" ]; then
				ping_result="$(
					ping $ping_family -I "$iface" -s "$ping_size" -c 1 "$host" &> /dev/null
					echo $?
				)"
			else
				ping_result="$(
					ping $ping_family -s "$ping_size" -c 1 "$host" &> /dev/null
					echo $?
				)"
			fi

			if [ "$ping_result" -eq 0 ]; then
				time_lastcheck_withinternet="$time_now"
				end_result=0
				if [ "$about_to_restart_iface" -eq 0 ]; then
					if [ "$script" != "" ]; then
						logger -p daemon.info -t "watchcat[$$]" "$host replies to ping, running script cancelled"
					elif [ "$iface" != "" ]; then
						logger -p daemon.info -t "watchcat[$$]" "$host replies to ping, restarting \"$iface\" cancelled"
					else
						logger -p daemon.info -t "watchcat[$$]" "$host replies to ping, restarting networking cancelled"
					fi
					about_to_restart_iface=1
				fi
			else
				logger -p daemon.info -t "watchcat[$$]" "Could not reach $host for \"$((time_now - time_lastcheck_withinternet))\" seconds."
			fi
		done
		if [ "$end_result" -ne 0 ]; then
			if [ "$script" != "" ]; then
				logger -p daemon.info -t "watchcat[$$]" "Could not reach any configured host via \"$iface\" for \"$((time_now - time_lastcheck_withinternet))\" seconds. Running script after reaching \"$failure_period\" seconds"
			elif [ "$iface" != "" ]; then
				logger -p daemon.info -t "watchcat[$$]" "Could not reach any configured host via \"$iface\" for \"$((time_now - time_lastcheck_withinternet))\" seconds. Restarting \"$iface\" after reaching \"$failure_period\" seconds"
			else
				logger -p daemon.info -t "watchcat[$$]" "Could not reach any configured host for \"$((time_now - time_lastcheck_withinternet))\" seconds. Restarting networking after reaching \"$failure_period\" seconds"
			fi
			about_to_restart_iface=0
		fi

		[ "$((time_now - time_lastcheck_withinternet))" -ge "$failure_period" ] && {
			if [ "$script" != "" ]; then
				watchcat_run_script "$script" "$iface"
			else
				if [ "$mm_iface_name" != "" ]; then
					watchcat_restart_modemmanager_iface "$mm_iface_name" "$mm_iface_unlock_bands"
				fi
				if [ "$iface" != "" ]; then
					watchcat_restart_network_iface "$iface"
				else
					watchcat_restart_all_network
				fi
			fi
			/etc/init.d/watchcat start
			# Restart timer cycle.
			time_lastcheck_withinternet="$time_now"
			about_to_restart_iface=1
		}

	done
}

watchcat_ping() {
	failure_period="$1"
	force_reboot_delay="$2"
	ping_hosts="$3"
	ping_frequency_interval="$4"
	ping_size="$5"
	address_family="$6"
	iface="$7"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"

	[ "$time_now" -lt "$failure_period" ] && sleep "$((failure_period - time_now))"

	time_now="$(cat /proc/uptime)"
	time_now="${time_now%%.*}"
	time_lastcheck="$time_now"
	time_lastcheck_withinternet="$time_now"

	ping_size="$(get_ping_size "$ping_size")"

	ping_family="$(get_ping_family_flag "$address_family")"

	while true; do
		# account for the time ping took to return. With a ping time of 5s, ping might take more than that, so it is important to avoid even more delay.
		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_diff="$((time_now - time_lastcheck))"

		[ "$time_diff" -lt "$ping_frequency_interval" ] && sleep "$((ping_frequency_interval - time_diff))"

		time_now="$(cat /proc/uptime)"
		time_now="${time_now%%.*}"
		time_lastcheck="$time_now"

		for host in $ping_hosts; do
			if [ "$iface" != "" ]; then
				ping_result="$(
					ping $ping_family -I "$iface" -s "$ping_size" -c 1 "$host" &> /dev/null
					echo $?
				)"
			else
				ping_result="$(
					ping $ping_family -s "$ping_size" -c 1 "$host" &> /dev/null
					echo $?
				)"
			fi

			if [ "$ping_result" -eq 0 ]; then
				time_lastcheck_withinternet="$time_now"
			else
				logger -p daemon.info -t "watchcat[$$]" "Could not reach $host for $((time_now - time_lastcheck_withinternet)). Rebooting after reaching $failure_period"
			fi
		done

		[ "$((time_now - time_lastcheck_withinternet))" -ge "$failure_period" ] && reboot_now "$force_reboot_delay"
	done
}

mode="$1"

# Fix potential typo in mode and provide backward compatibility.
[ "$mode" = "allways" ] && mode="periodic_reboot"
[ "$mode" = "always" ] && mode="periodic_reboot"
[ "$mode" = "ping" ] && mode="ping_reboot"

case "$mode" in
periodic_reboot)
	# args from init script: period forcedelay
	watchcat_periodic "$2" "$3"
	;;
ping_reboot)
	# args from init script: period forcedelay pinghosts pingperiod pingsize addressfamily interface
	watchcat_ping "$2" "$3" "$4" "$5" "$6" "$7" "$8"
	;;
restart_iface)
	# args from init script: period pinghosts pingperiod pingsize interface mmifacename unlockbands addressfamily
	watchcat_monitor_network "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" ""
	;;
run_script)
	# args from init script: period pinghosts pingperiod pingsize interface addressfamily script
	watchcat_monitor_network "$2" "$3" "$4" "$5" "$6" "" "" "$7" "$8"
	;;
*)
	echo "Error: invalid mode selected: $mode"
	;;
esac
