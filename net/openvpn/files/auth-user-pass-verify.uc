#!/usr/bin/env ucode

// cmd method { via-env|via-file } 

print('cmd ', ARGV, '\n');

// See the environment variables passed to this script: https://ucode.mein.io/module-core.html#getenv
print(getenv(), '\n');

// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#environmental-variables-177179
// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#script-hooks-177179


/* do something */


/*
exit(0); // client auth request accepted
exit(1); // reject client
exit(2); // deferred auth
*/
