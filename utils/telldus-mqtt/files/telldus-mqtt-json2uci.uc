#!/usr/bin/ucode
// Migration: write the UCI config telldus-mqtt from an old telldus-mqtt.json.
// Usage: ucode telldus-mqtt-json2uci.uc [<input file> [<uci config dir>]]
// The UCI config dir is for tests. Default: /etc/config.
// Default input: /etc/telldus-mqtt/telldus-mqtt.json.
// If the UCI config has device sections already, nothing is changed.
// It sets main.topic_prefix to the most used prefix of the old topics,
// so that a new name gets a topic next to the old ones.

'use strict';

import { cursor } from 'uci';
import * as fs from 'fs';

const DEFAULT_INPUT = '/etc/telldus-mqtt/telldus-mqtt.json';
const CONFIG = 'telldus-mqtt';

function text(value) {
	return (type(value) == 'string') ? value : null;
}

// UCI option value from a JSON string or number, or null
function option(value) {
	if (type(value) == 'string')
		return value;
	if (type(value) == 'int' || type(value) == 'double')
		return sprintf('%d', value);
	return null;
}

function last_part(topic) {
	let parts = split(topic, '/');
	return parts[length(parts) - 1];
}

// The prefix for new names: the most used topic without its last part
// ("Hemma/Uteförråd" -> "Hemma"). If two prefixes are used equally often,
// the first in file order. null if no topic has a '/'.
function topic_prefix(devices) {
	let count = {};
	let order = [];
	for (let i = 0; i < length(devices); i++) {
		let topic = devices[i].topic;
		let end = topic ? rindex(topic, '/') : -1;
		if (end <= 0)
			continue;
		let prefix = substr(topic, 0, end);
		if (!count[prefix]) {
			count[prefix] = 0;
			push(order, prefix);
		}
		count[prefix]++;
	}
	let best = null;
	for (let i = 0; i < length(order); i++)
		if (best == null || count[order[i]] > count[best])
			best = order[i];
	return best;
}

// Pure function: daemon JSON object -> { main: { option: value },
// devices: [ { option: value } ], warnings: [ ... ] }.
// main.topic_prefix is set from the topics of the devices. The devices
// keep their topics: a later change of the prefix does not move them.
function json2uci(cfg) {
	let main = {};
	let devices = [];
	let warnings = [];
	let seen = {};

	let main_keys = [
		[ 'host', 'host' ],
		[ 'port', 'port' ],
		[ 'user', 'user' ],
		[ 'pass', 'pass' ],
		[ 'sensor-offline-seconds', 'offline_seconds' ]
	];
	for (let i = 0; i < length(main_keys); i++) {
		let value = option(cfg[main_keys[i][0]]);
		if (value != null)
			main[main_keys[i][1]] = value;
	}

	// The daemon uses the first entry that matches: keep the first one
	function add(device, what) {
		let key = device.type + ' ' + device.id + ' ' + (device.gateway || '');
		if (seen[key]) {
			push(warnings, sprintf('%s: %s %s is a duplicate, skipped', what, device.type, device.id));
			return;
		}
		seen[key] = true;
		push(devices, device);
	}

	let list = (type(cfg.devices) == 'array') ? cfg.devices : [];
	for (let i = 0; i < length(list); i++) {
		let e = list[i];
		let what = sprintf('devices entry %d', i + 1);
		if (type(e) != 'object' || !text(e.type) || !text(e.id) || !text(e.name) ||
		    (e.type != 'sensor' && e.type != 'switch')) {
			push(warnings, what + ': no type, id or name, skipped');
			continue;
		}
		let device = { type: e.type, id: e.id, name: e.name };
		if (text(e.topic))
			device.topic = e.topic;
		if (text(e.gateway))
			device.gateway = e.gateway;
		add(device, what);
	}

	list = (type(cfg['topic-translation']) == 'array') ? cfg['topic-translation'] : [];
	for (let i = 0; i < length(list); i++) {
		let e = list[i];
		let what = sprintf('topic-translation entry %d', i + 1);
		let telldus = (type(e) == 'object') ? text(e.telldus) : null;
		let mqtt = (type(e) == 'object') ? text(e.mqtt) : null;
		let m = telldus ? match(telldus, /^telldus\/([^\/]+)\/(sensor|switch)\/([^\/]+)$/) : null;
		if (!m || !mqtt || mqtt == '') {
			push(warnings, sprintf('%s: "%s" is not telldus/<serial>/sensor|switch/<id>, skipped', what, telldus));
			continue;
		}
		// Keep the topic, so that it does not change
		add({
			type: m[2],
			id: m[3],
			name: text(e.name) ? e.name : last_part(mqtt),
			topic: mqtt,
			gateway: m[1]
		}, what);
	}

	let prefix = topic_prefix(devices);
	if (prefix != null)
		main.topic_prefix = prefix;

	return { main: main, devices: devices, warnings: warnings };
}

function main(args) {
	// No options with '-': ucode itself reads them (glibc getopt)
	if (length(args) > 2) {
		warn('Usage: telldus-mqtt-json2uci.uc [<input file> [<uci config dir>]]\n');
		return 2;
	}
	let input = args[0] || DEFAULT_INPUT;
	let confdir = args[1];

	let content = fs.readfile(input);
	if (content == null) {
		warn(sprintf('telldus-mqtt-json2uci: cannot read %s: %s\n', input, fs.error()));
		return 1;
	}
	let cfg;
	try {
		cfg = json(content);
	}
	catch (e) {
		warn(sprintf('telldus-mqtt-json2uci: %s is not valid JSON: %s\n', input, e.message));
		return 1;
	}
	if (type(cfg) != 'object') {
		warn(sprintf('telldus-mqtt-json2uci: %s is not a JSON object\n', input));
		return 1;
	}

	// uci cannot set options in a config file that does not exist
	let path = (confdir || '/etc/config') + '/' + CONFIG;
	if (!fs.stat(path) && fs.writefile(path, '') == null) {
		warn(sprintf('telldus-mqtt-json2uci: cannot create %s: %s\n', path, fs.error()));
		return 1;
	}

	let c = confdir ? cursor(confdir) : cursor();
	if (!c || !c.load(CONFIG)) {
		warn('telldus-mqtt-json2uci: cannot read UCI config ' + CONFIG + '\n');
		return 1;
	}

	let has_devices = false;
	c.foreach(CONFIG, 'device', function() { has_devices = true; });
	if (has_devices) {
		print('telldus-mqtt-json2uci: UCI config ' + CONFIG + ' has device sections already, nothing changed\n');
		return 0;
	}

	let result = json2uci(cfg);
	for (let i = 0; i < length(result.warnings); i++)
		warn('telldus-mqtt-json2uci: ' + result.warnings[i] + '\n');

	let main_name = null;
	c.foreach(CONFIG, 'main', function(s) {
		if (!main_name)
			main_name = s['.name'];
	});
	if (!main_name) {
		main_name = 'main';
		c.set(CONFIG, main_name, 'main');
	}
	for (let name in result.main)
		c.set(CONFIG, main_name, name, result.main[name]);

	let order = [ 'type', 'id', 'name', 'topic', 'gateway' ];
	for (let i = 0; i < length(result.devices); i++) {
		let device = result.devices[i];
		let s = c.add(CONFIG, 'device');
		for (let j = 0; j < length(order); j++)
			if (device[order[j]] != null)
				c.set(CONFIG, s, order[j], device[order[j]]);
	}

	if (!c.commit(CONFIG)) {
		warn('telldus-mqtt-json2uci: cannot write UCI config ' + CONFIG + ': ' + c.error() + '\n');
		return 1;
	}
	print(sprintf('telldus-mqtt-json2uci: %d devices written to UCI config %s\n', length(result.devices), CONFIG));
	if (result.main.topic_prefix != null)
		print(sprintf('telldus-mqtt-json2uci: topic_prefix set to "%s" (the most used prefix of the old topics)\n',
			result.main.topic_prefix));
	return 0;
}

// The tests set global.TELLDUS_MQTT_UC_TEST and load this file with
// loadfile() to get the functions.
if (!global.TELLDUS_MQTT_UC_TEST)
	exit(main(ARGV));

return { json2uci: json2uci, topic_prefix: topic_prefix };
