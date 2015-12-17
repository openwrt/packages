# adblock script for openwrt

## Description
A lot of people already use adblocker plugins within their desktop browsers,  
but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...  
...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router.  

When the dns server on your router receives dns requests, you’ll sort out queries that ask for the [A] resource records of ad servers  
and return the local ip address of your router and the internal web server delivers a transparent pixel instead.

## Main Features
* support of the following domain blocklist sources (free for private usage, for commercial use please check their individual licenses):
    * [pgl.yoyo.org](http://pgl.yoyo.org/adservers)
    * => weekly updates, approx. 2.500 entries (enabled by default)
    * [malwaredomains.com](http://malwaredomains.com)
    * => daily updates, approx. 16.000 entries
    * [zeustracker.abuse.ch](https://zeustracker.abuse.ch)
    * => daily updates, approx. 440 entries
    * [feodotracker.abuse.ch](https://feodotracker.abuse.ch)
    * => daily updates, approx. 0-10 entries
    * [palevotracker.abuse.ch](https://palevotracker.abuse.ch)
    * => daily updates, approx. 15 entries
    * [dshield.org](http://dshield.org)
    * => daily updates, approx. 4.500 entries
    * [shallalist.de](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default)
    * => daily updates, approx. 32.000 entries (a short description of all shallalist categories can be found [online](http://www.shallalist.de/categories.html))
    * [spam404.com](http://www.spam404.com)
    * => infrequent updates, approx. 5.000 entries
    * [winhelp2002.mvps.org](http://winhelp2002.mvps.org)
    * => infrequent updates, approx. 15.000 entries
    * [adaway.org](https://adaway.org)
    * => infrequent updates, approx. 400 entries
    * [disconnect.me](https://disconnect.me)
    * => numerous updates on the same day, approx. 6.500 entries
* each blocklist source will be updated and processed separately
* timestamp check to download and process only updated blocklists
* overall duplicate removal in separate blocklists (will be automatically disabled on low memory systems)
* blocklist parsing by fast & flexible regex rulesets
* additional white- and blacklist support for manual overrides
* use of dynamic adblock network interface
* use of dynamic uhttpd instance as pixel server
* use of quality checks after adblocklist updates to ensure a reliable dnsmasq service
* optional features (disabled by default): 
    * powerful adblock list backup/restore handling
    * adblock updates only on pre-defined wan interfaces (useful for (mobile) multiwan setups)
    * domain query logging as a background service to easily identify free and already blocked domains (see example output below)
    * ntp time sync
    * status & error logging to separate file (req. ntp time sync)

## Prerequisites
* [openwrt](https://openwrt.org) (tested only with trunk > r47025), CC should also work
* additional software packages:
    * curl
    * wget (due to an openwrt bug still needed for certain https requests - see ticket #19621)
    * optional: busybox find with *-mtime* support for logfile housekeeping (enabled by default with r47362, will be disabled if not found)
* the above dependencies and requirements will be checked during package installation & script startup, please check console output or *logread -e "adblock"* for errors

## Usage
* select & install adblock package (*opkg install adblock*)
* configure */etc/config/adblock* to your needs, see additional comments in *adblock.conf.sample*
* at least configure the ip address of the local adblock interface/uhttpd instance, it needs to be a different subnet from the normal LAN
* recommendation: there is no need to enable all blacklist sites at once, for normal use one to three lists should be sufficient
* recommendation: to handle all blacklists at once add an usb stick or any other storage device to supersize your /tmp directory with a swap partition
* => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* add additional domain white- or blacklist entries, one domain per line (wildcards & regex are not allowed!), both lists are located in */etc/adblock*
* by default openwrts main uhttpd instance is bind to all ports of your router,
* for a working adblock setup you have to bind uhttpd to the standard LAN port only, please change listen_http accordingly
* start /usr/bin/adblock-update.sh and check console output or *logread -e "adblock"* for errors

## Distributed samples
* all sample configuration files stored in */etc/adblock/samples*
* to enable/disable additional domain query logging set the dnsmasq option *logqueries* accordingly, see *dhcp.config.sample*
* to bind uhttpd to standard LAN port only, see *uhttpd.config.sample*
* for rc.local based autostart and /tmp resizing on the fly see *rc.local.sample*
* for scheduled call of *adblock-update.sh* see *root.crontab.sample*
* to redirect/force all dns queries to your router see *firwall.user.sample*
* for further dnsmasq tweaks see *dnsmasq.conf.sample*

## Examples

  log of a full adblock run:  
    
    adblock[1586] info : domain adblock processing started (0.40.0, r47670, 17.12.2015 10:50:09)  
    adblock[1586] info : wan update check will be disabled  
    adblock[1586] info : get ntp time sync (192.168.2.254), after 0 loops  
    adblock[1586] info : created new dynamic/volatile network interface (adblock, 192.168.2.1)  
    adblock[1586] info : created new dynamic/volatile uhttpd instance (adblock, 192.168.2.1)  
    adblock[1586] info : shallalist (pre-)processing started ...  
    adblock[1586] info : source download finished (http://pgl.yoyo.org/adservers/serverlist.php?hostformat=one-line&showintro=0&mimetype=plaintext, 2432 entries)  
    adblock[1586] info : domain merging finished (yoyo)  
    adblock[1586] info : source download finished (http://mirror1.malwaredomains.com/files/justdomains, 17368 entries)  
    adblock[1586] info : domain merging finished (malware)  
    adblock[1586] info : source download finished (https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist, 440 entries)  
    adblock[1586] info : domain merging finished (zeus)  
    adblock[1586] info : no online timestamp received, current date will be used (feodo)  
    adblock[1586] info : source download finished (https://feodotracker.abuse.ch/blocklist/?download=domainblocklist, 0 entries)  
    adblock[1586] info : empty domain input received (feodo)  
    adblock[1586] info : no online timestamp received, current date will be used (palevo)  
    adblock[1586] info : source download finished (https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist, 16 entries)  
    adblock[1586] info : domain merging finished (palevo)  
    adblock[1586] info : source download finished (http://www.dshield.org/feeds/suspiciousdomains_Low.txt, 4542 entries)  
    adblock[1586] info : domain merging finished (dshield)  
    adblock[1586] info : source download finished (http://spam404bl.com/spam404scamlist.txt, 5193 entries)  
    adblock[1586] info : domain merging finished (spam404)  
    adblock[1586] info : source download finished (http://winhelp2002.mvps.org/hosts.txt, 13635 entries)  
    adblock[1586] info : domain merging finished (winhelp)  
    adblock[1586] info : source download finished (https://adaway.org/hosts.txt, 410 entries)  
    adblock[1586] info : domain merging finished (adaway)  
    adblock[1586] info : source download finished (https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt, 6343 entries)  
    adblock[1586] info : domain merging finished (disconnect)  
    adblock[1586] info : source download finished (file:////tmp/tmp.FIhIBh/shallalist.txt, 32458 entries)  
    adblock[1586] info : domain merging finished (shalla)  
    adblock[1586] info : source download finished (file:///etc/adblock/adblock.blacklist, 1 entries)  
    adblock[1586] info : domain merging finished (blacklist)  
    adblock[1586] info : remove duplicates in separate adblocklists ...  
    adblock[1586] info : adblocklists with overall 71552 domains loaded, new backups generated  
    adblock[1586] info : new domain query log background process started (pid: 2416)  
    adblock[1586] info : domain adblock processing finished (0.40.0, r47670, 17.12.2015 10:52:47)  
    

  domain blocklist for dnsmasq (disconnect.me after overall duplicate removal):  
    
    address=/0000mps.webpreview.dsl.net/192.168.2.1  
    address=/0001.2waky.com/192.168.2.1  
    address=/001wen.com/192.168.2.1  
    address=/002it.com/192.168.2.1  
    address=/00game.net/192.168.2.1  
    [...]  
    address=/zzsgssxh.com/192.168.2.1  
    address=/zzshw.net/192.168.2.1  
    address=/zztxdown.com/192.168.2.1  
    address=/zzxcws.com/192.168.2.1  
    #------------------------------------------------------------------  
    # adblock-update.sh (0.40.0) - 3710 ad/abuse domains blocked  
    # source: https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt  
    # last modified: Thu, 17 Dec 2015 09:21:17 GMT  
    

  domain query log excerpt:  
    
    query[A] www.seenby.de from fe80::6257:18ff:fe6b:4667  
    query[A] tarifrechner.heise.de from 192.168.1.131  
    query[A] www.mittelstandswiki.de from fe80::6257:18ff:fe6b:4667  
    query[A] ad.doubleclick.net from 192.168.1.131  
    ad.doubleclick.net is 192.168.2.1  
    

The first three queries are OK (not blocked), the last one has been blocked and answered by local dnsmasq instance.

Have fun!  
Dirk  
