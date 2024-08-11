<!-- markdownlint-disable -->

# DNS based ad/abuse domain blocking

## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other (wlan) gadget!? Getting rid of annoying ads, trackers and other abuse sites (like facebook) is simple: block them with your router. When the DNS server on your router receives DNS requests, you will sort out queries that ask for the resource records of ad servers and return a simple 'NXDOMAIN'. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if domain name is unable to resolved using the DNS server, a condition called the 'NXDOMAIN' occurred.  

## Main Features
* Support of the following fully pre-configured domain blocklist sources (free for private usage, for commercial use please check their individual licenses)

| Source              | Enabled | Size | Focus            | Information                                                                       |
| :------------------ | :-----: | :--- | :--------------- | :-------------------------------------------------------------------------------- |
| 1Hosts              |         | VAR  | compilation      | [Link](https://github.com/badmojr/1Hosts)                                         |
| adaway              |         | S    | mobile           | [Link](https://github.com/AdAway/adaway.github.io)                                |
| adguard             | x       | L    | general          | [Link](https://adguard.com)                                                       |
| adguard_tracking    |         | L    | tracking         | [Link](https://github.com/AdguardTeam/cname-trackers)                             |
| android_tracking    |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| andryou             |         | L    | compilation      | [Link](https://gitlab.com/andryou/block/-/blob/master/readme.md)                  |
| anti_ad             |         | L    | compilation      | [Link](https://github.com/privacy-protection-tools/anti-AD/blob/master/README.md) |
| antipopads          |         | L    | compilation      | [Link](https://github.com/AdroitAdorKhan/antipopads-re)                           |
| anudeep             |         | M    | compilation      | [Link](https://github.com/anudeepND/blacklist)                                    |
| bitcoin             |         | S    | mining           | [Link](https://github.com/hoshsadiq/adblock-nocoin-list)                          |
| cpbl                |         | XL   | compilation      | [Link](https://github.com/bongochong/CombinedPrivacyBlockLists)                   |
| disconnect          |         | S    | general          | [Link](https://disconnect.me)                                                     |
| doh_blocklist       |         | S    | doh_server       | [Link](https://github.com/dibdot/DoH-IP-blocklists)                               |
| easylist            |         | M    | compilation      | [Link](https://easylist.to)                                                       |
| easyprivacy         |         | M    | tracking         | [Link](https://easylist.to)                                                       |
| firetv_tracking     |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| games_tracking      |         | S    | tracking         | [Link](https://www.gameindustry.eu)                                               |
| hagezi              |         | VAR  | compilation      | [Link](https://github.com/hagezi/dns-blocklists)                                  |
| hblock              |         | XL   | compilation      | [Link](https://hblock.molinero.dev)                                               |
| lightswitch05       |         | XL   | compilation      | [Link](https://github.com/lightswitch05/hosts)                                    |
| notracking          |         | XL   | tracking         | [Link](https://github.com/notracking/hosts-blocklists)                            |
| oisd_big            |         | XXL  | general          | [Link](https://oisd.nl)                                                           |
| oisd_nsfw           |         | XXL  | porn             | [Link](https://oisd.nl)                                                           |
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
    • <b>S</b> (-10k), <b>M</b> (10k-30k) and <b>L</b> (30k-80k) should work for 128 MByte devices,  
    • <b>XL</b> (80k-200k) should work for 256-512 MByte devices,  
    • <b>XXL</b> (200k-) needs more RAM and Multicore support, e.g. x86 or raspberry devices.  
    • <b>VAR</b> (50k-900k) variable size depending on the selection.  
* Zero-conf like automatic installation & setup, usually no manual changes needed
* Simple but yet powerful adblock engine: adblock does not use error prone external iptables rulesets, http pixel server instances and things like that
* Supports five different DNS backend formats: dnsmasq, unbound, named (bind), kresd or raw (e.g. used by dnscrypt-proxy)
* Supports four different SSL-enabled download utilities: uclient-fetch, wget, curl or aria2c
* Supports SafeSearch for google, bing, duckduckgo, yandex, youtube and pixabay
* Supports RPZ-trigger 'RPZ-CLIENT-IP' to always allow/deny certain DNS clients based on their IP address (currently only supported by bind dns backend)
* Fast downloads & list processing as they are handled in parallel running background jobs with multicore support
* Supports a wide range of router modes, even AP modes are supported
* Full IPv4 and IPv6 support
* Provides top level domain compression ('tld compression'), this feature removes thousands of needless host entries from the blocklist and lowers the memory footprint for the DNS backend
* Provides a 'DNS File Reset', where the generated DNS blocklist file will be purged after DNS backend loading to save storage space
* Source parsing by fast & flexible regex rulesets, all rules and source information are placed in an external/compredd JSON file ('/etc/adblock/adblock.sources.gz')
* Overall duplicate removal in generated blocklist file 'adb_list.overall'
* Additional local blacklist for manual overrides, located in '/etc/adblock/adblock.blacklist'
* Additional local whitelist for manual overrides, located in '/etc/adblock/adblock.whitelist'
* Quality checks during blocklist update to ensure a reliable DNS backend service
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support ('start', 'stop', 'restart', 'reload', 'enable', 'disable', 'running', 'status', 'suspend',  'resume', 'query', 'report', 'list', 'timer')
* Auto-Startup via procd network interface trigger or via classic time based startup
* Suspend & Resume adblock temporarily without blocklist reloading
* Provides comprehensive runtime information
* Provides a detailed DNS Query Report with DNS related information about client requests, top (blocked) domains and more
* Provides a powerful query function to quickly find blocked (sub-)domains, e.g. for whitelisting
* Provides an easily configurable blocklist update scheduler called 'Refresh Timer'
* Includes an option to generate an additional, restrictive 'adb_list.jail' to block access to all domains except those listed in the whitelist file. You can use this restrictive blocklist manually e.g. for guest wifi or kidsafe configurations
* Includes an option to force DNS requests to the local resolver
* Automatic blocklist backup & restore, these backups will be used in case of download errors and during startup
* Send notification E-Mails in case of a processing error or if the overall domain count is &le; 0
* Add new adblock sources on your own, see example below
* Strong LuCI support, all relevant options are exposed to the web frontend

## Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series and with the latest rolling snapshot releases.  
  <b>Please note:</b> Devices with less than 128 MByte RAM are _not_ supported!  
* A usual setup with an enabled DNS backend at minimum - dumb AP modes without a working DNS backend are _not_ supported
* A download utility with SSL support: 'wget', 'uclient-fetch' with one of the 'libustream-*' ssl libraries, 'aria2c' or 'curl' is required
* A certificate store such as 'ca-bundle' or 'ca-certificates', as adblock checks the validity of the SSL certificates of all download sites by default
* Optional E-Mail notification support: for E-Mail notifications you need to install the additional 'msmtp' package
* Optional DNS Query Report support: for DNS reporting you need to install the additional package 'tcpdump-mini' or 'tcpdump'

## Installation & Usage
* Update your local opkg repository (_opkg update_)
* Install 'adblock' (_opkg install adblock_). The adblock service is enabled by default
* Install the LuCI companion package 'luci-app-adblock' (_opkg install luci-app-adblock_)
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of adblock, the application is located in LuCI under the 'Services' menu
* Update from a former adblock version is easy. During the update a backup is made of the old configuration '/etc/config/adblock-backup' and replaced by the new config - that's all

## Adblock CLI Options
* All important adblock functions are accessible via CLI as well.  
<pre><code>
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
	query           &lt;domain&gt; Query active blocklists and backups for a specific domain
	report          [&lt;search&gt;] Print DNS statistics with an optional search parameter
	list            List available sources
	timer           [&lt;add&gt; &lt;tasks&gt; &lt;hour&gt; [&lt;minute&gt;] [&lt;weekday&gt;]]|[&lt;remove&gt; &lt;line no.&gt;] List/Edit cron update intervals
	version         Print version information
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
</code></pre>

## Adblock Config Options
* Usually the auto pre-configured adblock setup works quite well and no manual overrides are needed

| Option             | Default                            | Description/Valid Values                                                                       |
| :----------------- | :--------------------------------- | :--------------------------------------------------------------------------------------------- |
| adb_enabled        | 1, enabled                         | set to 0 to disable the adblock service                                                        |
| adb_srcarc         | -, /etc/adblock/adblock.sources.gz | full path to the used adblock source archive                                                   |
| adb_srcfile        | -, /tmp/adb_sources.json           | full path to the used adblock source file, which has a higher precedence than the archive file |
| adb_dns            | -, auto-detected                   | 'dnsmasq', 'unbound', 'named', 'kresd' or 'raw'                                                |
| adb_fetchutil      | -, auto-detected                   | 'uclient-fetch', 'wget', 'curl' or 'aria2c'                                                    |
| adb_fetchparm      | -, auto-detected                   | manually override the config options for the selected download utility                         |
| adb_fetchinsecure  | 0, disabled                        | don't check SSL server certificates during download                                            |
| adb_trigger        | -, not set                         | trigger network interface or 'not set' to use a time-based startup                             |
| adb_triggerdelay   | 2                                  | additional trigger delay in seconds before adblock processing begins                           |
| adb_debug          | 0, disabled                        | set to 1 to enable the debug output                                                            |
| adb_nice           | 0, standard prio.                  | valid nice level range 0-19 of the adblock processes                                           |
| adb_forcedns       | 0, disabled                        | set to 1 to force DNS requests to the local resolver                                           |
| adb_dnsdir         | -, auto-detected                   | path for the generated blocklist file 'adb_list.overall'                                       |
| adb_dnstimeout     | 10                                 | timeout in seconds to wait for a successful DNS backend restart                                |
| adb_dnsinstance    | 0, first instance                  | set to the relevant dns backend instance used by adblock (dnsmasq only)                        |
| adb_dnsflush       | 0, disabled                        | set to 1 to flush the DNS Cache before & after adblock processing                              |
| adb_dnsallow       | -, not set                         | set to 1 to disable selective DNS whitelisting (RPZ-PASSTHRU)                                  |
| adb_lookupdomain   | example.com                        | external domain to check for a successful DNS backend restart or 'false' to disable this check |
| adb_portlist       | 53 853 5353                        | space separated list of firewall ports which should be redirected locally                      |
| adb_report         | 0, disabled                        | set to 1 to enable the background tcpdump gathering process for reporting                      |
| adb_reportdir      | /tmp                               | path for DNS related report files                                                              |
| adb_repiface       | -, auto-detected                   | name of the reporting interface or 'any' used by tcpdump                                       |
| adb_replisten      | 53                                 | space separated list of reporting port(s) used by tcpdump                                      |
| adb_repchunkcnt    | 5                                  | report chunk count used by tcpdump                                                             |
| adb_repchunksize   | 1                                  | report chunk size used by tcpdump in MB                                                        |
| adb_represolve     | 0, disabled                        | resolve reporting IP addresses using reverse DNS (PTR) lookups                                 |
| adb_backup         | 1, enabled                         | set to 0 to disable the backup function                                                        |
| adb_backupdir      | /tmp                               | path for adblock backups                                                                       |
| adb_tmpbase        | /tmp                               | path for all adblock related runtime operations, e.g. downloading, sorting, merging etc.       |
| adb_safesearch     | 0, disabled                        | set to 1 to enforce SafeSearch for google, bing, duckduckgo, yandex, youtube and pixabay       |
| adb_safesearchlist | -, not set                         | Limit SafeSearch to certain provider (see above)                                               |
| adb_safesearchmod  | 0, disabled                        | set to 1 to enable moderate SafeSearch filters for youtube                                     |
| adb_mail           | 0, disabled                        | set to 1 to enable notification E-Mails in case of a processing errors                         |
| adb_mailreceiver   | -, not set                         | receiver address for adblock notification E-Mails                                              |
| adb_mailsender     | no-reply@adblock                   | sender address for adblock notification E-Mails                                                |
| adb_mailtopic      | adblock&nbsp;notification          | topic for adblock notification E-Mails                                                         |
| adb_mailprofile    | adb_notify                         | mail profile used in 'msmtp' for adblock notification E-Mails                                  |
| adb_mailcnt        | 0                                  | minimum domain count to trigger E-Mail notifications                                           |
| adb_jail           | 0                                  | set to 1 to enable the additional, restrictive 'adb_list.jail' creation                        |
| adb_jaildir        | /tmp                               | path for the generated jail list                                                               |

## Examples
**Change the DNS backend to 'unbound':**  
No further configuration is needed, adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/unbound' by default.  
To preserve the DNS cache after adblock processing please install the additional package 'unbound-control'.

**Change the DNS backend to 'bind':**  
Adblock deposits the final blocklist 'adb_list.overall' in '/var/lib/bind' by default.  
To preserve the DNS cache after adblock processing please install the additional package 'bind-rdnc'.
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

**Change the DNS backend to 'kresd':**  
Adblock deposits the final blocklist 'adb_list.overall' in '/etc/kresd', no further configuration needed.  
<b>Please note:</b> The knot-resolver (kresd) is only available on Turris devices and does not support the SafeSearch functionality yet.

**Use restrictive jail modes:**  
You can enable a restrictive 'adb_list.jail' to block access to all domains except those listed in the whitelist file. Usually this list will be generated as an additional list for guest or kidsafe configurations (for a separate dns server instance). If the jail directory points to your primary dns directory, adblock enables the restrictive jail mode automatically (jail mode only).

**Manually override the download options:**  
By default adblock uses the following pre-configured download options:  
* aria2c: <code>--timeout=20 --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o</code>
* curl: <code>--connect-timeout 20 --silent --show-error --location -o</code>
* uclient-fetch: <code>--timeout=20 -O</code>
* wget: <code>--no-cache --no-cookies --max-redirect=0 --timeout=20 -O</code>

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

**Service status output:**  
In LuCI you'll see the realtime status in the 'Runtime' section on the overview page.  
To get the status in the CLI, just call _/etc/init.d/adblock status_ or _/etc/init.d/adblock status\_service_:
<pre><code>
~#@blackhole:~# /etc/init.d/adblock status
::: adblock runtime information
  + adblock_status  : enabled
  + adblock_version : 4.1.4
  + blocked_domains : 268355
  + active_sources  : adaway, adguard, adguard_tracking, android_tracking, bitcoin, disconnect, firetv_tracking, games_t
                      racking, hblock, oisd_basic, phishing_army, smarttv_tracking, stopforumspam, wally3k, winspy, yoyo
  + dns_backend     : unbound (unbound-control), /var/lib/unbound
  + run_utils       : download: /usr/bin/curl, sort: /usr/libexec/sort-coreutils, awk: /bin/busybox
  + run_ifaces      : trigger: wan, report: br-lan
  + run_directories : base: /tmp, backup: /mnt/data/adblock-Backup, report: /mnt/data/adblock-Report, jail: /tmp
  + run_flags       : backup: ✔, flush: ✘, force: ✔, search: ✘, report: ✔, mail: ✔, jail: ✘
  + last_run        : restart, 3m 17s, 249/73/68, 2022-09-10T13:43:07+02:00
  + system          : ASUS RT-AX53U, OpenWrt SNAPSHOT r20535-2ca5602864
</code></pre>
The 'last\_run' line includes the used start type, the run duration, the memory footprint after DNS backend loading (total/free/available) and the date/time of the last run.  

**Edit, add new adblock sources:**  
The adblock blocklist sources are stored in an external, compressed JSON file '/etc/adblock/adblock.sources.gz'. 
This file is directly parsed in LuCI and accessible via CLI, just call _/etc/init.d/adblock list_:
<pre><code>
/etc/init.d/adblock list
::: Available adblock sources
:::
    Name                 Enabled   Size   Focus               Info URL
    ------------------------------------------------------------------
  + adaway               x         S      mobile              https://adaway.org
  + adguard              x         L      general             https://adguard.com
  + andryou              x         L      compilation         https://gitlab.com/andryou/block/-/blob/master/readme.md
  + bitcoin              x         S      mining              https://github.com/hoshsadiq/adblock-nocoin-list
  + disconnect           x         S      general             https://disconnect.me
  + dshield                        XL     general             https://www.dshield.org
[...]
  + winhelp                        S      general             http://winhelp2002.mvps.org
  + winspy               x         S      win_telemetry       https://github.com/crazy-max/WindowsSpyBlocker
  + yoyo                 x         S      general             https://pgl.yoyo.org
</code></pre>

To add new or edit existing sources extract the compressed JSON file _gunzip /etc/adblock/adblock.sources.gz_.  
A valid JSON source object contains the following required information, e.g.:
<pre><code>
	[...]
	"adaway": {
		"url": "https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt",
		"rule": "/^127\\.0\\.0\\.1[[:space:]]+([[:alnum:]_-]+\\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower($2)}",
		"size": "S",
		"focus": "mobile",
		"descurl": "https://github.com/AdAway/adaway.github.io"
	},
	[...]
</code></pre>
Add an unique object name, make the required changes to 'url', 'rule', 'size' and 'descurl' and finally compress the changed JSON file _gzip /etc/adblock/adblock.sources_ to use the new source object in adblock.  
<b>Please note:</b> if you're going to add new sources on your own, please make a copy of the default file and work with that copy further on, cause the default will be overwritten with every adblock update. To reference your copy set the option 'adb\_srcarc' which points by default to '/etc/adblock/adblock.sources.gz'  
<b>Please note:</b> when adblock starts, it looks for the uncompressed 'adb\_srcfile', only if this file is not found the archive 'adb\_srcarc' is unpacked once and then the uncompressed file is used

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
