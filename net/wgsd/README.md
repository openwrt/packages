## Wireguard Service Discovery (Mesh)

This tool allows you to build a mesh from wireguard tunnels and also traversal NAT.

See this article: https://www.jordanwhited.com/posts/wireguard-endpoint-discovery-nat-traversal/
Also see project on github: https://github.com/jwhited/wgsd


## Usage

On server edit /etc/Corefile to select on which port DNS-SD should be serving and also which interface to use.

Here is the example, where port `5353` will be used by coredns, `coredns.lan.` zone be used for discovery and `vpn_wg` interface be used to gather peers information.

    .:5353 {
      log
      #whoami
      wgsd coredns.lan. vpn_wg
    }

On a client you should put to the cron line like that:

    1,6,11,16,21,26,31,36,41,46,51,56 * * * * /usr/bin/wgsd-client -device vpn_wg -dns your.central.node:5353 -zone coredns.lan


### Note

All peers that should connect to each other should know other peers.
So you should setup your central node as a first peer followed with peers.
E.g. let's say we have a Cloud-Router (CR), Alice and the Bob. Then you should configure peers for CR (with the address) and Bob on Alice's side and CR and Alice on Bob's.
