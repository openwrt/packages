// travelmate - uplink selection: walks the configured stations against the
// ranked scan of one radio, steps (op): log sta keep mismatch add try noscan

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

// bssid with upper-case hex digits
export function normbssid(b) {
	return replace(b ?? '', /[a-f]/g, (m) => uc(m));
};

// locally administered address, the usual evil-twin pattern
function laa(bssid) {
	return (hex(split(bssid, ':')[0]) & 2) != 0;
}

// bracket expression at p[i] == '[', returns the index after ']' and whether
// c matched, or null if there is no closing ']' (then '[' is literal)
function bracket(p, i, c) {
	let j = i + 1, neg = false, ok = false;

	if (substr(p, j, 1) == '!' || substr(p, j, 1) == '^') {
		neg = true;
		j++;
	}

	for (let first = true; j < length(p); first = false) {
		let a = substr(p, j, 1);

		if (a == ']' && !first)
			return { next: j + 1, ok: ok != neg };

		if (substr(p, j + 1, 1) == '-' && j + 2 < length(p) && substr(p, j + 2, 1) != ']') {
			let b = substr(p, j + 2, 1);

			if (ord(c) >= ord(a) && ord(c) <= ord(b))
				ok = true;

			j += 3;
		}
		else {
			if (c == a)
				ok = true;

			j++;
		}
	}

	return null;
}

// glob pattern match on bytes for trm_ssidfilter: *, ?, [...], backslash
export function glob(p, s, pi, si) {
	pi ??= 0;
	si ??= 0;

	while (pi < length(p)) {
		let c = substr(p, pi, 1);

		if (c == '*') {
			while (substr(p, pi, 1) == '*')
				pi++;

			if (pi == length(p))
				return true;

			for (let k = si; k <= length(s); k++)
				if (glob(p, s, pi, k))
					return true;

			return false;
		}

		if (si >= length(s))
			return false;

		if (c == '?') {
			pi++;
			si++;
			continue;
		}

		if (c == '[') {
			let r = bracket(p, pi, substr(s, si, 1));

			if (r) {
				if (!r.ok)
					return false;

				pi = r.next;
				si++;
				continue;
			}
		}

		if (c == '\\' && pi + 1 < length(p))
			c = substr(p, ++pi, 1);

		if (substr(s, si, 1) != c)
			return false;

		pi++;
		si++;
	}

	return si == length(s);
};

function log(out, class, msg) {
	push(out, { op: 'log', class, msg });
}

// an info that repeats every cycle as long as the scan stays the same, the
// daemon logs it once per run and as debug line afterwards
function note(out, msg) {
	push(out, { op: 'log', class: 'info', msg, once: true });
}

// open uplinks to autoadd, in scan order: open, named, above minquality,
// not filtered, not configured yet and within the autoadd quota
function autoadd(out, opts, entries, known) {
	let cfg = opts.cfg, radio = opts.radio, cnt = cfg.autoaddcnt;

	for (let e in entries) {
		if (e.quality < cfg.minquality)
			break;

		if (!e.open || e.hidden || known[radio + '\n' + e.raw])
			continue;

		// per bss: an LAA bss is skipped, another bss of the ssid may count
		if (cfg.eviltwin && laa(e.bssid)) {
			note(out, sprintf("skipped autoadd of LAA candidate (evil-twin) '%s/%s/%s'",
				radio, e.ssid, e.bssid));
			continue;
		}

		// per ssid: one decision, also for further bss of a filtered one
		known[radio + '\n' + e.raw] = true;

		let pattern = null;

		for (let p in cfg.ssidfilter) {
			if (glob(p, e.raw)) {
				pattern = p;
				break;
			}
		}

		if (pattern != null) {
			note(out, sprintf("open uplink filtered out '%s/%s/%s'", radio, e.raw, pattern));
			continue;
		}

		if (cfg.maxautoadd != 0 && cnt >= cfg.maxautoadd)
			break;

		push(out, { op: 'add', radio, essid: e.raw }, { op: 'try' });
		cnt++;
	}
}

// configured stations first, in their order; open uplinks are added and tried
// only as last resort, never while the current uplink is kept
export function plan(opts) {
	let out = [], cfg = opts.cfg, radio = opts.radio, cur = opts.current;
	let ifaces = opts.ifaces ?? {}, entries = null, known = {};

	for (let n, s in ifaces)
		known[s.device + '\n' + s.ssid] = true;

	for (let sta in opts.stalist ?? []) {
		let w = ifaces[sta.section] ?? {};
		let sradio = w.device ?? '', sessid = w.ssid ?? '', sbssid = normbssid(w.bssid);

		if (!length(sradio) || !length(sessid)) {
			note(out, sprintf("invalid wireless section '%s'", sta.section));
			continue;
		}

		push(out, { op: 'sta', section: sta.section, radio: sradio, bssid: sbssid, essid: sessid });

		if (cur && radio == cur.radio && sradio == cur.radio &&
		    sessid == cur.essid && sbssid == cur.bssid) {
			push(out, { op: 'keep' });
			return out;
		}

		log(out, 'debug', sprintf('f_main-5    ::: sta_radio: %s, sta_essid: "%s", sta_bssid: %s',
			sradio, sessid, length(sbssid) ? sbssid : '-'));

		entries ??= opts.scan() ?? [];

		if (!length(entries)) {
			push(out, { op: 'noscan', radio });
			return out;
		}

		for (let e in entries) {
			let named = !e.hidden && e.raw == sessid;

			log(out, 'debug', sprintf('f_main-6    ::: radio(sta/scan): %s/%s, essid(sta/scan): "%s"/%s, bssid(sta/scan): %s/%s, quality(min/scan): %d/%d, open: %s',
				sradio, radio, sessid, e.ssid, sbssid, e.bssid, cfg.minquality, e.quality, e.open ? '+' : '-'));

			if (e.quality < cfg.minquality)
				break;

			if (length(sbssid) && radio == sradio && e.bssid != sbssid && named) {
				push(out, { op: 'mismatch', bssid: e.bssid });
				continue;
			}

			if (((named && (!length(sbssid) || e.bssid == sbssid)) ||
			     (e.bssid == sbssid && e.hidden)) && radio == sradio) {
				if (cfg.eviltwin && !length(sbssid) && !e.hidden && laa(e.bssid)) {
					note(out, sprintf("skipped LAA candidate (evil-twin) '%s/%s/%s => %s'",
						sradio, sessid, length(sbssid) ? sbssid : '-', e.bssid));
					continue;
				}

				push(out, { op: 'try' });
				cur = null;
				break;
			}
		}
	}

	if (cfg.autoadd) {
		entries ??= opts.scan() ?? [];

		if (!length(entries)) {
			push(out, { op: 'noscan', radio });
			return out;
		}

		autoadd(out, opts, entries, known);
	}

	return out;
};
