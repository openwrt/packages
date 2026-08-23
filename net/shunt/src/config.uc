// shunt - configuration
//
// Turns UCI shaped sections into the structures the other modules consume.
// load() reads UCI, parse() is pure and fed literals by the tests.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export const DEFAULTS = {
	enabled: true,
	poll_interval: 300,
	entry_ttl: 1200,
	snoop: true,
	snoop_devices: [ 'br-lan' ],
	debug: false,
	rp_filter_manage: false
};

export const MIN = {
	poll_interval: 30,
	entry_ttl: 60
};

function to_bool(v, dflt) {
	if (v == null)
		return dflt;
	if (v === true || v === false)
		return v;
	if (v == '1' || v == 1)
		return true;
	if (v == '0' || v == 0)
		return false;
	return null;
}

function uniq(list) {
	let seen = {};
	let out = [];

	for (let v in list) {
		if (!seen[v]) {
			seen[v] = true;
			push(out, v);
		}
	}

	return out;
}

function to_list(v) {
	if (v == null)
		return [];
	if (type(v) == 'array')
		return v;
	return [ v ];
}

// require('uci') sits inside so the module stays importable without it, and
// parse() stays pure for the tests.
export function load() {
	let uci;

	try {
		uci = require('uci');
	}
	catch (e) {
		return null;
	}

	let sections = [];

	uci.cursor().foreach('shunt', null, (s) => {
		let values = {};

		for (let k in s)
			if (substr(k, 0, 1) != '.')
				values[k] = s[k];

		push(sections, { type: s['.type'], name: s['.name'], values });
	});

	return sections;
};

export function parse(sections) {
	let g = { ...DEFAULTS };
	let policies = [], issues = [];

	function reject(section, option, reason) {
		push(issues, { section, option, reason });
	}

	function num_opt(section, values, key) {
		let v = values[key];
		if (v == null)
			return;

		let n = +v;
		if (type(v) == 'string' && match(v, /^[0-9]+$/) == null || n != n) {
			reject(section, key, sprintf('not a number: %J, default %d kept',
				v, g[key]));
			return;
		}
		if (n < MIN[key]) {
			reject(section, key, sprintf('%d below minimum, clamped to %d',
				n, MIN[key]));
			n = MIN[key];
		}
		g[key] = n;
	}

	function bool_opt(section, values, key) {
		let b = to_bool(values[key], g[key]);
		if (b === null) {
			reject(section, key, sprintf('not a boolean: %J, default kept',
				values[key]));
			return;
		}
		g[key] = b;
	}

	for (let s in (sections ?? [])) {
		if (s?.type == 'global') {
			let v = s.values ?? {};

			bool_opt(s.name ?? 'global', v, 'enabled');
			bool_opt(s.name ?? 'global', v, 'snoop');
			bool_opt(s.name ?? 'global', v, 'debug');
			bool_opt(s.name ?? 'global', v, 'rp_filter_manage');
			num_opt(s.name ?? 'global', v, 'poll_interval');
			num_opt(s.name ?? 'global', v, 'entry_ttl');

			if (v.snoop_device != null) {
				let devs = [];

				for (let d in to_list(v.snoop_device)) {
					if (type(d) == 'string' && length(d))
						push(devs, d);
					else
						reject(s.name ?? 'global', 'snoop_device',
							sprintf('not a device name: %J, entry dropped', d));
				}

				if (length(devs))
					g.snoop_devices = uniq(devs);
				else
					reject(s.name ?? 'global', 'snoop_device',
						'no usable device, default kept');
			}
			continue;
		}

		if (s?.type != 'policy')
			continue;

		let v = s.values ?? {};

		if (to_bool(v.enabled, true) !== true)
			continue;

		push(policies, {
			name: s.name,
			interface: v.interface,
			fallback: v.fallback,
			gw4: v.gw4,
			gw6: v.gw6,
			src: to_list(v.src),
			src_mac: to_list(v.src_mac),
			dport: to_list(v.dport),
			proto: to_list(v.proto),
			dst: to_list(v.dst),
			domains: to_list(v.domain)
		});
	}

	return { global: g, policies, issues };
};
