// SPDX-License-Identifier: GPL-2.0-or-later
// Helper functions used to identify the boot device

// adapted from /lib/functions.sh
let cmdline_get_var = function(var) {
	let cmdline = fs.open("/proc/cmdline", "r");
	let allargs = cmdline.read("all");
	cmdline.close();
	let ret = null;
	for (let arg in split(allargs, /[ \t\n]/)) {
		let el = split(arg, "=");
		if (shift(el) == var)
			return join("=", el);
	}
	return ret;
};

// adapted from /lib/upgrade/common.sh
let get_blockdevs = function() {
	let devs = [];
	for (let dev in fs.glob('/dev/*'))
		if (fs.stat(dev).type == "block")
			push(devs, split(dev, '/')[-1]);

	return devs;
};

// adapted from /lib/upgrade/common.sh
let get_uevent_major_minor = function(file) {
	let uevf = fs.open(file, "r");
	if (!uevf)
		return null;

	let r = {};
	let evl;
	while ((evl = uevf.read("line"))) {
	let ev = split(evl, '=');
		if (ev[0] == "MAJOR")
			r.major = +ev[1];
		if (ev[0] == "MINOR")
			r.minor = +ev[1];
	}
	uevf.close();
	return r;
};

// adapted from /lib/upgrade/common.sh
let fitblk_get_bootdev = function(void) {
	let rootdisk_handle = fs.open("/sys/firmware/devicetree/base/chosen/rootdisk", "r");
	if (!rootdisk_handle)
		return null;

	// read rootdisk handle
	let rootdisk = rootdisk_handle.read("all");
	rootdisk_handle.close();

	// find all block device handle sysfs files
	let handles = fs.glob('/sys/class/block/*/of_node/phandle');
	let mtd_handles = fs.glob('/sys/class/block/*/device/of_node/phandle');
	// concat array of both globs
	for (let mtddev in mtd_handles)
		push(handles, mtddev);

	for (let dev in handles) {
		let bdev_handle = fs.open(dev, "r");
		if (!bdev_handle)
			continue;

		let bdev = bdev_handle.read("all");
		bdev_handle.close();

		if ( bdev != rootdisk )
			continue;

		let path = split(dev, '/');
		let pe = length(path) - 3;
		if (path[pe] == "device")
			--pe;

		return path[pe];
	}

	return null;
};

// adapted from /lib/upgrade/common.sh
let get_bootdev = function(void) {
	let rootpart = cmdline_get_var("root");
	let uevent = null;

	if (wildcard(rootpart, "PARTUUID=[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]-[a-f0-9][a-f0-9]")) {
		let uuidarg = split(substr(rootpart, 9), '-')[0];
		for (let bd in get_blockdevs()) {
			let bdf = fs.open(sprintf("/dev/%s", bd), "r");
			bdf.seek(440);
			let bduuid = bdf.read(4);
			bdf.close();
			if (uuidarg == sprintf("%x%x%x%x", ord(bduuid, 3), ord(bduuid, 2), ord(bduuid, 1), ord(bduuid, 0))) {
				uevent = sprintf("/sys/class/block/%s/uevent", bd);
				break;
				}
			}
		} else if (wildcard(rootpart, "PARTUUID=????????-????-????-????-??????????0?/PARTNROFF=*") ||
			   wildcard(rootpart, "PARTUUID=????????-????-????-????-??????????02")) {
			let uuidarg = substr(split(substr(rootpart, 9), '/')[0], 0, -2) + "00";
			for (let bd in get_blockdevs()) {
				let bdf = fs.open(sprintf("/dev/%s", bd), "r");
				bdf.seek(568);
				let bduuid = bdf.read(16);
				bdf.close();
				if (!bduuid)
					continue;

			let uuid = sprintf("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
				ord(bduuid, 3), ord(bduuid, 2), ord(bduuid, 1), ord(bduuid, 0),
				ord(bduuid, 5), ord(bduuid, 4),
				ord(bduuid, 7), ord(bduuid, 6),
				ord(bduuid, 8), ord(bduuid, 9),
				ord(bduuid, 10), ord(bduuid, 11), ord(bduuid, 12), ord(bduuid, 13), ord(bduuid, 14), ord(bduuid, 15));

			if (uuidarg == uuid) {
				uevent = sprintf("/sys/class/block/%s/uevent", bd);
				break;
			}
		}
	} else if (wildcard(rootpart, "0x[a-f0-9][a-f0-9][a-f0-9]") ||
		   wildcard(rootpart, "0x[a-f0-9][a-f0-9][a-f0-9][a-f0-9]") ||
		   wildcard(rootpart, "[a-f0-9][a-f0-9][a-f0-9]") ||
		   wildcard(rootpart, "[a-f0-9][a-f0-9][a-f0-9][a-f0-9]")) {
		let devid = rootpart;
		if (substr(devid, 0, 2) == "0x")
			devid = substr(devid, 2);

		devid = hex(devid);
		for (let bd in get_blockdevs()) {
			let r = get_uevent_major_minor(sprintf("/sys/class/block/%s/uevent", bd));
			if (r && (r.major == devid / 256) && (r.minor == devid % 256)) {
				uevent = sprintf("/sys/class/block/%s/../uevent", bd);
				break;
			}
		}
	} else if (rootpart == "/dev/fit0") {
		uevent = sprintf("/sys/class/block/%s/../uevent", fitblk_get_bootdev());
	} else if (wildcard(rootpart, "/dev/*")) {
		uevent = sprintf("/sys/class/block/%s/../uevent", split(rootpart, '/')[-1]);
	}
	return get_uevent_major_minor(uevent);
};

// adapted from /lib/upgrade/common.sh
let get_partition = function(dev, num) {
	if (!dev)
		return null;

	for (let bd in get_blockdevs()) {
		let r = get_uevent_major_minor(sprintf("/sys/class/block/%s/uevent", bd));
		if (r.major == dev.major && r.minor == dev.minor + num) {
			return bd;
			break;
		}
	}
	return null;
};

blockdev_common = {};
blockdev_common.get_partition = get_partition;
blockdev_common.get_bootdev = get_bootdev;
