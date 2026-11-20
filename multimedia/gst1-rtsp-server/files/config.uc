import * as uci from 'uci';
import { pipeline_build, source_build, raw_caps_build, processors_build,
	encoding_build, sender_build, receiver_build, stream_resolve } from './model.uc';

function section_find(config, type, key) {
	return filter(values(config), s => s['.type'] == type && s.path == key)[0];
}

function section_add(cursor, config, prefix, type, options) {
	let index = 0;
	while (config[prefix + index])
		index++;
	let name = prefix + index;
	if (!cursor.set('gst-rtsp', name, type))
		die('Cannot add configuration section\n');
	config[name] = { '.name': name, '.type': type, ...options };
	for (let option, value in options)
		if (!cursor.set('gst-rtsp', name, option, value))
			die(`Cannot set ${name}.${option}\n`);
	return config[name];
}

function links_add(cursor, section, option, values) {
	let existing = section[option] ?? [];
	if (type(existing) != 'array')
		existing = [existing];
	for (let value in values) {
		if (index(existing, value) >= 0)
			continue;
		if (!cursor.list_append('gst-rtsp', section['.name'], option, value))
			die(`Cannot add ${section['.name']}.${option}\n`);
		push(existing, value);
	}
	section[option] = existing;
}

export function config_update(cursor, inventory) {
	if (!cursor.load('gst-rtsp'))
		die('Cannot load gst-rtsp configuration\n');
	let config = cursor.get_all('gst-rtsp'), devices = {};
	for (let key, device in inventory.devices) {
		let section = section_find(config, 'video-device', key);
		if (!section)
			section = section_add(cursor, config, 'device', 'video-device', {
				path: key, entity: device.entity, role: device.role, handled: '1' });
		devices[key] = section;
		links_add(cursor, section, 'capture_format', device.capture ?? []);
		links_add(cursor, section, 'output_format', device.output ?? []);
	}
	for (let key, device in inventory.devices) {
		let upstream = map(device.upstream, k => devices[k]?.['.name']);
		links_add(cursor, devices[key], 'upstream', filter(upstream, s => s != null));
	}
	for (let camera in inventory.cameras) {
		let section = section_find(config, 'camera', camera.key);
		if (!section) {
			let options = { path: camera.key, source: camera.source };
			for (let role in ['capture', 'sensor'])
				if (camera[role])
					options[role] = devices[camera[role]]['.name'];
			section = section_add(cursor, config, 'camera', 'camera', options);
		}
		links_add(cursor, section, 'devices', map(camera.devices, k => devices[k]['.name']));
		if (camera.id && section.id == null) {
			if (!cursor.set('gst-rtsp', section['.name'], 'id', camera.id))
				die('Cannot store camera ID\n');
		}
		if (section.configured != null)
			continue;
		let used = map(filter(values(config), s => s['.type'] == 'stream'), s => int(s.port));
		let port = 8554;
		while (index(used, port) >= 0 && port <= 65535)
			port++;
		if (port > 65535)
			die('No unused stream port\n');
		let input = section_add(cursor, config, 'input', 'input', {
			camera: section['.name'], enabled: '0', width: '0', height: '0',
			framerate: 'auto', pixel_format: 'auto',
			io_mode: camera.source == 'v4l2src' ? 'dmabuf' : 'auto' });
		section_add(cursor, config, 'stream', 'stream', {
			input: input['.name'], enabled: '0', port: '' + port, mount: '/test',
			codec: 'auto', resolution: 'native', framerate: 'auto', bitrate: '0',
			bitrate_mode: 'cbr', quality: 'high', jpeg_quality: 'auto',
			profile: 'auto', keyframe_interval: '0', pixel_format: 'auto',
			colourimetry: 'auto', output_io_mode: 'dmabuf-import',
			repeat_headers: 'auto', encoder: 'auto' });
		if (!cursor.set('gst-rtsp', section['.name'], 'configured', '1'))
			die('Cannot mark camera as configured\n');
		section.configured = '1';
	}
	let changed = length(cursor.changes('gst-rtsp')['gst-rtsp'] ?? []) > 0;
	if (changed && !cursor.commit('gst-rtsp'))
		die('Cannot commit gst-rtsp configuration\n');
	return changed;
};

export function devices_resolve(cursor, options) {
	for (let name in ['capture', 'encoder_device'])
		if (options[name])
			options[name] = cursor.get('gst-rtsp', options[name], 'path') ??
				die(`Unknown ${name} device\n`);
	if (options.processor) {
		let processors = type(options.processor) == 'array' ?
			options.processor : [options.processor];
		options.processor = map(processors, p => cursor.get('gst-rtsp', p, 'path') ??
			die('Unknown processor device\n'));
	}
	return options;
};

function stream_get(cursor, section) {
	let stream = cursor.get_all('gst-rtsp', section);
	if (!stream || stream['.type'] != 'stream')
		die('Unknown stream\n');
	let input = stream.input ? cursor.get_all('gst-rtsp', stream.input) : null;
	if (stream.input && (!input || input['.type'] != 'input'))
		die('Unknown capture input\n');
	let camera_name = input?.camera ?? stream.camera;
	let camera = camera_name ? cursor.get_all('gst-rtsp', camera_name) : null;
	if (camera_name && (!camera || camera['.type'] != 'camera'))
		die('Unknown camera\n');
	if (camera)
		devices_resolve(cursor, camera);
	devices_resolve(cursor, stream);
	return { stream, camera, input };
}

export function stream_pipeline(cursor, section, state) {
	let entry = stream_get(cursor, section);
	if (!entry.input || entry.stream.pipeline)
		return pipeline_build(entry.stream, entry.camera, state);
	if (entry.input.enabled != '1')
		die('Capture input is disabled\n');
	return receiver_build(stream_resolve(entry.stream, entry.input, entry.camera, state));
};

export function camera_pipeline(cursor, section, state) {
	let camera = cursor.get_all('gst-rtsp', section);
	if (!camera || camera['.type'] != 'camera')
		die('Unknown camera\n');
	/*
	 * A raw pipeline override: the camera section carries the whole
	 * capture pipeline (source, branches, the unixfdsink senders).
	 * The stream sections then carry only their receivers, e.g. to
	 * mix sources, insert software elements, or scale, which the
	 * automatic build cannot express.
	 */
	if (camera.pipeline)
		return camera.pipeline;
	devices_resolve(cursor, camera);
	let streams = [];
	cursor.foreach('gst-rtsp', 'stream', function(stream) {
		if (stream.enabled != '1' || stream.pipeline || !stream.input)
			return;
		if (cursor.get('gst-rtsp', stream.input, 'camera') == section)
			push(streams, stream['.name']);
	});
	if (!length(streams))
		return '';
	let pipeline = [], inputs = {}, pad = 0;
	if (camera.source == 'libcamerasrc')
		push(pipeline, source_build({}, camera, state) + ' name=camera');
	for (let name in streams) {
		let entry = stream_get(cursor, name);
		if (entry.input.enabled != '1')
			die('Capture input is disabled\n');
		if (entry.stream.source || entry.stream.capture || entry.stream.source_properties)
			die('Stream source settings belong to its capture input\n');
		let input = devices_resolve(cursor, { ...entry.input });
		let stream = stream_resolve(entry.stream, input, camera, state);
		let source;
		if (camera.source == 'libcamerasrc') {
			if (input.source || input.capture || input.source_properties)
				die('Libcamera owns capture and ISP output selection\n');
			for (let key in ['width', 'height', 'framerate', 'pixel_format', 'colourimetry'])
				if (!stream[key] || stream[key] == '0' || stream[key] == 'auto')
					stream[key] = input[key];
			let processing = processors_build(input, state) + processors_build(stream, state);
			let caps = raw_caps_build(stream);
			let key = processing + ' ! ' + caps;
			if (!inputs[key]) {
				let id = 'capture_' + pad;
				let output = pad == 0 ? 'camera.src' : 'camera.src_' + (pad - 1);
				push(pipeline, output + processing + ' ! ' + caps + ' ! tee name=' + id);
				inputs[key] = id;
				pad++;
			}
			source = inputs[key] + '.';
		} else {
			let id = entry.stream.input;
			if (!match(id, /^[a-zA-Z0-9_]+$/))
				die('Invalid input section name\n');
			if (!inputs[id]) {
				if (camera.source == 'v4l2src' && input.io_mode != 'dmabuf')
					die('V4L2 capture requires DMABUF export\n');
				push(pipeline, source_build(input, camera, state) + ' ! ' +
					raw_caps_build(input) + ' ! tee name=' + id);
				inputs[id] = true;
			}
			source = id + '.';
			source += processors_build(stream, state);
		}
		push(pipeline, source + ' ! ' + encoding_build(stream, state) + ' ! ' +
			sender_build(stream));
	}
	return join(' ', pipeline);
};
