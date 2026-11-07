#!/usr/bin/ucode
import { mkdir, readfile, writefile, rename, glob, realpath } from 'fs';
import * as uci from 'uci';
import * as ubus from 'ubus';
import * as uloop from 'uloop';
import { command_read, inventory_read, MEDIA_SYSFS } from './model.uc';
import { config_update } from './config.uc';
import { watcher_create } from './watch.uc';

const STATE_DIR = '/var/run/gst-rtsp';

function topology_stamp() {
	return join('\n', map(sort([
		...glob('/sys/class/video4linux/*'), ...glob(`/sys/${MEDIA_SYSFS}/media*`)
	]), p => p + '=' + realpath(p)));
}

function inventory_apply(inventory, connection) {
	let cursor = uci.cursor('/etc/config', STATE_DIR + '/uci', '');
	let text = sprintf('%J', { boot_id: trim(readfile('/proc/sys/kernel/random/boot_id')),
		...inventory });
	if (writefile(STATE_DIR + '/devices.json.new', text) != length(text) ||
	    !rename(STATE_DIR + '/devices.json.new', STATE_DIR + '/devices.json'))
		die('Cannot store runtime video topology\n');
	config_update(cursor, inventory);
	connection.call({ object: 'service', method: 'event',
		data: { type: 'config.change', data: { package: 'gst-rtsp' } } });
	if (connection.error())
		die('Cannot notify procd of video configuration\n');
}

mkdir(STATE_DIR, 0755);
mkdir(STATE_DIR + '/uci', 0700);
uloop.init();
let connection = ubus.connect();
if (!connection)
	die('Cannot connect to ubus\n');
let watcher = watcher_create(() => inventory_read('/sys', command_read),
	inventory => inventory_apply(inventory, connection), topology_stamp);
let object = connection.publish('gst-rtsp', {
	discover: { call: function() { watcher.event(); return {}; } }
});
if (!object)
	die('Cannot publish gst-rtsp discovery object\n');
uloop.signal('SIGTERM', function() {
	watcher.stop();
	uloop.end();
});
watcher.event();
uloop.run();
