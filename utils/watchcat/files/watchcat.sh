#!/bin/sh
#
# Copyright (C) 2010 segal.di.ubi.pt
# Copyright (C) 2020 nbembedded.com
#
# This is free software, licensed under the GNU General Public License v2.
#

# shellcheck shell=busybox

# source=/dev/null is required as /lib/network/config.sh exists on the target
# system, but not on the system on which shell check is run.
# shellcheck source=/dev/null
. /lib/network/config.sh # Provides find_config on the OpenWrt target system

get_ping_size() {
	local ps="$1"
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
	echo "$ps"
}

get_ping_family_flag() {
	local family="$1"
	case "$family" in
	any)
		family=""
		;;
	ipv4)
		family="4"
		;;
	ipv6)
		family="6"
		;;
	*)
		printf "Error: invalid address_family \"%s\". address_family should be one of: any, ipv4, ipv6" "$family" 1>&2
		;;
	esac
	printf "%s" "$family"
}

reboot_now() {
	# Attempt to reboot, but background so we can do a force reboot after a
	# delay, in case the reboot attempt fails.
	( reboot & )

	# Do a forced reboot if the normal reboot has not yet completed after
	# a delay.
	[ "$1" -ge 1 ] && {
		sleep "$1"
		echo 1 >/proc/sys/kernel/sysrq
		echo b >/proc/sysrq-trigger # Will immediately reboot the system without syncing or unmounting your disks.
	}
}

check_hosts() {
	local ping_hosts="$1"
	local time_now="$2"
	local time_lastcheck_withinternet="$3"
	local failure_period="$4"
	local ping_family="$5"
	local iface="$6"
	local ping_size="$7"
	local callback="$8"
	local script="$9"

	local host

	# Avoid globbing while (intentionally) word-splitting in ash
	set -f

	# word splitting is intentional (in fact it is required) here
	# shellcheck disable=SC2086
	set -- $1

	# restore default (pathname expansion/globbing)
	set +f

	local all_hosts_reachable="true"

	while [ "$1" ]; do
		host="$1"
		shift || true

		if ping ${ping_family:+-"${ping_family}"} ${iface:+-I "${iface}"} -s "$ping_size" -c 1 "$host" >/dev/null 2>&1; then
			:
		else
			"$callback" "$host" "$iface" "$time_now" "$time_lastcheck_withinternet" "$failure_period" "$script"
			all_hosts_reachable="false"
		fi
	done

	if [ "$all_hosts_reachable" = "true" ]; then
		time_lastcheck_withinternet="$time_now"
	fi

	echo "$time_lastcheck_withinternet"
}

watchcat_periodic() {
	local reboot_period="$1"
	local force_reboot_delay="$2"

	# After reboot_period (from service start), attempt a reboot, and if it doesn't succeed within
	# the time specified by force_reboot_delay, do a forced reboot
	sleep "$reboot_period" && reboot_now "$force_reboot_delay"
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
	local network
	network="$(find_config "$1")"
	logger -p daemon.info -t "watchcat[$$]" "Restarting network interface: \"$1\" (network: \"$network\")."
	ifup "$network"
}

watchcat_run_script() {
	logger -p daemon.info -t "watchcat[$$]" "Running script \"$1\" for network interface: \"$2\"."
	"$1" "$2"
}

watchcat_restart_all_network() {
	logger -p daemon.info -t "watchcat[$$]" "Restarting networking now by running: /etc/init.d/network restart"
	/etc/init.d/network restart
}

watchcat_ping_cb() {
	local host="$1"
	local iface="$2"
	local time_now="$3"
	local time_lastcheck_withinternet="$4"
	local failure_period="$5"

	logger -p daemon.info -t "watchcat[$$]" "Could not reach $host for $((time_now - time_lastcheck_withinternet)). Rebooting after reaching $failure_period"
}

watchcat_monitor_network_cb() {
	local host="$1"
	local iface="$2"
	local time_now="$3"
	local time_lastcheck_withinternet="$4"
	local failure_period="$5"
	local script="$6"

	if [ "$script" != "" ]; then
		logger -p daemon.info -t "watchcat[$$]" "Could not reach $host via \"$iface\" for \"$((time_now - time_lastcheck_withinternet))\" seconds. Running script after reaching \"$failure_period\" seconds"
	elif [ "$iface" != "" ]; then
		logger -p daemon.info -t "watchcat[$$]" "Could not reach $host via \"$iface\" for \"$((time_now - time_lastcheck_withinternet))\" seconds. Restarting \"$iface\" after reaching \"$failure_period\" seconds"
	else
		logger -p daemon.info -t "watchcat[$$]" "Could not reach $host for \"$((time_now - time_lastcheck_withinternet))\" seconds. Restarting networking after reaching \"$failure_period\" seconds"
	fi
}

watchcat_monitor_network() {
	local failure_period="$1"
	local ping_hosts="$2"
	local ping_frequency_interval="$3"
	local ping_size="$4"
	local iface="$5"
	local mm_iface_name="$6"
	local mm_iface_unlock_bands="$7"
	local address_family="$8"
	local script="$9"

	local time_now time_lastcheck time_lastcheck_withinternet time_diff host

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

		time_lastcheck_withinternet="$(check_hosts "$ping_hosts" "$time_now" "$time_lastcheck_withinternet" "$failure_period" "$ping_family" \
			"$iface" "$ping_size" watchcat_monitor_network_cb "$script")"

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
		}

	done
}

watchcat_ping() {
	local failure_period="$1"
	local force_reboot_delay="$2"
	local ping_hosts="$3"
	local ping_frequency_interval="$4"
	local ping_size="$5"
	local address_family="$6"
	local iface="$7"

	local time_now time_lastcheck time_lastcheck_withinternet time_diff host

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

		time_lastcheck_withinternet="$(check_hosts "$ping_hosts" "$time_now" "$time_lastcheck_withinternet" "$failure_period" "$ping_family" \
			"$iface" "$ping_size" watchcat_ping_cb)"

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
	watchcat_monitor_network "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
	;;
run_script)
	# args from init script: period pinghosts pingperiod pingsize interface addressfamily script
	watchcat_monitor_network "$2" "$3" "$4" "$5" "$6" "" "" "$7" "$8"
	;;
*)
	printf "Error: invalid mode selected: %s\n" "$mode"
	;;
esac
