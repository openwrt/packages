#!/usr/bin/env ucode

// 0 == link_mtu => historic
// cmd tun_dev tun_mtu 0 ifconfig_local_ip ifconfig_remote_ip [init | restart]
// cmd tap_dev tap_mtu 0 ifconfig_local_ip ifconfig_netmask [init | restart]

print('tun_dev ', ARGV[0],' tun_mtu ', ARGV[1], ' ', ARGV[2], ' if_lip "', ARGV[3], '" if_rip "', ARGV[4], '" i/r "', ARGV[5], '"\n');
print('tap_dev ', ARGV[0],' tap_mtu ', ARGV[1], ' ', ARGV[2], ' if_lip "', ARGV[3], '" if_nm "', ARGV[4], '" i/r "', ARGV[5], '"\n');

/* e.g.
tun_dev asdf0 tun_mtu 1500 0 if_lip "" if_rip "" i/r "init"
*/

// See the environment variables passed to this script: https://ucode.mein.io/module-core.html#getenv
print(getenv(), '\n');

// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#environmental-variables-177179
// https://openvpn.net/community-docs/community-articles/openvpn-2-6-manual.html#script-hooks-177179

/* e.g. 
{
	"script_type": "up",
	"dev_type": "tun",
	"dev": "asdf0",
	"tun_mtu": "1500",
	"script_context": "init",
	"verb": "6",
	"daemon": "0",
	"daemon_log_redirect": "0",
	"daemon_start_time": "1770389649",
	"daemon_pid": "6116",
	"proto_1": "udp",
	"local_port_1": "1194",
	"remote_1": "192.0.2.10",
	"remote_port_1": "1194"
}
*/
