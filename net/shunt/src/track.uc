// shunt - interface health tracking
//
// An interface netifd reports up can still be dead - a WireGuard tunnel is
// up whether or not its peer answers - and the fallback of its policies
// never takes over then. Each tracked device is probed with ICMP echo
// requests to the track_ip targets, from a raw socket bound to the device
// and carrying the device's probe mark: the binding keeps the probe off
// every other path, the mark routes it through the device's probe table,
// which holds the same default route as its policies and is never
// withdrawn. A device that answers no target for DOWN rounds in a row is
// dead and treated like one whose link went down; UP answered rounds
// bring it back.
//
// Packets are built and read with chr()/ord(), so no struct module is
// needed. The socket module is passed in, which keeps everything but
// open() testable without one.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

export const TRACK = { interval: 5, down: 3, up: 3 };

// Not exported as constants by ucode-mod-socket.
const PROTO = { '4': 1, '6': 58 };
const ECHO = { '4': [ 8, 0 ], '6': [ 128, 129 ] };
const ID = 0x5348;

function csum(b) {
	let x = 0;

	for (let i = 0; i < length(b); i += 2)
		x += (ord(b, i) << 8) + (ord(b, i + 1) ?? 0);

	while (x >> 16)
		x = (x & 0xffff) + (x >> 16);

	return ~x & 0xffff;
}

// The kernel fills in the ICMPv6 checksum on a raw socket, as it must for
// the pseudo header; ICMP for IPv4 has none and is summed here.
export function echo(fam, seq) {
	let pkt = (c) => chr(ECHO[fam][0], 0, c >> 8, c & 0xff,
		ID >> 8, ID & 0xff, (seq >> 8) & 0xff, seq & 0xff) + 'shunt';

	return (fam == '4') ? pkt(csum(pkt(0))) : pkt(0);
};

// The sequence number of an echo reply to one of our requests, else null.
// A raw IPv4 socket delivers the IP header with the payload, a raw IPv6
// one does not.
export function reply(fam, data) {
	let off = (fam == '4') ? (ord(data, 0) & 0x0f) * 4 : 0;

	if (length(data ?? '') < off + 8 || ord(data, off) != ECHO[fam][1])
		return null;

	if (((ord(data, off + 4) << 8) | ord(data, off + 5)) != ID)
		return null;

	return (ord(data, off + 6) << 8) | ord(data, off + 7);
};

// One round's outcome into the hysteresis. Returns 'down' or 'up' on a
// change of state, null otherwise.
export function step(h, ok) {
	if (ok) {
		h.good++;
		h.bad = 0;
	}
	else {
		h.bad++;
		h.good = 0;
	}

	if (h.alive && h.bad >= TRACK.down) {
		h.alive = false;
		return 'down';
	}

	if (!h.alive && h.good >= TRACK.up) {
		h.alive = true;
		return 'up';
	}

	return null;
};

// The targets by family, the families the kernel lacks left out.
export function targets(ips, addr_family, ipv6) {
	let t = { '4': [], '6': [] };

	for (let a in (ips ?? [])) {
		let fam = sprintf('%d', addr_family(a) ?? 0);

		if (fam == '4' || (fam == '6' && ipv6 !== false))
			push(t[fam], a);
	}

	return t;
};

// A raw socket for one family, bound to the device and carrying its probe
// mark, or null with the reason.
export function open(sock, dev, fam, mark) {
	let s = sock.create((fam == '4') ? sock.AF_INET : sock.AF_INET6,
		sock.SOCK_RAW | sock.SOCK_NONBLOCK, PROTO[fam]);

	if (!s)
		return { err: sock.error() };

	if (!s.setopt(sock.SOL_SOCKET, sock.SO_BINDTODEVICE, dev) ||
	    !s.setopt(sock.SOL_SOCKET, sock.SO_MARK, mark)) {
		let err = sock.error();

		s.close();
		return { err };
	}

	return { s };
};
