// SPDX-License-Identifier: GPL-2.0-only
// Radio state read straight from the kernel (nl80211) instead of parsing
// the text output of "iw". Every function returns null when nl80211 is not
// available (ucode-mod-nl80211 missing) or the request fails; the agent then
// falls back to iw. The results have the shape of the parse.uc functions.

'use strict';

let chan = require('chanmgr.chan');

let nl = null;

try {
	nl = require('nl80211');
}
catch (e) {
	nl = null;
}

// nl80211_chan_width -> MHz
const WIDTHS = { '0': 20, '1': 20, '2': 40, '3': 80, '4': 80, '5': 160, '6': 5, '7': 10, '13': 320 };
const PLINK_ESTAB = 4;
// nl80211_iftype -> the names "iw dev <if> info" prints
const IFTYPES = { '2': 'managed', '3': 'AP', '6': 'monitor', '7': 'mesh point' };

function request(cmd, dump, args) {
	if (!nl)
		return null;

	let c = nl.const;
	let r = nl.request(c[cmd], dump ? c.NLM_F_DUMP : 0, args);

	return r ?? null;
}

function list(r) {
	return (type(r) == 'array') ? r : (r ? [ r ] : []);
}

// "iw dev <if> survey dump": [ { freq, in_use, noise, active, busy, rx, tx } ]
function survey(ifname) {
	let r = request('NL80211_CMD_GET_SURVEY', true, { dev: ifname });

	if (r == null)
		return null;

	let res = [];

	for (let e in list(r)) {
		let s = e.survey_info;

		if (!s?.frequency)
			continue;

		push(res, {
			freq: s.frequency, in_use: !!s.in_use, noise: s.noise,
			// field names differ between ucode versions
			active: s.time ?? s.time_active, busy: s.busy ?? s.time_busy,
			rx: s.time_rx, tx: s.time_tx
		});
	}

	// every radio reports at least the channel in use: nothing usable (an
	// unexpected reply format) means falling back to iw
	return length(filter(res, (e) => e.active != null && e.busy != null)) ? res : null;
}

// Station dump of one interface: [ { mac, rx_duration (us), plink_state } ]
function stations(ifname) {
	let r = request('NL80211_CMD_GET_STATION', true, { dev: ifname });

	if (r == null)
		return null;

	return map(filter(list(r), (e) => e.mac), (e) => ({
		mac: lc(e.mac), rx_duration: e.sta_info?.rx_duration, plink_state: e.sta_info?.plink_state
	}));
}

// Receive airtime per client, { mac: microseconds }
function station_rx(ifname) {
	let st = stations(ifname);

	if (st == null)
		return null;

	let res = {};

	for (let s in st)
		if (s.rx_duration != null)
			res[s.mac] = s.rx_duration;

	return res;
}

// Established 802.11s peers of a mesh interface
function mesh_peers(ifname) {
	let st = stations(ifname);

	return (st == null) ? null : length(filter(st, (s) => s.plink_state == PLINK_ESTAB));
}

// "iw dev <if> info": { ifname, addr, wiphy, channel, freq, width, center1 }
function dev_info(ifname) {
	let r = request('NL80211_CMD_GET_INTERFACE', false, { dev: ifname });

	if (type(r) != 'object' || r.wiphy == null)
		return null;

	let res = { ifname: r.ifname ?? ifname, addr: r.mac ? lc(r.mac) : null, type: IFTYPES['' + r.iftype], wiphy: r.wiphy };

	if (r.wiphy_freq) {
		res.freq = r.wiphy_freq;
		res.channel = chan.freq2chan(r.wiphy_freq);
		res.width = WIDTHS['' + r.channel_width] ?? 20;
		res.center1 = r.center_freq1 ?? r.wiphy_freq;
	}

	return res;
}

// Tests replace the nl80211 module with a stand-in.
function use(mod) {
	nl = mod;
}

return { survey, station_rx, mesh_peers, dev_info, use, available: () => nl != null };
