// SPDX-License-Identifier: GPL-2.0-or-later
// shared backend selection and locking for uvol entry points
//  (c) 2022 Daniel Golle <daniel@makrotopia.org>

let common_fs = require("fs");
let common_uci = require("uci");

include("/usr/lib/uvol/mount.uc");

let shell_quote = function(word) {
	return "'" + replace(`${word}`, /'/g, "'\\''") + "'";
};

// volumes are taken down whether or not anything mounted them, so umount is
// expected to fail and stays quiet. That needs a shell, hence the quoting.
let umount_dev = function(dev) {
	return system(sprintf("umount %s 2>/dev/null", shell_quote(sprintf("/dev/%s", dev))));
};

let lock_open = function(path) {
	common_fs.mkdir("/tmp/run", 0755);
	let lockfd = common_fs.open(path, "a");
	if (lockfd)
		lockfd.lock("x");
	return lockfd;
};

uvol_common = {
	// volume names reach tool arguments and lock file paths; anything outside
	// this set is refused before it gets there. A leading '.' is reserved for
	// internal volumes such as .meta, and a leading '-' would be taken for an
	// option by the backend tools.
	name_valid: function(name, allow_internal) {
		if (type(name) != "string")
			return false;
		if (allow_internal && name == ".meta")
			return true;
		return !!match(name, /^[A-Za-z0-9_][A-Za-z0-9._-]*$/);
	},

	shell_quote: shell_quote,

	ctx_init: function() {
		let ctx = {};
		ctx.cursor = common_uci ? common_uci.cursor() : null;
		ctx.fs = common_fs;
		ctx.register = uvol_mount.register;
		ctx.unregister = uvol_mount.unregister;
		ctx.shell_quote = shell_quote;
		ctx.umount_dev = umount_dev;
		return ctx;
	},

	backend_select: function(ctx) {
		let backend = null;
		let tried = [];
		for (let plugin in common_fs.glob("/usr/lib/uvol/backends/*.uc")) {
			let current_backend = {};
			include(plugin, { backend: current_backend });
			push(tried, current_backend.backend);
			if (type(backend) == "object" &&
			    type(backend.priority) == "int" &&
			    type(current_backend.priority) == "int" &&
			    backend.priority > current_backend.priority)
				continue;
			if (type(current_backend.init) == "function" &&
			    current_backend.init(ctx)) {
				backend = current_backend;
				break;
			}
		}
		return { backend: backend, tried: tried };
	},

	// released on process exit; the caller keeps the returned fd alive
	lock_device: function() {
		return lock_open("/tmp/run/uvol.lock");
	},

	lock_volume: function(vol_name) {
		return lock_open(sprintf("/tmp/run/uvol.lock.%s", vol_name));
	}
};
