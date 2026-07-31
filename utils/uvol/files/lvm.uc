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
	let fstab = cursor ? cursor.get_all('fstab') : null;
	for (let k, section in (fstab ?? {})) {
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

function lvs_deleting(vg_name) {
	let ret = [];
	let tmp = lvm("lvs", "-o", "lv_active,lv_name,lv_full_name,lv_dm_path", "-S",
		      sprintf("\"lvname=~^dd_.* && vg_name=%s\"", vg_name));
	if (tmp && tmp.report.lv) {
		ret = tmp.report.lv;
		for (let r in ret)
			r.lv_active = (r.lv_active == "active");
	}
	return ret;
}

function lvs_incomplete(vg_name, vol_name) {
	let ret = [];
	let tmp = lvm("lvs", "-o", "lv_active,lv_name,lv_full_name,lv_size", "-S",
		      sprintf("\"lvname=~^w[op]_%s\$ && vg_name=%s\"", vol_name ?? ".*", vg_name));
	if (tmp && tmp.report.lv) {
		ret = tmp.report.lv;
		for (let r in ret) {
			r.lv_active = (r.lv_active == "active");
			r.lv_size = +(rtrim(r.lv_size, "B"));
		}
	}
	return ret;
}

// purge incomplete (wo_/wp_) leftovers; with match_size, only those of exactly
// that allocated size (null purges all)
function lvm_purge_incomplete(vol_name, match_size) {
	for (let lv in lvs_incomplete(vg_name, vol_name)) {
		if (match_size != null && lv.lv_size != match_size)
			continue;
		if (lv.lv_active)
			lvm("lvchange", "-a", "n", lv.lv_full_name);
		lvm("lvremove", "-y", lv.lv_full_name);
	}
	return 0;
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
	register = ctx.register;
	unregister = ctx.unregister;
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
	if (mode == "wo")
		return 22;
	if (mode == "wp")
		return 16;
	if (!res[0].lv_active)
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

	if (!up) {
		let devname = getdev(lv);
		if (devname) {
			unregister(devname);
			system(sprintf("umount /dev/%s 2>/dev/null", devname));
		}
	}

	if (lv.lv_active != up) {
		let lvchange_r = lvm("lvchange", up?"-k":"-a", "n", lv.lv_full_name);
		if (up && lvchange_r.retval != 0)
			return lvchange_r.retval;

		lvchange_r = lvm("lvchange", up?"-a":"-k", "y", lv.lv_full_name);
		if (lvchange_r.retval != 0)
			return lvchange_r.retval;
	}

	if (up)
		return register(vol_name, getdev(lv), substr(lv.lv_name, 0, 2) == "ro");

	return 0;
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
	if (vol_size != vol_size || vol_size <= 0)
		return 22;

	let size_ext = vol_size / vg.vg_extent_size;
	if (vol_size % vg.vg_extent_size)
		++size_ext;

	// reclaim only an exact name+size retry; a size mismatch surfaces as EEXIST
	lvm_purge_incomplete(vol_name, size_ext * vg.vg_extent_size);

	let res = lvs(vg_name, vol_name);
	if (res[0])
		return 17;

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
		let mkfs_ret = system(sprintf("/usr/sbin/mke2fs -F -t ext4 -O has_journal -L \"%s\" \"%s\"", vol_name, lv.lv_path));
		if (mkfs_ret != 0) {
			lvchange_r = lvm("lvchange", "-a", "n", lv.lv_full_name);
			if (lvchange_r.retval != 0)
				return lvchange_r.retval;
			return mkfs_ret;
		}
	}

	ret = lvm("lvchange", "-a", "n", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	ret = lvm("lvrename", vg_name, sprintf("wp_%s", vol_name), sprintf("rw_%s", vol_name));
	if (ret.retval != 0)
		return ret.retval;

	return 0;
}

// identify the on-disk filesystem by superblock magic (no external tool needed)
function fs_type(devpath) {
	let f = fs.open(devpath, "r");
	if (!f)
		return null;
	f.seek(1024);
	let sb = f.read(58);
	f.close();
	if (type(sb) != "string" || length(sb) < 58)
		return null;
	if (ord(sb, 0) == 0x10 && ord(sb, 1) == 0x20 && ord(sb, 2) == 0xf5 && ord(sb, 3) == 0xf2)
		return "f2fs";
	if (ord(sb, 56) == 0x53 && ord(sb, 57) == 0xef)
		return "ext";
	return null;
}

// Grow a rw volume in place; the fs (ext4 or f2fs, chosen at create by size) is
// grown with its own tool. Shrink is refused. The fs-grow tool is an optional
// dependency: if absent, report and refuse rather than grow the LV past the fs.
function lvm_resize(vol_name, vol_size) {
	if (!vol_name || !vg_name)
		return 22;

	vol_size = +vol_size;
	if (vol_size != vol_size || vol_size <= 0)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	if (substr(res[0].lv_name, 0, 2) != "rw")
		return 1;

	let size_ext = vol_size / vg.vg_extent_size;
	if (vol_size % vg.vg_extent_size)
		++size_ext;

	let new_size = size_ext * vg.vg_extent_size;
	if (new_size == +res[0].lv_size)
		return 0;
	if (new_size < +res[0].lv_size)
		return 22;

	let dev = getdev(res[0]);
	if (!dev)
		return 2;

	let fstype = fs_type(sprintf("/dev/%s", dev));
	let tool = (fstype == "f2fs") ? "resize.f2fs" : (fstype == "ext") ? "resize2fs" : null;
	if (!tool) {
		warn(sprintf("uvol: cannot identify filesystem on %s; not resizing\n", vol_name));
		return 95;
	}

	// the fs-grow tool first, so the LV is never left larger than its filesystem
	if (system(sprintf("command -v %s >/dev/null 2>&1", tool)) != 0) {
		warn(sprintf("uvol: %s not found; install %s to grow this %s volume\n",
			     tool, (fstype == "f2fs") ? "f2fs-tools" : "e2fsprogs", fstype));
		return 95;
	}

	let ret = lvm("lvextend", "-l", size_ext, res[0].lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	if (fstype == "f2fs")
		return system(sprintf("resize.f2fs /dev/%s", dev));

	return system(sprintf("resize2fs /dev/%s", dev));
}

// Reap volumes marked for deferred deletion (dd_ prefix). A volume can only be
// reaped once its backing device has no holder; blockd signals that moment with
// a mount.umount notification (autofs idle-expiry), which triggers 'uvol reap'.
// Still-held volumes are left for the next signal (or the boot sweep).
function lvm_reap() {
	for (let dd in lvs_deleting(vg_name)) {
		let dev = getdev(dd);
		if (dd.lv_active) {
			let r = lvm("lvchange", "-a", "n", dd.lv_full_name);
			if (r.retval != 0)
				continue;
		}
		if (dev)
			unregister(dev);
		lvm("lvremove", "-y", dd.lv_full_name);
	}
	return 0;
}

function lvm_remove(vol_name) {
	if (!vol_name || !vg_name)
		return 22;

	let res = lvs(vg_name, vol_name);
	if (!res[0])
		return 2;

	// mark for deletion: rename to the dd_ state (works whether the volume is
	// active or not, and hides it from list/status). reap removes it now if the
	// device is already free, otherwise blockd's mount.umount triggers reap once
	// the holder releases it.
	let ret = lvm("lvrename", vg_name, res[0].lv_name, sprintf("dd_%s", vol_name));
	if (ret.retval != 0)
		return ret.retval;

	return lvm_reap();
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

function lvm_write(vol_name, vol_size, verify) {
	if (!vol_name || !vg_name)
		return 22;

	let lv = lvs(vg_name, vol_name);
	if (!lv[0] || !lv[0].lv_full_name)
		return 2;

	lv = lv[0];
	vol_size = +vol_size;
	if (vol_size > lv.lv_size)
		return 27;

	if (!wildcard(lv.lv_path, "/dev/*/wo_*"))
		return 22;

	let ret = lvm("lvchange", "-p", "rw", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	let ret = lvm("lvchange", "-a", "y", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	let volfile = fs.open(lv.lv_path, "w");
	let rem = lvm_dd(fs.stdin, volfile, vol_size);
	volfile.close();
	if (rem < 0) {
		printf("more %d bytes data than given size!\n", -rem);
	}

	if (rem > 0) {
		printf("reading finished %d bytes before given size!\n", rem);
	}

	if (verify && !verify(lv.lv_path)) {
		lvm("lvchange", "-a", "n", lv.lv_full_name);
		lvm("lvchange", "-p", "r", lv.lv_full_name);
		return 74;
	}

	let ret = lvm("lvchange", "-a", "n", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	let ret = lvm("lvchange", "-p", "r", lv.lv_full_name);
	if (ret.retval != 0)
		return ret.retval;

	let ret = lvm("lvrename", vg_name, sprintf("wo_%s", vol_name), sprintf("ro_%s", vol_name));
	if (ret.retval != 0)
		return ret.retval;

	return 0;
}

function lvm_detect() {
	for (let lv in lvs(vg_name)) {
		if (!lv.lv_active)
			continue;

		let mode = substr(lv.lv_name, 0, 2);
		if (mode != "ro" && mode != "rw")
			continue;

		register(substr(lv.lv_name, 3), getdev(lv), mode == "ro");
	}
	return 0;
}

function lvm_boot() {
	// clear crash/power-loss leftovers before activating
	lvm_reap();
	lvm_purge_incomplete();
	for (let lv in lvs(vg_name, null, "lv_skip_activation=0")) {
		let mode = substr(lv.lv_name, 0, 2);
		if (mode != "ro" && mode != "rw")
			continue;

		lvm_up(substr(lv.lv_name, 3));
	}
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
backend.resize = lvm_resize;
backend.remove = lvm_remove;
backend.reap = lvm_reap;
backend.write = lvm_write;
