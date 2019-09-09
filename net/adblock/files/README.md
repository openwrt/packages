# dns based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other (wlan) gadget!? Getting rid of annoying ads, trackers and other abuse sites (like facebook) is simple: block them with your router. When the dns server on your router receives dns requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the dns server, a condition called the 'NXDOMAIN' occurred.  

## Main Features
* support of the following domain blocklist sources (free for private usage, for commercial use please check their individual licenses):
    * [adaway](https://adaway.org)
    * => infrequent updates, approx. 400 entries (enabled by default)
    * [adguard](https://adguard.com)
    * => numerous updates on the same day, approx. 12.000 entries
    * [bitcoin](https://github.com/hoshsadiq/adblock-nocoin-list)
    * => infrequent updates, approx. 15 entries
    * [blacklist]()
    * => static local blacklist, located by default in '/etc/adblock/adblock.blacklist'
    * [disconnect](https://disconnect.me)
    * => numerous updates on the same day, approx. 6.500 entries (enabled by default)
    * [dshield](http://dshield.org)
    * => daily updates, approx. 4.500 entries
    * [hphosts](https://hosts-file.net)
    * => monthly updates, approx. 50.000 entries
    * [malwaredomains](http://malwaredomains.com)
    * => daily updates, approx. 16.000 entries
    * [malwaredomainlist](http://www.malwaredomainlist.com)
    * => daily updates, approx. 1.500 entries
    * [openphish](https://openphish.com)
    * => numerous updates on the same day, approx. 1.800 entries
    * [ransomware tracker](https://ransomwaretracker.abuse.ch)
    * => daily updates, approx. 150 entries
    * [reg_cn](https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt)
    * => regional blocklist for China, daily updates, approx. 1.600 entries
    * [reg_cz](https://raw.githubusercontent.com/qxstyles/turris-hole-czech-block-list/master/turris-hole-czech-block-list)
    * => regional blocklist for Czechia, maintained by Turris Omnia Users, infrequent updates, approx. 100 entries
    * [reg_de](https://easylist-downloads.adblockplus.org/easylistgermany+easylist.txt)
    * => regional blocklist for Germany, daily updates, approx. 9.200 entries
    * [reg_id](https://easylist-downloads.adblockplus.org/abpindo+easylist.txt)
    * => regional blocklist for Indonesia, daily updates, approx. 800 entries
    * [reg_nl](https://easylist-downloads.adblockplus.org/easylistdutch+easylist.txt)
    * => regional blocklist for the Netherlands, weekly updates, approx. 1300 entries
    * [reg_pl](http://adblocklist.org)
    * => regional blocklist for Poland, daily updates, approx. 50 entries
    * [reg_ro](https://easylist-downloads.adblockplus.org/rolist+easylist.txt)
    * => regional blocklist for Romania, weekly updates, approx. 600 entries
    * [reg_ru](https://code.google.com/p/ruadlist)
    * => regional blocklist for Russia, weekly updates, approx. 2.000 entries
    * [shallalist](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default)
    * => daily updates, approx. 32.000 entries (a short description of all categories can be found [online](http://www.shallalist.de/categories.html))
    * [spam404](http://www.spam404.com)
    * => infrequent updates, approx. 5.000 entries
    * [sysctl/cameleon](http://sysctl.org/cameleon)
    * => weekly updates, approx. 21.000 entries
    * [ut_capitole](https://dsi.ut-capitole.fr/blacklists) (categories "cryptojacking" "ddos" "malware" "phishing" "warez" enabled by default)
    * => daily updates, approx. 64.000 entries (a short description of all categories can be found [online](https://dsi.ut-capitole.fr/blacklists/index_en.php))
    * [whocares](http://someonewhocares.org)
    * => weekly updates, approx. 12.000 entries
    * [winhelp](http://winhelp2002.mvps.org)
    * => infrequent updates, approx. 15.000 entries
    * [winspy](https://github.com/crazy-max/WindowsSpyBlocker)
    * => infrequent updates, approx. 120 entries
    * [yoyo](http://pgl.yoyo.org/adservers)
    * => weekly updates, approx. 2.500 entries (enabled by default)
* zero-conf like automatic installation & setup, usually no manual changes needed
* simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* support four different dns backends: dnsmasq, unbound, named (bind) and kresd
* support two different dns blocking variants: 'nxdomain' (default, supported by all backends), 'null' (supported only by dnsmasq)
* support six different download utilities: uclient-fetch, wget, curl, aria2c, wget-nossl, busybox-wget
* fast downloads & list processing as they are handled in parallel running background jobs (see 'Download Queue')
* provide 'http only' mode without installed ssl library for all non-SSL blocklist sources
* support a wide range of router modes, even AP modes are supported
* full IPv4 and IPv6 support
* provide top level domain compression ('tld compression'), this feature removes thousands of needless host entries from the blocklist and lowers the memory footprint for the dns backend
* provide a 'DNS File Reset', where the final DNS blockfile will be purged after DNS backend loading to save storage space
* blocklist source parsing by fast & flexible regex rulesets
* overall duplicate removal in central blocklist 'adb_list.overall'
* additional blacklist for manual overrides, located by default in /etc/adblock/adblock.blacklist or in LuCI
* additional whitelist for manual overrides, located by default in /etc/adblock/adblock.whitelist or in LuCI
* quality checks during blocklist update to ensure a reliable dns backend service
* minimal status & error logging to syslog, enable debug logging to receive more output
* procd based init system support (start/stop/restart/reload/suspend/resume/query/status)
* procd network interface trigger support or classic time based startup
* keep the dns cache intact after adblock processing (currently supported by unbound, named and kresd)
* suspend & resume adblock actions temporarily without blocklist reloading
* provide comprehensive runtime information via LuCI or via 'status' init command
* provide a detailed DNS Query Report with dns related information about client requests, top (blocked) domains and more
* provide a query function to quickly identify blocked (sub-)domains, e.g. for whitelisting. This function is also able to search in adblock backups and black-/whitelist, to get back the set of blocking lists sources for a certain domain
* option to force dns requests to the local resolver
* automatic blocklist backup & restore, these backups will be used in case of download errors and during startup
* send notification E-Mails in case of a processing error or if the overall domain count is &le; 0
* add new adblock sources on your own, see example below
* strong LuCI support for all options

## Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series (19.07) and with the latest snapshot
* a usual setup with an enabled dns backend at minimum - dump AP modes without a working dns backend are _not_ supported
* a download utility:
    * to support all blocklist sources a full version (with ssl support) of 'wget', 'uclient-fetch' with one of the 'libustream-*' ssl libraries, 'aria2c' or 'curl' is required
    * for limited devices with real memory constraints, adblock provides also a 'http only' option and supports wget-nossl and uclient-fetch (without libustream-ssl) as well
    * for more configuration options see examples below
* E-Mail notification (optional): for E-Mail notification support you need the additional 'msmtp' package
* DNS Query Report (optional): for this detailed report you need the additional package 'tcpdump' or 'tcpdump-mini'

## Installation & Usage
* install 'adblock' (_opkg install adblock_)
* at minimum configure the appropriate dns backend ('dnsmasq' by default), the download utility and enable the adblock service in _/etc/config/adblock_
* control the adblock service manually with _/etc/init.d/adblock_ start/stop/restart/reload/suspend/resume/status or use the LuCI frontend

## LuCI adblock companion package
* it's strongly recommended to use the LuCI frontend to easily configure all powerful aspects of adblock
* install 'luci-app-adblock' (_opkg install luci-app-adblock_)
* the application is located in LuCI under the 'Services' menu

## Tweaks
* **runtime information:** the adblock status is available via _/etc/init.d/adblock status_ (see example below)
* **debug logging:** for script debugging please set the config option 'adb\_debug' to '1' and check the runtime output with _logread -e "adblock"_
* **storage expansion:** to process and store all blocklist sources at once it might be helpful to enlarge your temp directory with a swap partition => see [OpenWrt Wiki](https://openwrt.org/docs/guide-user/storage/fstab) for further details
* **coreutils sort:** To speedup adblock processing in particular with many enabled blocklist sources it's recommended to install the additional package 'coreutils-sort'
* **add white- / blacklist entries:** add domain black- or whitelist entries to always-deny or -allow certain (sub) domains, by default both lists are empty and located in _/etc/adblock_. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below). You need to refresh your blocklists after changes to these static lists.
* **download queue size:** for further download & list processing performance improvements you can raise the 'adb\_maxqueue' value, e.g. '8' or '16' should be safe
* **scheduled list updates:** for a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **change startup behaviour:** by default the startup will be triggered by the 'wan' procd interface trigger. Choose 'none' to disable automatic startups, 'timed' to use a classic timeout (default 30 sec.) or select another trigger interface
* **suspend & resume adblocking:** to quickly switch the adblock service 'on' or 'off', simply use _/etc/init.d/adblock [suspend|resume]_
* **domain query:** to query the active blocklist for a certain domain, please use the LuCI frontend or run _/etc/init.d/adblock query `<DOMAIN>`_ (see example below)
* **add new list sources:** you could add new blocklist sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)

## Further adblock config options
* usually the pre-configured adblock setup works quite well and no manual overrides are needed
* the following options apply to the 'global' config section:
    * adb\_enabled => main switch to enable/disable adblock service (default: '0', disabled)
    * adb\_dns => select the dns backend for your environment: 'dnsmasq', 'unbound', 'named' or 'kresd' (default: 'dnsmasq')
    * adb\_dnsvariant => select the blocking variant: 'nxdomain' (default, supported by all backends), 'null (IPv4)' and 'null (IPv4/IPv6)' both options are only supported by dnsmasq
    * adb\_fetchutil => name of the used download utility: 'uclient-fetch', 'wget', 'curl', 'aria2c', 'wget-nossl'. 'busybox' (default: 'uclient-fetch')
    * adb\_fetchparm => special config options for the download utility (default: not set)
    * adb\_trigger => set the startup trigger to a certain interface, to 'timed' or to 'none' (default: 'wan')
* the following options apply to the 'extra' config section:
    * adb\_debug => enable/disable adblock debug output (default: '0', disabled)
    * adb\_nice => set the nice level of the adblock process and all sub-processes (int/default: '0', standard priority)
    * adb\_forcedns => force dns requests to local resolver (bool/default: '0', disabled)
    * adb\_maxqueue => size of the download queue to handle downloads & list processing in parallel (int/default: '8')
    * adb\_dnsfilereset => the final DNS blockfile will be purged after DNS backend loading to save storage space (bool/default: 'false', disabled)
    * adb\_report => enable the background tcpdump gathering process to provide a detailed DNS Query Report (bool/default: '0', disabled)
    * adb\_repdir => target directory for dns related report files generated by tcpdump (default: '/tmp')
    * adb\_backupdir => target directory for adblock backups (default: '/tmp')
    * adb\_mail => send notification E-Mails in case of a processing errors or if the overall domain count is &le; 0 (bool/default: '0', disabled)
    * adb\_mreceiver => receiver address for adblock notification E-Mails (default: not set)
* the following options could be added via "Additional Field" in LuCI and apply to the 'extra' config section as well:
    * adb\_dnsdir => target directory for the generated blocklist 'adb_list.overall' (default: not set, use dns backend default)
    * adb\_blacklist => full path to the static blacklist file (default: '/etc/adblock/adblock.blacklist')
    * adb\_whitelist => full path to the static whitelist file (default: '/etc/adblock/adblock.whitelist')
    * adb\_triggerdelay => additional trigger delay in seconds before adblock processing begins (int/default: '2')
    * adb\_maxtld => disable the tld compression, if the number of blocked domains is greater than this value (int/default: '100000')
    * adb\_portlist => space separated list of fw ports which should be redirected locally (default: '53 853 5353')
    * adb\_dnsinotify => disable adblock triggered restarts and the 'DNS File Reset' for dns backends with autoload features (bool/default: 'false', disabled)
    * adb\_dnsflush => flush DNS cache after adblock processing, i.e. enable the old restart behavior (bool/default: '0', disabled)
    * adb\_repiface => reporting interface used by tcpdump, set to 'any' for multiple interfaces (default: 'br-lan')
    * adb\_replisten => space separated list of reporting port(s) used by tcpdump (default: '53')
    * adb\_repchunkcnt => report chunk count used by tcpdump (default: '5')
    * adb\_repchunksize => report chunk size used by tcpdump in MB (int/default: '1')
    * adb\_msender => sender address for adblock notification E-Mails (default: 'no-reply@adblock')
    * adb\_mtopic => topic for adblock notification E-Mails (default: 'adblock notification')
    * adb\_mprofile => mail profile used in 'msmtp' for adblock notification E-Mails (default: 'adb_notify')
    * adb\_mcnt => raise the minimum domain count E-Mmail notification trigger (int/default: '0')

## Examples
**change default dns backend to 'unbound':**

Adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/unbound' where unbound can find them in its jail, no further configuration needed.  
To preserve the DNS cache after adblock processing you need to install 'unbound-control'.  
  
**change default dns backend to 'named' (bind):**

Adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/bind'.  
To preserve the DNS cache after adblock processing you need to install & configure 'bind-rdnc'.  
To use the blocklist please modify '/etc/bind/named.conf':
<pre><code>
in the 'options' namespace add:
  response-policy { zone "rpz"; };

and at the end of the file add:
  zone "rpz" {
    type master;
    file "/var/lib/bind/adb_list.overall";
    allow-query { none; };
    allow-transfer { none; };
  };
</code></pre>
  
**change default dns backend to 'kresd':**

The knot-resolver (kresd) is only available on Turris Omnia devices.  
Adblock deposits the final blocklist 'adb_list.overall' in '/etc/kresd', no further configuration needed.
  
**enable E-Mail notification via msmtp:**

To use the email notification you have to install & configure the package 'msmtp'.  
Modify the file '/etc/msmtprc':
<pre><code>
[...]
defaults
auth            on
tls             on
tls_certcheck   off
timeout         5
syslog          LOG_MAIL
[...]
account         adb_notify
host            smtp.gmail.com
port            587
from            dev.adblock@gmail.com
user            dev.adblock
password        xxx
</code></pre>
Finally enable E-Mail support and add a valid E-Mail address in LuCI.
  
**receive adblock runtime information:**

<pre><code>
/etc/init.d/adblock status
::: adblock runtime information
  + adblock_status  : enabled
  + adblock_version : 3.8.0
  + overall_domains : 48359
  + fetch_utility   : /bin/uclient-fetch (libustream-ssl)
  + dns_backend     : dnsmasq, /tmp
  + dns_variant     : null (IPv4/IPv6), true
  + backup_dir      : /mnt/data/adblock
  + last_rundate    : 15.08.2019 08:43:16
  + system_release  : GL.iNet GL-AR750S, OpenWrt SNAPSHOT r10720-ccb4b96b8a
</code></pre>
  
**receive adblock DNS Query Report information:**
<pre><code>
/etc/init.d/adblock report
:::
::: Adblock DNS-Query Report
:::
  + Start   ::: 2018-12-19, 16:29:40
  + End     ::: 2018-12-19, 16:45:08
  + Total   ::: 42
  + Blocked ::: 17 (40.48 %)
:::
::: Top 10 Clients
  + 32       ::: 101.167.1.103
  + 10       ::: abc1:abc1:abc0:0:abc1:abcb:abc5:abc3
:::
::: Top 10 Domains
  + 7        ::: dns.msftncsi.com
  + 4        ::: forum.openwrt.org
  + 2        ::: outlook.office365.com
  + 1        ::: www.google.com
  + 1        ::: www.deepl.com
  + 1        ::: safebrowsing.googleapis.com
  + 1        ::: play.googleapis.com
  + 1        ::: odc.officeapps.live.com
  + 1        ::: login.microsoftonline.com
  + 1        ::: test-my.sharepoint.com
:::
::: Top 10 Blocked Domains
  + 4        ::: nexus.officeapps.live.com
  + 4        ::: mobile.pipe.aria.microsoft.com
  + 3        ::: watson.telemetry.microsoft.com
  + 2        ::: v10.events.data.microsoft.com
  + 2        ::: settings-win.data.microsoft.com
  + 2        ::: nexusrules.officeapps.live.com
[...]
</code></pre>
  
**cronjob for a regular block list update (/etc/crontabs/root):**

<pre><code>
0 06 * * *    /etc/init.d/adblock reload
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

This entry removes the following (sub)domains from the blocklist:
  maps.here.com
  here.com

This entry does not remove:
  where.com
  www.adwhere.com
</code></pre>
  
**query the active blocklist, the backups and black-/whitelist for a certain (sub-)domain, e.g. for whitelisting:**

The query function checks against the submitted (sub-)domain and recurses automatically to the upper top level domain. For every (sub-)domain it returns the first ten relevant results.
<pre><code>
/etc/init.d/adblock query google.com
:::
::: results for domain 'google.com' in active blocklist
:::
  + adservice.google.com
  + adservice.google.com.au
  + adservice.google.com.vn
  + adservices.google.com
  + analytics.google.com
  + googleadapis.l.google.com
  + pagead.l.google.com
  + partnerad.l.google.com
  + ssl-google-analytics.l.google.com
  + video-stats.video.google.com
  + [...]

:::
::: results for domain 'google.com' in backups and black-/whitelist
:::
  + adb_list.adguard.gz           partnerad.l.google.com
  + adb_list.adguard.gz           googleadapis.l.google.com
  + adb_list.adguard.gz           ssl-google-analytics.l.google.com
  + adb_list.adguard.gz           [...]
  + adb_list.disconnect.gz        pagead.l.google.com
  + adb_list.disconnect.gz        partnerad.l.google.com
  + adb_list.disconnect.gz        video-stats.video.google.com
  + adb_list.disconnect.gz        [...]
  + adb_list.whocares.gz          video-stats.video.google.com
  + adb_list.whocares.gz          adservice.google.com
  + adb_list.whocares.gz          adservice.google.com.au
  + adb_list.whocares.gz          [...]
  + adb_list.yoyo.gz              adservice.google.com
  + adb_list.yoyo.gz              analytics.google.com
  + adb_list.yoyo.gz              pagead.l.google.com
  + adb_list.yoyo.gz              [...]
</code></pre>
  
**add a new blocklist source:**

1. the easy way ...  
example: https://easylist-downloads.adblockplus.org/rolist+easylist.txt  
Adblock already supports an easylist source, called 'reg_ru'. To add the additional local easylist as a new source, copy the existing config source section and change only
the source name, the url and the description - that's all!
<pre><code>
config source 'reg_ro'
  option enabled '0'
  option adb_src 'https://easylist-downloads.adblockplus.org/rolist+easylist.txt'
  option adb_src_rset 'BEGIN{FS=\"[|^]\"}/^\|\|([^([:space:]|#|\*|\/).]+\.)+[[:alpha:]]+\^("\\\$third-party")?$/{print tolower(\$3)}'
  option adb_src_desc 'focus on romanian ads plus generic easylist additions, weekly updates, approx. 9.400 entries'
</code></pre>

2. a bit harder ...  
To add a really new source with different domain/host format you have to write a suitable awk one-liner on your own, so basic awk skills are needed. As a starting point check the already existing awk rulesets 'adb_src_rset' in the config file, probably you need only small changes for your individual list. Download the desired list and test your new awk string locally. The output result should be a sequential list with one domain/host per line - nothing more. If your awk one-liner works quite well, add a new source section to the adblock config file and test the new source.  

## Support
Please join the adblock discussion in this [forum thread](https://forum.openwrt.org/t/adblock-support-thread/507) or contact me by mail <dev@brenken.org>  

Have fun!  
Dirk  
