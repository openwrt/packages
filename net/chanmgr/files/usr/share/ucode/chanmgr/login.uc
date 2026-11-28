// SPDX-License-Identifier: GPL-2.0-only
// The rpcd login a controller uses to reach this device's agent. It only
// grants the chanmgr-agent ACL (scan, survey, channel switch).

'use strict';

let fs = require('fs');
let uci = require('uci');

const ACL = 'chanmgr-agent';

function shq(s) {
	return "'" + replace('' + s, "'", "'\\''") + "'";
}

function list(v) {
	return (v == null) ? [] : (type(v) == 'array') ? v : [ v ];
}

// Ours: created here (option chanmgr), or by hand with only our ACL.
function is_ours(s) {
	return s.chanmgr == '1' ||
		(join(' ', list(s.read)) == ACL && join(' ', list(s.write)) == ACL);
}

function find(c, username) {
	let found = null, other = null;

	c.foreach('rpcd', 'login', (s) => {
		if (username != null && s.username != username)
			return;

		if (is_ours(s))
			found ??= s;
		else
			other ??= s;
	});

	return { found, other };
}

function get() {
	let f = find(uci.cursor()).found;

	return f ? { configured: true, username: f.username } : { configured: false };
}

function set(username, password) {
	username ??= 'chanmgr';

	if (!match(username, /^[A-Za-z0-9_.-]{1,32}$/))
		return { ok: false, error: 'invalid username' };

	if (username == 'root')
		return { ok: false, error: 'root cannot be used: it would lose access to LuCI' };

	if (length(password ?? '') < 8)
		return { ok: false, error: 'the password needs at least 8 characters' };

	let c = uci.cursor();
	let f = find(c, username);

	if (!f.found && f.other)
		return { ok: false, error: 'the login "' + username + '" already exists for something else' };

	let p = fs.popen('uhttpd -m ' + shq(password) + ' 2>/dev/null', 'r');
	let hash = trim(p?.read('all') ?? '');

	p?.close();

	if (!match(hash, /^\$[0-9a-z]+\$/))
		return { ok: false, error: 'could not hash the password (is uhttpd installed?)' };

	// one login for chanmgr: reuse the previous one even if renamed
	let sid = f.found?.['.name'] ?? find(c).found?.['.name'] ?? c.add('rpcd', 'login');

	c.set('rpcd', sid, 'username', username);
	c.set('rpcd', sid, 'password', hash);
	c.set('rpcd', sid, 'read', [ ACL ]);
	c.set('rpcd', sid, 'write', [ ACL ]);
	c.set('rpcd', sid, 'chanmgr', '1');
	c.commit('rpcd');

	return { ok: true, username };
}

return { get, set };
