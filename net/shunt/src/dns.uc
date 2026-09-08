// shunt - DNS message parser
//
// Parses a response far enough to answer: which name was asked for, and
// which A/AAAA addresses came back. Never trusts a length off the wire.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

// Hard limits: message size, name length, answers processed per message.
export const LIM = {
	msg: 4096,
	labels: 63,
	name: 255,
	answers: 64
};

export const TYPE = {
	A: 1,
	NS: 2,
	CNAME: 5,
	SOA: 6,
	TXT: 16,
	AAAA: 28,
	OPT: 41
};

// Parser verdicts. These identifiers are contract - fixtures and the LuCI
// labels compare them verbatim.
export const ERR = {
	SHORT: 'E_SHORT',
	MSGLEN: 'E_MSGLEN',
	NOTRESP: 'E_NOTRESP',
	TRUNC: 'E_TRUNC',
	RCODE: 'E_RCODE',
	QDCOUNT: 'E_QDCOUNT',
	QPTR: 'E_QPTR',
	LABEL: 'E_LABEL',
	NAMELEN: 'E_NAMELEN',
	CHARSET: 'E_CHARSET',
	RDLEN: 'E_RDLEN',
	ANSMAX: 'E_ANSMAX'
};

const HDR_LEN = 12;
const RR_FIXED = 10;

const F_QR = 0x8000;
const F_TC = 0x0200;
const M_RCODE = 0x000f;

const LBL_MASK = 0xc0;
const LBL_PTR = 0xc0;

function u16at(buf, off) {
	return (ord(buf, off) << 8) | ord(buf, off + 1);
}

function fmt4(buf, off) {
	return sprintf('%d.%d.%d.%d',
		ord(buf, off), ord(buf, off + 1),
		ord(buf, off + 2), ord(buf, off + 3));
}

function fmt6(buf, off) {
	let g = [];
	for (let i = 0; i < 8; i++)
		push(g, u16at(buf, off + i * 2));

	let bs = -1, bl = 0, cs = -1, cl = 0;
	for (let i = 0; i < 8; i++) {
		if (g[i] != 0) {
			cs = -1;
			cl = 0;
			continue;
		}
		if (cs < 0)
			cs = i;
		cl++;
		if (cl > bl) {
			bs = cs;
			bl = cl;
		}
	}

	if (bl < 2) {
		bs = -1;
		bl = 0;
	}

	let parts = [], i = 0;
	while (i < 8) {
		if (i == bs) {
			push(parts, '');
			i += bl;
			continue;
		}
		push(parts, sprintf('%x', g[i]));
		i++;
	}

	let out = join(':', parts);

	if (bs == 0)
		out = ':' + out;
	if (bs >= 0 && bs + bl == 8)
		out = out + ':';

	return out;
}

export function decode_name(buf, off) {
	let blen = length(buf), labels = [], total = 1;

	while (true) {
		if (off >= blen)
			return { err: ERR.SHORT };

		let len = ord(buf, off);

		if ((len & LBL_MASK) == LBL_PTR)
			return { err: ERR.QPTR };
		if (len & LBL_MASK)
			return { err: ERR.LABEL };

		off++;
		if (!len)
			break;

		total += len + 1;
		if (total > LIM.name)
			return { err: ERR.NAMELEN };
		if (off + len > blen)
			return { err: ERR.SHORT };

		let lbl = lc(substr(buf, off, len));
		for (let i = 0; i < len; i++) {
			let c = ord(lbl, i);
			if ((c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39) ||
				c == 0x2d || c == 0x5f)
				continue;
			return { err: ERR.CHARSET };
		}

		push(labels, lbl);
		off += len;
	}

	return { name: join('.', labels), next: off };
};

export function skip_name(buf, off) {
	let blen = length(buf);

	while (true) {
		if (off >= blen)
			return null;

		let len = ord(buf, off);

		if ((len & LBL_MASK) == LBL_PTR)
			return (off + 2 <= blen) ? off + 2 : null;
		if (len & LBL_MASK)
			return null;

		off++;
		if (!len)
			return off;

		off += len;
		if (off > blen)
			return null;
	}
};

export function parse(buf) {
	let blen = length(buf ?? '');

	if (blen > LIM.msg)
		return { ok: false, err: ERR.MSGLEN };
	if (blen < HDR_LEN)
		return { ok: false, err: ERR.SHORT };

	let flags = u16at(buf, 2);

	if (!(flags & F_QR))
		return { ok: false, err: ERR.NOTRESP };
	if (flags & F_TC)
		return { ok: false, err: ERR.TRUNC };
	if (flags & M_RCODE)
		return { ok: false, err: ERR.RCODE };

	if (u16at(buf, 4) != 1)
		return { ok: false, err: ERR.QDCOUNT };

	let ancount = u16at(buf, 6);
	if (ancount > LIM.answers)
		return { ok: false, err: ERR.ANSMAX };

	let q = decode_name(buf, HDR_LEN);
	if (q.err)
		return { ok: false, err: q.err };

	let off = q.next;
	if (off + 4 > blen)
		return { ok: false, err: ERR.SHORT };

	let qtype = u16at(buf, off);
	off += 4;

	let a = [], aaaa = [];

	for (let i = 0; i < ancount; i++) {
		off = skip_name(buf, off);
		if (off === null)
			return { ok: false, err: ERR.SHORT };

		if (off + RR_FIXED > blen)
			return { ok: false, err: ERR.SHORT };

		let rtype = u16at(buf, off);
		let rdlen = u16at(buf, off + 8);
		off += RR_FIXED;

		if (off + rdlen > blen)
			return { ok: false, err: ERR.RDLEN };

		if (rtype == TYPE.A) {
			if (rdlen != 4)
				return { ok: false, err: ERR.RDLEN };
			push(a, fmt4(buf, off));
		}
		else if (rtype == TYPE.AAAA) {
			if (rdlen != 16)
				return { ok: false, err: ERR.RDLEN };
			push(aaaa, fmt6(buf, off));
		}

		off += rdlen;
	}

	return {
		ok: true,
		id: u16at(buf, 0),
		qname: q.name,
		qtype,
		a,
		aaaa
	};
};
