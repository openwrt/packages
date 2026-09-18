/* strict mode compliance: ensure that global variables are defined */
if (!exists(global, 'REQUIRE_SEARCH_PATH'))
	global.REQUIRE_SEARCH_PATH = [];

if (!exists(global, 'MOCK_SEARCH_PATH'))
	global.MOCK_SEARCH_PATH = [];

if (!exists(global, 'TRACE_CALLS'))
	global.TRACE_CALLS = null;

let _fs = require("fs");

/* Force reloading fs module on next require */
delete global.modules.fs;

/* Also force reloading uci and ubus modules */
delete global.modules.uci;
delete global.modules.ubus;

let _log = (level, fmt, ...args) => {
	let color, prefix;

	switch (level) {
	case 'info':
		color = 34;
		prefix = '!';
		break;

	case 'warn':
		color = 33;
		prefix = 'W';
		break;

	case 'error':
		color = 31;
		prefix = 'E';
		break;

	default:
		color = 0;
		prefix = 'I';
	}

	let f = sprintf("\u001b[%d;1m[%s] %s\u001b[0m", color, prefix, fmt);
	warn(replace(sprintf(f, ...args), "\n", "\n    "), "\n");
};

let read_data_file = (path) => {
	for (let dir in MOCK_SEARCH_PATH) {
		let fd = _fs.open(dir + '/' + path, "r");

		if (fd) {
			let data = fd.read("all");
			fd.close();

			return data;
		}
	}

	return null;
};

let read_json_file = (path) => {
	let data = read_data_file(path);

	if (data != null)  {
		try {
			return json(data);
		}
		catch (e) {
			_log('error', "Unable to parse JSON data in %s: %s", path, e);

			return NaN;
		}
	}

	return null;
};

let format_json = (data) => {
	let rv;

	let format_value = (value) => {
		switch (type(value)) {
		case "object":
			return sprintf("{ /* %d keys */ }", length(value));

		case "array":
			return sprintf("[ /* %d items */ ]", length(value));

		case "string":
			if (length(value) > 64)
				value = substr(value, 0, 64) + "...";

			/* fall through */
			return sprintf("%J", value);

		default:
			return sprintf("%J", value);
		}
	};

	switch (type(data)) {
	case "object":
		rv = "{";

		let k = sort(keys(data));

		for (let i, n in k)
			rv += sprintf("%s %J: %s", i ? "," : "", n, format_value(data[n]));

		rv += " }";
		break;

	case "array":
		rv = "[";

		for (let i, v in data)
			rv += (i ? "," : "") + " " + format_value(v);

		rv += " ]";
		break;

	default:
		rv = format_value(data);
	}

	return rv;
};

let trace_call = (ns, func, args) => {
	let msg = "[call] " +
		(ns ? ns + "." : "") +
		func;

	for (let k, v in args) {
		msg += ' ' + k + ' <';

		switch (type(v)) {
		case "array":
		case "object":
			msg += format_json(v);
			break;

		default:
			msg += v;
		}

		msg += '>';
	}

	switch (TRACE_CALLS) {
	case '1':
	case 'stdout':
		_fs.stdout.write(msg + "\n");
		break;

	case 'stderr':
		_fs.stderr.write(msg + "\n");
		break;
	}
};

/* Captured file contents from mock writefile — used for readfile/writefile round-trip */
let _captured = {};

/* Commands passed to system() — used by tests to assert on what was executed.
   run_tests.sh spawns one ucode process per testcase, so this starts empty for
   each and cannot leak into the next; clear_commands() is for asserting a single
   phase within one run, not for cleaning up after another test. */
let _commands = [];
let _argvs = [];

/* Needles whose commands system() should report as failed. Empty by default:
   the stub returns 0 for everything, which is what nearly every test wants. */
let _failing = [];

/* Select recorded commands: everything when needle is null, those containing
   needle when it is a string, those matching it when it is a regexp. */
let commands_matching = (needle) => {
	if (needle == null)
		return slice(_commands);

	if (type(needle) == "regexp")
		return filter(_commands, cmd => match(cmd, needle));

	return filter(_commands, cmd => index(cmd, '' + needle) >= 0);
};

/* Same needle semantics, applied to one command as it is executed. Note the
   needle sees the command line EXACTLY as it was handed to system(), which for
   anything routed through sh.try_cmd() means every word is single-quoted: a
   regexp like /route replace/ will not match `'route' 'replace'`, while the
   bare substring "route" still does. */
let command_fails = (cmd) => {
	for (let needle in _failing) {
		if (type(needle) == "regexp") {
			if (match(cmd, needle)) return true;
		} else if (index(cmd, '' + needle) >= 0) {
			return true;
		}
	}
	return false;
};

/* Prepend mocklib to REQUIRE_SEARCH_PATH */
for (let pattern in REQUIRE_SEARCH_PATH) {
	/* Only consider ucode includes */
	if (!match(pattern, /\*\.uc$/))
		continue;

	let path = replace(pattern, /\*/, 'mocklib'),
	    stat = _fs.stat(path);

	if (!stat || stat.type != 'file')
		continue;

	if (!length(global.MOCK_SEARCH_PATH))
		global.MOCK_SEARCH_PATH = [ replace(path, /mocklib\.uc$/, '../mocks') ];

	unshift(REQUIRE_SEARCH_PATH, replace(path, /mocklib\.uc$/, 'mocklib/*.uc'));
	break;
}

if (!length(global.MOCK_SEARCH_PATH))
	global.MOCK_SEARCH_PATH = [ './mocks' ];

/* Register global mocklib namespace */
global.mocklib = {
	require: function(module) {
		let path, res, ex;

		if (type(REQUIRE_SEARCH_PATH) == "array" && index(REQUIRE_SEARCH_PATH[0], 'mocklib/*.uc') != -1)
			path = shift(REQUIRE_SEARCH_PATH);

		try {
			res = require(module);
		}
		catch (e) {
			ex = e;
		}

		if (path)
			unshift(REQUIRE_SEARCH_PATH, path);

		if (ex)
			die(ex);

		return res;
	},

	I: (...args) => _log('info', ...args),
	N: (...args) => _log('notice', ...args),
	W: (...args) => _log('warn', ...args),
	E: (...args) => _log('error', ...args),

	format_json,
	read_data_file,
	read_json_file,
	trace_call,

	/* Store content in the captured map (called by mock writefile) */
	capture: (path, data) => { _captured[path] = data; },

	/* Read content from the captured map (called by tests to inspect output) */
	read_captured: (path) => _captured[path],

	/* Check if a path exists in the captured map */
	has_captured: (path) => exists(_captured, path),

	/* Remove a path from the captured map */
	delete_captured: (path) => { delete _captured[path]; },

	/* Read the commands system() was called with, in call order (called by
	   tests to inspect commands that are executed rather than written out).
	   Returns a copy, so the caller cannot disturb the recording.

	   Pass nothing for the full list, a string to keep only the commands
	   containing it, or a regexp to keep only the ones matching it. Note
	   sh.run() appends ' >/dev/null 2>&1' to everything it runs, so match on
	   substrings or anchored regexps rather than on equality. */
	commands: commands_matching,

	/* Check whether any recorded command matches — same argument as commands() */
	has_command: (needle) => length(commands_matching(needle)) > 0,

	/* Drop everything recorded so far, so a test can record one phase at a
	   time (e.g. clear after start_service() to assert on stop_service()) */
	clear_commands: () => { _commands = []; _argvs = []; _failing = []; },

	/* Read what system() was called with WITHOUT the join(' ') flattening that
	   commands() applies -- an array call is returned as an array. Needed to
	   assert that an argument containing a space is passed as ONE argv element
	   rather than being re-split by a shell; commands() cannot see that
	   difference, since ['a b','c'] and ['a','b','c'] join identically. */
	argvs: () => [ ..._argvs ],

	/* Make system() return non-zero for commands matching this needle, so an
	   error path that only runs on a failed command can be exercised. Same
	   argument as commands(): a string matches as a substring, a regexp is
	   matched against the command line. Call it more than once to fail more
	   than one shape of command; clear_commands() resets the list along with
	   the recording. */
	fail_command: (needle) => { push(_failing, needle); },
};

/* Override stdlib functions */
global.system = function(argv, timeout) {
	trace_call(null, "system", { command: argv, timeout });

	/* Record the command for mocklib.commands(). Everything is recorded,
	   including the '[ -t 2 ]' tty probe below, so the list reflects the
	   process exactly as it ran. */
	push(_commands, type(argv) == "array" ? join(' ', argv) : '' + argv);
	push(_argvs, type(argv) == "array" ? [ ...argv ] : '' + argv);

	/* Return 1 for tty checks so output goes to logger, not stderr */
	if (type(argv) == "string" && index(argv, "[ -t ") >= 0)
		return 1;

	if (length(_failing) &&
	    command_fails(type(argv) == "array" ? join(' ', argv) : '' + argv))
		return 1;

	return 0;
};

global.time = function() {
	trace_call(null, "time");

	return 1615382640;
};

global.print = ((_orig) => function(...args) {
	if (length(args) == 1 && type(args[0]) in ["array", "object"])
		printf("%s\n", format_json(args[0]));
	else
		_orig(...args);
})(global.print);

/* Override getenv — returns null */
global.getenv = function(key) {
	return null;
};

/* Override getpid — returns fixed PID */
global.getpid = function() {
	return 12345;
};

/* Override loadstring — returns a no-op function for user file tests */
global._orig_loadstring = global.loadstring;

return global.mocklib;
