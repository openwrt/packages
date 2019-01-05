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
* automatic blocklist backup & restore, they will be used in case of download errors or during startup in backup mode
* 'backup mode' to re-use blocklist backups during startup, get fresh lists via reload or restart action
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

## banIP config options
* usually the pre-configured banIP setup works quite well and no manual overrides are needed
* the following options apply to the 'global' config section:
    * ban\_enabled => main switch to enable/disable banIP service (bool/default: '0', disabled)
    * ban\_automatic => determine the L2/L3 WAN network device automatically (bool/default: '1', enabled)
    * ban\_fetchutil => name of the used download utility: 'uclient-fetch', 'wget', 'curl', 'aria2c', 'wget-nossl'. 'busybox' (default: 'uclient-fetch')
    * ban\_iface => space separated list of WAN network interface(s)/device(s) used by banIP (default: automatically set by banIP ('ban_automatic'))

* the following options apply to the 'extra' config section:
    * ban\_debug => enable/disable banIP debug output (default: '0', disabled)
    * ban\_nice => set the nice level of the banIP process and all sub-processes (int/default: '0', standard priority)
    * ban\_triggerdelay => additional trigger delay in seconds before banIP processing begins (int/default: '2')
    * ban\_backup => create compressed blocklist backups, they will be used in case of download errors or during startup in 'backup mode' (bool/default: '0', disabled)
    * ban\_backupdir => target directory for adblock backups (default: not set)
    * ban\_backupboot => do not automatically update blocklists during startup, use their backups instead (bool/default: '0', disabled)
    * ban\_maxqueue => size of the download queue to handle downloads & IPSet processing in parallel (int/default: '8')
    * ban\_fetchparm => special config options for the download utility (default: not set)

## Examples
**receive banIP runtime information:**

<pre><code>
/etc/init.d/banip status
::: banIP runtime information
  + status     : enabled
  + version    : 0.1.0
  + fetch_info : /bin/uclient-fetch (libustream-ssl)
  + ipset_info : 1 IPSets with overall 516 IPs/Prefixes (backup mode)
  + last_run   : 05.01.2019 14:48:18
  + system     : TP-LINK RE450, OpenWrt SNAPSHOT r8910+72-25d8aa7d02
</code></pre>
  
**cronjob for a regular block list update (/etc/crontabs/root):**

<pre><code>
0 06 * * *    /etc/init.d/banip reload
</code></pre>
  

## Support
Please join the banIP discussion in this [forum thread](https://forum.openwrt.org/t/banip-support-thread/16985) or contact me by mail <dev@brenken.org>  

## Removal
* stop all banIP related services with _/etc/init.d/banip stop_
* optional: remove the banip package (_opkg remove banip_)

Have fun!  
Dirk  
