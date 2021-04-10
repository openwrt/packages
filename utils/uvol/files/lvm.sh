#!/bin/sh

command -v lvm || return 1

. /lib/functions.sh
. /lib/upgrade/common.sh

export_bootdevice
[ "$BOOTDEV_MAJOR" ] || return 1
export_partdevice rootdev 0
[ "$rootdev" ] || return 1
LVM_SUPPRESS_FD_WARNINGS=1

case "$rootdev" in
	mtd*|\
	ram*|\
	ubi*)
		return 1
esac

lvs() {
	local cmd="$1"
	local cb="$2"
	local param="${3:+-S vg_name=${vgname} -S lv_name=~^r[ow]_$3\$}"
	local oIFS="$IFS"
	IFS=" "
	set -- $(LVM_SUPPRESS_FD_WARNINGS=1 $cmd -c $param)
	[ "$1" ] || {
		IFS="$oIFS"
		return 1
	}
	IFS=":"
	set -- $1
	IFS="$oIFS"
	$cb "$@"
}

pvvars() {
	case "${1:5}" in
		"$rootdev"*)
			partdev="$1"
			vgname="$2"
			;;
	esac
}

vgvars() {
	[ "$1" = "$vgname" ] || return
	vgbs="${13}"
	vgts="${14}"
	vgus="${15}"
	vgfs="${16}"
}

lvvars() {
	lvpath="$1"
	lvsize=$(( 512 * $7 ))
}

freebytes() {
	echo $((vgfs * vgbs * 1024))
}

totalbytes() {
	echo $((vgts * vgbs * 1024))
}

existvol() {
	[ "$1" ] || return 1
	test -e "/dev/$vgname/ro_$1" || test -e "/dev/$vgname/rw_$1"
	return $?
}

getlvname() {
	lvs lvdisplay lvvars "$1"

	[ "$lvpath" ] && echo ${lvpath:5}
}

getdev() {
	existvol "$1" || return 1
	readlink /dev/$(getlvname "$1")
}

getsize() {
	lvs lvdisplay lvvars "$1"
	[ "$lvsize" ] && echo $lvsize
}

activatevol() {
	LVM_SUPPRESS_FD_WARNINGS=1 lvchange -a y "$(getlvname "$1")"
}

disactivatevol() {
	existvol "$1" || return 1
	LVM_SUPPRESS_FD_WARNINGS=1 lvchange -a n "$(getlvname "$1")"
}

getstatus() {
	lvs lvdisplay lvvars "$1"
	[ "$lvsize" ] || return 2
	existvol "$1" || return 1
	return 0
}

createvol() {
	local mode ret lvname
	case "$3" in
		ro)
			mode=r
			;;
		rw)
			mode=rw
			;;
		*)
			return 22
			;;
	esac

	LVM_SUPPRESS_FD_WARNINGS=1 lvcreate -p $mode -a n -y -W n -Z n -n "${3}_${1}" -L "$2" $vgname
	ret=$?
	if [ ! $ret -eq 0 ] || [ "$mode" = "r" ]; then
		return $ret
	fi
	lvs lvdisplay lvvars "$1"
	[ "$lvpath" ] || return 22
	lvname=${lvpath:5}
	LVM_SUPPRESS_FD_WARNINGS=1 lvchange -a y /dev/$lvname || return 1
	if [ $lvsize -gt $(( 100 * 1024 * 1024 )) ]; then
		mkfs.f2fs -f -l "$1" $lvpath || return 1
	else
		mke2fs -F -L "$1" $lvpath || return 1
	fi
	return 0
}

removevol() {
	local lvname="$(getlvname "$1")"
	[ "$lvname" ] || return 2
	LVM_SUPPRESS_FD_WARNINGS=1 lvremove -y "$(getlvname "$1")"
}

updatevol() {
	lvs lvdisplay lvvars "$1"
	[ "$lvpath" ] || return 2
	[ $lvsize -ge $2 ] || return 27
	LVM_SUPPRESS_FD_WARNINGS=1 lvchange -a y -p rw ${lvpath:5}
	dd of=$lvpath
	case "$lvpath" in
		/dev/*/ro_*)
			LVM_SUPPRESS_FD_WARNINGS=1 lvchange -p r ${lvpath:5}
			;;
	esac
}

lvs pvdisplay pvvars
lvs vgdisplay vgvars
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
		getdev "$@"
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
