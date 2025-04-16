<!-- markdownlint-disable -->

# DNS based ad/abuse domain blocking

<a id="description"></a>
## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other (wlan) gadget!? Getting rid of annoying ads, trackers and other abuse sites (like facebook) is simple: block them with your router. When the DNS server on your router receives DNS requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the DNS server, a condition called the 'NXDOMAIN' occurred.

<a id="main-features"></a>
## Main Features
* Support of the following fully pre-configured domain blocklist feeds (free for private usage, for commercial use please check their individual licenses)

| Feed                | Enabled | Size | Focus            | Information                                                                       |
| :------------------ | :-----: | :--- | :--------------- | :-------------------------------------------------------------------------------- |
| 1Hosts              |         | VAR  | compilation      | [Link](https://github.com/badmojr/1Hosts)                                         |
| adaway              |         | S    | mobile           | [Link](https://github.com/AdAway/adaway.github.io)                                |
| adguard             |    x    | L    | general          | [Link](https://adguard.com)                                                       |
| adguard_tracking    |    x    | L    | tracking         | [Link](https://github.com/AdguardTeam/cname-trackers)                             |
| android_tracking    |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| andryou             |         | L    | compilation      | [Link](https://gitlab.com/andryou/block/-/blob/master/readme.md)                  |
| anti_ad             |         | L    | compilation      | [Link](https://github.com/privacy-protection-tools/anti-AD/blob/master/README.md) |
| anudeep             |         | M    | compilation      | [Link](https://github.com/anudeepND/blacklist)                                    |
| bitcoin             |         | S    | mining           | [Link](https://github.com/hoshsadiq/adblock-nocoin-list)                          |
| certpl              |    x    | L    | phishing         | [Link](https://cert.pl/en/warning-list/)                                          |
| cpbl                |         | XL   | compilation      | [Link](https://github.com/bongochong/CombinedPrivacyBlockLists)                   |
| disconnect          |         | S    | general          | [Link](https://disconnect.me)                                                     |
| doh_blocklist       |         | S    | doh_server       | [Link](https://github.com/dibdot/DoH-IP-blocklists)                               |
| easylist            |         | M    | compilation      | [Link](https://easylist.to)                                                       |
| easyprivacy         |         | M    | tracking         | [Link](https://easylist.to)                                                       |
| energized_blu       |         | XL   | compilation      | [Link](https://energized.pro)                                                     |
| energized_spark     |         | L    | compilation      | [Link](https://energized.pro)                                                     |
| energized_ultimate  |         | XXL  | compilation      | [Link](https://energized.pro)                                                     |
| firetv_tracking     |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| games_tracking      |         | S    | tracking         | [Link](https://www.gameindustry.eu)                                               |
| hagezi              |         | VAR  | compilation      | [Link](https://github.com/hagezi/dns-blocklists)                                  |
| hblock              |         | XL   | compilation      | [Link](https://hblock.molinero.dev)                                               |
| lightswitch05       |         | XL   | compilation      | [Link](https://github.com/lightswitch05/hosts)                                    |
| notracking          |         | XL   | tracking         | [Link](https://github.com/notracking/hosts-blocklists)                            |
| oisd_big            |         | XXL  | general          | [Link](https://oisd.nl)                                                           |
| oisd_nsfw           |         | XXL  | porn             | [Link](https://oisd.nl)                                                           |
| oisd_nsfw_small     |         | M    | porn             | [Link](https://oisd.nl)                                                           |
| oisd_small          |         | L    | general          | [Link](https://oisd.nl)                                                           |
| openphish           |         | S    | phishing         | [Link](https://openphish.com)                                                     |
| phishing_army       |         | S    | phishing         | [Link](https://phishing.army)                                                     |
| reg_cn              |         | S    | reg_china        | [Link](https://easylist.to)                                                       |
| reg_cz              |         | S    | reg_czech+slovak | [Link](https://easylist.to)                                                       |
| reg_de              |         | S    | reg_germany      | [Link](https://easylist.to)                                                       |
| reg_es              |         | S    | reg_espania      | [Link](https://easylist.to)                                                       |
| reg_fi              |         | S    | reg_finland      | [Link](https://github.com/finnish-easylist-addition)                              |
| reg_fr              |         | M    | reg_france       | [Link](https://forums.lanik.us/viewforum.php?f=91)                                |
| reg_id              |         | S    | reg_indonesia    | [Link](https://easylist.to)                                                       |
| reg_it              |         | S    | reg_italy        | [Link](https://easylist.to)                                                       |
| reg_jp              |         | S    | reg_japan        | [Link](https://github.com/k2jp/abp-japanese-filters)                              |
| reg_kr              |         | S    | reg_korea        | [Link](https://github.com/List-KR/List-KR)                                        |
| reg_lt              |         | S    | reg_lithuania    | [Link](https://easylist.to)                                                       |
| reg_nl              |         | S    | reg_netherlands  | [Link](https://easylist.to)                                                       |
| reg_pl              |         | M    | reg_poland       | [Link](https://kadantiscam.netlify.com)                                           |
| reg_ro              |         | S    | reg_romania      | [Link](https://easylist.to)                                                       |
| reg_ru              |         | S    | reg_russia       | [Link](https://easylist.to)                                                       |
| reg_se              |         | S    | reg_sweden       | [Link](https://github.com/lassekongo83/Frellwits-filter-lists)                    |
| reg_vn              |         | S    | reg_vietnam      | [Link](https://bigdargon.github.io/hostsVN)                                       |
| smarttv_tracking    |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| spam404             |         | S    | general          | [Link](https://github.com/Dawsey21)                                               |
| stevenblack         |         | VAR  | compilation      | [Link](https://github.com/StevenBlack/hosts)                                      |
| stopforumspam       |         | S    | spam             | [Link](https://www.stopforumspam.com)                                             |
| utcapitole          |         | VAR  | general          | [Link](https://dsi.ut-capitole.fr/blacklists/index_en.php)                        |
| wally3k             |         | S    | compilation      | [Link](https://firebog.net/about)                                                 |
| whocares            |         | M    | general          | [Link](https://someonewhocares.org)                                               |
| winhelp             |         | S    | general          | [Link](https://winhelp2002.mvps.org)                                              |
| winspy              |         | S    | win_telemetry    | [Link](https://github.com/crazy-max/WindowsSpyBlocker)                            |
| yoyo                |         | S    | general          | [Link](https://pgl.yoyo.org/adservers)                                            |

* List of supported and fully pre-configured adblock sources, already active sources are pre-selected.  
  <b><em>To avoid OOM errors, please do not select too many lists!</em></b>  
  List size information with the respective domain ranges as follows:  
    • <b>S</b> (-10k), <b>M</b> (10k-30k) and <b>L</b> (30k-80k) should work for 128 MByte devices  
    • <b>XL</b> (80k-200k) should work for 256-512 MByte devices  
    • <b>XXL</b> (200k-) needs more RAM and Multicore support, e.g. x86 or raspberry devices  
    • <b>VAR</b> (50k-900k) variable size depending on the selection  
* Zero-conf like automatic installation & setup, usually no manual changes needed
* Simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* Supports six different DNS backend formats: dnsmasq, unbound, named (bind), kresd, smartdns or raw (e.g. used by dnscrypt-proxy)
* Supports three different SSL-enabled download utilities: uclient-fetch, full wget or curl
* Supports SafeSearch for google, bing, brave, duckduckgo, yandex, youtube and pixabay
* Supports RPZ-trigger 'RPZ-CLIENT-IP' to always allow/deny certain DNS clients based on their IP address (currently only supported by bind dns backend)
* Fast downloads & list processing as they are handled in parallel running background jobs with multicore support
* The download engine supports ETAG headers to download only updated feeds
* Supports a wide range of router modes, even AP modes are supported
* Full IPv4 and IPv6 support
* Provides top level domain compression ('tld compression'), this feature removes thousands of needless host entries from the blocklist and lowers the memory footprint for the DNS backend
* Provides a 'DNS Shift', where the generated final DNS blocklist is moved to the backup directory and only a soft link to this file is set in memory. As long as your backup directory is located on an external drive, you should activate this option to save disk space.
* Source parsing by fast & flexible regex rulesets, all rules and feed information are placed in an external JSON file ('/etc/adblock/adblock.feeds')
* Overall duplicate removal in generated blocklist file 'adb_list.overall'
* Additional local allowlist for manual overrides, located in '/etc/adblock/adblock.allowlist' (only exact matches).
* Additional local blocklist for manual overrides, located in '/etc/adblock/adblock.blocklist'
* Quality checks during blocklist update to ensure a reliable DNS backend service
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support ('start', 'stop', 'restart', 'reload', 'enable', 'disable', 'running', 'status', 'suspend', 'resume', 'query', 'report')
* Auto-Startup via procd network interface trigger or via classic time based startup
* Suspend & Resume adblock temporarily without blocklist re-processing
* Provides comprehensive runtime information
* Provides a detailed DNS Query Report with DNS related information about client requests, top (blocked) domains and more
* Provides a powerful query function to quickly find blocked (sub-)domains, e.g. to allow certain domains
* Includes an option to generate an additional, restrictive 'adb_list.jail' to block access to all domains except those listed in the allowlist file. You can use this restrictive blocklist manually e.g. for guest wifi or kidsafe configurations
* Includes an option to force DNS requests to the local resolver
* Automatic blocklist backup & restore, these backups will be used in case of download errors and during startup
* Send notification E-Mails, see example configuration below
* Add new adblock feeds on your own with the 'Custom Feed Editor' in LuCI or via CLI, see example below
* Strong LuCI support, all relevant options are exposed to the web frontend

<a id="prerequisites"></a>
## Prerequisites
* **[OpenWrt](https://openwrt.org)**, latest stable release 24.x or a development snapshot
* A usual setup with a working DNS backend
* A download utility with SSL support: 'wget', 'uclient-fetch' with one of the 'libustream-*' ssl libraries or 'curl' is required
* A certificate store such as 'ca-bundle' or 'ca-certificates', as adblock checks the validity of the SSL certificates of all download sites by default
* For E-Mail notifications you need to install and setup the additional 'msmtp' package
* For DNS reporting you need to install the additional package 'tcpdump-mini' or 'tcpdump'

**Please note:**
* Devices with less than 128MB of RAM are **_not_** supported
* For performance reasons, adblock depends on gnu sort and gawk

<a id="installation-and-usage"></a>
## Installation & Usage
* Update your local opkg/apk repository
* Install the LuCI companion package 'luci-app-adblock' which also installs the main 'adblock' package as a dependency
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of adblock, the application is located in LuCI under the 'Services' menu
* It's also recommended to configure at least a 'Startup Trigger Interface' to depend on WAN ifup events during boot or restart of your router

<a id="adblock-cli-interface"></a>
## Adblock CLI interface
* The most important adblock functions are accessible via CLI as well.

```
~# /etc/init.d/adblock 
Syntax: /etc/init.d/adblock [command]

Available commands:
	start           Start the service
	stop            Stop the service
	restart         Restart the service
	reload          Reload configuration files (or restart if service does not implement reload)
	enable          Enable service autostart
	disable         Disable service autostart
	enabled         Check if service is started on boot
	suspend         Suspend adblock processing
	resume          Resume adblock processing
	query           <domain> Query active blocklists and backups for a specific domain
	report          [<cli>|<mail>|<gen>|<json>] Print DNS statistics
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

<a id="adblock-config-options"></a>
## Adblock Config Options
* Usually the auto pre-configured adblock setup works quite well and no manual overrides are needed

| Option             | Default                            | Description/Valid Values                                                                       |
| :----------------- | :--------------------------------- | :--------------------------------------------------------------------------------------------- |
| adb_enabled        | 1, enabled                         | set to 0 to disable the adblock service                                                        |
| adb_feedfile       | /etc/adblock/adblock.feeds         | full path to the used adblock feed file                                                        |
| adb_dns            | -, auto-detected                   | 'dnsmasq', 'unbound', 'named', 'kresd', 'smartdns' or 'raw'                                    |
| adb_fetchcmd       | -, auto-detected                   | 'uclient-fetch', 'wget' or 'curl'                                                              |
| adb_fetchparm      | -, auto-detected                   | manually override the config options for the selected download utility                         |
| adb_fetchinsecure  | 0, disabled                        | don't check SSL server certificates during download                                            |
| adb_trigger        | -, not set                         | trigger network interface or 'not set' to use a time-based startup                             |
| adb_triggerdelay   | 2                                  | additional trigger delay in seconds before adblock processing begins                           |
| adb_debug          | 0, disabled                        | set to 1 to enable the debug output                                                            |
| adb_nice           | 0, standard prio.                  | valid nice level range 0-19 of the adblock processes                                           |
| adb_dnsforce       | 0, disabled                        | set to 1 to force DNS requests to the local resolver                                           |
| adb_dnsdir         | -, auto-detected                   | path for the generated blocklist file 'adb_list.overall'                                       |
| adb_dnstimeout     | 10                                 | timeout in seconds to wait for a successful DNS backend restart                                |
| adb_dnsinstance    | 0, first instance                  | set to the relevant dns backend instance used by adblock (dnsmasq only)                        |
| adb_dnsflush       | 0, disabled                        | set to 1 to flush the DNS Cache before & after adblock processing                              |
| adb_lookupdomain   | localhost                          | domain to check for a successful DNS backend restart                                           |
| adb_portlist       | 53 853 5353                        | space separated list of firewall ports which should be redirected locally                      |
| adb_report         | 0, disabled                        | set to 1 to enable the background tcpdump gathering process for reporting                      |
| adb_reportdir      | /tmp/adblock-report                | path for DNS related report files                                                              |
| adb_repiface       | -, auto-detected                   | name of the reporting interface or 'any' used by tcpdump                                       |
| adb_replisten      | 53                                 | space separated list of reporting port(s) used by tcpdump                                      |
| adb_repchunkcnt    | 5                                  | report chunk count used by tcpdump                                                             |
| adb_repchunksize   | 1                                  | report chunk size used by tcpdump in MB                                                        |
| adb_represolve     | 0, disabled                        | resolve reporting IP addresses using reverse DNS (PTR) lookups                                 |
| adb_tld            | 1, enabled                         | set to 0 to disable the top level domain compression (tld) function                            |
| adb_backupdir      | /tmp/adblock-backup                | path for adblock backups                                                                       |
| adb_tmpbase        | /tmp                               | path for all adblock related runtime operations, e.g. downloading, sorting, merging etc.       |
| adb_safesearch     | 0, disabled                        | enforce SafeSearch for google, bing, brave, duckduckgo, yandex, youtube and pixabay            |
| adb_safesearchlist | -, not set                         | Limit SafeSearch to certain provider (see above)                                               |
| adb_mail           | 0, disabled                        | set to 1 to enable notification E-Mails in case of a processing errors                         |
| adb_mailreceiver   | -, not set                         | receiver address for adblock notification E-Mails                                              |
| adb_mailsender     | no-reply@adblock                   | sender address for adblock notification E-Mails                                                |
| adb_mailtopic      | adblock notification               | topic for adblock notification E-Mails                                                         |
| adb_mailprofile    | adb_notify                         | mail profile used in 'msmtp' for adblock notification E-Mails                                  |
| adb_jail           | 0                                  | set to 1 to enable the additional, restrictive 'adb_list.jail' creation                        |
| adb_jaildir        | /tmp                               | path for the generated jail list                                                               |

<a id="examples"></a>
## Examples

**Change the DNS backend to 'unbound':**
No further configuration is needed, adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/unbound' by default.
To preserve the DNS cache after adblock processing please install the additional package 'unbound-control'.

**Change the DNS backend to 'bind':**
Adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/bind' by default.
To preserve the DNS cache after adblock processing please install the additional package 'bind-rdnc'.
To use the blocklist please modify '/etc/bind/named.conf':

```
in the 'options' namespace add:
  response-policy { zone "rpz"; };

and at the end of the file add:
  zone "rpz" {
    type master;
    file "/var/lib/bind/adb_list.overall";
    allow-query { none; };
    allow-transfer { none; };
  };
```

**Change the DNS backend to 'kresd':**
Adblock deposits the final blocklist 'adb_list.overall' in '/tmp/kresd', no further configuration needed.

**Change the DNS backend to 'smartdns':**
No further configuration is needed, adblock deposits the final blocklist 'adb_list.overall' in '/tmp/smartdns' by default.

**Use restrictive jail modes:**
You can enable a restrictive 'adb_list.jail' to block access to all domains except those listed in the allowlist file. Usually this list will be generated as an additional list for guest or kidsafe configurations (for a separate dns server instance). If the jail directory points to your primary dns directory, adblock enables the restrictive jail mode automatically (jail mode only).

**Manually override the download options:**
By default adblock uses the following pre-configured download options:
* <code>curl: --connect-timeout 20 --silent --show-error --location -o</code>
* <code>uclient-fetch: --timeout=20 -O</code>
* <code>wget: --no-cache --no-cookies --max-redirect=0 --timeout=20 -O</code>

To override the default set 'adb_fetchparm' manually to your needs.

**Enable E-Mail notification via 'msmtp':**
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
Finally enable E-Mail support and add a valid E-Mail receiver address in LuCI.

**Send status E-Mails and update the adblock lists via cron job**  
For a regular, automatic status mailing and update of the used lists on a daily basis set up a cron job, e.g.

```
55 03 * * * /etc/init.d/adblock report mail
00 04 * * * /etc/init.d/adblock reload
```

**Service status output:**
In LuCI you'll see the realtime status in the 'Runtime' section on the overview page.
To get the status in the CLI, just call _/etc/init.d/adblock status_ or _/etc/init.d/adblock status\_service_:

```
~#@blackhole:~# /etc/init.d/adblock status
::: adblock runtime information
  + adblock_status  : enabled
  + adblock_version : 4.4.0-r1
  + blocked_domains : 1 154 208
  + active_feeds    : 1hosts, certpl, cpbl, doh_blocklist, hagezi, winspy
  + dns_backend     : dnsmasq (-), /mnt/data/adblock/backup, 92.87 MB
  + run_utils       : download: /usr/bin/curl, sort: /usr/libexec/sort-coreutils, awk: /usr/bin/gawk
  + run_ifaces      : trigger: trm_wwan, report: br-lan
  + run_directories : base: /mnt/data/adblock, backup: /mnt/data/adblock/backup, report: /mnt/data/adblock/report, jail: -
  + run_flags       : shift: ✔, force: ✔, flush: ✘, tld: ✔, search: ✘, report: ✔, mail: ✘, jail: ✘
  + last_run        : mode: reload, 2025-04-10T20:34:17+02:00, duration: 0m 55s, 682.52 MB available
  + system_info     : OpenWrt One, mediatek/filogic, OpenWrt 24.10-SNAPSHOT r28584-a51b1a98e0 
```

**Change/add adblock feeds**  
The adblock default blocklist feeds are stored in an external JSON file '/etc/adblock/adblock.feeds'. All custom changes should be stored in an external JSON file '/etc/adblock/adblock.custom.feeds' (empty by default). It's recommended to use the LuCI based Custom Feed Editor to make changes to this file.  
A valid JSON source object contains the following information, e.g.:

```
	[...]
	"adguard": {
		"url": "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt",
		"rule": "BEGIN{FS=\"[|^]\"}/^\\|\\|([[:alnum:]_-]{1,63}\\.)+[[:alpha:]]+\\^(\\$third-party)?$/{print tolower($3)}",
		"size": "L",
		"descr": "general"
	},
	[...]
```

Add an unique feed name (no spaces, no special chars) and make the required changes: adapt at least the URL, the regex rule, the size and the description for a new feed.  

## Support
Please join the adblock discussion in this [forum thread](https://forum.openwrt.org/t/adblock-support-thread/507) or contact me by mail <dev@brenken.org>

## Removal
Stop all adblock related services with _/etc/init.d/adblock stop_ and remove the adblock package if necessary.

## Donations
You like this project - is there a way to donate? Generally speaking "No" - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.

If you still insist to donate some bucks ...
* I would be happy if you put your money in kind into other, social projects in your area, e.g. a children's hospice
* Let's meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
* Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken) and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!

Have fun!
Dirk
