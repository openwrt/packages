// Read and write /etc/tellstick.conf (the telldusd config, libconfuse format).
// A library: telldus-mqtt-uci2tellstick.uc and telldus-mqtt-tellstick2uci.uc
// load it with loadfile(). It has no main.
//
// The options are the ones of telldus-core service/SettingsConfuse.cpp.
// libconfuse stops on an unknown option, so this parser does the same.

'use strict';

import * as fs from 'fs';

// Parameters of a device, in the order of SettingsConfuse.cpp
const PARAMETERS = [ 'devices', 'house', 'unit', 'code', 'system', 'units', 'fade' ];

// Global settings for a new file. telldusd changes to this user and group:
// OpenWrt has no "plugdev" group (the telldus-core default), so use root.
const DEFAULT_HEADER =
	'user = "root"\n' +
	'group = "root"\n' +
	'deviceNode = "/dev/tellstick"\n' +
	'ignoreControllerConfirmation = "false"\n';

// Option spec: name (lower case) -> 'str', 'int' or a section spec
const SPEC_PARAMETERS = { section: 'parameters', multi: false, opts: {} };
for (let p in PARAMETERS)
	SPEC_PARAMETERS.opts[p] = 'str';

const SPEC_DEVICE = { section: 'device', multi: true, opts: {
	id: 'int', name: 'str', controller: 'int', protocol: 'str', model: 'str',
	parameters: SPEC_PARAMETERS
} };
const SPEC_CONTROLLER = { section: 'controller', multi: true, opts: {
	id: 'int', name: 'str', type: 'int', serial: 'str'
} };
const SPEC_TOP = { section: null, multi: false, opts: {
	user: 'str', group: 'str', devicenode: 'str', ignorecontrollerconfirmation: 'str',
	device: SPEC_DEVICE, controller: SPEC_CONTROLLER
} };

// libconfuse defaults of the options
function defaults(spec) {
	if (spec == SPEC_DEVICE)
		return { id: -1, name: 'Unnamed', controller: 0, protocol: 'arctech', model: '', parameters: {} };
	if (spec == SPEC_CONTROLLER)
		return { id: -1, name: '', type: 0, serial: '' };
	if (spec == SPEC_TOP)
		return { user: 'nobody', group: 'plugdev', devicenode: '/dev/tellstick',
			ignorecontrollerconfirmation: 'false', device: [], controller: [] };
	return {};
}

// ---- Tokenizer (as libconfuse src/lexer.l) ----

const C_NL = 10, C_CR = 13, C_TAB = 9, C_SP = 32, C_HASH = 35, C_DQ = 34, C_SQ = 39,
	C_SLASH = 47, C_STAR = 42, C_BSL = 92, C_DOLLAR = 36, C_LBRACE = 123;

// Characters that end an unquoted string: space # " ' \t \n \r = { } ( ) + , *
function ends_unquoted(c) {
	return c == null || index([ 32, 35, 34, 39, 9, 10, 13, 61, 123, 125, 40, 41, 43, 44, 42 ], c) >= 0;
}

function hexval(c) {
	if (c >= 48 && c <= 57) return c - 48;
	if (c >= 65 && c <= 70) return c - 55;
	if (c >= 97 && c <= 102) return c - 87;
	return -1;
}

// text -> [ { t: 'str' | '{' | '}' | '=' | '+=' | '(' | ')' | ',', v, start, end, line } ]
// Calls die() for what libconfuse refuses, and for what this parser does
// not support safely (environment variables, stray characters).
function tokenize(text) {
	let tokens = [];
	let n = length(text);
	let i = 0;
	let line = 1;

	function fail(msg) {
		die(sprintf('line %d: %s', line, msg));
	}

	while (i < n) {
		let c = ord(text, i);
		let c2 = (i + 1 < n) ? ord(text, i + 1) : null;
		let start = i;

		if (c == C_SP || c == C_TAB || c == C_CR) {
			i++;
		}
		else if (c == C_NL) {
			line++;
			i++;
		}
		else if (c == C_HASH || (c == C_SLASH && c2 == C_SLASH)) {
			while (i < n && ord(text, i) != C_NL)
				i++;
		}
		else if (c == C_SLASH && c2 == C_STAR) {
			let e = index(substr(text, i + 2), '*/');
			if (e < 0)
				fail('comment /* has no end');
			let body = substr(text, i, e + 4);
			line += length(match(body, /\n/g) || []);
			i += e + 4;
		}
		else if (index('{}=(),', chr(c)) >= 0) {
			push(tokens, { t: chr(c), v: chr(c), start: i, end: i + 1, line: line });
			i++;
		}
		else if (c == 43 && c2 == 61) {
			push(tokens, { t: '+=', v: '+=', start: i, end: i + 2, line: line });
			i += 2;
		}
		else if (c == C_DOLLAR && c2 == C_LBRACE) {
			fail('environment variables (${...}) are not supported');
		}
		else if (c == C_DQ) {
			let v = '';
			let first = line;
			i++;
			while (true) {
				if (i >= n)
					fail('string has no end quote');
				let d = ord(text, i);
				if (d == C_DQ) {
					i++;
					break;
				}
				if (d == C_DOLLAR && i + 1 < n && ord(text, i + 1) == C_LBRACE)
					fail('environment variables (${...}) are not supported');
				if (d == C_NL)
					line++;
				if (d != C_BSL) {
					v += chr(d);
					i++;
					continue;
				}
				if (i + 1 >= n)
					fail('string has no end quote');
				let e = ord(text, i + 1);
				if (e == C_NL) {			// line continues
					line++;
					i += 2;
				}
				else if (e >= 48 && e <= 57) {
					// libconfuse: \[0-7]{1,3} is octal, a longer run of digits is an error
					let j = i + 1;
					while (j < n && ord(text, j) >= 48 && ord(text, j) <= 57)
						j++;
					let digits = substr(text, i + 1, j - i - 1);
					if (length(digits) > 3 || !match(digits, /^[0-7]+$/))
						fail('bad escape sequence \\' + digits);
					let val = 0;
					for (let k = 0; k < length(digits); k++)
						val = val * 8 + ord(digits, k) - 48;
					if (val > 255)
						fail('bad octal number \\' + digits);
					v += chr(val);
					i = j;
				}
				else if (e == 120 && i + 2 < n && hexval(ord(text, i + 2)) >= 0) {	// \x
					let val = hexval(ord(text, i + 2));
					i += 3;
					if (i < n && hexval(ord(text, i)) >= 0) {
						val = val * 16 + hexval(ord(text, i));
						i++;
					}
					v += chr(val);
				}
				else {
					let map = { n: '\n', r: '\r', b: '\b', f: '\f', a: '\x07', e: '\x1b', t: '\t', v: '\v' };
					v += map[chr(e)] ?? chr(e);
					i += 2;
				}
			}
			push(tokens, { t: 'str', v: v, start: start, end: i, line: first });
		}
		else if (c == C_SQ) {
			let v = '';
			let first = line;
			i++;
			while (true) {
				if (i >= n)
					fail('string has no end quote');
				let d = ord(text, i);
				if (d == C_SQ) {
					i++;
					break;
				}
				if (d == C_NL)
					line++;
				if (d == C_BSL && i + 1 < n) {
					let e = ord(text, i + 1);
					if (e == C_NL)
						line++;
					else if (e == C_BSL || e == C_SQ)
						v += chr(e);
					else
						v += chr(d) + chr(e);
					i += 2;
					continue;
				}
				v += chr(d);
				i++;
			}
			push(tokens, { t: 'str', v: v, start: start, end: i, line: first });
		}
		else if (!ends_unquoted(c)) {
			while (i < n && !ends_unquoted(ord(text, i)))
				i++;
			push(tokens, { t: 'str', v: substr(text, start, i - start), start: start, end: i, line: line });
		}
		else {
			fail(sprintf('unexpected character "%s"', chr(c)));
		}
	}
	return tokens;
}

// ---- Parser (as libconfuse cfg_parse_internal, with the telldus spec) ----

// strtol(value, &end, 0) as libconfuse uses it, but no spaces and no empty value
function parse_int(v) {
	let m = match(v, /^([+-]?)(0[xX][0-9a-fA-F]+|0[0-7]*|[1-9][0-9]*)$/);
	if (!m)
		return null;
	let digits = m[2];
	let n;
	if (match(digits, /^0[xX]/))
		n = hex(substr(digits, 2));
	else if (length(digits) > 1 && substr(digits, 0, 1) == '0') {
		n = 0;
		for (let k = 1; k < length(digits); k++)
			n = n * 8 + ord(digits, k) - 48;
	}
	else
		n = int(digits);
	if (type(n) != 'int' || n > 2147483647)
		return null;
	return (m[1] == '-') ? -n : n;
}

// text -> { globals: { user, group, devicenode, ignorecontrollerconfirmation },
//   devices: [ { id, name, controller, protocol, model, parameters, start, end } ],
//   controllers: [ { id, name, type, serial, start, end } ] }
// start and end are the byte offsets of the section in text.
// Calls die() with a message if libconfuse would not read the file, or if
// it cannot be parsed safely.
function parse(text) {
	let tokens = tokenize(text);
	let pos = 0;

	function fail(tok, msg) {
		die(tok ? sprintf('line %d: %s', tok.line, msg) : 'end of file: ' + msg);
	}

	function block(spec, obj, level) {
		while (true) {
			let tok = tokens[pos++];
			if (!tok) {
				if (level > 0)
					fail(null, 'section has no "}"');
				return null;
			}
			if (tok.t == '}') {
				if (level == 0)
					fail(tok, 'unexpected "}"');
				return tok;
			}
			if (tok.t != 'str')
				fail(tok, sprintf('unexpected "%s"', tok.v));
			let name = lc(tok.v);
			let kind = spec.opts[name];
			if (!kind)
				fail(tok, sprintf('unknown option "%s"', tok.v));

			if (type(kind) == 'object') {
				let open = tokens[pos++];
				if (!open || open.t != '{')
					fail(open, sprintf('"{" missing after "%s"', tok.v));
				let sub = kind.multi ? defaults(kind) : obj[name];
				let close = block(kind, sub, level + 1);
				if (kind.multi) {
					sub.start = tok.start;
					sub.end = close.end;
					push(obj[name], sub);
				}
				continue;
			}

			let eq = tokens[pos++];
			if (!eq || eq.t != '=')
				fail(eq || tok, sprintf('"=" missing after "%s"', tok.v));
			let val = tokens[pos++];
			if (!val || val.t != 'str')
				fail(val || eq, sprintf('value missing for "%s"', tok.v));
			if (kind == 'int') {
				let n = parse_int(val.v);
				if (n == null)
					fail(val, sprintf('"%s" is not a number', val.v));
				obj[name] = n;
			}
			else
				obj[name] = val.v;
		}
	}

	let top = defaults(SPEC_TOP);
	block(SPEC_TOP, top, 0);
	return {
		globals: {
			user: top.user, group: top.group, devicenode: top.devicenode,
			ignorecontrollerconfirmation: top.ignorecontrollerconfirmation
		},
		devices: top.device,
		controllers: top.controller
	};
}

// ---- Writer ----

// A libconfuse string in double quotes. "${" starts an environment variable
// in libconfuse: write "\$" for "$".
function quote(s) {
	let out = '"';
	for (let i = 0; i < length(s); i++) {
		let c = substr(s, i, 1);
		let o = ord(c);
		if (c == '"' || c == '\\' || c == '$')
			out += '\\' + c;
		else if (c == '\n')
			out += '\\n';
		else if (c == '\r')
			out += '\\r';
		else if (c == '\t')
			out += '\\t';
		else if (o < 32 || o == 127)
			out += sprintf('\\x%02x', o);
		else
			out += c;
	}
	return out + '"';
}

// A device section. controller only if not 0 (the telldus-core default).
// The parameters in the order of d.parameters.
function format_device(d) {
	let s = 'device {\n' +
		sprintf('  id = %d\n', d.id) +
		'  name = ' + quote(d.name) + '\n';
	if (d.controller)
		s += sprintf('  controller = %d\n', d.controller);
	s += '  protocol = ' + quote(d.protocol) + '\n' +
		'  model = ' + quote(d.model) + '\n' +
		'  parameters {\n';
	for (let p in keys(d.parameters))
		if (index(PARAMETERS, p) >= 0 && d.parameters[p] != null)
			s += '    ' + p + ' = ' + quote(d.parameters[p]) + '\n';
	return s + '  }\n}\n';
}

// Devices from UCI: a device that is in tellstick.conf (old, from parse())
// already keeps its name, its controller and the order of its parameters.
function keep_existing(devices, old) {
	let by_id = {};
	for (let o in old)
		by_id[o.id] = o;
	for (let d in devices) {
		let o = by_id[d.id];
		if (!o)
			continue;
		d.name = o.name;
		d.controller = o.controller;
		let params = {};
		for (let p in keys(o.parameters))
			if (d.parameters[p] != null)
				params[p] = d.parameters[p];
		for (let p in PARAMETERS)
			if (d.parameters[p] != null)
				params[p] = d.parameters[p];
		d.parameters = params;
	}
	return devices;
}

// The parts that telldusd uses, for a compare
function canonical(d) {
	let params = {};
	for (let p in PARAMETERS)
		if (d.parameters[p] != null)
			params[p] = d.parameters[p];
	return sprintf('%J', [ d.id, d.name, d.controller || 0, d.protocol, d.model, params ]);
}

function same_devices(a, b) {
	if (length(a) != length(b))
		return false;
	for (let i = 0; i < length(a); i++)
		if (canonical(a[i]) != canonical(b[i]))
			return false;
	return true;
}

function is_space(c) {
	return c == ' ' || c == '\t' || c == '\r';
}

function is_blank_line(text, pos) {
	let e = pos;
	while (e < length(text) && is_space(substr(text, e, 1)))
		e++;
	return (e < length(text) && substr(text, e, 1) == '\n') ? e + 1 : -1;
}

// Replace the device sections of text (parsed with parse()) by devices.
// Everything else stays as it is. The new sections go where the first old
// one was, or before the first controller section, or at the end.
// Blank lines: a removed section takes the blank lines after it with it.
// One blank line separates the new sections. One blank line follows the
// last new section if the last old section had one after it.
function replace_devices(text, parsed, devices) {
	let parts = [];
	for (let d in devices)
		push(parts, format_device(d));
	let block = join('\n', parts);
	let blank_after = false;

	let spans = [];
	for (let d in parsed.devices) {
		let s = d.start, e = d.end;
		// Remove the whole line if the section is alone on its lines
		let ls = s;
		while (ls > 0 && is_space(substr(text, ls - 1, 1)))
			ls--;
		let le = e;
		while (le < length(text) && is_space(substr(text, le, 1)))
			le++;
		if ((ls == 0 || substr(text, ls - 1, 1) == '\n') &&
		    (le == length(text) || substr(text, le, 1) == '\n')) {
			s = ls;
			e = (le < length(text)) ? le + 1 : le;
			blank_after = false;
			for (let b = is_blank_line(text, e); b >= 0; b = is_blank_line(text, e)) {
				e = b;
				blank_after = true;
			}
		}
		else
			blank_after = false;
		push(spans, [ s, e ]);
	}

	let at;
	if (length(spans))
		at = spans[0][0];
	else if (length(parsed.controllers)) {
		at = parsed.controllers[0].start;
		while (at > 0 && is_space(substr(text, at - 1, 1)))
			at--;
	}
	else
		at = length(text);

	if (block != '' && blank_after && spans[length(spans) - 1][1] < length(text))
		block += '\n';

	// A new section starts on a new line
	if (block != '' && at > 0 && substr(text, at - 1, 1) != '\n')
		block = '\n' + block;

	let out = '';
	let p = 0;
	let inserted = false;
	for (let sp in spans) {
		out += substr(text, p, sp[0] - p);
		if (!inserted) {
			out += block;
			inserted = true;
		}
		p = sp[1];
	}
	if (!inserted) {
		out += substr(text, p, at - p);
		out += block;
		p = at;
	}
	return out + substr(text, p);
}

// ---- UCI ----

function text(value) {
	return (type(value) == 'string') ? value : '';
}

// Sort UCI sections (from cursor.get_all()) by their order in the file
function ordered(sections) {
	let list = [];
	for (let name in sections)
		push(list, sections[name]);
	return sort(list, function(a, b) {
		return (a['.index'] || 0) - (b['.index'] || 0);
	});
}

// UCI sections -> { devices: [ tellstick.conf devices, sorted by id ],
// errors: [ ... ] }. A switch section with a protocol is a tellstick.conf
// device.
function devices_from_uci(sections) {
	let devices = [];
	let errors = [];
	let seen = {};

	for (let s in ordered(sections || {})) {
		if (s['.type'] != 'device' || s.type != 'switch' || s.protocol == null)
			continue;
		let what = 'device section ' + s['.name'];
		let bad = false;
		for (let o in [ 'id', 'name', 'protocol', 'model', ...PARAMETERS ])
			if (s[o] != null && type(s[o]) != 'string') {
				push(errors, sprintf('%s: %s must be an option, not a list', what, o));
				bad = true;
			}
		if (bad)
			continue;
		if (!match(text(s.id), /^[1-9][0-9]{0,8}$/)) {
			push(errors, sprintf('%s: id "%s" is not a number from 1 to 999999999', what, text(s.id)));
			continue;
		}
		if (s.protocol == '') {
			push(errors, what + ': protocol is empty');
			continue;
		}
		if (seen[s.id]) {
			push(errors, sprintf('%s: switch id %s is also in section %s', what, s.id, seen[s.id]));
			continue;
		}
		seen[s.id] = s['.name'];

		let d = {
			id: int(s.id),
			name: (text(s.name) != '') ? s.name : 'switch ' + s.id,
			controller: null,
			protocol: s.protocol,
			model: text(s.model),
			parameters: {}
		};
		for (let p in PARAMETERS)
			if (text(s[p]) != '')
				d.parameters[p] = s[p];
		push(devices, d);
	}

	devices = sort(devices, function(a, b) { return a.id - b.id; });
	return { devices: devices, errors: errors };
}

// ---- Files ----

// Write path atomically with this mode: a temporary file, then rename.
// Returns null, or an error message.
function write_file(path, content, mode, uid, gid) {
	let tmp = path + '.tmp';
	fs.unlink(tmp);
	let f = fs.open(tmp, 'w', mode);
	if (!f)
		return fs.error();
	let ok = f.write(content) != null;
	ok = f.close() && ok;
	ok = ok && fs.chmod(tmp, mode);
	if (ok && uid != null)
		ok = fs.chown(tmp, uid, gid);
	ok = ok && fs.rename(tmp, path);
	if (!ok) {
		let err = fs.error();
		fs.unlink(tmp);
		return err;
	}
	return null;
}

return {
	PARAMETERS: PARAMETERS,
	DEFAULT_HEADER: DEFAULT_HEADER,
	tokenize: tokenize,
	parse: parse,
	quote: quote,
	format_device: format_device,
	same_devices: same_devices,
	replace_devices: replace_devices,
	keep_existing: keep_existing,
	devices_from_uci: devices_from_uci,
	ordered: ordered,
	write_file: write_file
};
