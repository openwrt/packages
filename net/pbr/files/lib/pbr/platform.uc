'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// Platform detection, download helpers, AGH config discovery.

function create_platform(fs_mod, config, sh, pkg, V) {
	let readfile = fs_mod.readfile;
	let stat = fs_mod.stat;
	let unlink = fs_mod.unlink;
	let _dirname = fs_mod.dirname;

	let cfg = config.cfg;

	let env = {
		nft_installed: false,
		dnsmasq_installed: false,
		unbound_installed: false,
		adguardhome_installed: false,
		dnsmasq_features: '',
		dnsmasq_nftset_supported: false,
		resolver_set_supported: false,
		agh_config_file: '/etc/AdGuardHome/AdGuardHome.yaml',

		firewall_wan_zone: '',
		ifaces_supported: '',
		webui_interfaces: [],
		webui_interface_labels: {},
		uplink_gw: '',
		uplink_gw4: '',
		uplink_gw6: '',

		_dl_cache: null,

		tor_dns_port: '',
		tor_traffic_port: '',

		netifd_mark: {},
		mwan4_mark: {},
		mwan4_interface_chain: {},
		mwan4_strategy_chain: {},

		_config_loaded: false,
		_loaded: false,
		_detected: false,
		_network_output_done: false,

		protocols: {},
	};

	function is_mwan4_installed() {
		return fs_mod.access('/etc/init.d/mwan4', 'x') == true && stat('/etc/config/mwan4')?.type != null;
	}

	function is_mwan4_running() {
		if (!is_mwan4_installed()) return false;
		return sh.run('/etc/init.d/mwan4 running') == 0;
	}

	function detect() {
		if (env._detected) return;
		env.nft_installed = sh.is_present('nft');
		env.dnsmasq_installed = sh.is_present('dnsmasq');
		env.unbound_installed = sh.is_present('unbound');
		let agh = sh.exec('command -v AdGuardHome');
		if (agh && sh.is_present(agh)) {
			let content = readfile(env.agh_config_file);
			if (content && content != '') {
				env.adguardhome_installed = true;
			} else {
				let alt = _dirname(agh) + '/AdGuardHome.yaml';
				content = readfile(alt);
				env.adguardhome_installed = !!(content && content != '');
			}
		}
		if (env.dnsmasq_installed) {
			if (!env.dnsmasq_features)
				env.dnsmasq_features = sh.exec("dnsmasq --version 2>/dev/null | grep -m1 'Compile time options:' | cut -d: -f2") + ' ';
			env.dnsmasq_nftset_supported = index(env.dnsmasq_features, ' nftset ') >= 0;
		}
		if (cfg.resolver_set == 'dnsmasq.nftset') {
			env.resolver_set_supported = !!env.dnsmasq_nftset_supported;
		} else {
			env.resolver_set_supported = !cfg.resolver_set || cfg.resolver_set == 'none' || false;
		}
		// Parse external marks from netifd/mwan4 nft files
		let define_re = regexp('^define ' + pkg.nft_prefix + '_(\\S+)_mark = (\\S+)');
		let netifd_nft = readfile(pkg.nft_netifd_file) || '';
		for (let line in split(netifd_nft, '\n')) {
			let m = match(line, define_re);
			if (m) env.netifd_mark[m[1]] = m[2];
		}
		// mwan4 marks, chains, strategies — relies on the mwan4 ucode
		// module being loadable. Fallbacks to file parsing have been
		// dropped: current mwan4 doesn't emit the per-iface define-style
		// lines pbr would need, and the file naming has changed too.
		if (is_mwan4_installed()) {
			let m4 = null;
			try { m4 = require('mwan4'); m4.load(); } catch(e) {}
			if (m4) {
				for (let iface in m4.get_interfaces()) {
					let mark = m4.get_iface_mark(iface);
					if (mark) env.mwan4_mark[iface] = mark;
					env.mwan4_interface_chain[iface] = m4.get_iface_chain(iface);
				}
				for (let strategy in m4.get_strategies())
					env.mwan4_strategy_chain[strategy] = m4.get_strategy_chain(strategy);
			}
		}
		// Cache supported protocols from /etc/protocols
		let proto_content = readfile('/etc/protocols') || '';
		for (let line in split(proto_content, '\n')) {
			if (!line || substr(line, 0, 1) == '#') continue;
			let m = match(line, /^(\S+)/);
			if (m) env.protocols[lc(m[1])] = true;
		}

		env._detected = true;
	}

	function detect_agh_config() {
		if (sh.is_present('AdGuardHome')) {
			let agh_path = sh.exec('command -v AdGuardHome');
			if (agh_path) {
				let content = readfile(env.agh_config_file);
				if (!content || content == '') {
					let alt = _dirname(agh_path) + '/AdGuardHome.yaml';
					content = readfile(alt);
					if (content && content != '')
						env.agh_config_file = alt;
				}
			}
		}
	}

	function is_running_nft_file() {
		let s = stat(pkg.nft_main_file);
		return s != null && s.type == 'file' && s.size > 0;
	}

	function get_downloader() {
		if (env._dl_cache) return env._dl_cache;
		let command, flag, https_supported;
		if (sh.is_present('curl')) {
			command = 'curl --silent --insecure';
			flag = '-o';
		} else if (sh.is_present('/usr/libexec/wget-ssl')) {
			command = '/usr/libexec/wget-ssl --no-check-certificate -q';
			flag = '-O';
		} else if (sh.exec('wget --version 2>/dev/null | grep -q "+https" && echo yes') == 'yes') {
			command = 'wget --no-check-certificate -q';
			flag = '-O';
		} else {
			command = 'uclient-fetch --no-check-certificate -q';
			flag = '-O';
		}
		if (sh.exec('curl --version 2>/dev/null | grep -q "Protocols: .*https.*" && echo yes') == 'yes' ||
			sh.exec('wget --version 2>/dev/null | grep -q "+ssl" && echo yes') == 'yes') {
			https_supported = true;
		}
		env._dl_cache = { command, flag, https_supported };
		return env._dl_cache;
	}

	function process_url(url, errors) {
		let _sanitize_list = function(filepath) {
			let content = readfile(filepath) || '';
			let lines = split(content, '\n');
			let seen = {}, results = [];
			for (let line in lines) {
				line = replace(line, /#.*/, '');
				line = trim(line);
				if (line && !seen[line]) {
					seen[line] = true;
					push(results, line);
				}
			}
			sort(results);
			return join(' ', results);
		};

		let dl = get_downloader();

		let dl_temp_file = sh.exec('mktemp -q -t ' + sh.quote(pkg.name + '_tmp.XXXXXXXX'));
		if (!dl_temp_file || !stat(dl_temp_file)) {
			push(errors, { code: 'errorMktempFileCreate', info: pkg.name + '_tmp.XXXXXXXX' });
			return '';
		}

		let result = '';
		if (V.is_url_file(url) && !sh.is_present('curl')) {
			push(errors, { code: 'errorFileSchemaRequiresCurl', info: url });
		} else if (V.is_url_https(url) && !dl.https_supported) {
			push(errors, { code: 'errorDownloadUrlNoHttps', info: url });
		} else if (sh.run(dl.command + ' ' + sh.quote(url) + ' ' + dl.flag + ' ' + sh.quote(dl_temp_file)) == 0) {
			result = _sanitize_list(dl_temp_file);
		} else {
			push(errors, { code: 'errorDownloadUrl', info: url });
		}

		unlink(dl_temp_file);
		return result;
	}

	return {
		env,
		detect,
		detect_agh_config,
		is_running_nft_file,
		is_mwan4_installed,
		is_mwan4_running,
		get_downloader,
		process_url,
	};
}

export default create_platform;
