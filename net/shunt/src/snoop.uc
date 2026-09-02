// shunt - passive DNS observer
//
// Opens an AF_PACKET socket with a BPF filter on DNS answers and turns a
// captured frame into a verdict: which policies want it, or why not.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { decap } from 'shunt.frame';
import { parse, TYPE } from 'shunt.dns';

export const RECV_LEN = 4160;

export function open(dev) {
	let sock, bpf;

	try {
		sock = require('socket');
	}
	catch (e) {
		return { ok: false, err: 'socket module missing - install ucode-mod-socket' };
	}

	try {
		bpf = require('shunt.snoop_bpf').BPF;
	}
	catch (e) {
		return { ok: false,
			err: 'shunt.snoop_bpf missing - reinstall the shunt package' };
	}

	let s = sock.create(sock.AF_PACKET, sock.SOCK_RAW, 0);
	if (!s)
		return { ok: false, err: `create: ${sock.error()}` };

	if (!s.setopt(sock.SOL_SOCKET, sock.SO_ATTACH_FILTER,
		{ len: length(bpf), filter: bpf })) {
		let err = `SO_ATTACH_FILTER: ${sock.error()}`;
		s.close();
		return { ok: false, err };
	}

	if (!s.bind({ family: sock.AF_PACKET, interface: dev,
		protocol: 0x0003, address: '00:00:00:00:00:00' })) {
		let err = `bind: ${sock.error()}`;
		s.close();
		return { ok: false, err };
	}

	return { ok: true, sock: s };
};

// Returns { policies, qname, a, aaaa } or { drop: <verdict> }. The verdict
// strings are contract; the fixtures compare them verbatim.
export function observe(frame, matcher) {
	let f = decap(frame);
	if (!f.ok)
		return { drop: `frame:${f.err}` };

	let r = parse(f.payload);
	if (!r.ok)
		return { drop: `dns:${r.err}` };

	if (r.qtype != TYPE.A && r.qtype != TYPE.AAAA)
		return { drop: 'qtype' };

	if (!length(r.a) && !length(r.aaaa))
		return { drop: 'noaddr' };

	let policies = matcher.test(r.qname);
	if (policies == null)
		return { drop: 'nomatch' };

	return { policies, qname: r.qname, a: r.a, aaaa: r.aaaa };
};
