#!/usr/bin/ucode
// captive portal auto-login script for bahn/ICE hotspots (DE)
// Copyright (c) 2020-2026 Dirk Brenken (dev@brenken.org)
// This is free software, licensed under the GNU General Public License v3.

import { readfile, unlink } from 'fs';
import { fetch, lookup } from 'travelmate.login';

let domain = 'wifi.bahn.de';

if (!lookup(domain)) {
	domain = 'login.wifionice.de';

	if (!lookup(domain))
		exit(1);
}

// current cna portal api
let r = fetch('https://' + domain + '/cna/logon', { args: [ '--header', 'Content-Type: application/json',
	'--header', 'X-Requested-With: XMLHttpRequest', '--header', 'X-Csrf-Token: csrf',
	'--header', 'Referer: https://' + domain + '/cna/', '--data', '{}' ] });

if (index(r.body, 'success') >= 0)
	exit(0);

// legacy portal api, get security token from the cookie jar
let jar = '/var/run/travelmate/' + domain + '.cookie', token = '';

if (fetch('https://' + domain + '/en/', { args: [ '--cookie-jar', jar, '--output', '/dev/null' ] }).rc == 0) {
	for (let l in split(readfile(jar) ?? '', '\n'))
		if (index(l, 'csrf') >= 0)
			token += (split(trim(l, ' \t'), /[ \t]+/)[6] ?? '') + '\n';

	token = rtrim(token, '\n');
}

unlink(jar);

if (!length(token))
	exit(2);

// legacy portal api, final post request
r = fetch('https://' + domain + '/en/', { args: [ '--header', 'Cookie: csrf=' + token,
	'--data', 'login=true&CSRFToken=' + token, '--output', '/dev/null' ] });

exit(r.rc == 0 ? 0 : 255);
