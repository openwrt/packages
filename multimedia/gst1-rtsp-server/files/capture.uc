#!/usr/bin/ucode
import { readfile, writefile, rename, unlink, dup2, access } from 'fs';
import * as socket from 'socket';
import * as uloop from 'uloop';
import { launch_argv, stream_caps_parse } from './model.uc';

let camera = ARGV[0];
if (!camera || !match(camera, /^[a-zA-Z0-9_]+$/))
	die('Invalid camera section\n');
let state = json(readfile('/var/run/gst-rtsp/devices.json'));
let boot_id = trim(readfile('/proc/sys/kernel/random/boot_id'));
if (state.boot_id != boot_id)
	die('Video inventory belongs to another boot\n');
let pipeline = ARGV[1];
let command = launch_argv(pipeline);
if (!length(command))
	exit(0);
command[1] = '-v';
let path = '/var/run/gst-rtsp/' + camera + '.json';
let streams = {}, pending = '', status = 1, child, reader;
let descriptors = socket.pair();
if (!descriptors || !uloop.init())
	die('Cannot initialise capture supervisor\n');

function metadata_refresh() {
	if (access('/etc/init.d/onvif-simple-server', 'x'))
		system('/usr/bin/ucode /usr/share/gst-rtsp/onvif.uc && /etc/init.d/onvif-simple-server reload');
}

function metadata_update(line) {
	let caps = stream_caps_parse(line);
	if (!caps)
		return;
	if (sprintf('%J', streams[caps.name]) == sprintf('%J', caps))
		return;
	streams[caps.name] = caps;
	warn('Negotiated stream: ', caps, '\n');
	let text = sprintf('%J', { boot_id, pipeline, streams });
	if (writefile(path + '.new', text) != length(text) || !rename(path + '.new', path))
		die('Cannot publish negotiated stream properties\n');
	metadata_refresh();
}

unlink(path);
child = uloop.process(command[0], slice(command, 1), null, function(code) {
	status = code;
	uloop.end();
}, function() {
	descriptors[0].close();
	dup2(descriptors[1].fileno(), 1);
	descriptors[1].close();
});
if (!child)
	die('Cannot start capture process\n');
uloop.guard(function(e) {
	warn('Capture supervisor: ', e, '\n');
	system('kill -TERM ' + child.pid());
});
descriptors[1].close();
reader = uloop.handle(descriptors[0], function() {
	let chunk = descriptors[0].recv();
	if (chunk == null || !length(chunk)) {
		reader.delete();
		return;
	}
	let lines = split(pending + chunk, '\n');
	pending = pop(lines);
	for (let line in lines)
		metadata_update(line);
}, uloop.ULOOP_READ);
let terminate = uloop.signal('SIGTERM', () => system('kill -TERM ' + child.pid()));
let interrupt = uloop.signal('SIGINT', () => system('kill -INT ' + child.pid()));
uloop.run();
unlink(path);
metadata_refresh();
descriptors[0].close();
exit(status);
