# Unbound Recursive DNS Server with UCI

## Unbound Description
[Unbound](https://www.unbound.net/) is a validating, recursive, and caching DNS resolver. The C implementation of Unbound is developed and maintained by [NLnet Labs](https://www.nlnetlabs.nl/). It is based on ideas and algorithms taken from a java prototype developed by Verisign labs, Nominet, Kirei and ep.net. Unbound is designed as a set of modular components, so that also DNSSEC (secure DNS) validation and stub-resolvers (that do not run as a server, but are linked into an application) are easily possible.

## Package Overview
Unbound may be useful on consumer grade embedded hardware. It is _intended_ to be a recursive resolver only. [NLnet Labs NSD](https://www.nlnetlabs.nl/projects/nsd/) is _intended_ for the authoritative task. This is different than [ISC Bind](https://www.isc.org/downloads/bind/) and its inclusive functions. Unbound configuration effort and memory consumption may be easier to control. A consumer could have their own recursive resolver with 8/64 MB router, and remove potential issues from forwarding resolvers outside of their control.

This package builds on Unbounds capabilities with OpenWrt UCI. Not every Unbound option is in UCI, but rather, UCI simplifies the combination of related options. Unbounds native options are bundled and balanced within a smaller set of choices. Options include resources, DNSSEC, access control, and some TTL tweaking. The UCI also provides an escape option and work at the raw "unbound.conf" level.

## HOW TO Adblocking
The UCI scripts will work with [net/adblock 2.3+](https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md), if it is installed and enabled. Its all detected and integrated automatically. In brief, the adblock scripts create distinct local-zone files that are simply included in the unbound conf file during UCI generation. If you don't want this, then disable adblock or reconfigure adblock to not send these files to Unbound.

## HOW TO Integrate with DHCP
Some UCI options and scripts help Unbound to work with DHCP servers to load the local DNS. The examples provided here are serial dnsmasq-unbound, parallel dnsmasq-unbound, and unbound scripted with odhcpd.

### Serial dnsmasq
In this case, dnsmasq is not changed *much* with respect to the default OpenWRT/LEDE configuration. Here dnsmasq is forced to use the local Unbound instance as the lone upstream DNS server, instead of your ISP. This may be the easiest implementation, but performance degradation can occur in high volume networks. dnsmasq and Unbound effectively have the same information in memory, and all transfers are double handled.

**/etc/config/unbound**:

```
config unbound
  option add_local_fqdn '0'
  option add_wan_fqdn '0'
  option dhcp_link 'none'
  # dnsmasq should not forward your domain to unbound, but if...
  option domain 'yourdomain'
  option domain_type 'refuse'
  option listen_port '1053'
  ...
```

**/etc/config/dhcp**:

```
config dnsmasq
  option domain 'yourdomain'
  option noresolv '1'
  option resolvfile '/tmp/resolv.conf.auto'
  option port '53'
  list server '127.0.0.1#1053'
  list server '::1#1053'
  ...
```

### Parallel dnsmasq
In this case, Unbound serves your local network directly for all purposes. It will look over to dnsmasq for DHCP-DNS resolution. Unbound is generally accessible on port 53, and dnsmasq is only accessed at 127.0.0.1:1053 by Unbound. Although you can dig/drill/nslookup remotely with the proper directives.

**/etc/config/unbound**:

```
config unbound
  option dhcp_link 'dnsmasq'
  option listen_port '53'
  ...
```

**/etc/config/dhcp**:

```
config dnsmasq
  option domain 'yourdomain'
  option noresolv '1'
  option resolvfile '/tmp/resolv.conf.auto'
  option port '1053'
  ...

config dhcp 'lan'
  # dnsmasq may not issue DNS option if not std. configuration
  list dhcp_option 'option:dns-server,0.0.0.0'
  ...
```

### Unbound and odhcpd
You may ask can Unbound replace dnsmasq? You can have DHCP-DNS records with Unbound and odhcpd only. The UCI scripts will allow Unbound to act like dnsmasq. When odhcpd configures each DHCP lease, it will call a script. The script provided with Unbound will read the lease file for DHCP-DNS records. You **must install** `unbound-control`, because the lease records are added and removed without starting, stopping, flushing cache, or re-writing conf files. (_restart overhead can be excessive with even a few mobile devices._)

Don't forget to disable or uninstall dnsmasq when you don't intend to use it. Strange results may occur. If you want to use default dnsmasq+odhcpd and add Unbound on top, then use the dnsmasq-serial or dnsmasq-parallel methods above.

**/etc/config/unbound**:

```
config unbound
  # name your router in DNS
  option add_local_fqdn '1'
  option add_wan_fqdn '1'
  option dhcp_link 'odhcpd'
  # add SLAAC inferred from DHCPv4
  option dhcp4_slaac6 '1'
  option domain 'lan'
  option domain_type 'static'
  option listen_port '53'
  option rebind_protection '1'
  # install unbound-control and set this
  option unbound_control '1'
  ...
```

**/etc/config/dhcp**:

```
config dhcp 'lan'
  option dhcpv4 'server'
  option dhcpv6 'server'
  option interface 'lan'
  option leasetime '12h'
  option ra 'server'
  option ra_management '1'
  # issue your ULA and avoid default [fe80::]
  list dns 'fdxx:xxxx:xxxx::1'
  ...

config odhcpd 'odhcpd'
  option maindhcp '1'
  option leasefile '/var/lib/odhcpd/dhcp.leases'
  # this is where the magic happens
  option leasetrigger '/usr/lib/unbound/odhcpd.sh'
```

## HOW TO Manual Override
Yes, there is a UCI to disable the rest of Unbound UCI. However, OpenWrt or LEDE are targeted at embedded machines with flash ROM. The initialization scripts do a few things to protect flash ROM.

### Completely Manual (almost)
All of `/etc/unbound` (persistent, ROM) is copied to `/var/lib/unbound` (tmpfs, RAM). Edit your manual `/etc/unbound/unbound.conf` to reference this `/var/lib/unbound` location for included files. Note in preparation for a jail, `/var/lib/unbound` is `chown unbound`. Configure for security in`/etc/unbound/unbound.conf` with options `username:unbound` and `chroot:/var/lib/unbound`.

Keep the DNSKEY updated with your choice of flash activity. `root.key` maintenance for DNSKEY RFC5011 would be hard on flash. Unbound natively updates frequently. It also creates and destroys working files in the process. In `/var/lib/unbound` this is no problem, but it would be gone at the next reboot. If you have DNSSEC (validator) active, then you should consider the age UCI option. Choose how many days to copy from `/var/lib/unbound/root.key` (tmpfs) to `/etc/unbound/root.key` (flash).

**/etc/config/unbound**:

```
config unbound
  option manual_conf '1'
  option root_age '9'
  # end
```

### Hybrid Manual/UCI
You like the UCI. Yet, you need to add some difficult to standardize options, or just are not ready to make a UCI request yet. The files `/etc/unbound/unbound_srv.conf` and `/etc/unbound/unbound_ext.conf` will be copied to Unbounds chroot directory and included during auto generation.

The former will be added to the end of the `server:` clause. The later will be added to the end of the file for extended `forward:` and `view:` clauses. You can also disable unbound-control in the UCI which only allows "localhost" connections unencrypted, and then add an encrypted remote `control:` clause.

## Complete List of UCI Options
**/etc/config/unbound**:

```
config unbound
  Currently only one instance is supported.

  option add_local_fqdn '0'
    Level. This puts your routers host name in the LAN (local) DNS.
    Each level is more detailed and comprehensive.
    0 - Disabled
    1 - Host Name on only the primary address
    2 - Host Name on all addresses found (except link)
    3 - FQDN and host name on all addresses (except link)
    4 - Above and interfaces named <iface>.<hostname>.<domain>

  option add_wan_fqdn '0'
    Level. Same as previous option only this applies to the WAN. WAN
    are inferred by a UCI `config dhcp` entry that contains the line
    option ignore '1'.

  option dns64 '0'
    Boolean. Enable DNS64 through Unbound in order to bridge networks
    that are IPV6 only and IPV4 only (see RFC6052).

  option dns64_prefix '64:ff9b::/96'
    IPV6 Prefix. The IPV6 prefix wrapped on the IPV4 address for DNS64.
    You should use RFC6052 "well known" address, unless you also
    redirect to a proxy or gateway for your NAT64.

  option dhcp_link 'none'
    Program Name. Link to one of the supported programs we have scripts
    for. You may also need to install a trigger script in the DHCP
    servers configuration. See HOW TO above.

  option dhcp4_slaac6 '0'
    Boolean. Some DHCP servers do this natively (dnsmasq). Otherwise
    the script provided with this package will try to fabricate SLAAC
    IP6 addresses from DHCPv4 MAC records.

  option domain 'lan'
    Unbound local-zone: <domain> <type>. This is used to suffix all
    host records, and maintain a local zone. When dnsmasq is dhcp_link
    however, then this option is ignored (dnsmasq does it all).

  option domain_type 'static'
    Unbound local-zone: <domain> <type>. This allows you to lock
    down or allow forwarding of your domain, your router host name
    without suffix, and leakage of RFC6762 "local."

  option edns_size '1280'
    Bytes. Extended DNS is necessary for DNSSEC. However, it can run
    into MTU issues. Use this size in bytes to manage drop outs.

  option hide_binddata '1'
    Boolean. If enabled version.server, version.bind, id.server, and
    hostname.bind queries are refused.

  option listen_port '53'
    Port. Incoming. Where Unbound will listen for queries.

  option localservice '1'
    Boolean. Prevent DNS amplification attacks. Only provide access to
    Unbound from subnets this machine has interfaces on.

  option manual_conf '0'
    Boolean. Skip all this UCI nonsense. Manually edit the
    configuration. Make changes to /etc/unbound/unbound.conf.

  option protocol 'mixed'
    Unbound can limit its protocol used for recursive queries.
    Set 'ip4_only' to avoid issues if you do not have native IP6.
    Set 'ip6_prefer' to possibly improve performance as well as
    not consume NAT paths for the client computers.
    Do not use 'ip6_only' unless testing.

  option query_minimize '0'
    Boolean. Enable a minor privacy option. Don't let each server know
    the next recursion. Query one piece at a time.

  option query_min_strict '0'
    Boolean. Query minimize is best effort and will fall back to normal
    when it must. This option prevents the fall back, but less than
    standard name servers will fail to resolve their domains.

  option rebind_localhost '0'
    Boolean. Prevent loopback "127.0.0.0/8" or "::1/128" responses.
    These may used by black hole servers for good purposes like
    ad-blocking or parental access control. Obviously these responses
    also can be used to for bad purposes.

  option rebind_protection '1'
    Boolean. Prevent RFC 1918 Reponses from global DNS. Example a
    poisoned reponse within "192.168.0.0/24" could be used to turn a
    local browser into an external attack proxy server.

  option recursion 'passive'
    Unbound has numerous options for how it recurses. This UCI combines
    them into "passive," "aggressive," or Unbound's own "default."
    Passive is easy on resources, but slower until cache fills.

  option resource 'small'
    Unbound has numerous options for resources. This UCI gives "tiny,"
    "small," "medium," and "large." Medium is most like the compiled
    defaults with a bit of balancing. Tiny is close to the published
    memory restricted configuration. Small 1/2 medium, and large 2x.

  option root_age '9'
    Days. >90 Disables. Age limit for Unbound root data like root
    DNSSEC key. Unbound uses RFC 5011 to manage root key. This could
    harm flash ROM. This activity is mapped to "tmpfs," but every so
    often it needs to be copied back to flash for the next reboot.

  option ttl_min '120'
    Seconds. Minimum TTL in cache. Recursion can be expensive without
    cache. A low TTL is normal for server migration. A low TTL can be
    abused for snoop-vertising (DNS hit counts; recording query IP).
    Typical to configure maybe 0~300, but 1800 is the maximum accepted.

  option unbound_control '0'
    Boolean. Enables unbound-control application access ports. Enabling
    this without the unbound-control package installed is robust.

  option validator '0'
    Boolean. Enable DNSSEC. Unbound names this the "validator" module.

  option validator_ntp '1'
    Boolean. Disable DNSSEC time checks at boot. Once NTP confirms
    global real time, then DNSSEC is restarted at full strength. Many
    embedded devices don't have a real time power off clock. NTP needs
    DNS to resolve servers. This works around the chicken-and-egg.

  list domain_insecure
    List. Domains or pointers that you wish to skip DNSSEC. Your DHCP
    domains and pointers in dnsmasq will get this automatically.
```


