# Unbound Recursive DNS Server with UCI
<!-- markdownlint-disable -->

## Unbound Description
[Unbound](https://www.unbound.net/) is a validating, recursive, and caching DNS resolver. The C implementation of Unbound is developed and maintained by [NLnet Labs](https://www.nlnetlabs.nl/). It is based on ideas and algorithms taken from a java prototype developed by Verisign labs, Nominet, Kirei and ep.net. Unbound is designed as a set of modular components, so that also DNSSEC (secure DNS) validation and stub-resolvers (that do not run as a server, but are linked into an application) are easily possible.

## Package Overview
OpenWrt default build uses [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for DNS forwarding and DHCP. With a forward only resolver, dependence on the upstream recursors may be cause for concern. They are often provided by the ISP, and some users have switched to public DNS providers. Either way may result in problems due to performance, "snoop-vertising", hijacking (MiM), and other causes. Running a recursive resolver or resolver capable of TLS may be a solution.

Unbound may be useful on consumer grade embedded hardware. It is fully DNSSEC and TLS capable. It is _intended_ to be a recursive resolver only. NLnet Labs [NSD](https://www.nlnetlabs.nl/projects/nsd/) is _intended_ for the authoritative task. This is different than [ISC Bind](https://www.isc.org/downloads/bind/) and its inclusive functions. Unbound configuration effort and memory consumption may be easier to control. A consumer could have their own recursive resolver with 8/64 MB router, and remove potential issues from forwarding resolvers outside of their control.

This package builds on Unbounds capabilities with OpenWrt UCI. Not every Unbound option is in UCI, but rather, UCI simplifies the combination of related options. Unbounds native options are bundled and balanced within a smaller set of choices. Options include resources, DNSSEC, access control, and some TTL tweaking. The UCI also provides an escape option and works at the raw `unbound.conf` level.

## HOW TO: Ad Blocking
The UCI scripts will work with [net/adblock](https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md), if it is installed and enabled. Its all detected and integrated automatically. In brief, the adblock scripts create distinct local-zone files that are simply included in the unbound conf file during UCI generation. If you don't want this, then disable adblock or reconfigure adblock to not send these files to Unbound.

A few tweaks may be needed to enhance the realiability and effectiveness. Ad Block option for delay time may need to be set for upto one minute (adb_triggerdelay), because of boot up race conditions with interfaces calling Unbound restarts. Also many smart devices (TV, microwave, or refigerator) will also use public DNS servers either as a bypass or for certain connections in general. If you wish to force exclusive DNS to your router, then you will need a firewall rule for example:

**/etc/config/firewall**:
```
config rule
  option dest 'wan'
  option dest_port '53 853 5353'
  option enabled '1'
  option family 'any'
  option name 'Block-Public-DNS'
  option proto 'tcpudp'
  option src 'lan'
  option target 'REJECT'
```

## HOW TO: Integrate with DHCP
Some UCI options and scripts help Unbound to work with DHCP servers to load the local DNS. The examples provided here are serial dnsmasq with unbound, parallel dnsmasq with unbound, and unbound scripted with odhcpd.

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
  option port '53'
  option resolvfile '/tmp/resolv.conf.auto'
  list server '127.0.0.1#1053'
  list server '::1#1053'
  ...
```

### Parallel dnsmasq
In this case, Unbound serves your local network directly for all purposes. It will look over to dnsmasq for DHCP-DNS resolution. Unbound is generally accessible on port 53, and dnsmasq is only accessed at `127.0.0.1#1053` by Unbound. Although you can dig/drill/nslookup remotely with the proper directives.

**/etc/config/unbound**:
```
config unbound
  # likely you want to match domain option between Unbound and dnsmasq
  option dhcp_link 'dnsmasq'
  option domain 'yourdomain'
  option listen_port '53'
  ...
```

**/etc/config/dhcp**:
```
config dnsmasq
  option domain 'yourdomain'
  option noresolv '1'
  option port '1053'
  option resolvfile '/tmp/resolv.conf.auto'
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
  option leasefile '/var/lib/odhcpd/dhcp.leases'
  # this is where the magic happens
  option leasetrigger '/usr/lib/unbound/odhcpd.sh'
  option maindhcp '1'
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
  list server 'ns1.it.example.com'
  list server 'ns2.it.example.com'
  option url_dir 'https://asset-management.it.example.com/zones/'
  option zone_type 'auth_zone'
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
  # these servers assume a common TLS port/index
  list server '192.0.2.53'
  list server '2001:db8::53'
  # this alternate server is fully specified inline
  list server '192.0.2.153@443#dns.alternate.example.org'
  list zone_name '.'
  option zone_type 'forward_zone'
```

## Optional Compile Switches
Unbound can be changed by toggling switches within `make menuconfig` Libraries/Network/libunbound. Disable libevent, libpthread, and ipset to attempt to gain performance and size on small single core targets. These downgrade options are well tested, but they are not needed unless Unbound will not fit. Take care before enabling subnetcache, dnscrypt, and python options. These enhancements are not fully tested within OpenWrt and python is a large dependency. These enhancements are default off and they do not have UCI. You will need to use the files `/etc/unbound/unbound_srv.conf` and `/etc/unbound/unbound_ext.conf` to configure these modules. The `server:` clause line `module: subnetcache validator python iterator` will be filled out if the modules are compiled in.

Note: if you use python, then you will need to manual configure and you cannot use chroot. The scripts are not yet enhanced enough to set up the directory binding.

## Complete UCI
### config unbound
One instance is supported currently.
| UCI | Default | Units | Description | Unbound |
| --- | ------- | ----- | ----------- | ------- |
| add_extra_dns | 0 | level | Read OpenWrt traditional options for `dnsmasq`.<br>`0`: Disabled<br>`1`: Use only domain<br>`2`: Use domain, mxhost, and srvhost<br>`3`: Use all cname, domain, mxhost, and srvhost | local-data: |
| add_local_fqdn | 0 | level | Each level puts a  more detailed router entry within the LAN DNS (except link).<br>`0`: Disabled<br>`1`: Host name on the primary address<br>`2`: Host name on all addresses<br>`3`: FQDN and host name on all addresses<br>`4`: FQDN defined by "iface.hostname.domain" |  local-zone: local-data: |
| add_wan_fqdn | 0 | level | Same as `add_local_fqdn` but on WAN as listed in `iface_wan` | local-zone: local-data: |
| dns64 | 0 | boolean | Enable DNS64 RFC6052 to bridge IPv4 and IPv6 networks. | module: dns64 |
| dns64_prefix | 64:ff9b::/96 | subnet | DNS64 RFC6052 IPv4 in IPv6 well known prefix. | dns64-prefix: |
| dhcp_link | none | program | Link to a DHCP server with supported scripts. See HOW TO above. | local-zone: local-data: forward-zone: |
| dhcp4_slaac6 | 0 | boolean | Infer SLAAC IE64 IPv6 addresses from DHCPv4 MAC in DHCP link scripts. | - |
| exclude_ipv6_ga | 0 | boolean | If exclude IPv6 global addresses from local data. | local-data: |
| domain | lan | domain | This will suffix DHCP host records and be the default search domain. | local-zone: |
| domain_insecure | (empty) | domain | **List** domains that you wish to skip DNSSEC. It is one way around NTP chicken and egg. Your DHCP domains are automatically included. | domain-insecure: |
| domain_type | static | state | This allows you to lock down or allow forwarding of the local zone.<br>`static`: no forwarding like dnsmasq default<br>`refuse`: answer overtly with REFUSED<br>`deny`: covertly drop all queries<br>`transparent`: may continue forwarding or recusion | local-zone: |
| edns_size | 1232 | bytes | Extended DNS is necessary for DNSSEC. Use this to manage MTU issues. | edns-size: |
| extended_stats | 0 | boolean | Extended statistics are stored in Unbound memory for report by `unbound-control`. | extended-statistics: |
| hide_binddata  | 1 | boolean | Refuse possible attack queries like version.server, version.bind, id.server, and hostname.bind. | hide-identity: hide-version: |
| iface_lan | lan | interface | **List** to add interafaces you wish to consider to be LAN beyond those served by DHCP | interface: access-control: |
| iface_trig | lan wan | interface | **List** interfaces to watch IFUP to restart Unbound. This works around `netifd` and `procd` hyper activity with WAN DHCPv6 (else restart each 2-3 minutes). | - |
| iface_wan | wan | interface | **List** interafaces you wish to consider to be WAN for masked local zone purposes | interface-outgoing: |
| interface_auto | 1 | boolean | RECOMMEND ENABLED otherwise Unbound answers to any attached address regardless of query in-address. This also binds Unboud to the wild card address. | interface-automatic: |
| listen_port | 53 | port | Inbound port where Unbound will listen for queries. | port: |
| localservice | 1 | boolean | Prevent DNS amplification attacks. Only answer to subnets this machine has interfaces on. | access-control: |
| manual_conf | 0 | boolean | Skip all this UCI nonsense. Manually edit the configuration in `/etc/unbound/unbound.conf`. | - |
| num_threads | 1 | threads | Enable multithreading. Two are supported with only one cache slab. More becomes an industrial setup, and UCI simplificaitons may not be appropriate. | num-threads: |
| protocol | mixed | state | Limit Unbound protocols for recursion or forwarding.<br>`ip4_only`: old fashioned IPv4 upstream and downstream<br>`ip6_only`: test environment only; could cauase problems<br>`ip6_local`: upstream IPv4 only and local network IPv4 and IPv6<br>`ip6_prefer`: both IPv4 and IPv6 but try IPv6 first<br>`mixed`: both IPv4 and IPv6<br>`default`: built-in defaults | do-ip4: do-ip6: prefer-ip6: interface: |
| query_minimize | 0 | boolean | Enable a minor privacy option. Query one domain piece at a time (dot separator). | qname-minimisation: |
| query_min_strict | 0 | boolean | Query minimize may fall back to normal. This prevents the fall back, but non-standard name servers will fail. | qname-minimisation-strict: |
| rate_limit | 0 | query/s | Limit the total number of queries and queries per client by half that. Disabled by setting 0. | ratelimit: ip-ratelimit: |
| rebind_localhost | 0 | boolean | Prevent loopback addresses `127.0.0.0/8` or `::1` in upstream responses. They could be a good black hole server or a spring board attack. | private-address: |
| rebind_protection | 1 | level | Prevent your local addresses from being allowed in upstream responses. They could be a spring board attack.<br>`0`: Disabled<br>`1`: Only RFC 1918 and 4193 responses blocked<br>`2`: Above plus GLA /64 on machine<br>`3`: Above plus DHCP-PD passed down (not implemented) | private-address: |
| recursion | passive | state | Unbound has many options for recrusion but UCI is bundled for simplicity.<br>`passive`: slower until cache fills but kind on CPU load<br>`default`: built-in defaults<br>`aggressive`: uses prefetching to handle more requests quickly | (many) |
| resource | small | state | Unbound has many options for memory resources but UCI is bundled for simplicity.<br>`tiny`: similar to published memory restricted configuration<br>`small`: about half of medium<br>`medium`: similar to default<br>`default`: built-in defaults<br>`large`: about double of medium | \*-cache-size: |
| root_age | 9 | day | >90 Disables. Age limit for root data like root DNSSEC key. Scripts will copy from `tmps` to flash ROM with this limit to save write life. | - |
| ttl_min | 120 | second | Minimum TTL in cache to avoid abused low TTL for snoop-vertising and non-standard load balancing. Typical to configure maybe 0~300 but 1800 is the maximum accepted. | cache-min-ttl: |
| unbound_control | 0 | level | Enables `unbound-control` application access ports.<br>`0`: None else add your own in unbound_ext.conf<br>`1`: Unencrypted Local Host Access<br>`2`: SSL Local Host Access w/ auto unbound-control-setup<br>`3`: SSL Network Access w/ auto unbound-control-setup<br>`4`: SSL Network Access; static key/pem files must already exist | unbound-control: ... (clause) |
| validator | 0 | boolean | Enable DNSSEC validator module. | module: validator |
| validator_ntp | 1 | boolean | Disable DNSSEC time checks at boot and restart when NTP locks in time. DNSSEC requires time validation and this breaks the chicken and egg. | - |
| verbosity | 1 |  level | Logging inensity. | verbosity: |

### config zone
Confingure any mix of Unbound `forward-zone:`, `stub-zone:`, or `auth-zone:` clauses. These sections are more compact than Unbound and will unroll into Unbound's configuration syntax.
| UCI | Default | Units | Description | Unbound |
| --- | ------- | ----- | ----------- | ------- |
| dns_assist | none | program | Check against local host forwarding by requiring a target program to exist and be enabled else do not permit forwarding `127.0.0.0/8` or `::1`. Includes bind, dnsmasq, http-proxy-dns, ipset-dns, and nsd. | forward-addr: |
| enabled | 0 | boolean | turn zone on or off without deleting it | - |
| fallback | 1 | boolean | Allow this zone to fall through to other zones or recursion. | forward-first: |
| port | 53 | port | Target server's target port for plain DNS operations. | (auto 192.0.2.53 \#53)
| resolv_conf | 0 | boolean | Use resolv.conf servers as it was filled by the DHCP client. For example your ISP services (mail.example.net) or co-located services (streamed-movies.example.com). | - |
| server | (empty) | address domain | Required **list** to target servers. Full form is accepted but not required `192.0.2.53#53@dns.exmple.net`. Stub zones must use an IP address. | master: forward-host: forward-addr: stub-addr: |
| tls_index | (empty) | domain | TLS certifiicated signature index. If ommitted, Unbound encrypts but does not validate. | (auto 192.0.2.53 \#853 \@dns.example.net) |
| tls_port | 853 | port | Target server's target port for TLS DNS operations. | (auto 192.0.2.53 \#853) |
| tls_upstream | 0 | boolean | Use TLS to contact the zone server. | forward-tls-upstream: |
| url_dir | (empty) | string | Directory only path by http or https to get authoritative zone files. | url: |
| zone_name | (empty) | domain | Required **list** to select domains subject to this zone section. You can forward the root `.` zone or just your organizaiton `example.com.` | name: |
| zone_type | (empty) | state | Required option to create an Unbound zone clause.<br>`auth_zone`: prefetch whole zones from authoritative server<br>`forward_zone`: forward queries by domain name (like dnsmasq)<br>`stub_zone`: direct authoritative lookup by domain name | auth-zone: forward-zone: stub-zone: ... (clauses) |

