// travelmate - runtime status: composes the status object for LuCI, the
// mail and the connection loop, decides whether the connect mail is due

// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2016-2026 Dirk Brenken <dev@brenken.org>

import { normbssid } from 'travelmate.select';
import { ref as uplink_ref, option as uplink_option } from 'travelmate.uplink';

function dash(v) {
	return length(v ?? '') ? '' + v : '-';
}

function flag(v) {
	return v ? '✔' : '✘';
}

// first sta interface of 'network.wireless status', any radio
export function sta_info(wstatus) {
	for (let radio, r in wstatus)
		for (let i in (r?.interfaces ?? []))
			if (i?.config?.mode == 'sta')
				return {
					section: '' + (i.section ?? ''),
					essid: '' + (i.config.ssid ?? ''),
					mac: '' + (i.config.macaddr ?? ''),
					bssid: '' + (i.config.bssid ?? ''),
					iface: '' + (i.config.network?.[0] ?? '')
				};

	return null;
};

// st: daemon state, sta: sta_info() or null, radio_of(section): wifi-iface
// device, ntp/mailed/vpnup: bools, mem: MiB, ts: 'YYYY-MM-DD HH:MM:SS'
export function compose(st, sta, uplinks, radio_of, ntp, mailed, vpnup, mem, ts) {
	let r = { uplinkcfg: null, mail: false };
	let section = '', sradio = '', sessid = '', sbssid = '', smac = '', siface = '';
	let vpn = '', vpn_iface = '', vpn_done = false, status, runtime = null;
	let uplinkcfg = st.uplinkcfg ?? '';

	if (st.ifstatus === true) {
		status = 'connected, ' + dash(st.connection);

		if (sta) {
			section = sta.section;
			sessid = sta.essid;
			smac = sta.mac;
			sbssid = sta.bssid;
			siface = sta.iface;
		}

		if (length(section)) {
			sbssid = normbssid(sbssid);
			sradio = radio_of(section) ?? '';
			uplinkcfg = uplink_ref(uplinks, sradio, sessid, sbssid);
			r.uplinkcfg = uplinkcfg;
		}

		vpn = uplink_option(uplinks, uplinkcfg, 'vpn');

		if (st.vpn && length(st.vpnlist) && vpn == '1' && vpnup) {
			vpn_iface = uplink_option(uplinks, uplinkcfg, 'vpniface');
			vpn_done = true;
		}
	}
	else if (st.ifstatus == 'error') {
		status = 'program error';
	}
	else {
		status = st.active ? 'processing' : 'not connected';
		runtime = '-';
	}

	let mail_done = (st.mail && mailed);

	if (st.ifstatus === true || st.ifstatus == 'error')
		runtime = sprintf('mode: %s, date / time: %s, memory: %s MB available',
			length(st.runmode) ? st.runmode : 'n/a', ts, length(mem) ? mem : '0');

	r.data = {
		travelmate_status: status,
		frontend_ver: st.fver ?? '',
		backend_ver: st.bver ?? '',
		station_id: dash(sradio) + '/' + dash(sessid) + '/' + dash(sbssid),
		station_mac: dash(smac),
		station_interfaces: dash(siface) + ', ' + dash(vpn_iface),
		station_subnet: dash(st.subnet),
		run_flags: sprintf('autoadd: %s, captive: %s, eviltwin: %s, mail: %s, netcheck: %s, ntp: %s, proactive: %s, randomize: %s, vpn: %s',
			flag(st.autoadd), flag(st.captive), flag(st.eviltwin), mail_done ? '✔' : '✘', flag(st.netcheck),
			ntp ? '✔' : '✘', flag(st.proactive), flag(st.randomize), vpn_done ? '✔' : '✘'),
		last_run: dash(runtime),
		system_info: sprintf('cores: %s, fetch: %s, %s', st.cores ?? '', st.fetch ?? '', st.sysver ?? '')
	};

	// connect mail: once per connection, after ntp sync and, with a vpn
	// uplink, only once the vpn is up
	if (index(status, 'connected, net ok/') == 0 && st.mail && st.mailcmd &&
	    length(st.mailreceiver) && ntp && !mail_done &&
	    (!st.vpn || vpn != '1' || !length(st.vpnlist) || vpn_done)) {
		r.mail = true;
		mail_done = true;
	}

	r.debug = sprintf('section: %s, status: %s, sta_iface: %s, sta_radio: %s, sta_essid: %s, sta_bssid: %s, ntp: %d, vpn: %s/%d, mail: %s/%d',
		dash(section), dash((st.ifstatus == null) ? '' : '' + st.ifstatus), dash(siface), dash(sradio), dash(sessid), dash(sbssid),
		ntp ? 1 : 0, length(vpn) ? vpn : '0', vpn_done ? 1 : 0, st.mail ? 1 : 0, mail_done ? 1 : 0);

	return r;
};
