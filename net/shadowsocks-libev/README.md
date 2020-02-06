Skip to [recipes](#recipes) for quick setup instructions

# components

`ss-local` provides SOCKS5 proxy with UDP associate support.

	 socks5                                     ss              plain
	--------> tcp:local_address:local_port ----> ss server -------> dest

`ss-redir`.  The REDIRECT and TPROXY part are to be provided by `ss-rules` script.  REDIRECT is for tcp traffic (`SO_ORIGINAL_DST` only supports TCP).  TPROXY is for udp messages, but it's only available in the PREROUTING chain and as such cannot proxy local out traffic.

	  plain             plain                                 ss              plain
	---------> REDIRECT ------> tcp:local_address:local_port ----> ss server -----> original dest

	  plain            plain                                 ss              plain
	---------> TPROXY -------> udp:local_address:local_port -----> ss server -----> original dest

`ss-tunnel` provides ssh `-L` local-forwarding-like tunnel.  Typically it's used to tunnel DNS traffic to the remote.

	  plain                                       ss               plain
	---------> tcp|udp:local_address:local_port ------> ss server -------> tunnel_address

`ss-server`, the "ss server" in the above diagram

# uci

Option names are the same as those used in json config files.  Check `validate_xxx` func definition of the [service script](files/shadowsocks-libev.init) and shadowsocks-libev's own documentation for supported options and expected value types.  A [sample config file](files/shadowsocks-libev.config) is also provided for reference.

Every section have a `disabled` option to temporarily turn off the component instance or component instances referring to it.

Section type `server` is for definition of remote shadowsocks servers.  They will be referred to from other component sections and as such should be named (as compared to anonymous section).

Section type `ss_local`, `ss_redir`, `ss_tunnel` are for specification of shadowsocks-libev components.  They share mostly a common set of options like `local_port`, `verbose`, `fast_open`, `timeout`, etc.

Plugin options should be specified in `server` section and will be inherited by other compoenents referring to it.

We can have multiple instances of component and `server` sections.  The relationship between them is many-to-one.  This will have the following implications

 - It's possible to have both `ss_local` and `ss_redir` referring to the same `server` definition
 - It's possible to have multiple instances of `ss_redir` listening on the same address:port with `reuse_port` enabled referring to the same or different `server` sections

`ss_rules` section is for configuring the behaviour of `ss-rules` script.  There can only exist at most one such section with the name also being `ss_rules`

	redir_tcp		name of ss_redir section with mode tcp_only or tcp_and_udp
	redir_udp		name of ss_redir section with mode udp_only or tcp_and_udp
	ifnames			only apply rules on packets from these ifnames

	--- for incoming packets having source address in

	src_ips_bypass		will bypass the redir chain
	src_ips_forward		will always go through the redir chain
	src_ips_checkdst	will continue to have their destination addresses checked

	--- otherwise, the default action can be specified with

	src_default		bypass, forward, [checkdst]

	--- if the previous check result is checkdst,
	--- then packets having destination address in

	dst_ips_bypass_file
	dst_ips_bypass		will bypass the redir chain
	dst_ips_forward_file
	dst_ips_forward		will go through the redir chain

	--- otherwise, the default action can be specified with

	dst_default		[bypass], forward

	--- for local out tcp packets, the default action can be specified with

	local_default		[bypass], forward, checkdst

Bool option `dst_forward_recentrst` requires iptables/netfilter `recent` match module (`opkg install iptables-mod-conntrack-extra`).  When enabled, `ss-rules` will setup iptables rules to forward through `ss-redir` those packets whose destination have recently sent to us multiple tcp-rst.

ss-rules uses kernel ipset mechanism for storing addresses/networks.  Those ipsets are also part of the API and can be populated by other programs, e.g. dnsmasq with builtin ipset support.  For more details please read output of `ss-rules --help`

Note also that `src_ips_xx` and `dst_ips_xx` actually also accepts cidr network representation.  Option names are retained in its current form for backward compatibility coniderations

# incompatible changes

| Commit date | Commit ID | Subject | Comment |
| ----------- | --------- | ------- | ------- |
| 2019-05-09  | afe7d3424 | shadowsocks-libev: move plugin options to server section | This is a revision against c19e949 committed 2019-05-06 |
| 2017-07-02  | b61af9703 | shadowsocks-libev: rewrite | Packaging of shadowsocks-libev was rewritten from scratch |

# notes and faq

Useful paths and commands for debugging

	# check current running status
	ubus call service list '{"name": "shadowsocks-libev"}'
	ubus call service list '{"name": "shadowsocks-libev", "verbose": true}'

	# dump validate definition
	ubus call service validate '{"package": "shadowsocks-libev"}'
	ubus call service validate '{"package": "shadowsocks-libev"}' \
		| jsonfilter -e '$["shadowsocks-libev"]["ss_tunnel"]'

	# check json config
	ls -l /var/etc/shadowsocks-libev/

	# set uci config option verbose to 1, restart the service and follow the log
	logread -f

ss-redir needs to open a new socket and setsockopt IP_TRANSPARENT when sending udp reply to client.  This requires `CAP_NET_ADMIN` and as such the process cannot run as `nobody`

ss-local, ss-redir, etc. supports specifying an array of remote ss server, but supporting this in uci seems to be overkill.  The workaround can be defining multiple `server` sections and multiple `ss-redir` instances with `reuse_port` enabled

# recipes

## forward all

This will setup firewall rules to forward almost all incoming tcp/udp and locally generated tcp traffic (excluding those to private addresses like 192.168.0.0/16 etc.) through remote shadowsocks server

Install components.
Retry each command till it succeed

	opkg install shadowsocks-libev-ss-redir
	opkg install shadowsocks-libev-ss-rules
	opkg install shadowsocks-libev-ss-tunnel

Edit uci config `/etc/config/shadowsocks-libev`.
Replace `config server 'sss0'` section with parameters of your own remote shadowsocks server.
As for other options, change them only when you know the effect.

	config server 'sss0'
		option disabled 0
		option server '_sss_addr_'
		option server_port '_sss_port_'
		option password '********'
		option method 'aes-256-cfb'

	config ss_tunnel
		option disabled 0
		option server 'sss0'
		option local_address '0.0.0.0'
		option local_port '8053'
		option tunnel_address '8.8.8.8:53'
		option mode 'tcp_and_udp'

	config ss_redir ssr0
		option disabled 0
		option server 'sss0'
		option local_address '0.0.0.0'
		option local_port '1100'
		option mode 'tcp_and_udp'
		option reuse_port 1

	config ss_rules 'ss_rules'
		option disabled 0
		option redir_tcp 'ssr0'
		option redir_udp 'ssr0'
		option src_default 'checkdst'
		option dst_default 'forward'
		option local_default 'forward'

Restart shadowsocks-libev components

	/etc/init.d/shadowsocks-libev restart

Check if things are in place

	iptables-save | grep ss_rules
	netstat -lntp | grep -E '8053|1100'
	ps ww | grep ss-

Edit `/etc/config/dhcp`, making sure options are present in the first dnsmasq section like the following to let it use local tunnel endpoint for upstream dns query.
Option `noresolv` instructs dnsmasq to not use other dns servers like advertised by local isp.
Option `localuse` intends to make sure the device you are configuring also uses this dnsmasq instance as the resolver, not the ones from other sources.

	config dnsmasq
		...
		list server '127.0.0.1#8053'
		option noresolv 1
		option localuse 1

Restart dnsmasq

	/etc/init.d/dnsmasq restart

Check network on your computer

	nslookup www.google.com
	curl -vv https://www.google.com
