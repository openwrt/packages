# dns based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router. When the dns server on your router receives dns requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the dns server, a condition called the 'NXDOMAIN' occurred.  

## Main Features
* support of the following domain block list sources (free for private usage, for commercial use please check their individual licenses):
    * [adaway](https://adaway.org)
    * => infrequent updates, approx. 400 entries (enabled by default)
    * [adguard](https://adguard.com)
    * => numerous updates on the same day, approx. 12.000 entries
    * [blacklist]()
    * => static local blacklist, located by default in '/etc/adblock/adblock.blacklist'
    * [disconnect](https://disconnect.me)
    * => numerous updates on the same day, approx. 6.500 entries (enabled by default)
    * [dshield](http://dshield.org)
    * => daily updates, approx. 4.500 entries
    * [feodotracker](https://feodotracker.abuse.ch)
    * => daily updates, approx. 0-10 entries
    * [hphosts](https://hosts-file.net)
    * => monthly updates, approx. 50.000 entries
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
    * [reg_cn](https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt)
    * => regional blocklist for China, daily updates, approx. 1.600 entries
    * [reg_pl](http://adblocklist.org)
    * => regional blocklist for Poland, daily updates, approx. 50 entries
    * [reg_ro](https://easylist-downloads.adblockplus.org/rolist+easylist.txt)
    * => regional blocklist for Romania, weekly updates, approx. 600 entries
    * [reg_ru](https://code.google.com/p/ruadlist)
    * => regional blocklist for Russia, weekly updates, approx. 2.000 entries
    * [securemecca](http://www.securemecca.com)
    * => infrequent updates, approx. 25.000 entries
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
    * [winspy](https://github.com/crazy-max/WindowsSpyBlocker)
    * => infrequent updates, approx. 120 entries
    * [yoyo](http://pgl.yoyo.org/adservers)
    * => weekly updates, approx. 2.500 entries (enabled by default)
    * [zeus tracker](https://zeustracker.abuse.ch)
    * => daily updates, approx. 440 entries
* zero-conf like automatic installation & setup, usually no manual changes needed
* simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* automatically selects dnsmasq or unbound as dns backend
* automatically selects uclient-fetch or wget as download utility (other tools like curl or aria2c are supported as well)
* support http only mode (without installed ssl library) for all non-SSL blocklist sources
* automatically supports a wide range of router modes, even AP modes are supported
* full IPv4 and IPv6 support
* supports tld compression (top level domain compression), this feature removes thousands of needless host entries from the block lists and lowers the memory footprint for the dns backends
* each block list source will be updated and processed separately
* block list source parsing by fast & flexible regex rulesets
* overall duplicate removal in separate block lists
* additional whitelist for manual overrides, located by default in /etc/adblock/adblock.whitelist
* quality checks during block list update to ensure a reliable dns backend service
* minimal status & error logging to syslog, enable debug logging to receive more output
* procd based init system support (start/stop/restart/reload/suspend/resume/query/status)
* procd based hotplug support, the adblock start will be solely triggered by network interface triggers
* suspend & resume adblock actions temporarily without block list reloading
* runtime information available via LuCI & via 'status' init command
* query function to quickly identify blocked (sub-)domains, e.g. for whitelisting
* optional: force dns requests to local resolver
* optional: force overall sort / duplicate removal for low memory devices (handle with care!)
* optional: automatic block list backup & restore, backups will be (de-)compressed and restored on the fly in case of any runtime error
* optional: add new adblock sources on your own via uci config

## Prerequisites
* [LEDE project](https://www.lede-project.org), tested with latest stable release (LEDE 17.01) and with current LEDE snapshot
* a usual setup with an enabled dns backend at minimum - dump AP modes without a working dns backend are _not_ supported
* a download utility:
    * to support all blocklist sources a full version (with ssl support) of 'wget', 'uclient-fetch' with one of the 'libustream-*' ssl libraries, 'aria2c' or 'curl' is required
    * for limited devices with real memory constraints, adblock provides also a plain http option and supports wget-nossl and uclient-fetch (without libustream-ssl), too
    * for more configuration options see examples below

## LEDE trunk Installation & Usage
* install 'adblock' (_opkg install adblock_) and that's it - the adblock start will be automatically triggered by procd interface trigger
* control the adblock service manually with _/etc/init.d/adblock_ start/stop/restart/reload/suspend/resume/status or use the LuCI frontend
* enable/disable your favored block list sources in _/etc/config/adblock_ - 'adaway', 'disconnect' and 'yoyo' are enabled by default

## LuCI adblock companion package
* for easy management of the various block list sources and all other adblock options you can also use a nice & efficient LuCI frontend
* install 'luci-app-adblock' (_opkg install luci-app-adblock_)
* the application is located in LuCI under 'Services' menu

## Tweaks
* **runtime information:** the adblock status is available via _/etc/init.d/adblock status_ (see example below)
* **debug logging:** for script debugging please set the config option 'adb\_debug' to '1' and check the runtime output with _logread -e "adblock"_
* **storage expansion:** to process and store all block list sources at once it might helpful to enlarge your temp directory with a swap partition => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* **add white- / blacklist entries:** add domain white- or blacklist entries to always-allow or -deny certain (sub) domains, by default both lists are empty and located in _/etc/adblock_. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below)
* **backup & restore block lists:** enable this feature, to restore automatically the latest compressed backup of your block lists in case of any processing error (e.g. a single block list source is not available during update). Please use an (external) solid partition and _not_ your volatile router temp directory for this
* **scheduled list updates:** for a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **restrict procd interface trigger:** restrict the procd interface trigger to a (list of) certain interface(s) (default: wan). To disable it at all, remove all entries
* **suspend & resume adblocking:** to quickly switch the adblock service 'on' or 'off', simply use _/etc/init.d/adblock [suspend|resume]_
* **domain query:** to query the active block lists for a specific domain, please run _/etc/init.d/adblock query `<DOMAIN>`_ (see example below)
* **add new list sources:** you could add new block list sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)
* **disable active dns probing in windows 10:** to prevent a yellow exclamation mark on your internet connection icon (which wrongly means connected, but no internet), please change the following registry key/value from "1" to "0" _HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\EnableActiveProbing_

## Further adblock config options
* usually the pre-configured adblock setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' config section:
    * adb\_enabled => main switch to enable/disable adblock service (default: '1', enabled)
    * adb\_debug => enable/disable adblock debug output (default: '0', disabled)
    * adb\_iface => set the procd interface trigger to a (list of) lan / wan interface(s) (default: 'wan')
    * adb\_fetch => full path to a different download utility, see example below (default: not set, use wget)
    * adb\_fetchparm => options for the download utility, see example below (default: not set, use wget options)
    * adb\_triggerdelay => additional trigger delay in seconds before adblock processing starts (default: '2')
    * adb\_forcedns => force dns requests to local resolver (default: '0', disabled)
    * adb\_forcesrt => force overall sort on low memory devices with less than 64 MB RAM (default: '0', disabled)

## Examples
**change default dns backend to 'unbound':**
<pre><code>
Adblock detects the presence of an active unbound dns backend and the block lists will be automatically pulled in by unbound.
The adblock script deposits the sorted and filtered block lists in '/var/lib/unbound' where unbound can find them in its jail.
If you use manual configuration for unbound, then just include the following line in your 'server:' clause:

  include: "/var/lib/unbound/adb_list.*"
</code></pre>
  
**configuration for different download utilities:**
<pre><code>
wget (default):
  option adb_fetch="/usr/bin/wget"
  option adb_fetchparm="--no-config --quiet --no-cache --no-cookies --max-redirect=0 --timeout=10 --no-check-certificate -O"

aria2c:
  option adb_fetch '/usr/bin/aria2c'
  option adb_fetchparm '-q --timeout=10 --allow-overwrite=true --auto-file-renaming=false --check-certificate=false -o'

uclient-fetch:
  option adb_fetch '/bin/uclient-fetch'
  option adb_fetchparm '-q --timeout=10 --no-check-certificate -O'

curl:
  option adb_fetch '/usr/bin/curl'
  option adb_fetchparm '-s --connect-timeout 10 --insecure -o'
</code></pre>
  
**receive adblock runtime information:**
<pre><code>
root@blackhole:~# /etc/init.d/adblock status
::: adblock runtime information
 status          : active
 adblock_version : 2.6.0
 blocked_domains : 113711
 fetch_info      : wget (built-in)
 dns_backend     : dnsmasq
 last_rundate    : 12.04.2017 13:08:26
 system          : LEDE Reboot SNAPSHOT r3900-399d5cf532
</code></pre>
  
**cronjob for a regular block list update (/etc/crontabs/root):**
<pre><code>
0 06 * * *    /etc/init.d/adblock start
</code></pre>
  
**blacklist entry (/etc/adblock/adblock.blacklist):**
<pre><code>
ads.example.com

This entry blocks the following (sub)domains:
  http://ads.example.com/foo.gif
  http://server1.ads.example.com/foo.gif
  https://ads.example.com:8000/

This entry does not block:
  http://ads.example.com.ua/foo.gif
  http://example.com/
</code></pre>
  
**whitelist entry (/etc/adblock/adblock.whitelist):**
<pre><code>
here.com

This entry removes the following (sub)domains from the block lists:
  maps.here.com
  here.com

This entry does not remove:
  where.com
  www.adwhere.com
</code></pre>
  
**query active block lists for a certain (sub-)domain, e.g. for whitelisting:**
<pre><code>
/etc/init.d/adblock query example.www.doubleclick.net
::: distinct results for domain 'example.www.doubleclick.net'
 no match
::: distinct results for domain 'www.doubleclick.net'
 adb_list.sysctl      : www.doubleclick.net
::: distinct results for domain 'doubleclick.net'
 adb_list.adaway      : ad-g.doubleclick.net
 adb_list.securemecca : 1168945.fls.doubleclick.net
 adb_list.sysctl      : 1435575.fls.doubleclick.net
 adb_list.whocares    : 3ad.doubleclick.net

The query function checks against the submitted (sub-)domain and recurses automatically to the upper top level domain(s).
For every domain it returns the overall count plus a distinct list of active block lists with the first relevant result.
In the example above whitelist "www.doubleclick.net" to free the submitted domain.
</code></pre>
  
**add a new block list source:**
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
  
## Support
Please join the adblock discussion in this [forum thread](https://forum.lede-project.org/t/adblock-2-x-support-thread/507) or contact me by mail <dev@brenken.org>  

## Removal
* stop all adblock related services with _/etc/init.d/adblock stop_
* optional: remove the adblock package (_opkg remove adblock_)

Have fun!  
Dirk  
