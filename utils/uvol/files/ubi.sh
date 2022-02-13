#!/bin/sh

cmd="$1"
shift

if [ "$cmd" = "name" ]; then
	echo "UBI"
	return 0
fi

test -e /sys/class/ubi/version || return 0
read -r ubiver < /sys/class/ubi/version
[ "$ubiver" = "1" ] || return 1
test -e /sys/devices/virtual/ubi || return 0

ubidev=$(ls -1 /sys/devices/virtual/ubi | head -n 1)

read -r ebsize < "/sys/devices/virtual/ubi/${ubidev}/eraseblock_size"

. /lib/functions/uvol.sh

freebytes() {
	read -r availeb < "/sys/devices/virtual/ubi/${ubidev}/avail_eraseblocks"
	echo $((availeb * ebsize))
}

totalbytes() {
	read -r totaleb < "/sys/devices/virtual/ubi/${ubidev}/total_eraseblocks"
	echo $((totaleb * ebsize))
}

getdev() {
	local voldir volname
	for voldir in "/sys/devices/virtual/ubi/${ubidev}/${ubidev}_"*; do
		read -r volname < "${voldir}/name"
		case "$volname" in
			uvol-[rw][owpd]-$1)
				basename "$voldir"
				break
				;;
			*)
				continue
				;;
		esac
	done
}

vol_is_mode() {
	local voldev="$1"
	local volname
	read -r volname < "/sys/devices/virtual/ubi/${ubidev}/${voldev}/name"
	case "$volname" in
		uvol-$2-*)
			return 0
			;;
	esac
	return 1
}

getstatus() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	vol_is_mode "$voldev" wo && return 22
	vol_is_mode "$voldev" wp && return 16
	vol_is_mode "$voldev" wd && return 1
	vol_is_mode "$voldev" ro && [ ! -e "/dev/ubiblock${voldev:3}" ] && return 1
	return 0
}

getsize() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	cat "/sys/devices/virtual/ubi/${ubidev}/${voldev}/data_bytes"
}

getuserdev() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	if vol_is_mode "$voldev" ro ; then
		echo "/dev/ubiblock${voldev:3}"
	elif vol_is_mode "$voldev" rw ; then
		echo "/dev/$voldev"
	fi
}

mkubifs() {
	local tmp_mp
	tmp_mp="$(mktemp -d)"
	mount -t ubifs "$1" "$tmp_mp" || return $?
	umount "$tmp_mp" || return $?
	rmdir "$tmp_mp" || return $?
	return 0
}

createvol() {
	local mode ret voldev
	voldev=$(getdev "$@")
	[ "$voldev" ] && return 17
	case "$3" in
		ro|wo)
			mode=wo
			;;
		rw)
			mode=wp
			;;
		*)
			return 22
			;;
	esac
	ubimkvol "/dev/$ubidev" -N "uvol-$mode-$1" -s "$2" || return $?
	ret=$?
	[ $ret -eq 0 ] || return $ret
	voldev="$(getdev "$@")"
	ubiupdatevol -t "/dev/$voldev" || return $?
	[ "$mode" = "wp" ] || return 0
	mkubifs "/dev/$voldev" || return $?
	uvol_uci_add "$1" "/dev/$voldev" "rw"
	ubirename "/dev/$ubidev" "uvol-wp-$1" "uvol-wd-$1" || return $?
}

removevol() {
	local voldev volnum
	voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	vol_is_mode "$voldev" rw && return 16
	vol_is_mode "$voldev" ro && return 16
	volnum="${voldev#${ubidev}_}"
	ubirmvol "/dev/$ubidev" -n "$volnum" || return $?
	uvol_uci_remove "$1"
	uvol_uci_commit "$1"
}

block_hotplug() {
	export ACTION="$1"
	export DEVNAME="$2"
	/sbin/block hotplug
}

activatevol() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	vol_is_mode "$voldev" rw && return 0
	vol_is_mode "$voldev" ro && return 0
	vol_is_mode "$voldev" wo && return 22
	vol_is_mode "$voldev" wp && return 16
	uvol_uci_commit "$1"
	if vol_is_mode "$voldev" rd; then
		ubirename "/dev/$ubidev" "uvol-rd-$1" "uvol-ro-$1" || return $?
		ubiblock --create "/dev/$voldev" || return $?
		return 0
	elif vol_is_mode "$voldev" wd; then
		ubirename "/dev/$ubidev" "uvol-wd-$1" "uvol-rw-$1" || return $?
		block_hotplug add "$voldev"
		return 0
	fi
}

disactivatevol() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	vol_is_mode "$voldev" rd && return 0
	vol_is_mode "$voldev" wd && return 0
	vol_is_mode "$voldev" wo && return 22
	vol_is_mode "$voldev" wp && return 16
	if vol_is_mode "$voldev" ro; then
		grep -q "^/dev/ubiblock${voldev:3}" /proc/self/mounts && umount "/dev/ubiblock${voldev:3}"
		ubiblock --remove "/dev/$voldev"
		ubirename "/dev/$ubidev" "uvol-ro-$1" "uvol-rd-$1" || return $?
		return 0
	elif vol_is_mode "$voldev" rw; then
		umount "/dev/$voldev"
		ubirename "/dev/$ubidev" "uvol-rw-$1" "uvol-wd-$1" || return $?
		block_hotplug remove "$voldev"
		return 0
	fi
}

updatevol() {
	local voldev
	voldev="$(getdev "$@")"
	[ "$voldev" ] || return 2
	[ "$2" ] || return 22
	vol_is_mode "$voldev" wo || return 22
	ubiupdatevol -s "$2" "/dev/$voldev" -
	ubiblock --create "/dev/$voldev"
	uvol_uci_add "$1" "/dev/ubiblock${voldev:3}" "ro"
	ubiblock --remove "/dev/$voldev"
	ubirename "/dev/$ubidev" "uvol-wo-$1" "uvol-rd-$1"
}

listvols() {
	local volname volmode volsize json_output json_notfirst
	if [ "$1" = "-j" ]; then
		json_output=1
		shift
		echo "["
	fi
	for voldir in "/sys/devices/virtual/ubi/${ubidev}/${ubidev}_"*; do
		read -r volname < "$voldir/name"
		case "$volname" in
			uvol-[rw][wod]*)
				read -r volsize < "$voldir/data_bytes"
				;;
			*)
				continue
				;;
		esac
		volmode="${volname:5:2}"
		volname="${volname:8}"
		[ "${volname:0:1}" = "." ] && continue
		if [ "$json_output" = "1" ]; then
			[ "$json_notfirst" = "1" ] && echo ","
				echo -e "\t{"
				echo -e "\t\t\"name\": \"$volname\","
				echo -e "\t\t\"mode\": \"$volmode\","
				echo -e "\t\t\"size\": $volsize"
				echo -n -e "\t}"
				json_notfirst=1
		else
			echo "$volname $volmode $volsize"
		fi
	done

	if [ "$json_output" = "1" ]; then
		[ "$json_notfirst" = "1" ] && echo
		echo "]"
	fi
}

bootvols() {
	local volname volmode volsize voldev fstype
	for voldir in "/sys/devices/virtual/ubi/${ubidev}/${ubidev}_"*; do
		read -r volname < "$voldir/name"
		voldev="$(basename "$voldir")"
		fstype=
		case "$volname" in
			uvol-ro-*)
				ubiblock --create "/dev/$voldev" || return $?
				;;
			*)
				continue
				;;
		esac
		volmode="${volname:5:2}"
		volname="${volname:8}"
	done
}

detect() {
	local volname voldev volmode voldev fstype tmpdev=""
	for voldir in "/sys/devices/virtual/ubi/${ubidev}/${ubidev}_"*; do
		read -r volname < "$voldir/name"
		voldev="$(basename "$voldir")"
		fstype=
		case "$volname" in
			uvol-r[od]-*)
				if ! [ -e "/dev/ubiblock${voldev:3}" ]; then
					ubiblock --create "/dev/$voldev" || return $?
				fi
				case "$volname" in
				uvol-rd-*)
					tmpdev="$tmpdev $voldev"
					;;
				esac
				;;
			*)
				continue
				;;
		esac
		volmode="${volname:5:2}"
		volname="${volname:8}"
	done

	uvol_uci_init

	for voldir in "/sys/devices/virtual/ubi/${ubidev}/${ubidev}_"*; do
		read -r volname < "$voldir/name"
		voldev="$(basename "$voldir")"
		case "$volname" in
			uvol-[rw][wod]*)
				true
				;;
			*)
				continue
				;;
		esac
		volmode="${volname:5:2}"
		volname="${volname:8}"
		case "$volmode" in
		"ro" | "rd")
			uvol_uci_add "$volname" "/dev/ubiblock${voldev:3}" "ro"
			;;
		"rw" | "wd")
			uvol_uci_add "$volname" "/dev/${voldev}" "rw"
			;;
		esac
	done

	uvol_uci_commit

	for voldev in $tmpdev ; do
		ubiblock --remove "/dev/$voldev" || return $?
	done
}

case "$cmd" in
	align)
		echo "$ebsize"
		;;
	free)
		freebytes
		;;
	total)
		totalbytes
		;;
	detect)
		detect
		;;
	boot)
		bootvols
		;;
	list)
		listvols "$@"
		;;
	create)
		createvol "$@"
		;;
	remove)
		removevol "$@"
		;;
	device)
		getuserdev "$@"
		;;
	size)
		getsize "$@"
		;;
	up)
		activatevol "$@"
		;;
	down)
		disactivatevol "$@"
		;;
	status)
		getstatus "$@"
		;;
	write)
		updatevol "$@"
		;;
	*)
		echo "unknown command"
		return 1
		;;
esac
