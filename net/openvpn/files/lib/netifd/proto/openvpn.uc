#!/usr/bin/env ucode
'use strict';

import * as fs from 'fs';

const OPENVPN = '/usr/sbin/openvpn';
const OPENVPN_PASS   = '/var/run/openvpn.%s.pass';
const OPENVPN_AUTH   = '/var/run/openvpn.%s.auth';
const OPENVPN_PID    = '/var/run/openvpn.%s.pid';
const OPENVPN_STATUS = '/var/run/openvpn.%s.status';


function openvpn_exists() {
	return fs.access(OPENVPN, fs.F_OK);
}

/* --- option lists (mirrors files/openvpn.options) --- */
const OPENVPN_STRING_PARAMS = [
	{ name: 'allow_compression', deprecated: true },
	{ name: 'auth' },
	{ name: 'auth_gen_token' },
	{ name: 'auth_gen_token_secret' },
	{ name: 'auth_retry' },
	{ name: 'auth_user_pass_verify' },
	{ name: 'bind_dev' },
	{ name: 'capath' },
	{ name: 'chroot' },
	{ name: 'cipher' },
	{ name: 'client_config_dir' },
	{ name: 'client_connect' },
	{ name: 'client_crresponse' },
	{ name: 'client_disconnect' },
	{ name: 'client_nat' },
	{ name: 'comp_lzo', deprecated: true },
	{ name: 'compress', deprecated: true },
	{ name: 'connect_freq' },
	{ name: 'connect_freq_initial' },
	{ name: 'crl_verify' },
	{ name: 'data_ciphers_fallback' },
	{ name: 'dev' },
	{ name: 'dev_node' },
	{ name: 'dev_type' },
	{ name: 'dhcp_option' },
	{ name: 'dns' },
	{ name: 'down' },
	{ name: 'ecdh_curve' },
	{ name: 'echo' },
	{ name: 'engine' },
	{ name: 'fragment' },
	{ name: 'group' },
	{ name: 'hash_size' },
	{ name: 'http_proxy' },
	{ name: 'http_proxy_option' },
	{ name: 'http_proxy_user_pass' },
	{ name: 'ifconfig' },
	{ name: 'ifconfig_ipv6' },
	{ name: 'ifconfig_ipv6_pool' },
	{ name: 'ifconfig_ipv6_push' },
	{ name: 'ifconfig_pool' },
	{ name: 'ifconfig_pool_persist' },
	{ name: 'ifconfig_push' },
	{ name: 'inactive' },
	{ name: 'ipchange' },
	{ name: 'iproute' },
	{ name: 'iroute' },
	{ name: 'iroute_ipv6' },
	{ name: 'keepalive' },
	{ name: 'keying_material_exporter' },
	{ name: 'learn_address' },
	{ name: 'lladdr' },
	{ name: 'local' },
	{ name: 'log' },
	{ name: 'log_append' },
	{ name: 'management' },
	{ name: 'management_client_group' },
	{ name: 'management_client_user' },
	{ name: 'management_external_cert' },
	{ name: 'management_external_key' },
	{ name: 'mark' },
	{ name: 'mode' },
	{ name: 'mtu_disc' },
	{ name: 'ovpnproto' },
	{ name: 'peer_fingerprint' },
	{ name: 'pkcs11_id' },
	{ name: 'pkcs11_providers' },
	{ name: 'plugin' },
	{ name: 'port_share' },
	{ name: 'proto_force' },
	{ name: 'providers' },
	{ name: 'pull_filter' },
	{ name: 'push' },
	{ name: 'push_remove' },
	{ name: 'redirect_gateway' },
	{ name: 'redirect_private' },
	{ name: 'remap_usr1' },
	{ name: 'remote_cert_eku' },
	{ name: 'remote_cert_ku' },
	{ name: 'remote_cert_tls' },
	{ name: 'replay_persist' },
	{ name: 'replay_window' },
	{ name: 'resolv_retry' },
	{ name: 'route' },
	{ name: 'route_delay' },
	{ name: 'route_gateway' },
	{ name: 'route_ipv6' },
	{ name: 'route_ipv6_gateway' },
	{ name: 'route_pre_down' },
	{ name: 'route_up' },
	{ name: 'server' },
	{ name: 'server_bridge' },
	{ name: 'server_ipv6' },
	{ name: 'setcon' },
	{ name: 'socket_flags' },
	{ name: 'socks_proxy' },
	{ name: 'stale_routes_check' },
	{ name: 'static_challenge' },
	{ name: 'tls_auth' },
	{ name: 'tls_cert_profile' },
	{ name: 'tls_crypt_v2_verify' },
	{ name: 'tls_export_cert' },
	{ name: 'tls_verify' },
	{ name: 'tls_version_max' },
	{ name: 'tls_version_min' },
	{ name: 'tmp_dir' },
	{ name: 'topology' },
	{ name: 'up' },
	{ name: 'user' },
	{ name: 'verify_client_cert' },
	{ name: 'verify_hash', deprecated: true },
	{ name: 'verify_x509_name' },
	{ name: 'vlan_accept' },
	{ name: 'x509_track' },
	{ name: 'x509_username_field' }
];

const OPENVPN_FILE_PARAMS = [
	{ name: 'askpass' },
	{ name: 'auth_user_pass' },
	{ name: 'ca' },
	{ name: 'cert' },
	{ name: 'config' },
	{ name: 'dh' },
	{ name: 'extra_certs' },
	{ name: 'extra_certs' },
	{ name: 'http_proxy_user_pass' },
	{ name: 'key' },
	{ name: 'pkcs12' },
	{ name: 'secret', deprecated: true },
	{ name: 'tls_crypt' },
	{ name: 'tls_crypt_v2' },
];

const OPENVPN_INT_PARAMS = [
	{ name: 'nice' }
];

const OPENVPN_UINT_PARAMS = [
	{ name: 'auth_gen_token_lifetime' },
	{ name: 'bcast_buffers' },
	{ name: 'connect_retry' },
	{ name: 'connect_retry_max' },
	{ name: 'connect_timeout' },
	{ name: 'explicit_exit_notify' },
	{ name: 'hand_window' },
	{ name: 'key_direction' },
	{ name: 'link_mtu', deprecated: true },
	{ name: 'lport' },
	{ name: 'management_log_cache' },
	{ name: 'max_clients' },
	{ name: 'max_packet_size' },
	{ name: 'max_routes_per_client' },
	{ name: 'mssfix' },
	{ name: 'mute' },
	{ name: 'ping' },
	{ name: 'ping_exit' },
	{ name: 'ping_restart' },
	{ name: 'pkcs11_cert_private' },
	{ name: 'pkcs11_pin_cache' },
	{ name: 'pkcs11_private_mode' },
	{ name: 'pkcs11_protected_authentication' },
	{ name: 'port' },
	{ name: 'rcvbuf' },
	{ name: 'reneg_bytes' },
	{ name: 'reneg_pkts' },
	{ name: 'reneg_sec' },
	{ name: 'route_metric' },
	{ name: 'rport' },
	{ name: 'script_security' },
	{ name: 'server_poll_timeout' },
	{ name: 'session_timeout' },
	{ name: 'shaper' },
	{ name: 'sndbuf' },
	{ name: 'socks_proxy_retry' },
	{ name: 'status_version' },
	{ name: 'tcp_queue_limit' },
	{ name: 'tls_timeout' },
	{ name: 'tran_window' },
	{ name: 'tun_max_mtu' },
	{ name: 'tun_mtu' },
	{ name: 'tun_mtu_extra' },
	{ name: 'txqueuelen' },
	{ name: 'up_delay' },
	{ name: 'verb' },
	{ name: 'vlan_pvid' }
];

const OPENVPN_BOOL_PARAMS = [
	{ name: 'allow_pull_fqdn' },
	{ name: 'allow_recursive_routing' },
	{ name: 'auth_nocache' },
	{ name: 'auth_user_pass_optional' },
	{ name: 'bind' },
	{ name: 'block_ipv6' },
	{ name: 'ccd_exclusive' },
	{ name: 'client' },
	{ name: 'client_to_client' },
	{ name: 'comp_noadapt', deprecated: true },
	{ name: 'disable_dco' },
	{ name: 'disable_occ' },
	{ name: 'down_pre' },
	{ name: 'duplicate_cn' },
	{ name: 'errors_to_stderr' },
	{ name: 'fast_io' },
	{ name: 'float' },
	{ name: 'force_tls_key_material_export' },
	{ name: 'ifconfig_noexec' },
	{ name: 'ifconfig_nowarn' },
	{ name: 'machine_readable_output' },
	{ name: 'management_client' },
	{ name: 'management_client_auth' },
	{ name: 'management_forget_disconnect' },
	{ name: 'management_hold' },
	{ name: 'management_query_passwords' },
	{ name: 'management_query_proxy' },
	{ name: 'management_query_remote' },
	{ name: 'management_signal' },
	{ name: 'management_up_down' },
	{ name: 'mktun' },
	{ name: 'mlock' },
	{ name: 'mtu_test' },
	{ name: 'multihome' },
	{ name: 'mute_replay_warnings' },
	{ name: 'nobind' },
	{ name: 'opt_verify', deprecated: true },
	{ name: 'passtos' },
	{ name: 'persist_key' },
	{ name: 'persist_local_ip' },
	{ name: 'persist_remote_ip' },
	{ name: 'persist_tun' },
	{ name: 'ping_timer_rem' },
	{ name: 'pkcs11_id_management' },
	{ name: 'pull' },
	{ name: 'push_peer_info' },
	{ name: 'push_reset' },
	{ name: 'remote_random' },
	{ name: 'remote_random_hostname' },
	{ name: 'rmtun' },
	{ name: 'route_noexec' },
	{ name: 'route_nopull' },
	{ name: 'single_session' },
	{ name: 'suppress_timestamps' },
	{ name: 'tcp_nodelay' },
	{ name: 'test_crypto' },
	{ name: 'tls_client' },
	{ name: 'tls_exit' },
	{ name: 'tls_server' },
	{ name: 'up_restart' },
	{ name: 'use_prediction_resistance' },
	{ name: 'username_as_common_name' },
	{ name: 'vlan_tagging' }
];

const OPENVPN_LIST_PARAMS = [
	{ name: 'data_ciphers' },
	{ name: 'disable' },
	{ name: 'ignore_unknown_option' },
	{ name: 'push' },
	{ name: 'remote' },
	{ name: 'route' },
	{ name: 'setenv' },
	{ name: 'setenv_safe' },
	{ name: 'tls_cipher' },
	{ name: 'tls_ciphersuites' },
	{ name: 'tls_groups' }
];

/*
const PROTO_BOOLS = [
	{ name: 'allow_deprecated' }
];
const PROTO_STRINGS = [
	{ name: 'username' },
	{ name: 'password' },
	{ name: 'cert_password' }
];
*/

function is_true(v) {
	return v === true || v === '1' || v === 1 || v === 'true';
}

function add_param(params, key, value) {
	// key: option name (underscored), value: single string
	let flag = `--${replace(key, '_', '-')}`;
	push(params, flag);
	if (value)
		push(params, value);
}

function build_exec_params(cfg) {
	let params = [];
	let allow_deprecated = is_true(cfg.allow_deprecated) ? 1 : 0;

	for (let v in OPENVPN_BOOL_PARAMS) {
		if (v?.deprecated && !allow_deprecated) continue;
		if(cfg && cfg[v.name]) {
			let val = cfg[v.name];
			if (is_true(val))
				add_param(params, v.name);
		}
	}

	function add_param_loop(array, param_array) {
		for (let k in param_array) {
			if (k?.deprecated && !allow_deprecated) continue;
			let val = cfg[k.name];
			if (!val) continue;
			add_param(array, k.name, `${val}`);
		}
	}

	add_param_loop(params, OPENVPN_UINT_PARAMS);
	add_param_loop(params, OPENVPN_INT_PARAMS);
	add_param_loop(params, OPENVPN_STRING_PARAMS);

	for (let k in OPENVPN_FILE_PARAMS) {
		if (k?.deprecated && !allow_deprecated) continue;
		let val = cfg[k.name];
		if (val && type(val) == 'string') {
			if (fs.access(val, fs.F_OK))
				add_param(params, k.name, val);
		}
	}

	for (let k in OPENVPN_LIST_PARAMS) {
		if (k?.deprecated && !allow_deprecated) continue;
		let val = cfg[k.name];
		if (!val)
			continue;

		if (type(val) == 'array') {
			for (let e in val) {
				add_param(params, k.name, e);
			}
		} else {
			// split space separated list
			let items = split(val, ' ');
			for (let item in items)
				if (item !== '')
					add_param(params, k.name, item);
		}
	}

	return params;
}

function write_file(path, content) {
	let fd = fs.open(path, 'w');
	if (!fd)
		return false;
	fd.write(content);
	fd.close();
	// ensure restrictive permissions
	fs.chmod(path, 0o600);
	return true;
}

function pid_from_file(path) {
	let f = fs.open(path, 'r');
	if (!f) return null;
	let data = rtrim(f.read('all'));
	f.close();
	if (!data) return null;
	return data;
}

function proto_setup(proto) {
	if (!openvpn_exists()) {
		warn('OpenVPN binary not found at ' + OPENVPN + '\n');
		proto.setup_failed();
		return;
	}

	let iface = proto.iface;
	let cfg = proto.config || {};

	let params = build_exec_params(cfg);

	// handle secret / askpass (cert_password)
	let passfile = null;
	if (cfg.cert_password && `${cfg.cert_password}` !== '') {
		passfile = sprintf(OPENVPN_PASS, iface);
		write_file(passfile, `${cfg.cert_password}`);
		push(params, `--askpass`);
		push(params, passfile);
	} else if (cfg.askpass) {
		push(params, `--askpass`);
		push(params, cfg.askpass);
	}

	// handle auth-user-pass
	let authfile = null;
	if ((cfg.username && cfg.username !== '') && (cfg.password && cfg.password !== '')) {
		authfile = sprintf(OPENVPN_AUTH, iface);
		write_file(authfile, sprintf('%s\n%s\n', cfg.username, cfg.password));
		push(params, `--auth-user-pass`);
		push(params, authfile);
	} else if (cfg.auth_user_pass) {
		push(params, `--auth-user-pass`);
		push(params, cfg.auth_user_pass);
	}

	// default dev-type tun if not provided
	let has_dev_type = false;
	for (let param in params) {
		if (rindex(param, '--dev-type') !== -1 ) {
			has_dev_type = true;
		}
	}

	if (!has_dev_type) {
		push(params, '--dev-type');
		push(params, 'tun');
	}

	let statusfile = sprintf(OPENVPN_STATUS, iface);
	let cd_dir = '/';
	if (cfg.config && cfg.config !== '') {
		if (index(cfg.config, '/') >= 0) {
			let parts = split(cfg.config, '/');
			parts.pop();
			cd_dir = join('/', parts);
			if (cd_dir == '') cd_dir = `/etc/openvpn/${iface}`;
		}
	}

	// assemble the final command line
	let cmd = [
		OPENVPN,
		'--cd', cd_dir,
		'--status', statusfile,
		'--syslog', sprintf('openvpn_%s', iface),
		'--tmp-dir', '/var/run',
		'--writepid', sprintf(OPENVPN_PID, iface),
		// join(' ', params)
		...params
	];

	// run_command needs an argv array
	proto.run_command(cmd);

	// do not call proto.update_link() here - OpenVPN will handle if_up
}

function proto_renew(proto) {
	let iface = proto.iface;
	let pidfile = sprintf(OPENVPN_PID, iface);
	let pid = pid_from_file(pidfile);
	if (pid) {
		system(sprintf('kill -SIGUSR1 %s 2>/dev/null || true', pid));
		return;
	}
	warn('openvpn: renew requested but pidfile missing for ' + iface + '\n');
}

function proto_teardown(proto) {
	let iface = proto.iface;

	// Allow OpenVPN's down script to process

	sleep(700);

	// best-effort cleanup
	fs.unlink(sprintf(OPENVPN_PASS, iface));
	fs.unlink(sprintf(OPENVPN_AUTH, iface));
	fs.unlink(sprintf(OPENVPN_STATUS, iface));
	fs.unlink(sprintf(OPENVPN_PID, iface));

	let link_data = {
		ifname: iface
	};

	proto.kill_command();

	// remove the link
	proto.update_link(true, link_data);
}

netifd.add_proto({
	available: true,
	no_device: true,
	'renew-handler': true,
	name: 'openvpn',

	config: function(ctx) {
		// keep user-provided fields, ensure allow_deprecated default
		return {
			...ctx.data,
			allow_deprecated: ctx.data.allow_deprecated ?? '0'
		};
	},

	setup: proto_setup,
	teardown: proto_teardown,
	renew: proto_renew
});
