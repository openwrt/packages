#!/usr/bin/ucode
// One-time import: copy the devices of tellstick.conf (telldusd) to the UCI
// config telldus-mqtt, then set manage_switches '1' in the main section.
// Usage: ucode telldus-mqtt-tellstick2uci.uc [<tellstick.conf> [<uci config dir> [<gateway serial>]]]
// Default: /etc/tellstick.conf. The UCI config dir is for tests.
//
// For each device: the switch section with the same id gets protocol, model
// and the parameters. If there is no such section, a new switch section
// without name is added (it is not published to MQTT). If more sections have
// the id, the one with gateway <gateway serial> is used, else the one without
// gateway. If that is not clear, nothing is changed.
// If manage_switches is '1' already, nothing is changed.

'use strict';

import { cursor } from 'uci';
import * as fs from 'fs';

const DEFAULT_CONF = '/etc/tellstick.conf';
const CONFIG = 'telldus-mqtt';

const lib = loadfile(fs.dirname(sourcepath()) + '/telldus-mqtt-tellstick.uc')();

function text(value) {
	return (type(value) == 'string') ? value : '';
}

// Pure function: tellstick.conf devices, UCI sections (from get_all()),
// gateway serial or null -> { changes: [ { section (null: new), id,
// options: { name: value or null to delete } } ], errors: [ ... ],
// warnings: [ ... ] }
function import_devices(devices, sections, serial) {
	let changes = [];
	let errors = [];
	let warnings = [];
	let seen = {};
	let switches = [];

	for (let s in lib.ordered(sections || {}))
		if (s['.type'] == 'device' && s.type == 'switch')
			push(switches, s);

	for (let d in devices) {
		let id = sprintf('%d', d.id);
		if (d.id < 1) {
			push(errors, sprintf('device "%s": no id or id below 1', d.name));
			continue;
		}
		if (seen[id]) {
			push(errors, sprintf('device id %s is in tellstick.conf more than once', id));
			continue;
		}
		seen[id] = true;

		let options = { protocol: d.protocol, model: (d.model != '') ? d.model : null };
		for (let p in lib.PARAMETERS)
			options[p] = d.parameters[p];

		let candidates = filter(switches, s => s.id == id);
		let chosen = null;
		let by_serial = serial ? filter(candidates, s => s.gateway == serial) : [];
		let no_gateway = filter(candidates, s => text(s.gateway) == '');
		if (length(by_serial) == 1)
			chosen = by_serial[0];
		else if (length(by_serial) > 1) {
			push(errors, sprintf('switch %s: %d sections have gateway %s', id, length(by_serial), serial));
			continue;
		}
		else if (length(no_gateway) == 1)
			chosen = no_gateway[0];
		else if (length(no_gateway) > 1) {
			push(errors, sprintf('switch %s: %d sections have no gateway', id, length(no_gateway)));
			continue;
		}
		else if (length(candidates) == 1 && !serial)
			chosen = candidates[0];
		else if (length(candidates) > 1) {
			push(errors, sprintf('switch %s: %d sections have this id, give the gateway serial of this TellStick',
				id, length(candidates)));
			continue;
		}
		// Else: no section, or only one for another gateway: add a new section

		push(changes, { section: chosen ? chosen['.name'] : null, id: id, options: options });
	}
	return { changes: changes, errors: errors, warnings: warnings };
}

function main(args) {
	// No options with '-': ucode itself reads them (glibc getopt)
	if (length(args) > 3) {
		warn('Usage: telldus-mqtt-tellstick2uci.uc [<tellstick.conf> [<uci config dir> [<gateway serial>]]]\n');
		return 2;
	}
	let path = args[0] || DEFAULT_CONF;
	let confdir = args[1];
	let serial = (args[2] != null && args[2] != '') ? args[2] : null;

	// uci cannot set options in a config file that does not exist
	let uci_path = (confdir || '/etc/config') + '/' + CONFIG;
	if (!fs.stat(uci_path) && fs.writefile(uci_path, '') == null) {
		warn(sprintf('telldus-mqtt-tellstick2uci: cannot create %s: %s\n', uci_path, fs.error()));
		return 1;
	}
	let c = confdir ? cursor(confdir) : cursor();
	let sections = (c && c.load(CONFIG)) ? c.get_all(CONFIG) : null;
	if (!sections) {
		warn('telldus-mqtt-tellstick2uci: cannot read UCI config ' + CONFIG + '\n');
		return 1;
	}

	let main_name = null;
	for (let s in lib.ordered(sections))
		if (s['.type'] == 'main') {
			main_name = s['.name'];
			break;
		}
	if (main_name && sections[main_name].manage_switches == '1') {
		print('telldus-mqtt-tellstick2uci: manage_switches is 1 already, nothing changed\n');
		return 0;
	}

	let devices = [];
	let content = fs.readfile(path);
	if (content == null) {
		if (fs.error() != 'No such file or directory') {
			warn(sprintf('telldus-mqtt-tellstick2uci: cannot read %s: %s\n', path, fs.error()));
			return 1;
		}
		print(sprintf('telldus-mqtt-tellstick2uci: %s does not exist, no devices to import\n', path));
	}
	else {
		try {
			devices = lib.parse(content).devices;
		}
		catch (e) {
			warn(sprintf('telldus-mqtt-tellstick2uci: cannot parse %s: %s. Nothing changed\n', path, e.message));
			return 1;
		}
	}

	let result = import_devices(devices, sections, serial);
	for (let w in result.warnings)
		warn('telldus-mqtt-tellstick2uci: ' + w + '\n');
	if (length(result.errors)) {
		for (let e in result.errors)
			warn('telldus-mqtt-tellstick2uci: ' + e + '\n');
		warn('telldus-mqtt-tellstick2uci: nothing changed\n');
		return 1;
	}

	let added = 0;
	for (let ch in result.changes) {
		let s = ch.section;
		if (!s) {
			s = c.add(CONFIG, 'device');
			c.set(CONFIG, s, 'type', 'switch');
			c.set(CONFIG, s, 'id', ch.id);
			added++;
		}
		for (let o in [ 'protocol', 'model', ...lib.PARAMETERS ]) {
			if (ch.options[o] != null)
				c.set(CONFIG, s, o, ch.options[o]);
			else
				c.delete(CONFIG, s, o);
		}
	}
	if (!main_name) {
		main_name = 'main';
		c.set(CONFIG, main_name, 'main');
	}
	c.set(CONFIG, main_name, 'manage_switches', '1');

	if (!c.commit(CONFIG)) {
		warn('telldus-mqtt-tellstick2uci: cannot write UCI config ' + CONFIG + ': ' + c.error() + '\n');
		return 1;
	}
	print(sprintf('telldus-mqtt-tellstick2uci: %d devices imported (%d new sections without name), manage_switches set to 1\n',
		length(result.changes), added));
	return 0;
}

// The tests set global.TELLDUS_MQTT_UC_TEST and load this file with
// loadfile() to get the functions.
if (!global.TELLDUS_MQTT_UC_TEST)
	exit(main(ARGV));

return { import_devices: import_devices };
