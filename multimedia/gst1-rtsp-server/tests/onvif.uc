import { onvif_build } from '../files/onvif-model.uc';

function rejected(config, state, options) {
	try {
		onvif_build(config, state, options);
	} catch (e) {
		return true;
	}
	return false;
}

let config = {
	camera0: { '.name': 'camera0', '.type': 'camera', source_width: '3840',
		source_height: '2160', source_framerate: '30', path: '/base/sensor' },
	input0: { '.name': 'input0', '.type': 'input', enabled: '1', camera: 'camera0',
		width: '3840', height: '2160', framerate: '30000/1001' }
};
let controls = {
	video_bitrate: { default: 4000000 }, video_gop_size: { default: 30 },
	h264_profile: { default: 4, menu: { '4': 'High' } },
	hevc_profile: { default: 0, menu: { '0': 'Main' } },
	h264_i_frame_qp_value: { default: 26, max: 51 },
	hevc_i_frame_qp_value: { default: 26, max: 51 },
	compression_quality: { default: 50 }
};
let state = { devices: { encoder: { controls } }, encoders: [
	{ key: 'encoder', factory: 'v4l2h264enc', codec: 'h264' },
	{ key: 'encoder', factory: 'v4l2h265enc', codec: 'h265' },
	{ key: 'encoder', factory: 'v4l2jpegenc', codec: 'mjpeg' }
] };
for (let codec in ['h264', 'h265', 'mjpeg'])
	config[codec] = { '.name': codec, '.type': 'stream', enabled: '1',
		input: 'input0', codec, port: '8554', mount: '/' + codec };
let options = { uuid: 'b47bd8ea-7b8b-58c7-8354-88dbaddf57aa', port: 8080 };
let result = onvif_build(config, state, options);
assert(result.device_uuid == options.uuid && !('ifs' in result));
assert(length(result.profiles) == 3);
assert(result.source_width == 3840 && result.source_height == 2160);
assert(result.profiles[0].type == 'H264' && result.profiles[1].type == 'H265');
assert(result.profiles[2].type == 'JPEG' && result.profiles[2].quality == 50);
assert(result.profiles[0].encoding_profile == 'High');
assert(result.profiles[1].encoding_profile == 'Main');
assert(result.profiles[0].bitrate == 4000 && result.profiles[0].gov_length == 30);
assert(result.profiles[0].quality == 26);
assert(result.profiles[0].framerate == 30000 && result.profiles[0].framerate_den == 1001);
let board = {
	board_name: 'vendor,board /A', model: 'Vendor Camera', hostname: 'camera-lan',
	serial: 'serial-001', release: { description: 'OpenWrt SNAPSHOT r123' }
};
result = onvif_build(config, state, options, board);
assert(result.manufacturer == 'vendor' && result.model == board.model);
assert(result.firmware_ver == board.release.description);
assert(result.hardware_id == board.board_name && result.serial_num == board.serial);
assert(result.scopes[0] == 'onvif://www.onvif.org/name/camera-lan');
assert(result.scopes[1] == 'onvif://www.onvif.org/hardware/vendor%2Cboard%20%2FA');
result = onvif_build(config, state, { ...options, manufacturer: 'Camera Vendor',
	model: 'Custom Camera', firmware_ver: 'Custom firmware', hardware_id: 'board-02',
	serial: 'serial-002' }, board);
assert(result.manufacturer == 'Camera Vendor' && result.model == 'Custom Camera');
assert(result.firmware_ver == 'Custom firmware' && result.hardware_id == 'board-02');
assert(result.serial_num == 'serial-002');
assert(result.scopes[1] == 'onvif://www.onvif.org/hardware/board-02');
result = onvif_build(config, state, options, { model: 'Camera', hostname: 'cam',
	board_name: 'generic_board' });
assert(result.manufacturer == 'Unknown' && result.firmware_ver == 'Unknown');
assert(result.serial_num == options.uuid);
board.hostname = 'cam ' + chr(0xc3, 0xa9);
result = onvif_build(config, state, options, board);
assert(result.scopes[0] == 'onvif://www.onvif.org/name/cam%20%C3%A9');
config.h264.bitrate = '16000000';
config.h264.profile = 'baseline';
config.h264.keyframe_interval = '45';
result = onvif_build(config, state, options);
assert(result.profiles[0].bitrate == 16000 && result.profiles[0].gov_length == 45);
assert(result.profiles[0].encoding_profile == 'Baseline');
config.h264.bitrate = '16000123';
assert(rejected(config, state, options));
config.h264.bitrate = '16000000';
config.input0.framerate = 'auto';
assert(rejected(config, state, options));
config.input0.framerate = '30/1';
let automatic = { ...config, h264: { ...config.h264, enabled: '0' },
	mjpeg: { ...config.mjpeg, enabled: '0' },
	h265: { ...config.h265, codec: 'auto', resolution: 'native',
		bitrate_mode: 'quality', quality: 'high', framerate: 'auto' } };
let detected = { ...state, cameras: [{ key: '/base/sensor',
	native: { width: 4056, height: 3040 } }], runtime: {} };
assert(onvif_build(automatic, detected, options) == null);
controls.hevc_i_frame_qp_value.min = 1;
controls.hevc_p_frame_qp_value = { min: 1, max: 51, default: 28 };
detected.runtime.h265 = { codec: 'h265', width: '4056', height: '3040',
	framerate: '24000/1001', profile: 'main' };
let negotiated = onvif_build(automatic, detected, options).profiles[0];
assert(negotiated.width == 4056 && negotiated.height == 3040);
assert(negotiated.framerate == 24000 && negotiated.framerate_den == 1001);
assert(negotiated.bitrate == 0 && negotiated.quality == 32);
config.camera1 = { '.name': 'camera1', '.type': 'camera' };
config.input1 = { ...config.input0, camera: 'camera1' };
config.h264.input = 'input1';
assert(rejected(config, state, options));
assert(length(onvif_build(config, state, { ...options, camera: 'camera0' }).profiles) == 2);
config.input0.enabled = '0';
config.input1.enabled = '0';
assert(onvif_build(config, state, options) == null);
print('ONVIF metadata, board identity, scope encoding and source isolation passed\n');
