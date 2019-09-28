# DNS based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other (wlan) gadget!? Getting rid of annoying ads, trackers and other abuse sites (like facebook) is simple: block them with your router. When the DNS server on your router receives DNS requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the DNS server, a condition called the 'NXDOMAIN' occurred.  

## Main Features
* Support of the following domain blocklist sources (free for private usage, for commercial use please check their individual licenses):
    * [adaway](https://adaway.org)
        * Infrequent updates, approx. 400 entries (enabled by default)
    * [adguard](https://adguard.com)
        * Numerous updates on the same day, approx. 12.000 entries
    * [bitcoin](https://github.com/hoshsadiq/adblock-nocoin-list)
        * Infrequent updates, approx. 15 entries
    * [blacklist]()
        * Static local blacklist, located by default in `/etc/adblock/adblock.blacklist`
    * [disconnect](https://disconnect.me)
        * Numerous updates on the same day, approx. 6.500 entries (enabled by default)
    * [dshield](http://dshield.org)
        * Daily updates, approx. 4.500 entries
    * [hphosts](https://hosts-file.net)
        * Monthly updates, approx. 50.000 entries
    * [malwaredomains](http://malwaredomains.com)
        * Daily updates, approx. 16.000 entries
    * [malwaredomainlist](http://www.malwaredomainlist.com)
        * Daily updates, approx. 1.500 entries
    * [openphish](https://openphish.com)
        * Numerous updates on the same day, approx. 1.800 entries
    * [ransomware tracker](https://ransomwaretracker.abuse.ch)
        * Daily updates, approx. 150 entries
    * [reg_cn](https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt)
        * Regional blocklist for China, daily updates, approx. 1.600 entries
    * [reg_cz](https://raw.githubusercontent.com/qxstyles/turris-hole-czech-block-list/master/turris-hole-czech-block-list)
        * Regional blocklist for Czechia, maintained by Turris Omnia Users, infrequent updates, approx. 100 entries
    * [reg_de](https://easylist-downloads.adblockplus.org/easylistgermany+easylist.txt)
        * Regional blocklist for Germany, daily updates, approx. 9.200 entries
    * [reg_id](https://easylist-downloads.adblockplus.org/abpindo+easylist.txt)
        * Regional blocklist for Indonesia, daily updates, approx. 800 entries
    * [reg_nl](https://easylist-downloads.adblockplus.org/easylistdutch+easylist.txt)
        * Regional blocklist for the Netherlands, weekly updates, approx. 1300 entries
    * [reg_pl](http://adblocklist.org)
        * Regional blocklist for Poland, daily updates, approx. 50 entries
    * [reg_ro](https://easylist-downloads.adblockplus.org/rolist+easylist.txt)
        * Regional blocklist for Romania, weekly updates, approx. 600 entries
    * [reg_ru](https://code.google.com/p/ruadlist)
        * Regional blocklist for Russia, weekly updates, approx. 2.000 entries
    * [shallalist](http://www.shallalist.de) (categories "adv" "costtraps" "spyware" "tracker" "warez" enabled by default)
        * Daily updates, approx. 32.000 entries (a short description of all categories can be found [online](http://www.shallalist.de/categories.html))
    * [spam404](http://www.spam404.com)
        * Infrequent updates, approx. 5.000 entries
    * [sysctl/cameleon](http://sysctl.org/cameleon)
        * Weekly updates, approx. 21.000 entries
    * [ut_capitole](https://dsi.ut-capitole.fr/blacklists) (categories "cryptojacking" "ddos" "malware" "phishing" "warez" enabled by default)
        * Daily updates, approx. 64.000 entries (a short description of all categories can be found [online](https://dsi.ut-capitole.fr/blacklists/index_en.php))
    * [whocares](http://someonewhocares.org)
        * Weekly updates, approx. 12.000 entries
    * [winhelp](http://winhelp2002.mvps.org)
        * Infrequent updates, approx. 15.000 entries
    * [winspy](https://github.com/crazy-max/WindowsSpyBlocker)
        * Infrequent updates, approx. 120 entries
    * [yoyo](http://pgl.yoyo.org/adservers)
        * Weekly updates, approx. 2.500 entries (enabled by default)
* Zero-conf like automatic installation & setup, usually no manual changes needed
* Simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* Support four different DNS backends: `dnsmasq`, `unbound`, `named` (bind) and `kresd`
* Support two different DNS blocking variants: `nxdomain` (default, supported by all backends), `null` (supported only by `dnsmasq`)
* Support six different download utilities: `uclient-fetch`, `wget`, `curl`, `aria2c`, `wget-nossl`, `busybox-wget`
* Fast downloads & list processing as they are handled in parallel running background jobs (see 'Download Queue')
* Provide `http only` mode without installed SSL library for all non-SSL blocklist sources
* Support a wide range of router modes, even AP modes are supported
* Full IPv4 and IPv6 support
* Provide top level domain compression (`tld compression`), this feature removes thousands of needless host entries from the blocklist and lowers the memory footprint for the DNS backend
* Provide a 'DNS File Reset', where the final DNS blockfile will be purged after DNS backend loading to save storage space
* Blocklist source parsing by fast & flexible regex rulesets
* Overall duplicate removal in central blocklist `adb_list.overall`
* Additional blacklist for manual overrides, located by default in `/etc/adblock/adblock.blacklist` or in LuCI
* Additional whitelist for manual overrides, located by default in `/etc/adblock/adblock.whitelist` or in LuCI
* Quality checks during blocklist update to ensure a reliable DNS backend service
* Minimal status & error logging to syslog, enable debug logging to receive more output
* procd based init system support (`start/stop/restart/reload/suspend/resume/query/status`)
* procd network interface trigger support or classic time based startup
* Keep the DNS cache intact after adblock processing (currently supported by unbound, named and kresd)
* Suspend & resume adblock actions temporarily without blocklist reloading
* Provide comprehensive runtime information via LuCI or via `status` init command
* Provide a detailed DNS Query Report with DNS related information about client requests, top (blocked) domains and more
* Provide a query function to quickly identify blocked (sub-)domains, e.g. for whitelisting. This function is also able to search in adblock backups and black-/whitelist, to get back the set of blocking lists sources for a certain domain
* Option to force DNS requests to the local resolver
* Automatic blocklist backup & restore, these backups will be used in case of download errors and during startup
* Send notification emails in case of a processing error or if the overall domain count is &le; 0
* Add new adblock sources on your own, see example below
* Strong LuCI support for all options

## Installation & Usage
### Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series (19.07) and with the latest snapshot
* A usual setup with an enabled DNS backend at minimum - dump AP modes without a working DNS backend are _not_ supported
* A download utility:
    * To support all blocklist sources and in order to run the default configuration of `adblock`, a full version (with SSL support) of `wget`, `uclient-fetch` with one of the `libustream-*` SSL libraries, `aria2c` or `curl` is required
        * The package used by default is probably `uclient-fetch` so in order to make `adblock` work with its default configuration it is needed to install one of the `libustream-*` SSL libraries. Example: `opkg install libustream-openssl`
    * For limited devices with real memory constraints, adblock provides also a `http only` option and supports `wget-nossl` and `uclient-fetch` (without `libustream-ssl`) as well
    * For more configuration options see examples below
* Email notification (optional): For email notification support you need the additional `msmtp` package
* DNS Query Report (optional): For this detailed report you need the additional package `tcpdump` or `tcpdump-mini`

### Installation of the core package
* Install `adblock` (`opkg install adblock`)

### LuCI adblock companion package
* It is strongly recommended to use the LuCI frontend to easily configure all powerful aspects of adblock
* Install `luci-app-adblock` (`opkg install luci-app-adblock`)
* The application is located in LuCI under the `Services` menu

### Configuration and controlling
* At minimum configure the appropriate DNS backend (`dnsmasq` by default), the download utility and enable the adblock service in `/etc/config/adblock`
* Control the adblock service manually with `/etc/init.d/adblock` `start/stop/restart/reload/suspend/resume/status` or use the LuCI frontend

#### Tweaks
* **Runtime information:** The adblock status is available via `/etc/init.d/adblock status` (see example below)
* **Debug logging:** For script debugging please set the config option `adb\_debug` to `1` and check the runtime output with `logread -e "adblock"`
* **Storage expansion:** To process and store all blocklist sources at once it might be helpful to enlarge your temp directory with a swap partition => see [OpenWrt Wiki](https://openwrt.org/docs/guide-user/storage/fstab) for further details
* **coreutils sort:** To speedup adblock processing in particular with many enabled blocklist sources it is recommended to install the additional package `coreutils-sort`
* **Add white- / blacklist entries:** Add domain black- or whitelist entries to always-deny or -allow certain (sub) domains, by default both lists are empty and located in `/etc/adblock`. Please add one domain per line - ip addresses, wildcards & regex are _not_ allowed (see example below). You need to refresh your blocklists after changes to these static lists.
* **Download queue size:** For further download & list processing performance improvements you can raise the `adb\_maxqueue` value, e.g. `8` or `16` should be safe
* **Scheduled list updates:** For a scheduled call of the adblock service add an appropriate crontab entry (see example below)
* **Change startup behaviour:** By default the startup will be triggered by the `wan` procd interface trigger. Choose `none` to disable automatic startups, `timed` to use a classic timeout (default 30 sec.) or select another trigger interface
* **Suspend & resume adblocking:** To quickly switch the adblock service `on` or `off`, simply use `/etc/init.d/adblock [suspend|resume]`
* **Domain query:** To query the active blocklist for a certain domain, please use the LuCI frontend or run _/etc/init.d/adblock query `<DOMAIN>`_ (see example below)
* **Add new list sources:** You can add new blocklist sources on your own via uci config, all you need is a source url and an awk one-liner (see example below)

#### Further adblock config options
* Usually the pre-configured adblock setup works quite well and no manual overrides are needed
* The following options apply to the `global` config section:
    * `adb\_enabled` => Main switch to enable/disable adblock service (default: `0`, disabled)
    * `adb\_dns` => Select the DNS backend for your environment: `dnsmasq`, `unbound`, `named` or `kresd` (default: `dnsmasq`)
    * `adb\_dnsvariant` => Select the blocking variant: `nxdomain` (default, supported by all backends), `null (IPv4)` and `null (IPv4/IPv6)` both options are only supported by `dnsmasq`
    * `adb\_fetchutil` => Name of the used download utility: `uclient-fetch`, `wget`, `curl`, `aria2c`, `wget-nossl` or `busybox` (default: `uclient-fetch`)
    * `adb\_fetchparm` => Special config options for the download utility (default: not set)
    * `adb\_trigger` => Set the startup trigger to a certain interface, to `timed` or to `none` (default: `wan`)
* The following options apply to the `extra` config section:
    * `adb\_debug` => Enable/disable adblock debug output (default: `0`, disabled)
    * `adb\_nice` => Set the nice level of the adblock process and all sub-processes (int/default: `0`, standard priority)
    * `adb\_forcedns` => Force DNS requests to local resolver (bool/default: `0`, disabled)
    * `adb\_maxqueue` => Size of the download queue to handle downloads & list processing in parallel (int/default: `8`)
    * `adb\_dnsfilereset` => The final DNS blockfile will be purged after DNS backend loading to save storage space (bool/default: `false`, disabled)
    * `adb\_report` => Enable the background tcpdump gathering process to provide a detailed DNS Query Report (bool/default: `0`, disabled)
    * `adb\_repdir` => Target directory for DNS related report files generated by tcpdump (default: `/tmp`)
    * `adb\_backupdir` => Target directory for adblock backups (default: `/tmp`)
    * `adb\_mail` => Send notification emails in case of a processing errors or if the overall domain count is &le; 0 (bool/default: `0`, disabled)
    * `adb\_mreceiver` => Receiver address for adblock notification emails (default: not set)
* The following options could be added via "Additional Field" in LuCI and apply to the `extra` config section as well:
    * `adb\_dnsdir` => Target directory for the generated blocklist `adb_list.overall` (default: not set, use DNS backend default)
    * `adb\_blacklist` => Full path to the static blacklist file (default: `/etc/adblock/adblock.blacklist`)
    * `adb\_whitelist` => Full path to the static whitelist file (default: `/etc/adblock/adblock.whitelist`)
    * `adb\_triggerdelay` => Additional trigger delay in seconds before adblock processing begins (int/default: `2`)
    * `adb\_maxtld` => Disable the tld compression, if the number of blocked domains is greater than this value (int/default: `100000`)
    * `adb\_portlist` => Space separated list of fw ports which should be redirected locally (default: `53 853 5353`)
    * `adb\_dnsinotify` => Disable adblock triggered restarts and the 'DNS File Reset' for DNS backends with autoload features (bool/default: `false`, disabled)
    * `adb\_dnsflush` => Flush DNS cache after adblock processing, i.e. enable the old restart behavior (bool/default: `0`, disabled)
    * `adb\_repiface` => Reporting interface used by tcpdump, set to `any` for multiple interfaces (default: `br-lan`)
    * `adb\_replisten` => Space separated list of reporting port(s) used by tcpdump (default: `53`)
    * `adb\_repchunkcnt` => Report chunk count used by tcpdump (default: `5`)
    * `adb\_repchunksize` => Report chunk size used by tcpdump in MB (int/default: `1`)
    * `adb\_msender` => Sender address for adblock notification emails (default: `no-reply@adblock`)
    * `adb\_mtopic` => Topic for adblock notification emails (default: `adblock notification`)
    * `adb\_mprofile` => Email profile used in `msmtp` for adblock notification emails (default: `adb_notify`)
    * `adb\_mcnt` => Raise the minimum domain count email notification trigger (int/default: `0`)

#### Examples
**Change default DNS backend to `unbound`:**

Adblock deposits the final blocklist `adb_list.overall` in `/var/lib/unbound` where unbound can find them in its jail, no further configuration needed.  
To preserve the DNS cache after adblock processing you need to install `unbound-control`.

**Change default DNS backend to `named` (bind):**

Adblock deposits the final blocklist `adb_list.overall` in `/var/lib/bind`.  
To preserve the DNS cache after adblock processing you need to install & configure `bind-rdnc`.  
To use the blocklist please modify `/etc/bind/named.conf`:
* In the `options` namespace add:
```
  response-policy { zone "rpz"; };
```
* And at the end of the file add:
```
  zone "rpz" {
    type master;
    file "/var/lib/bind/adb_list.overall";
    allow-query { none; };
    allow-transfer { none; };
  };
```

**Change default DNS backend to `kresd`:**

The knot-resolver (kresd) is only available on Turris Omnia devices.  
Adblock deposits the final blocklist `adb_list.overall` in `/etc/kresd`, no further configuration needed.
  
**Enable email notification via msmtp:**

To use the email notification you have to install & configure the package `msmtp`.  
Modify the file `/etc/msmtprc`:
```
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
```
Finally enable email support and add a valid email address in LuCI.
  
**Receive adblock runtime information:**

```
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
```
  
**Receive adblock DNS Query Report information:**
```
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
```
  
**Cronjob for a regular block list update (`/etc/crontabs/root`):**

```
0 06 * * *    /etc/init.d/adblock reload
```
  
**Blacklist entry (`/etc/adblock/adblock.blacklist`):**

```
ads.example.com

This entry blocks the following (sub)domains:
  http://ads.example.com/foo.gif
  http://server1.ads.example.com/foo.gif
  https://ads.example.com:8000/

This entry does not block:
  http://ads.example.com.ua/foo.gif
  http://example.com/
```
  
**Whitelist entry (`/etc/adblock/adblock.whitelist`):**

```
here.com

This entry removes the following (sub)domains from the blocklist:
  maps.here.com
  here.com

This entry does not remove:
  where.com
  www.adwhere.com
```
  
**Query the active blocklist, the backups and black-/whitelist for a certain (sub-)domain, e.g. for whitelisting:**

The query function checks against the submitted (sub-)domain and recurses automatically to the upper top level domain. For every (sub-)domain it returns the first ten relevant results.
```
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
```

**Add a new blocklist source:**

1. The easy way ...  
Example: https://easylist-downloads.adblockplus.org/rolist+easylist.txt  
Adblock already supports an easylist source, called 'reg_ru'. To add the additional local easylist as a new source, copy the existing config source section and change only the source name, the url and the description - that's all!
```
config source 'reg_ro'
  option enabled '0'
  option adb_src 'https://easylist-downloads.adblockplus.org/rolist+easylist.txt'
  option adb_src_rset 'BEGIN{FS=\"[|^]\"}/^\|\|([^([:space:]|#|\*|\/).]+\.)+[[:alpha:]]+\^("\\\$third-party")?$/{print tolower(\$3)}'
  option adb_src_desc 'focus on romanian ads plus generic easylist additions, weekly updates, approx. 9.400 entries'
```

2. A bit harder ...  
To add a really new source with different domain/host format you have to write a suitable awk one-liner on your own, so basic awk skills are needed. As a starting point check the already existing awk rulesets `adb_src_rset` in the config file, probably you need only small changes for your individual list. Download the desired list and test your new awk string locally. The output result should be a sequential list with one domain/host per line - nothing more. If your awk one-liner works quite well, add a new source section to the adblock config file and test the new source.  

## Support
Please join the adblock discussion in this [forum thread](https://forum.openwrt.org/t/adblock-support-thread/507) or contact me by email <dev@brenken.org>  

Have fun!  
Dirk  
