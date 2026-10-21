#!/usr/bin/ucode
// captive portal auto-login script for vodafone hotspots (DE)
// Copyright (c) 2021-2026 Dirk Brenken (dev@brenken.org)
// This is free software, licensed under the GNU General Public License v3.

import { fetch, lookup, captiveurl } from 'travelmate.login';

let username = ARGV[0] ?? '', password = ARGV[1] ?? '';
let domain = 'hotspot.vodafone.de';

if (!lookup(domain))
	exit(1);

// get sid, from the redirect the portal answers with
let redirect_url = fetch(captiveurl, { follow: false, write_out: '%{redirect_url}', args: [ '--output', '/dev/null' ] }).body;
let sid = split(redirect_url, /[=&]/)[1] ?? '';

if (!length(sid))
	exit(1);

// get session
let raw = fetch('https://' + domain + '/api/v4/session?sid=' + sid,
	{ args: [ '--referer', 'http://' + domain + '/portal/?sid=' + sid ] }).body;
let res = null;

try { res = json(raw); } catch (e) { }

let session = res?.session;

if (session == null || !length('' + session))
	exit(2);

// login profile 4: csc community account
let ids = map(res?.loginProfiles ?? [], (p) => '' + p?.id);

if (index(ids, '4') < 0)
	exit(3);

// final login request
if (length(username) && length(password))
	raw = fetch('https://' + domain + '/api/v4/login?sid=' + sid, { args: [ '--referer', 'http://' + domain + '/portal/?sid=' + sid,
		'--data', 'loginProfile=4&accessType=csc-community&accountType=csc&password=' + password +
		'&session=' + session + '&username=' + username ] }).body;

res = null;

try { res = json(raw); } catch (e) { }

exit(('' + res?.success) == 'true' ? 0 : 255);
