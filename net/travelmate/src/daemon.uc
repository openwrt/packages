// travelmate - connection manager: the run cycle and its system actions,
// the decisions come from the other modules

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { readfile, writefile, rename, unlink, stat, access, mkdir, realpath, popen, open } from 'fs';
import { cursor } from 'uci';
import { connect as ubus_connect } from 'ubus';
import { RUNDIR, FETCH_TIMEOUT, global as cfg_global, typed, words, fetch_args, capture, have } from 'travelmate.common';
import { rank as scan_rank, report as scan_report } from 'travelmate.scan';
import { plan as select_plan, normbssid } from 'travelmate.select';
import { classify as net_classify, debug as net_debug, hostname, MARKER } from 'travelmate.net';
import { queries as probe_queries, ready as probe_ready } from 'travelmate.probe';
import { init as check_init, round as check_round } from 'travelmate.check';
import { sta_info, compose as status_compose } from 'travelmate.status';
import { load as uplink_load, ref as uplink_ref, option as uplink_option } from 'travelmate.uplink';
import { plan as vpn_plan, infolist as vpn_infolist, service as vpn_service } from 'travelmate.vpn';

export const FILES = {
	ntplock: RUNDIR + '/travelmate.ntp.lock',
	vpnfile: RUNDIR + '/travelmate.vpn',
	mailfile: RUNDIR + '/travelmate.mail',
	refreshfile: RUNDIR + '/travelmate.refresh',
	pidfile: RUNDIR + '/travelmate.pid',
	scanfile: RUNDIR + '/travelmate.scan',
	rtfile: RUNDIR + '/travelmate.runtime.json',
	revivefile: RUNDIR + '/travelmate.revive',
	actionfile: RUNDIR + '/travelmate.action'
};

// the system side, replaceable for tests
export function system_io(log_fn) {
	let conn = null;

	return {
		log: log_fn,
		// libubus calls uloop_init(), which catches SIGTERM/SIGINT; restore
		// the default action so procd can stop the daemon at once
		ubus: () => {
			if (conn == null) {
				conn = ubus_connect();
				signal('SIGTERM', 'default');
				signal('SIGINT', 'default');
			}

			return conn;
		},
		// run directly (no shell), return the exit code
		exec: (argv) => system(argv),
		capture,
		sleep: (s) => { if (s > 0) sleep(s * 1000); },
		time: () => {
			let t = localtime();

			return sprintf('%04d-%02d-%02d %02d:%02d:%02d', t.year, t.mon, t.mday, t.hour, t.min, t.sec);
		},
		random: (n) => {
			let fh = open('/dev/urandom', 'r');
			let b = fh?.read(n) ?? '';

			fh?.close();

			return b;
		}
	};
};

function dash(v) {
	return length('' + (v ?? '')) ? '' + v : '-';
}

// flags in debug lines
function b(v) {
	return v ? '1' : '0';
}

// interface status in debug lines: true, false, error or empty
function st_text(v) {
	return (v == null) ? '' : '' + v;
}

function is_file(p) {
	return stat(p)?.type == 'file';
}

function is_dir(p) {
	return stat(p)?.type == 'directory';
}

function touch_once(path, text) {
	if (!is_file(path))
		writefile(path, text);
}

// radio, essid and bssid of a 'radio/essid/bssid' station id: radio up to
// the first '/', bssid after the last one, the essid in between
function split_id(id) {
	let first = index(id, '/'), last = rindex(id, '/');
	let head = (last >= 0) ? substr(id, 0, last) : id;
	let i = index(head, '/');

	return {
		radio: (first >= 0) ? substr(id, 0, first) : id,
		essid: (i >= 0) ? substr(head, i + 1) : head,
		bssid: (last >= 0) ? substr(id, last + 1) : id
	};
}

// network address of 'a.b.c.d/len'
function network_of(cidr) {
	let m = match(cidr ?? '', /^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\/([0-9]+)$/);

	if (!m)
		return '';

	let len = +m[5], out = [];

	for (let i = 0; i < 4; i++) {
		let bits = len - i * 8;
		let mask = (bits >= 8) ? 255 : ((bits <= 0) ? 0 : (0xff << (8 - bits)) & 0xff);

		push(out, '' + (+m[i + 1] & mask));
	}

	return join('.', out);
}

export function create(io, files) {
	files ??= FILES;

	// ifstatus: null (unknown), true, false or 'error'; conn: the net
	// state of an up uplink, { result, quality } or null
	let T = {
		action: '', runmode: '', ifstatus: null, conn: null, active: false, wifireload: true,
		radiolist: [], stalist: [], activesta: '', uplinkcfg: '', vpnlist: [],
		subnet: '', subnet_last: '', lannet: '',
		fver: '', bver: '', sysver: '', cores: 1, fetch: [], cfg: cfg_global(cursor()),
		c: null, uplinks: null, mailcmd: false, noted: {}
	};

	let c = () => T.c ??= cursor();
	let uplinks = () => T.uplinks ??= uplink_load(c());
	let cfg = (k) => T.cfg['trm_' + k];

	// connection text like 'net ok/90', the net state alone like 'net ok'
	let conn_text = () => T.conn ? T.conn.result + '/' + (T.conn.quality ?? '') : '';
	let conn_net = () => T.conn?.result ?? '';

	// every change is saved as a delta right away, like the uci cli did
	function uci_set(config, section, option, value) {
		c().set(config, section, option, value);
		c().save(config);
		T.uplinks = null;
	}

	function uci_delete(config, section, option) {
		c().delete(config, section, option);
		c().save(config);
		T.uplinks = null;
	}

	function uci_changes(config) {
		// only a fresh cursor sees the saved deltas
		let ch = cursor().changes(config);

		return length((type(ch) == 'array') ? ch : (ch?.[config] ?? [])) > 0;
	}

	function uci_commit(config) {
		c().commit(config);
		T.uplinks = null;
	}

	function uci_revert(config) {
		c().revert(config);
		T.c = null;
		T.uplinks = null;
	}

	// option of the current uplink, dflt if unset or there is none
	function getval(option, dflt) {
		return uplink_option(uplinks(), T.uplinkcfg, option, dflt ?? '');
	}

	function getcfg(radio, essid, bssid) {
		T.uplinkcfg = uplink_ref(uplinks(), radio ?? '', essid ?? '', bssid ?? '');
	}

	function wireless_status() {
		return io.ubus()?.call('network.wireless', 'status');
	}

	// genstatus is used before its definition
	let genstatus;

	function log(class, msg) {
		if (!length(msg ?? '') || (class == 'debug' && !cfg('debug')))
			return;

		io.log(class, 'trm-' + dash(T.bver), substr(msg, 0, 512));

		if (class == 'err' || class == 'emerg') {
			T.ifstatus = 'error';

			if (length(readfile(files.rtfile) ?? '') && length(T.bver))
				genstatus();

			writefile(files.pidfile, '');
			exit(1);
		}
	}

	// system information, once per daemon run
	function system_info() {
		let pkgs = io.ubus()?.call('rpc-sys', 'packagelist', { all: true })?.packages ?? {};
		let b = io.ubus()?.call('system', 'board') ?? {};
		let r = b.release ?? {};
		let v = (x) => (x == null) ? '' : '' + x;

		T.fver = v(pkgs['luci-app-travelmate']);
		T.bver = v(pkgs['travelmate']);
		T.sysver = sprintf('%s, %s, %s %s (%s)', v(b.model), v(r.target), v(r.distribution), v(r.version), v(r.revision));

		let n = 0;

		for (let l in split(readfile('/proc/cpuinfo') ?? '', '\n'))
			if (match(l, /^processor/) && ++n >= 16)
				break;

		T.cores = (n > 0) ? n : 1;
	}

	// wifi reload, then poll each radio until it is up and not pending
	function wifi() {
		let timeout = 0, radio_up = '', radio = '', maxwait = cfg('maxwait'), over = false;

		io.exec([ 'wifi', 'reload' ]);

		for (radio in T.radiolist) {
			while (true) {
				if (timeout >= maxwait) {
					over = true;
					break;
				}

				let s = wireless_status()?.[radio];

				if (s?.up !== true || s?.pending !== false) {
					if (radio != radio_up) {
						io.exec([ 'wifi', 'up', radio ]);
						radio_up = radio;
					}

					timeout++;
					io.sleep(1);
				}
				else {
					break;
				}
			}

			if (over)
				break;
		}

		if (timeout < maxwait) {
			io.sleep(int(maxwait / 6));
			timeout += int(maxwait / 6);
		}

		log('debug', sprintf('f_wifi      ::: radio_list: %s, ssid_filter: %s, radio: %s, timeout: %d',
			join(' ', T.radiolist), dash(join(' ', cfg('ssidfilter'))), radio, timeout));
	}

	// interfaces via netifd, like ifdown and ifup (which reloads the network
	// config first, so a removed interface comes back)
	function if_down(iface) {
		io.ubus()?.call('network.interface', 'down', { interface: iface });
	}

	function if_up(iface) {
		io.ubus()?.call('network', 'reload');
		io.ubus()?.call('network.interface', 'down', { interface: iface });
		io.ubus()?.call('network.interface', 'up', { interface: iface });
	}

	function if_remove(iface) {
		io.ubus()?.call('network.interface.' + iface, 'remove');
	}

	// true, false or null if the interface is unknown
	function iface_up(iface) {
		let v = io.ubus()?.call('network.interface.' + iface, 'status')?.up;

		return (type(v) == 'bool') ? v : null;
	}

	// objects already on ubus need no 'ubus wait_for' process
	function wait_for(timeout, ...objs) {
		let have_all = true;

		for (let o in objs) {
			let l = null;

			try { l = io.ubus()?.list(o); } catch (e) { }

			if (!length(l)) {
				have_all = false;
				break;
			}
		}

		return have_all || io.exec([ 'ubus', '-t', '' + timeout, 'wait_for', ...objs ]) == 0;
	}

	// the curl status probe of the vpn handling
	function vpn_net() {
		let rc = io.capture([ 'curl', ...T.fetch, '--user-agent', cfg('useragent'),
			'--header', 'Cache-Control: no-cache, no-store, must-revalidate, max-age=0',
			'--write-out', '%{response_code}', '--output', '/dev/null', cfg('captiveurl') ]).out;

		return (rc == '200' || rc == '204') ? 'net ok' : rc;
	}

	// start, keep or stop the vpn connection of an uplink
	function vpn_program(action, iface, service) {
		let maxwait = cfg('maxwait');

		if (action == 'disable') {
			if_down(iface);
			if_remove(iface);
			unlink(files.vpnfile);
			log('info', sprintf("%s client connection disabled '%s'", service, iface));

			return 0;
		}

		let status = (action == 'enable_keep') ? iface_up(iface) : null;

		log('debug', sprintf('f_vpnpgm    ::: action: %s, interface: %s, status: %s',
			action, iface, dash(st_text(status))));

		if (status === true)
			return 0;

		if_down(iface);
		if_remove(iface);
		io.sleep(1);
		if_up(iface);

		if (!wait_for(int(maxwait / 6), 'network.interface.' + iface))
			log('info', sprintf("travelmate vpn interface '%s' does not appear on ubus on ifup event", iface));

		let net_status = '';

		for (let cnt = 0; ; cnt++) {
			if (iface_up(iface) === true) {
				net_status = vpn_net();

				if (net_status == 'net ok') {
					writefile(files.vpnfile, '');
					log('info', sprintf("%s client connection enabled '%s'", service, iface));

					return 0;
				}
			}

			if (cnt >= int(maxwait / 3)) {
				if_down(iface);
				if_remove(iface);
				unlink(files.vpnfile);
				log('info', sprintf("%s client connection can't be established '%s' (rc: %s)", service, iface, dash(net_status)));

				return 1;
			}

			io.sleep(1);
		}
	}

	function vpn_handle(action) {
		let rc = null;
		let up = { vpn: getval('vpn') == '1', iface: getval('vpniface'), service: '' };

		if (length(up.iface))
			up.service = vpn_service(c().get_all('network', up.iface));

		let p = vpn_plan({
			vpn: cfg('vpn'), list: T.vpnlist, action, connection: conn_net() == 'net ok',
			connected: is_file(files.vpnfile), ntp: is_dir(files.ntplock)
		}, up, (iface) => iface_up(iface) === true);

		for (let s in p.steps) {
			switch (s.op) {
			case 'down':
				if_down(s.iface);

				if (s.why == 'initial')
					if_remove(s.iface);

				log('info', sprintf("take down vpn interface '%s' (%s)", s.iface, (s.why == 'initial') ? 'cleanup' : 'uplink switch'));
				break;

			case 'clear':
				unlink(files.vpnfile);
				io.sleep(1);
				break;

			case 'rc':
				rc = 1;
				break;

			case 'pgm':
				rc = vpn_program(s.action, s.iface, s.service);
				break;
			}
		}

		if (p.pgm && rc != null)
			genstatus();

		log('debug', sprintf('f_vpn       ::: vpn: %s, enabled: %s, action: %s, vpn_service: %s, vpn_iface: %s, vpn_infolist: %s, connection: %s, rc: %s',
			b(cfg('vpn')), b(up.vpn), action, dash(up.service), dash(up.iface),
			dash(join(' ', T.vpnlist)), conn_net(), dash(rc)));
	}

	// a random unicast LAA mac, second nibble 2, 6, A or E
	function random_mac() {
		let r = io.random(7), out = [];

		for (let i = 0; i < 6; i++)
			push(out, sprintf('%02X', ord(r, i) ?? 0));

		out[0] = substr(out[0], 0, 1) + [ '2', '6', 'A', 'E' ][(ord(r, 6) ?? 0) % 4];

		return join(':', out);
	}

	function sta_macaddr() {
		for (let radio, r in (wireless_status() ?? {}))
			for (let i in (r?.interfaces ?? []))
				if (i?.config?.mode == 'sta' && i?.config?.macaddr != null)
					return '' + i.config.macaddr;

		return '';
	}

	function mac_set(section) {
		let macaddr = getval('macaddr'), result;

		if (length(macaddr)) {
			result = macaddr;
			uci_set('wireless', section, 'macaddr', result);
		}
		else if (cfg('randomize')) {
			result = random_mac();
			uci_set('wireless', section, 'macaddr', result);
		}
		else {
			if (c().get('wireless', section, 'macaddr') != null)
				uci_delete('wireless', section, 'macaddr');

			result = sta_macaddr();
		}

		log('debug', sprintf('f_mac       ::: action: set, section: %s, macaddr: %s, result: %s',
			dash(section), dash(macaddr), dash(result)));

		return result;
	}

	function network_dump() {
		return io.ubus()?.call('network.interface', 'dump')?.interface ?? [];
	}

	// default gateway of the first interface with a default route, per family
	function getgw() {
		let dump = network_dump(), gw = {};

		for (let fam in [ [ '0.0.0.0', 4 ], [ '::', 6 ] ]) {
			let wan = null;

			for (let i in dump)
				for (let r in (i.route ?? []))
					if (r.target == fam[0] && r.table == null && wan == null)
						wan = i;

			gw[fam[1]] = '';

			for (let r in (wan?.route ?? []))
				if (r.target == fam[0] && r.table == null && r.nexthop != null) {
					gw[fam[1]] = '' + r.nexthop;
					break;
				}
		}

		let result = length(gw[4]) > 0 || length(gw[6]) > 0;

		log('debug', sprintf('f_getgw     ::: wan4_gw: %s, wan6_gw: %s, result: %s', dash(gw[4]), dash(gw[6]), '' + result));

		return result;
	}

	function subnet_of(dump, iface) {
		for (let i in dump)
			if (i.interface == iface) {
				let a = i['ipv4-address']?.[0];

				return (a?.address != null) ? network_of(a.address + '/' + a.mask) : '';
			}

		return '';
	}

	function subnet() {
		let conn_state = conn_net();

		if (conn_state == T.subnet_last && length(T.subnet))
			return;

		let dump = network_dump();
		let wan = subnet_of(dump, length(cfg('iface')) ? cfg('iface') : 'trm_wwan');

		if (!length(T.lannet))
			T.lannet = subnet_of(dump, length(cfg('laniface')) ? cfg('laniface') : 'lan');

		if (length(T.lannet) && length(wan) && T.lannet == wan)
			log('info', sprintf("uplink network '%s' conflicts with router LAN network, please adjust your network settings", wan));

		T.subnet = sprintf('%s (lan: %s)', dash(wan), dash(T.lannet));
		T.subnet_last = conn_state;

		log('debug', sprintf('f_subnet    ::: lan: %s, wan: %s', dash(T.lannet), dash(wan)));
	}

	function runtime() {
		let rt = null;

		try { rt = json(readfile(files.rtfile) ?? ''); } catch (e) { }

		return (type(rt?.data) == 'object') ? rt.data : null;
	}

	function getstatus_text() {
		let data = runtime();

		if (!data)
			return '::: no travelmate runtime information available\n';

		let out = '::: travelmate runtime information\n';

		for (let k, v in data)
			out += sprintf('  + %-18s : %s\n', k, v);

		return out;
	}

	function mail(station_id) {
		let board = io.ubus()?.call('system', 'board') ?? {};
		let text = null, topic = cfg('mailtopic');

		if (!length(topic))
			topic = sprintf("travelmate connection to '%s'", station_id);

		// a mail header line, no control characters from an ssid
		topic = replace(topic, /[[:cntrl:]]/g, ' ');

		if (is_file(cfg('mailtemplate'))) {
			try {
				text = render(cfg('mailtemplate'), {
					banner: readfile('/etc/banner') ?? '', board,
					status: getstatus_text(), station_id
				});
			}
			catch (e) {
				log('info', sprintf('mail template error: %s', e.message));
			}
		}
		else {
			log('info', 'no mail template');
		}

		if (!length(text ?? ''))
			log('info', 'no mail content');

		let head = sprintf('From: %s\nTo: %s\nSubject: %s\nReply-to: %s\nMime-Version: 1.0\nContent-Type: text/html;charset=utf-8\nContent-Disposition: inline\n\n',
			cfg('mailsender'), cfg('mailreceiver'), topic, cfg('mailsender'));
		let argv = [ 'msmtp', '--timeout=10' ];

		if (cfg('debug'))
			push(argv, '--debug');

		push(argv, '-a', cfg('mailprofile'), cfg('mailreceiver'));

		let p = popen(argv, 'w');
		let rc = -1;

		if (p) {
			p.write(head + (text ?? ''));
			rc = p.close();
		}

		log('debug', sprintf('f_mail      ::: template: %s, profile: %s, receiver: %s, rc: %s',
			cfg('mailtemplate'), cfg('mailprofile'), cfg('mailreceiver'), '' + rc));
	}

	genstatus = function() {
		if (T.ifstatus !== true)
			T.conn = null;

		subnet();

		let st = {
			ifstatus: T.ifstatus, connection: conn_text(), active: T.active, runmode: T.runmode,
			subnet: T.subnet, fver: T.fver, bver: T.bver, sysver: T.sysver, cores: T.cores, fetch: 'curl',
			vpn: cfg('vpn'), vpnlist: T.vpnlist, mail: cfg('mail'),
			mailcmd: T.mailcmd, mailreceiver: cfg('mailreceiver'),
			uplinkcfg: T.uplinkcfg, captive: cfg('captive'), proactive: cfg('proactive'),
			netcheck: cfg('netcheck'), autoadd: cfg('autoadd'), randomize: cfg('randomize'), eviltwin: cfg('eviltwin')
		};
		let m = match(readfile('/proc/meminfo') ?? '', /MemAvailable:[ \t]*([0-9]+)/);
		let r = status_compose(st, (T.ifstatus === true) ? sta_info(wireless_status()) : null, uplinks(),
			(section) => c().get('wireless', section, 'device'),
			is_dir(files.ntplock), is_file(files.mailfile), is_file(files.vpnfile),
			m ? sprintf('%.2f', +m[1] / 1024) : '', io.time());
		let tmp = files.rtfile + '.tmp';

		if (writefile(tmp, sprintf('%J\n', { data: r.data })) == null || !rename(tmp, files.rtfile))
			unlink(tmp);

		if (r.uplinkcfg != null)
			T.uplinkcfg = r.uplinkcfg;

		if (r.mail) {
			writefile(files.mailfile, '');
			mail(r.data.station_id);
		}

		log('debug', 'f_genstatus ::: ' + r.debug);
	};

	// the internet and captive portal probe, net_classify() result
	function net() {
		let raw = io.capture([ 'curl', ...T.fetch, '--user-agent', cfg('useragent'),
			'--header', 'Cache-Control: no-cache, no-store, must-revalidate, max-age=0',
			'--write-out', '\\n' + MARKER + '%{json}', cfg('captiveurl') ]).out;
		let r = net_classify(raw, cfg('captiveurl'), cfg('captive'));

		log('debug', sprintf('f_net       ::: timeout: %d, %s', FETCH_TIMEOUT, net_debug(r)));

		return r;
	}

	// add the captive portal domain to the dnsmasq rebind allowlist
	function rebind_allow(domain) {
		let sid = null;

		// only a dns name, an address or a malformed host never goes into
		// the dnsmasq config
		if (!hostname(domain))
			return false;

		c().foreach('dhcp', 'dnsmasq', (s) => { sid ??= s['.name']; });

		if (sid == null)
			return false;

		let l = c().get('dhcp', sid, 'rebind_domain');

		l = (type(l) == 'array') ? l : words(l);

		if (domain in l)
			return false;

		c().set('dhcp', sid, 'rebind_domain', [ ...l, domain ]);
		c().save('dhcp');

		if (uci_changes('dhcp'))
			uci_commit('dhcp');

		io.exec([ '/etc/init.d/dnsmasq', 'reload' ]);
		log('info', sprintf("captive portal domain '%s' added to dhcp rebind allowlist", domain));

		return true;
	}

	// login script: '/etc/travelmate/*.uc', executable, credentials as args
	function login(domain) {
		let script = getval('script');

		if (!length(script))
			return null;

		script = realpath(script) ?? '';

		if (substr(script, 0, 16) != '/etc/travelmate/' || !match(script, /\.uc$/)) {
			log('info', 'captive portal login script rejected, it has to be a ucode script /etc/travelmate/*.uc');
			return null;
		}

		if (!is_file(script) || access(script, 'x') != true)
			return null;

		let rc = io.exec([ script, ...words(getval('script_args')) ]);

		log('info', sprintf("captive portal login script for '%s' has been finished with rc '%d'", domain, rc));

		return rc;
	}

	// the net and captive portal check of an up uplink, ends the poll
	function check_net(status, sta_id, quality) {
		let r = net();

		if (cfg('captive')) {
			let domain;

			while (true) {
				domain = r.domain;

				if (access('/etc/init.d/dnsmasq', 'x') != true || !is_file('/etc/config/dhcp') || !length(domain))
					break;

				if (!rebind_allow(domain))
					break;

				r = net();
			}

			if (length(domain)) {
				T.conn = { result: r.result, quality };
				genstatus();

				if (login(domain) === 0)
					r = net();
			}
		}

		if (r.net == 'nok' && cfg('netcheck'))
			r = net();

		if (r.net == 'nok') {
			vpn_handle('disable');

			if (cfg('netcheck')) {
				log('info', sprintf("uplink has no internet '%s'", sta_id));
				T.conn = null;
				T.ifstatus = status;
				genstatus();

				return;
			}
		}

		T.conn = { result: r.result, quality };
		genstatus();
	}

	function station_id() {
		return '' + (runtime()?.station_id ?? '');
	}

	// the current station from the runtime file, or from the wireless status
	// if a restart cleared the runtime file
	function station() {
		let p = split_id(station_id());

		p.bssid = replace(p.bssid, /-/g, '');

		if (length(p.radio) && p.radio != '-')
			return p;

		let sta = sta_info(wireless_status());
		let radio = sta ? '' + (c().get('wireless', sta.section, 'device') ?? '') : '';

		if (!length(radio) || !length(sta.essid))
			return p;

		return { radio, essid: sta.essid, bssid: normbssid(sta.bssid) };
	}

	// mode: initial, dev, sta or rev; status: the expected interface status
	function check(mode, status, sta_radio, sta_essid, sta_bssid) {
		let ifname = '', quality = null, wait = 0, maxwait = cfg('maxwait');

		if (mode == 'initial' || mode == 'dev') {
			let p = station();

			sta_radio = p.radio;
			sta_essid = p.essid;
			sta_bssid = p.bssid;
		}

		sta_radio ??= '';
		sta_essid ??= '';
		sta_bssid ??= '';

		let sta_id = sprintf('%s/%s/%s', dash(sta_radio), dash(sta_essid), dash(sta_bssid));
		let init = check_init({ mode, status, radio: sta_radio, essid: sta_essid, bssid: sta_bssid,
			ifstatus: T.ifstatus, wifireload: T.wifireload }, uplinks());
		let enabled = init.enabled;

		T.uplinkcfg = init.uplinkcfg;

		if (init.wifi)
			wifi();

		if (mode == 'sta') {
			io.ubus()?.call('network.interface.' + cfg('iface'), 'down');
			io.ubus()?.call('network.interface.' + cfg('iface'), 'up');

			if (!wait_for(int(maxwait / 6), 'network.interface.' + cfg('iface')))
				log('info', sprintf("travelmate interface '%s' does not appear on ubus on ifup event", cfg('iface')));

			io.sleep(1);
		}

		while (wait <= maxwait) {
			if (wait > 0)
				io.sleep(1);

			wait++;

			let next = null;
			let steps = check_round({
				mode, status, enabled, ifstatus: T.ifstatus, connection: T.conn != null,
				wait, maxwait, minquality: cfg('minquality'), quality, sta_id
			}, probe_queries(io.ubus(), cfg('iface')));

			for (let s in steps) {
				switch (s.op) {
				case 'probe': ifname = s.ifname; quality = s.quality; break;
				case 'ifstatus': T.ifstatus = s.value; break;
				case 'log': log(s.class, s.msg); break;
				case 'vpn': vpn_handle('disable'); break;
				case 'conn': T.conn = null; break;
				case 'genstatus': genstatus(); break;
				case 'sleep': io.sleep(s.s); break;
				default: next = s.op;
				}
			}

			if (next == 'break')
				break;

			if (next == 'continue')
				continue;

			if (next == 'net') {
				check_net(status, sta_id, quality);
				break;
			}
		}

		log('debug', sprintf('f_check     ::: mode: %s, sta_id: %s, name: %s, status: %s, enabled: %s, connection: %s, wait: %d, max_wait: %d, min_quality/quality: %d/%s, captive: %s, netcheck: %s',
			mode, sta_id, dash(ifname), st_text(T.ifstatus), b(enabled), dash(conn_text()), wait, maxwait,
			cfg('minquality'), dash(quality), b(cfg('captive')), b(cfg('netcheck'))));
	}

	// revive list: [ { cnt, rounds, radio, bssid, essid }, ... ]
	function revive_read() {
		let l = null;

		try { l = json(readfile(files.revivefile) ?? ''); } catch (e) { }

		return (type(l) == 'array') ? l : [];
	}

	function revive_write(list) {
		writefile(files.revivefile + '.tmp', sprintf('%J\n', list));
		rename(files.revivefile + '.tmp', files.revivefile);
	}

	function reviveload(radio, essid, bssid) {
		let revive = int(replace(getval('revive', '0'), /[^0-9]/g, '') || '0'), found = false;

		if (!(revive > 0))
			return;

		if (revive < 10)
			revive = 10;

		let list = revive_read();

		for (let e in list) {
			if (e.radio == radio && e.essid == essid && e.bssid == bssid) {
				found = true;
				e.rounds++;

				if (e.rounds > cfg('maxretry')) {
					e.cnt = 0;
					log('info', sprintf("uplink stays disabled '%s/%s/%s', revive limit reached", radio, essid, dash(bssid)));
				}
				else {
					e.cnt = revive;
				}
			}
		}

		if (!found)
			push(list, { cnt: revive, rounds: 1, radio, bssid, essid });

		revive_write(list);

		log('debug', sprintf('f_reviveload ::: radio: %s, essid: %s, bssid: %s, revive: %d, max_rounds: %d',
			radio, essid, dash(bssid), revive, cfg('maxretry')));
	}

	// a working uplink starts over, its revive rounds are dropped
	function revive_drop(radio, essid, bssid) {
		let list = revive_read();
		let out = filter(list, (e) => !(e.radio == radio && e.essid == essid && e.bssid == bssid));

		if (length(out) != length(list))
			revive_write(out);
	}

	function revive() {
		let list = revive_read(), out = [];

		if (!length(list))
			return;

		for (let e in list) {
			if (e.cnt > 0 && --e.cnt == 0) {
				getcfg(e.radio, e.essid, e.bssid);

				if (!length(T.uplinkcfg))
					continue;

				if (getval('enabled') == '0') {
					uci_set('travelmate', T.uplinkcfg, 'enabled', '1');
					uci_commit('travelmate');
					touch_once(files.refreshfile, 'cfg_reload');
					log('info', sprintf("uplink has been re-enabled '%s/%s/%s' (%d/%d)", e.radio, e.essid, dash(e.bssid), e.rounds, cfg('maxretry')));
				}
			}

			push(out, e);
		}

		revive_write(out);
	}

	function setdev(radio) {
		let match_ = length(cfg('radio')) ? (radio in cfg('radio')) : !(radio in T.radiolist);
		let disabled = '';

		if (match_) {
			if (cfg('revradio'))
				unshift(T.radiolist, radio);
			else
				push(T.radiolist, radio);

			disabled = '' + (c().get('wireless', radio, 'disabled') ?? '');

			if (disabled == '1')
				uci_set('wireless', radio, 'disabled', '0');
		}

		log('debug', sprintf('f_setdev    ::: device: %s, radio: %s, radio_list: %s, disabled: %s',
			dash(radio), dash(join(' ', cfg('radio'))), dash(join(' ', T.radiolist)), dash(disabled)));
	}

	function setif(section, proactive) {
		let get = (o) => '' + (c().get('wireless', section, o) ?? '');
		let radio = get('device');

		if (!(radio in T.radiolist))
			return;

		let mode = get('mode'), essid = get('ssid'), bssid = get('bssid'), disabled = get('disabled');

		getcfg(radio, essid, bssid);

		let enabled = getval('enabled', '0') == '1';

		if (mode == 'sta') {
			if (!enabled || ((disabled == '' || disabled == '0') && (!proactive || T.ifstatus !== true))) {
				uci_set('wireless', section, 'disabled', '1');
			}
			else if (disabled == '0' && T.ifstatus === true && proactive) {
				if (!length(T.activesta))
					T.activesta = section;
				else
					uci_set('wireless', section, 'disabled', '1');
			}

			if (enabled)
				push(T.stalist, { section, radio });
		}

		log('debug', sprintf('f_setif     ::: uplink_config: %s, section: %s, enabled: %s, active_sta: %s',
			dash(T.uplinkcfg), section, b(enabled), dash(T.activesta)));
	}

	// autoadd an open uplink, returns its wifi-iface section or null
	function addsta(radio, essid) {
		let new_uplink = true, offset = 1, cnt = null, out = null;

		c().foreach('wireless', 'wifi-iface', (s) => {
			if (s.ssid == essid && s.device == radio)
				new_uplink = false;
			else
				offset++;
		});

		if (new_uplink) {
			let k = offset + 1;

			while (c().get('wireless', 'trm_uplink' + k) != null)
				k++;

			let wifi_cfg = 'trm_uplink' + k;

			c().set('wireless', wifi_cfg, 'wifi-iface');

			for (let kv in [ [ 'mode', 'sta' ], [ 'network', cfg('iface') ], [ 'device', radio ],
					[ 'ssid', essid ], [ 'encryption', 'none' ], [ 'disabled', '1' ] ])
				c().set('wireless', wifi_cfg, kv[0], kv[1]);

			let trm_cfg = c().add('travelmate', 'uplink');

			c().set('travelmate', trm_cfg, 'device', radio);
			c().set('travelmate', trm_cfg, 'ssid', essid);
			c().set('travelmate', trm_cfg, 'opensta', '1');
			c().set('travelmate', trm_cfg, 'enabled', '1');

			if (length(cfg('stdvpniface'))) {
				c().set('travelmate', trm_cfg, 'vpniface', cfg('stdvpniface'));
				c().set('travelmate', trm_cfg, 'vpn', '1');
			}

			cnt = typed('int', c().get('travelmate', 'global', 'trm_autoaddcnt'), 0) + 1;
			c().set('travelmate', 'global', 'trm_autoaddcnt', '' + cnt);
			c().save('travelmate');
			c().save('wireless');

			if (uci_changes('travelmate'))
				uci_commit('travelmate');

			if (uci_changes('wireless'))
				uci_commit('wireless');

			T.uplinks = null;
			wifi();
			touch_once(files.refreshfile, 'ui_reload');
			log('info', sprintf("open uplink '%s/%s' added to wireless config", radio, essid));
			out = wifi_cfg;
		}

		log('debug', sprintf('f_addsta    ::: radio: %s, essid: %s, autoaddcnt/maxautoadd: %d/%d, new_uplink: %d, offset: %d',
			dash(radio), essid, cnt ?? cfg('autoaddcnt'), cfg('maxautoadd'), new_uplink ? 1 : 0, offset));

		return out;
	}

	// connect the station ctx { section, radio, essid, bssid }, after
	// terminating the current uplink cur { radio, essid, bssid }
	function connect_sta(ctx, cur) {
		if (cur && length(cur.radio)) {
			vpn_handle('disable');
			uci_set('wireless', T.activesta, 'disabled', '1');

			if (uci_changes('wireless'))
				uci_commit('wireless');

			check('rev', false);
			log('info', sprintf("uplink connection terminated '%s/%s/%s'", cur.radio, cur.essid, dash(cur.bssid)));
			cur.radio = cur.essid = cur.bssid = '';
		}

		let maxretry = cfg('maxretry'), retry_display = (maxretry == 0) ? '-' : '' + maxretry;
		let sta = sprintf('%s/%s/%s', ctx.radio, ctx.essid, dash(ctx.bssid));

		getcfg(ctx.radio, ctx.essid, ctx.bssid);

		for (let retry = 1; maxretry == 0 || retry <= maxretry; retry++) {
			let mac = mac_set(ctx.section);

			uci_set('wireless', ctx.section, 'disabled', '0');
			check('sta', false, ctx.radio, ctx.essid, ctx.bssid);

			if (T.ifstatus === true) {
				unlink(files.mailfile);

				if (uci_changes('wireless'))
					uci_commit('wireless');

				log('info', sprintf("connected to uplink '%s' with mac '%s' (%d/%s)", sta, dash(mac), retry, retry_display));
				revive_drop(ctx.radio, ctx.essid, ctx.bssid);
				vpn_handle('enable');

				return true;
			}

			uci_revert('wireless');
			check('rev', false, ctx.radio, ctx.essid, ctx.bssid);

			if (retry == maxretry) {
				// without revive the uplink stays off, tell how to get it back
				let hint = (getval('revive', '0') == '0') ? ", re-enable it in LuCI or set 'revive'" : '';

				if (length(T.uplinkcfg)) {
					uci_set('travelmate', T.uplinkcfg, 'enabled', '0');
					uci_commit('travelmate');
					touch_once(files.refreshfile, 'cfg_reload');
					reviveload(ctx.radio, ctx.essid, ctx.bssid);
				}

				log('info', sprintf("uplink has been disabled '%s' (%d/%s)%s", sta, retry, retry_display, hint));

				return false;
			}

			genstatus();
			log('info', sprintf("can't connect to uplink '%s' (%d/%s)", sta, retry, retry_display));
			io.sleep(int(cfg('maxwait') / 6));
		}

		return false;
	}

	function select_cfg() {
		return {
			minquality: cfg('minquality'), autoadd: cfg('autoadd'), eviltwin: cfg('eviltwin'),
			maxautoadd: cfg('maxautoadd'), autoaddcnt: typed('int', c().get('travelmate', 'global', 'trm_autoaddcnt'), 0),
			ssidfilter: cfg('ssidfilter')
		};
	}

	function select_ifaces() {
		let out = {};

		c().foreach('wireless', 'wifi-iface', (s) => {
			out[s['.name']] = { device: s.device, ssid: s.ssid, bssid: s.bssid };
		});

		return out;
	}

	// one run cycle
	function main() {
		let cur = { radio: '', essid: '', bssid: '' };
		let proactive = cfg('proactive');

		T.active = true;
		revive();
		check('initial', false);

		if (!proactive)
			vpn_handle((conn_net() == 'net ok') ? 'enable_keep' : 'disable');

		log('debug', sprintf('f_main-1    ::: status: %s, connection: %s, proactive: %s',
			st_text(T.ifstatus), conn_net(), b(proactive)));

		if (T.ifstatus !== true || proactive) {
			c().foreach('wireless', 'wifi-iface', (s) => setif(s['.name'], proactive));

			if (T.ifstatus === true && length(T.activesta) && proactive) {
				let p = station();

				cur.radio = p.radio;
				cur.essid = p.essid;
				cur.bssid = normbssid(p.bssid);
				check('dev', true);
				log('debug', sprintf('f_main-2    ::: config_radio: %s, config_essid: "%s", config_bssid: %s',
					cur.radio, cur.essid, dash(cur.bssid)));
			}
			else {
				if (uci_changes('wireless')) {
					uci_commit('wireless');
					T.wifireload = true;
				}
				else if (!T.wifireload && !probe_ready(io.ubus(), T.radiolist)) {
					T.wifireload = true;
				}

				log('debug', 'f_main-2    ::: wifi_reload: ' + b(T.wifireload));
				check('dev', false);
				T.wifireload = false;
			}

			log('debug', sprintf('f_main-3    ::: radio_list: %s, sta_list: %s',
				dash(join(' ', T.radiolist)), dash(join(' ', map(T.stalist, (s) => s.section + '-' + s.radio)))));

			for (let radio in T.radiolist) {
				if (!length(filter(T.stalist, (s) => s.radio == radio)) && !cfg('autoadd'))
					continue;

				let steps = select_plan({
					radio, stalist: T.stalist,
					current: (T.conn && length(cur.radio)) ? cur : null,
					cfg: select_cfg(), ifaces: select_ifaces(),
					scan: () => scan_rank(io.ubus()?.call('iwinfo', 'scan', { device: radio })?.results)
				});
				let ctx = { section: '', radio: '', bssid: '', essid: '' }, skip = false;

				for (let s in steps) {
					switch (s.op) {
					case 'log':
						if (s.once && T.noted[s.msg])
							log('debug', s.msg);
						else {
							if (s.once)
								T.noted[s.msg] = true;

							log(s.class, s.msg);
						}
						break;

					case 'noscan':
						log('info', sprintf("no scan results on '%s'", s.radio));
						T.wifireload = true;
						break;

					case 'sta':
						ctx = { section: s.section, radio: s.radio, bssid: s.bssid, essid: s.essid };
						skip = false;
						getcfg(ctx.radio, ctx.essid, ctx.bssid);
						break;

					case 'keep':
						vpn_handle('enable_keep');
						log('debug', sprintf('f_main-4    ::: config_radio: %s, config_essid: %s, config_bssid: %s',
							cur.radio, cur.essid, dash(cur.bssid)));
						return;

					case 'mismatch':
						if (length(T.uplinkcfg)) {
							uci_set('travelmate', T.uplinkcfg, 'enabled', '0');
							uci_commit('travelmate');
							touch_once(files.refreshfile, 'cfg_reload');
						}

						log('info', sprintf("bssid mismatch (evil-twin) '%s/%s/%s => %s'", ctx.radio, ctx.essid, ctx.bssid, s.bssid));
						break;

					case 'add':
						let section = addsta(s.radio, s.essid);

						if (section) {
							ctx = { section, radio: s.radio, bssid: '', essid: s.essid };
						}
						else {
							skip = true;
							log('info', sprintf("open uplink could not be added '%s/%s'", s.radio, s.essid));
						}
						break;

					case 'try':
						if (!skip && connect_sta(ctx, cur))
							return;

						skip = false;
						break;
					}
				}
			}
		}

		T.active = false;

		if (T.ifstatus !== true && T.ifstatus != 'error')
			genstatus();
	}

	// config and runtime checks before each cycle, false if travelmate has to stop
	function conf() {
		T.c = null;
		T.uplinks = null;
		T.cfg = cfg_global(c());
		T.radiolist = [];
		T.stalist = [];
		T.activesta = '';
		T.uplinkcfg = '';

		if (length(T.action))
			T.runmode = T.action;

		if (!length(cfg('iface'))) {
			log('info', "travelmate is currently not configured, please use the 'Interface Wizard' in LuCI");
			return false;
		}

		if (!wait_for(cfg('maxwait'), 'network.wireless', 'network.interface.' + cfg('iface'))) {
			log('info', sprintf("travelmate interface '%s' does not appear on ubus, please check your network setup", cfg('iface')));
			return false;
		}

		c().foreach('wireless', 'wifi-device', (s) => setdev(s['.name']));

		if (uci_changes('wireless')) {
			uci_commit('wireless');
			wifi();
		}

		if (cfg('vpn') && !length(T.vpnlist)) {
			let ifaces = [], refs = length(cfg('stdvpniface')) ? [ cfg('stdvpniface') ] : [];

			c().foreach('network', 'interface', (s) => push(ifaces, s));
			c().foreach('travelmate', 'uplink', (s) => {
				if (length(s.vpniface ?? ''))
					push(refs, '' + s.vpniface);
			});

			let r = vpn_infolist(ifaces, cfg('vpnifacelist'), refs);

			T.vpnlist = r.list;

			for (let l in r.logs)
				log('debug', l);
		}

		let device = io.ubus()?.call('network.interface.' + cfg('iface'), 'status')?.device;

		T.fetch = fetch_args(T.cfg, (device != null) ? '' + device : '');

		log('debug', sprintf('f_conf      ::: frontend: %s, backend: %s, sys_ver: %s, fetch_parm: %s',
			T.fver, T.bver, T.sysver, join(' ', T.fetch)));

		return true;
	}

	// start-up checks
	function startup(action) {
		mkdir(RUNDIR);
		system_info();
		T.action = action ?? '';

		if (length(T.action) && T.action != 'stop') {
			if (!is_dir('/etc/travelmate'))
				log('err', 'no travelmate config directory');

			if (!is_file('/etc/config/travelmate'))
				log('err', 'no travelmate config');

			if (cursor().get('travelmate', 'global', 'trm_enabled') == '0')
				log('err', 'travelmate is disabled');
		}

		for (let cmd in [ 'curl', 'wifi', 'ubus' ])
			if (!have(cmd))
				log('emerg', sprintf("command '%s' not found", cmd));

		T.mailcmd = have('msmtp');
	}

	return {
		T, startup, conf, main, getgw, log, genstatus,
		scan: (radio) => scan_report(io.ubus()?.call('iwinfo', 'scan', { device: radio })?.results),
		status_text: getstatus_text
	};
};
