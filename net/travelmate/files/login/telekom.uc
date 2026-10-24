#!/usr/bin/ucode
// captive portal auto-login script for telekom hotspots (DE)
// Copyright (c) 2021-2026 Dirk Brenken (dev@brenken.org)
// This is free software, licensed under the GNU General Public License v3.

import { fetch, lookup, urlencode, between, https_on, captiveurl } from 'travelmate.login';

let username = urlencode(ARGV[0] ?? ''), password = urlencode(ARGV[1] ?? '');
let domain = 'hotspot.t-mobile.net';

if (!lookup(domain))
	exit(1);

// get redirect url
let redirect_url = replace(between(fetch(captiveurl).body, '<loginurl>', '</loginurl>'), /&amp;/g, '&');

// the credentials go to the hotspot host via https only
if (!https_on(redirect_url, domain))
	exit(1);

// final login request
let r = fetch(redirect_url, { args: [ '--referer', 'https://' + domain + '/wlan/rest/freeLogin',
	'--header', 'content-type: application/x-www-form-urlencoded',
	'--data', 'UserName=' + username + '&Password=' + password + '&FNAME=0&button=Login&OriginatingServer=' + urlencode(captiveurl) ] });

exit(length(between(r.body, '<logoffurl>', '</logoffurl>')) ? 0 : 255);
