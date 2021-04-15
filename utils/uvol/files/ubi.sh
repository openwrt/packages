#!/bin/sh

cmd="$1"
shift

if [ "$cmd" = "name" ]; then
	echo "UBI"
	return 0
fi

test -e /sys/class/ubi/version || return 0
read ubiver < /sys/class/ubi/version
[ "$ubiver" = "1" ] || return 1
test -e /sys/devices/virtual/ubi || return 0

ubidev=$(ls -1 /sys/devices/virtual/ubi | head -n 1)

read ebsize < "/sys/devices/virtual/ubi/${ubidev}/eraseblock_size"

freebytes() {
	read availeb < "/sys/devices/virtual/ubi/${ubidev}/avail_eraseblocks"
	echo $((availeb * ebsize))
}

totalbytes() {
	read totaleb < "/sys/devices/virtual/ubi/${ubidev}/total_eraseblocks"
	echo $((totaleb * ebsize))
}

getdev() {
	local voldir volname devname
	for voldir in /sys/devices/virtual/ubi/${ubidev}/${ubidev}_*; do
		read volname < "${voldir}/name"
		[ "$volname" = "uvol-ro-$1" ] || [ "$volname" = "uvol-wp-$1" ] || [ "$volname" = "uvol-rw-$1" ] || [ "$volname" = "uvol-wo-$1" ] || continue
		basename "$voldir"
	done
}

vol_is_mode() {
	local voldev="$1"
	local volname
	read volname < "/sys/devices/virtual/ubi/${ubidev}/${voldev}/name"
	case "$volname" in
		uvol-$2-*)
			return 0
			;;
	esac
	return 1
}

getstatus() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	vol_is_mode $voldev wo && return 1
	vol_is_mode $voldev ro && [ ! -e "/dev/ubiblock${voldev:3}" ] && return 1
	return 0
}

getsize() {
	local voldev
	voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	cat /sys/devices/virtual/ubi/${ubidev}/${voldev}/data_bytes
}

getuserdev() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	if vol_is_mode $voldev ro ; then
		echo "/dev/ubiblock${voldev:3}"
	elif vol_is_mode $voldev rw ; then
		echo "/dev/$voldev"
	fi
}

createvol() {
	local mode ret
	local existdev=$(getdev "$@")
	[ "$existdev" ] && return 17
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
	ubimkvol /dev/$ubidev -N "uvol-$mode-$1" -s "$2"
	ret=$?
	[ $ret -eq 0 ] || return $ret
	ubiupdatevol -t /dev/$(getdev "$@")
	[ "$mode" = "wp" ] || return 0
	local tmp_mp=$(mktemp -d)
	mount -t ubifs /dev/$(getdev "$@") $tmp_mp
	umount $tmp_mp
	rmdir $tmp_mp
	ubirename /dev/$ubidev uvol-wp-$1 uvol-rw-$1
}

removevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	local volnum=${voldev#${ubidev}_}
	ubirmvol /dev/$ubidev -n $volnum
}

activatevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	vol_is_mode $voldev wo || return 1
	vol_is_mode $voldev ro || return 0
	[ -e "/dev/ubiblock${voldev:3}" ] && return 0
	ubiblock --create /dev/$voldev
}

disactivatevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	vol_is_mode $voldev ro || return 0
	[ -e "/dev/ubiblock${voldev:3}" ] || return 0
	ubiblock --remove /dev/$voldev
}

updatevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	[ "$2" ] || return 22
	vol_is_mode $voldev wo || return 22
	ubiupdatevol -s $2 /dev/$voldev -
	ubirename /dev/$ubidev uvol-wo-$1 uvol-ro-$1
}

listvols() {
	local volname volmode volsize
	for voldir in /sys/devices/virtual/ubi/${ubidev}/${ubidev}_*; do
		read volname < $voldir/name
		case "$volname" in
			uvol-r[wo]*)
				read volsize < $voldir/data_bytes
				;;
			*)
				continue
				;;
		esac
		volmode=${volname:5:2}
		volname=${volname:8}
		echo "$volname $volmode $volsize"
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
