// shunt - domain patterns from files
//
// Reads the files a policy names in `domain_file` and attaches their
// patterns as `file_domains`, kept apart from the hand-entered `domains`:
// the matcher takes both, poll takes only the latter. A file is the shape
// a community list comes in, and resolving ten thousand names every poll
// interval is not a service, it is a DNS storm - so file entries are
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

// Hard limit on one file: a list of that size is the wrong tool on a
// router, and reading it into a ucode array would show why.
export const LIM = {
	size: 4 * 1024 * 1024
};

export const DIR = '/tmp/shunt';

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

// One pattern per line, `#` starts a comment, blanks are skipped. Only the
// count and the first offender are reported, not every bad line - a list
// with a thousand broken entries must not turn into a thousand log lines.
export function parse(text) {
	let patterns = [], seen = {};
	let lines = 0, rejected = 0, first = null;

	for (let line in split(text ?? '', '\n')) {
		lines++;

		let hash = index(line, '#');
		if (hash >= 0)
			line = substr(line, 0, hash);

		line = trim(line);
		if (!length(line))
			continue;

		let r = pattern(line);

		if (r.error) {
			rejected++;
			if (first == null)
				first = sprintf('line %d: %s', lines, r.error);
			continue;
		}

		let key = (r.wild ? '*.' : '') + r.pat;

		if (seen[key])
			continue;

		seen[key] = true;
		push(patterns, key);
	}

	return { patterns, rejected, first };
};

export function load(policies, reader) {
	let rd = reader ?? read;
	let cache = {}, issues = [], out = [];
	let files = 0, entries = 0;

	function reject(policy, entry, reason) {
		push(issues, { policy, entry, reason });
	}

	function fetch(path) {
		if (cache[path] != null)
			return cache[path];

		let file = resolve(path);
		let res = { file: file ?? path, patterns: [], error: null };

		if (file == null) {
			res.error = 'not a file name - a bare name or an absolute path';
		}
		else {
			let f = rd(file);

			if (f.error) {
				res.error = f.missing ? f.error : `cannot read: ${f.error}`;
			}
			else {
				let p = parse(f.text);

				res.patterns = p.patterns;

				if (!length(p.patterns))
					res.error = p.rejected
						? sprintf('no usable pattern, %d line(s) rejected (%s)',
							p.rejected, p.first)
						: 'no usable pattern';
				else if (p.rejected)
					res.warn = sprintf('%d line(s) rejected (%s), %d pattern(s) kept',
						p.rejected, p.first, length(p.patterns));

				files++;
				entries += length(p.patterns);
			}
		}

		cache[path] = res;

		return res;
	}

	for (let p in (policies ?? [])) {
		let file_domains = [];

		for (let path in (p?.domain_files ?? [])) {
			let res = fetch(path);

			if (res.error)
				reject(p?.name, res.file, res.error);
			else if (res.warn)
				reject(p?.name, res.file, res.warn);

			for (let pat in res.patterns)
				push(file_domains, pat);
		}

		push(out, { ...p, file_domains });
	}

	return { policies: out, issues, files, entries };
};
