#!/bin/sh

pim_rule () {
uci -q batch <<-EOT
	delete firewall.$1
	set firewall.$1=rule
	set firewall.$1.name='$2 multicast forward for $3'
	set firewall.$1.src='*'
	set firewall.$1.dest='*'
	set firewall.$1.family='$2'
	set firewall.$1.proto='udp'
	set firewall.$1.dest_ip='$3'
	set firewall.$1.target='ACCEPT'
EOT
}

pim_rule pimbd4 ipv4 224.0.0.0/4
pim_rule pimbd6 ipv6 ff00::/8
uci commit firewall

exit 0

