# adblock script for openwrt

## Description
A lot of people already use adblocker plugins within their desktop browsers,  
but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...  
...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router.  

When the dns server on your router receives dns requests, you’ll sort out queries that ask for the [A] resource records of ad servers  
and return the local ip address of your router and the internal web server delivers a transparent pixel instead.

## Main Features
* support of the following domain blacklist sites (free for private usage, for commercial use please check their individual licenses):
    * [pgl.yoyo.org](http://pgl.yoyo.org/adservers), approx. 2.500 entries
    * [malwaredomains.com](http://malwaredomains.com), approx. 16.000 entries
    * [zeustracker.abuse.ch](https://zeustracker.abuse.ch), approx. 420 entries
    * [feodotracker.abuse.ch](https://feodotracker.abuse.ch), approx. 10 entries
    * [palevotracker.abuse.ch](https://palevotracker.abuse.ch), approx. 10 entries
    * [dshield.org](http://dshield.org), approx. 4.500 entries
    * [shallalist.de](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default), approx. 32.000 entries
    * a short description of all shallalist categories can be found [online](http://www.shallalist.de/categories.html)
    * [spam404.com](http://www.spam404.com), approx. 5.000 entries
    * [winhelp2002.mvps.org](http://winhelp2002.mvps.org), approx. 15.000 entries
* blocklist parsing by fast & flexible regex rulesets
* additional white- and blacklist support for manual overrides
* separate dynamic adblock network interface
* separate dynamic uhttpd instance as pixel server
* adblock quality checks after list update to ensure a reliable dnsmasq service
* optional: powerful adblock list backup/restore handling
* optional: adblock updates only on pre-defined wan interfaces (useful for (mobile) multiwan setups)
* optional: domain query logging as a background service to easily identify free and already blocked domains (see example output below)
* optional: status & error logging to separate file (req. ntp time sync)
* optional: ntp time sync

## Prerequisites
* [openwrt](https://openwrt.org) (tested only with trunk > r47025), CC should also work
* additional software packages:
    * curl
    * wget (due to an openwrt bug still needed for certain https requests - see ticket #19621)
    * optional: busybox find with *-mtime* support for logfile housekeeping (enabled by default with r47362, will be disabled if not found)
    * optional: coreutils-sort for reliable sort results, even on low memory systems
* recommended: add an usb stick or any other storage device to supersize your /tmp directory with a swap partition (see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab))
* the above dependencies and requirements will be checked during package installation & script startup, please check console output or *logread -e "adblock"* for errors

## Usage
* select & install adblock package (*opkg install adblock*)
* configure */etc/config/adblock* to your needs, see additional comments in *adblock.conf.sample*
* at least configure the ip address of the local adblock interface/uhttpd instance, needs to be a different subnet from the normal LAN
* optional: add additional domain white- or blacklist entries, one domain per line (wildcards & regex are not allowed!), both list are located in */etc/adblock*
* by default openwrts main uhttpd instance is bind to all ports of your router. For a working adblock setup you have to bind uhttpd to the standard LAN port only, please change listen_http accordingly
* start /usr/bin/adblock-update.sh and check console output or *logread -e "adblock"* for errors

## Distributed samples
* all sample configuration files stored in */etc/adblock/samples*
* to enable/disable additional domain query logging set the dnsmasq option *logqueries* accordingly, see *dhcp.config.sample*
* to bind uhttpd to standard LAN port only, see *uhttpd.config.sample*
* for script autostart by rc.local and /tmp resizing on the fly see *rc.local.sample*
* for scheduled call of *adblock-update.sh* see *root.crontab.sample*
* to redirect/force all dns queries to your router see *firwall.user.sample*
* for further dnsmasq tweaks see *dnsmasq.conf.sample*

## Examples

  stdout excerpt for successful adblock run:  
    
    adblock[11541] info : domain adblock processing started (0.22.2, r47665, 29.11.2015 14:58:11)  
    adblock[11541] info : wan update check will be disabled  
    adblock[11541] info : get ntp time sync (192.168.254.254), after 0 loops  
    adblock[11541] info : shallalist (pre-)processing started ...  
    adblock[11541] info : shallalist (pre-)processing finished (adv costtraps spyware tracker warez)  
    adblock[11541] info : source download finished (http://pgl.yoyo.org/adservers/serverlist.php?hostformat=one-line&showintro=0&mimetype=plaintext, 2423 entries)  
    adblock[11541] info : source download finished (http://mirror1.malwaredomains.com/files/justdomains, 16016 entries)  
    adblock[11541] info : source download finished (https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist, 419 entries)  
    adblock[11541] info : source download finished (https://feodotracker.abuse.ch/blocklist/?download=domainblocklist, 0 entries)  
    adblock[11541] info : source download finished (https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist, 12 entries)  
    adblock[11541] info : source download finished (http://www.dshield.org/feeds/suspiciousdomains_Low.txt, 4542 entries)  
    adblock[11541] info : source download finished (http://spam404bl.com/spam404scamlist.txt, 5193 entries)  
    adblock[11541] info : source download finished (http://winhelp2002.mvps.org/hosts.txt, 13635 entries)  
    adblock[11541] info : source download finished (file:////tmp/tmp.CgbMmO/shallalist.txt, 32446 entries)  
    adblock[11541] info : empty source download finished (file:///etc/adblock/adblock.blacklist)  
    adblock[11541] info : domain merging finished  
    adblock[11541] info : new adblock list with 69646 domains loaded, backup generated  
    adblock[11541] info : domain adblock processing finished (0.22.2, r47665, 29.11.2015 14:59:23)  
    

  generated domain blocklist for dnsmasq:  
    
    address=/0-29.com/192.168.2.1  
    address=/0-2u.com/192.168.2.1  
    address=/0.r.msn.com/192.168.2.1  
    address=/00.devoid.us/192.168.2.1  
    address=/000007.ru/192.168.2.1  
    [...]  
    address=/zzz.cn/192.168.2.1  
    address=/zzzjsh.com/192.168.2.1  
    ####################################################  
    # last adblock list update: 20.11.2015 - 18:00:02  
    # adblock-update.sh (0.21.0) - 73087 ad/abuse domains blocked  
    # domain blacklist sources:  
    # http://pgl.yoyo.org/adservers/serverlist.php?hostformat=one-line&showintro=0&mimetype=plaintext  
    # http://mirror1.malwaredomains.com/files/justdomains  
    # https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist  
    # https://feodotracker.abuse.ch/blocklist/?download=domainblocklist  
    # https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist  
    # http://www.dshield.org/feeds/suspiciousdomains_Low.txt  
    # http://spam404bl.com/spam404scamlist.txt  
    # http://winhelp2002.mvps.org/hosts.txt  
    # file:////tmp/tmp.CLBLNF/shallalist.txt  
    # file:///etc/adblock/adblock.blacklist  
    #####  
    # /etc/adblock/adblock.whitelist  
    ####################################################  
    

  domain query log excerpt:  
    
    query[A] www.seenby.de from fe80::6257:18ff:fe6b:4667  
    query[A] tarifrechner.heise.de from 192.168.1.131  
    query[A] www.mittelstandswiki.de from fe80::6257:18ff:fe6b:4667  
    query[A] ad.doubleclick.net from 192.168.1.131  
    ad.doubleclick.net is 192.168.2.1  
    

The first three queries are OK (not blocked), the last one has been blocked and answered by local dnsmasq instance.

Have fun!  
Dirk  
