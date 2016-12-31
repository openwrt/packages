# dns based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other wlan gadget...getting rid of annoying ads, trackers and other abuse sites (like facebook ;-) is simple: block them with your router. When the dns server on your router receives dns requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the dns server, a condition called the 'NXDOMAIN' occurred.  

## Main Features
* support of the following domain block list sources (free for private usage, for commercial use please check their individual licenses):
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
* zero-conf like automatic installation & setup, usually no manual changes needed
* simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* supports a wide range of router modes, even AP modes are supported
* full IPv4 and IPv6 support
* each block list source will be updated and processed separately
* block list source parsing by fast & flexible regex rulesets
* overall duplicate removal in separate block lists
* additional whitelist for manual overrides, located by default in /etc/adblock/adblock.whitelist
* quality checks during block list update to ensure a reliable dns server service
* minimal status & error logging to syslog, enable debug logging to receive more output
* procd based init system support (start/stop/restart/reload/suspend/resume)
* procd based hotplug support, the adblock start will be triggered by interface triggers
* suspend & resume adblock actions temporarily without block list reloading
* runtime statistics via ubus service call
* query function to quickly identify blocked (sub-)domains, i.e. for whitelisting
* automatic block list backup & restore, backups will be (de-)compressed and restored on the fly
* add new adblock sources on your own via uci config

## Prerequisites
* [openwrt](https://openwrt.org), tested with latest stable release (Chaos Calmer) and with current trunk (Designated Driver)
* [LEDE project](https://www.lede-project.org), tested with trunk > r98
* a usual setup with an enabled dns server at minimum - dump AP modes without a working dns server are _not_ supported
* a download utility: 'wget', 'aria2c', 'uclient-fetch' or 'curl' are supported (only full versions with ssl support). Normally you should use the pre-configured default 'wget'. If you need a smaller memory footprint try 'uclient-fetch' without openssl dependency. The default ustream ssl backend 'libustream-polarssl' has issues with certain https sites and is currently not supported. To change the ssl backend see example below.

## OpenWrt / LEDE trunk Installation & Usage
* install 'adblock' (_opkg install adblock_) and that's it - the adblock start will be automatically triggered by procd interface triggers
* start/stop/restart/reload/suspend/resume the adblock service manually with _/etc/init.d/adblock_
* enable/disable your favored block list sources in _/etc/config/adblock_ - 'adaway', 'disconnect' and 'yoyo' are enabled by default

## LuCI adblock companion package
* for easy management of the various block list sources and options you can also use a nice & efficient LuCI frontend
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
* **status/runtime statistics:** the adblock status and runtime statistics are available via ubus service call (see example below)
* **debug output:** for script debugging please set the config option 'adb\_debug' to '1' and check the runtime output with _logread -e "adblock"_
* **storage expansion:** to process and store all block list sources at once it might helpful to enlarge your temp directory with a swap partition => see [openwrt wiki](https://wiki.openwrt.org/doc/uci/fstab) for further details
* **add white-/blacklist entries:** add domain white- or blacklist entries to always-allow or -deny certain (sub) domains, by default both lists are empty and located in _/etc/adblock_. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below)
* **backup & restore block lists:** enable this feature, to restore automatically the latest compressed backup of your block lists in case of any processing error (i.e. a single block list source is not available during update). Please use an (external) solid partition and _not_ your volatile router temp directory for this
* **scheduled list updates:** for a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **restrict/disable procd interface trigger:** to restrict the procd interface trigger to a (list of) certain wan interface(s) or to disable it at all, set 'adb\_iface' to an existing interface like 'wan' or to a non-existing like 'false'
* **suspend & resume adblocking:** to quickly switch the adblock service 'on' or 'off', simply use _/etc/init.d/adblock [suspend|resume]_
* **domain query:** to query the active block lists for a specific domain, please run _/etc/init.d/adblock query `<DOMAIN>`_ (see example below)
* **divert dns requests:** to force dns requests to your local dns resolver add an appropriate firewall rule (see example below)
* **add new list sources:** you could add new block list sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)
* **disable active dns probing in windows 10:** to prevent a yellow exclamation mark on your internet connection icon (which wrongly means connected, but no internet), please change the following registry key/value from "1" to "0" _HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\EnableActiveProbing_

## Further adblock config options
* usually the pre-configured adblock setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' config section:
    * adb\_enabled => main switch to enable/disable adblock service (default: '1', enabled)
    * adb\_debug => enable/disable adblock debug output (default: '0', disabled)
    * adb\_iface => restrict the procd interface trigger to a (list of) certain wan interface(s) or disable it at all (default: not set, disabled)
    * adb\_fetch => reference an alternate download utility, see example below (default: not set, use wget)
    * adb\_fetchparm => set options for the download utility, see example below (default: not set, use wget options)

## Examples

**example to change the ssl backend for 'uclient-fetch' or 'curl':**
<pre><code>
opkg update
opkg remove --force-depends libustream-polarssl
opkg install libustream-mbedtls
</code></pre>
  
**example configuration for different download utilities:**
<pre><code>
config for wget (default):
  option adb_fetch="/usr/bin/wget"
  option adb_fetchparm="--no-config --quiet --tries=1 --no-cache --no-cookies --max-redirect=0 --timeout=5 --no-check-certificate -O"

config for aria2c:
  option adb_fetch '/usr/bin/aria2c'
  option adb_fetchparm '-q --max-tries=1 --timeout=5 --allow-overwrite=true --auto-file-renaming=false --check-certificate=false -o'

config for uclient-fetch (download errors with default ssl backend!):
  option adb_fetch '/bin/uclient-fetch'
  option adb_fetchparm '-q --timeout=5 --no-check-certificate -O'

config for curl (download errors with default ssl backend!):
  option adb_fetch '/usr/bin/curl'
  option adb_fetchparm '-s --retry 1 --connect-timeout 5 --insecure -o'
</code></pre>
  
**example to receive adblock statistics via ubus:**
<pre><code>
ubus call service list '{"name":"adblock_stats"}'
This will output the active block lists, the overall domain count and the last runtime as JSON, i.e.:
{
    "adblock_stats": {
        "instances": {
            "stats": {
                "running": false,
                "command": [
                    ""
                ],
                "data": {
                    "active_lists": [
                        {
                            "palevo": "14",
                            "blacklist": "143",
                            "winspy": "164",
                            "zeus": "446",
                            "rolist": "644",
                            "malwarelist": "1218",
                            "openphish": "1515",
                            "ransomware": "1463",
                            "ruadlist": "1773",
                            "yoyo": "2320",
                            "dshield": "123",
                            "disconnect": "3181",
                            "spam404": "6155",
                            "malware": "9882",
                            "whocares": "11825",
                            "winhelp": "10917",
                            "sysctl": "8529",
                            "securemecca": "9919",
                            "shalla": "25779",
                            "hphosts": "37111"
                        }
                    ],
                    "blocked_domains": "133121",
                    "last_rundate": "31.12.2016 07:19:25",
                    "system": "LEDE Reboot SNAPSHOT r2709-b7677f05d6"
                }
            }
        }
    }
}
</code></pre>
  
**example cronjob for a regular block list update (/etc/crontabs/root):**
<pre><code>
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

This entry removes the following (sub)domains from the block lists:
  maps.here.com
  here.com

This entry does not remove:
  where.com
  www.adwhere.com
</code></pre>
  
**example to query active block lists for a certain (sub-)domain, i.e. for whitelisting:**
<pre><code>
/etc/init.d/adblock query "example.www.doubleclick.net"
:: distinct results for domain 'example.www.doubleclick.net' (overall 0)
   no matches in active block lists
:: distinct results for domain 'www.doubleclick.net' (overall 1)
   adb_list.securemecca : www.doubleclick.net
:: distinct results for domain 'doubleclick.net' (overall 127)
   adb_list.adaway      : ad-g.doubleclick.net
   adb_list.securemecca : 1168945.fls.doubleclick.net

The query function checks against the submitted (sub-)domain and recurses automatically to the upper top level domain(s).
For every domain it returns the overall count plus a distinct list of active block lists with the first relevant result.
In the example above whitelist "www.doubleclick.net" to free the submitted domain.
</code></pre>
  
**example to divert dns requests to local dns resolver (/etc/config/firewall):**
<pre><code>
config redirect
    option name 'Divert DNS'
    option src 'lan'
    option proto 'tcp udp'
    option src_dport '53'
    option dest_port '53'
    option target 'DNAT'
</code></pre>
  
**example to add a new block list source:**
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
Please join the adblock discussion in this [forum thread](https://forum.openwrt.org/viewtopic.php?id=59803) or contact me by mail <dev@brenken.org>  

## Removal
* stop all adblock related services with _/etc/init.d/adblock stop_
* optional: remove the adblock package (_opkg remove adblock_)

Have fun!  
Dirk  
