'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// UCI config loading, schema definitions, and cursor management.

function create_config(uci_mod, ubus_mod, pkg) {
	let cursor_fn = uci_mod.cursor;
	let connect_fn = ubus_mod.connect;

	let _cursor = null;
	let _cursor_loaded = {};

	// Shared mutable config — populated by load(), read by everyone
	let cfg = {};

	function uci_ctx(config, reload) {
		if (!_cursor) _cursor = cursor_fn();
		if (!_cursor_loaded[config] || reload) {
			_cursor.load(config);
			_cursor_loaded[config] = true;
		}
		return _cursor;
	}

	function ubus_call(path, method, args) {
		let u = connect_fn();
		if (!u) return null;
		let result = u.call(path, method, args);
		u.disconnect();
		return result;
	}

	function network_flush_cache() {
		_cursor_loaded['network'] = false;
	}

	// ── Config Schema ───────────────────────────────────────────────

	const config_schema = {
		enabled:                  ['bool', false],
		ipv6_enabled:             ['bool', false],
		nft_rule_counter:         ['bool', false],
		nft_set_counter:          ['bool', false],
		nft_set_flags_timeout:    ['bool', false],
		nft_user_set_counter:     ['bool', false],
		netifd_enabled:           ['bool', false],
		debug_performance:        ['bool', false],
		netifd_strict_enforcement:['bool', false],
		nft_set_auto_merge:       ['bool', true],
		nft_set_flags_interval:   ['bool', true],
		strict_enforcement:       ['bool', true],
		config_compat:            ['string'],
		config_version:           ['string'],
		fw_mask:                  ['string', '00ff0000'],
		icmp_interface:           ['string', ''],
		nft_set_gc_interval:      ['string', ''],
		nft_set_policy:           ['string', 'performance'],
		nft_set_timeout:          ['string', ''],
		nft_user_set_policy:      ['string', ''],
		prefixlength:             ['string', '1'],
		procd_boot_trigger_delay: ['string', '5000'],
		procd_reload_delay:       ['string', '0'],
		resolver_set:             ['string', ''],
		uplink_interface:         ['string', 'wan'],
		uplink_interface6:        ['string', 'wan6'],
		uplink_ip_rules_priority: ['string', '30000'],
		uplink_mark:              ['string', '00010000'],
		netifd_interface_default: ['string', ''],
		netifd_interface_default6:['string', ''],
		netifd_interface_local:   ['string', ''],
		verbosity:                ['int', 2],
		ignored_interface:        ['list', ''],
		lan_device:               ['list', 'br-lan'],
		resolver_instance:        ['list', '*'],
		supported_interface:      ['list', ''],
	};

	const policy_schema = {
		enabled:   ['string', '1'],
		name:      ['string', ''],
		interface: ['string', ''],
		src_addr:  ['string', ''],
		src_port:  ['string', ''],
		dest_addr: ['string', ''],
		dest_port: ['string', ''],
		proto:     ['string', ''],
		chain:     ['string', ''],
	};

	const dns_policy_schema = {
		enabled:       ['string', '1'],
		name:          ['string', ''],
		src_addr:      ['string', ''],
		dest_dns:      ['string', ''],
		dest_dns_port: ['string', ''],
	};

	function parse_options(raw, schema) {
		let result = {};
		for (let key in schema) {
			let spec = schema[key];
			let v = raw[key];
			switch (spec[0]) {
			case 'bool':
				result[key] = (v == null) ? spec[1] : (+v > 0 || v == 'yes' || v == 'on' || v == 'true');
				break;
			case 'string':
				result[key] = (v == null) ? (spec[1] ?? null) : '' + v;
				break;
			case 'int':
				result[key] = (v == null) ? (spec[1] ?? 0) : +v;
				break;
			case 'list':
				if (v == null) { result[key] = spec[1] ?? ''; }
				else { result[key] = (type(v) == 'array') ? join(' ', v) : '' + v; }
				break;
			}
		}
		return result;
	}

	// ── load() ──────────────────────────────────────────────────────

	function load(sh) {
		let raw = uci_ctx(pkg.name, true).get_all(pkg.name, 'config') || {};
		let parsed = parse_options(raw, config_schema);

		// Copy into shared cfg object (so all holders see updates)
		for (let k in parsed)
			cfg[k] = parsed[k];

		cfg.uplink_interface4 = cfg.uplink_interface;
		cfg.uplink_interface6_metric = '128';
		cfg.fw_mask = '0x' + cfg.fw_mask;
		cfg.uplink_mark = '0x' + cfg.uplink_mark;

		if (cfg.resolver_set == 'none') cfg.resolver_set = '';
		if (!cfg.ipv6_enabled) cfg.uplink_interface6 = '';

		let mask_val = int(hex(cfg.fw_mask));
		let xor_val = mask_val ^ 0xffffffff;
		cfg.fw_maskXor = sprintf('%#x', xor_val) || '0xff00ffff';

		if (!match('' + cfg.procd_boot_trigger_delay, /^[0-9]+$/)) cfg.procd_boot_trigger_delay = '5000';
		if (int(cfg.procd_boot_trigger_delay) < 1000) cfg.procd_boot_trigger_delay = '1000';

		// suppress_prefixlength is interpolated into an `ip rule` command line,
		// so it must be a bare number. UCI declares it a string with no bound,
		// which let arbitrary text through to the shell. 0-128 is the protocol
		// maximum; `ip -4` rejects anything above 32 on its own.
		if (!match('' + cfg.prefixlength, /^[0-9]+$/)) cfg.prefixlength = '1';
		if (int(cfg.prefixlength) > 128) cfg.prefixlength = '128';

		if (!match('' + cfg.uplink_ip_rules_priority, /^[0-9]+$/)) cfg.uplink_ip_rules_priority = '30000';
		if (int(cfg.uplink_ip_rules_priority) < 99) cfg.uplink_ip_rules_priority = '99';
		if (int(cfg.uplink_ip_rules_priority) > 32765) cfg.uplink_ip_rules_priority = '32765';

		// An nft time value is a run of <decimal><unit>, unit being ms, s, m, h
		// or d -- `1h`, `6h`, `1h30m`, `100ms`. A bare number is NOT accepted,
		// and neither is a `w` for weeks; both were checked against nftables
		// 1.0.9 and the 1.1.6 in OpenWrt 25.12. UCI declares these two options
		// a free string with no bound, so a typo went straight into the set
		// declaration. Drop a value nft cannot use rather than emit it: these
		// are tuning knobs, and a whole ruleset nft refuses -- which stops ALL
		// policy routing -- is a far worse outcome than an ignored timeout.
		// Same treatment as prefixlength above.
		if (cfg.nft_set_timeout && !match(cfg.nft_set_timeout, /^([0-9]+(ms|s|m|h|d))+$/))
			cfg.nft_set_timeout = '';
		if (cfg.nft_set_gc_interval && !match(cfg.nft_set_gc_interval, /^([0-9]+(ms|s|m|h|d))+$/))
			cfg.nft_set_gc_interval = '';

		// Build nft_set_flags string. Flags ONLY: the set's default timeout is
		// emitted once, below. Appending it here as well put `timeout` in the
		// declaration twice.
		let nft_set_flags = '';
		let fi = cfg.nft_set_flags_interval;
		let ft = cfg.nft_set_flags_timeout;
		if (fi && ft) {
			nft_set_flags = 'flags interval, timeout';
		} else if (fi && !ft) {
			nft_set_flags = 'flags interval';
		} else if (!fi && ft) {
			nft_set_flags = 'flags timeout';
		}

		if (!cfg.nft_set_flags_timeout && !cfg.nft_set_timeout) cfg.nft_set_gc_interval = '';

		// Compute nft params
		cfg._nft_rule_params = cfg.nft_rule_counter ? 'counter' : '';

		let set_parts = [];
		if (cfg.nft_set_auto_merge) push(set_parts, 'auto-merge;');
		if (cfg.nft_set_counter) push(set_parts, 'counter;');
		if (nft_set_flags) push(set_parts, nft_set_flags + ';');
		// `gc-interval`, not `gc_interval`, and both values go in BARE. The
		// quotes here were the shell version's own -- `gc_interval "$val";` in
		// the old init script, where the shell ate them before nft saw the
		// line. The ucode port copied them in as literal characters, which nft
		// rejects with `unexpected quoted string, expecting string`. `policy`
		// was ported correctly and is left alone.
		if (cfg.nft_set_gc_interval) push(set_parts, 'gc-interval ' + cfg.nft_set_gc_interval + ';');
		if (cfg.nft_set_policy) push(set_parts, 'policy ' + cfg.nft_set_policy + ';');
		if (cfg.nft_set_timeout) push(set_parts, 'timeout ' + cfg.nft_set_timeout + ';');
		cfg._nft_set_params = ' ' + join(' ', set_parts) + ' ';
	}

	return {
		cfg,
		uci_ctx,
		ubus_call,
		network_flush_cache,
		load,
		parse_options,
		config_schema,
		policy_schema,
		dns_policy_schema,
	};
}

export default create_config;
