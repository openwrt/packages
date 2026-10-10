#!/usr/bin/ucode
// SPDX-License-Identifier: GPL-2.0-only
//
// Show router state on the GL.iNet GL-E750 (Mudi) OLED.
//
// The kmod-gl-e750-mcu driver owns the MCU UART. This service only builds the
// screen content (a JSON object of strings, see
// https://github.com/gl-inet/GL-E750-MCU-instruction) and writes it to
// /dev/gl-e750-mcu whenever it changes. It reacts to netifd and hostapd
// events; only the clock and the cellular signal are refreshed periodically.

'use strict';

import * as ubus from 'ubus';
import * as uloop from 'uloop';
import { cursor } from 'uci';
import { open, popen, stat, readlink } from 'fs';

const DEV = '/dev/gl-e750-mcu';
const MODEM_PROTOS = { qmi: true, mbim: true, ncm: true, '3g': true, modemmanager: true };
const VPN_PROTOS = { wireguard: true, amneziawg: true, openvpn: true, l2tp: true,
		     pptp: true, sstp: true, vpnc: true, openconnect: true };
const TETHER_DRIVERS = { rndis_host: true, cdc_ether: true, cdc_ncm: true, ipheth: true };

let conn = ubus.connect();
let last = null;
let modem = null;
let pending = null;
let hostapd_sub = null;
let clock = null;
let modem_timer = null;
let running = true;

// ubus object names of all hostapd BSSes ("hostapd.phy0-ap0", ...)
function hostapd_objects() {
	return filter(conn.list() ?? [], n => index(n, 'hostapd.') == 0);
}

function str(v) {
	return (v == null) ? '' : '' + v;
}

function option(name, def) {
	let c = cursor();
	let v = c.get('gl-e750-oled', 'main', name);
	return (v == null) ? def : v;
}

function interfaces() {
	return conn.call('network.interface', 'dump')?.interface ?? [];
}

function wifi_bands(clients) {
	let res = {};
	let status = conn.call('network.wireless', 'status') ?? {};

	for (let name, radio in status) {
		let band = radio.config?.band;
		if (band != '2g' && band != '5g')
			continue;

		for (let iface in radio.interfaces ?? []) {
			if (iface.config?.mode != 'ap')
				continue;
			res[band] = {
				ssid: iface.config.ssid,
				key: iface.config.key,
				up: radio.up && !radio.disabled,
				clients: clients[iface.ifname] ?? 0,
			};
			break;
		}
	}
	return res;
}

function client_counts() {
	let res = {};
	for (let obj in hostapd_objects()) {
		let c = conn.call(obj, 'get_clients')?.clients ?? {};
		res[substr(obj, 8)] = length(keys(c));
	}
	return res;
}

// what carries the default route: cable, modem, repeater or tethering
function uplink(ifaces, wifi_sta) {
	for (let i in ifaces) {
		if (!i.up)
			continue;
		let def = filter(i.route ?? [], r => r.target == '0.0.0.0' && r.mask == 0);
		if (!length(def))
			continue;
		if (MODEM_PROTOS[i.proto])
			return 'modem';
		if (wifi_sta[i.interface])
			return 'repeater';
		let drv = readlink(`/sys/class/net/${i.l3_device ?? i.device}/device/driver`);
		if (drv && TETHER_DRIVERS[split(drv, '/')[-1]])
			return 'tethering';
		return 'cable';
	}
	return '';
}

function wifi_sta_networks() {
	let res = {};
	let status = conn.call('network.wireless', 'status') ?? {};
	for (let name, radio in status)
		for (let iface in radio.interfaces ?? [])
			if (iface.config?.mode == 'sta')
				for (let n in iface.config.network ?? [])
					res[n] = true;
	return res;
}

function vpn_state(ifaces) {
	for (let i in ifaces) {
		if (!VPN_PROTOS[i.proto] || i.autostart === false)
			continue;
		return {
			type: i.proto,
			status: i.up ? 'connected' : (i.pending ? 'connecting' : 'off'),
		};
	}
	return null;
}

// cellular state for the first QMI interface, refreshed once a minute
function modem_query(ifaces) {
	let iface = filter(ifaces, i => i.proto == 'qmi')[0];
	if (!iface)
		return null;

	let c = cursor();
	let dev = c.get('network', iface.interface, 'device');
	if (!dev || !stat(dev))
		return { sim: 'NO_SIM' };

	let run = (arg) => {
		let p = popen(`uqmi -t 3000 -s -d ${dev} ${arg} 2>/dev/null`, 'r');
		if (!p)
			return null;
		let out = p.read('all');
		p.close();
		// nothing or an error text instead of JSON when uqmi fails
		try {
			return length(out) ? json(out) : null;
		} catch (e) {
			return null;
		}
	};

	let serving = run('--get-serving-system');
	if (serving?.registration != 'registered') {
		let sim = run('--uim-get-sim-state');
		let s = lc(sprintf('%J', sim ?? ''));
		return { sim: index(s, 'pin') >= 0 ? 'PIN_SIM' :
			      (index(s, 'ready') >= 0 ? 'NO_REG' : 'NO_SIM') };
	}

	let signal = run('--get-signal-info') ?? {};
	let bars = 0;
	if (signal.rsrp != null)
		bars = signal.rsrp >= -90 ? 4 : signal.rsrp >= -100 ? 3 :
		       signal.rsrp >= -110 ? 2 : signal.rsrp >= -120 ? 1 : 0;
	else if (signal.rssi != null)
		bars = signal.rssi >= -70 ? 4 : signal.rssi >= -85 ? 3 :
		       signal.rssi >= -100 ? 2 : 1;

	let mode = { lte: '4G', wcdma: '3G', tdscdma: '3G', gsm: '2G' }[signal.type] ??
		   (index(str(signal.type), 'nr') >= 0 ? '5G' : '');

	return {
		carrier: serving.plmn_description || `${serving.plmn_mcc} ${serving.plmn_mnc}`,
		signal: bars,
		mode: mode,
		up: iface.up,
	};
}

function build() {
	let ifaces = interfaces();
	let wifi = wifi_bands(client_counts());
	let hide = option('hide_psk', '0') == '1';
	let lan = conn.call('network.interface.lan', 'status');
	let msg = {};

	for (let band, suffix in { '2g': '', '5g': '_5g' }) {
		let w = wifi[band];
		msg['ssid' + suffix] = str(w?.ssid);
		msg['up' + suffix] = w?.up ? '1' : '0';
		msg['key' + suffix] = hide ? '********' : str(w?.key);
	}
	msg.hide_psk = hide ? '1' : '0';
	msg.clients = str((wifi['2g']?.clients ?? 0) + (wifi['5g']?.clients ?? 0));
	msg.work_mode = 'Router';
	msg.lan_ip = str(lan?.['ipv4-address']?.[0]?.address);
	msg.method_nw = uplink(ifaces, wifi_sta_networks());

	if (modem?.sim) {
		msg.SIM = modem.sim;
	} else if (modem) {
		msg.carrier = substr(str(modem.carrier), 0, 16);
		msg.signal = str(modem.signal);
		msg.modem_mode = modem.mode;
		msg.modem_up = modem.up ? '1' : '0';
	}

	let vpn = vpn_state(ifaces);
	if (vpn) {
		msg.vpn_type = vpn.type;
		msg.vpn_status = vpn.status;
	}

	if (stat('/dev/mmcblk0') || stat('/dev/sda'))
		msg.disk = '1';

	let t = localtime();
	msg.clock = sprintf('%02d:%02d', t.hour, t.min);
	return msg;
}

function push() {
	let text = sprintf('%J', build());
	if (text == last)
		return;
	let f = open(DEV, 'w');
	if (!f) {
		warn(`gl-e750-oled: cannot open ${DEV}\n`);
		return;
	}
	f.write(text);
	f.close();
	last = text;
}

// coalesce bursts of events into one update
function schedule() {
	if (!running)
		return;
	if (pending)
		pending.set(500);
	else
		pending = uloop.timer(500, () => { pending = null; push(); });
}

function subscribe_hostapd() {
	for (let obj in hostapd_objects())
		hostapd_sub.subscribe(obj);
}

function clock_tick() {
	push();
	let now = localtime();
	clock.set((60 - now.sec) * 1000 + 50);
}

function modem_tick() {
	modem = modem_query(interfaces());
	schedule();
	modem_timer.set(60000);
}

uloop.init();

hostapd_sub = conn.subscriber(() => schedule(), () => schedule());
subscribe_hostapd();

conn.listener('network.interface', () => schedule());
conn.listener('ubus.object.add', (ev, data) => {
	if (index(data?.path ?? '', 'hostapd.') == 0) {
		hostapd_sub.subscribe(data.path);
		schedule();
	}
});

clock = uloop.timer(10, clock_tick);
modem_timer = uloop.timer(100, modem_tick);

// uloop leaves the loop on SIGTERM/SIGINT. Callbacks fired while the ubus
// connection is torn down afterwards (e.g. the subscriber's remove handler)
// must not touch uloop any more.
uloop.run();
running = false;
