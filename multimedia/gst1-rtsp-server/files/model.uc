import { readfile, realpath, glob, basename, dirname, popen } from 'fs';

export const MEDIA_SYSFS = 'bus/media/devices';

const V4L2_CAP_META_CAPTURE = 0x00800000;
const V4L2_CAP_VIDEO_M2M = 0x00008000;
const V4L2_CAP_VIDEO_M2M_MPLANE = 0x00004000;
const V4L2_CAP_VIDEO_CAPTURE = 0x00000001;
const V4L2_CAP_VIDEO_CAPTURE_MPLANE = 0x00001000;
const V4L2_CAP_IO_MC = 0x20000000;

export function gst_quote(value) {
	return '"' + replace('' + value, /[\\"]/g, '\\$&') + '"';
};

export function launch_argv(pipeline) {
	return pipeline ? ['/usr/bin/gst-launch-1.0', '-q', ...split(pipeline, ' ')] : [];
};

function shell_quote(value) {
	return "'" + replace(value, /'/g, "'\\''") + "'";
}

export function command_read(args) {
	let pipe = popen(join(' ', map(args, shell_quote)) + ' 2>/dev/null', 'r');
	if (!pipe)
		die(`Cannot run ${args[0]}\n`);
	let text = pipe.read('all');
	let status = pipe.close();
	return status == 0 ? text : null;
};

export function path_normalise(path) {
	let parts = split(path, '/');
	return join('/', map(parts, function(part) {
		if (match(part, /^usb[0-9]+$/))
			return 'usb';
		let usb = match(part, /^[0-9]+-([0-9.]+(:[0-9]+\.[0-9]+)?)$/);
		return usb ? usb[1] : part;
	}));
};

function firmware_path(device, root) {
	let path = realpath(device + '/of_node');
	if (path)
		return replace(path, root + '/firmware/devicetree', '');
	return trim(readfile(device + '/firmware_node/path') ?? '');
}

export function node_identity(root, name, entity, role) {
	let device = realpath(`${root}/class/video4linux/${name}/device`);
	if (!device && realpath(`${root}/class/video4linux/${name}`) ==
	    `${root}/devices/virtual/video4linux/${name}`)
		device = `${root}/devices/virtual`;
	if (!device)
		return null;
	let firmware = firmware_path(device, root);
	let path = path_normalise(replace(device, root + '/devices/', ''));
	let endpoint = entity ?? trim(readfile(`${root}/class/video4linux/${name}/name`) ?? '');
	if (!endpoint)
		return null;
	let key = firmware && match(name, /^v4l-subdev/) ? firmware :
		`${path}/${role}/${endpoint}`;
	return { key, path, entity: endpoint, firmware };
};

export function media_parse(text) {
	let entities = [], current, pad;
	for (let line in split(text ?? '', '\n')) {
		let entity = match(line, /^- entity [0-9]+: (.*) \([0-9]+ pad/);
		if (entity) {
			current = { name: entity[1], links: [] };
			push(entities, current);
			continue;
		}
		if (!current)
			continue;
		let node = match(line, /device node name (\/dev\/(video[0-9]+|v4l-subdev[0-9]+))/);
		if (node)
			current.node = basename(node[1]);
		let subtype = match(line, /subtype ([^ ]+)/);
		if (subtype)
			current.role = subtype[1] == 'Sensor' ? 'sensor' : 'subdevice';
		let p = match(line, /^\s*pad([0-9]+):/);
		if (p)
			pad = int(p[1]);
		let link = match(line, /^\s*<- "(.*)":([0-9]+) \[(.*)\]/);
		if (link)
			push(current.links, { entity: link[1], source_pad: int(link[2]),
				sink_pad: pad, enabled: index(link[3], 'ENABLED') >= 0 });
	}
	return entities;
};

export function formats_parse(text) {
	let formats = [];
	for (let line in split(text ?? '', '\n')) {
		let format = match(line, /\[[0-9]+\]: '([^']+)'/);
		if (format)
			push(formats, format[1]);
	}
	return uniq(formats);
};

export function role_parse(text, capture, output) {
	let caps = match(text ?? '', /Device Caps\s*:\s*(0x[0-9a-fA-F]+)/);
	if (!caps)
		caps = match(text ?? '', /Capabilities\s*:\s*(0x[0-9a-fA-F]+)/);
	if (!caps)
		return null;
	let value = int(caps[1], 16);
	if (value & V4L2_CAP_META_CAPTURE)
		return 'metadata';
	if (value & (V4L2_CAP_VIDEO_M2M | V4L2_CAP_VIDEO_M2M_MPLANE)) {
		let encoded = f => index(['H264', 'HEVC', 'MJPG', 'JPEG'], f) >= 0;
		if (length(filter(capture, encoded)) && !length(filter(output, encoded)))
			return 'encoder';
		if (length(filter(output, encoded)))
			return 'decoder';
		return 'processor';
	}
	if (value & (V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_VIDEO_CAPTURE_MPLANE))
		return value & V4L2_CAP_IO_MC ? 'capture_mc' : 'capture';
	return 'output';
};

function graph_read(root, run, nodes) {
	let graphs = [];
	for (let path in sort(glob(`${root}/${MEDIA_SYSFS}/media*`))) {
		let name = basename(path);
		let text = run(['media-ctl', '-d', '/dev/' + name, '-p']);
		if (text == null)
			die(`Cannot inspect /dev/${name}\n`);
		let target = realpath(path);
		if (!target)
			continue;
		let parent = dirname(target);
		let graph = path_normalise(replace(parent, root + '/devices/', ''));
		let entities = media_parse(text), by_name = {};
		for (let entity in entities) {
			let node = entity.node ? nodes[entity.node] : null;
			if (node) {
				let identity = node_identity(root, entity.node, entity.name, node.role);
				node = { ...node, ...identity };
				nodes[entity.node] = node;
			}
			if (!node) {
				let identity = entity.node ?
					node_identity(root, entity.node, entity.name, entity.role) : null;
				node = { ...(identity ?? { key: `${graph}/${entity.name}`,
					path: graph, entity: entity.name }), role: entity.role ?? 'subdevice',
					node: entity.node ? '/dev/' + entity.node : null, upstream: [], links: [] };
				if (entity.node)
					nodes[entity.node] = node;
				else
					nodes[`${graph}/${entity.name}`] = node;
			}
			by_name[entity.name] = node;
			entity.device = node;
		}
		for (let entity in entities) {
			for (let link in entity.links) {
				let upstream = by_name[link.entity];
				if (!upstream)
					continue;
				push(entity.device.upstream, upstream.key);
				push(entity.device.links, { source: upstream.key,
					source_pad: link.source_pad, sink_pad: link.sink_pad,
					enabled: link.enabled });
			}
		}
		push(graphs, { path: graph, devices: uniq(map(entities, e => e.device.key)) });
	}
	return graphs;
}

export function cameras_parse(text) {
	let cameras = [];
	for (let block in split(text ?? '', 'Device found:')) {
		if (!match(block, /gst-launch-1.0 libcamerasrc /))
			continue;
		let name = match(block, /\n\s*name\s*:\s*([^\n]+)/);
		if (!name)
			continue;
		let caps = [], active;
		for (let line in split(block, '\n')) {
			let first = match(line, /^\s*caps\s*:\s*(.*)/);
			if (first) {
				push(caps, first[1]);
				active = true;
				continue;
			}
			if (active && match(line, /^\s*(properties:|gst-launch-1.0)/))
				active = false;
			if (active && trim(line))
				push(caps, trim(line));
		}
		let size = match(block, /api\.libcamera\.PixelArraySize\s*=\s*<\s*\(int\)\s*([0-9]+),\s*\(int\)\s*([0-9]+)/);
		push(cameras, { id: trim(name[1]), source: 'libcamerasrc', caps,
			native: size ? { width: int(size[1]), height: int(size[2]) } : null });
	}
	return cameras;
};

export function encoder_device_parse(text) {
	let property;
	for (let line in split(text ?? '', '\n')) {
		let field = match(line, /^  ([a-zA-Z0-9_-]+) +:/);
		if (field)
			property = field[1];
		let value = match(line, /Default: "(\/dev\/video[0-9]+)"/);
		if (property == 'device' && value)
			return value[1];
	}
};

function factories_read(nodes, run) {
	let result = { encoders: [], processors: [] };
	let text = run(['gst-inspect-1.0', '--plugin', 'video4linux2']);
	for (let line in split(text ?? '', '\n')) {
		let factory = match(line, /^\s*([^ :]+(h264enc|h265enc|jpegenc|convert)):/);
		if (!factory)
			continue;
		let device = encoder_device_parse(run(['gst-inspect-1.0', factory[1]]));
		let node = filter(values(nodes), n => n.node == device)[0];
		if (!node)
			continue;
		if (factory[2] == 'convert' && node.role == 'processor')
			push(result.processors, { key: node.key, factory: factory[1] });
		else if (node.role == 'encoder' && factory[2] != 'convert')
			push(result.encoders, { key: node.key,
				codec: factory[2] == 'jpegenc' ? 'mjpeg' : substr(factory[2], 0, 4),
				factory: factory[1] });
	}
	return result;
}

export function controls_parse(text) {
	let controls = {}, current;
	for (let line in split(text ?? '', '\n')) {
		let field = match(line, /^\s*([a-zA-Z0-9_]+)\s+(0x[0-9a-fA-F]+)\s+\(([^)]+)\)\s*:\s*(.*)/);
		if (field) {
			current = { id: int(field[2], 16), type: field[3], menu: {} };
			controls[field[1]] = current;
			for (let word in split(field[4], ' ')) {
				let range = match(word, /^(min|max|step|default)=(-?[0-9]+)$/);
				if (range)
					current[range[1]] = int(range[2]);
			}
			continue;
		}
		let menu = match(line, /^\s*([0-9]+): (.*)$/);
		if (menu && current)
			current.menu[menu[1]] = menu[2];
	}
	return controls;
};

export function inventory_read(root, run) {
	let nodes = {};
	for (let path in sort(glob(`${root}/class/video4linux/video*`))) {
		let name = basename(path);
		let info = run(['v4l2-ctl', '-d', '/dev/' + name, '-D']);
		if (info == null)
			die(`Cannot inspect /dev/${name}\n`);
		let capture = formats_parse(run(['v4l2-ctl', '-d', '/dev/' + name, '--list-formats']));
		let output = formats_parse(run(['v4l2-ctl', '-d', '/dev/' + name, '--list-formats-out']));
		let role = role_parse(info, capture, output);
		let identity = role ? node_identity(root, name, null, role) : null;
		if (!identity)
			die(`No stable identity for /dev/${name}\n`);
		let controls = controls_parse(run(['v4l2-ctl', '-d', '/dev/' + name,
			'--list-ctrls-menus']));
		nodes[name] = { ...identity, role, capture, output, controls, node: '/dev/' + name,
			upstream: [], links: [] };
	}
	let graphs = graph_read(root, run, nodes);
	let cameras = cameras_parse(run(['gst-device-monitor-1.0', '-i', 'Video/Source']));
	let result = { devices: {}, graphs, cameras: [], ...factories_read(nodes, run) };
	for (let name, node in nodes) {
		if (result.devices[node.key])
			die(`Ambiguous video identity: ${node.key}\n`);
		result.devices[node.key] = node;
	}
	for (let camera in cameras) {
		let sensor = filter(values(nodes), n => n.firmware == camera.id)[0];
		if (!sensor)
			continue;
		let graph = filter(graphs, g => index(g.devices, sensor.key) >= 0)[0];
		push(result.cameras, { ...camera, key: camera.id, sensor: sensor.key,
			devices: graph?.devices ?? [sensor.key] });
	}
	for (let name, node in nodes) {
		if (node.role != 'capture')
			continue;
		push(result.cameras, { key: node.key, capture: node.key,
			source: 'v4l2src', devices: [node.key] });
	}
	return result;
};

function number_get(options, name, maximum) {
	let value = options[name];
	if (value == null || value == '' || value == 'auto')
		return 0;
	if (!match('' + value, /^[0-9]+$/) || int(value) > maximum)
		die(`Invalid ${name}\n`);
	return int(value);
}

function camera_controls_build(camera) {
	let properties = [];
	for (let name, property in { exposure: 'exposure-time', gain: 'analogue-gain',
		brightness: 'brightness', contrast: 'contrast', saturation: 'saturation',
		sharpness: 'sharpness' }) {
		let value = camera?.[name];
		if (value == null)
			continue;
		if (camera.source != 'libcamerasrc')
			die('Named camera controls require the libcamera source\n');
		if (value != 'auto' && !match(value, /^-?[0-9]+(\.[0-9]+)?$/))
			die(`Invalid camera ${name}\n`);
		if (name == 'exposure' || name == 'gain')
			push(properties, `${property}-mode=${value == 'auto' ? 0 : 1}`);
		if (value != 'auto')
			push(properties, `${property}=${value}`);
	}
	return join(' ', properties);
}

export function processors_build(stream, state) {
	let pipeline = '';
	let processors = stream.processor ?? [];
	if (type(processors) != 'array')
		processors = [processors];
	for (let key in processors) {
		let processor = filter(state.processors ?? [], p => p.key == key)[0];
		if (!processor)
			die('Processor device is absent or has no GStreamer converter\n');
		pipeline += ' ! ' + processor.factory +
			' disable-passthrough=true output-io-mode=dmabuf-import capture-io-mode=dmabuf';
	}
	return pipeline;
};

export function source_build(stream, camera, state) {
	let source = stream.source ?? camera?.source ?? 'autovideosrc';
	if (!match(source, /^[a-zA-Z0-9_]+$/))
		die('Invalid source factory\n');
	let capture = stream.capture ?? camera?.capture;
	let camera_id = stream.camera_id ?? camera?.id;
	if (source == 'libcamerasrc' && camera_id)
		source += ' camera-name=' + gst_quote(camera_id);
	if (source == 'v4l2src' && capture) {
		let node = state.devices?.[capture]?.node;
		if (!node)
			die('Capture device is absent\n');
		source += ' device=' + gst_quote(node);
		if (stream.io_mode && stream.io_mode != 'auto') {
			if (index(['rw', 'mmap', 'userptr', 'dmabuf', 'dmabuf-import'], stream.io_mode) < 0)
				die('Invalid capture io_mode\n');
			source += ' io-mode=' + stream.io_mode;
		}
	}
	let controls = camera_controls_build(camera);
	if (controls)
		source += ' ' + controls;
	if (camera?.source_properties)
		source += ' ' + camera.source_properties;
	if (stream.source_properties)
		source += ' ' + stream.source_properties;
	return source + processors_build(stream, state);
};

export function raw_caps_build(stream) {
	let raw = 'video/x-raw';
	for (let name in ['width', 'height']) {
		let value = number_get(stream, name, 2147483647);
		if (value)
			raw += `,${name}=${value}`;
	}
	if (stream.framerate && stream.framerate != 'auto') {
		if (!match(stream.framerate, /^[1-9][0-9]*(\/[1-9][0-9]*)?$/))
			die('Invalid framerate\n');
		raw += ',framerate=' + stream.framerate +
			(index(stream.framerate, '/') < 0 ? '/1' : '');
	}
	for (let key, name in { pixel_format: 'format', colourimetry: 'colorimetry' }) {
		if (!stream[key] || stream[key] == 'auto')
			continue;
		if (!match(stream[key], /^[a-zA-Z0-9_-]+$/))
			die(`Invalid ${key}\n`);
		raw += `,${name}=${stream[key]}`;
	}
	return raw;
};

export function encoder_select(stream, state) {
	let codec = stream.codec ?? 'h264';
	if (codec == 'auto') {
		for (let candidate in ['h265', 'h264', 'mjpeg']) {
			let available = filter(state.encoders ?? [], e => e.codec == candidate &&
				(!stream.encoder_device || e.key == stream.encoder_device) &&
				(!stream.encoder || stream.encoder == 'auto' || e.factory == stream.encoder));
			if (length(available)) {
				codec = candidate;
				break;
			}
		}
	}
	if (index(['h264', 'h265', 'mjpeg'], codec) < 0)
		die('Invalid codec\n');
	let candidates = filter(state.encoders ?? [], e => e.codec == codec);
	let encoder = stream.encoder ?? 'auto';
	let selected = stream.encoder_device ?
		filter(candidates, e => e.key == stream.encoder_device)[0] :
		(encoder == 'auto' ? candidates[0] : filter(candidates, e => e.factory == encoder)[0]);
	if (encoder == 'auto' || stream.encoder_device) {
		if (!selected)
			die('No hardware encoder supports the requested codec\n');
		encoder = selected.factory;
	}
	if (!match(encoder, /^[a-zA-Z0-9_]+$/))
		die('Invalid encoder factory\n');
	return { ...(selected ?? {}), codec, factory: encoder };
};

export function stream_resolve(stream, input, camera, state) {
	stream = { ...stream };
	for (let key in ['width', 'height', 'framerate', 'pixel_format', 'colourimetry'])
		if (!stream[key] || stream[key] == '0' || stream[key] == 'auto')
			stream[key] = input?.[key];
	if (stream.resolution == 'native') {
		let device = filter(state.cameras ?? [], c => c.key == camera?.path)[0];
		if (!device?.native?.width || !device.native.height)
			die('Sensor-native resolution is unavailable\n');
		stream.width = device.native.width;
		stream.height = device.native.height;
	}
	stream.codec = encoder_select(stream, state).codec;
	return stream;
};

export function quantisers_get(stream, controls) {
	let prefix = stream.codec == 'h265' ? 'hevc' : 'h264';
	let result = {};
	let offset = { high: -6, medium: 0, low: 6 }[stream.quality ?? 'high'];
	if (offset == null)
		die('Invalid encoder quality\n');
	for (let frame in ['i', 'p']) {
		let name = `${prefix}_${frame}_frame_qp_value`;
		let control = controls[name];
		if (control?.default == null || control.min == null || control.max == null)
			die('Hardware quantiser controls are unavailable\n');
		result[name] = max(control.min, min(control.max, control.default + offset));
	}
	return result;
};

/* 15 Mbit/s for 3856x2192 at 30 fps in H.265; H.264 needs about twice */
const BITS_PER_KILOPIXEL = { h265: 60, h264: 120 };
/* The sensor modes in use run at 30 fps when no rate is configured */
const DEFAULT_FRAMERATE = 30;

export function bitrate_default(stream, codec) {
	let width = number_get(stream, 'width', 2147483647);
	let height = number_get(stream, 'height', 2147483647);
	if (!width || !height || !BITS_PER_KILOPIXEL[codec])
		return 0;
	let num = DEFAULT_FRAMERATE, den = 1;
	let framerate = match('' + (stream.framerate ?? ''), /^([1-9][0-9]*)(\/([1-9][0-9]*))?$/);
	if (framerate) {
		num = int(framerate[1]);
		den = framerate[3] ? int(framerate[3]) : 1;
	}
	return int(width * height * num * BITS_PER_KILOPIXEL[codec] / (den * 1000));
};

export function encoding_build(stream, state) {
	let selected = encoder_select(stream, state);
	let codec = selected.codec;
	let encoder = selected.factory;
	let bitrate = number_get(stream, 'bitrate', 2147483647);
	let keyframe = number_get(stream, 'keyframe_interval', 2147483647);
	let quality = stream.jpeg_quality;
	let bitrate_mode = stream.bitrate_mode ?? 'auto';
	let properties = [], controls = [];
	let hardware = substr(encoder, 0, 4) == 'v4l2';
	if (hardware && !selected.key)
		die('Encoder factory is not associated with discovered hardware\n');
	if (codec == 'mjpeg' && (bitrate || keyframe))
		die('MJPEG uses jpeg_quality rather than bitrate or keyframe_interval\n');
	if (index(['auto', 'cbr', 'vbr', 'quality'], bitrate_mode) < 0)
		die('Invalid bitrate_mode\n');
	if (bitrate_mode != 'auto' && (!hardware ||
	    (codec == 'mjpeg' && bitrate_mode != 'quality')))
		die('Explicit bitrate mode requires a hardware H.264 or H.265 encoder\n');
	if (hardware) {
		if (stream.output_io_mode && stream.output_io_mode != 'auto' &&
		    stream.output_io_mode != 'dmabuf-import')
			die('Hardware encoding requires DMABUF import\n');
		push(properties, 'output-io-mode=dmabuf-import');
		push(properties, 'capture-io-mode=mmap');
		if (bitrate_mode == 'quality' && codec != 'mjpeg') {
			if (bitrate)
				die('Quality mode has no bitrate target\n');
			let available = state.devices[selected.key].controls;
			if (!available?.frame_level_rate_control_enable)
				die('Hardware fixed-quantiser mode is unavailable\n');
			push(controls, 'frame_level_rate_control_enable=(int)0');
			for (let name, value in quantisers_get({ ...stream, codec }, available))
				push(controls, `${name}=(int)${value}`);
		}
		if (bitrate_mode == 'quality' && codec == 'mjpeg') {
			let control = state.devices[selected.key].controls?.compression_quality;
			if (control?.max == null)
				die('Hardware JPEG quality control is unavailable\n');
			quality = '' + control.max;
		}
		if (!bitrate && (bitrate_mode == 'cbr' || bitrate_mode == 'vbr'))
			bitrate = bitrate_default(stream, codec);
		if (bitrate)
			push(controls, `video_bitrate=(int)${bitrate}`);
		if (bitrate_mode == 'cbr' || bitrate_mode == 'vbr') {
			let mode = bitrate_mode == 'cbr' ? 1 : 0;
			let supported = state.devices?.[selected.key]?.controls?.video_bitrate_mode;
			if (supported?.menu?.['' + mode] == null)
				die('Hardware encoder does not support the requested bitrate mode\n');
			push(controls, `video_bitrate_mode=(int)${mode}`);
		}
		if (keyframe)
			push(controls, `video_gop_size=(int)${keyframe}`);
		if (stream.repeat_headers == '1' || (stream.repeat_headers == 'auto' &&
		    state.devices[selected.key].controls?.prepend_sps_and_pps_to_idr))
			push(controls, 'prepend_sps_and_pps_to_idr=(int)1');
	} else if (encoder == 'x264enc' || encoder == 'x265enc') {
		if (bitrate)
			push(properties, 'bitrate=' + int((bitrate + 999) / 1000));
		if (keyframe)
			push(properties, 'key-int-max=' + keyframe);
	} else if (encoder == 'openh264enc') {
		if (bitrate)
			push(properties, 'bitrate=' + bitrate);
		if (keyframe)
			push(properties, 'gop-size=' + keyframe);
	} else if (bitrate || keyframe) {
		die('Encoder bitrate and keyframe controls are unknown\n');
	}
	if (quality != null && quality != '' && quality != 'auto') {
		if (codec != 'mjpeg')
			die('jpeg_quality requires MJPEG\n');
		if (!match('' + quality, /^[0-9]+$/) || int(quality) > 100)
			die('Invalid jpeg_quality\n');
		quality = int(quality);
		if (hardware) {
			let device = state.devices?.[selected?.key];
			if (!device?.controls?.compression_quality)
				die('Hardware JPEG quality control is unavailable\n');
			push(controls, 'compression_quality=(int)' + quality);
		} else if (encoder == 'jpegenc') {
			push(properties, 'quality=' + quality);
		} else {
			die('JPEG quality controls are unknown for the selected encoder\n');
		}
	}
	if (length(controls))
		push(properties, 'extra-controls=' + gst_quote('controls,' + join(',', controls) + ';'));
	let raw = raw_caps_build(stream);
	if (encoder == 'jpegenc' && (!stream.pixel_format || stream.pixel_format == 'auto'))
		raw += ',format=I420';
	let encoded = codec == 'mjpeg' ? 'image/jpeg' : `video/x-${codec}`;
	if (stream.profile && stream.profile != 'auto') {
		if (codec == 'mjpeg' || !match(stream.profile, /^[a-zA-Z0-9_-]+$/))
			die('Invalid codec profile\n');
		encoded += ',profile=' + stream.profile;
	}
	return `${raw} ! queue ! ${encoder} ${join(' ', properties)} ! ${encoded}`;
};

export function payloader_build(codec, name) {
	if (index(['mjpeg', 'h264', 'h265'], codec) < 0)
		die('Invalid codec\n');
	name ??= 'pay0';
	return codec == 'mjpeg' ? `rtpjpegpay name=${name} pt=26` :
		`${codec}parse ! rtp${codec}pay name=${name} pt=96 config-interval=1`;
};

export function pipeline_build(stream, camera, state) {
	if (stream.pipeline)
		return stream.pipeline;
	stream = stream_resolve(stream, null, camera, state);
	return `( ${source_build(stream, camera, state)} ! ${encoding_build(stream, state)}` +
		` ! ${payloader_build(stream.codec ?? 'h264')} )`;
};

function socket_properties_build(stream) {
	let name = stream['.name'];
	if (!name || !match(name, /^[a-zA-Z0-9_]+$/))
		die('Invalid stream section name\n');
	return 'socket-type=abstract socket-path=' + gst_quote('gst-rtsp.' + name);
}

export function sender_build(stream) {
	return 'unixfdsink ' + socket_properties_build(stream) +
		' name=stream_' + stream['.name'] + ' sync=false async=false';
};

export function stream_caps_parse(line) {
	let sink = match(line, /GstUnixFdSink:stream_([a-zA-Z0-9_]+)[./]GstPad:sink: caps = (video\/x-h26[45]|image\/jpeg),/);
	if (!sink)
		return null;
	let result = { name: sink[1], codec: sink[2] == 'image/jpeg' ? 'mjpeg' :
		substr(sink[2], length('video/x-')) };
	for (let field in ['width', 'height', 'framerate', 'profile']) {
		let value = match(line, regexp('(^|, )' + field + '=\\([a-z]+\\)([^, ]+)'));
		if (value)
			result[field] = value[2];
	}
	return result.width && result.height && result.framerate ? result : null;
};

export function receiver_build(stream) {
	return '( unixfdsrc ' + socket_properties_build(stream) + ' ! ' +
		payloader_build(stream.codec ?? 'h264') + ' )';
};
