<!-- markdownlint-disable -->

# banIP - ban incoming and outgoing IP addresses/subnets via Sets in nftables

## Description
IP address blocking is commonly used to protect against brute force attacks, prevent disruptive or unauthorized address(es) from access or it can be used to restrict access to or from a particular geographic area — for example. Further more banIP scans the log file via logread and bans IPs that make too many password failures, e.g. via ssh.  

## Main Features
* banIP supports the following fully pre-configured domain blocklist feeds (free for private usage, for commercial use please check their individual licenses).  
  **Please note:** By default every feed blocks all supported chains. The columns "WAN-INP", "WAN-FWD" and "LAN-FWD" show for which chains the feeds are suitable in common scenarios, e.g. the first entry should be limited to the LAN forward chain - see the config options 'ban\_blockpolicy', 'ban\_blockinput', 'ban\_blockforwardwan' and 'ban\_blockforwardlan' below.  

| Feed                | Focus                          | WAN-INP | WAN-FWD | LAN-FWD | Port-Limit   | Information                                                  |
| :------------------ | :----------------------------- | :-----: | :-----: | :-----: | :----------: | :----------------------------------------------------------- |
| adaway              | adaway IPs                     |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| adguard             | adguard IPs                    |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| adguardtrackers     | adguardtracker IPs             |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| antipopads          | antipopads IPs                 |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| asn                 | ASN segments                   |         |         |    x    | tcp: 80, 443 | [Link](https://asn.ipinfo.app)                               |
| backscatterer       | backscatterer IPs              |    x    |    x    |         |              | [Link](https://www.uceprotect.net/en/index.php)              |
| binarydefense       | binary defense banlist         |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=bds_atif)          |
| bogon               | bogon prefixes                 |    x    |    x    |         |              | [Link](https://team-cymru.com)                               |
| bruteforceblock     | bruteforceblocker IPs          |    x    |    x    |         |              | [Link](https://danger.rulez.sk/index.php/bruteforceblocker/) |
| country             | country blocks                 |    x    |    x    |         |              | [Link](https://www.ipdeny.com/ipblocks)                      |
| cinsscore           | suspicious attacker IPs        |    x    |    x    |         |              | [Link](https://cinsscore.com/#list)                          |
| darklist            | blocks suspicious attacker IPs |    x    |    x    |         |              | [Link](https://darklist.de)                                  |
| debl                | fail2ban IP blacklist          |    x    |    x    |         |              | [Link](https://www.blocklist.de)                             |
| doh                 | public DoH-Provider            |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/DoH-IP-blocklists)          |
| drop                | spamhaus drop compilation      |    x    |    x    |         |              | [Link](https://www.spamhaus.org)                             |
| dshield             | dshield IP blocklist           |    x    |    x    |         |              | [Link](https://www.dshield.org)                              |
| edrop               | spamhaus edrop compilation     |    x    |    x    |         |              | [Link](https://www.spamhaus.org)                             |
| etcompromised       | ET compromised hosts           |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=et_compromised)    |
| feodo               | feodo tracker                  |    x    |    x    |         |              | [Link](https://feodotracker.abuse.ch)                        |
| firehol1            | firehol level 1 compilation    |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=firehol_level1)    |
| firehol2            | firehol level 2 compilation    |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=firehol_level2)    |
| firehol3            | firehol level 3 compilation    |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=firehol_level3)    |
| firehol4            | firehol level 4 compilation    |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=firehol_level4)    |
| greensnow           | suspicious server IPs          |    x    |    x    |         |              | [Link](https://greensnow.co)                                 |
| iblockads           | Advertising IPs                |         |         |    x    | tcp: 80, 443 | [Link](https://www.iblocklist.com)                           |
| iblockspy           | Malicious spyware IPs          |         |         |    x    | tcp: 80, 443 | [Link](https://www.iblocklist.com)                           |
| ipblackhole         | blackhole IPs                  |    x    |    x    |         |              | [Link](https://ip.blackhole.monster)                         |
| ipthreat            | hacker and botnet TPs          |    x    |    x    |         |              | [Link](https://ipthreat.net)                                 |
| myip                | real-time IP blocklist         |    x    |    x    |         |              | [Link](https://myip.ms)                                      |
| nixspam             | iX spam protection             |    x    |    x    |         |              | [Link](http://www.nixspam.org)                               |
| oisdbig             | OISD-big IPs                   |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| oisdnsfw            | OISD-nsfw IPs                  |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| oisdsmall           | OISD-small IPs                 |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| proxy               | open proxies                   |    x    |         |         |              | [Link](https://iplists.firehol.org/?ipset=proxylists)        |
| ssbl                | SSL botnet IPs                 |    x    |    x    |         |              | [Link](https://sslbl.abuse.ch)                               |
| stevenblack         | stevenblack IPs                |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |
| talos               | talos IPs                      |    x    |    x    |         |              | [Link](https://talosintelligence.com/reputation_center)      |
| threat              | emerging threats               |    x    |    x    |         |              | [Link](https://rules.emergingthreats.net)                    |
| threatview          | malicious IPs                  |    x    |    x    |         |              | [Link](https://threatview.io)                                |
| tor                 | tor exit nodes                 |    x    |    x    |         |              | [Link](https://github.com/SecOps-Institute/Tor-IP-Addresses) |
| turris              | turris sentinel blocklist      |    x    |    x    |         |              | [Link](https://view.sentinel.turris.cz)                      |
| uceprotect1         | spam protection level 1        |    x    |    x    |         |              | [Link](https://www.uceprotect.net/en/index.php)              |
| uceprotect2         | spam protection level 2        |    x    |    x    |         |              | [Link](https://www.uceprotect.net/en/index.php)              |
| uceprotect3         | spam protection level 3        |    x    |    x    |         |              | [Link](https://www.uceprotect.net/en/index.php)              |
| urlhaus             | urlhaus IDS IPs                |    x    |    x    |         |              | [Link](https://urlhaus.abuse.ch)                             |
| urlvir              | malware related IPs            |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=urlvir)            |
| webclient           | malware related IPs            |    x    |    x    |         |              | [Link](https://iplists.firehol.org/?ipset=firehol_webclient) |
| voip                | VoIP fraud blocklist           |    x    |    x    |         |              | [Link](https://voipbl.org)                                   |
| yoyo                | yoyo IPs                       |         |         |    x    | tcp: 80, 443 | [Link](https://github.com/dibdot/banIP-IP-blocklists)        |

* Zero-conf like automatic installation & setup, usually no manual changes needed
* All Sets are handled in a separate nft table/namespace 'banIP'
* Full IPv4 and IPv6 support
* Supports nft atomic Set loading
* Supports blocking by ASN numbers and by iso country codes
* Supports local allow- and blocklist with MAC/IPv4/IPv6 addresses or domain names
* Supports concatenation of local MAC addresses with IPv4/IPv6 addresses, e.g. to enforce dhcp assignments
* All local input types support ranges in CIDR notation
* Auto-add the uplink subnet or uplink IP to the local allowlist
* Provides a small background log monitor to ban unsuccessful login attempts in real-time (like fail2ban, crowdsec etc.)
* Auto-add unsuccessful LuCI, nginx, Asterisk or ssh login attempts to the local blocklist
* Auto-add entire subnets to the blocklist Sets based on an additional RDAP request with the monitored suspicious IP
* Fast feed processing as they are handled in parallel as background jobs (on capable multi-core hardware)
* Per feed it can be defined whether the wan-input chain, the wan-forward chain or the lan-forward chain should be blocked (default: all chains)
* Automatic blocklist backup & restore, the backups will be used in case of download errors or during startup
* Automatically selects one of the following download utilities with ssl support: aria2c, curl, uclient-fetch or full wget
* Provides HTTP ETag support to download only ressources that have been updated on the server side, to speed up banIP reloads and to save bandwith
* Supports an 'allowlist only' mode, this option skips all blocklists and restricts the internet access only to specific, explicitly allowed IP segments
* Supports external allowlist URLs to reference additional IPv4/IPv6 feeds
* Deduplicate IPs accross all Sets (single IPs only, no intervals)
* Provides comprehensive runtime information
* Provides a detailed Set report
* Provides a Set search engine for certain IPs
* Feed parsing by fast & flexible regex rulesets
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support (start/stop/restart/reload/status/report/search/survey/lookup)
* Procd network interface trigger support
* Add new or edit existing banIP feeds on your own with the LuCI integrated custom feed editor
* Supports destination port & protocol limitations for external feeds (see the feed list above). To change the default assignments just use the feed editor
* Supports allowing / blocking of certain VLAN forwards
* Provides an option to transfer logging events on remote servers via cgi interface

## Prerequisites
* **[OpenWrt](https://openwrt.org)**, latest stable release or a snapshot with nft/firewall 4 support
* A download utility with SSL support: 'aria2c', 'curl', full 'wget' or 'uclient-fetch' with one of the 'libustream-*' SSL libraries, the latter one doesn't provide support for ETag HTTP header
* A certificate store like 'ca-bundle', as banIP checks the validity of the SSL certificates of all download sites by default
* For E-Mail notifications you need to install and setup the additional 'msmtp' package

**Please note:**
* Devices with less than 256Mb of RAM are **_not_** supported
* Any previous installation of ancient banIP 0.7.x must be uninstalled, and the /etc/banip folder and the /etc/config/banip configuration file must be deleted (they are recreated when this version is installed)

## Installation & Usage
* Update your local opkg repository (_opkg update_)
* Install banIP (_opkg install banip_) - the banIP service is disabled by default
* Install the LuCI companion package 'luci-app-banip' (opkg install luci-app-banip)
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of banIP, the application is located in LuCI under the 'Services' menu
* If you're using a complex network setup, e.g. special tunnel interfaces, than untick the 'Auto Detection' option under the 'General Settings' tab and set the required options manually
* Start the service with '/etc/init.d/banip start' and check everything is working by running '/etc/init.d/banip status' and also check the 'Firewall Log' and 'Processing Log' tabs
* If you're going to configure banIP via CLI, edit the config file '/etc/config/banip' and enable the service (set ban\_enabled to '1'), then add pre-configured feeds via 'ban\_feed' (see the feed list above) and add/change other options to your needs (see the options reference below)

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
	report          [text|json|mail] Print banIP related Set statistics
	search          [<IPv4 address>|<IPv6 address>] Check if an element exists in a banIP Set
	survey          [<Set name>] List all elements of a given banIP Set
	lookup          Lookup the IPs of domain names in the local lists and update them
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

## banIP config options

| Option                  | Type   | Default                       | Description                                                                                                       |
| :---------------------- | :----- | :---------------------------- | :---------------------------------------------------------------------------------------------------------------- |
| ban_enabled             | option | 0                             | enable the banIP service                                                                                          |
| ban_nicelimit           | option | 0                             | ulimit nice level of the banIP service (range 0-19)                                                               |
| ban_filelimit           | option | 1024                          | ulimit max open/number of files (range 1024-4096)                                                                 |
| ban_loglimit            | option | 100                           | scan only the last n log entries permanently. A value of '0' disables the monitor                                 |
| ban_logcount            | option | 1                             | how many times the IP must appear in the log to be considered as suspicious                                       |
| ban_logterm             | list   | regex                         | various regex for logfile parsing (default: dropbear, sshd, luci, nginx, asterisk and cgi-remote events)          |
| ban_logreadfile         | option | /var/log/messages             | alternative location for parsing the log file, e.g. via syslog-ng, to deactivate the standard parsing via logread |
| ban_autodetect          | option | 1                             | auto-detect wan interfaces, devices and subnets                                                                   |
| ban_debug               | option | 0                             | enable banIP related debug logging                                                                                |
| ban_loginput            | option | 1                             | log drops in the wan-input chain                                                                                  |
| ban_logforwardwan       | option | 1                             | log drops in the wan-forward chain                                                                                |
| ban_logforwardlan       | option | 0                             | log rejects in the lan-forward chain                                                                              |
| ban_autoallowlist       | option | 1                             | add wan IPs/subnets and resolved domains automatically to the local allowlist (not only to the Sets)              |
| ban_autoblocklist       | option | 1                             | add suspicious attacker IPs and resolved domains automatically to the local blocklist (not only to the Sets)      |
| ban_autoblocksubnet     | option | 0                             | add entire subnets to the blocklist Sets based on an additional RDAP request with the suspicious IP               |
| ban_autoallowuplink     | option | subnet                        | limit the uplink autoallow function to: 'subnet', 'ip' or 'disable' it at all                                     |
| ban_allowlistonly       | option | 0                             | skip all blocklists and restrict the internet access only to specific, explicitly allowed IP segments             |
| ban_allowurl            | list   | -                             | external allowlist feed URLs, one or more references to simple remote IP lists                                    |
| ban_basedir             | option | /tmp                          | base working directory while banIP processing                                                                     |
| ban_reportdir           | option | /tmp/banIP-report             | directory where banIP stores the report files                                                                     |
| ban_backupdir           | option | /tmp/banIP-backup             | directory where banIP stores the compressed backup files                                                          |
| ban_protov4             | option | - / autodetect                | enable IPv4 support                                                                                               |
| ban_protov6             | option | - / autodetect                | enable IPv4 support                                                                                               |
| ban_ifv4                | list   | - / autodetect                | logical wan IPv4 interfaces, e.g. 'wan'                                                                           |
| ban_ifv6                | list   | - / autodetect                | logical wan IPv6 interfaces, e.g. 'wan6'                                                                          |
| ban_dev                 | list   | - / autodetect                | wan device(s), e.g. 'eth2'                                                                                        |
| ban_vlanallow           | list   | -                             | always allow certain VLAN forwards, e.g. br-lan.20                                                                |
| ban_vlanblock           | list   | -                             | always block certain VLAN forwards, e.g. br-lan.10                                                                |
| ban_trigger             | list   | -                             | logical reload trigger interface(s), e.g. 'wan'                                                                   |
| ban_triggerdelay        | option | 20                            | trigger timeout during interface reload and boot                                                                  |
| ban_deduplicate         | option | 1                             | deduplicate IP addresses across all active Sets                                                                   |
| ban_splitsize           | option | 0                             | split ext. Sets after every n lines/members (saves RAM)                                                           |
| ban_cores               | option | - / autodetect                | limit the cpu cores used by banIP (saves RAM)                                                                     |
| ban_nftloglevel         | option | warn                          | nft loglevel, values: emerg, alert, crit, err, warn, notice, info, debug                                          |
| ban_nftpriority         | option | -200                          | nft priority for the banIP table (default is the prerouting table priority)                                       |
| ban_nftpolicy           | option | memory                        | nft policy for banIP-related Sets, values: memory, performance                                                    |
| ban_nftexpiry           | option | -                             | expiry time for auto added blocklist members, e.g. '5m', '2h' or '1d'                                             |
| ban_feed                | list   | -                             | external download feeds, e.g. 'yoyo', 'doh', 'country' or 'talos' (see feed table)                                |
| ban_asn                 | list   | -                             | ASNs for the 'asn' feed, e.g.'32934'                                                                              |
| ban_country             | list   | -                             | country iso codes for the 'country' feed, e.g. 'ru'                                                               |
| ban_blockpolicy         | option | -                             | limit the default block policy to a certain chain, e.g. 'input', 'forwardwan' or 'forwardlan'                     |
| ban_blocktype           | option | drop                          | 'drop' packets silently on input and forwardwan chains or actively 'reject' the traffic                           |
| ban_blockinput          | list   | -                             | limit a feed to the wan-input chain, e.g. 'country'                                                               |
| ban_blockforwardwan     | list   | -                             | limit a feed to the wan-forward chain, e.g. 'debl'                                                                |
| ban_blockforwardlan     | list   | -                             | limit a feed to the lan-forward chain, e.g. 'doh'                                                                 |
| ban_fetchcmd            | option | - / autodetect                | 'uclient-fetch', 'wget', 'curl' or 'aria2c'                                                                       |
| ban_fetchparm           | option | - / autodetect                | set the config options for the selected download utility                                                          |
| ban_fetchretry          | option | 5                             | number of download attempts in case of an error (not supported by uclient-fetch)                                  |
| ban_fetchinsecure       | option | 0                             | don't check SSL server certificates during download                                                               |
| ban_mailreceiver        | option | -                             | receiver address for banIP related notification E-Mails                                                           |
| ban_mailsender          | option | no-reply@banIP                | sender address for banIP related notification E-Mails                                                             |
| ban_mailtopic           | option | banIP notification            | topic for banIP related notification E-Mails                                                                      |
| ban_mailprofile         | option | ban_notify                    | mail profile used in 'msmtp' for banIP related notification E-Mails                                               |
| ban_mailnotification    | option | 0                             | receive E-Mail notifications with every banIP run                                                                 |
| ban_reportelements      | option | 1                             | count Set elements in the report, disable this option to speed up the report significantly                        |
| ban_resolver            | option | -                             | external resolver used for DNS lookups                                                                            |
| ban_remotelog           | option | 0                             | enable the cgi interface to receive remote logging events                                                         |
| ban_remotetoken         | option | -                             | unique token to communicate with the cgi interface                                                                |

## Examples
**banIP report information**  
```
~# /etc/init.d/banip report
:::
::: banIP Set Statistics
:::
    Timestamp: 2024-03-02 07:38:28
    ------------------------------
    auto-added to allowlist today: 0
    auto-added to blocklist today: 0

    Set                  | Elements     | WAN-Input (packets)   | WAN-Forward (packets) | LAN-Forward (packets) | Port/Protocol Limit
    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------
    allowlistv4MAC       | 0            | -                     | -                     | OK: 0                 | -                     
    allowlistv6MAC       | 0            | -                     | -                     | OK: 0                 | -                     
    allowlistv4          | 1            | OK: 0                 | OK: 0                 | OK: 0                 | -                     
    allowlistv6          | 2            | OK: 0                 | OK: 0                 | OK: 0                 | -                     
    adguardtrackersv6    | 74           | -                     | -                     | OK: 0                 | tcp: 80, 443          
    adguardtrackersv4    | 883          | -                     | -                     | OK: 0                 | tcp: 80, 443          
    cinsscorev4          | 12053        | OK: 25                | OK: 0                 | -                     | -                     
    countryv4            | 37026        | OK: 14                | OK: 0                 | -                     | -                     
    deblv4               | 13592        | OK: 0                 | OK: 0                 | -                     | -                     
    countryv6            | 38139        | OK: 0                 | OK: 0                 | -                     | -                     
    deblv6               | 82           | OK: 0                 | OK: 0                 | -                     | -                     
    dohv6                | 837          | -                     | -                     | OK: 0                 | tcp: 80, 443          
    dohv4                | 1240         | -                     | -                     | OK: 0                 | tcp: 80, 443          
    dropv6               | 51           | OK: 0                 | OK: 0                 | -                     | -                     
    dropv4               | 592          | OK: 0                 | OK: 0                 | -                     | -                     
    firehol1v4           | 906          | OK: 1                 | OK: 0                 | -                     | -                     
    firehol2v4           | 2105         | OK: 0                 | OK: 0                 | OK: 0                 | -                     
    threatv4             | 55           | OK: 0                 | OK: 0                 | -                     | -                     
    ipthreatv4           | 2042         | OK: 0                 | OK: 0                 | -                     | -                     
    turrisv4             | 6433         | OK: 0                 | OK: 0                 | -                     | -                     
    blocklistv4MAC       | 0            | -                     | -                     | OK: 0                 | -                     
    blocklistv6MAC       | 0            | -                     | -                     | OK: 0                 | -                     
    blocklistv4          | 0            | OK: 0                 | OK: 0                 | OK: 0                 | -                     
    blocklistv6          | 0            | OK: 0                 | OK: 0                 | OK: 0                 | -                     
    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------
    24                   | 116113       | 16 (40)               | 16 (0)                | 13 (0)
```

**banIP runtime information**  
```
~# /etc/init.d/banip status
::: banIP runtime information
  + status            : active (nft: ✔, monitor: ✔)
  + version           : 0.9.4-1
  + element_count     : 116113
  + active_feeds      : allowlistv4MAC, allowlistv6MAC, allowlistv4, allowlistv6, adguardtrackersv6, adguardtrackersv4, cinsscorev4, countryv4, deblv4, countryv6, deblv6, dohv6, dohv4, dropv6, dropv4, firehol1v4, firehol2v4, threatv4, ipthreatv4, turrisv4, blocklistv4MAC, blocklistv6MAC, blocklistv4, blocklistv6
  + active_devices    : wan: pppoe-wan / wan-if: wan, wan_6 / vlan-allow: - / vlan-block: -
  + active_uplink     : 217.89.211.113, fe80::2c35:fb80:e78c:cf71, 2003:ed:b5ff:2338:2c15:fb80:e78c:cf71
  + nft_info          : priority: -200, policy: performance, loglevel: warn, expiry: 2h
  + run_info          : base: /mnt/data/banIP, backup: /mnt/data/banIP/backup, report: /mnt/data/banIP/report
  + run_flags         : auto: ✔, proto (4/6): ✔/✔, log (wan-inp/wan-fwd/lan-fwd): ✔/✔/✔, dedup: ✔, split: ✘, custom feed: ✘, allowed only: ✘
  + last_run          : action: reload, log: logread, fetch: curl, duration: 0m 50s, date: 2024-03-02 07:35:01
  + system_info       : cores: 4, memory: 1685, device: Bananapi BPI-R3, OpenWrt SNAPSHOT r25356-09be63de70
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
    List of elements in the Set 'cinsscorev4' on 2023-03-06 14:07:58
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
list ban_logterm 'received a suspicious remote IP '\''.*'\'''
```

**allow-/blocklist handling**  
banIP supports local allow and block lists, MAC/IPv4/IPv6 addresses (incl. ranges in CIDR notation) or domain names. These files are located in /etc/banip/banip.allowlist and /etc/banip/banip.blocklist.  
Unsuccessful login attempts or suspicious requests will be tracked and added to the local blocklist (see the 'ban_autoblocklist' option). The blocklist behaviour can be further tweaked with the 'ban_nftexpiry' option.  
Depending on the options 'ban_autoallowlist' and 'ban_autoallowuplink' the uplink subnet or the uplink IP will be added automatically to local allowlist.  
Furthermore, you can reference external Allowlist URLs with additional IPv4 and IPv6 feeds (see 'ban_allowurl').  
Both local lists also accept domain names as input to allow IP filtering based on these names. The corresponding IPs (IPv4 & IPv6) will be extracted and added to the Sets. You can also start the domain lookup separately via /etc/init.d/banip lookup at any time.

**allowlist-only mode**  
banIP supports an "allowlist only" mode. This option skips all blocklists and restricts the internet access only to specific, explicitly allowed IP segments - and block access to the rest of the internet. All IPs which are _not_ listed in the allowlist (plus the external Allowlist URLs) are blocked.

**MAC/IP-binding**
banIP supports concatenation of local MAC addresses with IPv4/IPv6 addresses, e.g. to enforce dhcp assignments. Following notations in the local allow and block lists are allowed:
```
MAC-address only:
C8:C2:9B:F7:80:12                                  => this will be populated to the v4MAC- and v6MAC-Sets with the IP-wildcards 0.0.0.0/0 and ::/0

MAC-address with IPv4 concatenation:
C8:C2:9B:F7:80:12 192.168.1.10                     => this will be populated only to v4MAC-Set with the certain IP, no entry in the v6MAC-Set

MAC-address with IPv6 concatenation:
C8:C2:9B:F7:80:12 2a02:810c:0:80:a10e:62c3:5af:f3f => this will be populated only to v6MAC-Set with the certain IP, no entry in the v4MAC-Set

MAC-address with IPv4 and IPv6 concatenation:
C8:C2:9B:F7:80:12 192.168.1.10                     => this will be populated to v4MAC-Set with the certain IP
C8:C2:9B:F7:80:12 2a02:810c:0:80:a10e:62c3:5af:f3f => this will be populated to v6MAC-Set with the certain IP

MAC-address with IPv4 and IPv6 wildcard concatenation:
C8:C2:9B:F7:80:12 192.168.1.10                     => this will be populated to v4MAC-Set with the certain IP
C8:C2:9B:F7:80:12                                  => this will be populated to v6MAC-Set with the IP-wildcard ::/0
```
**enable the cgi interface to receive remote logging events**  
banIP ships a basic cgi interface in '/www/cgi-bin/banip' to receive remote logging events (disabled by default). The cgi interface evaluates logging events via GET or POST request (see examples below). To enable the cgi interface set the following options:  

    * set 'ban_remotelog' to '1' to enbale the cgi interface
    * set 'ban_remotetoken' to a secret transfer token, allowed token characters consist of '[A-Za-z]', '[0-9]', '.' and ':'

  Examples to transfer remote logging events from an internal server to banIP via cgi interface:  

    * POST request: curl --insecure --data "<ban_remotetoken>=<suspicious IP>" https://192.168.1.1/cgi-bin/banip
    * GET request: wget --no-check-certificate https://192.168.1.1/cgi-bin/banip?<ban_remotetoken>=<suspicious IP>

Please note: for security reasons use this cgi interface only internally and only encrypted via https transfer protocol.

**redirect Asterisk security logs to lodg/logread**  
banIP only supports logfile scanning via logread, so to monitor attacks on Asterisk, its security log must be available via logread. To do this, edit '/etc/asterisk/logger.conf' and add the line 'syslog.local0 = security', then run 'asterisk -rx reload logger' to update the running Asterisk configuration.

**send status E-Mails and update the banIP lists via cron job**  
For a regular, automatic status mailing and update of the used lists on a daily basis set up a cron job, e.g.
```
55 03 * * * /etc/init.d/banip report mail
00 04 * * * /etc/init.d/banip reload
```

**tweaks for low memory systems**  
nftables supports the atomic loading of firewall rules (incl. elements), which is cool but unfortunately is also very memory intensive. To reduce the memory pressure on low memory systems (i.e. those with 256-512Mb RAM), you should optimize your configuration with the following options:  

    * point 'ban_basedir', 'ban_reportdir' and 'ban_backupdir' to an external usb drive
    * set 'ban_cores' to '1' (only useful on a multicore system) to force sequential feed processing
    * set 'ban_splitsize' e.g. to '1000' to split the load of an external Set after every 1000 lines/members
    * set 'ban_reportelements' to '0' to disable the CPU intensive counting of Set elements

**tweak the download options**  
By default banIP uses the following pre-configured download options:
```
    * aria2c: --timeout=20 --retry-wait=10 --max-tries=5 --max-file-not-found=5 --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o
    * curl: --connect-timeout 20 --retry-delay 10 --retry 5 --retry-all-errors --fail --silent --show-error --location -o
    * wget: --no-cache --no-cookies --timeout=20 --waitretry=10 --tries=5 --retry-connrefused --max-redirect=0 -O
    * uclient-fetch: --timeout=20 -O
```
To override the default set 'ban_fetchretry', 'ban_fetchinsecure' or globally 'ban_fetchparm' to your needs.

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

**change existing banIP feeds or add port limitations**  
The banIP default blocklist feeds are stored in an external JSON file '/etc/banip/banip.feeds'. All custom changes should be stored in an external JSON file '/etc/banip/banip.custom.feeds' (empty by default). It's recommended to use the LuCI based Custom Feed Editor to make changes to this file.  
A valid JSON source object contains the following information, e.g.:
```
	[...]
	"tor":{
		"url_4": "https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst",
		"url_6": "https://raw.githubusercontent.com/SecOps-Institute/Tor-IP-Addresses/master/tor-exit-nodes.lst",
		"rule_4": "/^(([0-9]{1,3}\\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\\/(1?[0-9]|2?[0-9]|3?[0-2]))?)$/{printf \"%s,\\n\",$1}",
		"rule_6": "/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\\/(1?[0-2][0-8]|[0-9][0-9]))?)$/{printf \"%s,\\n\",$1}",
		"descr": "tor exit nodes",
		"flag": "80-89 443 tcp"
	},
	[...]
```
Add an unique feed name (no spaces, no special chars) and make the required changes: adapt at least the URL, the regex and the description for a new feed.  
Please note: the flag field is optional, it's a space separated list of options: supported are 'gz' as an archive format, port numbers (plus ranges) for destination port limitations with 'tcp' (default) or 'udp' as protocol variants.  

## Support
Please join the banIP discussion in this [forum thread](https://forum.openwrt.org/t/banip-support-thread/16985) or contact me by mail <dev@brenken.org>

## Removal
* stop all banIP related services with _/etc/init.d/banip stop_
* remove the banip package (_opkg remove banip_)

Have fun!  
Dirk
