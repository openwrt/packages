# Simple captive portal

This package intercepts/blocks traffic from 'interface' and
redirects http requests to a splash page that you can personalize,
stored in '/etc/simple-captive-portal/'.
After clicking on 'connect' the MAC of the client is allowed,
for 'timeout' seconds (24h), allowing both IPv4 and IPv6.

If your guest interface defaults to input drop or reject (recommended),
make sure to allow tcp 8888-8889 on input (and also dns and dhcp).

Here an example (ipv4) firewall configuration.

```
config zone
	option name 'guest'
	option forward 'REJECT'
	option output 'ACCEPT'
	option input 'REJECT'
	option network 'guest'

config forwarding
	option dest 'wans'
	option src 'guest'

config rule
	option name 'guest-dhcp'
	option src 'guest'
	option family 'ipv4'
	option proto 'udp'
	option dest_port '67'
	option target 'ACCEPT'

config rule
	option name 'guest-dns'
	option src 'guest'
	option family 'ipv4'
	list proto 'tcp'
	list proto 'udp'
	option dest_port '53'
	option target 'ACCEPT'

config rule
	option name 'guest-portal'
	option src 'guest'
	option family 'ipv4'
	list proto 'tcp'
	option dest_port '8888-8889'
	option target 'ACCEPT'
```

To disable simple-captive-portal, just unset/comment 'interface' in the uci config.
