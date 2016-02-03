# adblock script for openwrt

## Description
A lot of people already use adblocker plugins within their desktop browsers,  
but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...  
...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router.  

When the dns server on your router receives dns requests, you will sort out queries that ask for the resource records of ad servers and return the local ip address of your router and the internal web server delivers a transparent pixel instead.

## Main Features
* support of the following domain blocklist sources (free for private usage, for commercial use please check their individual licenses):
    * [adaway.org](https://adaway.org)
    * => infrequent updates, approx. 400 entries (enabled by default)
    * [disconnect.me](https://disconnect.me)
    * => numerous updates on the same day, approx. 6.500 entries (enabled by default)
    * [dshield.org](http://dshield.org)
    * => daily updates, approx. 4.500 entries
    * [feodotracker.abuse.ch](https://feodotracker.abuse.ch)
    * => daily updates, approx. 0-10 entries
    * [malwaredomains.com](http://malwaredomains.com)
    * => daily updates, approx. 16.000 entries
    * [malwaredomainlist.com](http://www.malwaredomainlist.com)
    * => daily updates, approx. 1.500 entries
    * [palevotracker.abuse.ch](https://palevotracker.abuse.ch)
    * => daily updates, approx. 15 entries
    * [shallalist.de](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default)
    * => daily updates, approx. 32.000 entries (a short description of all shallalist categories can be found [online](http://www.shallalist.de/categories.html))
    * [spam404.com](http://www.spam404.com)
    * => infrequent updates, approx. 5.000 entries
    * [whocares.org](http://someonewhocares.org)
    * => weekly updates, approx. 12.000 entries
    * [winhelp2002.mvps.org](http://winhelp2002.mvps.org)
    * => infrequent updates, approx. 15.000 entries
    * [yoyo.org](http://pgl.yoyo.org/adservers)
    * => weekly updates, approx. 2.500 entries (enabled by default)
    * [zeustracker.abuse.ch](https://zeustracker.abuse.ch)
    * => daily updates, approx. 440 entries
* zero-conf like automatic installation & setup, usually no manual changes needed (i.e. ip address, network devices etc.)
* full IPv4 and IPv6 support
* each blocklist source will be updated and processed separately
* timestamp check to download and process only updated adblock list sources
* overall duplicate removal in separate adblock lists (will be automatically disabled on low memory systems)
* adblock source list parsing by fast & flexible regex rulesets
* additional white- and blacklist support for manual overrides
* quality checks during & after update of adblock lists to ensure a reliable dnsmasq service
* wan update check, to wait for an active wan uplink before update
* basic adblock statistics via iptables packet counters
* status & error logging to stdout and syslog
* use of dynamic uhttpd instance as adblock pixel server
* optional features (disabled by default):
    * adblock list backup/restore
    * debug logging to separate file

## Prerequisites
* [openwrt](https://openwrt.org), tested with latest stable release (Chaos Calmer 15.05) and with current trunk (Designated Driver > r47025)
* usual openwrt setup with 'iptables' & 'uhttpd', additional required software packages:
    * wget
    * optional: 'kmod-ipt-nat6' for IPv6 support
* the above dependencies and requirements will be checked during package installation & script runtime, please check console output or *logread -e "adblock"* for errors

## Usage
* install the adblock package (*opkg install adblock*)
* optional: for an update installation please replace your existing */etc/config/adblock* with a copy of */etc/samples/adblock.conf.sample* to get the latest changes
* optional: enable/disable your required adblock list sources in */etc/config/adblock* - 'adaway', 'disconnect' and 'yoyo' are enabled by default
* start */usr/bin/adblock-update.sh* and check console output or *logread -e "adblock"* for errors

## Tweaks
* there is no need to enable all blacklist sites at once, for normal use one to three adblock list sources should be sufficient
* if you really need to handle all blacklists at once add an usb stick or any other storage device to supersize your /tmp directory with a swap partition
* => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* add static, personal domain white- or blacklist entries, one domain per line (wildcards & regex are not allowed!), by default both lists are located in */etc/adblock*
* enable the backup/restore feature, to restore automatically the latest, stable backup of your adblock lists in case of any processing error
* enable the logging feature for continuous logfile writing to monitor the adblock runs over a longer period

## Distributed samples
* all sample configuration files stored in */etc/adblock/samples*
* for a fully blown adblock configuration with all explained options see *adblock.conf.sample*
* for some dnsmasq tweaks see *dhcp.config.sample* and *dnsmasq.conf.sample*
* for rc.local based autostart and /tmp resizing on the fly see *rc.local.sample*
* for scheduled call of *adblock-update.sh* see *root.crontab.sample*

## Background
This adblock package is a dns/dnsmasq based adblock solution for openwrt.  
Queries to ad/abuse domains are never forwarded and always replied with a local IP address which may be IPv4 or IPv6.  
For that purpose adblock uses an ip address from the private 'TEST-NET-1' subnet (192.0.2.1 / ::ffff:c000:0201) by default.  
Furthermore all ad/abuse queries will be filtered by ip(6)tables and redirected to internal adblock pixel server (in PREROUTING chain) or rejected (in FORWARD and OUTPUT chain).  
All iptables and uhttpd related adblock additions are non-destructive, no hard-coded changes in 'firewall.user', 'uhttpd' config or any other openwrt related config files.

## Removal
* remove the adblock package (*opkg remove adblock*)
* remove all script generated adblock lists in */tmp/dnsmasq.d/*
* kill the running adblock uhttpd instance (ps | grep "[u]httpd.*\-h /www/adblock")
* run /etc/init.d/dnsmasq restart
* run /etc/init.d/firewall restart

Have fun!  
Dirk  
