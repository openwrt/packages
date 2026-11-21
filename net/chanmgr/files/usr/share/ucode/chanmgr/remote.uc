// SPDX-License-Identifier: GPL-2.0-only
// Minimal ubus-over-HTTP (JSON-RPC) client for remote agents.

'use strict';

let fs = require('fs');

const NULL_SID = '00000000000000000000000000000000';

let seq = 0;

function shq(s) {
	return "'" + replace('' + s, "'", "'\\''") + "'";
}

const UBUS_STATUS = {
	'3': 'method not found (update chanmgr on the node)',
	'4': 'chanmgr is not installed on the node, or rpcd was not restarted',
	'6': 'permission denied (check the rpcd login and its chanmgr-agent ACL)',
	'7': 'timeout'
};

function post(url, body, opts) {
	// the login request carries the password: keep it in a private directory
	fs.mkdir('/tmp/chanmgr', 0700);

	let tmp = sprintf('/tmp/chanmgr/rpc.%s.%d', fs.readlink('/proc/self') ?? '0', ++seq);

	fs.writefile(tmp, sprintf('%J', body));

	let cmd = sprintf('uclient-fetch -q -T %d -O - --post-file=%s %s%s 2>%s.err',
		opts.timeout ?? 30, shq(tmp), opts.insecure ? '--no-check-certificate ' : '', shq(url), shq(tmp));

	let p = fs.popen(cmd, 'r');
	let out = p ? p.read('all') : null;

	p?.close();

	let err = trim(fs.readfile(tmp + '.err') ?? '');

	fs.unlink(tmp);
	fs.unlink(tmp + '.err');

	return { out, err };
}

// First line of a response or error, for error messages.
function snippet(s) {
	s = trim(replace(s ?? '', /[\r\n\t ]+/g, ' '));

	return (length(s) > 120) ? substr(s, 0, 120) + '...' : s;
}

// node: { host, port, https, insecure, username, password, timeout }
function client(node) {
	let proto = node.https ? 'https' : 'http';
	let url = sprintf('%s://%s%s/ubus', proto, node.host, node.port ? ':' + node.port : '');
	let sid = null, id = 0;

	let rpc = (s, obj, method, args, timeout) => {
		let r = post(url, {
			jsonrpc: '2.0', id: ++id, method: 'call',
			params: [ s, obj, method, args ?? {} ]
		}, { timeout: timeout ?? node.timeout, insecure: node.insecure });

		if (!r.out)
			return { error: sprintf('no response from %s%s', url, r.err ? ': ' + snippet(r.err) : '') };

		let res;

		try {
			res = json(r.out);
		}
		catch (e) {
			return { error: sprintf('%s did not answer JSON (is it the ubus endpoint?): %s', url, snippet(r.out)) };
		}

		if (res.error)
			return { error: res.error.message ?? 'rpc error' };

		let st = res.result?.[0];

		if (st != 0)
			return { error: sprintf('ubus status %d (%s.%s): %s', st, obj, method, UBUS_STATUS['' + st] ?? 'error'), status: st };

		return { data: res.result[1] ?? {} };
	};

	let login = () => {
		let r = rpc(NULL_SID, 'session', 'login', {
			username: node.username ?? 'chanmgr',
			password: node.password ?? '',
			timeout: 900
		}, 15);

		if (r.status == 6)
			return 'login failed: wrong username or password';

		if (r.error)
			return r.error;

		sid = r.data.ubus_rpc_session;

		return sid ? null : 'login failed';
	};

	return {
		call: (obj, method, args, timeout) => {
			if (!sid) {
				let err = login();

				if (err)
					return { error: err };
			}

			let r = rpc(sid, obj, method, args, timeout);

			// session expired: log in again once
			if (r.status == 6) {
				sid = null;

				let err = login();

				return err ? { error: err } : rpc(sid, obj, method, args, timeout);
			}

			return r;
		}
	};
}

return { client };
