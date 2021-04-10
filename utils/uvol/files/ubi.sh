#!/bin/sh

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
		[ "$volname" = "uvol-ro-$1" ] || [ "$volname" = "uvol-rw-$1" ] || continue
		basename "$voldir"
	done
}

needs_ubiblock() {
	local voldev="$1"
	local volname
	read volname < "/sys/devices/virtual/ubi/${ubidev}/${voldev}/name"
	case "$volname" in
		uvol-ro-*)
			return 0
			;;
	esac
	return 1
}

getstatus() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	needs_ubiblock $voldev && [ ! -e "/dev/ubiblock${voldev:3}" ] && return 1
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
	if needs_ubiblock $voldev ; then
		echo "/dev/ubiblock${voldev:3}"
	else
		echo "/dev/$voldev"
	fi
}

createvol() {
	local mode
	local existdev=$(getdev "$1")
	[ "$existdev" ] && return 17
	case "$3" in
		ro)
			mode=ro
			;;
		rw)
			mode=rw
			;;
		*)
			return 22
			;;
	esac
	ubimkvol /dev/$ubidev -N "uvol-$mode-$1" -s "$2"
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
	needs_ubiblock $voldev || return 0
	[ -e "/dev/ubiblock${voldev:3}" ] && return 0
	ubiblock --create /dev/$voldev
}

disactivatevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	needs_ubiblock $voldev || return 0
	[ -e "/dev/ubiblock${voldev:3}" ] || return 0
	ubiblock --remove /dev/$voldev
}

updatevol() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	[ "$2" ] || return 22
	needs_ubiblock $voldev || return 22
	ubiupdatevol -s $2 /dev/$voldev -
}

getstatus() {
	local voldev=$(getdev "$@")
	[ "$voldev" ] || return 2
	needs_ubiblock $voldev && [ ! -e "/dev/ubiblock${voldev:3}" ] && return 1
	return 0
}

cmd="$1"
shift
case "$cmd" in
	free)
		freebytes
		;;
	total)
		totalbytes
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
