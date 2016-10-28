# Unbound Recursive DNS Server with UCI

## Unbound Description
Unbound is a validating, recursive, and caching DNS resolver. The C implementation of Unbound is developed and maintained by [NLnet Labs](https://www.unbound.net/). It is based on ideas and algorithms taken from a java prototype developed by Verisign labs, Nominet, Kirei and ep.net. Unbound is designed as a set of modular components, so that also DNSSEC (secure DNS) validation and stub-resolvers (that do not run as a server, but are linked into an application) are easily possible.

## Package Overview
Unbound may be useful on consumer grade embedded hardware. It is *intended* to be a recursive resolver only. [NLnet Labs NSD](https://www.nlnetlabs.nl/projects/nsd/) is *intended* for the authoritative task. This is different than [ISC Bind](https://www.isc.org/downloads/bind/) and its inclusive functions. Unbound configuration effort and memory consumption may be easier to control. A consumer could have their own recursive resolver, and remove potential issues from forwarding resolvers outside of their control.

This package builds on Unbounds capabilities with OpenWrt UCI. Not every Unbound option is in UCI, but rather, UCI simplifies the combination of related options. Unbounds native options are bundled and balanced within a smaller set of choices. Options include resources, DNSSEC, access control, and some TTL tweaking. The UCI also provides an escape option and work at the raw "unbound.conf" level.

## Work with dnsmasq
Some UCI options will help Unbound and dnsmasq work together in **parallel**. The default DHCP and DNS stub resolver in OpenWrt is dnsmasq, and it will continue to serve this purpose. The following actions will make Unbound the primary DNS server, and make dnsmasq only provide DNS to local DHCP.

- Set `unbound` UCI `option dnsmasq_link_dns` to true.
- Set other `unbound` UCI options how you wish.
- Set `dnsmasq` UCI `option noresolv` to true.
- Set `dnsmasq` UCI `option resolvfile` to blank single-quotes.
- Set `dnsmasq` UCI `option port` to 1053 or 5353.
- Add to each `dhcp` UCI `list dhcp_option option:dns-server,0.0.0.0`

Alternatives are mentioned here for completeness. DHCP event scripts which write host records are difficult to formulate for Unbound, NSD, or Bind. These programs sometimes need to be forcefully reloaded with host configuration, and reloads can bust cache. **Serial** configuration between dnsmasq and Unbound can be made on 127.0.0.1 with an off-port like #1053. This may double cache storage and incur unnecessary transfer delay.

## UCI Options
**/etc/config/unbound**:

	config unbound
		Currently only one instance is supported.

	option dnsmasq_gate_name '0'
		Boolean. Forward PTR records for interfaces not	serving DHCP.
		Assume these are WAN. Example dnsmasq option here to provide
		logs with a name when your ISP won't link DHCP-DNS.
		"dnsmasq.conf: interface-name=way-out.myrouter.lan,eth0.1"

	option dnsmasq_link_dns '0'
		Boolean. Master link to dnsmasq. Parse /etc/config/dhcp for dnsmasq
		options. Forward domain such as "lan" and PTR records for DHCP
		interfaces and their deligated subnets, IP4 and IP6.

	option dnsmasq_only_local '0'
		TODO: not yet implemented
		Boolean. Restrict link to dnsmasq. DNS only to local host. Obscure
		names of other connected hosts on the network. Example:
		"drill -x 198.51.100.17  ~ IN PTR way-out.myrouter.lan"
		"drill -x 192.168.10.1   ~ IN PTR guest-wifi.myrouter.lan"
		"drill -x 192.168.10.201 ~ NODATA" (insted of james-laptop.lan)

	option edns_size '1280'
		Extended DNS is necessary for DNSSEC. However, it can run into MTU
		issues. Use this size in bytes to manage drop outs.

	option listen_port '53'
		Port. Incoming. Where Unbound will listen for queries.

	option localservice '1'
		Boolean. Prevent DNS amplification attacks. Only provide access to
		Unbound from subnets this machine has interfaces on.

	option manual_conf '0'
		Boolean. Skip all this UCI nonsense. Manually edit the
		configuration. Make changes to /etc/unbound/unbound.conf.

	option query_minimize '0'
		Boolean. Enable a minor privacy option. Query only one name piece
		at a time. Don't let each server know the next recursion.

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

	option root_age '30'
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

