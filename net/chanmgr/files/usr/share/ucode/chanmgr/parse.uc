// SPDX-License-Identifier: GPL-2.0-only
// Parsers for "iw" command output.

'use strict';

function lines(text) {
	return split(text ?? '', '\n');
}

function num(s) {
	return (s != null) ? +s : null;
}

// "iw dev <if> scan [ap-force]" / "iw dev <if> scan dump"
function scan(text) {
	let res = [], cur = null, sect = null;

	for (let l in lines(text)) {
		let m = match(l, /^BSS ([0-9a-f:]{17})/);

		if (m) {
			cur = { bssid: m[1], ssid: '', freq: null, signal: null };
			push(res, cur);
			sect = null;
			continue;
		}

		if (!cur)
			continue;

		if ((m = match(l, /^\tfreq: ([0-9.]+)/)))
			cur.freq = int(+m[1]);
		else if ((m = match(l, /^\tsignal: (-?[0-9.]+) dBm/)))
			cur.signal = int(+m[1]);
		else if ((m = match(l, /^\tSSID: (.*)$/)))
			cur.ssid = m[1];
		else if (match(l, /^\tHT operation:/))
			sect = 'ht';
		else if (match(l, /^\tVHT operation:/))
			sect = 'vht';
		else if (match(l, /^\t[^\t ]/))
			sect = null;
		else if (sect == 'ht') {
			if ((m = match(l, /\* primary channel: ([0-9]+)/)))
				cur.primary = +m[1];
			else if ((m = match(l, /\* secondary channel offset: (.+)$/)))
				cur.sec_offset = trim(m[1]);
		}
		else if (sect == 'vht') {
			if ((m = match(l, /\* channel width: ([0-9]+)/)))
				cur.vht_width = +m[1];
			else if ((m = match(l, /\* center freq segment 1: ([0-9]+)/)))
				cur.seg1 = +m[1];
			else if ((m = match(l, /\* center freq segment 2: ([0-9]+)/)))
				cur.seg2 = +m[1];
		}
	}

	return filter(res, (b) => b.freq && b.signal != null);
}

// "iw dev <if> survey dump"
function survey(text) {
	let res = [], cur = null;

	for (let l in lines(text)) {
		let m;

		if ((m = match(l, /frequency:\s+([0-9.]+) MHz( \[in use\])?/))) {
			cur = { freq: int(+m[1]), in_use: !!m[2] };
			push(res, cur);
		}
		else if (!cur)
			continue;
		else if ((m = match(l, /noise:\s+(-?[0-9]+) dBm/)))
			cur.noise = +m[1];
		else if ((m = match(l, /channel active time:\s+([0-9]+) ms/)))
			cur.active = +m[1];
		else if ((m = match(l, /channel busy time:\s+([0-9]+) ms/)))
			cur.busy = +m[1];
		else if ((m = match(l, /channel receive time:\s+([0-9]+) ms/)))
			cur.rx = +m[1];
		else if ((m = match(l, /channel transmit time:\s+([0-9]+) ms/)))
			cur.tx = +m[1];
	}

	return res;
}

// "iw dev <if> info"
function dev_info(text) {
	let res = {};

	for (let l in lines(text)) {
		let m;

		if ((m = match(l, /^Interface (.+)$/)))
			res.ifname = m[1];
		else if ((m = match(l, /^\taddr ([0-9a-f:]{17})/)))
			res.addr = m[1];
		else if ((m = match(l, /^\ttype (.+)$/)))
			res.type = m[1];
		else if ((m = match(l, /^\twiphy ([0-9]+)/)))
			res.wiphy = +m[1];
		else if ((m = match(l, /^\tchannel ([0-9]+) \(([0-9.]+) MHz\)(, width: ([0-9]+) MHz)?(.*center1: ([0-9.]+) MHz)?/))) {
			res.channel = +m[1];
			res.freq = int(+m[2]);
			res.width = num(m[4]) ?? 20;
			res.center1 = m[6] ? int(+m[6]) : res.freq;
		}
	}

	return res;
}

// "iw phy <phy> info": the "Frequencies:" lists of every band.
function phy_channels(text) {
	let res = [];

	for (let l in lines(text)) {
		let m = match(l, /^\s+\* ([0-9]+)(\.[0-9]+)? MHz \[([0-9]+)\](.*)$/);

		if (!m)
			continue;

		let flags = m[4];

		push(res, {
			freq: +m[1],
			channel: +m[3],
			disabled: index(flags, 'disabled') >= 0,
			no_ir: index(flags, 'no IR') >= 0 || index(flags, 'passive scan') >= 0 || index(flags, 'no IBSS') >= 0,
			radar: index(flags, 'radar detection') >= 0
		});
	}

	return res;
}

// "iw phy <phy> info": the widest channel the hardware supports per band,
// { '2g': 40, '5g': 160 }. Bands without capability lines count as 20 MHz.
function phy_widths(text) {
	let res = {}, sect = null;
	let done = () => {
		if (sect?.band)
			res[sect.band] = max(res[sect.band] ?? 20, sect.width);
	};

	for (let l in lines(text)) {
		let m;

		if (match(l, /^\tBand [0-9]+:/)) {
			done();
			sect = { band: null, width: 20 };
		}
		else if (!sect)
			continue;
		else if (match(l, /^\S/) || match(l, /^\t[^\t]/)) {
			done();
			sect = null;
		}
		else if ((m = match(l, /^\s+\* ([0-9]+)(\.[0-9]+)? MHz \[/)))
			sect.band ??= (+m[1] < 3000) ? '2g' : (+m[1] < 5950) ? '5g' : '6g';
		else if (match(l, /HT20\/HT40/) || match(l, /HE40\/2\.4GHz/))
			sect.width = max(sect.width, 40);
		else if (match(l, /^\t\tVHT Capabilities/) || match(l, /HE40\/HE80\/5GHz/))
			sect.width = max(sect.width, 80);
		else if (match(l, /Supported Channel Width: 160/) || match(l, /HE160\/5GHz/))
			sect.width = max(sect.width, 160);
		else if (match(l, /EHT320/))
			sect.width = max(sect.width, 320);
	}

	done();

	return res;
}

// "iw dev <if> station dump": receive airtime per client, { mac: microseconds }
function station_rx(text) {
	let res = {}, mac = null;

	for (let l in lines(text)) {
		let m;

		if ((m = match(l, /^Station ([0-9a-f:]{17})/)))
			mac = m[1];
		else if (mac && (m = match(l, /^\trx duration:\s+([0-9]+) us/)))
			res[mac] = +m[1];
	}

	return res;
}

return { scan, survey, dev_info, phy_channels, phy_widths, station_rx };
