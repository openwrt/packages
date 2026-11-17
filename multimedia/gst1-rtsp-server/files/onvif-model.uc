import { encoder_select, stream_resolve, quantisers_get } from './model.uc';

function positive(value, name) {
	if (!match('' + value, /^[1-9][0-9]*$/))
		die(`ONVIF requires an explicit ${name}\n`);
	return int(value);
}

function setting_get(stream, input, key) {
	return stream[key] && stream[key] != 'auto' && stream[key] != '0' ?
		stream[key] : input[key];
}

function profile_build(stream, input, state) {
	let selected = encoder_select(stream, state);
	let controls = state.devices?.[selected.key]?.controls ?? {};
	let codec = stream.codec ?? 'h264';
	let framerate = setting_get(stream, input, 'framerate');
	if (!match('' + framerate, /^[1-9][0-9]*(\/[1-9][0-9]*)?$/))
		die('ONVIF requires an explicit frame rate\n');
	let fps = split(framerate, '/');
	let profile = {
		name: stream['.name'],
		width: positive(setting_get(stream, input, 'width'), 'stream width'),
		height: positive(setting_get(stream, input, 'height'), 'stream height'),
		framerate: int(fps[0]), framerate_den: int(fps[1] ?? '1'),
		type: { h264: 'H264', h265: 'H265', mjpeg: 'JPEG' }[codec],
		url: `rtsp://%s:${stream.port ?? '8554'}${stream.mount ?? '/test'}`,
		audio_encoder: 'NONE', audio_decoder: 'NONE',
		bitrate: 0, quality: 0, gov_length: 1
	};
	if (codec == 'mjpeg') {
		profile.quality = stream.bitrate_mode == 'quality' ? controls.compression_quality?.max :
			stream.jpeg_quality && stream.jpeg_quality != 'auto' ?
			int(stream.jpeg_quality) : controls.compression_quality?.default;
		if (profile.quality == null)
			die('ONVIF JPEG quality is unknown\n');
		return profile;
	}
	let bitrate = stream.bitrate_mode == 'quality' ? 0 :
		(int(stream.bitrate) || controls.video_bitrate?.default);
	if (bitrate == null || bitrate % 1000)
		die('ONVIF bitrate must be known and representable in kbps\n');
	profile.bitrate = bitrate / 1000;
	profile.gov_length = int(stream.keyframe_interval) || controls.video_gop_size?.default;
	if (!profile.gov_length)
		die('ONVIF GOP length is unknown\n');
	let control = codec == 'h264' ? 'h264_profile' : 'hevc_profile';
	let name = stream.profile && stream.profile != 'auto' ? stream.profile :
		lc(controls[control]?.menu?.['' + controls[control]?.default] ?? '');
	profile.encoding_profile = {
		baseline: 'Baseline', main: 'Main', high: 'High', extended: 'Extended', main10: 'Main10'
	}[name];
	if (!profile.encoding_profile)
		die('ONVIF codec profile is unknown\n');
	let qp = controls[codec == 'h264' ? 'h264_i_frame_qp_value' : 'hevc_i_frame_qp_value'];
	if (qp?.default == null || qp?.max == null)
		die('ONVIF quantiser quality is unknown\n');
	let quantiser = stream.bitrate_mode == 'quality' ?
		quantisers_get(stream, controls)[codec == 'h264' ?
			'h264_i_frame_qp_value' : 'hevc_i_frame_qp_value'] : qp.default;
	profile.quality = qp.max + 1 - quantiser;
	return profile;
}

function scope_component(value) {
	let encoded = '';
	for (let offset = 0; offset < length(value); offset++) {
		let byte = ord(value, offset);
		let character = chr(byte);
		encoded += match(character, /^[a-zA-Z0-9_.~-]$/) ?
			character : sprintf('%%%02X', byte);
	}
	return encoded;
}

export function onvif_build(config, state, options, board) {
	board ??= {};
	let profiles = [], cameras = {};
	for (let stream in values(config)) {
		if (stream['.type'] != 'stream' || stream.enabled != '1' || stream.onvif == '0')
			continue;
		let input = config[stream.input];
		if (!input || input.enabled != '1')
			continue;
		let camera = config[input.camera];
		if (!camera || (options.camera && options.camera != camera['.name']))
			continue;
		if (stream.pipeline)
			die('ONVIF needs generated stream settings\n');
		if (length(stream['.name']) > 46)
			die('ONVIF stream token exceeds the supported length\n');
		let resolved = stream_resolve(stream, input, camera, state);
		if (state.runtime != null) {
			let actual = state.runtime[stream['.name']];
			if (!actual)
				return null;
			resolved = { ...resolved, ...actual };
		}
		push(profiles, profile_build(resolved, input, state));
		cameras[camera['.name']] = camera;
	}
	if (!length(profiles))
		return null;
	if (length(cameras) != 1)
		die('Select one ONVIF camera in onvif-simple-server.main.camera\n');
	let camera = values(cameras)[0];
	let hardware = options.hardware_id ?? board.board_name ?? camera.path ?? camera['.name'];
	let vendor = index(board.board_name ?? '', ',') >= 0 ?
		split(board.board_name, ',')[0] : 'Unknown';
	let hostname = board.hostname ?? options.uuid;
	let result = {
		device_uuid: options.uuid, port: options.port,
		manufacturer: options.manufacturer ?? vendor,
		model: options.model ?? board.model ?? 'GStreamer camera',
		firmware_ver: options.firmware_ver ?? board.release?.description ?? 'Unknown',
		hardware_id: hardware,
		serial_num: options.serial ?? board.serial ?? options.uuid,
		scopes: [
			'onvif://www.onvif.org/name/' + scope_component(hostname),
			'onvif://www.onvif.org/hardware/' + scope_component(hardware)
		],
		adv_enable_media2: true, events_enable: 0,
		profiles
	};
	for (let key in ['source_width', 'source_height', 'source_framerate', 'source_framerate_den'])
		if (camera[key])
			result[key] = positive(camera[key], key);
	if (options.user) {
		result.user = options.user;
		result.password = options.password ?? die('ONVIF password is required\n');
	}
	return result;
};
