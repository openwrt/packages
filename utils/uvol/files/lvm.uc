// SPDX-License-Identifier: GPL-2.0-or-later
// LVM2 backend for uvol
//  (c) 2022 Daniel Golle <daniel@makrotopia.org>
//
// This plugin uses LVM2 as a storage backend for uvol.
//
// By default, volumes are allocated on the physical device used for booting,
// the LVM2 PV and VG are initialized auto-magically by the 'autopart' script.
// By setting the UCI option 'vg_name' in the 'uvol' section in /etc/config/fstab
// you may set an arbitrary LVM2 volume group to back uvol instad.

let lvm_exec = "/sbin/lvm";

function lvm(cmd, ...args) {
	let lvm_json_cmds = [ "lvs", "pvs", "vgs" ];
	try {
		let json_param = "";
		if (cmd in lvm_json_cmds)
			json_param = "--reportformat json --units b ";
		let stdout = fs.popen(sprintf("LVM_SUPPRESS_FD_WARNINGS=1 %s %s %s%s", lvm_exec, cmd, json_param, join(" ", args)));
		let tmp;
		if (stdout) {
			tmp = stdout.read("all");
			let ret = {};
			ret.retval = stdout.close();
			if (json_param) {
				let data = json(tmp);
				if (data.report)
					ret.report = data.report[0];
			} else {
				ret.stdout = trim(tmp);
			}
			return ret;
		} else {
			printf("lvm cli command failed: %s\n", fs.error());
		}
	} catch(e) {
		printf("Failed to parse lvm cli output: %s\n%s\n", e, e.stacktrace[0].context);
	}
	return null;
}

function pvs() {
	let fstab = cursor.get_all('fstab');
	for (let k, section in fstab) {
		if (section['.type'] != 'uvol' || !section.vg_name)
			continue;

		return section.vg_name;
	}
	include("/usr/lib/uvol/blockdev_common.uc");
	let rootdev = blockdev_common.get_partition(blockdev_common.get_bootdev(), 0);
	if (!rootdev)
		return null;

	let tmp = lvm("pvs", "-o", "vg_name", "-S", sprintf("\"pv_name=~^/dev/%s.*\$\"", rootdev));
	if (tmp.report.pv[0])
		return tmp.report.pv[0].vg_name;
	else
		return null;
}

function vgs(vg_name) {
	let tmp = lvm("vgs", "-o", "vg_extent_size,vg_extent_count,vg_free_count", "-S", sprintf("\"vg_name=%s\"", vg_name));
	let ret = null;
	if (tmp && tmp.report.vg) {
		ret = tmp.report.vg;
		for (let r in ret) {
			r.vg_extent_size = +(rtrim(r.vg_extent_size, "B"));
			r.vg_extent_count = +r.vg_extent_count;
			r.vg_free_count = +r.vg_free_count;
		}
	}
	if (ret)
		return ret[0];
	else
		return null;
}

function lvs(vg_name, vol_name, extra_exp) {
	let ret = [];
	if (!vol_name)
		vol_name = ".*";

	let lvexpr = sprintf("\"lvname=~^[rw][owp]_%s\$ && vg_name=%s%s%s\"",
			     vol_name, vg_name, extra_exp?" && ":"", extra_exp?extra_exp:"");
	let tmp = lvm("lvs", "-o", "lv_active,lv_name,lv_full_name,lv_size,lv_path,lv_dm_path", "-S", lvexpr);
	if (tmp && tmp.report.lv) {
		ret = tmp.report.lv;
		for (let r in ret) {
			r.lv_size = +(rtrim(r.lv_size, "B"));
			r.lv_active = (r.lv_active == "active");
		}
	}
	return ret;
}

function getdev(lv) {
	if (!lv)
		return null;

	for (let dms in fs.glob("/sys/devices/virtual/block/dm-*")) {
		let f = fs.open(sprintf("%s/dm/name", dms), "r");
		if (!f)
			continue;

		let dm_name = trim(f.read("all"));
		f.close();
		if ( split(lv.lv_dm_path, '/')[-1] == dm_name )
			return split(dms, '/')[-1]
	}
	return null;
}

function lvm_init(ctx) {
	cursor = ctx.cursor;
	fs = ctx.fs;
	if (type(fs.access) == "function" && !fs.access(lvm_exec, "x"))
		return false;

	vg_name = pvs();
	if (!vg_name)
		return false;

	vg = vgs(vg_name);
	uvol_uci_add = ctx.uci_add;
	uvol_uci_commit = ctx.uci_commit;
	uvol_uci_remove = ctx.uci_remove;
	uvol_uci_init = ctx.uci_init;
	return true;
}

function lvm_free() {
	if (!vg || !vg.vg_free_count || !vg.vg_extent_size)
		return 2;

	return sprintf("%d", vg.vg_free_count * vg.vg_extent_size);
}

function lvm_total() {
	if (!vg || !vg.vg_extent_count || !vg.vg_extent_size)
		return 2;

	return sprintf("%d", vg.vg_extent_count * vg.vg_extent_size);
}

function lvm_align() {
	if (!vg || !vg.vg_extent_size)
		return 2;

	return sprintf("%d", vg.vg_extent_size);
}

function lvm_list(vol_name) {
	let vols = [];

	if (!vg_name)
		return vols;

	let res = lvs(vg_name, vol_name);
	for (let lv in res) {
		let vol = {};
		if (substr(lv.lv_name, 3, 1) == ".")
			continue;

		vol.name = substr(lv.lv_name, 3);
		vol.mode = substr(lv.lv_name, 0, 2);
		if (!lv.lv_active) {
			if (vol.mode == "ro")
				vol.mode = "rd";
			if (vol.mode == "rw")
				vol.mode = "wd";
		}
		vol.size = lv.lv_size;
		push(vols, vol);
	}

	return vols;
}

function lvm_size(vol_name) {
	if (!vol_name || !vg_name)
		return 2;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	return sprintf("%d", res[0].lv_size);
}

function lvm_status(vol_name) {
	if (!vol_name || !vg_name)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	let mode = substr(res[0].lv_name, 0, 2);
	if ((mode != "ro" && mode != "rw") || !res[0].lv_active)
		return 1;

	return 0;
}

function lvm_device(vol_name) {
	if (!vol_name || !vg_name)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	let mode = substr(res[0].lv_name, 0, 2);
	if ((mode != "ro" && mode != "rw") || !res[0].lv_active)
		return 22;

	return getdev(res[0]);
}

function lvm_updown(vol_name, up) {
	if (!vol_name || !vg_name)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	let lv = res[0];
	if (!lv.lv_path)
		return 2;

	if (up && (wildcard(lv.lv_path, "/dev/*/wo_*") ||
		   wildcard(lv.lv_path, "/dev/*/wp_*")))
		return 22;

	if (up)
		uvol_uci_commit(vol_name);

	if (lv.lv_active == up)
		return 0;

	if (!up) {
		let devname = getdev(lv);
		if (devname)
			system(sprintf("umount /dev/%s", devname));
	}

	let lvchange_r = lvm("lvchange", up?"-k":"-a", "n", lv.lv_full_name);
	if (up && lvchange_r.retval != 0)
		return lvchange_r.retval;

	lvchange_r = lvm("lvchange", up?"-a":"-k", "y", lv.lv_full_name);
	if (lvchange_r.retval != 0)
		return lvchange_r.retval;

	return 0
}

function lvm_up(vol_name) {
	return lvm_updown(vol_name, true);
}

function lvm_down(vol_name) {
	return lvm_updown(vol_name, false);
}

function lvm_create(vol_name, vol_size, vol_mode) {
	if (!vol_name || !vg_name)
		return 22;

	vol_size = +vol_size;
	if (vol_size <= 0)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (res[0])
		return 17;

	let size_ext = vol_size / vg.vg_extent_size;
	if (vol_size % vg.vg_extent_size)
		++size_ext;
	let lvmode, mode;
	if (vol_mode == "ro" || vol_mode == "wo") {
		lvmode = "r";
		mode = "wo";
	} else if (vol_mode == "rw") {
		lvmode = "rw";
		mode = "wp";
	} else {
		return 22;
	}

	let ret = lvm("lvcreate", "-p", lvmode, "-a", "n", "-y", "-W", "n", "-Z", "n", "-n", sprintf("%s_%s", mode, vol_name), "-l", size_ext, vg_name);
	if (ret.retval != 0 || lvmode == "r")
		return ret.retval;

	let lv = lvs(vg_name, vol_name);
	if (!lv[0] || !lv[0].lv_full_name)
		return 22;

	lv = lv[0];
	let ret = lvm("lvchange", "-a", "y", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	let use_f2fs = (lv.lv_size > (100 * 1024 * 1024));
	if (use_f2fs) {
		let mkfs_ret = system(sprintf("/usr/sbin/mkfs.f2fs -f -l \"%s\" \"%s\"", vol_name, lv.lv_path));
		if (mkfs_ret != 0 && mkfs_ret != 134) {
			lvchange_r = lvm("lvchange", "-a", "n", lv.lv_full_name);
			if (lvchange_r.retval != 0)
				return lvchange_r.retval;
			return mkfs_ret;
		}
	} else {
		let mkfs_ret = system(sprintf("/usr/sbin/mke2fs -F -L \"%s\" \"%s\"", vol_name, lv.lv_path));
		if (mkfs_ret != 0) {
			lvchange_r = lvm("lvchange", "-a", "n", lv.lv_full_name);
			if (lvchange_r.retval != 0)
				return lvchange_r.retval;
			return mkfs_ret;
		}
	}
	uvol_uci_add(vol_name, sprintf("/dev/%s", getdev(lv)), "rw");

	ret = lvm("lvchange", "-a", "n", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	ret = lvm("lvrename", vg_name, sprintf("wp_%s", vol_name), sprintf("rw_%s", vol_name));
	if (ret.retval != 0)
		return ret.retval;

	return 0;
}

function lvm_remove(vol_name) {
	if (!vol_name || !vg_name)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	if (res[0].lv_active)
		return 16;

	let ret = lvm("lvremove", "-y", res[0].lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	uvol_uci_remove(vol_name);
	uvol_uci_commit(vol_name);
	return 0;
}

function lvm_dd(in_fd, out_fd, vol_size) {
	let rem = vol_size;
	let buf;
	while ((buf = in_fd.read(vg.vg_extent_size)) && (rem > 0)) {
		rem -= length(buf);
		if (rem < 0) {
			buf = substr(buf, 0, rem);
		}
		out_fd.write(buf);
	}
	return rem;
}

function lvm_write(vol_name, vol_size) {
	if (!vol_name || !vg_name)
		return 22;

	let lv = lvs(vg_name, vol_name);
	if (!lv[0] || !lv[0].lv_full_name)
		return 2;

	lv = lv[0];
	vol_size = +vol_size;
	if (vol_size > lv.lv_size)
		return 27;

	if (wildcard(lv.lv_path, "/dev/*/wo_*")) {
		let ret = lvm("lvchange", "-p", "rw", lv.lv_full_name);
		if (ret.retval != 0)
			return ret.retval;

		let ret = lvm("lvchange", "-a", "y", lv.lv_full_name);
		if (ret.retval != 0)
			return ret.retval;

		let volfile = fs.open(lv.lv_path, "w");
		let ret = lvm_dd(fs.stdin, volfile, vol_size);
		volfile.close();
		if (ret < 0) {
			printf("more %d bytes data than given size!\n", -ret);
		}

		if (ret > 0) {
			printf("reading finished %d bytes before given size!\n", ret);
		}

		uvol_uci_add(vol_name, sprintf("/dev/%s", getdev(lv)), "ro");

		let ret = lvm("lvchange", "-a", "n", lv.lv_full_name);
		if (ret.retval != 0)
			return ret.retval;

		let ret = lvm("lvchange", "-p", "r", lv.lv_full_name);
		if (ret.retval != 0)
			return ret.retval;

		let ret = lvm("lvrename", vg_name, sprintf("wo_%s", vol_name), sprintf("ro_%s", vol_name));
		if (ret.retval != 0)
			return ret.retval;

	} else {
		return 22;
	}
	return 0;
}

function lvm_detect() {
	let temp_up = [];
	let inactive_lv = lvs(vg_name, null, "lv_skip_activation!=0");
	for (let lv in inactive_lv) {
		lvm("lvchange", "-k", "n", lv.lv_full_name);
		lvm("lvchange", "-a", "y", lv.lv_full_name);
		push(temp_up, lv.lv_full_name);
	}
	sleep(1000);
	uvol_uci_init();
	for (let lv in lvs(vg_name)) {
		let vol_name = substr(lv.lv_name, 3);
		let vol_mode = substr(lv.lv_name, 0, 2);
		uvol_uci_add(vol_name, sprintf("/dev/%s", getdev(lv)), vol_mode);
	}
	uvol_uci_commit();
	for (let lv_full_name in temp_up) {
		lvm("lvchange", "-a", "n", lv_full_name);
		lvm("lvchange", "-k", "y", lv_full_name);
	}
	return 0;
}

function lvm_boot() {
	return 0;
}

backend.backend = "LVM";
backend.priority = 50;
backend.init = lvm_init;
backend.boot = lvm_boot;
backend.detect = lvm_detect;
backend.free = lvm_free;
backend.align = lvm_align;
backend.total = lvm_total;
backend.list = lvm_list;
backend.size = lvm_size;
backend.status = lvm_status;
backend.device = lvm_device;
backend.up = lvm_up;
backend.down = lvm_down;
backend.create = lvm_create;
backend.remove = lvm_remove;
backend.write = lvm_write;
