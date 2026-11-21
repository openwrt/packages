// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.telegram: the Telegram bot, `trafficctl telegram` (package
// trafficctl-telegram). Long polling with getUpdates; answers only the chat
// configured in trafficctl.telegram.chat_id. It takes commands only: the new
// and known device messages come from trafficctl.notify.
//
//   import * as telegram from 'trafficctl.telegram';
//
//   run()                      the bot loop; returns 0 when telegram.enabled
//                              is not 1, 1 without a token or a chat
//   handle(update)             one element of getUpdates' result
//   device_keyboard(devices)   the /devices keyboard (two per row)
//   action_keyboard(ip, devs)  one device's actions
//   ceiling(down, up)          '8000 kbit/s' or '8000↓ / 2000↑ kbit/s'
//   ceiling_short(down, up)    '8000k' or '8000/2000k'
//   toast(text)                a callback answer within Telegram's 200 bytes
//
// The actions and the device list go through /usr/sbin/trafficctl, with
// TCTL_VIA=telegram, TCTL_SRC=telegram:<chat> and TCTL_USER=telegram-bot for
// the activity log. The state files keep the shell bot's names and formats:
// /tmp/trafficctl_tg_offset and the 5 s device cache
// /tmp/trafficctl_tg_devices.json.

import { stat } from 'fs';
import * as lib from 'trafficctl.lib';

const CLI = '/usr/sbin/trafficctl';
const OFFSET_FILE = '/tmp/trafficctl_tg_offset';
const CACHE_FILE = '/tmp/trafficctl_tg_devices.json';
const CACHE_TTL = 5;
const TAG = 'trafficctl-tg';
const RELOAD = 60;

// Limiter and shaper presets, kbit/s, in rows of three and four.
const PRESETS = [ [ [ '1M', 1000 ], [ '2M', 2000 ], [ '5M', 5000 ] ],
	[ [ '10M', 10000 ], [ '25M', 25000 ], [ '50M', 50000 ], [ '100M', 100000 ] ] ];

const IP_RE = /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/;

let cfg = {};

function logger(msg) {
	lib.sh('logger -t ' + lib.q(TAG) + ' ' + lib.q(msg));
}

function opt(o, d) {
	return lib.uci_get('trafficctl', 'telegram', o) ?? d;
}

const POLL_MAX = 25;
// One gc() per this many polls: the loop runs for months, and ucode only
// collects reference cycles when asked (as notify's watch() does).
const GC_EVERY = 20;

function load_config() {
	lib.reset();
	cfg = {
		enabled: opt('enabled', '0'),
		token: opt('bot_token', ''),
		chat: opt('chat_id', ''),
		// The long-poll timeout, kept under curl's 30 s (api()): a longer one
		// is cut off by curl on every quiet poll and logged as a failure.
		poll: min(lib.valid_int(opt('poll_interval', '3'), 2) ?? 3, POLL_MAX),
		control: opt('control_enabled', '1'),
		btn_inet: opt('btn_block_inet', '1'),
		btn_wifi: opt('btn_block_wifi', '1'),
		btn_limit: opt('btn_limiter', '1'),
		btn_shape: opt('btn_shaper', '1'),
	};
}

// ── Telegram API ────────────────────────────────────────────────────────────

function api(method, body) {
	return lib.pipe('curl -s -m 30 -X POST --config -',
		lib.curl_config('https://api.telegram.org/bot' + cfg.token + '/' + method,
			[ 'Content-Type: application/json' ], lib.to_json(body)));
}

function send(text, markup) {
	let b = { chat_id: cfg.chat, text, parse_mode: 'HTML' };
	if (markup)
		b.reply_markup = markup;
	api('sendMessage', b);
}

// Telegram refuses a whole answerCallbackQuery whose text is over 200
// bytes, so a long backend message would vanish rather than be cut. The cut
// backs off to a character boundary: half a UTF-8 sequence is refused too.
function toast(text) {
	if (length(text) <= 200)
		return text;
	let n = 196;
	while (n > 0 && (ord(text, n) & 0xc0) == 0x80)
		n--;
	return substr(text, 0, n) + '...';
}

function answer(id, text) {
	api('answerCallbackQuery', { callback_query_id: id, text: toast(text) });
}

function edit(msg_id, text, markup) {
	let b = { chat_id: cfg.chat, message_id: msg_id, text, parse_mode: 'HTML' };
	if (markup)
		b.reply_markup = markup;
	api('editMessageText', b);
}

// ── devices ─────────────────────────────────────────────────────────────────

// The CLI with the caller variables the activity log records.
function cli(argv) {
	return lib.run('TCTL_VIA=telegram TCTL_SRC=' + lib.q('telegram:' + cfg.chat) + ' TCTL_USER=telegram-bot ' +
		lib.qv([ lib.path(CLI), ...argv ]));
}

function parse(s) {
	let v = null;
	try {
		v = json(s);
	}
	catch (e) {
		v = null;
	}
	return v;
}

// The summary, at most CACHE_TTL seconds old.
function devices() {
	let st = stat(lib.path(CACHE_FILE)), out;
	if (st?.type == 'file' && time() - st.mtime < CACHE_TTL)
		out = lib.readfile(CACHE_FILE) ?? '';
	else {
		out = cli([ 'summary' ]);
		lib.write_atomic(CACHE_FILE, out);
	}
	let d = parse(out);
	return (type(d) == 'array') ? d : [];
}

function invalidate() {
	lib.remove(CACHE_FILE);
}

// A JSON value as jsonfilter prints it.
function fv(v) {
	switch (type(v)) {
	case 'string':
		return v;
	case 'int':
	case 'double':
		return '' + v;
	case 'bool':
		return v ? 'true' : 'false';
	case null:
		return '';
	}
	return lib.to_json(v);
}

function device(devs, ip) {
	for (let d in devs)
		if (type(d) == 'object' && fv(d.ip) == ip)
			return d;
	return {};
}

function ips(devs) {
	return filter(map(devs, (d) => (type(d) == 'object') ? fv(d.ip) : ''), (ip) => ip != '');
}

function on(v) {
	v = fv(v);
	return v == 'true' || v == '1';
}

function positive(v) {
	v = fv(v);
	return !!match(v, /^[0-9]+$/) && int(v) > 0;
}

function ceiling(down, up) {
	return (positive(up) && fv(up) != fv(down)) ? sprintf('%s↓ / %s↑ kbit/s', fv(down), fv(up))
		: fv(down) + ' kbit/s';
}

function ceiling_short(down, up) {
	return (positive(up) && fv(up) != fv(down)) ? sprintf('%s/%sk', fv(down), fv(up)) : fv(down) + 'k';
}

const HTML_ESC = { '&': '&amp;', '<': '&lt;', '>': '&gt;' };

// A name for parse_mode HTML: a '<' in it made Telegram refuse the message.
function name_of(d) {
	let n = fv(d.name);
	if (!lib.plain(n))
		n = '';
	return (n != '') ? replace(n, /[&<>]/g, (c) => HTML_ESC[c]) : '?';
}

// ── keyboards ───────────────────────────────────────────────────────────────

function button(text, data) {
	return { text, callback_data: data };
}

function device_keyboard(devs) {
	let rows = [];
	for (let ip in ips(devs)) {
		// ASCII only, so the 12-byte cut cannot split a character.
		let name = fv(device(devs, ip).name);
		name = lib.plain(name) ? replace(name, /[^a-zA-Z0-9 _.()-]/g, '') : '';
		let b = button(substr((name != '') ? name : ip, 0, 12) + ' ' + ip, 'act:menu:' + ip);
		if (length(rows) && length(rows[-1]) == 1)
			push(rows[-1], b);
		else
			push(rows, [ b ]);
	}
	return { inline_keyboard: rows };
}

function preset_rows(sym, verb, ip) {
	return map(PRESETS, (row) => map(row, (p) => button(sym + ' ' + p[0], 'act:' + verb + ':' + ip + ':' + p[1])));
}

function action_keyboard(ip, devs) {
	let d = device(devs, ip), rows = [];
	if (cfg.btn_inet == '1')
		push(rows, on(d.blocked) ? [ button('▶️ Unblock Internet', 'act:unblock:' + ip) ]
			: [ button('⏸ Block Internet', 'act:block:' + ip) ]);
	if (cfg.btn_wifi == '1' && match(fv(d.conn_type), /wifi|2\.4G|5G|6G|WiFi/))
		push(rows, on(d.wifi_blocked) ? [ button('📶 Unblock WiFi', 'act:wunblock:' + ip) ]
			: [ button('📵 Block WiFi', 'act:wblock:' + ip) ]);
	if (cfg.btn_limit == '1') {
		if (positive(d.rate_limit_kbit))
			push(rows, [ button('⚡ Limit: ' + ceiling(d.rate_limit_kbit, d.rate_limit_kbit_up) + ' — Remove',
				'act:unlimit:' + ip) ]);
		else
			push(rows, ...preset_rows('⚡', 'limit', ip));
	}
	if (cfg.btn_shape == '1') {
		if (positive(d.shape_kbit))
			push(rows, [ button('🔧 Shape: ' + ceiling(d.shape_kbit, d.shape_kbit_up) + ' — Remove',
				'act:unshape:' + ip) ]);
		else
			push(rows, ...preset_rows('🔧', 'shape', ip));
	}
	push(rows, [ button('⬅️ Back', 'act:back') ]);
	return { inline_keyboard: rows };
}

// ── commands ────────────────────────────────────────────────────────────────

function cmd_help() {
	if (cfg.control == '1')
		send('<b>TrafficCtl Bot</b>\n\n/devices — active devices with action buttons\n' +
			'/status — blocked/limited summary\n/help — this message');
	else
		send('<b>TrafficCtl Bot</b> (notifications only)\n\n/devices — active devices list\n' +
			'/status — blocked/limited summary\n/help — this message\n\n' +
			'<i>Control disabled — enable in LuCI settings</i>');
}

function cmd_devices() {
	let devs = devices();
	if (!length(devs)) {
		send('No active devices');
		return;
	}
	let list = ips(devs);
	if (cfg.control == '1') {
		send(sprintf('<b>Active devices: %d</b>\nSelect a device:', length(list)), device_keyboard(devs));
		return;
	}
	let t = sprintf('<b>Active devices: %d</b>\n', length(list));
	for (let ip in list)
		t += '• ' + name_of(device(devs, ip)) + ' (' + ip + ')\n';
	send(rtrim(t, '\n'));
}

function devices_edit(msg_id) {
	invalidate();
	let devs = devices();
	edit(msg_id, sprintf('<b>Active devices: %d</b>\nSelect a device:', length(ips(devs))), device_keyboard(devs));
}

function cmd_status() {
	let devs = devices();
	if (!length(devs)) {
		send('No active devices');
		return;
	}
	let r = '';
	for (let ip in ips(devs)) {
		let d = device(devs, ip), f = '';
		if (on(d.blocked))
			f += ' 🚫inet';
		if (on(d.wifi_blocked))
			f += ' 📵wifi';
		if (positive(d.rate_limit_kbit))
			f += ' ⚡' + ceiling_short(d.rate_limit_kbit, d.rate_limit_kbit_up);
		if (positive(d.shape_kbit))
			f += ' 🔧' + ceiling_short(d.shape_kbit, d.shape_kbit_up);
		if (f != '')
			r += name_of(d) + ' (' + ip + '):' + f + '\n';
	}
	if (r == '')
		send('All devices are clean — no blocks or limits');
	else
		send(rtrim('<b>Active restrictions:</b>\n' + r, '\n'));
}

// ── callbacks ───────────────────────────────────────────────────────────────

// `cut -d: -f<n>`: a value without a colon is every field.
function cutf(parts, n) {
	return (length(parts) == 1) ? parts[0] : (parts[n - 1] ?? '');
}

// What each action runs (after `trafficctl`): the shell bot's arguments.
const ACTIONS = {
	block: (ip, p) => [ 'block', ip, 'tg' ],
	unblock: (ip, p) => [ 'unblock', ip, 'tg' ],
	wblock: (ip, p) => [ 'macfilter-add', ip ],
	wunblock: (ip, p) => [ 'macfilter-remove', ip ],
	limit: (ip, p) => [ 'ratelimit', ip, p, 'tg' ],
	unlimit: (ip, p) => [ 'ratelimit', ip, '0', 'tg' ],
	shape: (ip, p) => [ 'shape', 'add', ip, p, 'tg' ],
	unshape: (ip, p) => [ 'shape', 'remove', ip ],
};

function menu(cb_id, ip, msg_id) {
	invalidate();
	let devs = devices(), d = device(devs, ip), st = '';
	if (on(d.blocked))
		st += '🚫 Internet blocked\n';
	if (on(d.wifi_blocked))
		st += '📵 WiFi blocked\n';
	if (positive(d.rate_limit_kbit))
		st += '⚡ Limiter: ' + ceiling(d.rate_limit_kbit, d.rate_limit_kbit_up) + '\n';
	if (positive(d.shape_kbit))
		st += '🔧 Shaper: ' + ceiling(d.shape_kbit, d.shape_kbit_up) + '\n';
	if (st == '')
		st = '✅ No restrictions\n';
	edit(msg_id, rtrim('<b>' + name_of(d) + '</b> (' + ip + ')\n' + st, '\n'), action_keyboard(ip, devs));
	answer(cb_id, '');
}

function callback(cb_id, data, msg_id) {
	if (cfg.control != '1') {
		answer(cb_id, 'Control disabled');
		return;
	}
	// Telegram hands back what our buttons carry; anything else is refused
	// before it is taken apart.
	if (!lib.plain(data) || match(data, /[\x01-\x1f\x7f]/)) {
		answer(cb_id, 'invalid IP');
		return;
	}
	let parts = split(data, ':');
	let verb = cutf(parts, 2), ip = cutf(parts, 3), param = cutf(parts, 4);
	if (ip != '' && verb != 'back' && !match(ip, IP_RE)) {
		answer(cb_id, 'invalid IP');
		return;
	}
	if (param != '' && match(param, /[^0-9]/)) {
		answer(cb_id, 'invalid param');
		return;
	}
	if (verb == 'menu') {
		menu(cb_id, ip, msg_id);
		return;
	}
	if (verb == 'back') {
		devices_edit(msg_id);
		answer(cb_id, '');
		return;
	}
	if (!exists(ACTIONS, verb)) {
		answer(cb_id, 'Unknown action');
		return;
	}
	let r = parse(cli(ACTIONS[verb](ip, param)));
	let msg = (type(r) == 'object') ? fv(r.msg) : '';
	answer(cb_id, (msg != '') ? msg : 'done');
	invalidate();
	callback(cb_id, 'act:menu:' + ip, msg_id);
}

// ── updates ─────────────────────────────────────────────────────────────────

function handle(u) {
	if (type(u) != 'object')
		return;
	let m = u.message;
	if (type(m) == 'object' && m.chat?.id != null) {
		if (fv(m.chat.id) != cfg.chat)
			return;
		let t = fv(m.text);
		if (substr(t, 0, 6) == '/start' || substr(t, 0, 5) == '/help')
			cmd_help();
		else if (substr(t, 0, 8) == '/devices')
			cmd_devices();
		else if (substr(t, 0, 7) == '/status')
			cmd_status();
		return;
	}
	let c = u.callback_query;
	if (type(c) != 'object' || c.id == null)
		return;
	if (fv(c.message?.chat?.id) == cfg.chat)
		callback(fv(c.id), fv(c.data), c.message?.message_id);
}

function read_offset() {
	return lib.valid_int(trim(lib.readfile(OFFSET_FILE) ?? ''), 0) ?? 0;
}

function run() {
	load_config();
	if (cfg.enabled != '1') {
		logger('Telegram bot disabled');
		return 0;
	}
	if (cfg.token == '' || cfg.chat == '') {
		logger('Missing bot_token or chat_id');
		return 1;
	}
	logger('Bot started, chat_id=' + cfg.chat);
	let offset = read_offset(), reload_at = time() + RELOAD, polls = 0, up = true;
	while (true) {
		if (++polls % GC_EVERY == 0)
			gc();
		let r = parse(api('getUpdates', { offset, timeout: cfg.poll,
			allowed_updates: [ 'message', 'callback_query' ] }));
		if (type(r) != 'object' || r.ok !== true || type(r.result) != 'array') {
			// Once per outage, not once per retry every 5 s.
			if (up)
				logger('getUpdates failed' + ((type(r) == 'object' && r.error_code != null)
					? ' (' + r.error_code + ')' : ': no answer from api.telegram.org') + ', retrying every 5 s');
			up = false;
			sleep(5000);
			continue;
		}
		if (!up)
			logger('getUpdates works again');
		up = true;
		// The shell bot stopped at the first empty element; so does this.
		for (let u in r.result) {
			if (u == null)
				break;
			if (type(u) == 'object' && lib.valid_int(u.update_id, 0) != null)
				offset = u.update_id + 1;
			lib.write_atomic(OFFSET_FILE, offset + '\n');
			handle(u);
		}
		if (time() >= reload_at) {
			load_config();
			reload_at = time() + RELOAD;
		}
	}
}

export { run, handle, device_keyboard, action_keyboard, ceiling, ceiling_short, toast };
