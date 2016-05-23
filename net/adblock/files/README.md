# dns based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router. When the dns server on your router receives dns requests, you will sort out queries that ask for the resource records of ad servers and return the local ip address of your router and the internal web server delivers a transparent pixel instead.  

## Main Features
* support of the following domain blocklist sources (free for private usage, for commercial use please check their individual licenses):
    * [adaway](https://adaway.org)
    * => infrequent updates, approx. 400 entries (enabled by default)
    * [blacklist]()
    * => static local blacklist, located by default in '/etc/adblock/adblock.blacklist'
    * [disconnect](https://disconnect.me)
    * => numerous updates on the same day, approx. 6.500 entries (enabled by default)
    * [dshield](http://dshield.org)
    * => daily updates, approx. 4.500 entries
    * [feodotracker](https://feodotracker.abuse.ch)
    * => daily updates, approx. 0-10 entries
    * [malwaredomains](http://malwaredomains.com)
    * => daily updates, approx. 16.000 entries
    * [malwaredomainlist](http://www.malwaredomainlist.com)
    * => daily updates, approx. 1.500 entries
    * [openphish](https://openphish.com)
    * => numerous updates on the same day, approx. 1.800 entries
    * [palevo tracker](https://palevotracker.abuse.ch)
    * => daily updates, approx. 15 entries
    * [ransomware tracker](https://ransomwaretracker.abuse.ch)
    * => daily updates, approx. 150 entries
    * [rolist/easylist](https://easylist-downloads.adblockplus.org/rolist+easylist.txt)
    * => weekly updates, approx. 600 entries
    * [ruadlist/easylist](https://code.google.com/p/ruadlist)
    * => weekly updates, approx. 2.000 entries
    * [shallalist](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default)
    * => daily updates, approx. 32.000 entries (a short description of all shallalist categories can be found [online](http://www.shallalist.de/categories.html))
    * [spam404](http://www.spam404.com)
    * => infrequent updates, approx. 5.000 entries
    * [sysctl/cameleon](http://sysctl.org/cameleon)
    * => weekly updates, approx. 21.000 entries
    * [whocares](http://someonewhocares.org)
    * => weekly updates, approx. 12.000 entries
    * [winhelp](http://winhelp2002.mvps.org)
    * => infrequent updates, approx. 15.000 entries
    * [winspy](https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/hostsBlockWindowsSpy.txt)
    * => infrequent updates, approx. 120 entries
    * [yoyo](http://pgl.yoyo.org/adservers)
    * => weekly updates, approx. 2.500 entries (enabled by default)
    * [zeus tracker](https://zeustracker.abuse.ch)
    * => daily updates, approx. 440 entries
* zero-conf like automatic installation & setup, usually no manual changes needed (i.e. ip address, network devices etc.)
* supports a wide range of router modes (incl. AP mode), as long as the firewall and the DNS server are enabled
* full IPv4 and IPv6 support
* each blocklist source will be updated and processed separately
* timestamp check to download and process only updated adblock list sources
* overall duplicate removal in separate adblock lists (will be automatically disabled on low memory systems)
* adblock source list parsing by fast & flexible regex rulesets
* additional whitelist for manual overrides, located by default in /etc/adblock/adblock.whitelist
* quality checks during & after update of adblock lists to ensure a reliable dnsmasq service
* basic adblock statistics via iptables packet counters
* list states, (overall) list counts & last update time will be stored in uci config
* status & error logging to stdout and syslog
* use a dynamic uhttpd instance as an adblock pixel server
* use dynamic iptables rulesets for adblock related redirects/rejects
* openwrt init system support (start/stop/restart/reload)
* hotplug support, the adblock start will be triggered by wan 'ifup' event
* optional: automatic adblock list backup/restore, backups will be (de-)compressed on the fly (disabled by default)
* optional: add new adblock sources via uci config (see example below)

## Prerequisites
* [openwrt](https://openwrt.org), tested with latest stable release (Chaos Calmer) and with current trunk (Designated Driver)
* [LEDE project](https://www.lede-project.org), tested with trunk > r98
* usual setup with enabled 'iptables', 'dnsmasq' and 'uhttpd' - dump AP modes without these basics are _not_ supported!
* additional required software packages:
    * wget
    * optional: 'kmod-ipt-nat6' for IPv6 support
* the above dependencies and requirements will be checked during package installation & script runtime

## OpenWrt / LEDE trunk Installation & Usage
* install 'adblock' (_opkg install adblock_)
* adblock starts automatically during boot, triggered by wan-ifup event, check _logread -e "adblock"_ for adblock related information
* optional: start/restart/stop the adblock service manually with _/etc/init.d/adblock_
* optional: enable/disable your required adblock list sources in _/etc/config/adblock_ - 'adaway', 'disconnect' and 'yoyo' are enabled by default
* optional: maintain the adblock service in luci under 'System => Startup'

## LuCI adblock companion package
* for easy management of the various blocklist sources and adblock options there is also a nice & efficient LuCI frontend available
* install 'luci-app-adblock' (_opkg install luci-app-adblock_)
* the application is located in LuCI under 'Services' menu
* _Thanks to Hannu Nyman for this great adblock LuCI frontend!_

## Chaos Calmer installation notes
* 'adblock' and 'luci-app-adblock' are _not_ available as .ipk packages in the Chaos Calmer download repository
* download both packages from a development snapshot package directory:
    * for 'adblock' look [here](https://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/packages/packages/)
    * for 'luci-app-adblock' look [here](https://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/packages/luci/)
* manually transfer the packages to your routers temp directory (with tools like _sshfs_ or _winscp_)
* install the packages with _opkg install <...>_ as described above

## Tweaks
* **storage:** to process & store all blocklist sources at once it might helpful to enlarge your temp directory with a swap partition => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* **white-/blacklist:** add domain white- or blacklist entries to always-allow or -deny certain (sub) domains, by default both lists are located in _/etc/adblock_. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below)
* **backup/restore:** enable the backup/restore feature, to restore automatically the latest compressed backup of your adblock lists in case of any processing error (i.e. a single blocklist source is down). Please use an (external) solid partition and _not_ your volatile router temp directory for this
* **list updates:** for a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **new list sources:** you could add new blocklist sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)
* **AP mode:** in AP mode adblock uses automatically the local router ip as nullip address. To make sure that your LuCI interface will be still accessible, please change the local uhttpd instance to ports <> 80/443 (see example below)
* **debugging:** for script debugging please change the 'DEBUG' variable in the header of _/usr/bin/adblock-update.sh_ from '0' to '1' and start this script directly (without any parameters)

## Further adblock config options
* usually the adblock autodetection works quite well and no manual config overrides are needed, all options apply to the 'global' config section:
    * adb\_enabled => main switch to enable/disable adblock service (default: '1', enabled)
    * adb\_cfgver => config version string (do not change!) - adblock will check this entry during startup
    * adb\_lanif => name of the logical lan interface (default: 'lan')
    * adb\_nullport => port of the adblock uhttpd instance (default: '65535')
    * adb\_nullipv4 => IPv4 blackhole ip address (default: '192.0.2.1', in AP mode: local router ip)
    * adb\_nullipv6 => IPv6 blackhole ip address (default: '::ffff:c000:0201', in AP mode: local router ip)
    * adb\_forcedns => redirect all DNS queries to local dnsmasq resolver (default: '1', enabled)

## Examples

**example cronjob for a regular block list update:**
<pre><code>
# configuration found in /etc/crontabs/root
# start adblock script once a day at 6 a.m.
#
0 06 * * *    /etc/init.d/adblock start
</code></pre>
  
**example blacklist entry (/etc/adblock/adblock.blacklist):**
<pre><code>
ads.example.com
</code></pre>
  
This rule blocks:  
http://ads.example.com/foo.gif  
http://server1.ads.example.com/foo.gif  
https://ads.example.com:8000/  
  
This rule doesn't block:  
http://ads.example.com.ua/foo.gif  
http://example.com/  
  
**example whitelist entry (/etc/adblock/adblock.whitelist):**
<pre><code>
analytics.com
</code></pre>
  
This rule removes _all_ domains from the blocklists with this string in it, i.e.:  
  google-analytics.com  
  ssl.google-analytics.com  
  api.gameanalytics.com  
  photos.daily-deals.analoganalytics.com  
  adblockanalytics.com  
  
**example uhttpd configuration in AP mode:**
<pre><code>
# configuration found in /etc/config/uhttpd
# change default http/https ports <> 80/443
#
config uhttpd 'main'
    list listen_http '0.0.0.0:88'
    list listen_https '0.0.0.0:445'
</code></pre>
  
**example to add a new blocklist source:**
<pre><code>
1. the easy way ...
example: https://easylist-downloads.adblockplus.org/rolist+easylist.txt
adblock already supports an easylist source, called 'ruadlist'. To add the additional local easylist
as a new source, copy the existing config source 'ruadlist' section and change only 
the source name, the url and the description - that's all!

config source 'rolist'
  option enabled '0'
  option adb_src 'https://easylist-downloads.adblockplus.org/rolist+easylist.txt'
  option adb_src_rset '{FS=\"[|^]\"} \$0 ~/^\|\|([A-Za-z0-9_-]+\.){1,}[A-Za-z]+\^$/{print tolower(\$3)}'
  option adb_src_desc 'focus on romanian ad related domains plus generic easylist additions, weekly updates, approx. 600 entries'

2. a bit harder ...
to add a really new source with different domain/host format you have to write a suitable
awk one-liner on your own, so basic awk skills are needed. As a starting point check the already
existing awk strings (adb_src_rset) in adblock config, maybe you need only small changes for your individual list.
Download the desired list and test your new awk string locally with:
  cat new.list | awk 'fs__individual search__search core__result'
  'fs' => field separator (optional)
  'individual search' => individual search part to filter out needless list information
  'search core' => always '([A-Za-z0-9_-]+\.){1,}[A-Za-z]+', this is part of all list sources and should be unchanged
  'result' => always '{print tolower(\$n)}', only the output column 'n' may vary
the output result should be a sequential list with one domain/host per line - nothing more.

If your awk one-liner works quite well, add a new source section in adblock config and test your new source
</code></pre>
  
## Background
This adblock package is a dns/dnsmasq based adblock solution.  
Queries to ad/abuse domains are never forwarded and always replied with a local IP address which may be IPv4 or IPv6.  
For that purpose adblock uses an ip address from the private 'TEST-NET-1' subnet (192.0.2.1 / ::ffff:c000:0201) by default (in AP mode the local router ip address will be used).  
Furthermore all ad/abuse queries will be filtered by ip(6)tables and redirected to internal adblock pixel server (in PREROUTING chain) or rejected (in FORWARD or OUTPUT chain).  
All iptables and uhttpd related adblock additions are non-destructive, no hard-coded changes in 'firewall.user', 'uhttpd' config or any other openwrt related config files. There is _no_ adblock background daemon running, the (scheduled) start of the adblock service keeps only the adblock lists up-to-date.  

## Support
Please join the adblock discussion in this [openwrt forum thread](https://forum.openwrt.org/viewtopic.php?id=59803) or contact me by mail <dev@brenken.org>  

## Removal
* stop all adblock related services with _/etc/init.d/adblock stop_
* optional: remove the adblock package (_opkg remove adblock_)

Have fun!  
Dirk  
