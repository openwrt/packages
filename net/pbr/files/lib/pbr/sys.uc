'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// System interaction wrappers: shell execution, directory creation,
// ip command wrapper with rule-replace emulation.

function create_sys(fs_mod, pkg) {
	let popen = fs_mod.popen;
	let stat = fs_mod.stat;
	let access = fs_mod.access;
	let _dirname = fs_mod.dirname;
	let _mkdir = fs_mod.mkdir;

	function quote(s) {
		return "'" + replace('' + s, "'", "'\\''") + "'";
	}

	function exec(cmd) {
		let p = popen(cmd, 'r');
		if (!p) return '';
		let data = p.read('all') || '';
		p.close();
		return trim(data);
	}

	function run(cmd) {
		return system(cmd + ' >/dev/null 2>&1');
	}

	function mkdir_p(path) {
		if (!path || stat(path)?.type == 'directory') return true;
		let parent = _dirname(path);
		if (parent && parent != path) mkdir_p(parent);
		return _mkdir(path) != null;
	}

	function is_present(cmd) {
		if (index(cmd, '/') >= 0)
			return access(cmd, 'x') == true;
		for (let dir in ['/usr/sbin', '/usr/bin', '/sbin', '/bin'])
			if (access(dir + '/' + cmd, 'x') == true) return true;
		return false;
	}

	// Callers pass an argument VECTOR. Hand it to system() as an array so it is
	// execvp()'d directly: no shell, so no quoting, no re-splitting on spaces,
	// and no metacharacter interpretation of UCI-derived values. system() has
	// accepted arrays since long before the oldest ucode pbr supports
	// (verified on ucode 85922056 / OpenWrt 25.12) -- unlike fs.popen(), which
	// is string-only there. Non-string elements are coerced by system() itself.
	function ip(...args) {
		if (length(args) < 1) return 1;
		let fam = args[0];
		if (fam == '-4' || fam == '-6') {
			let rest = slice(args, 1);
			if (length(rest) >= 2 && rest[0] == 'rule' && rest[1] == 'replace') {
				let rule_args = slice(rest, 2);
				let prio = null;
				let newargs = [];
				for (let i = 0; i < length(rule_args); i++) {
					if (rule_args[i] == 'priority' || rule_args[i] == 'pref') {
						i++;
						if (i < length(rule_args))
							prio = rule_args[i];
						continue;
					}
					push(newargs, rule_args[i]);
				}
				if (prio != null) {
					// Keeps the shell: system() has no fd redirection, and this
					// delete is expected to fail when no such rule exists, so
					// its stderr must be suppressed. quote() the interpolation.
					system(pkg.ip_full + ' ' + fam + ' rule del priority ' + quote(prio) + ' 2>/dev/null');
					return system([pkg.ip_full, fam, 'rule', 'add', ...newargs, 'pref', prio]);
				}
				return system([pkg.ip_full, fam, 'rule', 'add', ...newargs]);
			}
			return system([pkg.ip_full, fam, ...rest]);
		}
		return system([pkg.ip_full, ...args]);
	}

	// Callers hand this an argument VECTOR too, but unlike ip() it cannot go to
	// system() as an array: every caller is a command whose failure is expected
	// and routine -- a route replace on an interface that has no gateway yet --
	// so its stderr must be suppressed, and system() has no fd redirection (see
	// run()). The shell therefore stays, and every element is quote()d instead,
	// which is what keeps a value carrying a space or a shell metacharacter as
	// one argv word. The recorded error carries the UNQUOTED join: that string
	// is shown to the user, not executed.
	function try_cmd(errors, ...args) {
		if (run(join(' ', map(args, quote))) != 0) {
			push(errors, { code: 'errorTryFailed', info: join(' ', args) });
			return false;
		}
		return true;
	}

	function try_ip(errors, ...args) {
		if (ip(...args) != 0) {
			push(errors, { code: 'errorTryFailed', info: pkg.ip_full + ' ' + join(' ', args) });
			return false;
		}
		return true;
	}

	return { quote, exec, run, mkdir_p, is_present, ip, try_cmd, try_ip };
}

export default create_sys;
