// shunt - link layer decoder
//
// Ethernet, optional VLAN tag, IPv4/IPv6, UDP - down to the DNS payload.
// Rejects anything malformed rather than guessing.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

// How far to walk before giving up: stacked VLAN tags, IPv6 extension headers.
export const LIM = {
	vlan: 3,
	ext: 8
};

// Decoder verdicts, contract like the parser's.
export const ERR = {
	SHORT: 'E_SHORT',
	ETHER: 'E_ETHER',
	VLAN: 'E_VLAN',
	IPLEN: 'E_IPLEN',
	FRAG: 'E_FRAG',
	EXTHDR: 'E_EXTHDR',
	PROTO: 'E_PROTO',
	UDPLEN: 'E_UDPLEN'
};

const ETH_HDR = 14;
const ETYPE_OFF = 12;
const VLAN_TAG = 4;

const ET_IPV4 = 0x0800;
const ET_IPV6 = 0x86dd;
const ET_VLAN = 0x8100;
const ET_QINQ = 0x88a8;

const IP4_MIN = 20;
const IP6_HDR = 40;
const EXT_MIN = 8;
const UDP_HDR = 8;

const IP_UDP = 17;
const IP_FRAG = 44;
const IP_AH = 51;

const IP4_FRAG_MASK = 0x3fff;

function u16(buf, off) {
	return (ord(buf, off) << 8) | ord(buf, off + 1);
}

function is_ext(proto) {
	return proto == 0 || proto == 43 || proto == 60 || proto == IP_AH;
}

export function decap(buf) {
	let len = length(buf ?? '');

	if (len < ETH_HDR)
		return { ok: false, err: ERR.SHORT };

	let off = ETYPE_OFF, et = u16(buf, off), tags = 0;

	while (et == ET_VLAN || et == ET_QINQ) {
		if (++tags > LIM.vlan)
			return { ok: false, err: ERR.VLAN };

		off += VLAN_TAG;
		if (off + 2 > len)
			return { ok: false, err: ERR.SHORT };

		et = u16(buf, off);
	}

	off += 2;

	let af, proto;

	if (et == ET_IPV4) {
		if (off + IP4_MIN > len)
			return { ok: false, err: ERR.SHORT };

		let ihl = (ord(buf, off) & 0x0f) * 4;
		if (ihl < IP4_MIN)
			return { ok: false, err: ERR.IPLEN };
		if (off + ihl > len)
			return { ok: false, err: ERR.SHORT };

		let tot = u16(buf, off + 2);
		if (tot < ihl)
			return { ok: false, err: ERR.IPLEN };
		if (off + tot > len)
			return { ok: false, err: ERR.SHORT };

		len = off + tot;

		if (u16(buf, off + 6) & IP4_FRAG_MASK)
			return { ok: false, err: ERR.FRAG };

		proto = ord(buf, off + 9);
		af = 4;
		off += ihl;
	}
	else if (et == ET_IPV6) {
		if (off + IP6_HDR > len)
			return { ok: false, err: ERR.SHORT };

		let plen = u16(buf, off + 4);
		if (off + IP6_HDR + plen > len)
			return { ok: false, err: ERR.SHORT };

		len = off + IP6_HDR + plen;

		proto = ord(buf, off + 6);
		af = 6;
		off += IP6_HDR;

		for (let i = 0; i < LIM.ext && is_ext(proto); i++) {
			if (off + EXT_MIN > len)
				return { ok: false, err: ERR.SHORT };

			let hlen = (proto == IP_AH)
				? (ord(buf, off + 1) + 2) * 4
				: (ord(buf, off + 1) + 1) * 8;

			proto = ord(buf, off);
			off += hlen;
		}

		if (proto == IP_FRAG)
			return { ok: false, err: ERR.FRAG };
		if (is_ext(proto))
			return { ok: false, err: ERR.EXTHDR };
	}
	else
		return { ok: false, err: ERR.ETHER };

	if (proto != IP_UDP)
		return { ok: false, err: ERR.PROTO };
	if (off + UDP_HDR > len)
		return { ok: false, err: ERR.SHORT };

	let sport = u16(buf, off);
	let ulen = u16(buf, off + 4);

	if (ulen < UDP_HDR || off + ulen > len)
		return { ok: false, err: ERR.UDPLEN };

	return {
		ok: true,
		af,
		sport,
		payload: substr(buf, off + UDP_HDR, ulen - UDP_HDR)
	};
};
