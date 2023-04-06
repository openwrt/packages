<!-- markdownlint-disable -->

# banIP - ban incoming and outgoing IP addresses/subnets via sets in nftables

## Description
IP address blocking is commonly used to protect against brute force attacks, prevent disruptive or unauthorized address(es) from access or it can be used to restrict access to or from a particular geographic area — for example. Further more banIP scans the log file via logread and bans IP addresses that make too many password failures, e.g. via ssh.  

## Main Features
* banIP supports the following fully pre-configured domain blocklist feeds (free for private usage, for commercial use please check their individual licenses).  
  **Please note:** the columns "WAN-INP", "WAN-FWD" and "LAN-FWD" show for which chains the feeds are suitable in common scenarios, e.g. the first entry should be limited to the LAN forward chain - see the config options 'ban\_blockinput', 'ban\_blockforwardwan' and 'ban\_blockforwardlan' below.  

| Feed                | Focus                          | WAN-INP | WAN-FWD | LAN-FWD | Information                                                   |
| :------------------ | :----------------------------- | :-----: | :-----: | :-----: | :-----------------------------------------------------------  |
| adaway              | adaway IPs                     |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| adguard             | adguard IPs                    |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| adguardtrackers     | adguardtracker IPs             |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| antipopads          | antipopads IPs                 |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| asn                 | ASN IPs                        |         |         |    x    | [Link](https://asn.ipinfo.app)                                |
| backscatterer       | backscatterer IPs              |    x    |    x    |         | [Link](https://www.uceprotect.net/en/index.php)               |
| bogon               | bogon prefixes                 |    x    |    x    |         | [Link](https://team-cymru.com)                                |
| country             | country blocks                 |    x    |    x    |         | [Link](https://www.ipdeny.com/ipblocks)                       |
| cinsscore           | suspicious attacker IPs        |    x    |    x    |         | [Link](https://cinsscore.com/#list)                           |
| darklist            | blocks suspicious attacker IPs |    x    |    x    |         | [Link](https://darklist.de)                                   |
| debl                | fail2ban IP blacklist          |    x    |    x    |         | [Link](https://www.blocklist.de)                              |
| doh                 | public DoH-Provider            |         |         |    x    | [Link](https://github.com/dibdot/DoH-IP-blocklists)           |
| drop                | spamhaus drop compilation      |    x    |    x    |         | [Link](https://www.spamhaus.org)                              |
| dshield             | dshield IP blocklist           |    x    |    x    |         | [Link](https://www.dshield.org)                               |
| edrop               | spamhaus edrop compilation     |    x    |    x    |         | [Link](https://www.spamhaus.org)                              |
| feodo               | feodo tracker                  |    x    |    x    |    x    | [Link](https://feodotracker.abuse.ch)                         |
| firehol1            | firehol level 1 compilation    |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=firehol_level1)     |
| firehol2            | firehol level 2 compilation    |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=firehol_level2)     |
| firehol3            | firehol level 3 compilation    |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=firehol_level3)     |
| firehol4            | firehol level 4 compilation    |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=firehol_level4)     |
| greensnow           | suspicious server IPs          |    x    |    x    |         | [Link](https://greensnow.co)                                  |
| iblockads           | Advertising IPs                |         |         |    x    | [Link](https://www.iblocklist.com)                            |
| iblockspy           | Malicious spyware IPs          |    x    |    x    |         | [Link](https://www.iblocklist.com)                            |
| myip                | real-time IP blocklist         |    x    |    x    |         | [Link](https://myip.ms)                                       |
| nixspam             | iX spam protection             |    x    |    x    |         | [Link](http://www.nixspam.org)                                |
| oisdbig             | OISD-big IPs                   |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| oisdnsfw            | OISD-nsfw IPs                  |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| oisdsmall           | OISD-small IPs                 |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| proxy               | open proxies                   |    x    |         |         | [Link](https://iplists.firehol.org/?ipset=proxylists)         |
| ssbl                | SSL botnet IPs                 |    x    |    x    |         | [Link](https://sslbl.abuse.ch)                                |
| stevenblack         | stevenblack IPs                |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |
| talos               | talos IPs                      |    x    |    x    |         | [Link](https://talosintelligence.com/reputation_center)       |
| threat              | emerging threats               |    x    |    x    |         | [Link](https://rules.emergingthreats.net)                     |
| threatview          | malicious IPs                  |    x    |    x    |         | [Link](https://threatview.io)                                 |
| tor                 | tor exit nodes                 |    x    |    x    |         | [Link](https://github.com/SecOps-Institute/Tor-IP-Addresses)  |
| uceprotect1         | spam protection level 1        |    x    |    x    |         | [Link](http://www.uceprotect.net/en/index.php)                |
| uceprotect2         | spam protection level 2        |    x    |    x    |         | [Link](http://www.uceprotect.net/en/index.php)                |
| uceprotect3         | spam protection level 3        |    x    |    x    |         | [Link](http://www.uceprotect.net/en/index.php)                |
| urlhaus             | urlhaus IDS IPs                |    x    |    x    |         | [Link](https://urlhaus.abuse.ch)                              |
| urlvir              | malware related IPs            |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=urlvir)             |
| webclient           | malware related IPs            |    x    |    x    |         | [Link](https://iplists.firehol.org/?ipset=firehol_webclient)  |
| voip                | VoIP fraud blocklist           |    x    |    x    |         | [Link](https://voipbl.org)                                    |
| yoyo                | yoyo IPs                       |         |         |    x    | [Link](https://github.com/dibdot/banIP-IP-blocklists)         |

* Zero-conf like automatic installation & setup, usually no manual changes needed
* All sets are handled in a separate nft table/namespace 'banIP'
* Full IPv4 and IPv6 support
* Supports nft atomic set loading
* Supports blocking by ASN numbers and by iso country codes
* Supports local allow- and blocklist (IPv4, IPv6, CIDR notation or domain names)
* Auto-add the uplink subnet to the local allowlist
* Provides a small background log monitor to ban unsuccessful login attempts in real-time
* Auto-add unsuccessful LuCI, nginx, Asterisk or ssh login attempts to the local blocklist
* Fast feed processing as they are handled in parallel as background jobs
* Per feed it can be defined whether the wan-input chain, the wan-forward chain or the lan-forward chain should be blocked (default: all chains)
* Automatic blocklist backup & restore, the backups will be used in case of download errors or during startup
* Automatically selects one of the following download utilities with ssl support: aria2c, curl, uclient-fetch or wget
* Supports an 'allowlist only' mode, this option restricts internet access from/to a small number of secure websites/IPs
* Deduplicate IPs accross all sets (single IPs only, no intervals)
* Provides comprehensive runtime information
* Provides a detailed set report
* Provides a set search engine for certain IPs
* Feed parsing by fast & flexible regex rulesets
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support (start/stop/restart/reload/status/report/search/survey/lookup)
* Procd network interface trigger support
* Ability to add new banIP feeds on your own

## Prerequisites
* **[OpenWrt](https://openwrt.org)**, latest stable release or a snapshot with nft/firewall 4 support
* A download utility with SSL support: 'wget', 'uclient-fetch' with one of the 'libustream-*' SSL libraries, 'aria2c' or 'curl' is required
* A certificate store like 'ca-bundle', as banIP checks the validity of the SSL certificates of all download sites by default
* For E-Mail notifications you need to install and setup the additional 'msmtp' package

**Please note the following:**
* Devices with less than 256Mb of RAM are **_not_** supported
* Any previous installation of ancient banIP 0.7.x must be uninstalled, and the /etc/banip folder and the /etc/config/banip configuration file must be deleted (they are recreated when this version is installed)

## Installation & Usage
* Update your local opkg repository (_opkg update_)
* Install banIP (_opkg install banip_) - the banIP service is disabled by default
* Install the LuCI companion package 'luci-app-banip' (opkg install luci-app-banip)
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of banIP, the application is located in LuCI under the 'Services' menu
* If you're going to configure banIP via CLI, edit the config file '/etc/config/banip' and enable the service (set ban\_enabled to '1'), then add pre-configured feeds via 'ban\_feed' (see the feed list above) and add/change other options to your needs (see the options reference below)
* Start the service with '/etc/init.d/banip start' and check check everything is working by running '/etc/init.d/banip status'

## banIP CLI interface
* All important banIP functions are accessible via CLI.
```
~# /etc/init.d/banip
Syntax: /etc/init.d/banip [command]

Available commands:
	start           Start the service
	stop            Stop the service
	restart         Restart the service
	reload          Reload configuration files (or restart if service does not implement reload)
	enable          Enable service autostart
	disable         Disable service autostart
	enabled         Check if service is started on boot
	report          [text|json|mail] Print banIP related set statistics
	search          [<IPv4 address>|<IPv6 address>] Check if an element exists in a banIP set
	survey          [<set name>] List all elements of a given banIP set
	lookup          Lookup the IPs of domain names in the local lists and update them
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

## banIP config options

| Option                  | Type   | Default                       | Description                                                                           |
| :---------------------- | :----- | :---------------------------- | :------------------------------------------------------------------------------------ |
| ban_enabled             | option | 0                             | enable the banIP service                                                              |
| ban_nicelimit           | option | 0                             | ulimit nice level of the banIP service (range 0-19)                                   |
| ban_filelimit           | option | 1024                          | ulimit max open/number of files (range 1024-4096)                                     |
| ban_loglimit            | option | 100                           | the logread monitor scans only the last n lines of the logfile                        |
| ban_logcount            | option | 1                             | how many times the IP must appear in the log to be considered as suspicious           |
| ban_logterm             | list   | regex                         | various regex for logfile parsing (default: dropbear, sshd, luci, nginx, asterisk)    |
| ban_autodetect          | option | 1                             | auto-detect wan interfaces, devices and subnets                                       |
| ban_debug               | option | 0                             | enable banIP related debug logging                                                    |
| ban_loginput            | option | 1                             | log drops in the wan-input chain                                                      |
| ban_logforwardwan       | option | 1                             | log drops in the wan-forward chain                                                    |
| ban_logforwardlan       | option | 0                             | log rejects in the lan-forward chain                                                  |
| ban_autoallowlist       | option | 1                             | add wan IPs/subnets automatically to the local allowlist                              |
| ban_autoblocklist       | option | 1                             | add suspicious attacker IPs automatically to the local blocklist                      |
| ban_allowlistonly       | option | 0                             | restrict the internet access from/to a small number of secure websites/IPs            |
| ban_basedir             | option | /tmp                          | base working directory while banIP processing                                         |
| ban_reportdir           | option | /tmp/banIP-report             | directory where banIP stores the report files                                         |
| ban_backupdir           | option | /tmp/banIP-backup             | directory where banIP stores the compressed backup files                              |
| ban_protov4             | option | - / autodetect                | enable IPv4 support                                                                   |
| ban_protov6             | option | - / autodetect                | enable IPv4 support                                                                   |
| ban_ifv4                | list   | - / autodetect                | logical wan IPv4 interfaces, e.g. 'wan'                                               |
| ban_ifv6                | list   | - / autodetect                | logical wan IPv6 interfaces, e.g. 'wan6'                                              |
| ban_dev                 | list   | - / autodetect                | wan device(s), e.g. 'eth2'                                                            |
| ban_trigger             | list   | -                             | logical startup trigger interface(s), e.g. 'wan'                                      |
| ban_triggerdelay        | option | 10                            | trigger timeout before banIP processing begins                                        |
| ban_triggeraction       | option | start                         | trigger action on ifup events, e.g. start, restart or reload                          |
| ban_deduplicate         | option | 1                             | deduplicate IP addresses across all active sets                                       |
| ban_splitsize           | option | 0                             | split ext. sets after every n lines/members (saves RAM)                               |
| ban_cores               | option | - / autodetect                | limit the cpu cores used by banIP (saves RAM)                                         |
| ban_nftloglevel         | option | warn                          | nft loglevel, values: emerg, alert, crit, err, warn, notice, info, debug, audit       |
| ban_nftpriority         | option | -200                          | nft priority for the banIP table (default is the prerouting table priority)           |
| ban_nftpolicy           | option | memory                        | nft policy for banIP-related sets, values: memory, performance                        |
| ban_nftexpiry           | option | -                             | expiry time for auto added blocklist members, e.g. '5m', '2h' or '1d'                 |
| ban_feed                | list   | -                             | external download feeds, e.g. 'yoyo', 'doh', 'country' or 'talos' (see feed table)    |
| ban_asn                 | list   | -                             | ASNs for the 'asn' feed, e.g.'32934'                                                  |
| ban_country             | list   | -                             | country iso codes for the 'country' feed, e.g. 'ru'                                   |
| ban_blockinput          | list   | -                             | limit a feed to the wan-input chain, e.g. 'country'                                   |
| ban_blockforwardwan     | list   | -                             | limit a feed to the wan-forward chain, e.g. 'debl'                                    |
| ban_blockforwardlan     | list   | -                             | limit a feed to the lan-forward chain, e.g. 'doh'                                     |
| ban_fetchcmd            | option | - / autodetect                | 'uclient-fetch', 'wget', 'curl' or 'aria2c'                                           |
| ban_fetchparm           | option | - / autodetect                | set the config options for the selected download utility                              |
| ban_fetchinsecure       | option | 0                             | don't check SSL server certificates during download                                   |
| ban_mailreceiver        | option | -                             | receiver address for banIP related notification E-Mails                               |
| ban_mailsender          | option | no-reply@banIP                | sender address for banIP related notification E-Mails                                 |
| ban_mailtopic           | option | banIP notification            | topic for banIP related notification E-Mails                                          |
| ban_mailprofile         | option | ban_notify                    | mail profile used in 'msmtp' for banIP related notification E-Mails                   |
| ban_mailnotification    | option | 0                             | receive E-Mail notifications with every banIP run                                     |
| ban_reportelements      | option | 1                             | list set elements in the report, disable this to speed up the report significantly    |
| ban_resolver            | option | -                             | external resolver used for DNS lookups                                                |

## Examples
**banIP report information**  
```
~# /etc/init.d/banip report
:::
::: banIP Set Statistics
:::
    Timestamp: 2023-02-25 08:35:37
    ------------------------------
    auto-added to allowlist: 0
    auto-added to blocklist: 4

    Set                  | Elements     | WAN-Input (packets)   | WAN-Forward (packets) | LAN-Forward (packets)
    ---------------------+--------------+-----------------------+-----------------------+------------------------
    allowlistvMAC        | 0            | -                     | -                     | OK: 0                 
    allowlistv4          | 15           | OK: 0                 | OK: 0                 | OK: 0                 
    allowlistv6          | 1            | OK: 0                 | OK: 0                 | OK: 0                 
    torv4                | 800          | OK: 0                 | OK: 0                 | OK: 0                 
    torv6                | 432          | OK: 0                 | OK: 0                 | OK: 0                 
    countryv6            | 34282        | OK: 0                 | OK: 1                 | -                     
    countryv4            | 35508        | OK: 1872              | OK: 0                 | -                     
    dohv6                | 343          | -                     | -                     | OK: 0                 
    dohv4                | 540          | -                     | -                     | OK: 3                 
    firehol1v4           | 1670         | OK: 296               | OK: 0                 | OK: 16                
    deblv4               | 12402        | OK: 4                 | OK: 0                 | OK: 0                 
    deblv6               | 41           | OK: 0                 | OK: 0                 | OK: 0                 
    adguardv6            | 12742        | -                     | -                     | OK: 161               
    adguardv4            | 23183        | -                     | -                     | OK: 212               
    adguardtrackersv6    | 169          | -                     | -                     | OK: 0                 
    adguardtrackersv4    | 633          | -                     | -                     | OK: 0                 
    adawayv6             | 2737         | -                     | -                     | OK: 15                
    adawayv4             | 6542         | -                     | -                     | OK: 137               
    oisdsmallv6          | 10569        | -                     | -                     | OK: 0                 
    oisdsmallv4          | 18800        | -                     | -                     | OK: 74                
    stevenblackv6        | 11901        | -                     | -                     | OK: 4                 
    stevenblackv4        | 16776        | -                     | -                     | OK: 139               
    yoyov6               | 215          | -                     | -                     | OK: 0                 
    yoyov4               | 309          | -                     | -                     | OK: 0                 
    antipopadsv4         | 1872         | -                     | -                     | OK: 0                 
    urlhausv4            | 7431         | OK: 0                 | OK: 0                 | OK: 0                 
    antipopadsv6         | 2081         | -                     | -                     | OK: 2                 
    blocklistvMAC        | 0            | -                     | -                     | OK: 0                 
    blocklistv4          | 1174         | OK: 1                 | OK: 0                 | OK: 0                 
    blocklistv6          | 40           | OK: 0                 | OK: 0                 | OK: 0                 
    ---------------------+--------------+-----------------------+-----------------------+------------------------
    30                   | 203208       | 12 (2173)             | 12 (1)                | 28 (763)
```

**banIP runtime information**  
```
~# /etc/init.d/banip status
::: banIP runtime information
  + status            : active (nft: ✔, monitor: ✔)
  + version           : 0.8.3-1
  + element_count     : 281161
  + active_feeds      : allowlistvMAC, allowlistv6, allowlistv4, adawayv4, adguardtrackersv4, adawayv6, adguardv6, adguardv4, adguardtrackersv6, antipopadsv6, antipopadsv4, cinsscorev4, deblv4, countryv6, countryv4, deblv6, dohv4, dohv6, iblockadsv4, firehol1v4, oisdbigv4, yoyov6, threatviewv4, yoyov4, oisdbigv6, blocklistvMAC, blocklistv4, blocklistv6
  + active_devices    : br-wan ::: wan, wan6
  + active_subnets    : 91.64.169.252/24, 2a02:710c:0:60:958b:3bd0:9e14:abb/128
  + nft_info          : priority: -200, policy: memory, loglevel: warn, expiry: -
  + run_info          : base: /mnt/data/banIP, backup: /mnt/data/banIP/backup, report: /mnt/data/banIP/report, feed: /etc/banip/banip.feeds
  + run_flags         : auto: ✔, proto (4/6): ✔/✔, log (wan-inp/wan-fwd/lan-fwd): ✔/✔/✔, dedup: ✔, split: ✘, allowed only: ✘
  + last_run          : action: reload, duration: 1m 0s, date: 2023-04-06 12:34:10
  + system_info       : cores: 4, memory: 1822, device: Bananapi BPI-R3, OpenWrt SNAPSHOT r22498-75f7e2d10b
```

**banIP search information**  
```
~# /etc/init.d/banip search 221.228.105.173
:::
::: banIP Search
:::
    Looking for IP '221.228.105.173' on 2023-02-08 22:12:48
    ---
    IP found in Set 'oisdbasicv4'
```

**banIP survey information**  
```
~# /etc/init.d/banip survey cinsscorev4
:::
::: banIP Survey
:::
    List the elements of Set 'cinsscorev4' on 2023-03-06 14:07:58
    ---
1.10.187.179
1.10.203.30
1.10.255.58
1.11.67.53
1.11.114.211
1.11.208.29
1.12.75.87
1.12.231.227
1.12.247.134
1.12.251.141
1.14.96.156
1.14.250.37
1.15.40.79
1.15.71.140
1.15.77.237
[...]
```
**default regex for logfile parsing**  
```
list ban_logterm 'Exit before auth from'
list ban_logterm 'luci: failed login'
list ban_logterm 'error: maximum authentication attempts exceeded'
list ban_logterm 'sshd.*Connection closed by.*\[preauth\]'
list ban_logterm 'SecurityEvent=\"InvalidAccountID\".*RemoteAddress='
```

**allow-/blocklist handling**  
banIP supports local allow and block lists (IPv4, IPv6, CIDR notation or domain names), located in /etc/banip/banip.allowlist and /etc/banip/banip.blocklist.  
Unsuccessful login attempts or suspicious requests will be tracked and added to the local blocklist (see the 'ban\_autoblocklist' option). The blocklist behaviour can be further tweaked with the 'ban\_nftexpiry' option.  
Furthermore the uplink subnet will be added to local allowlist (see 'ban\_autoallowlist' option).  
Both lists also accept domain names as input to allow IP filtering based on these names. The corresponding IPs (IPv4 & IPv6) will be extracted and added to the sets. You can also start the domain lookup separately via /etc/init.d/banip lookup at any time.

**allowlist-only mode**  
banIP supports an "allowlist only" mode. This option restricts the internet access from/to a small number of secure websites/IPs, and block access from/to the rest of the internet. All IPs and Domains which are _not_ listed in the allowlist are blocked.

**redirect Asterisk security logs to lodg/logread**  
banIP only supports logfile scanning via logread, so to monitor attacks on Asterisk, its security log must be available via logread. To do this, edit '/etc/asterisk/logger.conf' and add the line 'syslog.local0 = security', then run 'asterisk -rx reload logger' to update the running Asterisk configuration.

**send status E-Mails and update the banIP lists via cron job**  
For a regular, automatic status mailing and update of the used lists on a daily basis set up a cron job, e.g.
```
55 03 * * * /etc/init.d/banip report mail
00 04 * * * /etc/init.d/banip reload
```

**tweaks for low memory systems**  
nftables supports the atomic loading of rules/sets/members, which is cool but unfortunately is also very memory intensive. To reduce the memory pressure on low memory systems (i.e. those with 256-512Mb RAM), you should optimize your configuration with the following options:  

    * point 'ban_basedir', 'ban_reportdir' and 'ban_backupdir' to an external usb drive
    * set 'ban_cores' to '1' (only useful on a multicore system) to force sequential feed processing
    * set 'ban_splitsize' e.g. to '1000' to split the load of an external set after every 1000 lines/members
    * set 'ban_reportelements' to '0' to disable the CPU intensive counting of set elements

**tweak the download options**  
By default banIP uses the following pre-configured download options:
```
    * aria2c: --timeout=20 --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o
    * curl: --connect-timeout 20 --fail --silent --show-error --location -o
    * uclient-fetch: --timeout=20 -O
    * wget: --no-cache --no-cookies --max-redirect=0 --timeout=20 -O
```
To override the default set 'ban_fetchparm' manually to your needs.

**send E-Mail notifications via 'msmtp'**  
To use the email notification you must install & configure the package 'msmtp'.  
Modify the file '/etc/msmtprc', e.g.:
```
[...]
defaults
auth            on
tls             on
tls_certcheck   off
timeout         5
syslog          LOG_MAIL
[...]
account         ban_notify
host            smtp.gmail.com
port            587
from            <address>@gmail.com
user            <gmail-user>
password        <password>
```
Finally add a valid E-Mail receiver address.

**change existing banIP feeds or add a new one**  
The banIP blocklist feeds are stored in an external JSON file '/etc/banip/banip.feeds'.  
A valid JSON source object contains the following required information, e.g.:
```
	[...]
	"tor": {
		"url_4": "https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst",
		"url_6": "https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst",
		"rule_4": "/^(([0-9]{1,3}\\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\\/(1?[0-9]|2?[0-9]|3?[0-2]))?)$/{printf \"%s,\\n\",$1}",
		"rule_6": "/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\\/(1?[0-2][0-8]|[0-9][0-9]))?)$/{printf \"%s,\\n\",$1}",
		"focus": "tor exit nodes",
		"descurl": "https://github.com/SecOps-Institute/Tor-IP-Addresses"
	},
	[...]
```
Add an unique object name (no spaces, no special chars) and make the required changes: adapt at least the URL the regex to the new feed.  
**Please note:** if you're going to add new feeds, **always** make a backup of your work, cause this file is always overwritten with the maintainers version on every banIP update.  

## Support
Please join the banIP discussion in this [forum thread](https://forum.openwrt.org/t/banip-support-thread/16985) or contact me by mail <dev@brenken.org>

## Removal
* stop all banIP related services with _/etc/init.d/banip stop_
* remove the banip package (_opkg remove banip_)

Have fun!  
Dirk
