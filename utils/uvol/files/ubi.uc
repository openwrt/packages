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

function block_hotplug(action, devname) {
	return system(sprintf("ACTION=%s DEVNAME=%s /sbin/block hotplug", action, devname));
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

	uvol_uci_add = ctx.uci_add;
	uvol_uci_commit = ctx.uci_commit;
	uvol_uci_remove = ctx.uci_remove;
	uvol_uci_init = ctx.uci_init;

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
	let vol_dev = ubi_get_dev(vol_name);
	if (vol_dev)
		return 17;

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

	uvol_uci_add(vol_name, sprintf("/dev/%s", vol_dev), "rw");

	let ret = system(sprintf("ubirename /dev/%s \"uvol-wp-%s\" \"uvol-wd-%s\"", ubidev, vol_name, vol_name));
	if (ret != 0)
		return ret;

	return 0;
}

function ubi_remove(vol_name) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode == "rw" || vol_mode == "ro")
		return 16;

	let volnum = split(vol_dev, "_")[1];

	let ret = system(sprintf("ubirmvol /dev/%s -n %d", ubidev, volnum));
	if (ret != 0)
		return ret;

	uvol_uci_remove(vol_name);
	uvol_uci_commit(vol_name);

	return 0;
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

	uvol_uci_commit(vol_name);
	if (vol_mode == "rd") {
		let ret = system(sprintf("ubirename /dev/%s \"uvol-rd-%s\" \"uvol-ro-%s\"", ubidev, vol_name, vol_name));
		if (ret != 0)
			return ret;

		return system(sprintf("ubiblock --create /dev/%s", vol_dev));
	} else if (vol_mode == "wd") {
		let ret = system(sprintf("ubirename /dev/%s \"uvol-wd-%s\" \"uvol-rw-%s\"", ubidev, vol_name, vol_name));
		if (ret != 0)
			return ret;

		return block_hotplug("add", vol_dev);
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
		system(sprintf("umount /dev/ubiblock%s 2>&1 >/dev/null", substr(vol_dev, 3)));
		system(sprintf("ubiblock --remove /dev/%s", vol_dev));
		let ret = system(sprintf("ubirename /dev/%s \"uvol-ro-%s\" \"uvol-rd-%s\"", ubidev, vol_name, vol_name));
		return ret;
	} else if (vol_mode == "rw") {
		system(sprintf("umount /dev/%s 2>&1 >/dev/null", vol_dev));
		let ret = system(sprintf("ubirename /dev/%s \"uvol-rw-%s\" \"uvol-wd-%s\"", ubidev, vol_name, vol_name));
		block_hotplug("remove", vol_dev);
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

function ubi_detect() {
	let tmpdev = [];
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));

		if (!wildcard(vol_ubiname, "uvol-r[od]-*"))
			continue;

		let vol_name = substr(vol_ubiname, 8);
		let vol_mode = substr(vol_ubiname, 5, 2);
		let vol_dev = fs.basename(vol_dir);

		ret = system(sprintf("ubiblock --create /dev/%s", vol_dev));
		if (ret)
			continue;

		if (vol_mode == "rd")
			push(tmpdev, vol_dev);
	}

	uvol_uci_init();

	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));
		if (!wildcard(vol_ubiname, "uvol-[rw][wod]-*"))
			continue;

		let vol_dev = fs.basename(vol_dir);
		let vol_name = substr(vol_ubiname, 8);
		let vol_mode = substr(vol_ubiname, 5, 2);

		if (vol_mode == "ro" || vol_mode == "rd")
			uvol_uci_add(vol_name, sprintf("/dev/ubiblock%s", substr(vol_dev, 3)), "ro");
		else if (vol_mode == "rw" || vol_mode == "wd")
			uvol_uci_add(vol_name, sprintf("/dev/%s", vol_dev), "rw");
	}

	uvol_uci_commit();

	for (vol_dev in tmpdev)
		system(sprintf("ubiblock --remove /dev/%s", vol_dev));

	return 0;
}

function ubi_boot() {
	for (vol_dir in fs.glob(sprintf("/sys/class/ubi/%s_*", ubidev))) {
		let vol_dev = fs.basename(vol_dir);
		let vol_ubiname = read_file(sprintf("%s/name", vol_dir));

		if (!wildcard(vol_ubiname, "uvol-ro-*"))
			continue;

		system(sprintf("ubiblock --create /dev/%s", vol_dev));
	}
}

function ubi_write(vol_name, write_size) {
	let vol_dev = ubi_get_dev(vol_name);
	if (!vol_dev)
		return 2;

	write_size = +write_size;
	if (write_size <= 0)
		return 22;

	let vol_mode = vol_get_mode(vol_dev);
	if (vol_mode != "wo")
		return 22;

	let ret = system(sprintf("ubiupdatevol -s %s /dev/%s -", write_size, vol_dev));
	if (ret)
		return ret;

	system(sprintf("ubiblock --create /dev/%s", vol_dev));
	uvol_uci_add(vol_name, sprintf("/dev/ubiblock%s", substr(vol_dev, 3)), "ro");
	system(sprintf("ubiblock --remove /dev/%s", vol_dev));
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
backend.remove = ubi_remove;
backend.write = ubi_write;
