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
    * [rolist/easylist](https://easylist-downloads.adblockplus.org/rolist+easylist.txt)
    * => weekly updates, approx. 600 entries
    * [ruadlist/easylist](https://code.google.com/p/ruadlist)
    * => weekly updates, approx. 2.000 entries
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
* zero-conf like automatic installation & setup, usually no manual changes needed (i.e. ip address, network devices etc.)
* supports a wide range of router modes (incl. AP mode), as long as firewall and dnsmasq are installed and in use
* full IPv4 and IPv6 support
* each blocklist source will be updated and processed separately
* timestamp check to download and process only updated adblock list sources
* overall duplicate removal in separate adblock lists (will be automatically disabled on low memory systems)
* adblock source list parsing by fast & flexible regex rulesets
* additional whitelist for manual overrides, located by default in /etc/adblock/adblock.whitelist
* quality checks during & after update of adblock lists to ensure a reliable dnsmasq service
* adblock statistics, last runtime and list states/counts/update times will be stored in uci config for LuCI frontend
* status & error logging to stdout and syslog
* use two dynamic uhttpd instances as adblock pixel server, separated for ads delivered on port 80 and on port 443
* use dynamic iptables chains/rulesets for adblock related redirects/rejects
* init system support (start/stop/restart/reload/toggle/stats/cfgup/envchk/query)
* hotplug support, the adblock start will be triggered by wan 'ifup' event, this can be restricted to a certain wan interface or disabled at all (see config options below)
* toggle to quickly switch adblock 'on' or 'off'
* envchk function to check the volatile adblock environment only (without list updates)
* query function to quickly identify blocked (sub-)domains, i.e. for whitelisting
* optional: automatic adblock list backup/restore, backups will be (de-)compressed on the fly (disabled by default)
* optional: add new adblock sources via uci config (see example below)

## Prerequisites
* [openwrt](https://openwrt.org), tested with latest stable release (Chaos Calmer) and with current trunk (Designated Driver)
* [LEDE project](https://www.lede-project.org), tested with trunk > r98
* usual setup with enabled 'iptables', 'dnsmasq' and 'uhttpd' - dump AP modes without these basics are _not_ supported!
* additional required software packages:
    * a download utility: 'uclient-fetch' and 'wget' (full versions with ssl support) are supported. Normally you should use 'wget', it's quite stable and supports the online timestamp checks. If you need a smaller memory footprint try 'uclient-fetch' without openssl dependency. The default ustream ssl backend 'libustream-polarssl' has issues with certain https sites and is currently not supported. To change the ssl backend see example below.
    * optional: 'kmod-ipt-nat6' for IPv6 support
* the above dependencies and requirements will be checked during package installation & script runtime

## OpenWrt / LEDE trunk Installation & Usage
* install 'adblock' (_opkg install adblock_)
* adblock starts automatically during boot, triggered by wan-ifup event, check _logread -e "adblock"_ for adblock related information
* optional: start/restart/stop the adblock service manually with _/etc/init.d/adblock_
* optional: enable/disable your required adblock list sources in _/etc/config/adblock_ - 'adaway', 'disconnect' and 'yoyo' are enabled by default
* optional: maintain the adblock service in LuCI under 'System => Startup'

## LuCI adblock companion package
* for easy management of the various blocklist sources and adblock options there is also a nice & efficient LuCI frontend available
* install 'luci-app-adblock' (_opkg install luci-app-adblock_)
* the application is located in LuCI under 'Services' menu
* _Thanks to Hannu Nyman for this great adblock LuCI frontend!_

## Chaos Calmer installation notes
* 'adblock' and 'luci-app-adblock' are _not_ available as .ipk packages in the Chaos Calmer download repository
* download both packages from a development snapshot package directory:
    * for 'adblock' look [here](https://downloads.lede-project.org/snapshots/packages/x86_64/packages/)
    * for 'luci-app-adblock' look [here](https://downloads.lede-project.org/snapshots/packages/x86_64/luci/)
* manually transfer the packages to your routers temp directory (with tools like _sshfs_ or _winscp_)
* install the packages with _opkg install <...>_ as described above

## Tweaks
* **storage:** to process & store all blocklist sources at once it might helpful to enlarge your temp directory with a swap partition => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* **white-/blacklist:** add domain white- or blacklist entries to always-allow or -deny certain (sub) domains, by default both lists are located in _/etc/adblock_. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below)
* **backup/restore:** enable the backup/restore feature, to restore automatically the latest compressed backup of your adblock lists in case of any processing error (i.e. a single blocklist source is down). Please use an (external) solid partition and _not_ your volatile router temp directory for this
* **list updates:** for a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **hotplug fine tuning:** to restrict hotplug support to a certain wan interface or to disable it at all, you can set 'adb\_hotplugif' to an existing interface like 'wan' or to a non-existing 'dummy' interface
* **new list sources:** you could add new blocklist sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)
* **AP mode:** in 'AP mode' adblock uses automatically the local router ip as nullip address. To make sure that your LuCI interface will be still accessible, you have to change the local uhttpd instance to ports <> 80/443 (see example below), also make sure that firewall and dnsmasq are installed and running
* **restricted mode:** to disable flash writes with adblock status information to the adblock config file (used by LuCI frontend), please set 'adb\_restricted' to '1'
* **adblock toggle:** to quickly switch adblocking 'on' or 'off', simply use _/etc/init.d/adblock toggle_
* **adblock statistics:** to update only the adblock statistics (without updating the block lists as well), please run _/etc/init.d/adblock stats_
* **adblock query `<DOMAIN>`:** to query the active blocklists for a specific domain, please run _/etc/init.d/adblock query `<DOMAIN>`_ (see example below)
* **configuration update:** to update an outdated adblock config file with the current default version, please run _/etc/init.d/adblock cfgup_, make your individual changes and start the adblock service again
* **debugging:** for script debugging please set the 'adb\_debug' variable in the header of _/etc/init.d/adblock_ to '1'
* **mute output** to mute the normal adblock output and print only warn/error messages, please set 'adb\_loglevel to '0'
* **disable active dns probing in windows:** to prevent a possible yellow exclamation mark on your internet connection icon (which wrongly means connected, but no internet), please change the following registry key/value from "1" to "0" _HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\EnableActiveProbing_

## Further adblock config options
* usually the adblock autodetection works quite well and no manual config overrides are needed, all options apply to the 'global' config section:
    * adb\_enabled => main switch to enable/disable adblock service (default: '1', enabled)
    * adb\_cfgver => config version string (do not change!) - adblock will check this entry during startup
    * adb\_lanif => name of the logical lan interface (default: 'lan')
    * adb\_nullport => port of the adblock uhttpd instance used for ads delivered on port 80 (default: '65534')
    * adb\_nullportssl => port of the adblock uhttpd instance used for ads delivered on port 443 (default: '65535')
    * adb\_nullipv4 => IPv4 blackhole ip address (default: '198.18.0.1', in AP mode: local router ip)
    * adb\_nullipv6 => IPv6 blackhole ip address (default: '::ffff:c612:0001', in AP mode: local router ip)
    * adb\_forcedns => redirect all local DNS queries to the local dnsmasq resolver (default: '1', enabled / always disabled in 'AP mode')
    * adb\_fetchttl => set the timeout for list downloads (default: '5' seconds)
    * adb\_restricted => disable updates of the adblock config file (no flash writes) during runtime (default: '0', disabled)
    * adb\_hotplugif => restrict hotplug support to a certain wan interface or disable it at all (default: '', disabled)
    * adb\_loglevel => set it to '0' to mute normal adblock output and print only error messages (default: '1', normal output)

## Examples

**example to change the ssl backend for 'uclient-fetch':**
<pre><code>
opkg update
opkg remove --force-depends libustream-polarssl
opkg install libustream-mbedtls
</code></pre>
  
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

This entry blocks the following (sub)domains:
  http://ads.example.com/foo.gif
  http://server1.ads.example.com/foo.gif
  https://ads.example.com:8000/

This entry does not block:
  http://ads.example.com.ua/foo.gif
  http://example.com/
</code></pre>
  
**example whitelist entry (/etc/adblock/adblock.whitelist):**
<pre><code>
here.com

This entry removes the following (sub)domains from the blocklists:
  maps.here.com
  here.com

This entry does not remove:
  where.com
  www.adwhere.com
</code></pre>
  
**example uhttpd configuration in AP mode:**
<pre><code>
# configuration found in /etc/config/uhttpd
# change default http/https ports <> 80/443
#
config uhttpd 'main'
    list listen_http '0.0.0.0:88'
    list listen_https '0.0.0.0:445'
</code></pre>
  
**example to query active blocklists for a certain (sub-)domain, i.e. for whitelisting:**
<pre><code>
/etc/init.d/adblock query "example.www.doubleclick.net"
=> distinct results for domain 'example.www.doubleclick.net' (overall 0)
   no matches in active blocklists
=> distinct results for domain 'www.doubleclick.net' (overall 1)
   adb_list.winhelp     : www.doubleclick.net
=> distinct results for domain 'doubleclick.net' (overall 252)
   adb_list.adaway      : ad-g.doubleclick.net
   adb_list.hphosts     : 1016557.fls.doubleclick.net
   adb_list.rolist      : feedads.g.doubleclick.net
   adb_list.securemecca : 1168945.fls.doubleclick.net
   adb_list.sysctl      : ad.co.doubleclick.net
   adb_list.whocares    : 3ad.doubleclick.net
   adb_list.winhelp     : 1435575.fls.doubleclick.net

The query function checks against the submitted (sub-)domain and recurses automatically to the upper top level domain(s).
For every domain it returns the overall count plus a distinct list of active blocklists with the first relevant result.
In the example above you have to whitelist "www.doubleclick.net" to free the submitted domain.
</code></pre>
  
**example to identify blocked domains during web browsing, i.e. for whitelisting:**
<pre><code>
1. the easy way ...
enable the network analysis builtins in chrome or firefox to identify domains
which are redirected to the adblock null-ip (default 198.18.0.1), add these domains to your whitelist

2. a bit harder ...
enable 'Log queries' in the dnsmasq configuration (via LuCI Network => DHCP/DNS),
ssh to your router and start tracing with 'logread -f -e "dnsmasq" -e "198.18.0.1"'
switch to your client, access the relevant site and check all domains
that are blocked/listed in logread, add these domains to your whitelist

=> finally restart the adblock service (/etc/init.d/adblock restart) in both variants
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
Queries to ad/abuse domains are never forwarded and always replied with a local IP address which may be IPv4 or IPv6. For that purpose adblock uses an ip address from the private 'Benchmark Test' subnet (198.18.0.1 / ::ffff:c612:0001) by default (in AP mode the local router ip address will be used). Furthermore all ad/abuse queries will be filtered by ip(6)tables and redirected to two uhttpd instances, separated for ads delivered on port 80 and on port 443 (in PREROUTING chain) or rejected (in FORWARD or OUTPUT chain). In 'AP mode' only the uhttpd related rules in PREROUTING chain are enabled.  
  
All iptables and uhttpd related adblock additions are non-destructive, no hard-coded changes in 'firewall.user', 'uhttpd' config or any other system related config files. There is _no_ adblock background daemon running, the (scheduled) start of the adblock service keeps only the adblock lists up-to-date.  

## Support
Please join the adblock discussion in this [openwrt forum thread](https://forum.openwrt.org/viewtopic.php?id=59803) or contact me by mail <dev@brenken.org>  

## Removal
* stop all adblock related services with _/etc/init.d/adblock stop_
* optional: remove the adblock package (_opkg remove adblock_)

Have fun!  
Dirk  
