'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// Network state, interface queries, protocol detection, gateway discovery.

function create_network(fs_mod, config, sh, pkg, platform, V) {
	let readfile = fs_mod.readfile;
	let stat = fs_mod.stat;
	let lsdir = fs_mod.lsdir;

	let cfg = config.cfg;
	let env = platform.env;

	function network_get_device(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		return iface_status?.l3_device || iface_status?.device || null;
	}

	function network_get_physdev(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		return iface_status?.device || null;
	}

	function network_get_gateway(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		if (!iface_status) return null;
		let routes = iface_status?.route;
		if (type(routes) == 'array') {
			for (let r in routes) {
				if (r?.target == '0.0.0.0' && r?.mask == 0)
					return r?.nexthop;
			}
		}
		return null;
	}

	function network_get_gateway6(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		if (!iface_status) return null;
		let routes = iface_status?.route;
		if (type(routes) == 'array') {
			for (let r in routes) {
				if (r?.target == '::' && r?.mask == 0)
					return r?.nexthop;
			}
		}
		return null;
	}

	function network_get_ipaddr(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		let addrs = iface_status?.['ipv4-address'];
		if (type(addrs) == 'array' && length(addrs) > 0)
			return addrs[0]?.address || null;
		return null;
	}

	function network_get_ipaddr6(iface) {
		let iface_status = config.ubus_call('network.interface.' + iface, 'status');
		let addrs = iface_status?.['ipv6-address'];
		if (type(addrs) == 'array' && length(addrs) > 0)
			return addrs[0]?.address || null;
		// fall back to a delegated prefix's local address (PD-only setups)
		let pfx = iface_status?.['ipv6-prefix-assignment'];
		if (type(pfx) == 'array') {
			for (let p in pfx) {
				let la = p?.['local-address'];
				if (la?.address) return la.address;
			}
		}
		return null;
	}

	function network_get_protocol(iface) {
		let ctx = config.uci_ctx('network');
		return ctx.get('network', iface, 'proto') || null;
	}

	function uci_get_device(iface) {
		let ctx = config.uci_ctx('network');
		return ctx.get('network', iface, 'device') || ctx.get('network', iface, 'dev') || null;
	}

	// ── Protocol Detectors ──────────────────────────────────────────

	function is_dslite(iface) { let _p = network_get_protocol(iface); return _p != null && substr(_p, 0, 6) == 'dslite'; }
	function is_l2tp(iface) { let _p = network_get_protocol(iface); return _p != null && substr(_p, 0, 4) == 'l2tp'; }
	function is_oc(iface) { let _p = network_get_protocol(iface); return _p != null && substr(_p, 0, 11) == 'openconnect'; }
	function is_ovpn(iface) {
		let ctx = config.uci_ctx('network');
		let d = ctx.get('network', iface, 'device') || ctx.get('network', iface, 'dev');
		let p = network_get_protocol(iface);
		if (d && (substr(d, 0, 3) == 'tun' || substr(d, 0, 3) == 'tap')) return true;
		if (p && substr(p, 0, 7) == 'openvpn') return true;
		if (d && stat('/sys/devices/virtual/net/' + d + '/tun_flags')?.type != null) return true;
		return false;
	}
	function is_pptp(iface) { let _p = network_get_protocol(iface); return _p != null && substr(_p, 0, 4) == 'pptp'; }
	function is_softether(iface) { let d = network_get_device(iface); return d != null && substr(d, 0, 4) == 'vpn_'; }
	function is_netbird(iface) { let d = network_get_device(iface); return d != null && substr(d, 0, 2) == 'wt'; }
	function is_tailscale(iface) { let d = network_get_device(iface); return d != null && substr(d, 0, 9) == 'tailscale'; }
	function is_wg(iface) { let _p = network_get_protocol(iface); return !config.uci_ctx('network').get('network', iface, 'listen_port') && _p != null && substr(_p, 0, 9) == 'wireguard'; }
	function is_wg_server(iface) { let _p = network_get_protocol(iface); return !!config.uci_ctx('network').get('network', iface, 'listen_port') && _p != null && substr(_p, 0, 9) == 'wireguard'; }
	function is_tor(iface) { return lc(iface) == 'tor'; }
	function get_xray_traffic_port(iface) {
		if (!iface) return null;
		let i = replace('' + iface, pkg.xray_iface_prefix, '');
		if (i == '' + iface) return null;
		return i;
	}
	function is_xray(iface) { return get_xray_traffic_port(iface) != null; }
	function is_xfrm_interface(iface) { let _p = network_get_protocol(iface); return _p != null && substr(_p, 0, 4) == 'xfrm'; }
	function is_tunnel(iface) {
		return is_dslite(iface) || is_l2tp(iface) || is_oc(iface) || is_ovpn(iface) ||
			is_pptp(iface) || is_softether(iface) || is_netbird(iface) ||
			is_tailscale(iface) || is_tor(iface) || is_wg(iface) || is_xfrm_interface(iface);
	}

	// ── Device-level Link Detectors ─────────────────────────────────
	// dev-based (not iface-based): used for point-to-point gateway/route
	// fallbacks, mirroring the shell version's is_point_to_point/is_xfrm/is_p2p.
	// Uses `-o link show` (not `address show`) since POINTOPOINT is a link
	// flag, not something reliably reported by `ip address show` for all
	// interface types.
	function is_point_to_point(dev) {
		if (!dev) return false;
		let out = sh.exec(pkg.ip_full + ' -o link show dev ' + sh.quote(dev) + ' 2>/dev/null');
		return index(out, 'POINTOPOINT') >= 0;
	}
	function is_xfrm(dev) {
		if (!dev) return false;
		let out = sh.exec(pkg.ip_full + ' -o -d link show dev ' + sh.quote(dev) + ' 2>/dev/null');
		return !!match(out, /\bxfrm\b/);
	}
	function is_p2p(dev) {
		return is_point_to_point(dev) || is_xfrm(dev);
	}

	// ── Interface Classification ────────────────────────────────────

	function is_wan(iface) {
		if (!iface) return false;
		iface = '' + iface;
		let is6 = !!match(iface, /wan.*6$/) || !!match(iface, /.*wan6$/);
		if (is6) return !!cfg.ipv6_enabled;
		return !!match(iface, /wan/) || !!match(iface, /.*wan$/);
	}
	function is_uplink4(iface) { return iface == cfg.uplink_interface4; }
	function is_uplink6(iface) { return !!cfg.ipv6_enabled && iface == cfg.uplink_interface6; }
	function is_uplink(iface) { return is_uplink4(iface) || is_uplink6(iface); }
	function is_split_uplink() { return !!cfg.ipv6_enabled && cfg.uplink_interface4 != cfg.uplink_interface6; }
	function is_default_dev(dev) {
		let out = sh.exec(pkg.ip_full + ' -4 route show default 2>/dev/null');
		let m = match(out, /dev\s+(\S+)/);
		return m ? dev == m[1] : false;
	}
	function is_disabled_interface(iface) { return config.uci_ctx('network').get('network', iface, 'disabled') == '1'; }
	function is_lan(iface) {
		let d = network_get_device(iface);
		if (!d) return false;
		return V.str_contains(cfg.lan_device, d);
	}
	function is_ignored_interface(iface) { return V.str_contains_word(cfg.ignored_interface, iface); }
	// Tor is usable as a policy target as soon as it is CONFIGURED: the
	// redirect ports come out of torrc, not out of the running daemon. pbr is
	// START=20 and OpenWrt's tor is START=50, so at boot the service is never
	// up yet -- gating the port lookup on it left interface_process.tor()
	// unrun, the ports empty, and every Tor rule interpolating 'redirect to :',
	// which nft rejects for the whole file.
	function is_tor_configured() {
		if (is_ignored_interface('tor')) return false;
		let content = readfile(pkg.tor_config_file);
		return !!(content && content != '');
	}
	// Whether the daemon is actually up. Fine for reporting, but do NOT gate
	// rule generation on it: the ports live in torrc, the emitter keys off the
	// policy's interface name alone, and pbr starts before tor at boot.
	function is_tor_running() {
		if (!is_tor_configured()) return false;
		let svc = config.ubus_call('service', 'list', { name: 'tor' });
		if (!svc?.tor?.instances) return false;
		for (let k in keys(svc.tor.instances)) {
			if (svc.tor.instances[k]?.running == true)
				return true;
		}
		return false;
	}
	function is_ignore_target(iface) { return lc(iface) == 'ignore'; }
	function is_netifd_table(name) { let c = readfile('/etc/config/network') || ''; return index(c, name) >= 0 && !!match(c, regexp('ip.table.*' + name)); }
	function is_netifd_interface(iface) {
		return !!(iface && env.netifd_mark[iface]);
	}
	function is_mwan4_interface(iface) {
		return !!(iface && env.mwan4_mark[iface]);
	}
	function is_netifd_interface_default(iface) {
		if (!is_netifd_interface(iface)) return false;
		if (cfg.netifd_interface_default == iface) return true;
		if (cfg.netifd_interface_default6 == iface) return true;
		return false;
	}
	function is_supported_protocol(proto) {
		if (!proto) return false;
		return !!env.protocols[lc(proto)];
	}
	// nft can only match a port on a protocol that HAS one. The policy dropdown
	// is built from every line of /etc/protocols (46 of them on a stock 25.12),
	// so the other 41 are selectable and cannot work: with a port they produce
	// 'icmp dport ...', which nft refuses and which takes the whole ruleset with
	// it; without one the protocol is dropped from the rule entirely.
	// Verified against nftables 1.1.6 -- these five are accepted, the rest are not.
	const proto_with_ports = { tcp: true, udp: true, sctp: true, dccp: true, udplite: true };
	function proto_has_ports(proto) {
		return !!proto_with_ports[lc(proto || '')];
	}
	function is_mwan4_strategy(iface) { return iface && index(iface, 'mwan4_strategy_') == 0; }
	function is_supported_interface(iface) {
		if (!iface) return false;
		if (is_lan(iface) || is_disabled_interface(iface)) return false;
		// Checked ahead of supported_interface: without a torrc there are no
		// ports to redirect to, so a Tor policy cannot produce a usable rule
		// however the interface was listed.
		if (is_tor(iface)) return is_tor_configured();
		if (V.str_contains_word(cfg.supported_interface, iface)) return true;
		if (!is_ignored_interface(iface) && (is_uplink(iface) || is_wan(iface) || is_tunnel(iface))) return true;
		if (is_ignore_target(iface)) return true;
		if (is_xray(iface)) return true;
		return false;
	}
	function is_config_enabled(section_type) {
		let result = false;
		let ctx = config.uci_ctx(pkg.name);
		ctx.foreach(pkg.name, section_type, function(s) {
			if ((s.enabled || '1') == '1') result = true;
		});
		return result;
	}

	// ── Gateway Helpers ─────────────────────────────────────────────

	function default_via_from_route(out) {
		for (let line in split(out, '\n')) {
			let parts = split(trim(line), /\s+/);
			if (parts[0] != 'default') continue;
			for (let i = 0; i < length(parts) - 1; i++)
				if (parts[i] == 'via') return parts[i + 1];
		}
		return '';
	}

	function any_via_from_route(out) {
		for (let line in split(out, '\n')) {
			let parts = split(trim(line), /\s+/);
			for (let i = 0; i < length(parts) - 1; i++)
				if (parts[i] == 'via') return parts[i + 1];
		}
		return '';
	}

	// Record a warning unless an identical one is already there. Both gateway
	// helpers below rewrite their interface argument to the uplink of their own
	// address family, so on the usual wan + wan6 pair -- one device, one
	// upstream -- processing 'wan' and then 'wan6' produces the same warning,
	// with the same info string, twice. Two identical lines read as two faults;
	// one interface with no gateway is one warning.
	function push_warning_once(warnings, code, info) {
		for (let w in warnings)
			if (w.code == code && w.info == info) return;
		push(warnings, { code: code, info: info });
	}

	function get_gateway4(iface, dev, warnings) {
		if (is_uplink6(iface)) iface = cfg.uplink_interface4;
		let gw = network_get_gateway(iface);
		if (!gw || gw == '0.0.0.0') {
			// use table all in case of netifd where default routes are not present in main table
			let out = sh.exec(pkg.ip_full + ' -4 route show dev ' + sh.quote(dev) + ' table all 2>/dev/null');
			gw = default_via_from_route(out);
			// Fall back in case interfaces do not have a default route
			if (!gw) gw = any_via_from_route(out);
			// Fall back to ip route get
			if (!gw) {
				let out2 = sh.exec(pkg.ip_full + ' -4 route get 1.1.1.1 oif ' + sh.quote(dev) + ' 2>/dev/null');
				gw = any_via_from_route(out2);
			}
			// Raise warning if no gw and not point-to-point
			if (!gw && warnings && !is_p2p(dev))
				push_warning_once(warnings, 'warningInterfaceRoutingUnknownGateway4', 'interface:' + iface + '; device:' + dev + ' ');
		}
		return gw;
	}

	function get_gateway6(iface, dev, warnings) {
		if (!cfg.ipv6_enabled) return null;
		if (is_uplink4(iface)) iface = cfg.uplink_interface6;
		let gw = network_get_gateway6(iface);
		if (!gw || gw == '::/0' || gw == '::0/0' || gw == '::') {
			// use table all in case of netifd where default routes are not present in main table
			let out = sh.exec(pkg.ip_full + ' -6 route show dev ' + sh.quote(dev) + ' table all 2>/dev/null');
			gw = default_via_from_route(out);
			// Fall back in case interfaces do not have a default route
			if (!gw) gw = any_via_from_route(out);
			// Fall back to a link-local neighbor advertised as router
			if (!gw) {
				let neigh_out = sh.exec(pkg.ip_full + ' -6 neigh show dev ' + sh.quote(dev) + ' 2>/dev/null');
				for (let line in split(neigh_out, '\n')) {
					if (match(line, /^fe80:.*router/)) {
						let parts = split(trim(line), /\s+/);
						if (length(parts) > 0) { gw = parts[0]; break; }
					}
				}
			}
			// Raise warning if no gw and not point-to-point
			if (!gw && warnings && !is_p2p(dev))
				push_warning_once(warnings, 'warningInterfaceRoutingUnknownGateway6', 'interface:' + iface + '; device:' + dev + ' ');
		}
		return gw;
	}

	// Return the first address from `ip -o addr show` output (field 4,
	// stripped of its prefix length), mirroring `awk '{print $4; exit}' | cut -d/ -f1`.
	function first_addr_field(out) {
		for (let line in split(out, '\n')) {
			line = trim(line);
			if (line == '') continue;
			let parts = split(line, /\s+/);
			if (length(parts) >= 4) {
				let a = parts[3];
				let slash = index(a, '/');
				return slash >= 0 ? substr(a, 0, slash) : a;
			}
			return '';
		}
		return '';
	}

	// Return an interface's own IPv4 address, used for display when the
	// interface has no gateway (e.g. point-to-point links). Falls back to
	// the device's address from `ip` when ubus status has none.
	function get_ipaddr4(iface, dev) {
		if (is_uplink6(iface)) iface = cfg.uplink_interface4;
		let ipa = network_get_ipaddr(iface);
		if (!ipa || ipa == '0.0.0.0') {
			if (dev)
				ipa = first_addr_field(sh.exec(pkg.ip_full + ' -4 -o addr show dev ' + sh.quote(dev) + ' 2>/dev/null'));
		}
		return ipa;
	}

	function get_ipaddr6(iface, dev) {
		if (!cfg.ipv6_enabled) return null;
		if (is_uplink4(iface)) iface = cfg.uplink_interface6;
		let ipa = network_get_ipaddr6(iface);
		if (!ipa || ipa == '::/0' || ipa == '::0/0' || ipa == '::') {
			if (dev)
				ipa = first_addr_field(sh.exec(pkg.ip_full + ' -6 -o addr show dev ' + sh.quote(dev) + ' scope global 2>/dev/null'));
		}
		return ipa;
	}

	// ── load() ──────────────────────────────────────────────

	function load(param) {
		if (!env.ifaces_supported || env.ifaces_supported == '') {
			let ctx_fw = config.uci_ctx('firewall', true);
			ctx_fw.foreach('firewall', 'zone', function(s) {
				if (s.name == 'wan') env.firewall_wan_zone = s['.name'];
			});

			let parts = [];
			let webui_parts = [];
			let webui_labels = {};
			config.uci_ctx('network', true).foreach('network', 'interface', function(s) {
				let iface = s['.name'];
				if (is_supported_interface(iface)) {
					push(parts, iface);
					push(webui_parts, iface);
					if (env.mwan4_mark[iface])         webui_labels[iface] = 'mwan4:' + iface;
					else if (env.netifd_mark[iface])   webui_labels[iface] = 'netifd:' + iface;
					else                                webui_labels[iface] = iface;
				}
			});
			// Add mwan4 strategies
			for (let strategy in keys(env.mwan4_strategy_chain)) {
				let value = 'mwan4_strategy_' + strategy;
				push(webui_parts, value);
				webui_labels[value] = 'mwan4:strategy:' + strategy;
			}
			// Add the Tor pseudo interface. Tor has no corresponding
			// network.interface section (it redirects via nft dstnat rules,
			// not device routing), so it can never be discovered by the
			// foreach() loop above; expose it whenever the package is
			// installed, mirroring how 'ignore' is always offered.
			if (!is_ignored_interface('tor') && stat(pkg.tor_config_file)) {
				push(webui_parts, 'tor');
				webui_labels['tor'] = 'tor';
			}
			push(webui_parts, 'ignore');
			webui_labels['ignore'] = 'ignore';
			env.ifaces_supported = join(' ', parts);
			env.webui_interfaces = webui_parts;
			env.webui_interface_labels = webui_labels;
		}

		// Discover gateways
		if (!env.uplink_gw) {
			let dev4 = network_get_device(cfg.uplink_interface4) || network_get_physdev(cfg.uplink_interface4) || '';
			let gw4 = get_gateway4(cfg.uplink_interface4, dev4);
			env.uplink_gw4 = gw4 || '';
			if (cfg.ipv6_enabled && cfg.uplink_interface6) {
				let dev6 = network_get_device(cfg.uplink_interface6) || network_get_physdev(cfg.uplink_interface6) || dev4;
				let gw6 = get_gateway6(cfg.uplink_interface6, dev6);
				env.uplink_gw6 = gw6 || '';
			}
			env.uplink_gw = env.uplink_gw4 || env.uplink_gw6 || '';
		}
	}

	function is_wan_up(param, errors) {
		let ctx = config.uci_ctx('network');
		if (!ctx.get('network', cfg.uplink_interface4)) {
			push(errors, { code: 'errorNoUplinkInterface', info: cfg.uplink_interface4 });
			push(errors, { code: 'errorNoUplinkInterfaceHint', info: pkg.url('#uplink_interface') });
			return false;
		}
		config.network_flush_cache();
		load(param);
		if (env.uplink_gw) {
			return true;
		} else {
			push(errors, { code: 'errorNoUplinkGateway' });
			return false;
		}
	}

	return {
		network_get_device,
		network_get_physdev,
		network_get_gateway,
		network_get_gateway6,
		network_get_ipaddr,
		network_get_ipaddr6,
		network_get_protocol,
		uci_get_device,
		is_dslite, is_l2tp, is_oc, is_ovpn, is_pptp,
		is_softether, is_netbird, is_tailscale,
		is_wg, is_wg_server, is_tor, is_xray, is_xfrm_interface, is_tunnel,
		get_xray_traffic_port,
		is_point_to_point, is_xfrm, is_p2p,
		is_wan, is_uplink, is_uplink4, is_uplink6, is_split_uplink,
		is_default_dev, is_disabled_interface, is_lan,
		is_ignored_interface, is_tor_running, is_tor_configured,
		is_ignore_target, is_netifd_table, is_netifd_interface,
		is_mwan4_interface, is_netifd_interface_default,
		is_supported_protocol, proto_has_ports, is_mwan4_strategy,
		is_supported_interface, is_config_enabled,
		get_gateway4, get_gateway6,
		get_ipaddr4, get_ipaddr6,
		load, is_wan_up,
	};
}

export default create_network;
