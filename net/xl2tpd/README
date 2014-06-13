OpenWRT Package for xl2tpd

xl2tpd is a development from the original l2tpd package originally written by
Mark Spencer, subsequently forked by Scott Balmos and David Stipp, inherited
by Jeff McAdams, modified substantially by Jacco de Leeuw and then forked 
again by Xelerance (after it was abandoned by l2tpd.org).

Rationale for inclusion in OpenWRT:

l2tpd has some serious alignment problems on RISC platforms. It also runs 
purely in userspace.

Some of the features added in this fork include:

1. IPSec SA reference tracking inconjunction with openswan's IPSec transport
   mode, which adds support for multiple clients behind the same NAT router
	 and multiple clients on the same internal IP behind different NAT routers.

2. Support for the pppol2tp kernel mode L2TP.

3. Alignment and endian problems resolved.

hcg
