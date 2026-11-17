// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.notify: events, and the senders that deliver them.
//
//   import * as notify from 'trafficctl.notify';
//
// An event is one of EVENTS with flat fields from FIELDS. emit(ev, fields)
//   1. sends it on ubus as `trafficctl.notify` { event, time, ...fields }
//      (`ubus listen trafficctl.notify` shows them),
//   2. runs /etc/hotplug.d/trafficctl/* through hotplug-call, ACTION=<event>,
//      TIME and each field upper-cased in the environment,
//   3. hands it to every enabled sender subscribed to it.
// Steps 2 and 3 run in a detached `trafficctl notify dispatch`, so a caller
// never waits on the network; with sync, or TCTL_NOTIFY_SYNC=1, inline.
//
// Senders are uci sections of type notify_telegram, notify_ntfy,
// notify_webhook and notify_mail, each with `enabled` and `list events`
// (unset: every event). Before `notify migrate` has run, the Telegram bot's
// own options (telegram.enabled, notify_new_device, notify_known_device,
// notify_template) stand in for a notify_telegram section.
//
// The device scan behind new_device and known_device keeps the bot's state
// files and their formats: /etc/trafficctl/telegram_known.json, its lock
// /tmp/.trafficctl_known.lock, and /tmp/trafficctl_tg_online.
//
//   emit(ev, fields, sync)   { ok, msg }
//   emit_action(ev, fields)  emit() with via/src from TCTL_VIA/TCTL_SRC; never throws
//   dispatch(ev, fields, t)  hotplug + senders now: [ { sender, type, ok, msg } ]
//   scan()                   one pass: { new, online, devices }
//   watch()                  scan every notify.scan_interval seconds, forever
//   scan_wanted()            whether anything listens for the scan's events
//   dhcp(mac, ip, name)      a DHCP lease for mac: new_device if unknown
//   migrate()                the bot's notification options to notify_telegram
//   senders()                [ { type, name, s, legacy } ], s the options
//   test(name)               a test message through one sender: { ok, msg }
//   config_get()             the Notifications tab: globals and senders, secrets masked
//   config_set(a)            write one sender (a.sender) or the globals; caller commits
//   telegram_test(args)      the `telegram-test` command: { ok, msg }

import { lsdir } from 'fs';
import * as lib from 'trafficctl.lib';

const EVENTS = [ 'new_device', 'known_device', 'limit_applied', 'block_applied', 'cut_engaged' ];
const FIELDS = [ 'mac', 'ip', 'name', 'link', 'rate_kbit', 'rate_kbit_up', 'mode', 'kind',
	'duration', 'persist', 'via', 'src' ];
const INT_FIELDS = { rate_kbit: true, rate_kbit_up: true, duration: true };
const TYPES = [ 'telegram', 'ntfy', 'webhook', 'mail' ];

const CLI = '/usr/sbin/trafficctl';
const HOTPLUG_CALL = '/sbin/hotplug-call';
const HOTPLUG_DIR = '/etc/hotplug.d/trafficctl';
const MSMTP = '/usr/bin/msmtp';
const LEASES = '/tmp/dhcp.leases';
const CONNTRACK = '/proc/net/nf_conntrack';
const KNOWN = '/etc/trafficctl/telegram_known.json';
const KNOWN_LOCK = '/tmp/.trafficctl_known.lock';
// 10 s, then a holder older than 30 s is taken over.
const KNOWN_LOCK_TRIES = 100;
const KNOWN_LOCK_STALE = 30;
const ONLINE = '/tmp/trafficctl_tg_online';
const TAG = 'trafficctl-notify';

function now() {
	return lib.valid_int(getenv('TCTL_NOW') ?? '', 0) ?? time();
}

function logger(msg) {
	lib.sh('logger -t ' + lib.q(TAG) + ' ' + lib.q(msg));
}

function valid_event(e) {
	return lib.plain(e) && index(EVENTS, e) >= 0;
}

// ── fields ──────────────────────────────────────────────────────────────────

// One line of printable text: every field ends up in an environment
// variable, a header or a message.
function one_line(v) {
	return lib.plain(v) && length(v) <= 256 && !match(v, /[\x01-\x1f\x7f]/);
}

function clean(fields) {
	let out = {};
	if (type(fields) != 'object')
		return out;
	for (let k in FIELDS) {
		let v = fields[k];
		// ===: 0 == '' in ucode, and a 0 duration is a value.
		if (v == null || v === '')
			continue;
		if (exists(INT_FIELDS, k)) {
			v = lib.valid_int(v, 0);
			if (v != null)
				out[k] = v;
		}
		else if (k == 'persist')
			out[k] = (v === true || v == '1' || v == 'true');
		else if (type(v) == 'int' || one_line(v))
			out[k] = '' + v;
	}
	return out;
}

// k=v arguments of the CLI.
function parse_kv(args) {
	let f = {};
	for (let a in args) {
		let i = lib.plain(a) ? index(a, '=') : -1;
		if (i > 0)
			f[substr(a, 0, i)] = substr(a, i + 1);
	}
	return f;
}

function to_kv(f) {
	return map(keys(f), (k) => k + '=' + ((type(f[k]) == 'bool') ? (f[k] ? '1' : '0') : '' + f[k]));
}

function payload(ev, t, f) {
	let p = { event: ev, time: t };
	for (let k in keys(f))
		p[k] = f[k];
	return p;
}

// ── config ──────────────────────────────────────────────────────────────────

function uget(sect, opt) {
	return lib.uci_get('trafficctl', sect, opt);
}

function master_on() {
	return uget('notify', 'enabled') != '0';
}

function legacy_telegram() {
	let ev = [];
	if (uget('telegram', 'notify_new_device') != '0')
		push(ev, 'new_device');
	if (uget('telegram', 'notify_known_device') == '1')
		push(ev, 'known_device');
	return { type: 'telegram', name: 'telegram', legacy: true,
		s: { enabled: (uget('telegram', 'enabled') == '1') ? '1' : '0', events: ev,
			template: uget('telegram', 'notify_template') ?? '' } };
}

function senders() {
	let out = [];
	for (let t in TYPES)
		lib.uci_foreach('trafficctl', 'notify_' + t, (s) => {
			push(out, { type: t, name: s['.name'], s, legacy: false });
		});
	if (!length(filter(out, (x) => x.type == 'telegram')) && lib.cursor().get('trafficctl', 'telegram') != null)
		push(out, legacy_telegram());
	return out;
}

function events_of(s) {
	let e = s.events;
	if (e == null)
		return EVENTS;
	if (type(e) == 'string')
		e = split(e, /[ \t]+/);
	return filter(e, valid_event);
}

function enabled(s) {
	return (s.enabled ?? '1') == '1';
}

// A Telegram sender without a token or a chat has nowhere to send: the
// shipped config enables one, and it must not start the scan on a router
// whose bot was never set up.
function configured(x) {
	if (x.type != 'telegram')
		return true;
	return (x.s.bot_token || uget('telegram', 'bot_token') || '') != '' &&
		(x.s.chat_id || uget('telegram', 'chat_id') || '') != '';
}

function subscribers(ev) {
	if (!master_on())
		return [];
	return filter(senders(), (x) => enabled(x.s) && configured(x) && index(events_of(x.s), ev) >= 0);
}

function hotplug_scripts() {
	return length(filter(lsdir(lib.path(HOTPLUG_DIR)) ?? [], (e) => substr(e, 0, 1) != '.'));
}

function scan_interval() {
	return lib.valid_int(uget('notify', 'scan_interval') ?? '30', 0, 86400) ?? 30;
}

// The scan costs ip, iw and a station query per device: only when something
// takes new_device or known_device.
function scan_wanted() {
	if (scan_interval() == 0)
		return false;
	let mode = uget('notify', 'scan') ?? 'auto';
	if (mode == '0')
		return false;
	if (mode == '1')
		return true;
	return hotplug_scripts() > 0 || length(subscribers('new_device')) > 0 ||
		length(subscribers('known_device')) > 0;
}

// ── router facts ────────────────────────────────────────────────────────────

function first_option(conf, stype, opt) {
	let v = null;
	lib.uci_foreach(conf, stype, (s) => {
		v = s[opt];
		return false;
	});
	return (type(v) == 'array') ? join(' ', v) : v;
}

function router_name() {
	return first_option('system', 'system', 'hostname') ?? rtrim(lib.readfile('/proc/sys/kernel/hostname') ?? '', '\n');
}

function wan_ip() {
	return lib.ubus_call('network.interface.wan', 'status')?.['ipv4-address']?.[0]?.address ?? '';
}

function uptime_secs() {
	return lib.valid_int(split(split(lib.readfile('/proc/uptime') ?? '', ' ')[0], '.')[0], 0);
}

function load1() {
	let t = lib.readfile('/proc/loadavg');
	return (t == null) ? null : split(t, ' ')[0];
}

function wifi_ifaces() {
	return map(filter(lib.lines('iw dev'), (l) => !!match(l, /Interface/)), (l) => lib.field(l, 1));
}

// ── device discovery (trafficctl-telegram.sh, unchanged) ────────────────────

const MAC_RE = /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/;

function discover() {
	let macs = [];
	for (let l in lib.lines('ip neigh show'))
		if (index(l, 'lladdr') >= 0)
			push(macs, lc(lib.field(l, 4)));
	for (let l in lib.file_lines(LEASES))
		push(macs, lc(lib.field(l, 1)));
	for (let i in wifi_ifaces())
		for (let l in lib.lines('iw dev ' + lib.q(i) + ' station dump'))
			if (index(l, 'Station') >= 0)
				push(macs, lc(lib.field(l, 1)));
	return filter(sort(uniq(filter(macs, lib.plain))), (m) => !!match(m, MAC_RE));
}

function lease_of(mac) {
	for (let l in lib.file_lines(LEASES))
		if (lc(lib.field(l, 1)) == mac)
			return { ip: lib.field(l, 2), name: lib.field(l, 3) };
	return null;
}

function resolve(mac) {
	let lease = lease_of(mac), ip = lease?.ip ?? '', name = lease?.name ?? '', link = '?';
	if (ip == '')
		for (let l in lib.lines('ip neigh show'))
			if (lc(lib.field(l, 4)) == mac) {
				ip = lib.field(l, 0);
				break;
			}
	for (let i in wifi_ifaces())
		if (lib.sh('iw dev ' + lib.q(i) + ' station get ' + lib.q(mac)) == 0) {
			link = 'wifi';
			break;
		}
	if (link == '?' && ip != '')
		link = 'ethernet';
	if (name == '' || name == '*')
		name = 'unknown';
	return { name, ip: (ip == '') ? '?' : ip, link };
}

// ── known-device ledger ─────────────────────────────────────────────────────

function is_known(mac) {
	return index(lib.readfile(KNOWN) ?? '', '"' + mac + '"') >= 0;
}

function empty_ledger(t) {
	return t == null || trim(t) == '' || rtrim(t, '\n') == '[]';
}

// add_known_mac: a first entry replaces the '[]' (no newline after it), every
// later one goes before the closing bracket of each line ending in one.
// True only for the caller that added the MAC: the check is repeated under
// the lock, because the DHCP hook (`notify dhcp`) and the scan race for the
// same new device and only one of them may announce it. Without the lock
// nothing is written: a lost entry is announced again at the next sighting,
// a clobbered file loses every entry another writer added meanwhile.
function add_known(mac, name, ip) {
	mac = replace(mac, /[^a-fA-F0-9:]/g, '');
	name = replace(name, /[^a-zA-Z0-9 _.-]/g, '');
	ip = replace(ip, /[^0-9.]/g, '');
	let e = sprintf('{"mac":"%s","name":"%s","ip":"%s","first_seen":%d}', mac, name, ip, now());
	let ok = lib.with_lock(KNOWN_LOCK, KNOWN_LOCK_TRIES, KNOWN_LOCK_STALE, () => {
		if (is_known(mac))
			return false;
		let t = lib.readfile(KNOWN), data;
		if (empty_ledger(t))
			data = '[' + e + ']';
		else {
			let l = split(t, '\n');
			if (l[-1] == '')
				pop(l);
			data = join('\n', map(l, (x) => replace(x, /\]$/, () => ',' + e + ']'))) + '\n';
		}
		lib.mkdir_p('/etc/trafficctl');
		return !!lib.write_atomic(KNOWN, data);
	}, true);
	if (ok == null) {
		logger('Known-device ledger busy, ' + mac + ' not recorded');
		return false;
	}
	return ok;
}

function seed() {
	for (let mac in discover()) {
		let i = resolve(mac);
		add_known(mac, i.name, i.ip);
	}
	logger('Seeded known devices from current state');
}

// load_known: a missing or empty ledger is seeded from what is on the network
// now, so switching notifications on does not report the whole LAN as new.
function load_known() {
	let t = lib.readfile(KNOWN);
	if (!empty_ledger(t))
		return false;
	lib.mkdir_p('/etc/trafficctl');
	// Under the lock add_known takes, and asked again there: the DHCP hook
	// may have recorded a device since the read above, and '[]' renamed over
	// it would drop that entry and announce the device a second time.
	if (t == null || trim(t) == '')
		lib.with_lock(KNOWN_LOCK, KNOWN_LOCK_TRIES, KNOWN_LOCK_STALE, () => {
			let cur = lib.readfile(KNOWN);
			if (cur == null || trim(cur) == '')
				lib.write_atomic(KNOWN, '[]\n');
		}, true);
	seed();
	return true;
}

// ── messages ────────────────────────────────────────────────────────────────

const HTML_ESC = { '&': '&amp;', '<': '&lt;', '>': '&gt;' };

function esc(s) {
	return replace('' + s, /[&<>]/g, (c) => HTML_ESC[c]);
}

function strip_html(h) {
	h = replace(h, /<[^>]*>/g, '');
	h = replace(h, /&lt;/g, '<');
	h = replace(h, /&gt;/g, '>');
	return replace(h, /&amp;/g, '&');
}

function who(f) {
	let ip = f.ip ?? '';
	if (f.name != null && f.name != '' && f.name != ip)
		return f.name + ' (' + ((ip != '') ? ip : '?') + ')';
	return (ip != '') ? ip : (f.mac ?? '?');
}

// tg_ceiling: an upload figure of 0 or equal to download is not a split.
function ceiling(d, u) {
	return (u > 0 && u != d) ? sprintf('%d↓ / %d↑ kbit/s', d, u) : sprintf('%d kbit/s', d);
}

function span(sec) {
	if (sec % 3600 == 0)
		return sprintf('%d h', int(sec / 3600));
	if (sec % 60 == 0)
		return sprintf('%d min', int(sec / 60));
	return sprintf('%d s', sec);
}

function via_line(f) {
	return (f.via != null) ? '\nVia: ' + esc(f.via) : '';
}

// {{ var }} with blanks of class ws around the name, every occurrence.
function fill(tpl, vars, ws) {
	for (let k in keys(vars)) {
		let v = '' + vars[k];
		tpl = replace(tpl, regexp('\\{\\{' + ws + k + ws + '\\}\\}', 'g'), () => v);
	}
	return tpl;
}

function uptime_text(s) {
	let d = int(s / 86400), h = int((s % 86400) / 3600), m = int((s % 3600) / 60);
	if (d > 0)
		return sprintf('%dd %dh', d, h);
	return (h > 0) ? sprintf('%dh %dm', h, m) : sprintf('%dm', m);
}

function wifi_info(mac) {
	let r = { iface: '', ssid: '', signal: '', freq: '' }, out = '';
	for (let c in wifi_ifaces()) {
		out = lib.run('iw dev ' + lib.q(c) + ' station get ' + lib.q(mac));
		if (rtrim(out, '\n') != '') {
			r.iface = c;
			break;
		}
	}
	if (r.iface == '')
		return r;
	for (let l in split(out, '\n'))
		if (index(l, 'signal:') >= 0) {
			r.signal = lib.field(l, 1);
			break;
		}
	let info = lib.lines('iw dev ' + lib.q(r.iface) + ' info');
	for (let l in info) {
		if (index(l, 'channel') < 0)
			continue;
		let p = split(ltrim(l, ' \t'), /[ \t]+/), f = 0;
		for (let i = 1; i < length(p); i++) {
			let v = replace(p[i], /[^0-9]/g, '');
			let n = (v == '') ? 0 : int(v);
			if (n >= 2400 && n <= 7200) {
				f = n;
				break;
			}
		}
		r.freq = (f >= 5925) ? '6GHz' : (f >= 5000) ? '5GHz' : (f > 0) ? '2.4GHz' : '';
		break;
	}
	for (let l in info)
		if (index(l, 'ssid') >= 0) {
			r.ssid = lib.field(l, 1);
			break;
		}
	return r;
}

function conns(ip) {
	let n = 0, needle = 'src=' + ip + ' ';
	lib.each_line(CONNTRACK, (l) => {
		if (index(l, needle) >= 0)
			n++;
	});
	return n;
}

function count_lines(p) {
	let t = lib.readfile(p);
	return (t == null) ? 0 : length(split(t, '\n')) - 1;
}

// format_new_device_msg with a template: the bot's variables.
function device_template(tpl, f) {
	let t = localtime(now()), w = wifi_info(f.mac ?? '');
	let date = sprintf('%04d-%02d-%02d', t.year, t.mon, t.mday), hm = sprintf('%02d:%02d', t.hour, t.min);
	let vars = {
		name: f.name ?? 'unknown', ip: f.ip ?? '?', mac: f.mac ?? '', link: f.link ?? '?',
		date, time: hm, datetime: date + ' ' + hm, router: router_name(), ssid: w.ssid,
		signal: w.signal, freq: w.freq, iface: w.iface, clients: count_lines(LEASES),
		uptime: uptime_text(uptime_secs() ?? 0), wan_ip: wan_ip(), load: load1() ?? '',
		conns: conns(f.ip ?? '?'),
	};
	for (let k in [ 'name', 'ip', 'mac', 'link', 'router', 'ssid', 'iface' ])
		vars[k] = esc(vars[k]);
	return rtrim(replace(fill(tpl, vars, '[ \t]*'), /\\n/g, '\n'), '\n');
}

function html(ev, f, template) {
	let name = esc(f.name ?? 'unknown'), ip = esc(f.ip ?? '?'), link = esc(f.link ?? '?');
	switch (ev) {
	case 'new_device':
		if (template != null && template != '')
			return device_template(template, f);
		return sprintf('🆕 <b>New device</b>\n%s (%s)\nMAC: <code>%s</code>\nLink: %s', name, ip, esc(f.mac ?? ''), link);
	case 'known_device':
		return sprintf('📱 <b>Device online</b>\n%s (%s)\nLink: %s', name, ip, link);
	case 'block_applied':
		if (f.kind == 'wifi')
			return '📵 <b>WiFi blocked</b>\n' + esc(who(f)) +
				((f.mac != null) ? '\nMAC: <code>' + esc(f.mac) + '</code>' : '') + via_line(f);
		return '🚫 <b>Internet blocked</b>\n' + esc(who(f)) + via_line(f);
	case 'limit_applied':
		return '⚡ <b>Limit applied</b>\n' + esc(who(f)) + '\n' + ceiling(f.rate_kbit ?? 0, f.rate_kbit_up ?? 0) +
			((f.mode != null) ? ' (' + esc(f.mode) + ')' : '') + via_line(f);
	case 'cut_engaged':
		return '⛔ <b>Internet cut</b>\nAll devices, ' + (((f.duration ?? 0) > 0) ? 'for ' + span(f.duration) : 'until released') +
			(f.persist ? ', kept after reboot' : '') + via_line(f);
	}
	return esc(ev);
}

const TITLES = { new_device: 'New device', known_device: 'Device online', block_applied: 'Internet blocked',
	limit_applied: 'Limit applied', cut_engaged: 'Internet cut', test: 'Test' };

function message(ev, f, t, template) {
	let h = html(ev, f, template), title = TITLES[ev] ?? ev;
	if (ev == 'block_applied' && f.kind == 'wifi')
		title = 'WiFi blocked';
	let r = router_name();
	return { ev, f, time: t, html: h, text: strip_html(h), title: (r != '') ? r + ': ' + title : title, router: r };
}

// ── transports ──────────────────────────────────────────────────────────────
// Everything goes to curl as a config file on stdin (lib.curl_config): the
// URL may hold a token, and an argument list is readable by every local user.

// A header value or a URL: one line, nothing curl's config would take apart.
function header_ok(v) {
	return lib.plain(v) && v != '' && !match(v, /[\x01-\x1f\x7f]/);
}

function url_ok(u) {
	return header_ok(u) && !!match(u, /^https?:\/\/[^ "\\]+$/);
}

function http_status(code) {
	let n = lib.valid_int(trim(code), 0, 999);
	return (n != null && n >= 200 && n < 300) ? null : 'HTTP ' + ((n != null && n > 0) ? n : 'request failed');
}

function post_status(url, headers, body) {
	return http_status(lib.pipe("curl -s -m 10 -X POST -o /dev/null -w '%{http_code}' --config -",
		lib.curl_config(url, headers, body)));
}

const TG_TOKEN_RE = /^[0-9]+:[A-Za-z0-9_-]+$/;
const TG_CHAT_RE = /^-?[0-9]+$/;

// sendMessage: null when Telegram took it, else the reason.
function tg_send(token, chat, text) {
	let out = lib.pipe('curl -s -m 10 -X POST --config -',
		lib.curl_config('https://api.telegram.org/bot' + token + '/sendMessage', [ 'Content-Type: application/json' ],
			'{"chat_id":' + lib.to_json(chat) + ',"text":' + lib.to_json(text) + ',"parse_mode":"HTML"}'));
	let r = null;
	try {
		r = json(out);
	}
	catch (e) {
		r = null;
	}
	if (type(r) == 'object' && r.ok === true)
		return null;
	let d = (type(r) == 'object') ? r.description : null;
	return 'API error: ' + ((type(d) == 'string' && d != '') ? d : 'unknown');
}

function send_telegram(x, m) {
	let s = x.s;
	let token = s.bot_token || uget('telegram', 'bot_token') || '';
	let chat = s.chat_id || uget('telegram', 'chat_id') || '';
	if (token == '' || chat == '')
		return { ok: false, msg: 'token and chat_id required' };
	if (!lib.plain(chat) || !match(chat, TG_CHAT_RE))
		return { ok: false, msg: 'chat_id must be numeric' };
	if (!lib.plain(token) || !match(token, TG_TOKEN_RE))
		return { ok: false, msg: 'invalid token format' };
	let text = (m.ev == 'new_device' && (s.template ?? '') != '') ? html(m.ev, m.f, s.template) : m.html;
	let err = tg_send(token, chat, text);
	return err ? { ok: false, msg: err } : { ok: true, msg: 'sent' };
}

const NTFY_TAGS = { new_device: 'new', known_device: 'iphone', block_applied: 'no_entry',
	limit_applied: 'zap', cut_engaged: 'warning', test: 'white_check_mark' };

function send_ntfy(x, m) {
	let s = x.s, server = s.server || 'https://ntfy.sh', topic = s.topic ?? '';
	if (!url_ok(server))
		return { ok: false, msg: 'invalid server URL' };
	if (!lib.plain(topic) || !match(topic, /^[A-Za-z0-9_-]{1,64}$/))
		return { ok: false, msg: 'invalid topic' };
	let h = [ 'Content-Type: application/json' ];
	if ((s.token ?? '') != '') {
		if (!header_ok(s.token))
			return { ok: false, msg: 'invalid token' };
		push(h, 'Authorization: Bearer ' + s.token);
	}
	let body = { topic, title: m.title, message: m.text,
		priority: lib.valid_int(s.priority ?? '3', 1, 5) ?? 3, tags: [ NTFY_TAGS[m.ev] ?? 'bell' ] };
	let err = post_status(rtrim(server, '/') + '/', h, lib.to_json(body));
	return err ? { ok: false, msg: err } : { ok: true, msg: 'sent' };
}

function send_webhook(x, m) {
	let s = x.s, url = s.url ?? '';
	if (!url_ok(url))
		return { ok: false, msg: 'invalid URL' };
	let h = [ 'Content-Type: application/json' ];
	if ((s.auth ?? '') != '') {
		if (!header_ok(s.auth))
			return { ok: false, msg: 'invalid Authorization value' };
		push(h, 'Authorization: ' + s.auth);
	}
	let body = { event: m.ev, time: m.time, router: m.router, title: m.title, text: m.text };
	for (let k in keys(m.f))
		body[k] = m.f[k];
	let err = post_status(url, h, lib.to_json(body));
	return err ? { ok: false, msg: err } : { ok: true, msg: 'sent' };
}

const ADDR_RE = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+$/;
const DAYS = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ];
const MONTHS = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];

function rfc2822(t) {
	let g = gmtime(t);
	return sprintf('%s, %02d %s %04d %02d:%02d:%02d +0000', DAYS[g.wday % 7], g.mday, MONTHS[g.mon - 1],
		g.year, g.hour, g.min, g.sec);
}

function addresses(v) {
	if (type(v) == 'array')
		v = join(' ', v);
	return filter(split(v ?? '', /[ ,]+/), (a) => a != '');
}

function send_mail(x, m) {
	let s = x.s;
	if (!lib.is_file(MSMTP))
		return { ok: false, msg: 'msmtp is not installed' };
	let to = addresses(s.to), sender = s['from'] ?? '', acct = s.account ?? '';
	if (!length(to) || length(filter(to, (a) => !lib.plain(a) || !match(a, ADDR_RE))))
		return { ok: false, msg: 'invalid recipient' };
	if (sender != '' && (!lib.plain(sender) || !match(sender, ADDR_RE)))
		return { ok: false, msg: 'invalid sender address' };
	if (acct != '' && (!lib.plain(acct) || !match(acct, /^[A-Za-z0-9_.-]+$/)))
		return { ok: false, msg: 'invalid msmtp account' };
	let argv = [ lib.path(MSMTP), '--timeout=10' ];
	if (acct != '')
		push(argv, '-a', acct);
	if (sender != '')
		push(argv, '-f', sender);
	push(argv, '--');
	for (let a in to)
		push(argv, a);
	let mail = 'To: ' + join(', ', to) + '\n' + ((sender != '') ? 'From: ' + sender + '\n' : '') +
		'Subject: ' + m.title + '\nDate: ' + rfc2822(m.time) +
		'\nMIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: 8bit\n\n' +
		m.text + '\n';
	let out = lib.pipe(lib.qv(argv) + '; echo "rc=$?"', mail);
	let rc = match(out, /rc=([0-9]+)\n?$/);
	return (rc && rc[1] == '0') ? { ok: true, msg: 'sent' } : { ok: false, msg: 'msmtp failed' + (rc ? ' (exit ' + rc[1] + ')' : '') };
}

const SEND = { telegram: send_telegram, ntfy: send_ntfy, webhook: send_webhook, mail: send_mail };

function deliver(x, m) {
	let r;
	try {
		r = SEND[x.type](x, m);
	}
	catch (e) {
		r = { ok: false, msg: 'internal error: ' + e.message };
	}
	return { sender: x.name, type: x.type, ok: r.ok, msg: r.msg };
}

// ── events ──────────────────────────────────────────────────────────────────

function hotplug(ev, t, f) {
	if (!hotplug_scripts())
		return false;
	let env = [ 'ACTION=' + ev, 'TIME=' + t ];
	for (let k in keys(f))
		push(env, uc(k) + '=' + ((type(f[k]) == 'bool') ? (f[k] ? '1' : '0') : '' + f[k]));
	return lib.sh('env ' + lib.qv(env) + ' ' + lib.q(lib.path(HOTPLUG_CALL)) + ' trafficctl') == 0;
}

// notify.enabled '0' silences the senders (subscribers() is empty); ubus and
// the hotplug scripts are the router's own, and keep getting every event.
function dispatch(ev, fields, t) {
	if (!valid_event(ev))
		return [];
	let f = clean(fields);
	t ??= now();
	hotplug(ev, t, f);
	let res = [];
	for (let x in subscribers(ev)) {
		let r = deliver(x, message(ev, f, t, null));
		if (!r.ok)
			logger(sprintf('%s via %s failed: %s', ev, x.name, r.msg));
		push(res, r);
	}
	return res;
}

function emit(ev, fields, sync) {
	if (!valid_event(ev))
		return { ok: false, msg: 'unknown event: ' + (lib.plain(ev) ? ev : '') };
	let f = clean(fields), t = now();
	lib.ubus_event('trafficctl.notify', payload(ev, t, f));
	if (!hotplug_scripts() && !length(subscribers(ev)))
		return { ok: true, msg: 'event sent' };
	if (sync || getenv('TCTL_NOTIFY_SYNC') == '1')
		return { ok: true, msg: 'event sent', results: dispatch(ev, f, t) };
	lib.sh(lib.qv([ lib.path(CLI), 'notify', 'dispatch', ev, 'time=' + t, ...to_kv(f) ]) + ' &');
	return { ok: true, msg: 'event sent' };
}

// For the code that does an action (ctl, cut): emit() with the caller, as
// tctl_notify sends it from the shell. It never fails the action.
// TCTL_NOTIFY=0 (the ifup restore hook) puts back what was there: no event.
function emit_action(ev, fields) {
	if (getenv('TCTL_NOTIFY') == '0')
		return;
	try {
		let f = (type(fields) == 'object') ? { ...fields } : {};
		f.via = getenv('TCTL_VIA') || 'cli';
		f.src = getenv('TCTL_SRC') || 'local';
		emit(ev, f);
	}
	catch (e) {
		warn(sprintf('trafficctl: %s not sent: %s\n', ev, e.message));
	}
}

// ── the scan ────────────────────────────────────────────────────────────────

// check_new_devices: a MAC missing from the ledger is new; one in it that was
// not online at the previous scan is a known device back online.
function scan() {
	load_known();
	let macs = discover(), prev = lib.is_file(ONLINE) ? lib.file_lines(ONLINE) : null;
	let res = { new: 0, online: 0, devices: length(macs) };
	for (let mac in macs) {
		if (!is_known(mac)) {
			let i = resolve(mac);
			// Another writer (the DHCP hook) may have announced it first.
			if (add_known(mac, i.name, i.ip)) {
				emit('new_device', { mac, ip: i.ip, name: i.name, link: i.link }, true);
				res.new++;
			}
		}
		else if (prev != null && index(prev, mac) < 0) {
			let i = resolve(mac);
			emit('known_device', { mac, ip: i.ip, name: i.name, link: i.link }, true);
			res.online++;
		}
	}
	lib.write_atomic(ONLINE, length(macs) ? join('\n', macs) + '\n' : '');
	return res;
}

function watch() {
	while (true) {
		lib.reset();
		let iv = scan_interval();
		if (scan_wanted()) {
			try {
				scan();
			}
			catch (e) {
				warn(sprintf('trafficctl notify watch: %s\n', e.message));
			}
		}
		gc();
		sleep(((iv > 0) ? iv : 30) * 1000);
	}
}

// process_dhcp_triggers, for one lease, as dnsmasq reports it.
function dhcp(mac, ip, name) {
	mac = lib.plain(mac) ? lc(mac) : '';
	if (!match(mac, MAC_RE))
		return { ok: false, msg: 'usage: trafficctl notify dhcp <mac> [ip] [name]' };
	if (!scan_wanted())
		return { ok: true, msg: 'not watching for devices' };
	load_known();
	if (is_known(mac))
		return { ok: true, msg: 'known device' };
	ip = (lib.plain(ip) && ip != '') ? ip : '?';
	name = (lib.plain(name) && name != '') ? name : 'unknown';
	// The scan may have recorded and announced it since the check above.
	if (!add_known(mac, name, ip))
		return { ok: true, msg: 'known device' };
	emit('new_device', { mac, ip, name, link: 'dhcp' }, true);
	return { ok: true, msg: 'new device' };
}

// ── migration and tests ─────────────────────────────────────────────────────

// Once, from uci-defaults: the bot's notification options become the
// notify_telegram sender, with the same effect.
function migrate() {
	let c = lib.cursor();
	if (c.get('trafficctl', 'notify') != null)
		return { ok: true, msg: 'nothing to migrate' };
	c.set('trafficctl', 'notify', 'notify');
	c.set('trafficctl', 'notify', 'enabled', '1');
	c.set('trafficctl', 'notify', 'scan', 'auto');
	c.set('trafficctl', 'notify', 'scan_interval', '30');
	let had = 0;
	lib.uci_foreach('trafficctl', 'notify_telegram', () => {
		had++;
	});
	if (!had && c.get('trafficctl', 'telegram') != null) {
		let old = legacy_telegram().s;
		c.set('trafficctl', 'notify_telegram', 'notify_telegram');
		c.set('trafficctl', 'notify_telegram', 'enabled', length(old.events) ? old.enabled : '0');
		c.set('trafficctl', 'notify_telegram', 'events', length(old.events) ? old.events : [ 'new_device' ]);
		if (old.template != '')
			c.set('trafficctl', 'notify_telegram', 'template', old.template);
		for (let o in [ 'notify_new_device', 'notify_known_device', 'notify_template' ])
			c.delete('trafficctl', 'telegram', o);
	}
	if (!lib.commit('trafficctl'))
		return { ok: false, msg: 'could not save the trafficctl settings' };
	return { ok: true, msg: 'migrated' };
}

// ── settings (the LuCI Notifications tab) ───────────────────────────────────

// Per sender type, the options the tab edits; SECRET ones are never handed
// out, only a mask the setter recognises and an *_set flag.
const OPTS = {
	telegram: [ 'bot_token', 'chat_id', 'template' ],
	ntfy: [ 'server', 'topic', 'token', 'priority' ],
	webhook: [ 'url', 'auth' ],
	mail: [ 'to', 'from', 'account' ],
};
const SECRET = { bot_token: true, token: true, auth: true };
const MASK = '***';

function sender_view(x) {
	let o = { name: x.name, type: x.type, legacy: x.legacy, enabled: enabled(x.s), events: events_of(x.s) };
	for (let k in OPTS[x.type]) {
		let v = x.s[k] ?? '';
		if (type(v) == 'array')
			v = join(' ', v);
		if (SECRET[k]) {
			o[k] = (v != '') ? MASK : '';
			o[k + '_set'] = v != '';
		}
		else
			o[k] = v;
	}
	return o;
}

function config_get() {
	return {
		enabled: master_on(),
		scan: uget('notify', 'scan') ?? 'auto',
		scan_interval: scan_interval(),
		scan_wanted: scan_wanted(),
		events: EVENTS,
		types: TYPES,
		msmtp: lib.is_file(MSMTP),
		hotplug_scripts: hotplug_scripts(),
		bot_token_set: (uget('telegram', 'bot_token') ?? '') != '',
		bot_chat_id: uget('telegram', 'chat_id') ?? '',
		senders: map(senders(), sender_view),
	};
}

// The section a setter writes: a section name, or a type for its first
// section (created as notify_<type> when there is none).
function sender_section(name) {
	let c = lib.cursor();
	if (!lib.plain(name) || !match(name, /^[A-Za-z0-9_]{1,64}$/))
		return null;
	if (index(TYPES, name) >= 0) {
		let first = null;
		lib.uci_foreach('trafficctl', 'notify_' + name, (s) => {
			first = s['.name'];
			return false;
		});
		if (first == null) {
			first = 'notify_' + name;
			if (c.get('trafficctl', first) != null)
				return null;
			c.set('trafficctl', first, first);
		}
		return { name: first, type: name };
	}
	let t = c.get('trafficctl', name);
	if (type(t) != 'string' || substr(t, 0, 7) != 'notify_' || index(TYPES, substr(t, 7)) < 0)
		return null;
	return { name, type: substr(t, 7) };
}

function opt_ok(k, v) {
	switch (k) {
	case 'bot_token': return !!match(v, TG_TOKEN_RE);
	case 'chat_id': return !!match(v, TG_CHAT_RE);
	case 'template': return length(v) <= 4096;
	case 'server':
	case 'url': return url_ok(v);
	case 'topic': return !!match(v, /^[A-Za-z0-9_-]{1,64}$/);
	case 'token':
	case 'auth': return header_ok(v);
	case 'priority': return lib.valid_int(v, 1, 5) != null;
	case 'to': return length(addresses(v)) > 0 && !length(filter(addresses(v), (a) => !match(a, ADDR_RE)));
	case 'from': return !!match(v, ADDR_RE);
	case 'account': return !!match(v, /^[A-Za-z0-9_.-]{1,64}$/);
	}
	return false;
}

// What a sender cannot deliver without; checked when it is switched on.
function missing(t, s) {
	switch (t) {
	case 'telegram':
		return ((s.bot_token || uget('telegram', 'bot_token') || '') == '' ||
			(s.chat_id || uget('telegram', 'chat_id') || '') == '') ? 'a bot token and a chat id' : null;
	case 'ntfy': return ((s.topic ?? '') == '') ? 'a topic' : null;
	case 'webhook': return ((s.url ?? '') == '') ? 'a URL' : null;
	case 'mail':
		if (!lib.is_file(MSMTP))
			return 'msmtp (opkg install msmtp)';
		return ((s.to ?? '') == '') ? 'a recipient' : null;
	}
	return null;
}

// a: option name -> string, only the options the caller sent. sender ''
// (or absent) sets the global options. Nothing is written unless every
// value is valid. The caller commits.
function config_set(a) {
	let c = lib.cursor(), bad = (k) => ({ ok: false, msg: 'invalid ' + k });
	for (let k in keys(a))
		if (!lib.plain(a[k]) || (k != 'template' && match(a[k], /[\x01-\x1f\x7f]/)))
			return bad(k);
	let b = (v) => (v == '1' || v == 'true') ? '1' : '0';
	if ((a.sender ?? '') == '') {
		if (exists(a, 'scan') && index([ '0', '1', 'auto' ], a.scan) < 0)
			return bad('scan');
		let iv = exists(a, 'scan_interval') ? lib.valid_int(a.scan_interval, 0, 86400) : 30;
		if (iv == null || (iv > 0 && iv < 10))
			return bad('scan_interval');
		if (c.get('trafficctl', 'notify') == null)
			c.set('trafficctl', 'notify', 'notify');
		if (exists(a, 'enabled'))
			c.set('trafficctl', 'notify', 'enabled', b(a.enabled));
		if (exists(a, 'scan'))
			c.set('trafficctl', 'notify', 'scan', a.scan);
		if (exists(a, 'scan_interval'))
			c.set('trafficctl', 'notify', 'scan_interval', '' + iv);
		return { ok: true };
	}
	let ev = null;
	if (exists(a, 'events')) {
		ev = filter(split(a.events, /[ ,]+/), (e) => e != '');
		if (!length(ev) || length(filter(ev, (e) => !valid_event(e))))
			return bad('events');
	}
	let sec = sender_section(a.sender);
	if (!sec)
		return { ok: false, msg: 'no such sender' };
	let s = c.get_all('trafficctl', sec.name) ?? {};
	let set = {};
	for (let k in OPTS[sec.type]) {
		if (!exists(a, k) || (SECRET[k] && a[k] == MASK))
			continue;
		// rpcd types priority as an int: 0 is the server's default.
		if (k == 'priority' && a[k] == '0')
			a[k] = '';
		if (a[k] != '' && !opt_ok(k, a[k]))
			return bad(k);
		set[k] = a[k];
		s[k] = a[k];
	}
	let on = exists(a, 'enabled') ? b(a.enabled) : ((s.enabled ?? '1') == '1' ? '1' : '0');
	let need = (on == '1') ? missing(sec.type, s) : null;
	if (need)
		return { ok: false, msg: sec.type + ' needs ' + need };
	c.set('trafficctl', sec.name, 'enabled', on);
	if (ev)
		c.set('trafficctl', sec.name, 'events', ev);
	for (let k in keys(set)) {
		if (set[k] == '')
			c.delete('trafficctl', sec.name, k);
		else
			c.set('trafficctl', sec.name, k, set[k]);
	}
	return { ok: true, sender: sec.name };
}

function test(name) {
	let x = filter(senders(), (s) => s.name == name || s.type == name)[0];
	if (!x)
		return { ok: false, msg: 'no such sender: ' + (lib.plain(name) ? name : '') };
	let r = router_name(), h = '✅ <b>TrafficCtl</b> notifications work' + ((r != '') ? ' on ' + esc(r) : '');
	let m = { ev: 'test', f: {}, time: now(), html: h, text: strip_html(h),
		title: (r != '') ? r + ': Test' : 'Test', router: r };
	let res = deliver(x, m);
	return { ok: res.ok, msg: res.ok ? 'test message sent' : res.msg };
}

// trafficctl-telegram-test.sh: the token from TCTL_TG_TOKEN, else the first
// argument; a custom message gets the template's sample values.
function telegram_test(args) {
	let envtok = getenv('TCTL_TG_TOKEN');
	let token = (envtok != null && envtok != '') ? envtok : (args[0] ?? '');
	let chat = args[1] ?? '', custom = args[2] ?? '';
	if (token == '' || chat == '')
		return { ok: false, msg: 'token and chat_id required' };
	if (!lib.plain(chat) || !match(chat, TG_CHAT_RE))
		return { ok: false, msg: 'chat_id must be numeric' };
	if (!lib.plain(token) || !match(token, TG_TOKEN_RE))
		return { ok: false, msg: 'invalid token format' };
	let router = first_option('system', 'system', 'hostname') ?? 'OpenWrt', msg;
	if (lib.plain(custom) && custom != '') {
		let t = localtime(now());
		let date = sprintf('%04d-%02d-%02d', t.year, t.mon, t.mday), hm = sprintf('%02d:%02d', t.hour, t.min);
		let up = uptime_secs() ?? 0, wan = wan_ip();
		if (wan == '')
			wan = match(lib.run('ip route get 1.1.1.1'), /src ([0-9.]*)/)?.[1] ?? '';
		msg = fill(replace(custom, /\\n/g, '\n'), {
			name: 'TestDevice', ip: '192.168.0.100', mac: 'aa:bb:cc:dd:ee:ff', link: '5G', router,
			date, time: hm, datetime: date + ' ' + hm,
			ssid: first_option('wireless', 'wifi-iface', 'ssid') ?? 'WiFi', signal: '-52',
			freq: '5GHz', iface: 'wlan1', clients: '12',
			uptime: sprintf('%dd %dh', int(up / 86400), int((up % 86400) / 3600)),
			wan_ip: (wan != '') ? wan : 'unknown', load: load1() ?? '0.00', conns: '5',
		}, ' *');
		msg = rtrim(msg, '\n');
	}
	else
		msg = '✅ TrafficCtl bot connected from ' + router;
	let err = tg_send(token, chat, msg);
	return err ? { ok: false, msg: err } : { ok: true, msg: 'test message sent' };
}

export { EVENTS, TYPES, emit, emit_action, dispatch, scan, watch, scan_wanted, dhcp, migrate, senders,
	events_of, test, telegram_test, parse_kv, hotplug_scripts, config_get, config_set };
