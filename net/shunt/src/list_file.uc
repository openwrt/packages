// shunt - domain and address lists from files
//
// Reads the files a policy names in `domain_file` and `dst_file` and
// attaches their entries as `file_domains` and `file_dst`, kept apart from
// the hand-entered `domains` and `dst`: the matcher takes both domain
// lists, poll takes only the typed one, and nft renders both address lists
// into the policy's static destination sets. A file is the shape a
// community list comes in, and resolving ten thousand names every poll
// interval is not a service, it is a DNS storm - so file domains are
// learned passively, by snoop, when a client asks for them.
//
// Where the file comes from is not shunt's business. cron, a script, a
// package of its own - whatever writes it runs `shunt refresh`, and the
// daemon re-reads. A bare name lives under DIR, which is tmpfs: a list of
// that size has no business on flash, and a file that is not there yet
// after a reboot is the expected state, not a fault.
//
// load() is pure and takes the reader as an argument; read() is the one
// backed by the file system.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

import { readfile, stat, error as fs_error } from 'fs';
import { pattern } from 'shunt.match';
import { addr_family } from 'shunt.nft';

// Hard limit on one file: a list of that size is the wrong tool on a
// router, and reading it into a ucode array would show why.
export const LIM = {
	size: 4 * 1024 * 1024
};

export const DIR = '/tmp/shunt';

// One line, checked by the rules of the list it belongs to: `{ key }` for
// a usable entry in its canonical form, `{ error }` otherwise.
const KINDS = {
	domain: function(line) {
		let r = pattern(line);

		return r.error ? r : { key: (r.wild ? '*.' : '') + r.pat };
	},

	// The family check nft.uc applies to a typed `list dst`, so a file
	// entry is never one the kernel refuses - one bad element would take
	// the whole batch, every other policy included, down with it.
	dst: function(line) {
		let fam = addr_family(line);

		return fam ? { key: lc(line), fam } : { error: 'not an address or prefix' };
	}
};

// A bare name resolves under DIR; an absolute path is taken as given, for
// a list that lives on a mounted drive or in an overlay of the user's
// choosing. Anything else - empty, or a relative path with directories -
// is not a file name.
export function resolve(name) {
	if (type(name) != 'string' || !length(name))
		return null;
	if (substr(name, 0, 1) == '/')
		return name;
	if (index(name, '/') >= 0)
		return null;

	return `${DIR}/${name}`;
};

export function read(path) {
	let st = stat(path);

	if (st == null)
		return { error: 'not found - `shunt refresh` loads it once it is there', missing: true };

	if (st.type != 'file')
		return { error: `not a regular file (${st.type})` };

	if (st.size > LIM.size)
		return { error: sprintf('too large (%d bytes, limit %d)', st.size, LIM.size) };

	let text = readfile(path);

	if (text == null)
		return { error: fs_error() ?? 'unreadable' };

	return { text };
};

// One entry per line, `#` starts a comment, blanks are skipped. Only the
// count and the first offender are reported, not every bad line - a list
// with a thousand broken entries must not turn into a thousand log lines.
export function parse(text, kind) {
	let check = KINDS[kind ?? 'domain'];
	let entries = [], seen = {};
	let lines = 0, rejected = 0, first = null;

	for (let line in split(text ?? '', '\n')) {
		lines++;

		let hash = index(line, '#');
		if (hash >= 0)
			line = substr(line, 0, hash);

		line = trim(line);
		if (!length(line))
			continue;

		let r = check(line);

		if (r.error) {
			rejected++;
			if (first == null)
				first = sprintf('line %d: %s', lines, r.error);
			continue;
		}

		if (seen[r.key])
			continue;

		seen[r.key] = true;
		push(entries, r.key);
	}

	return { entries, rejected, first };
};

export function load(policies, reader) {
	let rd = reader ?? read;
	let cache = {}, issues = [], out = [];
	let files = 0, entries = 0, addresses = 0;

	function reject(policy, entry, reason) {
		push(issues, { policy, entry, reason });
	}

	// Keyed by kind as well: the same file named as a domain list by one
	// policy and as an address list by another is two different readings.
	function fetch(path, kind) {
		let ck = `${kind}:${path}`;

		if (cache[ck] != null)
			return cache[ck];

		let file = resolve(path);
		let res = { file: file ?? path, entries: [], error: null };
		let what = (kind == 'dst') ? 'address' : 'pattern';
		let whats = (kind == 'dst') ? 'address(es)' : 'pattern(s)';

		if (file == null) {
			res.error = 'not a file name - a bare name or an absolute path';
		}
		else {
			let f = rd(file);

			if (f.error) {
				res.error = f.missing ? f.error : `cannot read: ${f.error}`;
			}
			else {
				let p = parse(f.text, kind);

				res.entries = p.entries;

				if (!length(p.entries))
					res.error = p.rejected
						? sprintf('no usable %s, %d line(s) rejected (%s)',
							what, p.rejected, p.first)
						: `no usable ${what}`;
				else if (p.rejected)
					res.warn = sprintf('%d line(s) rejected (%s), %d %s kept',
						p.rejected, p.first, length(p.entries), whats);

				files++;

				if (kind == 'dst')
					addresses += length(p.entries);
				else
					entries += length(p.entries);
			}
		}

		cache[ck] = res;

		return res;
	}

	function collect(p, paths, kind) {
		let got = [];

		for (let path in (paths ?? [])) {
			let res = fetch(path, kind);

			if (res.error)
				reject(p?.name, res.file, res.error);
			else if (res.warn)
				reject(p?.name, res.file, res.warn);

			for (let e in res.entries)
				push(got, e);
		}

		return got;
	}

	for (let p in (policies ?? [])) {
		push(out, {
			...p,
			file_domains: collect(p, p?.domain_files, 'domain'),
			file_dst: collect(p, p?.dst_files, 'dst')
		});
	}

	return { policies: out, issues, files, entries, addresses };
};
