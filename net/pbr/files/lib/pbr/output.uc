'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// Logging and output system with verbosity levels.

function create_output(sh, pkg_name, sym) {
	let output_queue = '';
	let verbosity = 0;
	let is_tty = false;
	let script_name = pkg_name;
	let _uci_getter = null;

	function set_state(opts) {
		if (opts.verbosity != null) verbosity = opts.verbosity;
		if (opts.is_tty != null) is_tty = opts.is_tty;
		if (opts.script_name != null) script_name = opts.script_name;
		if (opts.uci_getter != null) _uci_getter = opts.uci_getter;
	}

	function _write(level, ...args) {
		let msg = join('', args);
		if (level != null && (verbosity & level) == 0) return;

		if (is_tty)
			warn(replace(msg, /\\n/g, '\n'));

		if (index(msg, '\\n') >= 0 || index(msg, '\n') >= 0) {
			msg = output_queue + msg;
			output_queue = '';
			let clean = replace(msg, /\x1b\[[0-9;]*m/g, '');
			clean = replace(clean, /\\n/g, '\n');
			clean = trim(clean);
			// Argument ARRAY, not a shell string: the message reaches logger as
			// one argv element, so arbitrary log text -- interface names, UCI
			// values, nft error output -- can never be re-split on spaces or
			// read as shell syntax. This is why sh.quote() is gone from here,
			// and why `sh` is now unused by create_output(). system() has taken
			// arrays since well before the oldest ucode pbr supports; see
			// create_sys().ip() in sys.uc for the full rationale.
			if (clean != '')
				system(['/usr/bin/logger', '-t', script_name, clean]);
		} else {
			output_queue += msg;
		}
	}

	function logger_debug(debug_performance, msg) {
		if (debug_performance)
			system(['/usr/bin/logger', '-t', script_name, msg]);
	}

	let out = {
		set_state,
		_write,
		logger_debug,
		info: {
			write:   function(...args) { _write(1, ...args); },
			ok:      function() { _write(1, sym.ok[0]); },
			okn:     function() { _write(1, sym.ok[0] + '\\n'); },
			okb:     function() { _write(1, sym.okb[0]); },
			okbn:    function() { _write(1, sym.okb[0] + '\\n'); },
			fail:    function() { _write(1, sym.fail[0]); },
			failn:   function() { _write(1, sym.fail[0] + '\\n'); },
			newline: function() { _write(1, '\\n'); },
		},
		verbose: {
			write:   function(...args) { _write(2, ...args); },
			ok:      function() { _write(2, sym.ok[1] + '\\n'); },
			okn:     function() { _write(2, sym.ok[1] + '\\n'); },
			okb:     function() { _write(2, sym.okb[1] + '\\n'); },
			okbn:    function() { _write(2, sym.okb[1] + '\\n'); },
			fail:    function() { _write(2, sym.fail[1] + '\\n'); },
			failn:   function() { _write(2, sym.fail[1] + '\\n'); },
			newline: function() { _write(2, '\\n'); },
		},
		print:    function(...args) { _write(null, ...args); },
		ok:       function() { _write(1, sym.ok[0]); _write(2, sym.ok[1] + '\\n'); },
		okn:      function() { _write(1, sym.ok[0] + '\\n'); _write(2, sym.ok[1] + '\\n'); },
		okb:      function() { _write(1, sym.okb[0]); _write(2, sym.okb[1] + '\\n'); },
		okbn:     function() { _write(1, sym.okb[0] + '\\n'); _write(2, sym.okb[1] + '\\n'); },
		fail:     function() { _write(1, sym.fail[0]); _write(2, sym.fail[1] + '\\n'); },
		failn:    function() { _write(1, sym.fail[0] + '\\n'); _write(2, sym.fail[1] + '\\n'); },
		dot:      function() { _write(1, sym.dot[0]); _write(2, sym.dot[1]); },
		error:    function(msg) { _write(null, sym.ERR + ' ' + msg + '!\\n'); },
		warning:  function(msg) { _write(3, sym.WARN + ' ' + msg + '.\\n'); },
		quiet_mode: function(mode, uci_getter) {
			if (mode == 'on') verbosity = 0;
			else if (uci_getter) verbosity = int(uci_getter() || '2');
		},
	};

	return out;
}

export default create_output;
