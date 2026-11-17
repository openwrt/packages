#!/usr/bin/ucode
// Make the telldus-mqtt config file (JSON) from the UCI config telldus-mqtt.
// Usage: ucode telldus-mqtt-uci2json.uc [<output file> [<uci config dir>]]
// The UCI config dir is for tests. Default: /etc/config.
// Default output: /var/etc/telldus-mqtt.json. The file holds the broker
// password: it is written with mode 0600.

'use strict';

import { cursor } from 'uci';
import * as fs from 'fs';

const DEFAULT_OUTPUT = '/var/etc/telldus-mqtt.json';

function number(value, dflt) {
	if (type(value) != 'string' || !match(value, /^[0-9]+$/))
		return dflt;
	let n = int(value);
	return (type(n) == 'int' && n >= 0) ? n : dflt;
}

function text(value) {
	return (type(value) == 'string') ? value : '';
}

// The topic from the name: <topic_prefix>/<name>. MQTT wildcards and the
// topic separator in the name are replaced by '_'.
function derive_topic(prefix, name) {
	name = replace(name, /[\/+#]/g, '_');
	return (prefix != '') ? prefix + '/' + name : name;
}

// Pure function: UCI sections (as cursor.get_all('telldus-mqtt') gives
// them) -> { config: <daemon JSON object>, warnings: [ ... ] }
function uci2json(sections) {
	let main = null;
	let devices = [];
	let warnings = [];

	let names = keys(sections || {});
	names = sort(names, function(a, b) {
		return (sections[a]['.index'] || 0) - (sections[b]['.index'] || 0);
	});

	for (let i = 0; i < length(names); i++) {
		let s = sections[names[i]];
		if (s['.type'] == 'main' && !main)
			main = s;
		else if (s['.type'] == 'device')
			push(devices, s);
	}

	if (!main)
		main = {};

	let prefix = (type(main.topic_prefix) == 'string') ? main.topic_prefix : 'home';
	let config = {
		'host': (text(main.host) != '') ? main.host : '127.0.0.1',
		'port': number(main.port, 1883),
		'user': text(main.user),
		'pass': text(main.pass),
		'sensor-offline-seconds': number(main.offline_seconds, 600),
		'filter-non-transled': 'yes',
		'devices': []
	};

	for (let i = 0; i < length(devices); i++) {
		let d = devices[i];
		// A switch without name, only for tellstick.conf: not published
		if (d.type == 'switch' && text(d.id) != '' && text(d.name) == '' && text(d.protocol) != '')
			continue;
		if (text(d.type) == ''|| text(d.id) == '' || text(d.name) == '') {
			push(warnings, sprintf('device section %s: no type, id or name, skipped', d['.name']));
			continue;
		}
		if (d.type != 'sensor' && d.type != 'switch') {
			push(warnings, sprintf('device section %s: unknown type %s, skipped', d['.name'], d.type));
			continue;
		}
		let entry = {
			'type': d.type,
			'id': d.id,
			'name': d.name,
			'topic': (text(d.topic) != '') ? d.topic : derive_topic(prefix, d.name)
		};
		if (text(d.gateway) != '')
			entry.gateway = d.gateway;
		push(config.devices, entry);
	}

	return { config: config, warnings: warnings };
}

// Write path atomically: a temporary file, then rename.
function write_file(path, content) {
	let tmp = path + '.tmp';
	let dir = fs.dirname(path);
	if (!fs.stat(dir))
		fs.mkdir(dir, 0755);

	fs.unlink(tmp);
	let f = fs.open(tmp, 'w', 0600);
	if (!f)
		return fs.error();
	let ok = f.write(content) != null;
	ok = f.close() && ok;
	ok = ok && fs.chmod(tmp, 0600);
	ok = ok && fs.rename(tmp, path);
	if (!ok) {
		let err = fs.error();
		fs.unlink(tmp);
		return err;
	}
	return null;
}

function main(args) {
	// No options with '-': ucode itself reads them (glibc getopt)
	if (length(args) > 2) {
		warn('Usage: telldus-mqtt-uci2json.uc [<output file> [<uci config dir>]]\n');
		return 2;
	}
	let output = args[0] || DEFAULT_OUTPUT;
	let confdir = args[1];

	let c = confdir ? cursor(confdir) : cursor();
	let sections = c ? c.get_all('telldus-mqtt') : null;
	if (!sections) {
		warn('telldus-mqtt-uci2json: cannot read UCI config telldus-mqtt\n');
		return 1;
	}

	let result = uci2json(sections);
	for (let i = 0; i < length(result.warnings); i++)
		warn('telldus-mqtt-uci2json: ' + result.warnings[i] + '\n');

	let err = write_file(output, sprintf('%.J\n', result.config));
	if (err) {
		warn(sprintf('telldus-mqtt-uci2json: cannot write %s: %s\n', output, err));
		return 1;
	}
	return 0;
}

// The tests set global.TELLDUS_MQTT_UC_TEST and load this file with
// loadfile() to get the functions.
if (!global.TELLDUS_MQTT_UC_TEST)
	exit(main(ARGV));

return { uci2json: uci2json, derive_topic: derive_topic };
