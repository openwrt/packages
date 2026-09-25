// shunt - route and rule application
//
// Sends the operations route.uc renders to the kernel over rtnetlink,
// through ucode-mod-rtnl, where an `ip` process per command used to be.
//
// rtnl.request() answers null on success, false when the kernel refused
// and null again when an attribute did not encode - an `oif` naming a
// device that is not there yet, the boot-time case. So the return value
// is not the verdict; rtnl.error() is, and it is null after a success.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken <dev@brenken.org>

// require() inside so the module stays importable without rtnl, and the
// caller decides what a missing module means for it.
export function open() {
	let rtnl;

	try {
		rtnl = require('rtnl');
	}
	catch (e) {
		return null;
	}

	return rtnl;
};

function call(rtnl, cmd, flags, msg) {
	rtnl.request(cmd, flags, msg);

	return rtnl.error();
}

// The kernel does not filter a route dump by table on its own - the whole
// forwarding base comes back - so the table is picked out here. A default
// route carries no dst attribute in the dump but needs one to be deleted,
// and the rest of the entry is echoed so the match is unambiguous.
function flush(rtnl, C, msg) {
	let routes = rtnl.request(C.RTM_GETROUTE, C.NLM_F_DUMP,
		{ family: msg.family, table: msg.table });

	if (type(routes) != 'array')
		return rtnl.error();

	let err = null;

	for (let r in routes) {
		if (r?.table != msg.table)
			continue;

		let del = { family: r.family, table: r.table,
			dst: r.dst ?? (r.family == C.AF_INET6 ? '::/0' : '0.0.0.0/0'),
			type: r.type, scope: r.scope, protocol: r.protocol };

		for (let k in [ 'oif', 'gateway', 'priority' ])
			if (r[k] != null)
				del[k] = r[k];

		err = call(rtnl, C.RTM_DELROUTE, 0, del) ?? err;
	}

	return err;
}

// One rendered operation. Returns null when the kernel took it, otherwise
// the reason as text - with no exit code left to interpret.
export function exec(rtnl, op) {
	let C = rtnl.const;

	switch (op?.cmd) {
	case 'newroute':
		return call(rtnl, C.RTM_NEWROUTE, C.NLM_F_CREATE | C.NLM_F_REPLACE, op.msg);
	case 'newrule':
		return call(rtnl, C.RTM_NEWRULE, C.NLM_F_CREATE | C.NLM_F_EXCL, op.msg);
	case 'delrule':
		return call(rtnl, C.RTM_DELRULE, 0, op.msg);
	case 'flush':
		return flush(rtnl, C, op.msg);
	default:
		return sprintf('unknown operation %J', op?.cmd);
	}
};

// For the log: the operation in the shape a reader knows from `ip`.
export function describe(op) {
	let m = op?.msg ?? {};
	let v = (m.family == 10) ? '-6' : '-4';

	switch (op?.cmd) {
	case 'newroute':
		return sprintf('ip %s route replace %sdefault%s%s%s table %d', v,
			m.type == 6 ? 'blackhole ' : '',
			m.gateway ? ` via ${m.gateway}` : '',
			m.oif ? ` dev ${m.oif}` : '',
			m.priority != null ? ` metric ${m.priority}` : '', m.table);
	case 'newrule':
		return sprintf('ip %s rule add pref %d fwmark 0x%x/0x%x lookup %s%s', v,
			m.priority, m.fwmark, m.fwmask,
			m.table == 254 ? 'main' : sprintf('%d', m.table),
			m.suppress_prefixlen != null
				? sprintf(' suppress_prefixlength %d', m.suppress_prefixlen) : '');
	case 'delrule':
		return sprintf('ip %s rule del pref %d', v, m.priority);
	case 'flush':
		return sprintf('ip %s route flush table %d', v, m.table);
	default:
		return sprintf('%J', op);
	}
};
