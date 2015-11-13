# adblock script for openwrt

## Description
A lot of people already use adblocker plugins within their desktop browsers,  
but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...  
...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router.  

When the dns server on your router receives dns requests, you’ll sort out queries that ask for the [A] resource records of ad servers  
and return the local ip address of your router and the internal web server delivers a transparent pixel instead.

## Main Features
* support of the following domain blacklist sites (free for private usage, for commercial use please check their individual licenses):
    * [pgl.yoyo.org](http://pgl.yoyo.org/adservers)
    * [malwaredomains.com](http://malwaredomains.com)
    * [zeustracker.abuse.ch](https://zeustracker.abuse.ch)
    * [feodotracker.abuse.ch](https://feodotracker.abuse.ch)
    * [palevotracker.abuse.ch](https://palevotracker.abuse.ch)
    * [dshield.org](http://dshield.org)
    * [shallalist.de](http://www.shallalist.de) (tested with the categories "adv" "costtraps" "downloads" "spyware" "tracker" "warez")
    * [spam404.com](http://www.spam404.com)
    * [winhelp2002.mvps.org](http://winhelp2002.mvps.org)
* blocklist parsing by fast & flexible regex rulesets
* additional white- and blacklist support for manual overrides
* separate dynamic adblock network interface
* separate dynamic uhttpd instance as pixel server
* optional: quality checks and a powerful backup/restore handling to ensure a reliable dnsmasq service
* optional: adblock updates only on pre-defined wan interfaces
* optional: domain query logging as a background service to easily identify free and already blocked domains
* optional: ntp time sync
* optional: status & error logging (req. ntp time sync)

## Prerequisites
* [openwrt](https://openwrt.org) (tested only with trunk > r47025), CC should also work
* additional software packages:
    * curl
    * wget (due to an openwrt bug still needed for certain https requests - see ticket #19621)
    * busybox find with *-mtime* support for logfile housekeeping (enabled by default with r47362, will be disabled if not found)
* optional: mounted usb stick or any other storage device to overcome limited memory resources on embedded router devices
* the above dependencies will be checked during package installation & script runtime, please check *logread -e "adblock"* for errors

## Usage
* select & install adblock package (*opkg install adblock*)
* configure /etc/config/adblock to your needs
* start /usr/bin/adblock-update.sh and check *logread -e "adblock"* for errors

## Distributed samples
* all sample configuration files stored in */etc/adblock/samples*.
* to enable/disable additional domain query logging set the dnsmasq option *logqueries* accordingly, see *dhcp.config.sample*.
* for script autostart by rc.local and /tmp resizing on the fly see *rc.local.sample*.
* for scheduled call of *adblock-update.sh* see *root.crontab.sample*.
* to redirect/force all dns queries to your router see *firwall.user.sample*.
* for further dnsmasq tweaks see *dnsmasq.conf.sample*.

Have fun!  
Dirk  
