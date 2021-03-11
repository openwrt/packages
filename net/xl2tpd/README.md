# OpenWrt Package for xl2tpd

xl2tpd is a development from the original l2tpd package originally written by
Mark Spencer, subsequently forked by Scott Balmos and David Stipp, inherited
by Jeff McAdams, modified substantially by Jacco de Leeuw and then forked
again by Xelerance (after it was abandoned by l2tpd.org).

## Rationale for inclusion in OpenWrt

l2tpd has some serious alignment problems on RISC platforms. It also runs
purely in userspace.

Some of the features added in this fork include:

1. IPSec SA reference tracking inconjunction with openswan's IPSec transport
   mode, which adds support for multiple clients behind the same NAT router
   and multiple clients on the same internal IP behind different NAT routers.

2. Support for the pppol2tp kernel mode L2TP.

3. Alignment and endian problems resolved.

hcg

## UCI options

`server` takes the form `host[:port]` with port defaults to `1701`.  It
specifies the l2tp server's address.

`checkup_interval` tells netifd to check after that many seconds since last
setup attempt to see if the interface is up.  If not it should issue another
teardown/setup round to retry the negotiation.  This option defaults to 0 and
netifd will not do the check and retry.

The following are generic ppp options and should have the same format and
semantics as with other ppp-related protocols.  See
[uci/network#protocol_ppp](https://openwrt.org/docs/guide-user/network/wan/wan_interface_protocols#protocol_ppp_ppp_over_modem)
for details.

	username
	password
	keepalive
	ipv6
	mtu
	pppd_options
