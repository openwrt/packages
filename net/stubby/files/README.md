# Stubby for OpenWRT

## Stubby Description
[Stubby](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby) is an application that acts as a local DNS Privacy stub resolver (using DNS-over-TLS). Stubby encrypts DNS queries sent from a client machine (desktop or laptop) to a DNS Privacy resolver increasing end user privacy.

Stubby is developed by the [getdns](http://getdnsapi.net/) project.

For more background and FAQ see our [About Stubby](https://dnsprivacy.org/wiki/display/DP/About+Stubby) page. Stubby is in the early stages of development but is suitable for technical/advanced users. A more generally user-friendly version is on the way!

## Prerequisites

You must have a ca cert bundle installed on your device for stubby to make the TLS enabled connections.

- You can install this by running the following: opkg install ca-certificates
- You can also install this through the LUCI web interface

## Package Overview
This package has some modifications that makes it differ from the default upstream configuration. They are outlined below.

### General Cleanup
Comments are removed, etc.

### EDNS Client-Subnet Option Changed to 0
The value of "edns_client_subnet_private" is '1' in the upstream default config. This informs the upstream resolver to NOT forward your connection's IP to any other upstream servers. This is good for privacy, but could result in sub-optimal routing to CDNs, etc.

To give a more "comparable" DNS experience similar to google/opendns, this package disables this option.

### Default Listening Ports Changed
The value of "listen_addresses" in the default config does not list port numbers, which will cause stubby to default to port 53. However, Openwrt defaults to dnsmasq as the main name server daemon, which runs on port 53. By setting the listening ports to non-standard values, this allows users to keep the main name server daemon in place (dnsmasq/unbound/etc.) and have that name server forward to stubby.

Additionally, due to the slight overhead involved with DNS-over-TLS, it is recommended to have a caching name server on the network.

### Round Robin Upstream Setting Changed

The default stubby config list multiple upstream resolvers, and because of this, it makes sense to "load balance" between them. However, in this package's default stubby config, the only upstream service listed is Cloudflare. One entry is for ipv6 and one for ipv4.

By setting the "round_robin_upstreams" value to 0, we are simply forcing stubby to try and use ipv6 connectivity to Cloudflare first, and if not available, simply use the ipv4 service.

Cloudflare is an Anycast DNS service. This should take care of any needed "failover" in the event that one of Cloudflare's nodes goes down.

### Upstream Resolvers Changed

Most of the default resolvers for stubby are in Europe. To provide a better experience for a larger number of users, this package defaults to using Cloudflare's DNS service. Cloudflare's DNS service has been ranked number one in speed against many other top resolvers.

https://developers.Cloudflare.com/1.1.1.1/commitment-to-privacy/
https://www.dnsperf.com/dns-resolver/1-1-1-1