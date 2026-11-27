#!/usr/bin/ucode
// Write the devices of tellstick.conf (telldusd) from the UCI config telldus-mqtt.
// Usage: ucode telldus-mqtt-uci2tellstick.uc [<tellstick.conf> [<uci config dir>]]
// Default: /etc/tellstick.conf. The UCI config dir is for tests.
//
// Only if option manage_switches of the main section is '1'. Every device
// section with type 'switch' and a protocol becomes a device in tellstick.conf.
// A device that is in tellstick.conf already keeps its name and controller.
// All other content of tellstick.conf stays as it is (telldusd writes the
// controller sections). The file is changed only if the devices change.
// Output on stdout: "changed", "unchanged" or "off" (manage_switches not 1).
// Exit code 0 if OK. On an error, the file is not changed.

'use strict';

import { cursor } from 'uci';
import * as fs from 'fs';

const DEFAULT_CONF = '/etc/tellstick.conf';
const CONFIG = 'telldus-mqtt';
const NEW_FILE_MODE = 0644;	// as telldus-core installs it

const lib = loadfile(fs.dirname(sourcepath()) + '/telldus-mqtt-tellstick.uc')();

function main(args) {
	// No options with '-': ucode itself reads them (glibc getopt)
	if (length(args) > 2) {
		warn('Usage: telldus-mqtt-uci2tellstick.uc [<tellstick.conf> [<uci config dir>]]\n');
		return 2;
	}
	let path = args[0] || DEFAULT_CONF;
	let confdir = args[1];

	let c = confdir ? cursor(confdir) : cursor();
	let sections = c ? c.get_all(CONFIG) : null;
	if (!sections) {
		warn('telldus-mqtt-uci2tellstick: cannot read UCI config ' + CONFIG + '\n');
		return 1;
	}

	let manage = null;
	for (let s in lib.ordered(sections))
		if (s['.type'] == 'main') {
			manage = s.manage_switches;
			break;
		}
	if (manage != '1') {
		warn('telldus-mqtt-uci2tellstick: manage_switches is not 1, ' + path + ' not changed\n');
		print('off\n');
		return 0;
	}

	let result = lib.devices_from_uci(sections);
	if (length(result.errors)) {
		for (let e in result.errors)
			warn('telldus-mqtt-uci2tellstick: ' + e + '\n');
		warn('telldus-mqtt-uci2tellstick: ' + path + ' not changed\n');
		return 1;
	}

	let st = fs.stat(path);
	let old = null;
	if (st) {
		old = fs.readfile(path);
		if (old == null) {
			warn(sprintf('telldus-mqtt-uci2tellstick: cannot read %s: %s\n', path, fs.error()));
			return 1;
		}
	}
	else if (fs.error() != 'No such file or directory') {
		warn(sprintf('telldus-mqtt-uci2tellstick: cannot read %s: %s\n', path, fs.error()));
		return 1;
	}

	let content;
	if (old == null)
		content = lib.replace_devices(lib.DEFAULT_HEADER, lib.parse(lib.DEFAULT_HEADER), result.devices);
	else {
		let parsed;
		try {
			parsed = lib.parse(old);
		}
		catch (e) {
			warn(sprintf('telldus-mqtt-uci2tellstick: cannot parse %s: %s. File not changed\n', path, e.message));
			return 1;
		}
		lib.keep_existing(result.devices, parsed.devices);
		if (lib.same_devices(parsed.devices, result.devices)) {
			print('unchanged\n');
			return 0;
		}
		content = lib.replace_devices(old, parsed, result.devices);
	}

	let err = st ? lib.write_file(path, content, st.mode & 07777, st.uid, st.gid)
		: lib.write_file(path, content, NEW_FILE_MODE);
	if (err) {
		warn(sprintf('telldus-mqtt-uci2tellstick: cannot write %s: %s\n', path, err));
		return 1;
	}
	print('changed\n');
	return 0;
}

exit(main(ARGV));
