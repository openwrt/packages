'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// Entry point: module wiring, service lifecycle, policy processing,
// interface routing, netifd integration, status/rpcd.
//
// Two ucode divergences from JavaScript that bite here: for-in over an array
// yields its values, not its indices (there is no for-of), and function
// declarations are not hoisted, so a helper must appear before its callers.

// ── Constants & Sub-module Factories ────────────────────────────────

import _pkg_mod from 'pkg';
let pkg = _pkg_mod.pkg;
let sym = _pkg_mod.sym;
let get_text = _pkg_mod.get_text;
import create_validators from 'validators';
import create_sys from 'sys';
import create_output from 'output';
import create_config from 'config';
import create_platform from 'platform';
import create_network from 'network';
import create_nft from 'nft';

// ── Factory ─────────────────────────────────────────────────────────

function create_pbr(fs_mod, uci_mod, ubus_mod) {

	let _fs = fs_mod || require('fs');
	let _uci = uci_mod || require('uci');
	let _ubus = ubus_mod || require('ubus');

	let sh = create_sys(_fs, pkg);
	let V = create_validators(_fs.lstat);
	let config = create_config(_uci, _ubus, pkg);
	let output = create_output(sh, pkg.name, sym);
	let platform = create_platform(_fs, config, sh, pkg, V);

	let cfg = config.cfg;
	let env = platform.env;

	// Shared mutable state — passed to nft module for error accumulation
	let state = { errors: [], warnings: [] };

	let net = create_network(_fs, config, sh, pkg, platform, V);
	let nft = create_nft(_fs, config, sh, output, pkg, platform, net, V, state);

	// ── Runtime State ───────────────────────────────────────────

	let iface_registry = {};
	let iface_priority = '';
	let ifaces_triggers = '';
	let service_start_trigger = '';
	let process_dns_policy_error = false;
	let process_policy_error = false;
	let pbr_nft_prev_param4 = '';
	let pbr_nft_prev_param6 = '';
	let _config_loaded = false;
	let _loaded = false;
	let _deferred_to_boot = false;

	// ── Interface Registry Helpers ──────────────────────────────────────
	
	function reset() {
		state.errors = [];
		state.warnings = [];
		_deferred_to_boot = false;
		for (let k in keys(iface_registry))
			delete iface_registry[k];
	}
	
	function get_mark(iface) {
		let iface_key = replace(iface, '-', '_');
		return iface_registry[iface_key]?.mark;
	}
	
	function set_interface(iface, data) {
		let iface_key = replace(iface, '-', '_');
		iface_registry[iface_key] = data;
	}
	
	function get_interface(iface) {
		let iface_key = replace(iface, '-', '_');
		return iface_registry[iface_key];
	}
	
	// ── Config / Environment Loading ────────────────────────────────────

	let _platform_loaded = false;
	let _network_loaded = false;

	function load_config() {
		if (_config_loaded) return;
		config.load(sh);
		let is_tty = system('[ -t 2 ]') == 0;
		output.set_state({ is_tty: is_tty, verbosity: cfg.verbosity,
			uci_getter: () => cfg.debug_performance });
		platform.detect_agh_config();
		_loaded = false;
		_platform_loaded = false;
		_network_loaded = false;
		_config_loaded = true;
	}

	function load_platform() {
		load_config();
		if (_platform_loaded) return;
		platform.detect();
		_platform_loaded = true;
	}

	function load_network(param) {
		load_platform();
		if (_network_loaded) return;
		net.load(param);
		_network_loaded = true;
	}

	// ── Forwarding Control ──────────────────────────────────────────────

	let forwarding = {};
	forwarding._read = function() {
		return trim(_fs.readfile('/proc/sys/net/ipv4/ip_forward') || '');
	};
	forwarding.disable = function() {
		load_config();
		if (!cfg.enabled) return;
		if (!cfg.strict_enforcement) return;
		if (forwarding._read() == '0') return;
		sh.run('/sbin/sysctl -w net.ipv4.ip_forward=0');
		sh.run('/sbin/sysctl -w net.ipv6.conf.all.forwarding=0');
		output.info.write('Forwarding disabled ');
		output.verbose.write('Forwarding disabled ');
		output.okn();
	};
	forwarding.enable = function() {
		load_config();
		if (forwarding._read() != '1') {
			sh.run('/sbin/sysctl -w net.ipv4.ip_forward=1');
			sh.run('/sbin/sysctl -w net.ipv6.conf.all.forwarding=1');
		}
		output.info.write('Forwarding enabled ');
		output.verbose.write('Forwarding enabled ');
		output.okn();
	};
	
	function _check_system_health() {
		let health_fail = false;
		if (!env.nft_installed) {
			push(state.errors, { code: 'errorNoNft' });
			health_fail = true;
		}
		let auto_inc = config.uci_ctx('firewall').get('firewall', 'defaults', 'auto_includes');
		if (auto_inc == '0') {
			let ctx = config.uci_ctx('firewall');
			ctx.delete('firewall', 'defaults', 'auto_includes');
			ctx.commit('firewall');
		}
		let ip_link = sh.exec('readlink /sbin/ip 2>/dev/null');
		if (ip_link != pkg.ip_full) {
			push(state.errors, { code: 'errorRequiredBinaryMissing', info: 'ip-full' });
			health_fail = true;
		}
		if (!nft.nft_check_element('table', 'fw4')) {
			push(state.errors, { code: 'errorDefaultFw4TableMissing', info: 'fw4' });
			health_fail = true;
		}
		if (net.is_config_enabled('dns_policy') || net.is_tor_configured()) {
			if (!nft.nft_check_element('chain', 'dstnat')) {
				push(state.errors, { code: 'errorDefaultFw4ChainMissing', info: 'dstnat' });
				health_fail = true;
			}
		}
		let chains = split(pkg.chains_list, ' ');
		for (let c in chains) {
			if (!nft.nft_check_element('chain', 'mangle_' + c)) {
				push(state.errors, { code: 'errorDefaultFw4ChainMissing', info: 'mangle_' + c });
				health_fail = true;
			}
		}
		if (cfg.resolver_set == 'dnsmasq.nftset' && !env.resolver_set_supported) {
			push(state.warnings, { code: 'warningResolverNotSupported' });
		}
		let ctx_dhcp = config.uci_ctx('dhcp');
		let ctx_net = config.uci_ctx('network');
		ctx_net.foreach('network', 'interface', function(s) {
			let iface = s['.name'];
			if (!net.is_lan(iface)) return;
			let force = ctx_dhcp.get('dhcp', iface, 'force');
			if (force == '0') {
				push(state.warnings, { code: 'warningDhcpLanForce', info: iface });
			}
			if (!cfg.resolver_set) return;
			let dhcp_option = ctx_dhcp.get('dhcp', iface, 'dhcp_option');
			if (type(dhcp_option) != 'array') return;
			let ipaddr = ctx_net.get('network', iface, 'ipaddr');
			if (type(ipaddr) == 'array') ipaddr = ipaddr[0];
			ipaddr ??= '';
			let ipaddr_base = split(ipaddr, '/')[0];
			for (let opt in dhcp_option) {
				let parts = split(opt, ',');
				if (length(parts) >= 2) {
					let option = parts[0];
					let value = parts[1];
					if (option == '6' && value != ipaddr_base)
						push(state.warnings, { code: 'warningIncompatibleDHCPOption6', info: iface + ': ' + value });
				}
			}
		});
		return !health_fail;
	}
	
	function load(param) {
		if (_loaded) return true;
	
		let start_time, end_time;
	
		switch (param) {
		case 'on_start':
			start_time = time();
			load_config();
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Loading config took ' + (end_time - start_time) + 's');
			output.info.write('Loading environment (' + param + ') ');
			output.verbose.write('Loading environment (' + param + ') ');
			if (!cfg.enabled) {
				output.failn();
				push(state.errors, { code: 'errorServiceDisabled' });
				output.error(get_text('errorServiceDisabled', cfg));
				output.print("Run the following commands before starting service again:\\n");
				output.print("uci set " + pkg.name + ".config.enabled='1'; uci commit " + pkg.name + ";\\n");
				return false;
			}
			start_time = time();
			load_platform();
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Detecting environment took ' + (end_time - start_time) + 's');
			if (!_check_system_health()) {
				output.failn();
				return false;
			}
			start_time = time();
			load_network(param);
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Loading network data took ' + (end_time - start_time) + 's');
			output.okn();
			break;

		case 'on_stop':
		case 'on_reload':
		case 'on_interface_reload':
			start_time = time();
			load_config();
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Loading config took ' + (end_time - start_time) + 's');
			output.info.write('Loading environment (' + param + ') ');
			output.verbose.write('Loading environment (' + param + ') ');
			start_time = time();
			load_platform();
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Detecting environment took ' + (end_time - start_time) + 's');
			start_time = time();
			load_network(param);
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Loading network data took ' + (end_time - start_time) + 's');
			output.okn();
			break;
	
		case 'netifd':
		case 'service_started':
			load_config();
			break;
	
		case 'rpcd':
		case 'status':
			load_network(param);
			break;
		}
	
		_loaded = true;
		return true;
	}
	
	// ── Address Exclusions ──────────────────────────────────────────────
	
	// nft has no OR between the match expressions of a rule, so every positive
	// address type a policy names needs a rule of its own -- that is what makes
	// src_addr/dest_addr a union of sources. Negated entries are the opposite:
	// they are AND terms and belong ON those rules. Given a rule of its own a
	// '!10.0.0.22' reads as "everything except 10.0.0.22", a catch-all that
	// swallows exactly the traffic the policy was meant to leave alone.
	//
	// Resolve a policy's negated groups once, into the fragments appended to
	// every rule it emits. classify_addr() keeps the families apart, so an IPv4
	// exclusion only ever reaches the IPv4 rule and vice versa. 'matched' feeds
	// the unknown-entry check in the callers.
	// First word of an address list with the negation markers stripped, used to
	// read a rule's address family. is_ipv4()/is_ipv6() do not accept a leading
	// '!', so the markers have to come off before the family is tested.
	function bare_first_word(raw) {
		return V.str_first_word(replace('' + (raw || ''), /!/g, ''));
	}

	function collect_negations(list, addr, direction, iface, uid, name, use_resolver) {
		let n4 = '', n6 = '', matched = '';
		if (!addr) return { n4, n6, matched };
		for (let fg in split(list, /\s+/)) {
			let fv = V.filter_options(fg, addr);
			if (!fv) continue;
			matched += (matched ? ' ' : '') + fv;
			let r = nft.classify_addr(fv, direction, iface, uid, name, use_resolver);
			if (r.param4 && !r.empty4) n4 += (n4 ? ' ' : '') + r.param4;
			if (r.param6 && !r.empty6) n6 += (n6 ? ' ' : '') + r.param6;
		}
		return { n4, n6, matched };
	}
	
	// ── DNS Policy Routing ──────────────────────────────────────────────
	
	function dns_policy_routing(name, src_addr, dest_dns, uid, dest_dns_port, dest_dns_ipv4, dest_dns_ipv6, src_neg) {
		let nft_insert = 'add';
		let protos = ['tcp', 'udp'];
		let chain = 'dstnat';
		let nft_table = pkg.nft_table;
		let nft_prefix = pkg.nft_prefix;
	
		if (!dest_dns_ipv4 && !dest_dns_ipv6) {
			process_dns_policy_error = true;
			push(state.errors, { code: 'errorPolicyProcessNoInterfaceDns', info: "'" + dest_dns + "'" });
			return 1;
		}
	
		// A rule built from exclusions alone has no positive source to take its
		// family from, so fall back to the negated entries for the guards below
		// and let the exclusions themselves decide which families to emit.
		let raw_src = src_addr || (src_neg ? src_neg.matched : '') || '';
		let first_value = bare_first_word(raw_src);
		let src_is_v4 = src_addr ? !V.is_ipv6(first_value) : !!(src_neg && src_neg.n4);
		let src_is_v6 = src_addr ? !V.is_ipv4(first_value) : !!(src_neg && src_neg.n6);
	
		if (!cfg.ipv6_enabled && V.is_ipv6(first_value)) {
			process_dns_policy_error = true;
			push(state.errors, { code: 'errorPolicyProcessNoIpv6', info: name });
			return 1;
		}
	
		if ((V.is_ipv4(first_value) && !dest_dns_ipv4) ||
			(V.is_ipv6(first_value) && !dest_dns_ipv6)) {
			process_dns_policy_error = true;
			push(state.errors, { code: 'errorPolicyProcessMismatchFamily',
				info: name + ": '" + raw_src + "' '" + dest_dns + "':'" + dest_dns_port + "'" });
			return 1;
		}
	
		for (let proto_i in protos) {
			let param4 = '', param6 = '';
			let inline_set_ipv4_empty = false, inline_set_ipv6_empty = false;
	
			let dest4 = 'dport 53 dnat ip to ' + dest_dns_ipv4 + (dest_dns_port ? ':' + dest_dns_port : '');
			// nft requires the IPv6 address to be bracketed when a port follows it.
			// is_ipv6() only checks for a ':', so dest_dns_ipv6 may already carry
			// brackets from the config; strip them first to avoid doubling up.
			let bare_dest_dns_ipv6 = dest_dns_ipv6 ? replace(dest_dns_ipv6, /^\[|\]$/g, '') : dest_dns_ipv6;
			let dest6 = 'dport 53 dnat ip6 to ' +
				(dest_dns_port ? '[' + bare_dest_dns_ipv6 + ']:' + dest_dns_port : bare_dest_dns_ipv6);
	
			if (src_addr) {
				let r = nft.classify_addr(src_addr, 'src', null, null, null, false);
				param4 = r.param4;
				param6 = r.param6;
				inline_set_ipv4_empty = r.empty4;
				inline_set_ipv6_empty = r.empty6;
			} else if (src_neg && (src_neg.n4 || src_neg.n6)) {
				// Exclusions with no positive source: suppress the family that
				// carries none of them, or its rule would match every packet.
				inline_set_ipv4_empty = !src_neg.n4;
				inline_set_ipv6_empty = !src_neg.n6;
			}
	
			// DNS rules already pin their family with 'meta nfproto', so the
			// exclusions can just be appended to the rule they belong to.
			if (src_neg) {
				if (src_neg.n4) param4 += (param4 ? ' ' : '') + src_neg.n4;
				if (src_neg.n6) param6 += (param6 ? ' ' : '') + src_neg.n6;
			}
	
			let rule_params = cfg._nft_rule_params ? ' ' + cfg._nft_rule_params : '';
			param4 = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
				(param4 ? ' ' + param4 : '') + rule_params + ' meta nfproto ipv4 ' + proto_i + ' ' + dest4 +
				' comment "' + name + '"';
			param6 = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
				(param6 ? ' ' + param6 : '') + rule_params + ' meta nfproto ipv6 ' + proto_i + ' ' + dest6 +
				' comment "' + name + '"';
	
			let ipv4_error = false, ipv6_error = false;
			if (pbr_nft_prev_param4 != param4 && first_value &&
				src_is_v4 && !inline_set_ipv4_empty && dest_dns_ipv4) {
				if (!nft.nft4(param4)) ipv4_error = true;
				pbr_nft_prev_param4 = param4;
			}
			if (pbr_nft_prev_param6 != param6 && param4 != param6 &&
				first_value && src_is_v6 && !inline_set_ipv6_empty && dest_dns_ipv6) {
				if (!nft.nft6(param6)) ipv6_error = true;
				pbr_nft_prev_param6 = param6;
			}
	
			if (cfg.ipv6_enabled && ipv4_error && ipv6_error) {
				process_dns_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessInsertionFailed', info: name });
				push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param4 });
				push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param6 });
			} else if (!cfg.ipv6_enabled && ipv4_error) {
				process_dns_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessInsertionFailedIpv4', info: name });
				push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param4 });
			}
		}
	}
	
	// ── Policy Routing ──────────────────────────────────────────────────
	
	function policy_routing(name, iface, src_addr, src_port, dest_addr, dest_port, proto, chain, uid, src_neg, dest_neg) {
		let nft_insert = 'add';
		let nft_table = pkg.nft_table;
		let nft_prefix = pkg.nft_prefix;
		let mark = get_mark(iface);
	
		proto = lc(proto || '');
		chain = lc(chain || '') || 'prerouting';
	
		// A rule built from exclusions alone still has a family; read it off the
		// negated entries when there is no positive address to read it from.
		let raw_src = src_addr || (src_neg ? src_neg.matched : '') || '';
		let raw_dest = dest_addr || (dest_neg ? dest_neg.matched : '') || '';
		if (!cfg.ipv6_enabled &&
			(V.is_ipv6(bare_first_word(raw_src)) ||
			 V.is_ipv6(bare_first_word(raw_dest)))) {
			process_policy_error = true;
			push(state.errors, { code: 'errorPolicyProcessNoIpv6', info: name });
			return 1;
		}
	
		let dest4, dest6;
		if (net.is_tor(iface)) {
			dest_port = null;
			proto = '';
		} else if (net.is_xray(iface)) {
			dest_port = null;
			if (!src_port) src_port = '0-65535';
			let xport = net.get_xray_traffic_port(iface);
			dest4 = 'tproxy ' + pkg.nft_ipv4_flag + ' to :' + xport + ' accept';
			dest6 = 'tproxy ' + pkg.nft_ipv6_flag + ' to :' + xport + ' accept';
		} else if (net.is_mwan4_strategy(iface)) {
			let strategy_data = get_interface(iface);
			let sname = strategy_data?.strategy_name;
			if (sname) {
				let schain = env.mwan4_strategy_chain[sname] || (pkg.mwan4_nft_prefix + '_strategy_' + sname);
				dest4 = 'goto ' + schain + '_ipv4';
				dest6 = 'goto ' + schain + '_ipv6';
			} else {
				process_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessUnknownFwmark', info: iface });
				return 1;
			}
		} else if (mark) {
			let chain_name = get_interface(iface).chain_name;
			if (index(chain_name, pkg.mwan4_nft_prefix) == 0) {
				dest4 = 'goto ' + chain_name + '_ipv4';
				dest6 = 'goto ' + chain_name + '_ipv6';
			} else {
				dest4 = 'goto ' + chain_name;
				dest6 = 'goto ' + chain_name;
			}
		} else if (iface == 'ignore') {
			dest4 = 'return';
			dest6 = 'return';
		} else {
			process_policy_error = true;
			push(state.errors, { code: 'errorPolicyProcessUnknownFwmark', info: iface });
			return 1;
		}
	
		if (!proto) {
			if (src_port || dest_port)
				proto = 'tcp udp';
			else
				proto = 'all';
		}
	
		let proto_list = split(proto, /\s+/);
		for (let proto_i in proto_list) {
			let param4 = '', param6 = '';
			let src_inline_set_ipv4_empty, src_inline_set_ipv6_empty;
			let dest_inline_set_ipv4_empty, dest_inline_set_ipv6_empty;
	
			if (proto_i == 'all') proto_i = '';
	
			if (proto_i && !net.is_supported_protocol(proto_i)) {
				process_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessUnknownProtocol', info: name + ": '" + proto_i + "'" });
				return 1;
			}
	
			if (src_addr) {
				let r = nft.classify_addr(src_addr, 'src', iface, uid, name, true);
				param4 = r.param4;
				param6 = r.param6;
				src_inline_set_ipv4_empty = r.empty4;
				src_inline_set_ipv6_empty = r.empty6;
			} else if (src_neg && (src_neg.n4 || src_neg.n6)) {
				// Exclusions with no positive source: suppress the family that
				// carries none of them, or its rule would match every packet.
				src_inline_set_ipv4_empty = !src_neg.n4;
				src_inline_set_ipv6_empty = !src_neg.n6;
			}
	
			if (dest_addr) {
				let r = nft.classify_addr(dest_addr, 'dst', iface, uid, name, true);
				param4 += (param4 ? ' ' : '') + r.param4;
				param6 += (param6 ? ' ' : '') + r.param6;
				dest_inline_set_ipv4_empty = r.empty4;
				dest_inline_set_ipv6_empty = r.empty6;
			} else if (dest_neg && (dest_neg.n4 || dest_neg.n6)) {
				dest_inline_set_ipv4_empty = !dest_neg.n4;
				dest_inline_set_ipv6_empty = !dest_neg.n6;
			}
	
			// An interface or MAC match (and an absent one) reads the same for
			// both families, so only one rule is emitted for it. A family-
			// specific exclusion breaks that: the IPv6 copy would carry no
			// exclusion and re-admit the very IPv4 packets the IPv4 copy just
			// filtered out. Pin each copy to its family before appending. An
			// empty positive match needs no guard: the family that carries no
			// exclusion is already suppressed above.
			let family_agnostic = (param4 == param6 && param4 != '');
			let neg4 = src_neg ? src_neg.n4 : '';
			let neg6 = src_neg ? src_neg.n6 : '';
			if (dest_neg) {
				if (dest_neg.n4) neg4 += (neg4 ? ' ' : '') + dest_neg.n4;
				if (dest_neg.n6) neg6 += (neg6 ? ' ' : '') + dest_neg.n6;
			}
			if (family_agnostic && neg4 != neg6) {
				param4 = 'meta nfproto ipv4' + (param4 ? ' ' + param4 : '');
				param6 = 'meta nfproto ipv6' + (param6 ? ' ' + param6 : '');
			}
			if (neg4) param4 += (param4 ? ' ' : '') + neg4;
			if (neg6) param6 += (param6 ? ' ' : '') + neg6;
	
			if (src_port) {
				let negation = '', value = src_port;
				if (substr(src_port, 0, 1) == '!') {
					negation = '!= ';
					value = substr(src_port, 1);
				}
				let port_param = (proto_i ? proto_i + ' ' : '') + 'sport ' + negation + '{ ' + V.inline_set(value) + ' }';
				param4 += (param4 ? ' ' : '') + port_param;
				param6 += (param6 ? ' ' : '') + port_param;
			}
	
			if (dest_port) {
				let negation = '', value = '' + dest_port;
				if (substr(value, 0, 1) == '!') {
					negation = '!= ';
					value = substr(value, 1);
				}
				let port_param = (proto_i ? proto_i + ' ' : '') + 'dport ' + negation + '{ ' + V.inline_set(value) + ' }';
				param4 += (param4 ? ' ' : '') + port_param;
				param6 += (param6 ? ' ' : '') + port_param;
			}
	
			let rule_params = cfg._nft_rule_params ? ' ' + cfg._nft_rule_params : '';
	
			if (net.is_tor(iface)) {
				let ipv4_error = false, ipv6_error = false;
				// Belt and braces. is_supported_interface() already rejects a
				// Tor policy on a box with no torrc, so this should be
				// unreachable -- but an empty port renders as 'redirect to :'
				// and nft rejects the ENTIRE file for it, taking every other
				// policy down with it. Never let one out of this function.
				if (!env.tor_dns_port || !env.tor_traffic_port) {
					process_policy_error = true;
					push(state.errors, { code: 'errorPolicyUnknownInterface', info: name });
					return 1;
				}
				chain = 'dstnat';
				let p4_base = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
					rule_params + ' meta nfproto ipv4 ' + param4;
				let p6_base = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
					rule_params + ' meta nfproto ipv6 ' + param6;
				let tor_rules = [
					'udp dport 53 redirect to :' + env.tor_dns_port + ' comment "Tor-DNS-UDP"',
					'tcp dport 80 redirect to :' + env.tor_traffic_port + ' comment "Tor-HTTP-TCP"',
					'udp dport 80 redirect to :' + env.tor_traffic_port + ' comment "Tor-HTTP-UDP"',
					'tcp dport 443 redirect to :' + env.tor_traffic_port + ' comment "Tor-HTTPS-TCP"',
					'udp dport 443 redirect to :' + env.tor_traffic_port + ' comment "Tor-HTTPS-UDP"',
				];
				for (let dest_rule in tor_rules) {
					if (!src_inline_set_ipv4_empty && !dest_inline_set_ipv4_empty) {
						if (!nft.nft4(p4_base + ' ' + dest_rule)) ipv4_error = true;
					}
					if (!src_inline_set_ipv6_empty && !dest_inline_set_ipv6_empty) {
						if (!nft.nft6(p6_base + ' ' + dest_rule)) ipv6_error = true;
					}
					if (cfg.ipv6_enabled && ipv4_error && ipv6_error) {
						process_policy_error = true;
						push(state.errors, { code: 'errorPolicyProcessInsertionFailed', info: name });
					} else if (!cfg.ipv6_enabled && ipv4_error) {
						process_policy_error = true;
						push(state.errors, { code: 'errorPolicyProcessInsertionFailedIpv4', info: name });
					}
				}
			} else {
				param4 = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
					(param4 ? ' ' + param4 : '') + rule_params + ' ' + (dest4 || '') + ' comment "' + name + '"';
				param6 = nft_insert + ' rule inet ' + nft_table + ' ' + nft_prefix + '_' + chain +
					(param6 ? ' ' + param6 : '') + rule_params + ' ' + (dest6 || '') + ' comment "' + name + '"';
	
				let ipv4_error = false, ipv6_error = false;
				if (pbr_nft_prev_param4 != param4 &&
					!src_inline_set_ipv4_empty && !dest_inline_set_ipv4_empty) {
					if (!nft.nft4(param4)) ipv4_error = true;
					pbr_nft_prev_param4 = param4;
				}
				if (pbr_nft_prev_param6 != param6 && param4 != param6 &&
					!src_inline_set_ipv6_empty && !dest_inline_set_ipv6_empty) {
					if (!nft.nft6(param6)) ipv6_error = true;
					pbr_nft_prev_param6 = param6;
				}
	
				if (cfg.ipv6_enabled && ipv4_error && ipv6_error) {
					process_policy_error = true;
					push(state.errors, { code: 'errorPolicyProcessInsertionFailed', info: name });
					push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param4 });
					push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param6 });
				} else if (!cfg.ipv6_enabled && ipv4_error) {
					process_policy_error = true;
					push(state.errors, { code: 'errorPolicyProcessInsertionFailedIpv4', info: name });
					push(state.errors, { code: 'errorPolicyProcessCMD', info: 'nft ' + param4 });
				}
			}
		}
	}
	
	// ── DNS Policy Process ──────────────────────────────────────────────
	
	function dns_policy_process(uid, enabled, name, src_addr, dest_dns, dest_dns_port) {
		if (enabled != '1') return 0;
		// The name reaches nft raw -- as the comment on every rule the policy
		// emits, on the sets it creates, and as the trailing comment on
		// dnsmasq's nftset lines. Sanitise it here, where it enters, rather
		// than at each of the dozen interpolations downstream; the errors and
		// log lines below then quote exactly what ends up in the ruleset.
		name = V.nft_comment(name);
	
		src_addr = replace(src_addr, /[,;{};]/g, ' ');
		dest_dns = replace(dest_dns, /[,;{}]/g, ' ');
	
		let j_parts = [];
		for (let i in split(src_addr || '', /\s+/)) {
			if (!i) continue;
			if (V.is_url(i)) i = platform.process_url(i, state.errors);
			push(j_parts, i);
		}
		src_addr = join(' ', j_parts);
	
		let dest_dns_interface = null, dest_dns_ipv4 = null, dest_dns_ipv6 = null;
		for (let v in split(trim('' + dest_dns), /\s+/)) {
			if (!dest_dns_interface && net.is_supported_interface(v)) dest_dns_interface = v;
			if (!dest_dns_ipv4 && V.is_ipv4(v)) dest_dns_ipv4 = v;
			if (!dest_dns_ipv6 && V.is_ipv6(v)) dest_dns_ipv6 = v;
		}
	
		// Record first v4 and first v6 DNS server from the interface; the
		// family decision is made later by the filter_options loop, which
		// knows the per-group family by construction. Avoids per-src_addr
		// is_family_mismatch (which expected one address per call).
		if (net.is_supported_interface(dest_dns_interface)) {
			let dns_list = config.uci_ctx('network').get('network', dest_dns_interface, 'dns');
			if (type(dns_list) == 'array') {
				for (let d in dns_list) {
					if (V.is_ipv4(d) && !dest_dns_ipv4) dest_dns_ipv4 = d;
					else if (V.is_ipv6(d) && !dest_dns_ipv6) dest_dns_ipv6 = d;
				}
			}
		}
	
		process_dns_policy_error = false;
		output.verbose.write("Routing '" + name + "' DNS to " + dest_dns + ':' + dest_dns_port + ' ');
	
		if (!src_addr) {
			push(state.errors, { code: 'errorPolicyNoSrcDest', info: name });
			output.fail(); return 1;
		}
		if (!dest_dns) {
			push(state.errors, { code: 'errorPolicyNoDns', info: name });
			output.fail(); return 1;
		}
	
		let filter_list = 'phys_dev mac_address domain ipv4 ipv6';
		let neg_list = 'phys_dev_negative mac_address_negative domain_negative ipv4_negative ipv6_negative';
		let src_neg = collect_negations(neg_list, src_addr, 'src', null, null, name, false);
		let has_positive = false;
		for (let fg in split(filter_list, /\s+/)) {
			let filtered = V.filter_options(fg, src_addr);
			if (!filtered) continue;
			has_positive = true;
			if (V.str_contains(fg, 'ipv4') && !dest_dns_ipv4) continue;
			if (V.str_contains(fg, 'ipv6') && !dest_dns_ipv6) continue;
			dns_policy_routing(name, filtered, dest_dns, uid, dest_dns_port, dest_dns_ipv4, dest_dns_ipv6, src_neg);
		}
		// Nothing but exclusions in src_addr: emit the single rule they describe,
		// 'every source but these'.
		if (!has_positive && (src_neg.n4 || src_neg.n6))
			dns_policy_routing(name, '', dest_dns, uid, dest_dns_port, dest_dns_ipv4, dest_dns_ipv6, src_neg);
	
		if (process_dns_policy_error) output.fail();
		else output.ok();
	}
	
	// ── Policy Process ──────────────────────────────────────────────────
	
	function policy_process(uid, enabled, name, interface_name, src_addr, src_port, dest_addr, dest_port, proto, chain) {
		if (enabled != '1') return 0;
		// The name reaches nft raw -- as the comment on every rule the policy
		// emits, on the sets it creates, and as the trailing comment on
		// dnsmasq's nftset lines. Sanitise it here, where it enters, rather
		// than at each of the dozen interpolations downstream; the errors and
		// log lines below then quote exactly what ends up in the ruleset.
		name = V.nft_comment(name);
	
		src_addr = replace(src_addr, /[,;{};]/g, ' ');
		src_port = replace(src_port, /[,;{}]/g, ' ');
		dest_addr = replace(dest_addr, /[,;{}]/g, ' ');
		dest_port = replace(dest_port, /[,;{}]/g, ' ');
	
		process_policy_error = false;
		proto = lc(proto || '');
		if (proto == 'auto' || proto == 'all') proto = '';
	
		output.verbose.write("Routing '" + name + "' via " + interface_name + ' ');
	
		if (!src_addr && !src_port && !dest_addr && !dest_port && !proto) {
			push(state.errors, { code: 'errorPolicyNoSrcDest', info: name });
			output.fail(); return 1;
		}
		if (!interface_name) {
			push(state.errors, { code: 'errorPolicyNoInterface', info: name });
			output.fail(); return 1;
		}
		// 'proto' is a PORT QUALIFIER, not a match of its own: it only ever
		// reaches a rule as a prefix on sport/dport. Set without a port it is
		// dropped and the policy routes every protocol; set to a protocol that
		// has no ports AND given a port it emits e.g. 'icmp dport { 53 }', which
		// nft refuses -- taking the entire ruleset, and all policy routing, with
		// it. The LuCI dropdown is built from /etc/protocols, so 41 of the 46
		// choices it offers are one or the other of those.
		if (proto) {
			for (let p in split(proto, /\s+/)) {
				if (!p) continue;
				// .info stays a single string: the procd emission below writes it
				// with json_add_string, so an array would reach the WebUI as
				// '[ "name", "proto" ]'.
				let who = "'" + name + "' (" + p + ")";
				// Why one warns and the other rejects: an ignored proto still
				// produces a VALID rule -- too broad, but the router keeps
				// routing, so the user can be told and left alone. A port on a
				// portless protocol produces a rule nft refuses, and the whole
				// file goes with it; warning about that would annotate an
				// outage rather than prevent one, so the policy is dropped and
				// every other one survives.
				if (net.proto_has_ports(p)) {
					if (!src_port && !dest_port)
						push(state.warnings, { code: 'warningPolicyProtoNoPort', info: who });
				} else if (src_port || dest_port) {
					push(state.errors, { code: 'errorPolicyProtoPortNotSupported', info: who });
					output.fail(); return 1;
				} else {
					push(state.warnings, { code: 'warningPolicyProtoPortless', info: who });
				}
			}
		}
		if (net.is_tor(interface_name)) {
			// Tor is a dstnat redirect, not a routed interface: the rules below
			// hardcode ports 53/80/443 and force the dstnat chain, so these
			// options are silently discarded (src_port additionally produces an
			// invalid rule). Warn rather than reject -- a dest_addr holding
			// ordinary resolvable domains is a legitimate Tor policy.
			//
			// History: these warnings were live from f532ad3 (2022-12-14) until
			// d2aba93 (2024-02-16) 'better TOR support in nft', which deleted the
			// dedicated policy_routing_tor_nft()/_iptables() helpers and folded
			// Tor into policy_routing(). The call sites went with those helpers
			// and were never re-added -- confirmed with the maintainer that this
			// was unintentional rather than a deliberate removal. The catalog
			// strings were left behind in pkg.uc and status.js, unreachable ever
			// since. Deliberately not restored verbatim: the old
			// warningTorUnsetParams also told users to unset src_addr, which that
			// same refactor turned into the correct way to match a Tor policy, so
			// its wording is now split per option.
			//
			// Deliberately NOT warned about: dest_addr, including '.onion'. A
			// domain dest_addr is a supported Tor policy and works whenever DNS
			// for the domain reaches Tor. pbr cannot see whether it does -- that
			// depends on dnsmasq, which on OpenWrt declares '.onion' local via
			// /usr/share/dnsmasq/rfc6761.conf -- so any such warning would fire
			// just as loudly on a correct setup as on a broken one. Documented
			// instead; see the Tor section of the README.
			if (src_port)
				push(state.warnings, { code: 'warningTorUnsetSrcPort', info: name });
			if (dest_port)
				push(state.warnings, { code: 'warningTorUnsetDestPort', info: name });
			if (proto)
				push(state.warnings, { code: 'warningTorUnsetProto', info: name });
			if (chain && lc(chain) != 'prerouting')
				push(state.warnings, { code: 'warningTorUnsetChainNft', info: name });
		}
		if (!net.is_supported_interface(interface_name) && !net.is_mwan4_strategy(interface_name)) {
			push(state.errors, { code: 'errorPolicyUnknownInterface', info: name });
			output.fail(); return 1;
		}
	
		let j_parts = [];
		for (let i in split(src_addr || '', /\s+/)) {
			if (!i) continue;
			if (V.is_url(i)) i = platform.process_url(i, state.errors);
			push(j_parts, i);
		}
		src_addr = join(' ', j_parts);
	
		j_parts = [];
		for (let i in split(dest_addr || '', /\s+/)) {
			if (!i) continue;
			if (V.is_url(i)) i = platform.process_url(i, state.errors);
			push(j_parts, i);
		}
		dest_addr = join(' ', j_parts);
	
		let filter_list_src = 'phys_dev mac_address domain ipv4 ipv6';
		let filter_list_dest = 'domain ipv4 ipv6';
		let neg_list_src = 'phys_dev_negative mac_address_negative domain_negative ipv4_negative ipv6_negative';
		let neg_list_dest = 'domain_negative ipv4_negative ipv6_negative';
		let processed_src = '', processed_dest = '';
	
		// One rule per positive group -- they are the policy's union of sources.
		let src_groups = [], dest_groups = [];
		for (let fg in split(filter_list_src, /\s+/)) {
			let fv = src_addr ? V.filter_options(fg, src_addr) : '';
			if (!fv) continue;
			push(src_groups, { fg, fv });
			processed_src += (processed_src ? ' ' : '') + fv;
		}
		for (let fg in split(filter_list_dest, /\s+/)) {
			let fv = dest_addr ? V.filter_options(fg, dest_addr) : '';
			if (!fv) continue;
			push(dest_groups, { fg, fv });
			processed_dest += (processed_dest ? ' ' : '') + fv;
		}
	
		// The exclusions ride along on each of those rules instead of getting
		// rules of their own.
		let src_neg = collect_negations(neg_list_src, src_addr, 'src', interface_name, uid, name, true);
		let dest_neg = collect_negations(neg_list_dest, dest_addr, 'dst', interface_name, uid, name, true);
		if (src_neg.matched) processed_src += (processed_src ? ' ' : '') + src_neg.matched;
		if (dest_neg.matched) processed_dest += (processed_dest ? ' ' : '') + dest_neg.matched;
	
		// No positive entries of a given side (none configured, or nothing but
		// exclusions) still yields one rule for that side, carrying whatever
		// exclusions it has.
		if (!length(src_groups)) push(src_groups, { fg: 'none', fv: '' });
		if (!length(dest_groups)) push(dest_groups, { fg: 'none', fv: '' });
	
		// ucode's for-in yields an array's values, not its indices, so each of
		// these is the { fg, fv } pushed above.
		for (let src_group in src_groups) {
			for (let dest_group in dest_groups) {
				if (V.str_contains(src_group.fg, 'ipv4') && V.str_contains(dest_group.fg, 'ipv6')) continue;
				if (V.str_contains(src_group.fg, 'ipv6') && V.str_contains(dest_group.fg, 'ipv4')) continue;
				policy_routing(name, interface_name, src_group.fv, src_port, dest_group.fv, dest_port,
					proto, chain, uid, src_neg, dest_neg);
			}
		}
	
		for (let i in split(src_addr || '', /\s+/)) {
			if (i && !V.str_contains(processed_src, i)) {
				process_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessUnknownEntry', info: name + ': ' + i });
			}
		}
		for (let i in split(dest_addr || '', /\s+/)) {
			if (i && !V.str_contains(processed_dest, i)) {
				process_policy_error = true;
				push(state.errors, { code: 'errorPolicyProcessUnknownEntry', info: name + ': ' + i });
			}
		}
	
		if (process_policy_error) output.fail();
		else output.ok();
	}
	
	// ── Interface Routing ───────────────────────────────────────────────
	
	let interface_routing = {};

	interface_routing.create = function(tid, mark, iface, gw4, dev4, gw6, dev6, priority) {
		if (!tid || !mark || !iface) {
			push(state.errors, { code: 'errorInterfaceRoutingEmptyValues' });
			return 1;
		}
		let readfile = _fs.readfile;
		let writefile = _fs.writefile;
		let nft_table = pkg.nft_table;
		let nft_prefix = pkg.nft_prefix;
		let rule_params = cfg._nft_rule_params ? ' ' + cfg._nft_rule_params : '';
		let ipv4_error = 1, ipv6_error = 1;

		if (net.is_netifd_interface(iface) || net.is_mwan4_interface(iface))
			return 0;
		let table_iface = iface;
		if (net.is_split_uplink() && iface == cfg.uplink_interface6)
			table_iface = cfg.uplink_interface4;

		let rt_content = readfile(pkg.rt_tables_file) || '';
		if (index(rt_content, tid + ' ' + pkg.ip_table_prefix + '_' + table_iface) < 0) {
			let lines = split(rt_content, '\n');
			let new_lines = [];
			for (let l in lines) {
				if (l != '' && index(l, pkg.ip_table_prefix + '_' + table_iface) < 0)
					push(new_lines, l);
			}
			push(new_lines, tid + ' ' + pkg.ip_table_prefix + '_' + table_iface);
			writefile(pkg.rt_tables_file, join('\n', new_lines) + '\n');
			sh.run('sync');
		}

		// Always create the nft mark chain so policies can reference it
		// even when the interface device is not yet available (e.g. a down WireGuard tunnel)
		let idata = get_interface(iface);
		nft.ensure_mark_chain(mark, idata.chain_name);

		let dscp = config.uci_ctx(pkg.name).get(pkg.name, 'config', iface + '_dscp') || '0';
		if (+dscp >= 1 && +dscp <= 63) {
			nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_prerouting ' +
				pkg.nft_ipv4_flag + ' dscp ' + dscp + rule_params + ' goto ' + idata.chain_name);
			if (cfg.ipv6_enabled)
				nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_prerouting ' +
					pkg.nft_ipv6_flag + ' dscp ' + dscp + rule_params + ' goto ' + idata.chain_name);
		}
		if (iface == cfg.icmp_interface) {
			nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_output ' +
				pkg.nft_ipv4_flag + ' protocol icmp' + rule_params + ' goto ' + idata.chain_name);
			if (cfg.ipv6_enabled)
				nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_output ' +
					pkg.nft_ipv6_flag + ' nexthdr icmpv6' + rule_params + ' goto ' + idata.chain_name);
		}

		if (dev4) {
			ipv4_error = 0;
			sh.run(pkg.ip_full + ' -4 rule flush table ' + tid);
			sh.run(pkg.ip_full + ' -4 route flush table ' + tid);
			if (gw4 || cfg.strict_enforcement) {
				if (gw4)
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'via', gw4, 'dev', dev4, 'table', tid) ? 0 : 1;
				else if (net.is_p2p(dev4))
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'dev', dev4, 'table', tid) ? 0 : 1;
				else
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv4_error = 1;
			} else if (net.is_p2p(dev4)) {
				ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'dev', dev4, 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv4_error = 1;
			}
		} else if (cfg.strict_enforcement && !(net.is_split_uplink() && net.is_uplink6(iface))) {
			ipv4_error = 0;
			sh.run(pkg.ip_full + ' -4 rule flush table ' + tid);
			sh.run(pkg.ip_full + ' -4 route flush table ' + tid);
			ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
			if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
				ipv4_error = 1;
		}

		if (cfg.ipv6_enabled && dev6) {
			ipv6_error = 0;
			sh.run(pkg.ip_full + ' -6 rule flush table ' + tid);
			sh.run(pkg.ip_full + ' -6 route flush table ' + tid);
			if (gw6 || cfg.strict_enforcement) {
				if (gw6)
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'via', gw6, 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				else if (net.is_p2p(dev6))
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				else
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv6_error = 1;
			} else if (net.is_p2p(dev6)) {
				ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv6_error = 1;
			}
		} else if (cfg.ipv6_enabled && cfg.strict_enforcement && !(net.is_split_uplink() && net.is_uplink4(iface))) {
			ipv6_error = 0;
			sh.run(pkg.ip_full + ' -6 rule flush table ' + tid);
			sh.run(pkg.ip_full + ' -6 route flush table ' + tid);
			ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
			if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
				ipv6_error = 1;
		}

		return (ipv4_error == 0 || ipv6_error == 0) ? 0 : 1;
	};

	interface_routing.create_user_set = function(iface, mark) {
		if (!iface || !mark) {
			push(state.errors, { code: 'errorInterfaceRoutingEmptyValues' });
			return 1;
		}
		let s = 0;
		nft.nftset.create_user(iface, 'dst', 'ip', 'user', '', mark) || (s = 1);
		nft.nftset.create_user(iface, 'src', 'ip', 'user', '', mark) || (s = 1);
		nft.nftset.create_user(iface, 'src', 'mac', 'user', '', mark) || (s = 1);
		return s;
	};

	interface_routing.destroy = function(tid, iface, priority) {
		if (!tid || !iface) {
			push(state.errors, { code: 'errorInterfaceRoutingEmptyValues' });
			return 1;
		}
		let readfile = _fs.readfile;
		let writefile = _fs.writefile;
		if (net.is_netifd_interface(iface) || net.is_mwan4_interface(iface)) return 0;
		sh.run(pkg.ip_full + ' -4 rule del table main prio ' + (+priority - 1000));
		sh.run(pkg.ip_full + ' -4 rule del table ' + tid + ' prio ' + priority);
		sh.run(pkg.ip_full + ' -6 rule del table main prio ' + (+priority - 1000));
		sh.run(pkg.ip_full + ' -6 rule del table ' + tid + ' prio ' + priority);
		sh.run(pkg.ip_full + ' -4 rule flush table ' + tid);
		sh.run(pkg.ip_full + ' -4 route flush table ' + tid);
		sh.run(pkg.ip_full + ' -6 rule flush table ' + tid);
		sh.run(pkg.ip_full + ' -6 route flush table ' + tid);
		let table_iface = iface;
		if (net.is_split_uplink() && iface == cfg.uplink_interface6)
			table_iface = cfg.uplink_interface4;
		let rt = readfile(pkg.rt_tables_file) || '';
		let lines = split(rt, '\n');
		let new_lines = [];
		for (let l in lines) {
			if (l != '' && index(l, pkg.ip_table_prefix + '_' + table_iface) < 0)
				push(new_lines, l);
		}
		writefile(pkg.rt_tables_file, join('\n', new_lines) + '\n');
		sh.run('sync');
		return 0;
	};

	interface_routing.reload = function(tid, mark, iface, gw4, dev4, gw6, dev6, priority) {
		if (!tid || !mark || !iface) {
			push(state.errors, { code: 'errorInterfaceRoutingEmptyValues' });
			return 1;
		}
		let ipv4_error = 1, ipv6_error = 1;
		if (net.is_netifd_interface(iface) || net.is_mwan4_interface(iface)) return 0;
		if (dev4) {
			ipv4_error = 0;
			sh.run(pkg.ip_full + ' -4 rule flush fwmark ' + sh.quote(mark + '/' + cfg.fw_mask) + ' table ' + tid);
			sh.ip('-4', 'route', 'flush', 'table', tid);
			if (gw4 || cfg.strict_enforcement) {
				if (gw4)
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'via', gw4, 'dev', dev4, 'table', tid) ? 0 : 1;
				else if (net.is_p2p(dev4))
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'dev', dev4, 'table', tid) ? 0 : 1;
				else
					ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv4_error = 1;
			} else if (net.is_p2p(dev4)) {
				ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'default', 'dev', dev4, 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv4_error = 1;
			}
		} else if (cfg.strict_enforcement && !(net.is_split_uplink() && net.is_uplink6(iface))) {
			ipv4_error = 0;
			sh.run(pkg.ip_full + ' -4 rule flush fwmark ' + sh.quote(mark + '/' + cfg.fw_mask) + ' table ' + tid);
			sh.ip('-4', 'route', 'flush', 'table', tid);
			ipv4_error = sh.try_cmd(state.errors, pkg.ip_full, '-4', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
			if (sh.try_ip(state.errors, '-4', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
				ipv4_error = 1;
		}
		if (cfg.ipv6_enabled && dev6) {
			ipv6_error = 0;
			sh.run(pkg.ip_full + ' -6 rule flush fwmark ' + sh.quote(mark + '/' + cfg.fw_mask) + ' table ' + tid);
			sh.ip('-6', 'route', 'flush', 'table', tid);
			if (gw6 || cfg.strict_enforcement) {
				if (gw6)
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'via', gw6, 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				else if (net.is_p2p(dev6))
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				else
					ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
				if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv6_error = 1;
			} else if (net.is_p2p(dev6)) {
				ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'default', 'dev', dev6, 'table', tid, 'metric', cfg.uplink_interface6_metric) ? 0 : 1;
				if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
					ipv6_error = 1;
			}
		} else if (cfg.ipv6_enabled && cfg.strict_enforcement && !(net.is_split_uplink() && net.is_uplink4(iface))) {
			ipv6_error = 0;
			sh.run(pkg.ip_full + ' -6 rule flush fwmark ' + sh.quote(mark + '/' + cfg.fw_mask) + ' table ' + tid);
			sh.ip('-6', 'route', 'flush', 'table', tid);
			ipv6_error = sh.try_cmd(state.errors, pkg.ip_full, '-6', 'route', 'replace', 'unreachable', 'default', 'table', tid) ? 0 : 1;
			if (sh.try_ip(state.errors, '-6', 'rule', 'replace', 'fwmark', mark + '/' + cfg.fw_mask, 'table', tid, 'priority', priority) != true)
				ipv6_error = 1;
		}
		return (ipv4_error == 0 || ipv6_error == 0) ? 0 : 1;
	};

	
	// ── Enumerate Interfaces ────────────────────────────────────────────
	
	// The mark chain's name is derived from the mark, so the two must be kept in
	// step: an interface whose mark is reassigned after the name was built ends up
	// naming another interface's chain, or one nobody creates. Deriving both from
	// here makes that structural rather than something each branch remembers.
	//
	// 'mark' is a '0x%06x' string. Every caller is already guaranteed one: it is
	// either iface_mark, built by sprintf() below, or a netifd/mwan4 mark reached
	// only through a branch that has tested it for truth. No coercion or fallback
	// here on purpose -- a sentinel name would be created by nobody and routed to
	// by nothing, turning a loud failure into the silent misroute this exists to
	// prevent.
	function mark_chain_name(mark) {
		return pkg.nft_prefix + '_mark_' + mark;
	}

	function interface_enumerate() {
		config.uci_ctx('network', true);
	
		let iface_mark = sprintf('0x%06x', hex(cfg.uplink_mark));
		let _iface_priority = cfg.uplink_ip_rules_priority;
		let _uplink_mark = '';
		let _uplink_priority = '';
	
		ifaces_triggers = '';
	
		config.uci_ctx('network').foreach('network', 'interface', function(s) {
			let iface = s['.name'];
	
			if (!net.is_supported_interface(iface)) return;
			if (hex(iface_mark) > hex(cfg.fw_mask)) {
				push(state.errors, { code: 'errorInterfaceMarkOverflow', info: iface });
				return;
			}
			if (+_iface_priority <= 0) {
				push(state.errors, { code: 'errorInterfacePriorityExhausted', info: iface });
				return;
			}
	
			let dev4 = net.network_get_device(iface);
			if (!dev4) dev4 = net.network_get_physdev(iface);
			if (!dev4) dev4 = net.uci_get_device(iface);
			let dev6 = null;
			if (net.is_uplink4(iface) && cfg.uplink_interface6) {
				dev6 = net.network_get_device(cfg.uplink_interface6);
				if (!dev6) dev6 = net.network_get_physdev(cfg.uplink_interface6);
			}
			if (!dev6) dev6 = dev4;
	
			let _mark = iface_mark;
			let _chain_name = mark_chain_name(_mark);
			let _priority = _iface_priority;
			let split_uplink_second = false;
	
			if (net.is_netifd_interface(iface) && env.netifd_mark[iface]) {
				_mark = env.netifd_mark[iface];
				_chain_name = mark_chain_name(_mark);
			} else if (net.is_mwan4_interface(iface) && env.mwan4_mark[iface]) {
				_mark = env.mwan4_mark[iface];
				_chain_name = env.mwan4_interface_chain[iface];
			} else if (net.is_split_uplink()) {
				if (net.is_uplink4(iface) || net.is_uplink6(iface)) {
					if (_uplink_mark && _uplink_priority) {
						_mark = _uplink_mark;
						// The chain name is derived from the mark above, so it
						// has to follow the mark here as it does in the netifd
						// and mwan4 branches. Left stale, the second uplink
						// names the chain of whichever interface really owns
						// the mark it no longer uses -- silently routing its
						// traffic out that interface -- or, when no interface
						// owns it, names a chain nobody creates, which fails
						// the ruleset check and installs nothing at all.
						_chain_name = mark_chain_name(_mark);
						_priority = _uplink_priority;
						split_uplink_second = true;
					} else {
						_uplink_mark = iface_mark;
						_uplink_priority = _iface_priority;
					}
				}
			}
	
			set_interface(iface, {
				mark: _mark, priority: _priority,
				chain_name: _chain_name,
				device_ipv4: dev4 || '', device_ipv6: dev6 || '',
				gateway_ipv4: '', gateway_ipv6: '',
				is_default: false,
			});
	
			if (!net.is_netifd_interface(iface) && !net.is_mwan4_interface(iface))
				ifaces_triggers += (ifaces_triggers ? ' ' : '') + iface;
	
			if (!split_uplink_second) {
				iface_mark = sprintf('0x%06x', hex(iface_mark) + hex(cfg.uplink_mark));
				_iface_priority = '' + (+_iface_priority - 1);
			}
		});
	
		iface_priority = _iface_priority;
	}

	// ── Enumerate mwan4 Strategies ──────────────────────────────────────
	// Register each detected mwan4 strategy as a synthetic iface_registry
	// entry so that policies targeting `mwan4_strategy_<name>` can resolve
	// in policy_routing(). Strategies don't own a routing table, mark, or
	// priority — mwan4's own chain handles the actual route decision —
	// so this entry is metadata only. The `action: 'mwan4_strategy'` flag
	// makes status/gateway summaries skip these entries.
	function strategy_enumerate() {
		for (let sname in keys(env.mwan4_strategy_chain)) {
			set_interface('mwan4_strategy_' + sname, {
				action: 'mwan4_strategy',
				strategy_name: sname,
				chain_name: env.mwan4_strategy_chain[sname],
				mark: '', priority: '',
				device_ipv4: '', device_ipv6: '',
				gateway_ipv4: '', gateway_ipv6: '',
				is_default: false,
			});
		}
	}

	// ── Resolve TID ─────────────────────────────────────────────────────
	
	function interface_resolve_tid(iface) {
		let tid = nft.get_rt_tables_id(iface);
		if (!tid && net.is_split_uplink() && (net.is_uplink4(iface) || net.is_uplink6(iface))) {
			let other = net.is_uplink4(iface) ? cfg.uplink_interface6 : cfg.uplink_interface4;
			let other_data = get_interface(other);
			if (other_data?.tid) tid = other_data.tid;
		}
		if (!tid) tid = nft.get_rt_tables_next_id();
		return tid;
	}
	
	// ── Process Interface ───────────────────────────────────────────────
	
	let interface_process = {};

	interface_process._get_tor_dns_port = function() {
		let content = _fs.readfile(pkg.tor_config_file);
		if (type(content) != 'string' || !content) return '9053';
		let m = match(content, /DNSPort\s+\S+:(\d+)/);
		return m ? m[1] : '9053';
	};

	interface_process._get_tor_traffic_port = function() {
		let content = _fs.readfile(pkg.tor_config_file);
		if (type(content) != 'string' || !content) return '9040';
		let m = match(content, /TransPort\s+\S+:(\d+)/);
		return m ? m[1] : '9040';
	};

	interface_process.create_global_rules = function() {
		let prio = '' + iface_priority;
		let priority_exhausted = false;
		config.uci_ctx('network').foreach('network', 'interface', function(s_iface) {
			let name = s_iface['.name'];
			if (net.is_wg_server(name) && !net.is_ignored_interface(name)) {
				let disabled = config.uci_ctx('network').get('network', name, 'disabled');
				let listen_port = config.uci_ctx('network').get('network', name, 'listen_port');
				if (disabled != '1' && listen_port) {
					if (cfg.uplink_interface4) {
						if (+prio <= 0) {
							if (!priority_exhausted) {
								push(state.errors, { code: 'errorInterfacePriorityExhausted', info: name });
								priority_exhausted = true;
							}
							return;
						}
						let tbl = pkg.ip_table_prefix + '_' + cfg.uplink_interface4;
						system(pkg.ip_full + ' -4 rule del sport ' + sh.quote(listen_port) + ' table ' + sh.quote(tbl) + ' priority ' + sh.quote(prio) + ' 2>/dev/null');
						sh.ip('-4', 'rule', 'add', 'sport', listen_port, 'table', tbl, 'priority', prio);
						if (cfg.ipv6_enabled) {
							system(pkg.ip_full + ' -6 rule del sport ' + sh.quote(listen_port) + ' table ' + sh.quote(tbl) + ' priority ' + sh.quote(prio) + ' 2>/dev/null');
							sh.ip('-6', 'rule', 'add', 'sport', listen_port, 'table', tbl, 'priority', prio);
						}
						prio = '' + (+prio - 1);
					}
				}
			}
		});
		// prio may have been left at <= 0 by the exhaustion guard above: never
		// issue an 'ip rule' at priority 0, it collides with the kernel's own
		// 'from all lookup local' rule (see 12b993766718). Bail out the same
		// way the tail of this function does: iface_priority stays a string,
		// and the returned 0 is unused, the sole caller ignores it.
		if (+prio <= 0) {
			if (!priority_exhausted)
				push(state.errors, { code: 'errorInterfacePriorityExhausted', info: pkg.name });
			iface_priority = prio;
			return 0;
		}
		system(pkg.ip_full + ' -4 rule del priority ' + sh.quote(prio) + ' 2>/dev/null');
		system(pkg.ip_full + ' -4 rule del lookup main suppress_prefixlength ' + sh.quote(cfg.prefixlength) + ' 2>/dev/null');
		sh.try_cmd(state.errors, pkg.ip_full, '-4', 'rule', 'add', 'lookup', 'main', 'suppress_prefixlength',
			'' + cfg.prefixlength, 'pref', prio);
		if (cfg.ipv6_enabled) {
			system(pkg.ip_full + ' -6 rule del priority ' + sh.quote(prio) + ' 2>/dev/null');
			system(pkg.ip_full + ' -6 rule del lookup main suppress_prefixlength ' + sh.quote(cfg.prefixlength) + ' 2>/dev/null');
			sh.try_cmd(state.errors, pkg.ip_full, '-6', 'rule', 'add', 'lookup', 'main', 'suppress_prefixlength',
				'' + cfg.prefixlength, 'pref', prio);
		}
		iface_priority = prio;
		return 0;
	};

	interface_process.tor = function(action) {
		switch (action) {
		case 'create':
		case 'reload':
		case 'reload_interface':
			env.tor_dns_port = interface_process._get_tor_dns_port();
			env.tor_traffic_port = interface_process._get_tor_traffic_port();
			set_interface('tor', {
				device_ipv4: '', device_ipv6: '',
				gateway_ipv4: '53->' + env.tor_dns_port,
				gateway_ipv6: '80,443->' + env.tor_traffic_port,
				is_default: false, action: action,
			});
			break;
		}
		return 0;
	};

	// Build the "GW4[/GW6]" display suffix. IPv4 falls back to 0.0.0.0,
	// IPv6 to ::0 ; the IPv6 segment is omitted when IPv6 is disabled
	function disp_gw_suffix(dg4, dg6) {
		let s = dg4 || '0.0.0.0';
		if (cfg.ipv6_enabled)
			s += '/' + (dg6 || '::0');
		return s;
	}

	interface_process.create = function(iface) {
		let existing = get_interface(iface);
		if (!existing) return 0;
		let _mark = existing.mark;
		let _priority = existing.priority;
		let dev4 = existing.device_ipv4;
		let dev6 = existing.device_ipv6;

		let _tid = interface_resolve_tid(iface);
		let gw4 = net.get_gateway4(iface, dev4, state.warnings);
		let gw6 = net.get_gateway6(iface, dev6, state.warnings);
		// Fall back to the interface's own address for display when there is
		// no gateway (e.g. point-to-point links). Computed before split-uplink
		// clearing so the display reflects the interface's real addresses.
		let ipa4 = net.get_ipaddr4(iface, dev4);
		let ipa6 = net.get_ipaddr6(iface, dev6);
		let dg4 = gw4 || ipa4 || '';
		let dg6 = gw6 || ipa6 || '';
		if (net.is_split_uplink()) {
			if (net.is_uplink4(iface)) { gw6 = ''; dev6 = ''; }
			else if (net.is_uplink6(iface)) { gw4 = ''; dev4 = ''; }
		}
		let disp_dev = (iface != dev4) ? dev4 : '';
		let disp_status = '';
		if (net.is_default_dev(dev4))
			disp_status = (cfg.verbosity == '1') ? sym.ok[0] : sym.ok[1];
		if (net.is_netifd_interface_default(iface))
			disp_status = (cfg.verbosity == '1') ? sym.okb[0] : sym.okb[1];
		let display_text = iface + '/' + (disp_dev ? disp_dev + '/' : '') + disp_gw_suffix(dg4, dg6);
		output.verbose.write("Setting up routing for '" + display_text + "' ");
		if (interface_routing.create(_tid, _mark, iface, gw4, dev4, gw6, dev6, _priority) == 0) {
			set_interface(iface, {
				tid: _tid, mark: _mark, priority: _priority,
				chain_name: existing.chain_name,
				device_ipv4: dev4 || '', device_ipv6: dev6 || '',
				gateway_ipv4: dg4, gateway_ipv6: dg6,
				is_default: disp_status ? true : false,
				status_symbol: disp_status, action: 'create',
			});
			if (net.is_netifd_interface(iface)) output.okb();
			else output.ok();
		} else {
			push(state.errors, { code: 'errorFailedSetup', info: display_text });
			output.fail();
		}
		return 0;
	};

	interface_process.create_user_set = function(iface) {
		let existing = get_interface(iface);
		if (!existing) return 0;
		let _mark = existing.mark;
		let _priority = existing.priority;
		let dev4 = existing.device_ipv4;
		let dev6 = existing.device_ipv6;
		let _tid = interface_resolve_tid(iface);
		if (net.is_split_uplink()) {
			if (net.is_uplink4(iface)) dev6 = '';
			else if (net.is_uplink6(iface)) dev4 = '';
		}
		interface_routing.create_user_set(iface, _mark);
		return 0;
	};

	interface_process.destroy = function(iface) {
		if (net.is_wg_server(iface) && !net.is_ignored_interface(iface)) {
			let lp = config.uci_ctx('network').get('network', iface, 'listen_port');
			if (lp) {
				sh.ip('-4', 'rule', 'del', 'sport', lp, 'table', 'pbr_' + cfg.uplink_interface4);
				sh.ip('-6', 'rule', 'del', 'sport', lp, 'table', 'pbr_' + cfg.uplink_interface4);
			}
		}
		let existing = get_interface(iface);
		if (!existing) return 0;
		let _mark = existing.mark;
		let _priority = existing.priority;
		let dev4 = existing.device_ipv4;
		let dev6 = existing.device_ipv6;
		let _tid = interface_resolve_tid(iface);
		if (net.is_split_uplink()) {
			if (net.is_uplink4(iface)) dev6 = '';
			else if (net.is_uplink6(iface)) dev4 = '';
		}
		let disp_dev = (iface != dev4) ? dev4 : '';
		let display_text = iface + '/' + (disp_dev ? disp_dev : '');
		output.verbose.write("Removing routing for '" + display_text + "' ");
		interface_routing.destroy(_tid, iface, _priority);
		if (net.is_netifd_interface(iface)) output.okb();
		else output.ok();
		return 0;
	};

	interface_process.reload = function(iface) {
		let existing = get_interface(iface);
		if (!existing) return 0;
		let _mark = existing.mark;
		let _priority = existing.priority;
		let dev4 = existing.device_ipv4;
		let dev6 = existing.device_ipv6;
		let _tid = interface_resolve_tid(iface);
		let gw4 = net.get_gateway4(iface, dev4, state.warnings);
		let gw6 = net.get_gateway6(iface, dev6, state.warnings);
		let ipa4 = net.get_ipaddr4(iface, dev4);
		let ipa6 = net.get_ipaddr6(iface, dev6);
		let dg4 = gw4 || ipa4 || '';
		let dg6 = gw6 || ipa6 || '';
		if (net.is_split_uplink()) {
			if (net.is_uplink4(iface)) { gw6 = ''; dev6 = ''; }
			else if (net.is_uplink6(iface)) { gw4 = ''; dev4 = ''; }
		}
		let disp_dev = (iface != dev4) ? dev4 : '';
		let disp_status = '';
		if (net.is_default_dev(dev4))
			disp_status = (cfg.verbosity == '1') ? sym.ok[0] : sym.ok[1];
		if (net.is_netifd_interface_default(iface))
			disp_status = (cfg.verbosity == '1') ? sym.okb[0] : sym.okb[1];
		set_interface(iface, {
			tid: _tid, mark: _mark, priority: _priority,
			chain_name: existing.chain_name,
			device_ipv4: dev4 || '', device_ipv6: dev6 || '',
			gateway_ipv4: dg4, gateway_ipv6: dg6,
			is_default: disp_status ? true : false,
			status_symbol: disp_status, action: 'reload',
		});
		return 0;
	};

	interface_process.reload_interface = function(iface, reloaded_iface) {
		let existing = get_interface(iface);
		if (!existing) return 0;
		let _mark = existing.mark;
		let _priority = existing.priority;
		let dev4 = existing.device_ipv4;
		let dev6 = existing.device_ipv6;
		let _tid = interface_resolve_tid(iface);
		let gw4 = net.get_gateway4(iface, dev4, state.warnings);
		let gw6 = net.get_gateway6(iface, dev6, state.warnings);
		let ipa4 = net.get_ipaddr4(iface, dev4);
		let ipa6 = net.get_ipaddr6(iface, dev6);
		let dg4 = gw4 || ipa4 || '';
		let dg6 = gw6 || ipa6 || '';
		if (net.is_split_uplink()) {
			if (net.is_uplink4(iface)) { gw6 = ''; dev6 = ''; }
			else if (net.is_uplink6(iface)) { gw4 = ''; dev4 = ''; }
		}
		let disp_dev = (iface != dev4) ? dev4 : '';
		let disp_status = '';
		if (net.is_default_dev(dev4))
			disp_status = (cfg.verbosity == '1') ? sym.ok[0] : sym.ok[1];
		if (net.is_netifd_interface_default(iface))
			disp_status = (cfg.verbosity == '1') ? sym.okb[0] : sym.okb[1];
		if (iface == reloaded_iface) {
			let ri_text = iface + '/' + (disp_dev ? disp_dev + '/' : '') + disp_gw_suffix(dg4, dg6);
			output.verbose.write("Reloading routing for '" + ri_text + "' ");
			if (interface_routing.reload(_tid, _mark, iface, gw4, dev4, gw6, dev6, _priority) == 0) {
				set_interface(iface, {
					tid: _tid, mark: _mark, priority: _priority,
					chain_name: existing.chain_name,
					device_ipv4: dev4 || '', device_ipv6: dev6 || '',
					gateway_ipv4: dg4, gateway_ipv6: dg6,
					is_default: disp_status ? true : false,
					status_symbol: disp_status, action: 'reload_interface',
				});
				if (net.is_netifd_interface(iface)) output.okb();
				else output.ok();
			} else {
				push(state.errors, { code: 'errorFailedReload', info: ri_text });
				output.fail();
			}
		} else {
			set_interface(iface, {
				tid: _tid, mark: _mark, priority: _priority,
				chain_name: existing.chain_name,
				device_ipv4: dev4 || '', device_ipv6: dev6 || '',
				gateway_ipv4: dg4, gateway_ipv6: dg6,
				is_default: disp_status ? true : false,
				status_symbol: disp_status, action: 'skip_interface',
			});
		}
		return 0;
	};

	
	// ── User File Process ───────────────────────────────────────────────
	
	function user_file_process(enabled, path) {
		let readfile = _fs.readfile;
		let writefile = _fs.writefile;
		let stat = _fs.stat;
		let unlink = _fs.unlink;
	
		let _is_bad_user_file_nft_call = function(filepath) {
			let content = readfile(filepath) || '';
			return index(content, '"$nft" list') >= 0 || index(content, '"$nft" -f') >= 0;
		};
	
		let _user_file_process_sh = function(path) {
			if (sh.run('/bin/sh -n ' + sh.quote(path)) != 0) {
				push(state.errors, { code: 'errorUserFileSyntax', info: path });
				output.fail();
				return 1;
			}
			if (_is_bad_user_file_nft_call(path)) {
				push(state.errors, { code: 'errorIncompatibleUserFile', info: path });
				output.fail();
				return 1;
			}
			let nft_capture = '/var/run/pbr.nft.user';
			let wrapper_path = '/var/run/pbr.user_wrapper.sh';
			unlink(nft_capture);
			writefile(wrapper_path,
				'nft() { printf "%s\\n" "$*" >> ' + sh.quote(nft_capture) + '; }\n' +
				'. ' + sh.quote(path) + '\n');
			let rc = sh.run('. ' + sh.quote(wrapper_path));
			let captured = readfile(nft_capture) || '';
			for (let line in split(captured, '\n')) {
				if (line) nft.nft_add(line);
			}
			unlink(nft_capture);
			unlink(wrapper_path);
			if (rc != 0) {
				push(state.errors, { code: 'errorUserFileRunning', info: path });
				let content = readfile(path) || '';
				if (index(content, 'curl') >= 0 && !sh.is_present('curl'))
					push(state.errors, { code: 'errorUserFileNoCurl', info: path });
				output.fail();
				return 1;
			}
			output.ok();
			return 0;
		};
	
		let _user_file_process_uc = function(path) {
			let _unsafe = false;
			let _pending = [];
			let _nft_validate = function(rule_line) {
				if (!rule_line) return false;
				if (!match(rule_line, /^(add|insert|create)\s/)) {
					_unsafe = true;
					return false;
				}
				return true;
			};
			let api = {
				compat: +pkg.compat,
				table: 'inet ' + pkg.nft_table,
				nft: function(rule_line) {
					if (_nft_validate(rule_line))
						push(_pending, rule_line);
				},
				nft4: function(rule_line) {
					if (_nft_validate(rule_line))
						push(_pending, rule_line);
				},
				nft6: function(rule_line) {
					if (cfg.ipv6_enabled && _nft_validate(rule_line))
						push(_pending, rule_line);
				},
				download: function(url) {
					let dl = platform.get_downloader();
					let tmp = sh.exec('mktemp -q -t ' + sh.quote(pkg.name + '_user.XXXXXXXX'));
					if (!tmp || !stat(tmp)) return null;
					let rc = sh.run(dl.command + ' ' + sh.quote(url) + ' ' + dl.flag + ' ' + sh.quote(tmp));
					if (rc != 0) { unlink(tmp); return null; }
					let content = readfile(tmp) || '';
					unlink(tmp);
					return content || null;
				},
				marking_chain: function(iface) {
					let data = get_interface(iface);
					return data?.chain_name || null;
				},
				strategy_chain: function(strategy) {
					return env.mwan4_strategy_chain[strategy] || null;
				},
				nftset: function(iface, family) {
					return nft.get_set_name(iface, family, 'dst', 'ip', 'user');
				},
			};
			let code = readfile(path);
			if (!code) {
				push(state.errors, { code: 'errorUserFileRunning', info: path });
				output.fail();
				return 1;
			}
			let fn = loadstring('' + code);
			if (!fn) {
				push(state.errors, { code: 'errorUserFileSyntax', info: path });
				output.fail();
				return 1;
			}
			let result;
			try { result = fn(); } catch (e) {
				push(state.errors, { code: 'errorUserFileRunning', info: path + ': ' + e });
				output.fail();
				return 1;
			}
			try {
				if (type(result) == 'function')
					result(api);
				else if (type(result) == 'object' && type(result?.run) == 'function')
					result.run(api);
			} catch (e) {
				push(state.errors, { code: 'errorUserFileRunning', info: path + ': ' + e });
				output.fail();
				return 1;
			}
			if (_unsafe) {
				push(state.errors, { code: 'errorUserFileUnsafeNft', info: path });
				output.fail();
				return 1;
			}
			for (let line in _pending)
				nft.nft_add(line);
			output.ok();
			return 0;
		};
	
		if (enabled != '1' && enabled != 1) return 0;
		output.verbose.write('Running ' + path + ' ');
		if (!stat(path) || stat(path).size == 0) {
			push(state.errors, { code: 'errorUserFileNotFound', info: path });
			output.fail();
			return 1;
		}
		if (match(path, /\.uc$/))
			return _user_file_process_uc(path);
		else
			return _user_file_process_sh(path);
	}
	
	// ── Netifd Integration ──────────────────────────────────────────────
	
	function netifd_handler(action, target_iface) {
		let readfile = _fs.readfile;
		let writefile = _fs.writefile;

		load_config();
		reset();
		action = action || 'install';

		if (action == 'check')
			return cfg.netifd_enabled == '1';

		let dryrun_dir = '/var/run/pbr-dryrun';
		let dryrun_net_ctx = null;
		let rt_file = pkg.rt_tables_file;

		if (action == 'dryrun') {
			sh.run('rm -rf ' + dryrun_dir);
			sh.mkdir_p(dryrun_dir);
			sh.run('cp /etc/config/network ' + dryrun_dir + '/network');
			dryrun_net_ctx = _uci.cursor(dryrun_dir);
			dryrun_net_ctx.load('network');
			rt_file = dryrun_dir + '/rt_tables';
		}

		if (action == 'install' || action == 'dryrun') {
			if (!cfg.netifd_strict_enforcement) {
				push(state.errors, { code: 'errorNetifdMissingOption', info: 'netifd_strict_enforcement' });
				output.error(get_text('errorNetifdMissingOption', cfg, 'netifd_strict_enforcement'));
				return false;
			}
			if (!cfg.netifd_interface_default) {
				push(state.errors, { code: 'errorNetifdMissingOption', info: 'netifd_interface_default' });
				output.error(get_text('errorNetifdMissingOption', cfg, 'netifd_interface_default'));
				return false;
			}
			let net_ctx = config.uci_ctx('network', true);
			if (net_ctx.get('network', cfg.netifd_interface_default) != 'interface') {
				push(state.errors, { code: 'errorNetifdInvalidGateway4', info: cfg.netifd_interface_default });
				output.error(get_text('errorNetifdInvalidGateway4', cfg, cfg.netifd_interface_default));
				return false;
			}
			if (cfg.netifd_interface_default6 && net_ctx.get('network', cfg.netifd_interface_default6) != 'interface') {
				push(state.errors, { code: 'errorNetifdInvalidGateway6', info: cfg.netifd_interface_default6 });
				output.error(get_text('errorNetifdInvalidGateway6', cfg, cfg.netifd_interface_default6));
				return false;
			}
			if (!cfg.netifd_interface_local) {
				push(state.warnings, { code: 'warningNetifdMissingInterfaceLocal', info: 'lan' });
				output.warning(get_text('warningNetifdMissingInterfaceLocal', cfg, 'lan'));
				cfg.netifd_interface_local = 'lan';
			}
		}

		let mark = sprintf('0x%06x', hex(cfg.uplink_mark));
		let priority = cfg.uplink_ip_rules_priority;
		let tid = nft.get_rt_tables_non_pbr_next_id();
		let lan_priority = int(cfg.uplink_ip_rules_priority) + 1000;
		let _uplinkMark, _uplinkPriority, _uplinkTableID;
		let nft_table = pkg.nft_table;
		let nft_prefix = pkg.nft_prefix;
		let rule_params = cfg._nft_rule_params ? ' ' + cfg._nft_rule_params : '';

		nft.nft_file.init('netifd');
		output.info.write('Netifd extensions ' + action + (target_iface ? ' on ' + target_iface : '') + ' ');

		let net_ctx = dryrun_net_ctx || config.uci_ctx('network', true);
		net_ctx.delete('network', 'main_ipv4');
		net_ctx.delete('network', 'main_ipv6');

		net_ctx.foreach('network', 'interface', function(s) {
			let iface = s['.name'];
			let rt_name = pkg.ip_table_prefix + '_' + iface;
			if (net.is_split_uplink() && iface == cfg.uplink_interface6)
				rt_name = pkg.ip_table_prefix + '_' + cfg.uplink_interface4;

			net_ctx.delete('network', iface, 'ip4table');
			net_ctx.delete('network', iface, 'ip6table');
			net_ctx.delete('network', rt_name + '_ipv4');
			net_ctx.delete('network', rt_name + '_ipv6');
	
			if (cfg.netifd_strict_enforcement == '1' && V.str_contains(cfg.netifd_interface_local, iface)) {
				if (action == 'install' || action == 'dryrun') {
					if (cfg.netifd_interface_default) {
						let rule_name = rt_name + '_ipv4';
						net_ctx.set('network', rule_name, 'rule');
						net_ctx.set('network', rule_name, 'in', iface);
						net_ctx.set('network', rule_name, 'lookup', pkg.ip_table_prefix + '_' + cfg.netifd_interface_default);
						net_ctx.set('network', rule_name, 'priority', '' + lan_priority);
					}
					if (cfg.netifd_interface_default6) {
						let ipv6_lookup = pkg.ip_table_prefix + '_' + cfg.netifd_interface_default6;
						if (net.is_split_uplink() && cfg.netifd_interface_default6 == cfg.uplink_interface6)
							ipv6_lookup = pkg.ip_table_prefix + '_' + cfg.uplink_interface4;
						let rule6_name = rt_name + '_ipv6';
						net_ctx.set('network', rule6_name, 'rule6');
						net_ctx.set('network', rule6_name, 'in', iface);
						net_ctx.set('network', rule6_name, 'lookup', ipv6_lookup);
						net_ctx.set('network', rule6_name, 'priority', '' + lan_priority);
					}
					lan_priority++;
				}
			}
	
			if (!net.is_supported_interface(iface)) return;
	
			let _mark = mark, _priority = priority, _tid = tid;
			let split_second = false;
	
			if (net.is_split_uplink()) {
				if (net.is_uplink4(iface) || net.is_uplink6(iface)) {
					if (_uplinkMark && _uplinkPriority && _uplinkTableID) {
						_mark = _uplinkMark;
						_priority = _uplinkPriority;
						_tid = _uplinkTableID;
						split_second = true;
					} else {
						_uplinkMark = _mark;
						_uplinkPriority = _priority;
						_uplinkTableID = _tid;
					}
				}
			}
	
			if (!cfg.netifd_strict_enforcement && cfg.netifd_interface_default == iface)
				rt_name = 'main';
	
			if (!target_iface || target_iface == iface) {
				if (action == 'install' || action == 'dryrun') {
					output.verbose.write('Setting up netifd extensions for ' + iface + '... ');
					if (!net.is_split_uplink() || !net.is_uplink6(iface)) {
						net_ctx.set('network', iface, 'ip4table', rt_name);
						let rule4 = rt_name + '_ipv4';
						net_ctx.set('network', rule4, 'rule');
						net_ctx.set('network', rule4, 'priority', '' + _priority);
						net_ctx.set('network', rule4, 'lookup', rt_name);
						net_ctx.set('network', rule4, 'mark', _mark);
						net_ctx.set('network', rule4, 'mask', cfg.fw_mask);
					}
					if (!net.is_split_uplink() || !net.is_uplink4(iface)) {
						net_ctx.set('network', iface, 'ip6table', rt_name);
						let rule6 = rt_name + '_ipv6';
						net_ctx.set('network', rule6, 'rule6');
						net_ctx.set('network', rule6, 'priority', '' + _priority);
						net_ctx.set('network', rule6, 'lookup', rt_name);
						net_ctx.set('network', rule6, 'mark', _mark);
						net_ctx.set('network', rule6, 'mask', cfg.fw_mask);
					}
					if (!net.is_split_uplink() || !net.is_uplink6(iface)) {
						if (rt_name != 'main') {
							let rt = readfile(rt_file) || readfile(pkg.rt_tables_file) || '';
							let lines = filter(split(rt, '\n'), l => l != '' && index(l, rt_name) < 0);
							push(lines, _tid + ' ' + rt_name);
							writefile(rt_file, join('\n', lines) + '\n');
						}
						nft.nft_file.filter('temp', _mark);
					}
					if (!nft.nft_file.match('temp', nft_prefix + '_mark_' + _mark)) {
						nft.nft_add('define ' + nft_prefix + '_' + iface + '_mark = ' + _mark);
						nft.nft_add('add chain inet ' + nft_table + ' ' + nft_prefix + '_mark_' + _mark);
						nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_mark_' + _mark + rule_params +
							' meta mark set (meta mark & ' + cfg.fw_maskXor + ') | $' + nft_prefix + '_' + iface + '_mark');
						nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_mark_' + _mark + ' return');
					}
					let dscp = config.uci_ctx(pkg.name).get(pkg.name, 'config', iface + '_dscp') || '0';
					if (+dscp >= 1 && +dscp <= 63) {
						if (!net.is_split_uplink() || !net.is_uplink6(iface))
							nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_prerouting ' +
								pkg.nft_ipv4_flag + ' dscp ' + dscp + rule_params + ' goto ' + nft_prefix + '_mark_' + _mark);
						if (!net.is_split_uplink() || !net.is_uplink4(iface))
							nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_prerouting ' +
								pkg.nft_ipv6_flag + ' dscp ' + dscp + rule_params + ' goto ' + nft_prefix + '_mark_' + _mark);
					}
					if (iface == cfg.icmp_interface) {
						if (!net.is_split_uplink() || !net.is_uplink6(iface))
							nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_output ' +
								pkg.nft_ipv4_flag + ' protocol icmp' + rule_params + ' goto ' + nft_prefix + '_mark_' + _mark);
						if (!net.is_split_uplink() || !net.is_uplink4(iface))
							nft.nft_add('add rule inet ' + nft_table + ' ' + nft_prefix + '_output ' +
								pkg.nft_ipv6_flag + ' nexthdr icmpv6' + rule_params + ' goto ' + nft_prefix + '_mark_' + _mark);
					}
					output.okb();
				} else if (action == 'remove' || action == 'uninstall') {
					output.verbose.write('Removing netifd extensions for ' + iface + '... ');
					if (rt_name != 'main') {
						let rt = readfile(pkg.rt_tables_file) || '';
						let lines = filter(split(rt, '\n'), l => l != '' && index(l, rt_name) < 0);
						writefile(pkg.rt_tables_file, join('\n', lines) + '\n');
					}
					nft.nft_file.sed('netifd', "'/" + _mark + "/d'");
					output.okb();
				}
			}
	
			if (!split_second) {
				mark = sprintf('0x%06x', hex(_mark) + hex(cfg.uplink_mark));
				priority = +_priority - 1;
				tid = +_tid + 1;
			}
		});
	
		output.info.newline();
	
		switch (action) {
		case 'dryrun': {
			let nft_content = nft.nft_file.get_content();
			if (nft_content)
				writefile(dryrun_dir + '/pbr-netifd.nft', nft_content);
			dryrun_net_ctx.commit('network');
			output.print('Dry run complete. Generated files:\\n');
			output.print('  Network config: ' + dryrun_dir + '/network\\n');
			output.print('  NFT rules:      ' + dryrun_dir + '/pbr-netifd.nft\\n');
			if (_fs.stat(rt_file))
				output.print('  RT tables:      ' + rt_file + '\\n');
			return true;
		}
		case 'install':
			nft.nft_file.apply('netifd');
			if (!target_iface)
				config.uci_ctx(pkg.name).set(pkg.name, 'config', 'netifd_enabled', '1');
			break;
		case 'remove':
			if (!target_iface) {
				nft.nft_file.remove('netifd');
				config.uci_ctx(pkg.name).delete(pkg.name, 'config', 'netifd_enabled');
			}
			break;
		case 'uninstall':
			if (!target_iface)
				nft.nft_file.remove('netifd');
			break;
		}

		config.uci_ctx(pkg.name).commit(pkg.name);
		config.uci_ctx('network').commit('network');
		sh.run('sync');

		output.info.write('Reloading network and firewall (' + action + ') ');
		output.verbose.write('Reloading network and firewall (' + action + ') ');
		if (sh.run('/etc/init.d/network reload') == 0 && sh.run('/etc/init.d/firewall reload') == 0)
			output.okbn();
		else
			output.failn();
	
		return true;
	}
	
	// ── start_service ───────────────────────────────────────────────────
	
	// Bypass an on_interface_reload caused by a DHCPv6 renew when the IPv6
	// uplink gateway has not actually changed. Compares the freshly discovered
	// gateway for the reloaded interface against the value pbr last published in
	// its procd service data. Called from the init script BEFORE stop_forward,
	// so an unchanged renew causes no forwarding churn or interface reprocessing.
	function should_skip_reload(iface) {
		if (!iface) return false;
		reset();
		load_config();
		if (!net.is_uplink6(iface)) return false;
		let dev6 = net.network_get_device(iface) || net.network_get_physdev(iface) || '';
		config.network_flush_cache();
		let cur = net.get_gateway6(iface, dev6) || '';
		if (cur == '') return false;
		let svc = config.ubus_call('service', 'list', { name: pkg.name });
		let gateways = svc?.[pkg.name]?.data?.gateways;
		let prev = null;
		if (type(gateways) == 'array') {
			for (let g in gateways)
				if (g.name == iface) { prev = g.gateway_ipv6; break; }
		}
		if (cur == prev) {
			// Match the shell: refresh the resolver hash before returning. The
			// value is process-local, so this is effectively a no-op here, kept
			// for parity with the reference implementation.
			nft.resolver.store_hash();
			output.verbose.write("Skipping reload for '" + iface + "' - IPv6 gateway unchanged (" + cur + ")\\n");
			return true;
		}
		return false;
	}

	function start_service(args) {
		let readfile = _fs.readfile;
		let stat = _fs.stat;
		let lsdir = _fs.lsdir;
		let param = (args && args[0]) || 'on_start';
		let reloaded_iface = (args && args[1]) || null;
	
		if (param == 'on_boot') return null;

		reset();
		if (!load(param)) {
			return null;
		}
		// Enumerate interfaces BEFORE is_wan_up — interface_enumerate /
		// strategy_enumerate consult UCI/env and don't require WAN to be
		// up. Building ifaces_triggers here means we can still register
		// per-interface procd triggers even on a degraded start (uplink
		// not ready). Otherwise procd's set/add call would emit only the
		// boot-retry trigger, which procd treats as a full replacement
		// — silently wiping the interface triggers and breaking
		// WAN-flap recovery (see issue #113).
		let start_time, end_time;
		start_time = time();
		interface_enumerate();
		strategy_enumerate();
		end_time = time();
		output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Enumerating interfaces took ' + (end_time - start_time) + 's');

		output.info.write('Detecting uplink (' + param + ') ');
		output.verbose.write('Detecting uplink (' + param + ') ');
		if (!net.is_wan_up(param, state.errors)) {
			output.failn();
			output.warning(get_text('warningUplinkDown', cfg));
			_deferred_to_boot = true;
			// Return a partial result so the wrapper can still emit
			// _pbr_ifaces_triggers and skip the per-instance data block,
			// preserving procd's existing data instead of wiping it.
			return {
				ifacesTriggers: ifaces_triggers,
				deferredToBoot: true,
				errors: state.errors,
				warnings: state.warnings,
			};
		}
	
		switch (param) {
		case 'on_interface_reload':
			if (reloaded_iface)
				service_start_trigger = 'on_interface_reload';
			else
				service_start_trigger = 'on_start';
			break;
		case 'on_reload':
			service_start_trigger = 'on_reload';
			break;
		case 'on_restart':
			service_start_trigger = 'on_start';
			break;
		default:
			service_start_trigger = 'on_start';
		}
	
		if (reloaded_iface && !net.is_supported_interface(reloaded_iface))
			return null;
	
		let ubus_errors = config.ubus_call('service', 'list', { name: pkg.name });
		let svc_data = ubus_errors?.[pkg.name]?.data;
		if (svc_data?.errors && length(svc_data.errors) > 0) {
			service_start_trigger = 'on_start';
			reloaded_iface = null;
		} else if (!nft.is_service_running_nft()) {
			service_start_trigger = 'on_start';
			reloaded_iface = null;
		} else if (!svc_data?.gateways) {
			service_start_trigger = 'on_start';
			reloaded_iface = null;
		}
	
		switch (service_start_trigger) {
		case 'on_interface_reload':
			nft.resolver.store_hash();
			output.okn();
			output.info.write('Reloading Interface: ' + reloaded_iface + ' ');
			start_time = time();
			config.uci_ctx('network').foreach('network', 'interface', function(s) {
				interface_process.reload_interface(s['.name'], reloaded_iface);
			});
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Reloading interface ' + reloaded_iface + ' took ' + (end_time - start_time) + 's');
			output.info.newline();
			break;
	
		default:
			nft.resolver.store_hash();
			nft.resolver.configure();
			// Only the ip-rule/rt_tables state needs tearing down here. The nft
			// chains and sets must NOT be removed live: everything rebuilt below
			// is appended to nft_lines and does not reach the kernel until the
			// 'fw4 -q reload' at the end of nft_file.apply('main'), so deleting
			// them now leaves a window -- seconds wide on a multi-interface
			// router -- in which the sets named by dnsmasq's nftset= directives
			// do not exist. dnsmasq keeps answering across it and logs
			// 'nftset ... Error: No such file or directory' for every reply that
			// lands in the gap, and those addresses are never added to the set.
			// fw4 reload rebuilds the whole inet table atomically from
			// 30-pbr.nft, so the old chains and sets are replaced regardless --
			// which is why stop() below likewise cleans only these two.
			nft.cleanup('main_table', 'rt_tables');
			nft.nft_file.init('main', iface_registry);
			output.okn();
	
			output.info.write('Processing interfaces ');
			start_time = time();
			config.uci_ctx('network').foreach('network', 'interface', function(s) {
				interface_process.create(s['.name']);
			});
			interface_process.tor('destroy');
			if (net.is_tor_configured()) interface_process.tor('create');
			interface_process.create_global_rules();
			sh.run(pkg.ip_full + ' route flush cache');
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Processing interfaces took ' + (end_time - start_time) + 's');
			output.info.newline();
	
			if (net.is_config_enabled('policy')) {
				output.info.write('Processing policies ');
				start_time = time();
				config.uci_ctx(pkg.name, true).foreach(pkg.name, 'policy', function(s) {
					let p = config.parse_options(s, config.policy_schema);
					policy_process(s['.name'],
						p.enabled, p.name, p.interface, p.src_addr, p.src_port,
						p.dest_addr, p.dest_port, p.proto, p.chain);
				});
				end_time = time();
				output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Processing policies took ' + (end_time - start_time) + 's');
				output.info.newline();
			}
	
			if (net.is_config_enabled('dns_policy')) {
				output.info.write('Processing dns policies ');
				start_time = time();
				config.uci_ctx(pkg.name, true).foreach(pkg.name, 'dns_policy', function(s) {
					let p = config.parse_options(s, config.dns_policy_schema);
					dns_policy_process(s['.name'],
						p.enabled, p.name, p.src_addr, p.dest_dns, p.dest_dns_port);
				});
				end_time = time();
				output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Processing DNS policies took ' + (end_time - start_time) + 's');
				output.info.newline();
			}
	
			if (net.is_config_enabled('include') || stat('/etc/' + pkg.name + '.d/')?.type == 'directory') {
				config.uci_ctx('network').foreach('network', 'interface', function(s) {
					interface_process.create_user_set(s['.name']);
				});
				output.info.write('Processing user file(s) ');
				start_time = time();
				config.uci_ctx(pkg.name, true).foreach(pkg.name, 'include', function(s) {
					user_file_process(s.enabled, s.path);
				});
				let user_dir = '/etc/' + pkg.name + '.d/';
				if (stat(user_dir)?.type == 'directory') {
					let files = lsdir(user_dir) || [];
					for (let f in files) {
						let fp = user_dir + f;
						if (stat(fp)?.type == 'file')
							user_file_process('1', fp);
					}
				}
				end_time = time();
				output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Processing user files took ' + (end_time - start_time) + 's');
				output.info.newline();
			}
	
			start_time = time();
			let nft_applied = nft.nft_file.apply('main');
			end_time = time();
			output.logger_debug(cfg.debug_performance, '[PERF-DEBUG] Installing nft rules took ' + (end_time - start_time) + 's');

			// Reap sets orphaned by policies that are gone. Only meaningful once
			// the new ruleset is live, and skipped when it failed to install,
			// since the sets still in use are then the previous file's.
			if (nft_applied) nft.cleanup('orphan_sets');
			// Before the restart below, so addresses re-resolved after it are
			// not wiped by a flush that follows.
			if (nft_applied) nft.resolver.flush_changed();

			if (nft.resolver.compare_hash()) nft.resolver.restart();
			else nft.resolver.flush_cache();
			break;
		}
	
		let _interface_label = function(name, iface) {
			if (iface?.action == 'mwan4_strategy')
				return 'mwan4:strategy:' + (iface.strategy_name || name);
			if (env.mwan4_mark[name])  return 'mwan4:' + name;
			if (env.netifd_mark[name]) return 'netifd:' + name;
			return name;
		};
		let _build_gateway_summary = function() {
			let lines = [];
			for (let name in keys(iface_registry)) {
				let iface = iface_registry[name];
				if (!iface || iface.action == 'mwan4_strategy') continue;
				let disp_dev = (name != iface.device_ipv4) ? iface.device_ipv4 : '';
				let text = _interface_label(name, iface) + '/' + (disp_dev ? disp_dev + '/' : '') +
					disp_gw_suffix(iface.gateway_ipv4, iface.gateway_ipv6);
				if (iface.status_symbol) text += ' ' + iface.status_symbol;
				push(lines, text);
			}
			return join('\\n', lines);
		};
		let gw_summary = _build_gateway_summary();
		let gateways = [];
		for (let name in keys(iface_registry)) {
			let iface = iface_registry[name];
			if (iface.action == 'mwan4_strategy') continue;
			push(gateways, {
				name: name,
				label: _interface_label(name, iface),
				device_ipv4: iface.device_ipv4,
				gateway_ipv4: iface.gateway_ipv4,
				device_ipv6: iface.device_ipv6,
				gateway_ipv6: iface.gateway_ipv6,
				'default': iface.is_default || false,
				action: iface.action,
				table_id: '' + (iface.tid || ''),
				mark: iface.mark || '',
				priority: '' + (iface.priority || ''),
			});
		}
		let result = {
			packageCompat: +pkg.compat,
			version: pkg.version,
			gateways: gateways,
			status: {},
			errors: state.errors,
			warnings: state.warnings,
			interfaces: env.webui_interfaces,
			interface_labels: env.webui_interface_labels,
			platform: {
				nft_installed: env.nft_installed,
				adguardhome_installed: env.adguardhome_installed,
				dnsmasq_installed: env.dnsmasq_installed,
				unbound_installed: env.unbound_installed,
				dnsmasq_nftset_support: env.dnsmasq_nftset_supported,
			},
			ifacesTriggers: ifaces_triggers,
		};
		if (gw_summary)
			result.status.gateways = gw_summary;
		return result;
	}
	
	// ── stop_service ────────────────────────────────────────────────────
	
	function stop_service() {
		reset();
		if (!nft.is_service_running_nft() && nft.get_rt_tables_next_id() == nft.get_rt_tables_non_pbr_next_id())
			return;
	
		_fs.unlink(pkg.lock_file);
		load('on_stop');
		output.info.write('Resetting routing ');
		output.verbose.write('Resetting routing ');
		let ok = nft.nft_file.remove('main') && nft.cleanup('main_table', 'rt_tables');
		sh.run(pkg.ip_full + ' route flush cache');
		sh.run('fw4 -q reload');
		if (ok) output.okn();
		else output.failn();

		output.info.write('Resetting resolver ');
		output.verbose.write('Resetting resolver ');
		if (nft.resolver.store_hash() && nft.resolver.cleanup())
			output.okn();
		else
			output.failn();

		if (nft.resolver.compare_hash()) nft.resolver.restart();

		if (cfg.enabled) {
			output.info.write(pkg.service_name + ' stopped ');
			output.verbose.write(pkg.service_name + ' stopped ');
			output.okn();
		}
	}
	
	// ── service_started ─────────────────────────────────────────────────
	
	function service_started(param, deferred_to_boot) {
		if (param == 'on_boot') return;
		// Uplink was down at start time; we've already emitted the warning
		// and are waiting for the procd boot trigger to retry. This is a
		// designed deferral, not a startup failure.
		if (deferred_to_boot == '1' || _deferred_to_boot) {
			return;
		}

		load_platform();

		let svc_info = config.ubus_call('service', 'list', { name: pkg.name });
		let svc_data = svc_info?.[pkg.name]?.data;

		if (nft.nft_file.exists('main')) {
			let mode;
			if (length(keys(env.netifd_mark)) > 0) mode = 'netifd-compatibility mode';
			else if (length(keys(env.mwan4_mark)) > 0) mode = 'mwan4-compatibility mode';
			else mode = 'dynamic routing tables mode';
			output.print(pkg.service_name + ' started in ' + mode + '.\\n');
			let gw_summary = svc_data?.status?.gateways;
			if (gw_summary)
				output.verbose.write(pkg.service_name + ' is monitoring interfaces:\\n' + gw_summary + '\\n');
		} else {
			output.print(pkg.service_name + ' FAILED TO START!!!\\n');
			output.print('Check the output of nft -c -f ' + pkg.nft_temp_file + '\\n');
		}
	
		let warnings = svc_data?.warnings || [];
		for (let w in warnings) {
			output.warning(get_text(w.code, cfg, w.info));
		}
		if (length(warnings) > 0)
			output.warning(get_text('warningSummary', cfg, pkg.url('#warning-messages-details')));
	
		let errors = svc_data?.errors || [];
		for (let e in errors) {
			output.error(get_text(e.code, cfg, e.info));
		}
		if (length(errors) > 0)
			output.error(get_text('errorSummary', cfg, pkg.url('#error-messages-details')));
	
		_fs.writefile(pkg.lock_file, trim(sh.exec('echo $$')));
	}
	
	// ── emit_procd_shell ────────────────────────────────────────────────

	// Package the procd data into two top-level shell variable assignments
	// consumed by init.d/pbr:
	//   _pbr_ifaces_triggers — space-separated list of netifd ifaces that
	//                          need per-interface procd triggers
	//   _pbr_svc_data        — multi-line string of json_add_* commands
	//                          that populate procd's service_data block
	function emit_procd_shell(data) {
		if (!data) return '';
		// Always emit the iface list and the deferred-to-boot flag.
		// service_triggers() in the init script reads both so per-iface
		// procd triggers can be registered on every start, including the
		// degraded path where ucode bailed because the uplink wasn't ready.
		let preamble = '_pbr_ifaces_triggers=' + sh.quote(data.ifacesTriggers || '') + '\n' +
		               '_pbr_deferred_to_boot=' + sh.quote(data.deferredToBoot ? '1' : '') + '\n';

		// Degraded start: skip the per-instance data block entirely
		// (empty _pbr_svc_data — wrapper will unset its service_data hook,
		// so procd's existing data isn't replaced by an empty object).
		if (data.deferredToBoot)
			return preamble + '_pbr_svc_data=\n';

		let lines = [];

		push(lines, 'json_add_int packageCompat ' + sh.quote('' + (data.packageCompat || 0)));
		push(lines, 'json_add_string version ' + sh.quote(data.version || ''));
	
		push(lines, 'json_add_array interfaces');
		for (let iface in (data.interfaces || []))
			push(lines, 'json_add_string \'\' ' + sh.quote(iface));
		push(lines, 'json_close_array');
	
		push(lines, 'json_add_object platform');
		for (let k in keys(data.platform || {})) {
			let v = data.platform[k];
			if (type(v) == 'bool')
				push(lines, 'json_add_boolean ' + k + ' ' + sh.quote(v ? '1' : '0'));
			else
				push(lines, 'json_add_string ' + k + ' ' + sh.quote('' + v));
		}
		push(lines, 'json_close_object');
	
		push(lines, 'json_add_array gateways');
		for (let gw in (data.gateways || [])) {
			push(lines, "json_add_object ''");
			for (let k in keys(gw)) {
				let v = gw[k];
				if (type(v) == 'bool')
					push(lines, 'json_add_boolean ' + k + ' ' + sh.quote(v ? '1' : '0'));
				else if (type(v) == 'int')
					push(lines, 'json_add_int ' + k + ' ' + sh.quote('' + v));
				else
					push(lines, 'json_add_string ' + k + ' ' + sh.quote('' + v));
			}
			push(lines, 'json_close_object');
		}
		push(lines, 'json_close_array');
	
		push(lines, 'json_add_object status');
		if (data.status?.gateways)
			push(lines, 'json_add_string gateways ' + sh.quote(data.status.gateways));
		push(lines, 'json_close_object');
	
		push(lines, 'json_add_array errors');
		for (let e in (data.errors || [])) {
			push(lines, "json_add_object ''");
			push(lines, 'json_add_string code ' + sh.quote(e.code || ''));
			push(lines, 'json_add_string info ' + sh.quote(e.info || ''));
			push(lines, 'json_close_object');
		}
		push(lines, 'json_close_array');
	
		push(lines, 'json_add_array warnings');
		for (let w in (data.warnings || [])) {
			push(lines, "json_add_object ''");
			push(lines, 'json_add_string code ' + sh.quote(w.code || ''));
			push(lines, 'json_add_string info ' + sh.quote(w.info || ''));
			push(lines, 'json_close_object');
		}
		push(lines, 'json_close_array');

		let body = join('\n', lines);
		return preamble + '_pbr_svc_data=' + sh.quote(body) + '\n';
	}

	// ── Status Service ──────────────────────────────────────────────────
	
	function status_service(params) {
		let readfile = _fs.readfile;
		let stat = _fs.stat;
		load('status');

		let verbose = false;
		for (let p in params)
			if (p == '-d' || p == '-v') verbose = true;

		// Determine routing mode
		let has_netifd = length(keys(env.netifd_mark)) > 0;
		let has_mwan4 = length(keys(env.mwan4_mark)) > 0;
		let running = platform.is_running_nft_file();

		if (!running) {
			printf('%s: not active.\n', pkg.service_name);
			return;
		}

		if (!verbose) {
			let mode;
			if (has_netifd) mode = 'netifd-compatibility mode';
			else if (has_mwan4) mode = 'mwan4-compatibility mode';
			else mode = 'dynamic routing tables mode';
			printf('%s: active in %s.\n', pkg.service_name, mode);

			if (has_netifd)
				printf('  netifd nft file: %s\n', pkg.nft_netifd_file);
			if (has_mwan4) {
				let m4 = null;
				try { m4 = require('mwan4'); } catch(e) {}
				if (m4 && m4.pkg && m4.pkg.NFT_FILES) {
					for (let target in keys(m4.pkg.NFT_FILES))
						printf('  mwan4 nft file:  %s\n', m4.pkg.NFT_FILES[target]);
				}
			}
			printf('  main nft file:   %s\n', pkg.nft_main_file);
			return;
		}

		// Verbose output (existing detailed diagnostics)
		// Use sh.exec()+printf() instead of system() to avoid stdout buffering
		// interleaving when output is redirected to a file.
		let _exec_print = function(cmd) {
			let out = sh.exec(cmd);
			if (out) printf('%s\n', out);
		};
		let board = config.ubus_call('system', 'board', {});
		let openwrt_release = board?.release?.description || 'unknown';

		let status_text = pkg.service_name + ' on ' + openwrt_release + '.\\n';

		if (cfg.uplink_interface4) {
			let dev4 = net.network_get_device(cfg.uplink_interface4);
			if (!dev4) dev4 = net.network_get_physdev(cfg.uplink_interface4);
			status_text += 'Uplink (IPv4): ' + cfg.uplink_interface4 +
				(dev4 ? '/' + dev4 : '') + '/' + (env.uplink_gw4 || '0.0.0.0') + '.\\n';
		}
		if (cfg.uplink_interface6) {
			let dev6 = net.network_get_device(cfg.uplink_interface6);
			if (!dev6) dev6 = net.network_get_physdev(cfg.uplink_interface6);
			if (!dev6) {
				let dev4 = net.network_get_device(cfg.uplink_interface4);
				if (!dev4) dev4 = net.network_get_physdev(cfg.uplink_interface4);
				dev6 = dev4 || '';
			}
			status_text += 'Uplink (IPv6): ' + cfg.uplink_interface6 +
				(dev6 ? '/' + dev6 : '') + '/' + (env.uplink_gw6 || '::/0') + '.\\n';
		}

		printf('===== %s - environment =====\n', pkg.name);
		printf('%s', replace(status_text, /\\n/g, '\n'));
		printf('===== dnsmasq version =====\n');
		_exec_print("dnsmasq --version 2>/dev/null | sed '/^$/,$d'");

		if (nft.nft_file.exists('netifd')) {
			printf('===== %s nft netifd file =====\n', pkg.name);
			let netifd_content = nft.nft_file.show('netifd');
			if (netifd_content) printf('%s', netifd_content);
		}
		if (nft.nft_file.exists('main')) {
			printf('===== %s nft main file =====\n', pkg.name);
			let main_content = nft.nft_file.show('main');
			if (main_content) printf('%s', main_content);
		}

		printf('===== %s chains - policies =====\n', pkg.name);
		for (let ch in split(pkg.chains_list + ' dstnat', /\s+/)) {
			_exec_print('nft -a list table inet ' + pkg.nft_table +
				" | sed -n '/chain " + pkg.nft_prefix + '_' + ch + " {/,/\\t}/p'");
		}

		printf('===== %s chains - marking =====\n', pkg.name);
		let mark_chains = nft.get_mark_nft_chains();
		for (let mc in split(mark_chains, /\s+/)) {
			if (!mc) continue;
			_exec_print('nft -a list table inet ' + pkg.nft_table +
				" | sed -n '/chain " + mc + " {/,/\\t}/p'");
		}

		printf('===== %s nft sets =====\n', pkg.name);
		let sets = nft.get_nft_sets();
		for (let ns in split(sets, /\s+/)) {
			if (!ns) continue;
			_exec_print('nft -a list table inet ' + pkg.nft_table +
				" | sed -n '/set " + ns + " {/,/\\t}/p'");
		}

		if (stat(pkg.dnsmasq_file)?.size > 0) {
			printf('===== dnsmasq nft sets in %s =====\n', pkg.dnsmasq_file);
			printf('%s', readfile(pkg.dnsmasq_file) || '');
		}

		printf('===== %s tables & routing =====\n', pkg.name);
		let rt = readfile(pkg.rt_tables_file) || '';
		let table_count = 0;
		for (let l in split(rt, '\n'))
			if (index(l, pkg.name + '_') >= 0) table_count++;
		let wan_tid = +nft.get_rt_tables_next_id() - table_count;

		for (let i = 0; i <= table_count; i++) {
			let tid = (i == 0) ? 'main' : '' + (wan_tid + i - 1);
			let status_table = '';
			for (let l in split(rt, '\n')) {
				if (index(l, tid + '\t') == 0 || index(l, tid + ' ') == 0) {
					let parts = split(trim(l), /\s+/);
					if (length(parts) >= 2) status_table = parts[1];
				}
			}
			printf('IPv4 table %s%s routes:\n', tid, status_table ? ' (' + status_table + ')' : '');
			_exec_print(pkg.ip_full + ' -4 route show table ' + tid + " | sed 's/^/    /'");
			printf('IPv4 table %s%s rules:\n', tid, status_table ? ' (' + status_table + ')' : '');
			_exec_print(pkg.ip_full + ' -4 rule list table ' + tid + " | sed 's/^/    /'");
			if (cfg.ipv6_enabled) {
				printf('===== IPv6 table %s =====\n', tid);
				_exec_print(pkg.ip_full + ' -6 route show table ' + tid + " | sed 's/^/    /'");
				printf('IPv6 table %s rules:\n', tid);
				_exec_print(pkg.ip_full + ' -6 rule list table ' + tid + " | sed 's/^/    /'");
			}
		}
	}
	
	// ── Support ─────────────────────────────────────────────────────────
	
	function support() {
		let readfile = _fs.readfile;
		// Use sh.exec()+printf() instead of system() to avoid stdout buffering
		// interleaving when output is redirected to a file.
		let _exec_print = function(cmd) {
			let out = sh.exec(cmd);
			if (out) printf('%s\n', out);
		};

		printf('Setting counters and verbosity for diagnostics...\n');
		let ctx = config.uci_ctx(pkg.name);
		ctx.set(pkg.name, 'config', 'nft_rule_counter', '1');
		ctx.set(pkg.name, 'config', 'nft_set_counter', '1');
		ctx.set(pkg.name, 'config', 'verbosity', '2');
		ctx.commit(pkg.name);

		for (let cfg_name in ['dhcp', 'firewall', 'network', 'pbr']) {
			let content = readfile('/etc/config/' + cfg_name);
			if (!content) continue;
			printf('===== %s config =====\n', cfg_name);
			for (let line in split('' + content, '\n')) {
				let m = match(line, /^(\s*(option|list)\s+)(endpoint_host|key|password|preshared_key|private_key|psk|public_key|token|username)(\s+)(.*)/);
				if (m) {
					let masked = replace(m[5], /[^ \t\x27"]+/g, 'REDACTED');
					printf('%s%s%s%s\n', m[1], m[3], m[4], masked);
				} else {
					let masked_line = line;
					if (!match(line, /^\s*(option|list)\s+allowed_ips\s+/)) {
						// MAC addresses (exactly six colon-separated octets)
						masked_line = replace(masked_line, /\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b/g, '__:RE:DA:CT:ED:__');
						// IPv6 addresses (full and :: compressed forms)
						masked_line = replace(masked_line, /(([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}|([0-9A-Fa-f]{1,4}:){1,7}:|([0-9A-Fa-f]{1,4}:){1,6}:[0-9A-Fa-f]{1,4}|([0-9A-Fa-f]{1,4}:){1,5}(:[0-9A-Fa-f]{1,4}){1,2}|([0-9A-Fa-f]{1,4}:){1,4}(:[0-9A-Fa-f]{1,4}){1,3}|([0-9A-Fa-f]{1,4}:){1,3}(:[0-9A-Fa-f]{1,4}){1,4}|([0-9A-Fa-f]{1,4}:){1,2}(:[0-9A-Fa-f]{1,4}){1,5}|[0-9A-Fa-f]{1,4}:(:[0-9A-Fa-f]{1,4}){1,6}|:((:[0-9A-Fa-f]{1,4}){1,7}|:))/g, 'RE:DA::CT:ED');
						// Public IPv4 addresses (private ranges left intact)
						masked_line = replace(masked_line, /([0-9]{1,3}\.){3}[0-9]{1,3}/g, function(ip) {
							if (match(ip, /^(10\.|127\.|192\.168\.)/) ||
							    match(ip, /^172\.(1[6-9]|2[0-9]|3[01])\./))
								return ip;
							return 'RE.DA.CT.ED';
						});
					}
					printf('%s\n', masked_line);
				}
			}
		}

		printf('===== ubus call system board =====\n');
		_exec_print('ubus call system board');

		printf('===== %s status -d =====\n', pkg.name);
		status_service(['-d']);
	}
	
	// ── rpcd Data Functions ─────────────────────────────────────────────
	
	function get_init_list(name) {
		name = name || pkg.name;
		load_config();
		let result = {};
		let enabled = config.uci_ctx(pkg.name).get(pkg.name, 'config', 'enabled') || '0';
		result[name] = { enabled: (enabled == '1') };
		return result;
	}
	
	function get_init_status(name) {
		name = name || pkg.name;
		load('status');
	
		let ubus_data = config.ubus_call('service', 'list', { name: pkg.name });
		let svc_data = ubus_data?.[pkg.name]?.data;
		let gateways = svc_data?.status?.gateways || '';
		gateways = replace(gateways, /\x1b\[[0-9;]*m/g, '');
		gateways = replace(gateways, /\\n/g, '<br />');
	
		let result = {};
		result[name] = {
			enabled: !!cfg.enabled,
			running: platform.is_running_nft_file(),
			running_nft: nft.is_service_running_nft(),
			running_nft_file: platform.is_running_nft_file(),
			version: pkg.version,
			packageCompat: +pkg.compat,
			gateways: gateways,
			gatewaysList: svc_data?.gateways || [],
			errors: svc_data?.errors || [],
			warnings: svc_data?.warnings || [],
			interfaces: env.webui_interfaces,
			interface_labels: env.webui_interface_labels,
			protocols: sort(keys(env.protocols)),
			platform: {
				nft_installed: env.nft_installed,
				adguardhome_installed: env.adguardhome_installed,
				dnsmasq_installed: env.dnsmasq_installed,
				unbound_installed: env.unbound_installed,
				dnsmasq_nftset_support: env.dnsmasq_nftset_supported,
			},
		};
		return result;
	}
	
	function get_platform_support(name) {
		name = name || pkg.name;
		load_platform();
		let result = {};
		result[name] = {
			nft_installed: env.nft_installed,
			adguardhome_installed: env.adguardhome_installed,
			dnsmasq_installed: env.dnsmasq_installed,
			unbound_installed: env.unbound_installed,
			dnsmasq_nftset_support: env.dnsmasq_nftset_supported,
		};
		return result;
	}
	
	function get_supported_interfaces(name) {
		name = name || pkg.name;
		load('rpcd');
		let result = {};
		result[name] = {
			interfaces: env.webui_interfaces,
			interface_labels: env.webui_interface_labels,
		};
		return result;
	}
	
	// ── Public API ──────────────────────────────────────────────

	return {
		pkg,
		load_config,
		load_platform,
		load_network,
		start_service,
		should_skip_reload,
		stop_service,
		status_service,
		netifd:                   netifd_handler,
		support,
		get_init_status,
		get_init_list,
		get_platform_support,
		get_supported_interfaces,
		service_started,
		emit_procd_shell,
		forwarding,
	};
}

export default create_pbr;
