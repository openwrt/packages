This package will add the so-called `pppossh` protocol support to OpenWrt.  The idea is mainly from [`pvpn` project](https://github.com/halhen/pvpn) (poor man's VPN over SSH).

PPPoSSH is generally not considered a network setup for production use mainly due to the TCP-over-TCP styles of traffic transport, but it can be quite handy for personal use.  And with what's already in OpenWrt, it is really easy and takes little extra space to configure it up and running.

## Prerequisites and dependency.

`pppossh` depends on either `dropbear` or `openssh-client`; `dropbear` is normally enabled in OpenWrt by default.

The following requirements need to be fulfilled for it to work.

- A SSH account on the remote machine with `CAP_NET_ADMIN` capability is required.
- Public key authentication must be enabled and setup properly.

	Public key of the one generated automatially by dropbear can be induced by the following command.  But you can always use your own (dropbear can work with OpenSSH public key).

		dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key

- SSH server's fingerprint has to be present in `~/.ssh/known_hosts` for the authentication to proceed in an unattended way.

	Manually logging in at least once to the remote server from OpenWrt should do this for you.

## How to use it.

The protocol name to use in `/etc/config/network` is `pppossh`.  Options are as described below.

- `server`, SSH server name
- `port`, SSH server port (defaults to `22`).
- `sshuser`, SSH login username
- `identity`, list of client private key files.  `~/.ssh/id_{rsa,dsa}` will
   be used if no identity file was specified and at least one of them must be
   valid for the public key authentication to proceed.
- `ipaddr`, local ip address to be assigned.
- `peeraddr`, peer ip address to be assigned.
- `ssh_options`, extra options for the ssh client.
- `peer_pppd_options`, extra options for the pppd command run on the peer side.
- `use_hostdep`, set it to `0` to disable the use of `proto_add_host_dependency`.  This is mainly for the case that the appropriate route to `server` is not registered to `netifd` and thus causing a incorrect route being setup.

## Tips

An `uci batch` command template for your reference.  Modify it to suite your situation.

	uci batch <<EOF
	delete network.fs
	set network.fs=interface
	set network.fs.proto=pppossh
	set network.fs.sshuser=root
	set network.fs.server=ssh.example.cn
	set network.fs.port=30244
	add_list network.fs.identity=/etc/dropbear/dropbear_rsa_host_key
	set network.fs.ipaddr=192.168.177.2
	set network.fs.peeraddr=192.168.177.1
	commit
	EOF

Allow forward and NAT on the remote side (`ppp0` is the peer interface on the remote side.  `eth0` is the interface for Internet access).

	sysctl -w net.ipv4.ip_forward=1
	iptables -t filter -A FORWARD -i ppp0 -j ACCEPT
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

It's possible that pppd may output protocol negotiation incompatibilities issues to syslog, such as something like the following which did not hurt the connectivity and was annoying only because we thought it can do better.

	Sun Oct 25 09:45:14 2015 daemon.err pppd[22188]: Received bad configure-rej:  12 06 00 00 00 00

To debug such problems, we can try adding `option pppd_optinos debug` to the interface config.  In the above case, it's a LCP CCP configure rej (the CCP options struct is exactly 6 octets in size as indicated in source code `pppd/ccp.h`) and since the internet fee is not charged on the bytes transferred, I will just use `noccp` to disable the negotiation altogether.

Also to optimize bulk transfer performance, you can try tweaking the ciphers.  OpenSSH client does not support `none` cipher by default and you have to patch and install it by yourself.  Another option is to try ciphers like `arcfour` and `blowfish-cbc`.  In my case, `arcfour` has the best throughput.

	option ssh_options '-o "Ciphers arcfour"'
