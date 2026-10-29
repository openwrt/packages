#!/usr/bin/ucode
import { readfile } from 'fs';
import * as uci from 'uci';
import { stream_pipeline, camera_pipeline } from './config.uc';

let state = {};
let text = readfile('/var/run/gst-rtsp/devices.json');
if (text) {
	state = json(text);
	if (state.boot_id != trim(readfile('/proc/sys/kernel/random/boot_id')))
		state = {};
}
try {
	if (ARGV[0] == 'camera-argv') {
		let pipeline = camera_pipeline(uci.cursor(), ARGV[1], state);
		print({ command: pipeline ? ['/usr/bin/ucode',
			'/usr/share/gst-rtsp/capture.uc', ARGV[1], pipeline] : [] });
		exit(0);
	}
	print(ARGV[0] == 'camera' ? camera_pipeline(uci.cursor(), ARGV[1], state) :
		stream_pipeline(uci.cursor(), ARGV[0], state));
} catch (e) {
	warn('gst-rtsp: ', e, '\n');
	exit(1);
}
