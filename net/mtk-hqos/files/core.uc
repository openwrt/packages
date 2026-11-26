'use strict';

function number(value, low, high, label) {
	if (!match('' + value, /^[0-9]+$/) || +value < low || +value > high)
		die(label + ': invalid number');
	return +value;
};

function device(value) {
	if (!match(value || '', /^[a-zA-Z0-9_.:-]{1,15}$/))
		die('Invalid output device');
	return value;
};

function address(value) {
	if (!value)
		return null;
	if (match(value, /^[0-9.]+(\/[0-9]{1,2})?$/))
		return 'ip saddr ' + value;
	if (match(value, /^[0-9a-fA-F:]+(\/[0-9]{1,3})?$/) && index(value, ':') >= 0)
		return 'ip6 saddr ' + value;
	die('Invalid source address');
};

function dscp(value) {
	if (value == null || value == '') return null;
	const name = uc('' + value);
	if (name == 'EF') return 46;
	if (name == 'LE') return 1;
	let m = match(name, /^CS([0-7])$/);
	if (m) return +m[1] * 8;
	m = match(name, /^AF([1-4])([1-3])$/);
	if (m) return +m[1] * 8 + +m[2] * 2;
	return number(value, 0, 63, 'DSCP');
};

export function plan(sections) {
	let enabled = false, queues = {}, rules = [];
	for (let s in sections)
		if (s['.type'] == 'global' && s['.name'] == 'main')
			enabled = s.enabled == '1';
	if (!enabled)
		return { enabled: false, queues: {}, rules: [] };
	for (let s in sections) {
		if (s['.type'] == 'queue') {
			const q = number(s.queue, 0, 15, 'Queue');
			if (exists(queues, '' + q))
				die('Duplicate queue ' + q);
			const rate = number(s.rate, 0, 2500000, 'Rate');
			if (rate && rate < 10000)
				die('Rate must be zero or at least 10000 kbit/s');
			queues['' + q] = rate;
			if (s.weight != null && s.weight != '' && s.weight != '0') {
				const weight = number(s.weight, 1, 16, 'Weight');
				const minimum = number(s.minimum || '0', 0, 2500000, 'Minimum');
				if (minimum && minimum < 10000) die('Minimum must be zero or at least 10000 kbit/s');
				if (rate && minimum > rate) die('Minimum exceeds maximum');
				queues['' + q] = { rate, minimum, weight };
			} else if (s.minimum && s.minimum != '0') {
				die('Explicit minimum requires a weight');
			}
		}
		if (s['.type'] != 'rule' || s.enabled == '0')
			continue;
		if (length(rules) >= 128)
			die('At most 128 classification rules are supported');
		const q = number(s.queue, 0, 15, 'Rule queue');
		const hook = s.hook || 'forward';
		if (hook != 'forward' && hook != 'output')
			die('Invalid rule hook');
		const proto = s.proto || 'all';
		if (proto != 'all' && proto != 'tcp' && proto != 'udp')
			die('Invalid protocol');
		let expr = 'oifname "' + device(s.device) + '"';
		const addr = address(s.source);
		if (addr)
			expr += ' ' + addr;
		if (proto != 'all')
			expr += ' meta l4proto ' + proto;
		if (s.port) {
			if (proto == 'all')
				die('Destination port requires TCP or UDP');
			expr += ' ' + proto + ' dport ' + number(s.port, 1, 65535, 'Port');
		}
		push(rules, { hook, expr, queue: q, dscp: dscp(s.dscp),
			family: addr ? (index(addr, 'ip6 ') == 0 ? 'ip6' : 'ip') : null });
	}
	return { enabled, queues, rules };
};

export function batch(p, existing) {
	let lines = existing ? ['delete table inet mtk_hqos'] : [];
	if (!p.enabled)
		return join('\n', lines) + '\n';
	push(lines, 'table inet mtk_hqos {');
	for (let hook in ['forward', 'output']) {
		push(lines, '\tchain ' + hook + ' {');
		push(lines, '\t\ttype filter hook ' + hook + ' priority -5; policy accept;');
		for (let rule in p.rules) {
			if (rule.hook != hook) continue;
			const action = sprintf(' counter meta priority set 0x%08x return', 0x4d540000 + rule.queue);
			if (rule.dscp == null) {
				push(lines, '\t\t' + rule.expr + action);
				continue;
			}
			/* Separate families avoid conflicting IPv4/IPv6 payload matches.
			 * DSCP excludes ECN; never rewrite either field or PBR marks. */
			for (let family in rule.family ? [rule.family] : ['ip', 'ip6'])
				push(lines, '\t\t' + rule.expr + ' ' + family + ' dscp ' + rule.dscp + action);
		}
		push(lines, '\t}');
	}
	push(lines, '}');
	return join('\n', lines) + '\n';
};

export function rates(text) {
	let result = {};
	for (let line in split(text || '', '\n')) {
		const fields = match(line, /^([0-9]+) ([0-9]+) (0x[0-9a-fA-F]+) (0x[0-9a-fA-F]+)$/);
		if (fields && +fields[1] < 16)
			result[fields[1]] = { rate: +fields[2], baseline: fields[3], effective: fields[4] };
	}
	return result;
};

// Validate nftables before calling this. commit() must apply one atomic batch.
export function transaction(wanted, previous, writeRate, commit) {
	let changed = [];
	try {
		for (let q in wanted) {
			push(changed, q);
			writeRate(q, wanted[q]);
		}
		commit();
		return { success: true, rollback: true };
	} catch (e) {
		let rollback = true;
		for (let q in reverse(changed))
			try { writeRate(q, previous[q].config ?? previous[q].rate); } catch (ignored) { rollback = false; }
		return { success: false, message: '' + e, rollback };
	}
};

// Extended driver ABI. The config object preserves all fields on rollback.
export function profiles(text) {
	let result = {};
	for (let line in split(text || '', '\n')) {
		const f = match(line, /^([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) (0x[0-9a-fA-F]+) (0x[0-9a-fA-F]+)$/);
		if (f && +f[1] < 16 && +f[4] <= 16)
			result[f[1]] = { rate: +f[2], minimum: +f[3], weight: +f[4], baseline: f[5],
				actual: f[6], effective: f[6], config: { rate: +f[2], minimum: +f[3], weight: +f[4] } };
	}
	return result;
};

// A complete policy is committed in one driver write. -1 inherits v0.2 behavior.
export function policyState(text) {
	let values = null, ports = {}, schedulers = {};
	for (let line in split(text || '', '\n')) {
		if (substr(line, 0, 7) == 'policy ') {
			const fields = split(substr(line, 7), ' ');
			if (length(fields) != 64) die('Invalid policy readback');
			values = [];
			for (let i = 0; i < 64; i++) {
				if (!match(fields[i], /^(-1|[0-9]+)$/)) die('Invalid policy value');
				const v = +fields[i];
				if (v < -1 || v > (i < 16 ? 1 : 15)) die('Invalid policy range');
				push(values, v);
			}
		}
		let f = match(line, /^port ([0-2]) ([a-zA-Z0-9_.:-]{1,15})$/);
		if (f) ports[f[2]] = +f[1];
		f = match(line, /^scheduler ([01]) (0x[0-9a-fA-F]+)$/);
		if (f) schedulers[f[1]] = f[2];
	}
	return { values, ports, schedulers };
};

export function policyPlan(sections, state) {
	let values = [], changed = {}, enabled = false, requested = false;
	for (let i = 0; i < 64; i++) push(values, -1);
	for (let s in sections)
		if (s['.type'] == 'global' && s['.name'] == 'main') enabled = s.enabled == '1';
	if (!enabled) return { values, requested: false };
	for (let s in sections) {
		if (s['.type'] == 'queue' && s.scheduler != null && s.scheduler != '' && s.scheduler != '-1') {
			const q = number(s.queue, 0, 15, 'Queue');
			values[q] = number(s.scheduler, 0, 1, 'Scheduler');
			requested = true;
		}
		if (s['.type'] != 'mapping' || s.enabled == '0') continue;
		const cls = number(s.class, 0, 15, 'Class');
		const q = number(s.queue, 0, 15, 'Mapped queue');
		const port = state.ports[s.device];
		if (port == null) die('Mapping requires a physical Ethernet output reported by the driver: ' + s.device);
		const index = 16 + 16 * port + cls;
		if (changed[index]) die('Duplicate class/output mapping');
		changed[index] = true;
		values[index] = q;
		requested = true;
	}
	if (requested && !state.values) die('Output mapping requires the updated firmware');
	return { values, requested };
};
