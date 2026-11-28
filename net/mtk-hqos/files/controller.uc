#!/usr/bin/ucode
'use strict';

import * as fs from 'fs';
import { cursor } from 'uci';
import { plan, batch, rates, profiles, transaction, policyState, policyPlan } from 'mtk_hqos.core';

const dir = '/var/run/mtk-hqos';
const extended = fs.lstat('/sys/kernel/debug/ppe0/hqos_queue') != null;
const hardware = '/sys/kernel/debug/ppe0/' + (extended ? 'hqos_queue' : 'hqos_rate');

function execute(command) {
	const pipe = fs.popen(command + ' 2>&1', 'r');
	if (!pipe) return { code: 127, output: 'Cannot start command' };
	const output = pipe.read('all') || '';
	return { code: pipe.close(), output };
};

function save(name, value) {
	const tmp = dir + '/.new';
	if (fs.writefile(tmp, sprintf('%J', value)) == null || !fs.rename(tmp, dir + '/' + name))
		die('Cannot save HQoS state');
};

function load(name) {
	try { return json(fs.readfile(dir + '/' + name) || '{}'); }
	catch (e) { die('Cannot parse previous HQoS state'); }
};

function setRate(q, rate) {
	const value = type(rate) == 'object' ? rate : { rate, minimum: 0, weight: 0 };
	if (!extended && value.weight) die('Queue weights require the updated firmware');
	const text = extended ? sprintf('%d %d %d %d\n', +q, value.rate, value.minimum, value.weight) : sprintf('%d %d\n', +q, value.rate);
	const fd = fs.open(hardware, 'w');
	if (!fd) die('Cannot open HQoS driver');
	const written = fd.write(text);
	const closed = fd.close();
	if (written != length(text) || !closed)
		die('Driver rejected queue ' + q);
};

function setPolicy(values) {
	const text = join(' ', values) + '\n';
	const fd = fs.open('/sys/kernel/debug/ppe0/hqos_policy', 'w');
	if (!fd) die('Cannot open HQoS policy');
	const written = fd.write(text), closed = fd.close();
	if (written != length(text) || !closed) die('Driver rejected HQoS policy');
};

let previous = {}, committed = false, rollback = true;
try {
	if (!fs.lstat(dir)) fs.mkdir(dir, 0o700);
	if (fs.lstat(dir)?.type != 'directory' || !fs.chmod(dir, 0o700))
		die('Unsafe HQoS state directory');
	if (ARGV[0] != 'apply' && ARGV[0] != 'stop') die('Expected apply or stop');
	const uci = cursor(), sections = [];
	if (!uci.load('mtk_hqos') && ARGV[0] != 'stop') die('Cannot load HQoS configuration');
	uci.foreach('mtk_hqos', null, (s) => push(sections, s));
	const p = ARGV[0] == 'stop' ? { enabled: false, queues: {}, rules: [] } : plan(sections);
	const raw = fs.readfile(hardware);
	previous = extended ? profiles(raw) : rates(raw);
	if (p.enabled && length(keys(previous)) != 16)
		die('MT7986 HQoS driver is unavailable; configuration was not applied');
	const policy = policyState(fs.readfile('/sys/kernel/debug/ppe0/hqos_policy'));
	const wantedPolicy = policyPlan(ARGV[0] == 'stop' ? [] : sections, policy);
	const old = load('state.json');
	const writePolicy = wantedPolicy.requested || old.policy;
	if (writePolicy && !policy.values) die('Cannot restore HQoS policy: driver unavailable');
	const oldQueues = old.queues || {};
	const wanted = {};
	for (let q in oldQueues) wanted[q] = 0;
	for (let q in p.queues) wanted[q] = p.queues[q];
	if (length(keys(wanted)) && length(keys(previous)) != 16)
		die('Cannot restore queues: HQoS driver is unavailable');
	for (let q in wanted)
		if (!match(q, /^(0|[1-9]|1[0-5])$/)) die('Invalid saved queue');
	const existing = execute('nft list table inet mtk_hqos').code == 0;
	const text = batch(p, existing);
	if (fs.writefile(dir + '/batch.nft', text) == null) die('Cannot write nft batch');
	if (p.enabled || existing) {
		const check = execute('nft -c -f /var/run/mtk-hqos/batch.nft');
		if (check.code) die('nft validation failed: ' + check.output);
	}
	let applied;
	try {
		if (writePolicy) setPolicy(wantedPolicy.values);
		applied = transaction(wanted, previous, setRate, () => {
			if (p.enabled || existing) {
				const result = execute('nft -f /var/run/mtk-hqos/batch.nft');
				if (result.code) die('nft apply failed: ' + result.output);
			}
		});
	} catch (e) {
		if (writePolicy) try { setPolicy(policy.values); } catch (ignored) { rollback = false; }
		die('' + e);
	}
	if (!applied.success && writePolicy)
		try { setPolicy(policy.values); } catch (ignored) { applied.rollback = false; }
	rollback = applied.rollback;
	if (!applied.success) die(applied.message);
	committed = true;
	save('state.json', { enabled: p.enabled, queues: p.queues, policy: wantedPolicy.requested, rule_count: length(p.rules), updated: time() });
	save('status.json', { success: true, enabled: p.enabled, updated: time() });
} catch (e) {
	const message = '' + e;
	try { save('status.json', { success: false, message, rollback, committed, updated: time() }); } catch (ignored) {}
	warn('MediaTek HQoS: ' + message + '\n');
	exit(1);
}
