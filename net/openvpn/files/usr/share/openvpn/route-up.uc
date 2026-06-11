#!/usr/bin/env ucode

// See the environment variables passed to this script: https://ucode.mein.io/module-core.html#getenv
print(getenv(), '\n');

// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#environmental-variables-177179
// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#script-hooks-177179

/* e.g.
{
	"script_type": "route-up",
	"dev": "asdf0",
	"tun_mtu": "1500",
	"script_context": "init",
	"signal": "sigint",
	"redirect_gateway": "0",
	"dev_type": "tun",
	"verb": "6",
	"daemon": "0",
	"daemon_log_redirect": "0",
	"daemon_start_time": "1770390291",
	"daemon_pid": "7435",
	"proto_1": "udp",
	"local_port_1": "1194",
	"remote_1": "192.0.2.10",
	"remote_port_1": "1194"
}
*/
