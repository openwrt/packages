#!/bin/sh
# Copyright 2010 Vertical Communications
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

fsck_dosfsck() {
	dosfsck -p "$device" 2>&1 | logger -t "fstab: dosfsck ($device)"
	local status="$?"
	case "$status" in
		0|1) ;; #success
		2) reboot;;
		4) echo "dosfsck ($device): Warning! Uncorrected errors."| logger -t fstab
			return 1
			;;
		*) echo "dosfsck ($device): Error $status. Check not complete."| logger -t fstab;;
	esac
	return 0
}

fsck_dos() {
	fsck_dosfsck "$@"
}

fsck_vfat() {
	fsck_dosfsck "$@"
}

append libmount_known_fsck "dos"
append libmount_known_fsck "vfat"
