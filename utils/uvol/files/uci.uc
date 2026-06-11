// SPDX-License-Identifier: GPL-2.0-or-later
// UCI tools for uvol
//  (c) 2022 Daniel Golle <daniel@makrotopia.org>

let uci_spooldir = "/var/spool/uvol";
let init_spooldir = function(void) {
	parentdir = fs.stat(fs.dirname(uci_spooldir));
	if (!parentdir || parentdir.type != "directory")
		fs.mkdir(fs.dirname(uci_spooldir), 0755);
	fs.mkdir(uci_spooldir, 0700);
};

uvol_uci = {
	uvol_uci_add: function(vol_name, dev_name, mode) {
		try {
			let autofs = false;
			let uuid;
			let target;
			if (mode == "ro")
				autofs = true;

			let uciname = replace(vol_name, /[-.]/g, "_");
			uciname = replace(uciname, /!([:alnum:]_)/g, "");
			let bdinfo_p = fs.popen("/sbin/block info");
			let bdinfo_l;
			while (bdinfo_l = bdinfo_p.read("line")) {
				if (substr(bdinfo_l, 0, length(dev_name) + 1) != dev_name + ":")
					continue;
				let bdinfo_e = split(bdinfo_l, " ");
				shift(bdinfo_e);
				for (let bdinfo_a in bdinfo_e) {
					let bdinfo_v = split(bdinfo_a, "=");
					if (bdinfo_v[0] && bdinfo_v[0] == "UUID") {
						uuid = trim(bdinfo_v[1], "\"");
						break;
					}
				}
				break;
			}

			if (!uuid)
				return 22;

			if (uciname == "_meta")
				target = "/tmp/run/uvol/.meta";
			else if (substr(uciname, 0, 1) == "_")
				return 1;
			else
				target = sprintf("/tmp/run/uvol/%s", vol_name);

			init_spooldir();
			let remspool = sprintf("%s/remove-%s", uci_spooldir, uciname);
			if (fs.stat(remspool))
				fs.unlink(remspool);

			let addobj = {};
			addobj.name=uciname;
			addobj.uuid=uuid;
			addobj.target=target;
			addobj.options=mode;
			addobj.autofs=autofs;
			addobj.enabled=true;

			let spoolfile = fs.open(sprintf("%s/add-%s", uci_spooldir, uciname), "w");
			spoolfile.write(addobj);
			spoolfile.close();
		} catch(e) {
			printf("adding UCI section to spool failed");
			return -1;
		}
		return 0;
	},

	uvol_uci_remove: function(vol_name) {
		let uciname = replace(vol_name, /[-.]/g, "_");
		uciname = replace(uciname, /!([:alnum:]_)/g, "");

		let addspool = sprintf("%s/add-%s", uci_spooldir, uciname);
		if (fs.stat(addspool)) {
			fs.unlink(addspool);
			return 0;
		}
		init_spooldir();
		let spoolfile = fs.open(sprintf("%s/remove-%s", uci_spooldir, uciname), "w");
		spoolfile.write(uciname);
		spoolfile.close();
		return 0;
	},

	uvol_uci_commit: function(vol_name) {
		try {
			let uciname = null;
			if (vol_name) {
				uciname = replace(vol_name, /[-.]/g, "_");
				uciname = replace(uciname, /!([:alnum:]_)/g, "");
			}

			for (let file in fs.glob(sprintf("%s/*-%s", uci_spooldir, uciname?uciname:"*"))) {
				let action = split(fs.basename(file), "-")[0];
				let spoolfd = fs.open(file, "r");
				let spoolstr = spoolfd.read("all");
				spoolfd.close();
				fs.unlink(file);
				if (action == "remove") {
					cursor.delete("fstab", spoolstr);
				} else if (action == "add") {
					let spoolobj = json(spoolstr);
					cursor.set("fstab", spoolobj.name, "mount");
					for (key in keys(spoolobj)) {
						if (key == "name")
							continue;

						cursor.set("fstab", spoolobj.name, key, spoolobj[key]);
					}
				}
			}
			cursor.commit();
		} catch(e) {
			printf("committing UCI spool failed");
			return -1;
		}
		return 0;
	},

	uvol_uci_init: function () {
		cursor.load("fstab");
		let f = cursor.get("fstab", "@uvol[0]", "initialized");
		if (f == 1)
			return 0;

		cursor.add("fstab", "uvol");
		cursor.set("fstab", "@uvol[-1]", "initialized", true);
		cursor.commit();
		cursor.unload("fstab");
		return 0;
	}
};
