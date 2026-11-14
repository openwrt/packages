let mocklib = global.mocklib; // ucode-lsp disable

let stat_path = function(path) { // ucode-lsp disable
	/* Check captured content first */
	if (mocklib.has_captured(path)) {
		mocklib.trace_call("fs", "stat", { path, source: "captured" });
		return { type: "file", size: length(mocklib.read_captured(path)) };
	}

	let file = sprintf("fs/stat~%s.json", replace(path, /[^A-Za-z0-9_-]+/g, '_')),
	    mock = mocklib.read_json_file(file);

	if (!mock || mock != mock) {
		/* No fixture: return null to indicate "not found" by default.
		 * For paths that look like directories, return directory type. */
		if (match(path, /\/$/))
			return { type: "directory" };
		/* Most stat() calls in pbr check for existence — return null
		 * unless there's a specific mock or captured content. */
		return null;
	}

	mocklib.trace_call("fs", "stat", { path });

	return mock;
};

return {
	readfile: function(path, limit) {
		/* Check captured content first (from mock writefile) */
		if (mocklib.has_captured(path)) {
			mocklib.trace_call("fs", "readfile", { path, limit, source: "captured" });
			let data = mocklib.read_captured(path);
			return limit ? substr(data, 0, limit) : data;
		}

		let file = sprintf("fs/open~%s.txt", replace(path, /[^A-Za-z0-9_-]+/g, '_')),
		    mock = mocklib.read_data_file(file);

		if (mock == null) {
			/* Silently return null for missing fixtures */
			return null;
		}

		mocklib.trace_call("fs", "readfile", { path, limit });

		return limit ? substr(mock, 0, limit) : mock;
	},

	writefile: function(path, data) {
		mocklib.capture(path, data);
		mocklib.trace_call("fs", "writefile", { path, length: length(data) });

		return length(data);
	},

	popen: (cmdline, mode) => {
		let read = (!mode || index(mode, "r") != -1),
		    path = sprintf("fs/popen~%s.txt", replace(cmdline, /[^A-Za-z0-9_-]+/g, '_')),
		    mock = mocklib.read_data_file(path);

		if (read && mock == null) {
			/* Silently return empty-read handle for missing fixtures */
			return {
				read: function(amount) { return ''; },
				write: function() {},
				close: function() {},
				error: function() { return null; }
			};
		}

		mocklib.trace_call("fs", "popen", { cmdline, mode });

		return {
			read: function(amount) {
				let rv;

				switch (amount) {
				case "all":
					rv = mock;
					mock = "";
					break;

				case "line":
					let i = index(mock, "\n");
					i = (i > -1) ? i + 1 : length(mock);
					rv = substr(mock, 0, i);
					mock = substr(mock, i);
					break;

				default:
					let n = +amount;
					n = (n > 0) ? n : 0;
					rv = substr(mock, 0, n);
					mock = substr(mock, n);
					break;
				}

				return rv;
			},

			write: function() {},
			close: function() {},

			error: function() {
				return null;
			}
		};
	},

	stat: stat_path,

	/* is_phys_dev() probes /sys/class/net/<dev> with lstat() because the entry
	   is a symlink. pbr passes fs.lstat around as a bare function reference, so
	   it must not depend on a receiver; fixtures are shared with stat(). */
	lstat: stat_path,

	unlink: function(path) {
		mocklib.delete_captured(path);
		mocklib.trace_call("fs", "unlink", { path });

		return true;
	},

	open: function(path, mode) {
		mocklib.trace_call("fs", "open", { path, mode });

		if (mode && index(mode, 'a') != -1) {
			/* Append mode: capture writes */
			let existing = mocklib.has_captured(path) ? mocklib.read_captured(path) : '';
			return {
				write: function(data) {
					existing += data;
					mocklib.capture(path, existing);
					return length(data);
				},
				close: function() {},
				read: function() { return ''; },
				error: function() { return null; }
			};
		}

		if (mode && index(mode, 'w') != -1) {
			/* Write mode */
			return {
				write: function(data) {
					mocklib.capture(path, data);
					return length(data);
				},
				close: function() {},
				read: function() { return ''; },
				error: function() { return null; }
			};
		}

		/* Read mode */
		let file = sprintf("fs/open~%s.txt", replace(path, /[^A-Za-z0-9_-]+/g, '_')),
		    mock = mocklib.read_data_file(file);

		if (mock == null) return null;

		return {
			read: function(amount) {
				let rv;
				switch (amount) {
				case "all":
					rv = mock;
					mock = "";
					break;
				case "line":
					let i = index(mock, "\n");
					i = (i > -1) ? i + 1 : length(mock);
					rv = substr(mock, 0, i);
					mock = substr(mock, i);
					break;
				default:
					let n = +amount;
					n = (n > 0) ? n : 0;
					rv = substr(mock, 0, n);
					mock = substr(mock, n);
					break;
				}
				return rv;
			},
			write: function() {},
			close: function() {},
			error: function() { return null; }
		};
	},

	glob: function(pattern) {
		mocklib.trace_call("fs", "glob", { pattern });
		return [];
	},

	mkdir: function(path) {
		mocklib.trace_call("fs", "mkdir", { path });
		return true;
	},

	mkstemp: function(template) {
		mocklib.trace_call("fs", "mkstemp", { template });
		let path = replace(template, /X+/, 'mock12');
		return {
			path: path,
			read: function() { return ''; },
			write: function(data) { mocklib.capture(path, data); return length(data); },
			close: function() {},
			error: function() { return null; }
		};
	},

	access: function(path, mode) {
		let file = sprintf("fs/access~%s~%s.txt", replace(path, /[^A-Za-z0-9_-]+/g, '_'), mode || 'r'),
		    mock = mocklib.read_data_file(file);

		if (mock != null) {
			mocklib.trace_call("fs", "access", { path, mode });
			return trim(mock) == 'true';
		}

		/* Default: check for a stat fixture or captured content */
		if (mocklib.has_captured(path)) return true;

		return null;
	},

	dirname: function(path) {
		let m = match(path, /^(.+)\/[^\/]+\/?$/);
		return m ? m[1] : '.';
	},

	lsdir: function(path) {
		mocklib.trace_call("fs", "lsdir", { path });
		return [];
	},

	error: () => "Unspecified error"
};
