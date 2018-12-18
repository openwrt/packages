# banIP - ban incoming and/or outgoing ip adresses via ipsets

## Description
IP address blocking is commonly used to protect against brute force attacks, prevent disruptive or unautherized address(es) from access or it can be used to restrict access to or from a particular geographic area — for example.  

## Main Features
* support many IP blocklist sources (free for private usage, for commercial use please check their individual licenses):
* zero-conf like automatic installation & setup, usually no manual changes needed
* supports six different download utilities: uclient-fetch, wget, curl, aria2c, wget-nossl, busybox-wget
* Really fast downloads & list processing as they are handled in parallel as background jobs in a configurable 'Download Queue'
* provides 'http only' mode without installed ssl library for all non-SSL blocklist sources
* full IPv4 and IPv6 support
* ipsets (one per source) are used to ban a large number of IP addresses
* supports blocking by ASN numbers
* supports blocking by iso country codes
* supports local white & blacklist (IPv4, IPv6 & CIDR notation), located by default in /etc/banip/banip.whitelist and /etc/banip/banip.blacklist
* auto-add unsuccessful ssh login attempts to local blacklist
* auto-add the uplink subnet to local whitelist
* per source configuration of SRC (incoming) and DST (outgoing)
* integrated IPSet-Lookup
* integrated RIPE-Lookup
* blocklist source parsing by fast & flexible regex rulesets
* minimal status & error logging to syslog, enable debug logging to receive more output
* procd based init system support (start/stop/restart/reload/status)
* procd network interface trigger support
* output comprehensive runtime information via LuCI or via 'status' init command
* strong LuCI support
* optional: add new banIP sources on your own

## Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series (18.06) and with the latest snapshot
* a download utility:
    * to support all blocklist sources a full version (with ssl support) of 'wget', 'uclient-fetch' with one of the 'libustream-*' ssl libraries, 'aria2c' or 'curl' is required
    * for limited devices with real memory constraints, banIP provides also a 'http only' option and supports wget-nossl and uclient-fetch (without libustream-ssl) as well

## Installation & Usage
* install 'banip' (_opkg install banip_)
* at minimum configure the needed IP blocklist sources, the download utility and enable the banIP service in _/etc/config/banip_
* control the banip service manually with _/etc/init.d/banip_ start/stop/restart/reload/status or use the LuCI frontend

## LuCI banIP companion package
* it's recommended to use the provided LuCI frontend to control all aspects of banIP
* install 'luci-app-banip' (_opkg install luci-app-banip_)
* the application is located in LuCI under 'Services' menu

## Examples
**receive banIP runtime information:**

<pre><code>
/etc/init.d/banip status
::: banIP runtime information
  + status     : enabled
  + version    : 0.0.5
  + fetch_info : /bin/uclient-fetch (libustream-ssl)
  + ipset_info : 3 IPSets with overall 29510 IPs/Prefixes
  + last_run   : 08.11.2018 15:03:50
  + system     : GL-AR750S, OpenWrt SNAPSHOT r8419-860de2e1aa
</code></pre>
  
**cronjob for a regular block list update (/etc/crontabs/root):**

<pre><code>
0 06 * * *    /etc/init.d/banip reload
</code></pre>
  

## Support
Please join the banIP discussion in this [forum thread](https://forum.openwrt.org/t/banip-new-project-needs-testers-feedback/16985) or contact me by mail <dev@brenken.org>  

## Removal
* stop all banIP related services with _/etc/init.d/banip stop_
* optional: remove the banip package (_opkg remove banip_)

Have fun!  
Dirk  
