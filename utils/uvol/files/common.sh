#!/bin/sh

UCI_SPOOLDIR="/var/spool/uvol"

_uvol_init_spooldir() {
	[ ! -d "$(dirname "$UCI_SPOOLDIR")" ] && mkdir -p "$(dirname "$UCI_SPOOLDIR")"
	mkdir -m 0700 -p "$UCI_SPOOLDIR"
}

uvol_uci_add() {
	local volname="$1"
	local devname="$2"
	local mode="$3"
	local autofs=0
	local target="/tmp/run/uvol/$volname"
	local uuid uciname

	[ "$mode" = "ro" ] && autofs=1
	uciname="${volname//[-.]/_}"
	uciname="${uciname//[!([:alnum:]_)]}"
	uuid="$(/sbin/block info | grep "^$2" | xargs -n 1 echo | grep "^UUID=.*")"
	[ "$uuid" ] || return 22
	uuid="${uuid:5}"

	case "$uciname" in
		"_meta")
			target="/tmp/run/uvol/.meta"
			;;
		"_"*)
			return 1
			;;
	esac

	_uvol_init_spooldir
	if [ -e "${UCI_SPOOLDIR}/remove-$1" ]; then
		rm "${UCI_SPOOLDIR}/remove-$1"
	fi

	cat >"${UCI_SPOOLDIR}/add-$1" <<EOF
set fstab.$uciname=mount
set fstab.$uciname.uuid=$uuid
set fstab.$uciname.target=$target
set fstab.$uciname.options=$mode
set fstab.$uciname.autofs=$autofs
set fstab.$uciname.enabled=1
EOF
}

uvol_uci_remove() {
	local volname="$1"
	local uciname

	uciname="${volname//[-.]/_}"
	uciname="${uciname//[!([:alnum:]_)]}"
	if [ -e "${UCI_SPOOLDIR}/add-$1" ]; then
		rm "${UCI_SPOOLDIR}/add-$1"
		return
	fi
	_uvol_init_spooldir
	cat >"${UCI_SPOOLDIR}/remove-$1" <<EOF
delete fstab.$uciname
EOF
}

uvol_uci_commit() {
	local volname="$1"
	local ucibatch

	for ucibatch in "${UCI_SPOOLDIR}/"*"-$volname"${volname+*} ; do
		[ -e "$ucibatch" ] || break
		uci batch < "$ucibatch"
		[ $? -eq 0 ] && rm "$ucibatch"
	done

	uci commit fstab
	return $?
}

uvol_uci_init() {
	uci -q get fstab.@uvol[0] && return
	uci add fstab uvol
	uci set fstab.@uvol[-1].initialized=1
}
