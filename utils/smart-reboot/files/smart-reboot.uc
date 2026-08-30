#!/usr/bin/ucode
'use strict';

import * as uci from "uci";
import * as uloop from "uloop";
import * as log from "log";
import * as fs from "fs";
import * as ubus from "ubus";

const CFG = "smart-reboot";
const SECTION = "settings";
const LOCK_FILE = "/var/lock/smart-reboot.lock";
const STATE_FILE = "/etc/smart-reboot.date";

log.openlog("smart-reboot", log.LOG_PID);

function logger(level, msg) {
	log.syslog(level, msg);
}

function parse_hhmm(str, def_h, def_m) {
	if (!str || type(str) != "string")
		return { hour: def_h, min: def_m };

	let m = match(str, /^([0-9]{1,2}):([0-9]{1,2})$/);
	if (!m)
		return { hour: def_h, min: def_m };

	let h = int(m[1]);
	let min = int(m[2]);

	if (!(h >= 0 && h <= 23 && min >= 0 && min <= 59))
		return { hour: def_h, min: def_m };

	return { hour: h, min: min };
}

function is_in_window(w_start, w_end, now) {
	let now_m = now.hour * 60 + now.min;
	let s_m = w_start.hour * 60 + w_start.min;
	let e_m = w_end.hour * 60 + w_end.min;

	if (s_m <= e_m)
		return (now_m >= s_m && now_m < e_m);
	else
		return (now_m >= s_m || now_m < e_m);
}

function get_seconds_until(target_hour, target_min, now) {
	let now_sec = now.hour * 3600 + now.min * 60 + now.sec;
	let target_sec = target_hour * 3600 + target_min * 60;
	let diff = target_sec - now_sec;

	if (diff <= 0)
		diff += 86400;

	return diff;
}

function resolve_interfaces(u, cfg_ifaces) {
	if (cfg_ifaces == "all" || (type(cfg_ifaces) == "array" && index(cfg_ifaces, "all") >= 0))
		return null;

	let resolved = {};
	let list = [];

	if (type(cfg_ifaces) == "array")
		list = cfg_ifaces;
	else if (type(cfg_ifaces) == "string" && length(trim(cfg_ifaces)))
		list = split(trim(cfg_ifaces), /[ \t\r\n]+/);

	if (length(list)) {
		for (let name in list) {
			if (!name)
				continue;

			if (fs.stat(`/sys/class/net/${name}`)) {
				resolved[name] = true;
				continue;
			}

			if (u) {
				try {
					let st = u.call(`network.interface.${name}`, "status");
					let dev = st?.l3_device || st?.device;
					if (dev && fs.stat(`/sys/class/net/${dev}`))
						resolved[dev] = true;
				} catch (e) {}
			}
		}
		return resolved;
	}

	if (u) {
		try {
			let dump = u.call("network.interface", "dump");
			for (let iface in dump?.interface || []) {
				if (iface.up && (iface.interface == "wan" || length(iface.route || []))) {
					let dev = iface.l3_device || iface.device;
					if (dev && fs.stat(`/sys/class/net/${dev}`))
						resolved[dev] = true;
				}
			}
		} catch (e) {}
	}

	return resolved;
}

function get_traffic_snapshot(target_devs) {
	let raw = fs.readfile("/proc/net/dev");
	if (!raw)
		return null;

	let snap = {};
	for (let line in split(raw, "\n")) {
		let colon = index(line, ":");
		if (colon < 0)
			continue;

		let dev = trim(substr(line, 0, colon));
		if (!length(dev) || dev == "lo")
			continue;

		if (target_devs && !target_devs[dev])
			continue;

		let fields = filter(split(trim(substr(line, colon + 1)), /[ \t]+/), length);
		if (length(fields) < 9)
			continue;

		let rx = int(fields[0]);
		let tx = int(fields[8]);

		snap[dev] = {
			rx: (rx >= 0) ? rx : 0,
			tx: (tx >= 0) ? tx : 0
		};
	}
	return snap;
}

function calc_total_delta(snap1, snap2) {
	let total = 0;

	for (let dev, s1 in snap1) {
		let s2 = snap2[dev];
		if (!s2)
			continue;

		let drx = (s2.rx >= s1.rx) ? (s2.rx - s1.rx) : s2.rx;
		let dtx = (s2.tx >= s1.tx) ? (s2.tx - s1.tx) : s2.tx;
		total += (drx + dtx);
	}

	return total;
}

function record_auto_reboot(now) {
	let ts = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
		now.year, now.mon, now.mday, now.hour, now.min, now.sec);
	fs.writefile(STATE_FILE, ts);
}

function run_check(is_cli_force) {
	let cursor = uci.cursor();
	let enabled = cursor.get(CFG, SECTION, "enabled");

	if (enabled != "1" && !is_cli_force)
		return;

	let now = localtime(time());

	if (!is_cli_force && !(now.year >= 2020)) {
		logger(log.LOG_WARNING, "System clock not synchronized via NTP yet. Retrying in 15s.");
		uloop.timer(15000, () => run_check(false));
		return;
	}

	let raw_start = cursor.get(CFG, SECTION, "window_start");
	let raw_end = cursor.get(CFG, SECTION, "window_end");
	let w_start = parse_hhmm(raw_start, 3, 0);
	let w_end = parse_hhmm(raw_end, (w_start.hour + 3) % 24, w_start.min);

	if (!is_cli_force) {
		let uptime_raw = fs.readfile("/proc/uptime");
		if (uptime_raw) {
			let up_sec = int(split(trim(uptime_raw), " ")[0]);
			if (!(up_sec >= 300)) {
				logger(log.LOG_INFO, `Uptime is ${up_sec}s (< 300s). Skipping check to prevent reboot loop.`);
				uloop.timer(60000, () => run_check(false));
				return;
			}
		}

		let last_reboot = trim(fs.readfile(STATE_FILE) || "");
		let today_str = sprintf("%04d-%02d-%02d", now.year, now.mon, now.mday);
		if (last_reboot && index(last_reboot, today_str) == 0) {
			logger(log.LOG_INFO, `Already rebooted today (${last_reboot}). Waiting for next day window.`);
			let delay = get_seconds_until(w_start.hour, w_start.min, now);
			uloop.timer(delay * 1000, () => run_check(false));
			return;
		}
	}

	let sample_sec = int(cursor.get(CFG, SECTION, "sample_seconds") || "60");
	if (!(sample_sec >= 10))
		sample_sec = 60;

	let check_int = int(cursor.get(CFG, SECTION, "check_interval") || "300");
	if (!(check_int >= 10))
		check_int = 300;

	let threshold_kb = int(cursor.get(CFG, SECTION, "threshold_kb") || "256");
	if (!(threshold_kb >= 0))
		threshold_kb = 256;
	let byte_thresh = threshold_kb * 1024;

	if (!is_cli_force && !is_in_window(w_start, w_end, now)) {
		let delay = get_seconds_until(w_start.hour, w_start.min, now);
		logger(log.LOG_INFO, `Outside dawn window (${w_start.hour}:${w_start.min} - ${w_end.hour}:${w_end.min}). Sleeping for ${delay}s.`);
		uloop.timer(delay * 1000, () => run_check(false));
		return;
	}

	let u = null;
	try {
		u = ubus.connect();
	} catch (e) {}

	let target_devs = resolve_interfaces(u, cursor.get(CFG, SECTION, "ifaces"));
	let dev_names = (target_devs == null) ? "all non-lo" : join(", ", keys(target_devs));

	let snap1 = get_traffic_snapshot(target_devs);
	if (!snap1 || !length(keys(snap1))) {
		logger(log.LOG_WARNING, "No target network interfaces active. Retrying in 60s.");
		if (!is_cli_force)
			uloop.timer(60000, () => run_check(false));
		return;
	}

	logger(log.LOG_INFO, `Sampling traffic on [${dev_names}] for ${sample_sec}s (threshold=${byte_thresh}B)...`);

	if (is_cli_force) {
		sleep(sample_sec * 1000);
		let snap2 = get_traffic_snapshot(target_devs);
		if (!snap2) {
			logger(log.LOG_ERR, "Failed to capture second traffic snapshot");
			return;
		}
		let delta = calc_total_delta(snap1, snap2);
		if (delta <= byte_thresh) {
			logger(log.LOG_INFO, `[TEST MODE] Network IDLE confirmed (delta=${delta}B <= ${byte_thresh}B). System would reboot.`);
		} else {
			logger(log.LOG_INFO, `[TEST MODE] Network ACTIVE (delta=${delta}B > ${byte_thresh}B). Reboot skipped.`);
		}
		return;
	}

	uloop.timer(sample_sec * 1000, function() {
		cursor.unload(CFG);
		cursor.load(CFG);
		if (cursor.get(CFG, SECTION, "enabled") != "1") {
			logger(log.LOG_INFO, "Service disabled during sampling. Aborting reboot.");
			return;
		}

		let snap2 = get_traffic_snapshot(target_devs);
		if (!snap2) {
			logger(log.LOG_ERR, "Failed to capture second traffic snapshot. Retrying later.");
			uloop.timer(check_int * 1000, () => run_check(false));
			return;
		}

		let delta = calc_total_delta(snap1, snap2);

		if (delta <= byte_thresh) {
			logger(log.LOG_INFO, `Network idle confirmed (delta=${delta}B <= threshold=${byte_thresh}B). Triggering smart reboot now.`);
			record_auto_reboot(localtime(time()));
			system("/bin/sync");
			system("/sbin/reboot");
		} else {
			logger(log.LOG_INFO, `Network active (delta=${delta}B > threshold=${byte_thresh}B). Retrying in ${check_int}s.`);
			uloop.timer(check_int * 1000, () => run_check(false));
		}
	});
}

function main() {
	let is_force = false;
	for (let arg in ARGV) {
		if (arg == "-f" || arg == "--force" || arg == "check" || arg == "test")
			is_force = true;
	}

	let lockfd = fs.open(LOCK_FILE, "w+");
	if (!lockfd || !lockfd.lock("xn")) {
		if (is_force)
			logger(log.LOG_WARNING, "Another smart-reboot instance is already running.");
		return 0;
	}

	if (is_force) {
		logger(log.LOG_INFO, "Running smart-reboot in manual test mode...");
		run_check(true);
		lockfd.lock("u");
		lockfd.close();
		return 0;
	}

	uloop.init();
	run_check(false);
	uloop.run();

	lockfd.lock("u");
	lockfd.close();
	return 0;
}

exit(main());
