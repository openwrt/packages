// SPDX-License-Identifier: GPL-2.0-or-later
// UBI backend for uvol
//  (c) 2022 Daniel Golle <daniel@makrotopia.org>
//
// This plugin uses UBI on NAND flash as a storage backend for uvol.

function read_file(file) {
	let fp = fs.open(file);
	if (!fp)
		return null;

	let var = rtrim(fp.read("all"));
	fp.close();
	return var;
}

function mkdtemp() {
	math = require("math");
	let r1 = math.rand();
	let r2 = math.rand();
	let randbytes = chr((r1 >> 24) & 0xff, (r1 >> 16) & 0xff, (r1 >> 8) & 0xff, r1 & 0xff,
			    (r2 >> 24) & 0xff, (r2 >> 16) & 0xff, (r2 >> 8) & 0xff, r2 & 0xff);

	let randstr = replace(b64enc(randbytes), /[\/-_.=]/g, "");
	let dirname = sprintf("/tmp/uvol-%s", randstr);
	fs.mkdir(dirname, 0700);
	return dirname;
}

function ubi_get_dev(vol_name) {
	let wcstring = sprintf("uvol-[rw][owpd]-%s", vol_name);
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (wildcard(vol_ubiname, wcstring))
			return fs.basename(vol_dir);
	}
	return null;
}

function vol_get_mode(vol_dev, mode) {
	let vol_name = read_file(sprintf("/sys/class/ubi/%s/name", vol_dev));
	return substr(vol_name, 5, 2);
}

function mkubifs(vol_dev) {
	let temp_mp = mkdtemp();
	system(sprintf("mount -t ubifs /dev/%s %s", vol_dev, temp_mp));
	system(sprintf("umount %s", temp_mp));
	fs.rmdir(temp_mp);
	return 0;
}

function ubi_init(ctx) {
	cursor = ctx.cursor;
	fs = ctx.fs;
	ubidev = null;

	let ubiver = read_file("/sys/class/ubi/version");
	if (ubiver != 1)
		return false;

	for (ubidevpath in fs.glob("/sys/class/ubi/*")) {
		if (!fs.stat(sprintf("%s/eraseblock_size", ubidevpath)))
			continue;

		ubidev = fs.basename(ubidevpath);
		break;
	}

	if (!ubidev)
		return false;

	ebsize = read_file(sprintf("%s/eraseblock_size", ubidevpath));

	register = ctx.register;
	unregister = ctx.unregister;

	return true;
}

function ubi_free() {
	let availeb = read_file(sprintf("/sys/class/ubi/%s/avail_eraseblocks", ubidev));
	return sprintf("%d", availeb * ebsize);
}

function ubi_align() {
	return sprintf("%d", ebsize);
}

function ubi_total() {
	let totaleb = read_file(sprintf("/sys/class/ubi/%s/total_eraseblocks", ubidev));
	return sprintf("%d", totaleb * ebsize);
}

function ubi_status(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode == "wo") return 22;
	if (vol_mode == "wp") return 16;
	if (vol_mode == "wd") return 1;
	if (vol_mode == "ro" &&
	    !fs.access(sprintf("/dev/ubiblock%s", substr(vol_dev, 3)), "r")) return 1;

	return 0;
}

function ubi_size(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_size = read_file(sprintf("/sys/class/ubi/%s/data_bytes", vol_dev));
	return sprintf("%d", vol_size);
}

function ubi_device(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode == "ro")
		return sprintf("/dev/ubiblock%s", substr(vol_dev, 3));
	else if (vol_mode == "rw")
		return sprintf("/dev/%s", vol_dev);

	return null;
}

function ubi_create(vol_name, vol_size, vol_mode) {
	let mode;
	if (vol_mode == "ro" || vol_mode == "wo")
		mode = "wo";
	else if (vol_mode == "rw")
		mode = "wp";
	else
		return 22;

	let vol_size = +vol_size;
	if (vol_size <= 0)
		return 22;

	ubi_purge_incomplete(vol_name, vol_size);

	let vol_dev = ubi_get_dev(vol_name);
	if (vol_dev)
		return 17;

	let ret = system(sprintf("ubimkvol /dev/%s -N \"uvol-%s-%s\" -s %d", ubidev, mode, vol_name, vol_size));
	if (ret != 0)
		return ret;

	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let ret = system(sprintf("ubiupdatevol -t /dev/%s", vol_dev));
	if (ret != 0)
		return ret;

	if (mode != "wp")
		return 0;

	let ret = mkubifs(vol_dev);
	if (ret != 0)
		return ret;

	let ret = system(sprintf("ubirename /dev/%s \"uvol-wp-%s\" \"uvol-wd-%s\"", ubidev, vol_name, vol_name));
	if (ret != 0)
		return ret;

	return 0;
}

// Grow a rw volume; UBIFS uses the new size directly. Shrink is refused.
function ubi_resize(vol_name, vol_size) {
	vol_size = +vol_size;
	if (vol_size <= 0)
		return 22;

	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	if (vol_get_mode(vol_dev) != "rw")
		return 1;

	let leb = +read_file(sprintf("/sys/class/ubi/%s/usable_eb_size", vol_dev));
	let cur_lebs = +read_file(sprintf("/sys/class/ubi/%s/reserved_ebs", vol_dev));
	let req_lebs = vol_size / leb;
	if (vol_size % leb)
		++req_lebs;

	if (req_lebs == cur_lebs)
		return 0;
	if (req_lebs < cur_lebs)
		return 22;

	return system(sprintf("ubirsvol /dev/%s -N \"uvol-rw-%s\" -s %d", ubidev, vol_name, vol_size));
}

function ubi_get_deleting() {
	let ret = [];
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (!wildcard(vol_ubiname, "uvol-dd-*"))
			continue;

		push(ret, fs.basename(vol_dir));
	}
	return ret;
}

function ubi_get_incomplete(vol_name) {
	let ret = [];
	let pat = vol_name ? sprintf("uvol-w[op]-%s", vol_name) : "uvol-w[op]-*";
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (!wildcard(vol_ubiname, pat))
			continue;
		push(ret, {
			dev: fs.basename(vol_dir),
			lebs: +read_file(sprintf("%s/reserved_ebs", vol_dir)),
			leb: +read_file(sprintf("%s/usable_eb_size", vol_dir)),
		});
	}
	return ret;
}

// purge incomplete (wo/wp) leftovers; with match_size, only those whose
// reservation matches that size (null purges all)
function ubi_purge_incomplete(vol_name, match_size) {
	for (let v in ubi_get_incomplete(vol_name)) {
		if (match_size != null) {
			if (!v.leb || !v.lebs)
				continue;
			let want = match_size / v.leb;
			if (match_size % v.leb)
				want++;
			if (v.lebs != want)
				continue;
		}
		let volnum = split(v.dev, "_")[1];
		system(sprintf("ubirmvol /dev/%s -n %d 2>/dev/null", ubidev, volnum));
	}
	return 0;
}

function ubi_reap() {
	for (let vol_dev in ubi_get_deleting()) {
		let volnum = split(vol_dev, "_")[1];
		let blkdev = sprintf("ubiblock%s", substr(vol_dev, 3));
		let isblock = fs.access(sprintf("/dev/%s", blkdev), "r");

		if (isblock && system(sprintf("ubiblock --remove /dev/%s 2>/dev/null", vol_dev)) != 0)
			continue;

		if (!isblock)
			system(sprintf("umount /dev/%s 2>/dev/null", vol_dev));

		if (system(sprintf("ubirmvol /dev/%s -n %d 2>/dev/null", ubidev, volnum)) != 0)
			continue;

		unregister(isblock ? blkdev : vol_dev);
	}
	return 0;
}

function ubi_remove(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_ubiname = read_file(sprintf("/sys/class/ubi/%s/name", vol_dev));
	let ret = system(sprintf("ubirename /dev/%s \"%s\" \"uvol-dd-%s\"", ubidev, vol_ubiname, vol_name));
	if (ret != 0)
		return ret;

	return ubi_reap();
}

function ubi_up(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode == "rw" || vol_mode == "ro")
		return 0;
	else if (vol_mode == "wo")
		return 22;
	else if (vol_mode == "wp")
		return 16;

	if (vol_mode == "rd") {
		let ret = system(sprintf("ubirename /dev/%s \"uvol-rd-%s\" \"uvol-ro-%s\"", ubidev, vol_name, vol_name));
		if (ret != 0)
			return ret;

		ret = system(sprintf("ubiblock --create /dev/%s", vol_dev));
		if (ret != 0)
			return ret;

		return register(vol_name, sprintf("ubiblock%s", substr(vol_dev, 3)), true);
	} else if (vol_mode == "wd") {
		let ret = system(sprintf("ubirename /dev/%s \"uvol-wd-%s\" \"uvol-rw-%s\"", ubidev, vol_name, vol_name));
		if (ret != 0)
			return ret;

		return register(vol_name, vol_dev, false);
	}
	return 0;
}

function ubi_down(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode == "rd" || vol_mode == "wd")
		return 0;
	else if (vol_mode == "wo")
		return 22;
	else if (vol_mode == "wp")
		return 16;
	else if (vol_mode == "ro") {
		unregister(sprintf("ubiblock%s", substr(vol_dev, 3)));
		system(sprintf("umount /dev/ubiblock%s 2>&1 >/dev/null", substr(vol_dev, 3)));
		system(sprintf("ubiblock --remove /dev/%s", vol_dev));
		let ret = system(sprintf("ubirename /dev/%s \"uvol-ro-%s\" \"uvol-rd-%s\"", ubidev, vol_name, vol_name));
		return ret;
	} else if (vol_mode == "rw") {
		unregister(vol_dev);
		system(sprintf("umount /dev/%s 2>&1 >/dev/null", vol_dev));
		let ret = system(sprintf("ubirename /dev/%s \"uvol-rw-%s\" \"uvol-wd-%s\"", ubidev, vol_name, vol_name));
		return ret;
	}
	return 0;
}

function ubi_list(search_name) {
	let volumes = [];
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol = {};
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (!wildcard(vol_ubiname, "uvol-[rw][wod]-*"))
			continue;

		let vol_mode = substr(vol_ubiname, 5, 2);
		let vol_name = substr(vol_ubiname, 8);
		let vol_size = read_file(sprintf("%s/data_bytes", vol_dir));
		if (substr(vol_name, 0, 1) == ".")
			continue;

		vol.name = vol_name;
		vol.mode = vol_mode;
		vol.size = vol_size;
		push(volumes, vol);
	}
	return volumes;
}

function ubi_register_active() {
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (!wildcard(vol_ubiname, "uvol-r[ow]-*"))
			continue;

		let vol_dev = fs.basename(vol_dir);
		let vol_name = substr(vol_ubiname, 8);
		let vol_mode = substr(vol_ubiname, 5, 2);

		if (vol_mode == "ro") {
			system(sprintf("ubiblock --create /dev/%s", vol_dev));
			register(vol_name, sprintf("ubiblock%s", substr(vol_dev, 3)), true);
		} else {
			register(vol_name, vol_dev, false);
		}
	}
	return 0;
}

function ubi_detect() {
	return ubi_register_active();
}

function ubi_boot() {
	// clear crash/power-loss leftovers before activating
	ubi_reap();
	ubi_purge_incomplete();
	return ubi_register_active();
}

function ubi_write(vol_name, write_size, verify) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	write_size = +write_size;
	if (write_size <= 0)
		return 22;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode != "wo")
		return 22;

	let ret = system(sprintf("ubiupdatevol -s %d /dev/%s -", write_size, vol_dev));
	if (ret)
		return ret;

	if (verify && !verify(sprintf("/dev/%s", vol_dev)))
		return 74;

	system(sprintf("ubirename /dev/%s \"uvol-wo-%s\" \"uvol-rd-%s\"", ubidev, vol_name, vol_name));

	return 0;
}

backend.backend = "UBI";
backend.priority = 20;
backend.init = ubi_init;
backend.boot = ubi_boot;
backend.detect = ubi_detect;
backend.free = ubi_free;
backend.align = ubi_align;
backend.total = ubi_total;
backend.list = ubi_list;
backend.size = ubi_size;
backend.status = ubi_status;
backend.device = ubi_device;
backend.up = ubi_up;
backend.down = ubi_down;
backend.create = ubi_create;
backend.resize = ubi_resize;
backend.remove = ubi_remove;
backend.reap = ubi_reap;
backend.write = ubi_write;
