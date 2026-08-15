// SPDX-License-Identifier: GPL-2.0-or-later
// blockd mount registration for uvol
//  (c) 2022 Daniel Golle <daniel@makrotopia.org>
//
// Register volumes with blockd over ubus instead of writing /etc/config/fstab,
// so volume state stays on the self-describing backing store and never leaks
// into the firmware rootfs.

let mount_fs = require("fs");
let mount_ubus = require("ubus");

let uvol_target = function(vol_name) {
	return sprintf("/tmp/run/uvol/%s", vol_name);
};

uvol_mount = {
	register: function(vol_name, dev_name, read_only) {
		if (!dev_name)
			return 22;
		if (substr(vol_name, 0, 1) == "." && vol_name != ".meta")
			return 1;

		let target = uvol_target(vol_name);
		let st = mount_fs.lstat(target);
		if (st && st.type == "link")
			mount_fs.unlink(target);
		else if (st && st.type == "directory")
			mount_fs.rmdir(target);

		let data = {
			device: dev_name,
			target: target,
			autofs: 1,
		};
		// declare the volume's read-only-ness to blockd, which carries it
		// to block as a mount option; block never guesses from the fs type.
		if (read_only)
			data.options = "ro";
		else
			data.check_fs = 1;

		mount_ubus.call({
			object: "block",
			method: "hotplug",
			data: data,
		});
		return mount_ubus.error() ? -1 : 0;
	},

	unregister: function(dev_name) {
		if (!dev_name)
			return 22;

		mount_ubus.call({
			object: "block",
			method: "hotplug",
			data: {
				device: dev_name,
				remove: 1,
			},
		});
		return mount_ubus.error() ? -1 : 0;
	}
};
