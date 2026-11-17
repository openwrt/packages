#!/usr/bin/env ucode

import { readfile } from 'fs';

// cmd client_response_temp_file

print('cmd ', ARGV, '\n');

// See the environment variables passed to this script: https://ucode.mein.io/module-core.html#getenv
print(getenv(), '\n');

// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#script-hooks-177179
// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#environmental-variables-177179

const content = trim(readfile(ARGV[0]));

const reply = b64dec(content);



/* do something */


// write result to the `auth_control_file` filename stored in the environment.

