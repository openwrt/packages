// SPDX-License-Identifier: GPL-2.0-only
// Agent: measures and switches the radios of the local device.
// Used directly by the controller for the local node and exposed to remote
// controllers through the rpcd plugin (chanmgr agent_* methods).
//
// Does not call rpcd-provided ubus objects (iwinfo, uci, ...): this module
// also runs inside rpcd, where that would deadlock.

'use strict';

let fs = require('fs');
let ubus = require('ubus');
let uci = require('uci');
let chan = require('chanmgr.chan');
let parse = require('chanmgr.parse');
let nl = require('chanmgr.nl');

// the list of changes made here survives reboots (a write per change)
const PERSIST_DIR = getenv('CHANMGR_PERSIST_DIR') ?? '/etc/chanmgr';
const CHANGES_MAX = 30;

let conn;
let pending = {};

function bus() {
	conn ??= ubus.connect();

	return conn;
}

function shq(s) {
	return "'" + replace('' + s, "'", "'\\''") + "'";
}

function run(cmd) {
	let p = fs.popen(cmd + ' 2>/dev/null', 'r');

	if (!p)
		return null;

	let out = p.read('all');

	p.close();

	return out;
}

function iw(args) {
	return run('iw ' + args);
}

// Radio state from nl80211 when available, else from the text of iw.
function dev_info(ifname) {
	return nl.dev_info(ifname) ?? parse.dev_info(iw('dev ' + shq(ifname) + ' info'));
}

// A radio entering a DFS channel listens for radar (channel availability
// check, 1 to 10 min) before it may transmit: nothing to measure or switch
// meanwhile. hostapd reports it (not an rpcd object: no deadlock).
function cac_active(ifname) {
	return !!bus().call('hostapd.' + ifname, 'get_status', {})?.dfs?.cac_active;
}

function survey_dump(ifname) {
	return nl.survey(ifname) ?? parse.survey(iw('dev ' + shq(ifname) + ' survey dump'));
}

function station_rx(ifname) {
	return nl.station_rx(ifname) ?? parse.station_rx(iw('dev ' + shq(ifname) + ' station dump'));
}

// Radios of this device with their interfaces, current channel and the
// channels the regulatory domain allows.
function info() {
	let st = bus().call('network.wireless', 'status', {}) ?? {};
	let cur = uci.cursor();
	let radios = {}, down = {};

	for (let name, r in st) {
		if (r.disabled)
			continue;

		if (!r.up) {
			down[name] = 'radio is down';
			continue;
		}

		let ifaces = [];

		for (let i in r.interfaces ?? []) {
			if (!i.ifname)
				continue;

			let d = dev_info(i.ifname);

			push(ifaces, { ifname: i.ifname, mode: i.config?.mode ?? d.type, addr: d.addr, info: d });
		}

		let main = filter(ifaces, (i) => i.mode == 'ap')[0] ?? filter(ifaces, (i) => i.mode == 'mesh')[0];

		if (!main || main.info.freq == null) {
			down[name] = main ? main.ifname + ' has no channel (not started, or waiting for DFS)' : 'no AP or mesh interface';
			continue;
		}

		if (main.mode == 'ap' && cac_active(main.ifname)) {
			down[name] = 'checking the DFS channel for radar before using it';
			continue;
		}

		let d = main.info;
		let band = r.config?.band ?? cur.get('wireless', name, 'band') ?? chan.freq2band(d.freq);
		let htmode = r.config?.htmode ?? cur.get('wireless', name, 'htmode') ?? 'HT20';
		let phy = iw('phy#' + d.wiphy + ' info');
		let channels = parse.phy_channels(phy);

		radios[name] = {
			band, htmode,
			ifname: main.ifname,
			mode: main.mode,
			channel: d.channel,
			freq: d.freq,
			width: d.width,
			// widest channel the hardware supports in this band (at least the
			// one it runs on, should the capabilities not be read)
			max_width: max(parse.phy_widths(phy)[band] ?? 20, d.width ?? 20),
			center: chan.freq2chan(d.center1),
			cfg_channel: '' + (r.config?.channel ?? cur.get('wireless', name, 'channel') ?? 'auto'),
			has_mesh: length(filter(ifaces, (i) => i.mode == 'mesh')) > 0,
			ifaces: map(ifaces, (i) => ({ ifname: i.ifname, mode: i.mode, addr: i.addr })),
			bssids: filter(map(ifaces, (i) => i.addr), (a) => a),
			channels: filter(channels, (c) => chan.freq2band(c.freq) == band)
		};
	}

	// agent: feature level, lets the controller refuse what an old agent cannot do
	return { hostname: trim(fs.readfile('/proc/sys/kernel/hostname') ?? ''), agent: 4, radios, down };
}

// Survey counters of every radio (passive, no off-channel time).
function survey() {
	let res = {};

	for (let name, r in info().radios) {
		// receive airtime of our own clients, to tell it apart from neighbors
		let stations = {};

		for (let i in filter(r.ifaces, (i) => i.mode == 'ap'))
			stations = { ...stations, ...station_rx(i.ifname) };

		res[name] = { freq: r.freq, survey: survey_dump(r.ifname), stations };
	}

	return { radios: res };
}

// Off-channel scan of one radio, plus the survey data collected while scanning.
function scan(radio) {
	let r = info().radios[radio];

	if (!r)
		return { error: 'unknown or inactive radio: ' + radio };

	let cmd = 'dev ' + shq(r.ifname) + ' scan' + ((r.mode == 'ap') ? ' ap-force' : '');
	let bss = parse.scan(iw(cmd));

	// "Device or resource busy" while another scan is running: retry once
	if (!length(bss)) {
		sleep(3000);
		bss = parse.scan(iw(cmd));
	}

	if (!length(bss))
		bss = parse.scan(iw('dev ' + shq(r.ifname) + ' scan dump'));

	return {
		radio, freq: r.freq,
		neighbors: bss,
		survey: survey_dump(r.ifname)
	};
}

// Number of established 802.11s peers on the given interfaces.
function mesh_peers(ifnames) {
	let n = 0;

	for (let ifname in ifnames)
		n += nl.mesh_peers(ifname) ?? length(filter(split(iw('dev ' + shq(ifname) + ' station dump') ?? '', '\n'),
			(l) => match(l, /mesh plink:\s+ESTAB/)));

	return n;
}

function current_freq(ifname) {
	return dev_info(ifname).freq;
}

// Does the interface run on freq (and width, when given)?
function running_on(ifname, freq, width) {
	let d = dev_info(ifname);

	return d.freq == freq && (!width || d.width == width);
}

// Wait until the radio runs on freq (and width). Returns true on success. The
// radio may be down for a while (restart), so look it up on every attempt.
function verify(radio, freq, timeout, width) {
	for (let t = 0; t < (timeout ?? 15); t++) {
		let r = info().radios[radio];

		if (r && running_on(r.ifname, freq, width))
			return true;

		sleep(1000);
	}

	return false;
}

// Restart one radio with its configured settings (also brings back an
// interface that hostapd disabled after a failed channel switch).
function restart(radio) {
	system(sprintf('wifi down %s >/dev/null 2>&1; wifi up %s >/dev/null 2>&1', shq(radio), shq(radio)));
}

// Store channel (and width, as htmode) in UCI. Commit only: no "wifi reload",
// the radio already runs with these settings (or the caller restarts it).
function persist(radio, channel, width) {
	let cur = uci.cursor();
	let changed = false;

	if (cur.get('wireless', radio, 'channel') != '' + channel) {
		cur.set('wireless', radio, 'channel', '' + channel);
		changed = true;
	}

	let htmode = cur.get('wireless', radio, 'htmode');

	if (width && htmode && chan.htmode_width(htmode) != +width) {
		cur.set('wireless', radio, 'htmode', chan.htmode_with_width(htmode, +width));
		changed = true;
	}

	if (changed)
		cur.commit('wireless');
}

// Channel changes made on this device, newest first (shown on its status
// page).
function changes() {
	try {
		return json(fs.readfile(PERSIST_DIR + '/changes.json') ?? '[]') ?? [];
	}
	catch (e) {
		return [];
	}
}

function note(radio, entry) {
	let list = changes();

	unshift(list, { ts: time(), radio, ...entry });
	fs.mkdir(PERSIST_DIR, 0755);
	fs.writefile(PERSIST_DIR + '/changes.json.tmp', sprintf('%J', slice(list, 0, CHANGES_MAX)));
	fs.rename(PERSIST_DIR + '/changes.json.tmp', PERSIST_DIR + '/changes.json');
}

// "Clear history" on the status page
function clear_changes() {
	fs.unlink(PERSIST_DIR + '/changes.json');
}

// Switch a radio.
//   args: { radio, channel, width, bcn_count, nowait, reload_fallback, method }
//   method "csa" (default): channel switch announcement, clients stay connected;
//     on failure the radio is restarted on its configured (old) channel, or on
//     the new one with reload_fallback.
//   method "reload": write the channel to UCI and restart the radio. Clients
//     reconnect, but it works for radios that also carry a mesh interface,
//     where a CSA can leave the radio down.
function do_switch(args) {
	let cur = uci.cursor();

	if (cur.get('wireless', args.radio) != 'wifi-device')
		return { ok: false, error: 'unknown radio: ' + args.radio };

	let r = info().radios[args.radio];
	let band = r?.band ?? cur.get('wireless', args.radio, 'band');
	let width = +(args.width || r?.width || chan.htmode_width(cur.get('wireless', args.radio, 'htmode')));
	let s = chan.spec(band, +args.channel, width);
	let bcn = +(args.bcn_count || 10);
	let errors = [];

	if (args.method == 'reload' || !r) {
		persist(args.radio, s.channel, s.width);
		system('wifi reload >/dev/null 2>&1');

		if (args.nowait)
			return { ok: true, errors, freq: s.freq };

		let ok = verify(args.radio, s.freq, 45, s.width);

		return { ok, errors: ok ? [] : [ 'radio not on the new channel after restart' ], freq: s.freq };
	}

	let ap = filter(r.ifaces, (i) => i.mode == 'ap')[0];

	if (ap) {
		// one call switches every BSS of the hostapd interface
		bus().call('hostapd.' + ap.ifname, 'switch_chan', chan.switch_args(s, r.htmode, bcn));

		let err = bus().error();

		if (err)
			push(errors, 'hostapd switch_chan: ' + err);
	}

	for (let i in filter(r.ifaces, (i) => i.mode == 'mesh')) {
		let cmd = sprintf('iw dev %s switch freq %d %d %d beacons %d', shq(i.ifname), s.freq, s.width, s.cfreq, bcn);

		if (system(cmd + ' >/dev/null 2>&1') != 0)
			push(errors, 'mesh CSA failed on ' + i.ifname);
	}

	if (args.nowait)
		return { ok: !length(errors), errors, freq: s.freq };

	let ok = verify(args.radio, s.freq, int(bcn * 0.1024) + 10, s.width);

	if (ok) {
		persist(args.radio, s.channel, s.width);

		return { ok, errors, freq: s.freq };
	}

	if (args.reload_fallback) {
		persist(args.radio, s.channel, s.width);
		system('wifi reload >/dev/null 2>&1');
		ok = verify(args.radio, s.freq, 90, s.width);
		push(errors, 'CSA failed, used wifi reload fallback');

		return { ok, errors, freq: s.freq };
	}

	// never leave the radio broken: back to its configured channel
	push(errors, 'CSA failed, radio restarted on its previous channel');
	restart(args.radio);

	return { ok: false, errors, freq: s.freq };
}

function switch_channel(args) {
	let before = info().radios[args.radio];
	let res = do_switch(args);
	let entry = {
		from: before?.channel, from_width: before?.width, to: +args.channel, width: +(args.width || before?.width || 0),
		how: (args.method == 'reload' || !before) ? 'restart' : 'csa'
	};

	// switches announced to a whole group are noted when confirmed
	if (args.nowait && res.ok)
		pending[args.radio] = entry;
	else
		note(args.radio, { ...entry, ok: res.ok, msg: join('; ', res.errors ?? (res.error ? [ res.error ] : []))
			|| ((entry.how == 'csa') ? 'clients followed the switch announcement' : 'radio restarted on the new channel') });

	return res;
}

// Confirm a switch issued with nowait and persist it.
function confirm(args) {
	let band = info().radios[args.radio]?.band ?? uci.cursor().get('wireless', args.radio, 'band');

	if (!band)
		return { ok: false, error: 'unknown radio: ' + args.radio };

	let freq = chan.chan2freq(band, +args.channel);
	let ok = verify(args.radio, freq, +(args.timeout || 15), +(args.width || 0));

	if (ok)
		persist(args.radio, +args.channel, +(args.width || 0));

	note(args.radio, { ...(pending[args.radio] ?? { to: +args.channel, width: +(args.width || 0) }), ok, how: 'group',
		msg: ok ? 'on the new channel together with the group' : 'not on the new channel' });
	delete pending[args.radio];

	return { ok };
}

return { info, survey, scan, switch_channel, confirm, verify, persist, current_freq, running_on, mesh_peers, changes, note, clear_changes };
