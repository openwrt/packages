# Unbound Recursive DNS Server with UCI

## Unbound Description
[Unbound](https://www.unbound.net/) is a validating, recursive, and caching DNS resolver. The C implementation of Unbound is developed and maintained by [NLnet Labs](https://www.nlnetlabs.nl/). It is based on ideas and algorithms taken from a java prototype developed by Verisign labs, Nominet, Kirei and ep.net. Unbound is designed as a set of modular components, so that also DNSSEC (secure DNS) validation and stub-resolvers (that do not run as a server, but are linked into an application) are easily possible.

## Package Overview
OpenWrt default build uses [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for DNS forwarding and DHCP. With a forward only resolver, dependence on the upstream recursors may be cause for concern. They are often provided by the ISP, and some users have switched to public DNS providers. Either way may result in problems due to performance, "snoop-vertising", hijacking (MiM), and other causes. Running a recursive resolver or resolver capable of TLS may be a solution.

Unbound may be useful on consumer grade embedded hardware. It is fully DNSSEC and TLS capable. It is _intended_ to be a recursive resolver only. NLnet Labs [NSD](https://www.nlnetlabs.nl/projects/nsd/) is _intended_ for the authoritative task. This is different than [ISC Bind](https://www.isc.org/downloads/bind/) and its inclusive functions. Unbound configuration effort and memory consumption may be easier to control. A consumer could have their own recursive resolver with 8/64 MB router, and remove potential issues from forwarding resolvers outside of their control.

This package builds on Unbounds capabilities with OpenWrt UCI. Not every Unbound option is in UCI, but rather, UCI simplifies the combination of related options. Unbounds native options are bundled and balanced within a smaller set of choices. Options include resources, DNSSEC, access control, and some TTL tweaking. The UCI also provides an escape option and works at the raw "unbound.conf" level.

## HOW TO: Ad Blocking
The UCI scripts will work with [net/adblock](https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md), if it is installed and enabled. Its all detected and integrated automatically. In brief, the adblock scripts create distinct local-zone files that are simply included in the unbound conf file during UCI generation. If you don't want this, then disable adblock or reconfigure adblock to not send these files to Unbound.

A few tweaks may be needed to enhance the realiability and effectiveness. Ad Block option for delay time may need to be set for upto one minute (adb_triggerdelay), because of boot up race conditions with interfaces calling Unbound restarts. Also many smart devices (TV, microwave, or refigerator) will also use public DNS servers either as a bypass or for certain connections in general. If you wish to force exclusive DNS to your router, then you will need a firewall rule for example:

**/etc/config/firewall**:
```
config rule
  option name 'Block-Public-DNS'
  option enabled '1'
  option src 'lan'
  option dest 'wan'
  option dest_port '53 853 5353'
  option proto 'tcpudp'
  option family 'any'
  option target 'REJECT'
```

## HOW TO: Integrate with DHCP
Some UCI options and scripts help Unbound to work with DHCP servers to load the local DNS. The examples provided here are serial dnsmasq-unbound, parallel dnsmasq-unbound, and unbound scripted with odhcpd.

### Serial dnsmasq
In this case, dnsmasq is not changed *much* with respect to the default [OpenWrt](https://openwrt.org/docs/guide-user/base-system/dns_configuration) configuration. Here dnsmasq is forced to use the local Unbound instance as the lone upstream DNS server, instead of your ISP. This may be the easiest implementation, but performance degradation can occur in high volume networks. Unbound and dnsmasq effectively have the same information in memory, and all transfers are double handled.

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
You may ask, "can Unbound replace dnsmasq?" You can have DHCP-DNS records with Unbound and [odhcpd](https://github.com/openwrt/odhcpd/blob/master/README) only. The UCI scripts will allow Unbound to act like dnsmasq. When odhcpd configures each DHCP lease, it will call a script. The script provided with Unbound will read the lease file for DHCP-DNS records. The unbound-control application is required, because simply rewriting conf-files and restarting unbound is too much overhead.
- Default OpenWrt has dnsmasq+odhcpd with `odhcpd-ipv6only` limited to DHCPv6.
- If you use dnsmasq+odhcpd together, then use dnsmasq serial or parallel methods above.
- You must install package `odhcpd` (full) to use odhcpd alone.
- You must install package `unbound-control` to load and unload leases.
- Remember to uninstall (or disable) dnsmasq when you won't use it.

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
  ...

config odhcpd 'odhcpd'
  option maindhcp '1'
  option leasefile '/var/lib/odhcpd/dhcp.leases'
  # this is where the magic happens
  option leasetrigger '/usr/lib/unbound/odhcpd.sh'
```

## HOW TO: Manual Override
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

The file `unbound_srv.conf` will be added into the `server:` clause. The file `unbound_ext.conf` will be added to the end of all configuration. It is for extended `forward-zone:`, `stub-zone:`, `auth-zone:`, and `view:` clauses. You can also disable unbound-control in the UCI which only allows "localhost" connections unencrypted, and then add an encrypted remote `control:` clause.

## HOW TO: Cache Zone Files
Unbound has the ability to AXFR a whole zone from an authoritative server to prefetch the zone. This can speed up access to common zones. Some may have special bandwidth concerns for DNSSEC overhead. The following is a generic example. UCI defaults include the [root](https://www.internic.net/domain/) zone, but it is disabled as a ready to go example.

**/etc/config/unbound**:
```
config zone
  option enabled '1'
  option fallback '1'
  option url_dir 'https://asset-management.it.example.com/zones/'
  option zone_type 'auth_zone'
  list server 'ns1.it.example.com'
  list server 'ns2.it.example.com'
  list zone_name 'example.com'
```

## HOW TO: TLS Over DNS
Unbound can use TLS as a client or server. UCI supports Unbound as a forwarding client with TLS. Servers are more complex and need manual configuration. This may be desired for privacy against stealth tracking. Some public DNS servers seem to advertise help in this quest. If your looking for a better understanding, then some information can be found at [Cloudflare](https://www.cloudflare.com/) DNS [1.1.1.1](https://1.1.1.1/). The following is a generic example. You can mix providers by using complete server specificaiton to override the zones common port and certificate domain index.

Update as of Unbound 1.9.1, all TLS functions work correctly with either OpenSSL 1.0.2 or 1.1.0. Please be sure to install `ca-bundle` package and use `opkg` to get updates regularly.

**/etc/config/unbound**:
```
config zone
  option enabled '1'
  # question: do you want to recurse when TLS fails or not?
  option fallback '0'
  option tls_index 'dns.example.net'
  option tls_port '853'
  option tls_upstream '1'
  option zone_type 'forward_zone'
  # these servers assume a common TLS port/index
  list server '192.0.2.53'
  list server '2001:db8::53'
  # this alternate server is fully specified inline
  list server '192.0.2.153@443#dns.alternate.example.org'
  list zone_name '.'
```

## Complete List of UCI Options
**/etc/config/unbound**:
```
config unbound
  Currently only one instance is supported.

  option add_extra_dns '0'
    Level. Execute traditional DNS overrides found in `/etc/config/dhcp`.
    Optional so you may use other Unbound conf or redirect to NSD instance.
    0 - Ignore `/etc/config/dhcp`
    1 - Use only 'domain' clause (host records)
    2 - Use 'domain', 'mxhost', and 'srvhost' clauses
    3 - Use all of 'domain', 'mxhost', 'srvhost', and 'cname' clauses

  option add_local_fqdn '0'
    Level. This puts your routers host name in the LAN (local) DNS.
    Each level is more detailed and comprehensive.
    0 - Disabled
    1 - Host Name on only the primary address
    2 - Host Name on all addresses found (except link)
    3 - FQDN and host name on all addresses (except link)
    4 - Above and interfaces named <iface>.<hostname>.<domain>

  option add_wan_fqdn '0'
    Level. Same as previous option only this applies to the WAN. WAN are
    inferred by a UCI `config dhcp` entry that contains the 'option ignore 1'.

  option dns64 '0'
    Boolean. Enable DNS64 through Unbound in order to bridge networks that are
    IPV6 only and IPV4 only (see RFC6052).

  option dns64_prefix '64:ff9b::/96'
    IPV6 Prefix. The IPV6 prefix wrapped on the IPV4 address for DNS64. You
    should use RFC6052 "well known" address, unless you also redirect to a proxy
    or gateway for your NAT64.

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
    down or allow forwarding of the local zone. Notable types:
    static - typical single router setup much like OpenWrt dnsmasq default
    refuse - to answer overtly with DNS code REFUSED
    deny - to drop queries for the local zone
    transparent - to use your manually added forward-zone: or stub-zone: clause

  option edns_size '1280'
    Bytes. Extended DNS is necessary for DNSSEC. However, it can run
    into MTU issues. Use this size in bytes to manage drop outs.

  option extended_stats '0'
    Boolean. extended statistics are printed from unbound-control.
    Keeping track of more statistics takes time.

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

  option num_threads '1'
    Count. Enable multithreading with the "heavy traffic" variant. Base variant
    spins each as whole proces and is not efficient. Two threads may be used,
    but they use one shared cache slab. More edges into an industrial setup,
    and UCI simplificaitons may not be appropriate.

  option protocol 'mixed'
    Unbound can limit its protocol used for recursive queries.
    ip4_only - old fashioned IPv4 upstream and downstream
    ip6_only - test environment only; could cauase problems
    ip6_local - upstream IPv4 only and local network IPv4 and IPv6
    ip6_prefer - both IPv4 and IPv6 but try IPv6 first
    mixed - both IPv4 and IPv6
    default - Unbound built-in defaults

  option query_minimize '0'
    Boolean. Enable a minor privacy option. Don't let each server know the next
    recursion. Query one piece at a time.

  option query_min_strict '0'
    Boolean. Query minimize is best effort and will fall back to normal when it
    must. This option prevents the fall back, but less than standard name
    servers will fail to resolve their domains.

  option rebind_localhost '0'
    Boolean. Prevent loopback "127.0.0.0/8" or "::1/128" responses. These may
    used by black hole servers for good purposes like ad-blocking or parental
    access control. Obviously these responses may be used to for bad purposes.

  option rebind_protection '1'
    Level. Block your local address responses from global DNS. A poisoned
    reponse within "192.168.0.0/24" or "fd00::/8" could turn a local browser
    into an external attack proxy server. IP6 GLA may be vulnerable also.
    0 - Off
    1 - Only RFC 1918 and 4193 responses blocked
    2 - Plus GLA /64 on designated interface(s)
    3 - Plus DHCP-PD range passed down interfaces (not implemented)

  option recursion 'passive'
    Unbound has many options for recrusion but UCI is bundled for simplicity.
    passive - slower until cache fills but kind on CPU load
    default - Unbound built-in defaults
    aggressive - uses prefetching to handle more requests quickly

  option resource 'small'
    Unbound has many options for resources but UCI is bundled for simplicity.
    tiny - similar to published memory restricted configuration
    small - about half of medium
    medium - similar to default, but fixed for consistency
    default - Unbound built-in defaults
    large - about double of medium

  option root_age '9'
    Days. >90 Disables. Age limit for Unbound root data like root DNSSEC key.
    Unbound uses RFC 5011 to manage root key. This could harm flash ROM. This
    activity is mapped to "tmpfs," but every so often it needs to be copied back
    to flash for the next reboot.

  option ttl_min '120'
    Seconds. Minimum TTL in cache. Recursion can be expensive without cache. A
    low TTL is normal for server migration. A low TTL can be abused for snoop-
    vertising (DNS hit counts; recording query IP). Typical to configure maybe
    0~300, but 1800 is the maximum accepted.

  option unbound_control '0'
    Level. Enables unbound-control application access ports.
    0 - No unbound-control Access, or add your own in 'unbound_ext.conf'
    1 - Unencrypted Local Host Access
    2 - SSL Local Host Access; auto unbound-control-setup if available
    3 - SSL Network Access; auto unbound-control-setup if available
    4 - SSL Network Access; static key/pem files must already exist

  option validator '0'
    Boolean. Enable DNSSEC. Unbound names this the "validator" module.

  option validator_ntp '1'
    Boolean. Disable DNSSEC time checks at boot. Once NTP confirms global real
    time, then DNSSEC is restarted at full strength. Many embedded devices don't
    have a real time power off clock. NTP needs DNS to resolve servers. This
    works around the chicken-and-egg.

  option verbosity '1'
    Level. Sets Unbounds logging intensity.

  list domain_insecure 'ntp.somewhere.org'
    Domain. Domains that you wish to skip DNSSEC. It is one way around NTP
    chicken and egg. Your DHCP servered domains are automatically included.

  list trigger_interface 'lan' 'wan'
    Interface (logical). This option is a work around for netifd/procd
    interaction with WAN DHCPv6. Minor RA or DHCP changes in IP6 can cause
    netifd to execute procd interface reload. Limit Unbound procd triggers to
    LAN and WAN (IP4 only) to prevent restart @2-3 minutes.


config zone
  Create Unbounds forward-zone:, stub-zone:, or auth-zone: clauses

  option enabled 1
    Boolean. Enable the zone clause.

  option fallback 1
    Boolean. Permit normal recursion when the narrowly selected servers in this
    zone are unresponsive or return empty responses. Disable, if there are
    security concerns (forward only internal to organization).

  option port 53
    Port. Servers are contact on this port for plain DNS operations.

  option resolv_conf 0
    Boolean. Use "resolv.conf" as it was filled by the DHCP client. This can be
    used to forward zones within your ISP (mail.example.net) or that have co-
    located services (streamed-movies.example.com). Recursion may not yield the
    most local result, but forwarding may instead.

  option tls_index (n/a)
    Domain. Name TLS certificates are signed for (dns.example.net). If this
    option is ommitted, then Unbound will make connections but not validate.

  option tls_port 853
    Port. Servers are contact on this port for DNS over TLS operations.

  option tls_upstream 0
    Boolean. Use TLS to contact the zone server.

  option url_dir
    String. http or https path, directory part only, to the zone file for
    auth_zone type only. Files "${zone_name}.zone" are expect in this path.

  option zone_type (n/a)
    State. Required field or the clause is effectively disabled. Check Unbound
    documentation for clarity (unbound-conf).
    auth_zone     - prefetch whole zones from authoritative server (ICANN)
    forward_zone  - forward queries in these domains to the listed servers
    stub_zone     - force recursion of these domains to the listed servers

  list server (n/a)
    IP. Every zone must have one server. Stub and forward require IP to prevent
    chicken and egg (due to UCI simplicity). Authoritative prefetch may use a
    server name.

  list zone_name
    Domain. Every zone must represent some part of the DNS tree. It can be all
    of it "." or you internal organization domain "example.com." Within each
    zone clause all zone names will be matched to all servers.
```

## Replaced Options
  config unbound / option prefetch_root
    List the domains in a zone with type auth_zone and fill in the server or url
    fields. Root zones are ready but disabled in default install UCI.

  config unbound / list domain_forward
    List the domains in a zone with type forward_zone and enable the
    resolv_conf option.

  config unbound / list rebind_interface
    Enable rebind_protection at 2 and all DHCP interfaces are also protected for
    IPV6 GLA (parallel to subnets in add_local_fqdn).

