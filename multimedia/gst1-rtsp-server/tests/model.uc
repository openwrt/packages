import { mkdtemp, mkdir, writefile, readfile, symlink, rename, glob, unlink } from 'fs';
import * as uci from 'uci';
import { inventory_read, pipeline_build, path_normalise, stream_resolve,
	encoding_build, bitrate_default, stream_caps_parse } from '../files/model.uc';
import { config_update, stream_pipeline, camera_pipeline } from '../files/config.uc';

let directory = mkdtemp('/tmp/gst-rtsp-test-XXXXXX');
let root = directory + '/sys';

function directory_add(path) {
	let current = '';
	for (let part in split(path, '/')) {
		if (!part)
			continue;
		current += '/' + part;
		mkdir(current, 0700);
	}
}

directory_add(root + '/class/video4linux');
directory_add(root + '/bus/media/devices');
directory_add(root + '/devices/platform/isp');
directory_add(root + '/devices/platform/isp/media0');
directory_add(root + '/devices/platform/codec');
directory_add(root + '/devices/platform/converter');
directory_add(root + '/devices/platform/i2c/sensor');
directory_add(root + '/firmware/devicetree/base/camera0');
symlink(root + '/firmware/devicetree/base/camera0',
	root + '/devices/platform/i2c/sensor/of_node');
symlink(root + '/devices/platform/isp/media0', root + '/bus/media/devices/media0');
let endpoints = ['mainpath', 'parameters', 'statistics', 'encoder', 'converter'];
let mapping = [0, 1, 2, 3, 4];
for (let index, name in endpoints) {
	let path = root + '/class/video4linux/video' + index;
	directory_add(path);
	let parent = index == 4 ? 'converter' : (index == 3 ? 'codec' : 'isp');
	symlink(root + '/devices/platform/' + parent, path + '/device');
	writefile(path + '/name', name);
}
directory_add(root + '/class/video4linux/v4l-subdev0');
symlink(root + '/devices/platform/i2c/sensor', root + '/class/video4linux/v4l-subdev0/device');

function run(args) {
	if (args[0] == 'media-ctl')
		return `- entity 1: sensor (1 pad, 1 link)
  type V4L2 subdev subtype Sensor flags 0
  device node name /dev/v4l-subdev0
- entity 2: isp (2 pads, 4 links)
  type V4L2 subdev subtype Unknown flags 0
  pad0: SINK
    <- "sensor":0 [ENABLED,IMMUTABLE]
    <- "parameters":0 [ENABLED]
- entity 3: mainpath (1 pad, 1 link)
  type Node subtype V4L flags 0
  device node name /dev/video${mapping[0]}
  pad0: SINK
    <- "isp":1 [ENABLED]
- entity 4: parameters (1 pad, 1 link)
  type Node subtype V4L flags 0
  device node name /dev/video${mapping[1]}
- entity 5: statistics (1 pad, 1 link)
  type Node subtype V4L flags 0
  device node name /dev/video${mapping[2]}
  pad0: SINK
    <- "isp":1 [ENABLED]
`;
	if (args[0] == 'gst-device-monitor-1.0')
		return `Device found:
  name : /base/camera0
  class : Source/Video
  caps : video/x-raw
  properties:
    api.libcamera.PixelArraySize = < (int)4056, (int)3040 > (GstValueArray)
  gst-launch-1.0 libcamerasrc camera-name='/base/camera0' ! ...
`;
	if (args[0] == 'gst-inspect-1.0') {
		if (args[1] == '--plugin')
			return '  v4l2h265enc: V4L2 H265 Encoder\n' +
				'  v4l2h264enc: V4L2 H264 Encoder\n  v4l2jpegenc: V4L2 JPEG Encoder\n' +
				'  v4l2convert: V4L2 Converter\n';
		let device = args[1] == 'v4l2convert' ? mapping[4] : mapping[3];
		return `  device              : Device location
                        flags: readable, writable
                        String. Default: "/dev/video${device}"
`;
	}
	if (args[2] == '/dev/video11') {
		if (args[3] == '-D')
			return 'Device Caps : 0x04000001';
		return args[3] == '--list-formats' ? "[0]: 'NV12' (Y/CbCr 4:2:0)" : '';
	}
	if (index(['/dev/video20', '/dev/video21', '/dev/video22'], args[2]) >= 0)
		return args[3] == '-D' ? 'Device Caps : 0x05200002' : '';
	let device = int(substr(args[2], length('/dev/video')));
	let role = index(mapping, device);
	if (args[3] == '-D')
		return 'Device Caps : ' + ['0x24201000', '0x04002000', '0x04800000',
			'0x04004000', '0x04004000'][role];
	if (args[3] == '--list-formats-out')
		return role >= 3 ? "[0]: 'NV12' (Y/CbCr 4:2:0)" : '';
	if (args[3] == '--list-ctrls-menus')
		return role == 3 ?
			'compression_quality 0x009d0903 (int) : min=1 max=100 step=1 default=80 value=80\n' +
			'video_bitrate_mode 0x009909ce (menu) : min=0 max=1 default=1 value=1\n' +
			'  1: Constant Bitrate' : '';
	return role == 3 ? "[0]: 'HEVC' (HEVC)\n[1]: 'H264' (H264)\n[2]: 'MJPG' (JPEG)" :
		"[0]: 'NV12' (Y/CbCr 4:2:0)";
}

let inventory = inventory_read(root, run);
assert(length(inventory.devices) == 7);
assert(length(inventory.cameras) == 1);
assert(length(inventory.cameras[0].devices) == 5);
assert(length(filter(values(inventory.devices), n => n.role == 'metadata')) == 1);
assert(length(filter(values(inventory.devices), n => n.role == 'encoder')) == 1);
assert(inventory.encoders[0].codec == 'h265');
assert(inventory.processors[0].factory == 'v4l2convert');
assert(path_normalise('pci0000/usb3/3-2/3-2.4:1.0') == 'pci0000/usb/2/2.4:1.0');

directory_add(directory + '/config');
directory_add(directory + '/delta');
writefile(directory + '/config/gst-rtsp', "config service 'main'\n");
let cursor = uci.cursor(directory + '/config', directory + '/delta', '');
assert(config_update(cursor, inventory));
let config = cursor.get_all('gst-rtsp');
assert(length(filter(values(config), s => s['.type'] == 'stream')) == 1);
assert(length(filter(values(config), s => s['.type'] == 'video-device' && s.handled == '1')) == 7);
assert(cursor.get('gst-rtsp', 'camera0', 'configured') == '1');
assert(cursor.get('gst-rtsp', 'camera0', 'sensor') != null);
assert(cursor.get('gst-rtsp', 'input0', 'enabled') == '0');
assert(cursor.get('gst-rtsp', 'stream0', 'bitrate_mode') == 'cbr');
assert(cursor.get('gst-rtsp', 'stream0', 'bitrate') == '0');
assert(index(readfile(directory + '/config/gst-rtsp'), '/dev/video') < 0);
cursor.set('gst-rtsp', 'stream0', 'width', '1920');
cursor.set('gst-rtsp', 'stream0', 'resolution', 'custom');
cursor.set('gst-rtsp', 'stream0', 'bitrate_mode', 'auto');
cursor.set('gst-rtsp', 'stream0', 'bitrate', '12345678');
cursor.commit('gst-rtsp');
let saved = readfile(directory + '/config/gst-rtsp');
assert(!config_update(cursor, inventory));
assert(readfile(directory + '/config/gst-rtsp') == saved);

for (let i in mapping)
	rename(root + '/class/video4linux/video' + i, root + '/class/video4linux/tmp' + i);
mapping = [7, 4, 9, 2, 5];
for (let i, number in mapping)
	rename(root + '/class/video4linux/tmp' + i, root + '/class/video4linux/video' + number);
let renumbered = inventory_read(root, run);
assert(join('\n', sort(keys(renumbered.devices))) == join('\n', sort(keys(inventory.devices))));
assert(!config_update(cursor, renumbered));
assert(readfile(directory + '/config/gst-rtsp') == saved);
assert(renumbered.devices[renumbered.encoders[0].key].node == '/dev/video2');

let automatic = stream_resolve({ codec: 'auto', resolution: 'native' }, {},
	{ path: '/base/camera0' }, renumbered);
assert(automatic.codec == 'h265' && automatic.width == 4056 && automatic.height == 3040);
assert(stream_resolve({ codec: 'auto' }, {}, {}, {
	encoders: filter(renumbered.encoders, e => e.codec != 'h265')
}).codec == 'h264');
let encoder_controls = renumbered.devices[renumbered.encoders[0].key].controls;
encoder_controls.frame_level_rate_control_enable = { type: 'bool', default: 1 };
encoder_controls.hevc_i_frame_qp_value = { min: 1, max: 51, default: 26 };
encoder_controls.hevc_p_frame_qp_value = { min: 1, max: 51, default: 28 };
let quality_pipeline = encoding_build({ ...automatic, bitrate_mode: 'quality', quality: 'high' },
	renumbered);
assert(index(quality_pipeline, 'frame_level_rate_control_enable=(int)0') >= 0);
assert(index(quality_pipeline, 'hevc_i_frame_qp_value=(int)20') >= 0);
assert(index(quality_pipeline, 'hevc_p_frame_qp_value=(int)22') >= 0);
assert(index(quality_pipeline, 'video_bitrate=') < 0);
let derived_pipeline = encoding_build({ ...automatic, bitrate_mode: 'cbr', bitrate: '0' },
	renumbered);
assert(index(derived_pipeline, 'video_bitrate=(int)22194432') >= 0);
assert(index(derived_pipeline, 'video_bitrate_mode=(int)1') >= 0);
assert(bitrate_default({ width: '1280', height: '720', framerate: '25/1' }, 'h264') == 2764800);
assert(bitrate_default({ width: '1280', height: '720' }, 'mjpeg') == 0);
let caps = stream_caps_parse('/GstPipeline:pipeline0/GstUnixFdSink:stream_stream0.GstPad:sink: caps = video/x-h265, width=(int)4056, height=(int)3040, framerate=(fraction)24000/1001, profile=(string)main');
assert(caps.name == 'stream0' && caps.width == '4056' && caps.framerate == '24000/1001');

cursor.set('gst-rtsp', 'input0', 'enabled', '1');
cursor.set('gst-rtsp', 'stream0', 'enabled', '1');
let launch = stream_pipeline(cursor, 'stream0', renumbered);
assert(index(launch, 'unixfdsrc socket-type=abstract socket-path="gst-rtsp.stream0"') >= 0);
assert(index(launch, 'h265parse ! rtph265pay name=pay0') >= 0);
let acquisition = camera_pipeline(cursor, 'camera0', renumbered);
assert(index(acquisition, 'camera-name="/base/camera0"') >= 0);
assert(index(acquisition, 'width=1920') >= 0);
assert(index(acquisition, 'video_bitrate=(int)12345678') >= 0);
assert(index(acquisition, 'v4l2h265enc output-io-mode=dmabuf-import') >= 0);
assert(index(acquisition, 'unixfdsink socket-type=abstract socket-path="gst-rtsp.stream0"') >= 0);
assert(index(acquisition, 'udpsink') < 0);
assert(index(acquisition, 'encodebin') < 0);
assert(index(acquisition, 'videoconvert') < 0);
cursor.set('gst-rtsp', 'stream0', 'bitrate_mode', 'cbr');
assert(index(camera_pipeline(cursor, 'camera0', renumbered),
	'video_bitrate_mode=(int)1') >= 0);
cursor.set('gst-rtsp', 'stream0', 'bitrate_mode', 'vbr');
let unsupported_mode;
try {
	camera_pipeline(cursor, 'camera0', renumbered);
} catch (e) {
	unsupported_mode = index('' + e, 'does not support the requested bitrate mode') >= 0;
}
assert(unsupported_mode, 'An unsupported bitrate mode must be rejected');
cursor.delete('gst-rtsp', 'stream0', 'bitrate_mode');
cursor.set('gst-rtsp', 'stream1', 'stream');
for (let key, value in { input: 'input0', enabled: '1', port: '8555', codec: 'mjpeg',
	width: '640', height: '480', jpeg_quality: '70' })
	cursor.set('gst-rtsp', 'stream1', key, value);
let neighbouring = stream_pipeline(cursor, 'stream1', renumbered);
let parallel = camera_pipeline(cursor, 'camera0', renumbered);
assert(index(parallel, 'camera.src_0 ! video/x-raw,width=640,height=480') >= 0);
assert(index(parallel, 'compression_quality=(int)70') >= 0);
cursor.set('gst-rtsp', 'stream2', 'stream');
for (let key, value in { input: 'input0', enabled: '1', port: '8556', codec: 'h264',
	width: '640', height: '480' })
	cursor.set('gst-rtsp', 'stream2', key, value);
let shared = camera_pipeline(cursor, 'camera0', renumbered);
assert(length(split(shared, 'tee name=capture_')) == 3);
assert(length(split(shared, 'capture_1. ! video/x-raw,width=640,height=480')) == 3);
assert(index(shared, 'camera.src_1') < 0);
cursor.delete('gst-rtsp', 'stream2');
for (let key, value in { width: '3840', height: '2160', codec: 'h264',
	profile: 'high', bitrate: '16000000', keyframe_interval: '30' })
	cursor.set('gst-rtsp', 'stream0', key, value);
assert(camera_pipeline(cursor, 'camera0', renumbered) != parallel);
assert(stream_pipeline(cursor, 'stream1', renumbered) == neighbouring);
assert(stream_pipeline(cursor, 'stream0', renumbered) != launch);
assert(index(neighbouring, 'rtpjpegpay name=pay0') >= 0);
let processor = filter(values(config), s => s.role == 'processor')[0]['.name'];
cursor.set('gst-rtsp', 'stream0', 'processor', [processor]);
assert(index(camera_pipeline(cursor, 'camera0', renumbered),
	'v4l2convert disable-passthrough=true output-io-mode=dmabuf-import') >= 0);
cursor.set('gst-rtsp', 'input0', 'processor', [processor]);
assert(index(camera_pipeline(cursor, 'camera0', renumbered),
	'camera.src ! v4l2convert disable-passthrough=true') >= 0);
cursor.delete('gst-rtsp', 'input0', 'processor');
cursor.delete('gst-rtsp', 'stream1');
cursor.delete('gst-rtsp', 'stream0');
cursor.commit('gst-rtsp');
assert(!config_update(cursor, renumbered));
assert(cursor.get('gst-rtsp', 'stream0') == null);

directory_add(root + '/devices/platform/xhci/usb3/3-2/3-2:1.0');
directory_add(root + '/class/video4linux/video11');
symlink(root + '/devices/platform/xhci/usb3/3-2/3-2:1.0',
	root + '/class/video4linux/video11/device');
writefile(root + '/class/video4linux/video11/name', 'USB camera');
let usb = inventory_read(root, run);
assert(length(usb.cameras) == 2);
assert(config_update(cursor, usb));
assert(cursor.get('gst-rtsp', 'camera1', 'source') == 'v4l2src');
cursor.set('gst-rtsp', 'input1', 'enabled', '1');
cursor.set('gst-rtsp', 'stream0', 'enabled', '1');
cursor.set('gst-rtsp', 'stream0', 'resolution', 'custom');
cursor.set('gst-rtsp', 'stream0', 'bitrate_mode', 'auto');
cursor.set('gst-rtsp', 'usb_extra', 'stream');
for (let key, value in { input: 'input1', enabled: '1', port: '8556', codec: 'h264' })
	cursor.set('gst-rtsp', 'usb_extra', key, value);
let usb_launch = camera_pipeline(cursor, 'camera1', usb);
assert(length(split(usb_launch, 'v4l2src')) == 2);
assert(index(usb_launch, 'device="/dev/video11" io-mode=dmabuf') >= 0);
assert(index(usb_launch, 'tee name=input1') >= 0);
assert(index(usb_launch, 'v4l2h265enc output-io-mode=dmabuf-import') >= 0);
assert(index(usb_launch, 'v4l2h264enc output-io-mode=dmabuf-import') >= 0);

let failed;
try {
	pipeline_build({ codec: 'h265' }, null, {});
} catch (e) {
	failed = true;
}
assert(failed, 'A missing hardware encoder must not select software');

function virtual_add(number) {
	let path = `${root}/devices/virtual/video4linux/video${number}`;
	directory_add(path);
	writefile(path + '/name', 'isp-hevc');
	symlink(path, `${root}/class/video4linux/video${number}`);
}

virtual_add(20);
let virtual = inventory_read(root, run);
let virtual_key = 'virtual/output/isp-hevc';
assert(virtual.devices[virtual_key].node == '/dev/video20');
assert(length(virtual.cameras) == length(usb.cameras));
assert(config_update(cursor, virtual));
let virtual_config = readfile(directory + '/config/gst-rtsp');
unlink(root + '/class/video4linux/video20');
virtual_add(21);
let virtual_renumbered = inventory_read(root, run);
assert(virtual_renumbered.devices[virtual_key].node == '/dev/video21');
assert(!config_update(cursor, virtual_renumbered));
assert(readfile(directory + '/config/gst-rtsp') == virtual_config);
virtual_add(22);
failed = false;
try {
	inventory_read(root, run);
} catch (e) {
	failed = index('' + e, 'Ambiguous video identity') >= 0;
}
assert(failed, 'Duplicate virtual card identities must be rejected');
print('Topology, UCI preservation, renumbering, deletion and hardware pipeline checks passed\n');
print('Fixture: ', directory, '\n');
