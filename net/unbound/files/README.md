# Unbound Recursive DNS Server with UCI

## Description
This package of UNBOUND is prepared with UCI. It allows UNBOUND to be used in parallel or serial to DNSMASQ. Recurse the universe DNS, but forward to DNSMASQ for your DHCP resolved names.

## UCI
/etc/config/unbound
config unbound

	option add_gate_name '0'
		Boolean, makes UNBOUND forward WAN ARPA requests to DNSMASQ. Often your
		ISP gives you a useless IP4 name and no IP6 name. In DNSMASQ, you could
		name the WAN with "--interface-name=gateway.out,wan" for logs.
	
	option add_local_name '0'
		(like gate name, but not used, and currently inclusive with DNSMASQ)
	
	option control '0'
		Boolean, Enables access to UNBOUND-CONTROL application on the loopback
		interface only; no SSL.
	
	option dnsmasq '0'
		Boolean, Forward local domain "lan" or "local" and ARAP to DNSMASQ. This
		will use "/etc/config/dhcp" figure DNSMASQ and interfaces.
	
	option dnssec '0'
		Boolean, Enable DNSSEC. If you don't have a real-time clock on power
		down, then also its recommended to make your internet time source
		"insecure_zone."
	
	option edns_size '1280'
		Extended DNS is necessary for DNSSEC. However, it can run into MTU
		issues. Use this size in bytes to manage drop outs due to this purpose.
	
	option localservice '1'
		Boolean, Prevent DNS amplification attacks. Only provide access to 
		unbound from subnets this machine has interfaces on.
	
	option obscure '0'
		Boolean, added privacy only send the query name a piece at a time.
		Not that it matters in most cases, as the site of intrest is often the
		second name.
		(option not available when testing on package for CC 15.05.1)
	
	option port '53'
		Port this instance of UNBOUND will listen on for queries.
	
	option recursion 'passive'
		UNBOUND has numerous options for how it recurses. For this UCI we provide
		"passive" or "aggressive." "default" uses the applications compiled opt.
	
	option rebind_localhost '0'
		Boolean, prevent loopback "127.0.0.0/8" or "::1/128" responses. These are
		often used by black hole servers for good (adblock) and bad (censor).
	
	option rebind_protection '1'
		Boolean, prevent local subnet responses "192.168.0.0/24" which could be
		used to turn a local browser into an external attack proxy server.
	
	option resource 'small'
		UNBOUND has numerous options for resources. For this UCI we provide
		"tiny," "small," "medium," and "large." Medium is most like the compiled
		defaults with a bit of balancing. Tiny is close to the published memory'
		restricted configuration. Small is half of medium, and large twice.
	
	option root_age '90'
		UNBOUND needs some guess at where to find root servers. They don't move
		much but they do move. When interfaces chagne (ifup), the root hints and
		root key (DNSSEC) will be updated this many days.
	
	option ttl_min '120'
		Recursion can be expensive if you can't cache. Some bad admin's out there
		have their TTL set to ZERO though (i.e. no cache). This is also used for
		a part of snoop-vertising (DNS hit count). However, a minimum of 2-5
		minutes should be okay. 30 minutes is most allowed.
	
	list insecure_zone
		List domains that you wish to skip DNSSEC on. This can be necessary for
		your internet time like "pool.ntp.org" to prevent chicken-n-egg. Your
		local domain gets this automatically from "option dnsmasq".

