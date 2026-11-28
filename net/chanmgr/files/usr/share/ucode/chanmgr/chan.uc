// SPDX-License-Identifier: GPL-2.0-only
// Channel math: frequencies, channel blocks, spectral overlap, candidates.

'use strict';

// First 20 MHz channel of every 5 GHz block, per bandwidth.
const BLOCKS_5G = {
	'40':  [ 36, 44, 52, 60, 100, 108, 116, 124, 132, 140, 149, 157, 165, 173 ],
	'80':  [ 36, 52, 100, 116, 132, 149, 165 ],
	'160': [ 36, 100, 149 ]
};

function chan2freq(band, ch) {
	if (band == '2g')
		return (ch == 14) ? 2484 : 2407 + 5 * ch;

	if (band == '6g')
		return (ch == 2) ? 5935 : 5950 + 5 * ch;

	return 5000 + 5 * ch;
}

function freq2band(freq) {
	if (freq < 3000)
		return '2g';

	if (freq < 5925)
		return '5g';

	return '6g';
}

function freq2chan(freq) {
	if (freq == 2484)
		return 14;

	if (freq < 3000)
		return int((freq - 2407) / 5);

	if (freq == 5935)
		return 2;

	if (freq >= 5950)
		return int((freq - 5950) / 5);

	return int((freq - 5000) / 5);
}

// Bandwidth in MHz implied by an UCI htmode value.
function htmode_width(htmode) {
	let m = match(htmode ?? '', /^(HT|VHT|HE|EHT)([0-9]+)/);

	return m ? +m[2] : 20;
}

// The htmode for another width, keeping the PHY family (HE80 -> HE40).
function htmode_with_width(htmode, width) {
	let fam = match(htmode ?? '', /^(HT|VHT|HE|EHT)/)?.[1] ?? 'HT';

	if (fam == 'HT' && width > 40)
		fam = 'VHT';

	return fam + width;
}

// Feature flags expected by hostapd's switch_chan for the given htmode.
function htmode_flags(htmode, band) {
	let fam = match(htmode ?? '', /^(NOHT|HT|VHT|HE|EHT)/)?.[1] ?? 'HT';
	let rank = { NOHT: 0, HT: 1, VHT: 2, HE: 3, EHT: 4 }[fam];

	return {
		ht: rank >= 1,
		vht: rank >= 2 && band != '2g',
		he: rank >= 3,
		eht: rank >= 4
	};
}

function block_start(ch, width) {
	let span = (width / 5) - 4;

	for (let s in BLOCKS_5G['' + width])
		if (ch >= s && ch <= s + span)
			return s;

	return null;
}

// Build a channel spec: { band, channel, width, center, freq, cfreq, sec }.
// "center" is the center channel number; "sec" the secondary offset (+1/-1/0).
function spec(band, channel, width, center) {
	width = +(width ?? 20);

	if (band == '2g' && width > 40)
		width = 40;

	if (center == null) {
		center = channel;

		if (band == '2g') {
			if (width == 40)
				center = (channel <= 7) ? channel + 2 : channel - 2;
		}
		else if (width >= 40) {
			let s = block_start(channel, width);

			if (s == null)
				width = 20;
			else
				center = s + (width / 20 - 1) * 2;
		}
	}

	let sec = 0;

	if (width >= 40)
		sec = (center > channel) ? 1 : -1;

	return {
		band, channel, width, center, sec,
		freq: chan2freq(band, channel),
		cfreq: chan2freq(band, center)
	};
}

// 20 MHz channel numbers covered by a spec.
function subchannels(s) {
	if (s.width <= 20)
		return [ s.channel ];

	if (s.band == '2g')
		return [ s.channel, s.channel + s.sec * 4 ];

	let n = s.width / 20, first = s.center - (n - 1) * 2, res = [];

	for (let i = 0; i < n; i++)
		push(res, first + i * 4);

	return res;
}

// Occupied spectrum [lo, hi] in MHz. 2.4 GHz 20 MHz signals are 22 MHz wide.
function span(s) {
	let half = (s.band == '2g' && s.width == 20) ? 11 : s.width / 2;

	return [ s.cfreq - half, s.cfreq + half ];
}

// Overlap of two specs as a fraction (0..1) of the narrower one.
function overlap(a, b) {
	let sa = span(a), sb = span(b);
	let ov = min(sa[1], sb[1]) - max(sa[0], sb[0]);

	if (ov <= 0)
		return 0;

	return min(1, 1.0 * ov / min(sa[1] - sa[0], sb[1] - sb[0]));
}

function key(s) {
	return s ? sprintf('%d/%d', s.channel, s.width) : '-';
}

function same(a, b) {
	return a && b && a.channel == b.channel && a.width == b.width;
}

// Allowed-channel map from a list of { channel, freq, disabled, no_ir, radar }.
// Channels that are disabled, or no-IR without being DFS, are unusable for an AP.
function allowed_map(channels, band) {
	let res = {};

	for (let c in channels) {
		if (freq2band(c.freq) != band || c.disabled)
			continue;

		if (c.no_ir && !c.radar)
			continue;

		res['' + c.channel] = { dfs: !!c.radar || (band == '5g' && c.channel >= 52 && c.channel <= 144) };
	}

	return res;
}

// Candidate specs for a radio.
//   allowed: map from allowed_map()
//   opts: { allow_dfs, channels_2g: [..] }
//   prefer: current primary channel, kept when it lies in a candidate block
function candidates(band, width, allowed, opts, prefer) {
	let res = [];

	if (band == '2g') {
		for (let ch in (opts.channels_2g ?? [ 1, 6, 11 ]))
			if (allowed['' + ch])
				push(res, spec(band, +ch, 20));

		return res;
	}

	if (band != '5g')
		return res;

	let usable = (ch) => allowed['' + ch] && (opts.allow_dfs || !allowed['' + ch].dfs);

	if (width <= 20) {
		for (let ch in sort(map(keys(allowed), (k) => +k), (a, b) => a - b))
			if (usable(ch))
				push(res, spec(band, ch, 20));

		return res;
	}

	for (let s in BLOCKS_5G['' + width] ?? []) {
		let sp = spec(band, s, width);

		if (sp.width != width || length(filter(subchannels(sp), (c) => !usable(c))))
			continue;

		if (prefer != null && index(subchannels(sp), +prefer) >= 0)
			sp = spec(band, +prefer, width, sp.center);

		push(res, sp);
	}

	return res;
}

// Spec of a scanned BSS (see parse.scan()).
function neighbor_spec(bss) {
	let band = freq2band(bss.freq);
	let ch = bss.primary ?? freq2chan(bss.freq);

	if (band == '5g' && bss.vht_width >= 1 && bss.seg1) {
		if (bss.seg2 && (bss.seg2 - bss.seg1 == 8 || bss.seg1 - bss.seg2 == 8))
			return spec(band, ch, 160, bss.seg2);

		return spec(band, ch, (bss.vht_width == 2) ? 160 : 80, bss.seg1);
	}

	if (bss.sec_offset == 'above')
		return spec(band, ch, 40, ch + 2);

	if (bss.sec_offset == 'below')
		return spec(band, ch, 40, ch - 2);

	return spec(band, ch, 20);
}

// Arguments for "ubus call hostapd.<ifname> switch_chan".
function switch_args(s, htmode, bcn_count) {
	let args = {
		freq: s.freq,
		center_freq1: s.cfreq,
		bandwidth: s.width,
		sec_channel_offset: s.sec,
		bcn_count: bcn_count ?? 10
	};

	return { ...args, ...htmode_flags(htmode, s.band) };
}

return {
	chan2freq, freq2band, freq2chan, htmode_width, htmode_flags, htmode_with_width,
	spec, subchannels, span, overlap, key, same,
	allowed_map, candidates, neighbor_spec, switch_args
};
