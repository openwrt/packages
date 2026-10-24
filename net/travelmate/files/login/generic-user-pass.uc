#!/usr/bin/ucode
// captive portal auto-login script template with credentials as parameters
// Copyright (c) 2020-2026 Dirk Brenken (dev@brenken.org)
// This is free software, licensed under the GNU General Public License v3.

import { fetch, lookup } from 'travelmate.login';

let user = ARGV[0] ?? '', password = ARGV[1] ?? '';
let domain = 'example.com';

if (!lookup(domain))
	exit(1);

// login with credentials
let r = fetch('http://' + domain, { args: [ '--header', 'Content-Type:application/x-www-form-urlencoded',
	'--data', 'username=' + user + '&password=' + password, '--output', '/dev/null' ] });

exit(r.rc == 0 ? 0 : 255);
