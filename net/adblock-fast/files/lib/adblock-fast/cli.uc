'use strict';
// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright 2023-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// CLI dispatcher for adblock-fast.
// Called from init script:
//   ucode -S -L /lib/adblock-fast /lib/adblock-fast/cli.uc -- <action> [args...]

import adb from 'adblock-fast';

let action = shift(ARGV);
if (action == '--') action = shift(ARGV);

switch (action) {
case 'start':
	let start_result = adb.start(ARGV);
	if (start_result)
		print(adb.emit_procd_shell(start_result));
	break;

case 'stop':
	let stop_result = adb.stop();
	if (stop_result)
		print(adb.emit_procd_shell(stop_result));
	break;

case 'status':
	adb.status_service(ARGV[0]);
	break;

case 'allow':
	adb.allow(join(' ', ARGV));
	break;

case 'check':
	adb.check(join(' ', ARGV));
	break;

case 'check_tld':
	adb.check_tld();
	break;

case 'check_leading_dot':
	adb.check_leading_dot();
	break;

case 'check_lists':
	adb.check_lists(join(' ', ARGV));
	break;

case 'dl':
	let dl_result = adb.dl();
	if (dl_result)
		print(adb.emit_procd_shell(dl_result));
	break;

case 'killcache':
	adb.killcache();
	break;

case 'pause':
	adb.pause(ARGV[0]);
	break;

case 'show_blocklist':
	adb.show_blocklist();
	break;

case 'sizes':
	adb.sizes();
	break;

case 'version':
	print(adb.pkg.version + '\n');
	break;

case 'get_wan_interfaces':
	let info = adb.get_network_trigger_info();
	if (info)
		print(sprintf('%J', info) + '\n');
	break;

case 'adb_config_update':
	adb.adb_config_update(ARGV[0]);
	break;

case 'load_environment':
	let env_ok = adb.env.load(ARGV[0], ARGV[1]);
	exit(env_ok ? 0 : 1);
	break;

default:
	warn('Unknown action: ' + (action || '(none)') + '\n');
	exit(1);
}
