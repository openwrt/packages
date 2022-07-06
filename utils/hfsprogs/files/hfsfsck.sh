# SPDX-Identifier-License: GPL-2.0-only
#!/bin/sh
# Copyright 2015 OpenWrt.org
#

fsck_hfsfsck() {
	hfsfsck "$device" 2>&1 | logger -t "fstab: hfsfsck ($device)"
	local status="$?"
	case "$status" in
		0) ;; #success
		4) reboot;;
		8) echo "hfsfsck ($device): Warning! Uncorrected errors."| logger -t fstab
			return 1
			;;
		*) echo "hfsfsck ($device): Error $status. Check not complete."| logger -t fstab;;
	esac
	return 0
}

fsck_hfs() {
	fsck_hfsfsck "$@"
}

fsck_hfsplus() {
	fsck_hfsfsck "$@"
}

append libmount_known_fsck "hfs"
append libmount_known_fsck "hfsplus"
