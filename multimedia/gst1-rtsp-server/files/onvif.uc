#!/usr/bin/ucode
import { readfile, writefile, mkdir, rename, unlink, chmod } from 'fs';
import * as uci from 'uci';
import * as ubus from 'ubus';
import { onvif_build } from './onvif-model.uc';
import { devices_resolve, camera_pipeline } from './config.uc';

const DIRECTORY = '/var/run/onvif-simple-server';
const CONFIG = DIRECTORY + '/config.json';

let cursor = uci.cursor();
let server = cursor.get_all('onvif-simple-server', 'main');
if (!server || server.enabled == '0' || (server.config_file && server.config_file != CONFIG))
	exit(0);
if (ARGV[0] == 'stop') {
	unlink(CONFIG);
	exit(0);
}

try {
	let inventory = readfile('/var/run/gst-rtsp/devices.json');
	if (!inventory)
		die('Video inventory is unavailable\n');
	let state = json(inventory);
	if (state.boot_id != trim(readfile('/proc/sys/kernel/random/boot_id')))
		die('Video inventory belongs to another boot\n');
	let listen = cursor.get('uhttpd', 'onvif', 'listen_http');
	if (type(listen) == 'array')
		listen = listen[0];
	let port = int(split(listen ?? '', ':')[-1]);
	if (port < 1 || port > 65535)
		die('ONVIF HTTP listener is not configured\n');
	let settings = cursor.get_all('gst-rtsp');
	state.runtime = {};
	for (let camera in values(settings)) {
		if (camera['.type'] != 'camera')
			continue;
		let text = readfile('/var/run/gst-rtsp/' + camera['.name'] + '.json');
		if (!text)
			continue;
		let actual = json(text);
		if (actual.boot_id == state.boot_id &&
		    actual.pipeline == camera_pipeline(cursor, camera['.name'], state))
			state.runtime = { ...state.runtime, ...actual.streams };
	}
	for (let stream in values(settings))
		if (stream['.type'] == 'stream' && stream.enabled == '1')
			devices_resolve(cursor, stream);
	let board = ubus.call({ object: 'system', method: 'board', data: {} });
	if (!board)
		die('Cannot read system board identity\n');
	for (let path in ['/sys/firmware/devicetree/base/serial-number',
	    '/sys/devices/virtual/dmi/id/product_serial']) {
		if (board.serial)
			break;
		let serial = trim(readfile(path) ?? '', '\x00\t\r\n ');
		if (serial)
			board.serial = serial;
	}
	let config = onvif_build(settings, state, { ...server, port }, board);
	if (!config) {
		unlink(CONFIG);
		exit(0);
	}
	mkdir(DIRECTORY, 0750);
	let text = sprintf('%J', config);
	if (writefile(CONFIG + '.new', text) != length(text) ||
	    !chmod(CONFIG + '.new', 0600) || !rename(CONFIG + '.new', CONFIG))
		die('Cannot publish ONVIF configuration\n');
} catch (e) {
	unlink(CONFIG);
	warn('gst-rtsp ONVIF: ', e, '\n');
	exit(1);
}
