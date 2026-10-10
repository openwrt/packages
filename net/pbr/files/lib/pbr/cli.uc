'use strict';
// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright 2017-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// CLI dispatcher for pbr.
// Called from init script:
//   ucode -S -L /lib/pbr /lib/pbr/cli.uc -- <action> [args...]

import create_pbr from 'pbr';
let pbr = create_pbr();

let action = shift(ARGV);
if (action == '--') action = shift(ARGV);

switch (action) {
case 'start_service':
	let start_result = pbr.start_service(ARGV);
	if (start_result)
		print(pbr.emit_procd_shell(start_result));
	break;

case 'stop_service':
	pbr.stop_service();
	break;

case 'status_service':
	pbr.status_service(ARGV);
	break;

case 'netifd':
	if (!pbr.netifd(ARGV[0], ARGV[1]))
		exit(1);
	break;

case 'support':
	pbr.support();
	break;

case 'version':
	print(pbr.pkg.version + '\n');
	break;

case 'service_started':
	pbr.service_started(ARGV[0], ARGV[1]);
	break;

case 'should_skip_reload':
	exit(pbr.should_skip_reload(ARGV[0]) ? 0 : 1);
	break;

case 'stop_forward':
	pbr.forwarding.disable();
	break;

case 'enable_forward':
	pbr.forwarding.enable();
	break;

default:
	warn('Unknown action: ' + (action || '(none)') + '\n');
	exit(1);
}
