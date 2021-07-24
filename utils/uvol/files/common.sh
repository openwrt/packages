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
	local autofs uuid uciname

	uciname=${volname//-/_}
	uuid="$(/sbin/block info | grep "^$2" | xargs -n 1 echo | grep "^UUID=.*")"
	[ "$uuid" ] || return 22
	_uvol_init_spooldir
	uuid="${uuid:5}"
	autofs=0
	[ "$mode" = "ro" ] && autofs=1
	if [ -e "${UCI_SPOOLDIR}/remove-$1" ]; then
		rm "${UCI_SPOOLDIR}/remove-$1"
	fi

	cat >"${UCI_SPOOLDIR}/add-$1" <<EOF
set fstab.$uciname=mount
set fstab.$uciname.uuid=$uuid
set fstab.$uciname.target=/var/run/uvol/$volname
set fstab.$uciname.options=$mode
set fstab.$uciname.autofs=$autofs
set fstab.$uciname.enabled=1
commit fstab
EOF
}

uvol_uci_remove() {
	local volname="$1"
	local uciname

	uciname=${volname//-/_}
	if [ -e "${UCI_SPOOLDIR}/add-$1" ]; then
		rm "${UCI_SPOOLDIR}/add-$1"
		return
	fi
	_uvol_init_spooldir
	cat >"${UCI_SPOOLDIR}/remove-$1" <<EOF
delete fstab.$uciname
commit fstab
EOF
}

uvol_uci_commit() {
	local volname="$1"

	if [ -e "${UCI_SPOOLDIR}/add-$1" ]; then
		uci batch < "${UCI_SPOOLDIR}/add-$1"
		rm "${UCI_SPOOLDIR}/add-$1"
	elif [ -e "${UCI_SPOOLDIR}/remove-$1" ]; then
		uci batch < "${UCI_SPOOLDIR}/remove-$1"
		rm "${UCI_SPOOLDIR}/remove-$1"
	fi

	return $?
}
