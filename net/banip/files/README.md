<!-- markdownlint-disable -->

# banIP - ban incoming and outgoing IP addresses/subnets via Sets in nftables

<a id="description"></a>
## Description
IP address blocking is commonly used to protect against brute force attacks, prevent disruptive or unauthorized address(es) from access or it can be used to restrict access to or from a particular geographic area — for example. Further more banIP scans the log file via logread and bans IPs that make too many password failures, e.g. via ssh.  

<a id="main-features"></a>
## Main Features
* banIP supports the following fully pre-configured IP blocklist feeds (free for private usage, for commercial use please check their individual licenses).  
**Please note:** By default, each feed blocks the packet flow in the chain shown in the table below. _Inbound_ combines the chains WAN-Input and WAN-Forward, _Outbound_ represents the LAN-FWD chain:  
  * WAN-INP chain applies to packets from internet to your router  
  * WAN-FWD chain applies to packets from internet to other local devices (not your router)  
  * LAN-FWD chain applies to local packets going out to the internet (not your router)  
  The listed standard assignments can be changed to your needs under the 'Feed/Set Settings' config tab.  

| Feed                | Focus                          | Inbound | Outbound | Proto/Port        | Information                                                  |
| :------------------ | :----------------------------- | :-----: | :------: | :---------------: | :----------------------------------------------------------- |
| asn                 | ASN segments                   |    x    |          |                   | [Link](https://asn.ipinfo.app)                               |
| backscatterer       | backscatterer IPs              |    x    |          |                   | [Link](https://www.uceprotect.net/en/index.php)              |
| becyber             | malicious attacker IPs         |    x    |          |                   | [Link](https://github.com/duggytuxy/malicious_ip_addresses)  |
| binarydefense       | binary defense banlist         |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=bds_atif)          |
| bogon               | bogon prefixes                 |    x    |          |                   | [Link](https://team-cymru.com)                               |
| bruteforceblock     | bruteforceblocker IPs          |    x    |          |                   | [Link](https://danger.rulez.sk/index.php/bruteforceblocker/) |
| country             | country blocks                 |    x    |          |                   | [Link](https://www.ipdeny.com/ipblocks)                      |
| cinsscore           | suspicious attacker IPs        |    x    |          |                   | [Link](https://cinsscore.com/#list)                          |
| debl                | fail2ban IP blacklist          |    x    |          |                   | [Link](https://www.blocklist.de)                             |
| doh                 | public DoH-Provider            |         |    x     | tcp, udp: 80, 443 | [Link](https://github.com/dibdot/DoH-IP-blocklists)          |
| drop                | spamhaus drop compilation      |    x    |          |                   | [Link](https://www.spamhaus.org)                             |
| dshield             | dshield IP blocklist           |    x    |          |                   | [Link](https://www.dshield.org)                              |
| etcompromised       | ET compromised hosts           |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=et_compromised)    |
| feodo               | feodo tracker                  |    x    |          |                   | [Link](https://feodotracker.abuse.ch)                        |
| firehol1            | firehol level 1 compilation    |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=firehol_level1)    |
| firehol2            | firehol level 2 compilation    |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=firehol_level2)    |
| firehol3            | firehol level 3 compilation    |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=firehol_level3)    |
| firehol4            | firehol level 4 compilation    |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=firehol_level4)    |
| greensnow           | suspicious server IPs          |    x    |          |                   | [Link](https://greensnow.co)                                 |
| hagezi              | Threat IP blocklist            |         |    x     | tcp, udp: 80, 443 | [Link](https://github.com/hagezi/dns-blocklists)             |
| ipblackhole         | blackhole IPs                  |    x    |          |                   | [Link](https://github.com/BlackHoleMonster/IP-BlackHole)     |
| ipsum               | malicious IPs                  |    x    |          |                   | [Link](https://github.com/stamparm/ipsum)                    |
| ipthreat            | hacker and botnet TPs          |    x    |          |                   | [Link](https://ipthreat.net)                                 |
| myip                | real-time IP blocklist         |    x    |          |                   | [Link](https://myip.ms)                                      |
| nixspam             | iX spam protection             |    x    |          |                   | [Link](http://www.nixspam.org)                               |
| pallebone           | curated IP blocklist           |    x    |          |                   | [Link](https://github.com/pallebone/StrictBlockPAllebone)    |
| proxy               | open proxies                   |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=proxylists)        |
| threat              | emerging threats               |    x    |          |                   | [Link](https://rules.emergingthreats.net)                    |
| threatview          | malicious IPs                  |    x    |          |                   | [Link](https://threatview.io)                                |
| tor                 | tor exit nodes                 |    x    |          |                   | [Link](https://www.dan.me.uk)                                |
| turris              | turris sentinel blocklist      |    x    |          |                   | [Link](https://view.sentinel.turris.cz)                      |
| uceprotect1         | spam protection level 1        |    x    |          |                   | [Link](https://www.uceprotect.net/en/index.php)              |
| uceprotect2         | spam protection level 2        |    x    |          |                   | [Link](https://www.uceprotect.net/en/index.php)              |
| uceprotect3         | spam protection level 3        |    x    |          |                   | [Link](https://www.uceprotect.net/en/index.php)              |
| urlhaus             | urlhaus IDS IPs                |    x    |          |                   | [Link](https://urlhaus.abuse.ch)                             |
| urlvir              | malware related IPs            |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=urlvir)            |
| webclient           | malware related IPs            |    x    |          |                   | [Link](https://iplists.firehol.org/?ipset=firehol_webclient) |
| voip                | VoIP fraud blocklist           |    x    |          |                   | [Link](https://voipbl.org)                                   |
| vpn                 | vpn IPs                        |    x    |          |                   | [Link](https://github.com/X4BNet/lists_vpn)                  |
| vpndc               | vpn datacenter IPs             |    x    |          |                   | [Link](https://github.com/X4BNet/lists_vpn)                  |

* Zero-conf like automatic installation & setup, usually no manual changes needed
* All Sets are handled in a separate nft table/namespace 'banIP'
* Full IPv4 and IPv6 support
* Supports nft atomic Set loading
* Supports blocking by ASN numbers and by iso country codes
* Block countries dynamically by Regional Internet Registry (RIR), e.g. all countries related to ARIN. Supported service regions are: AFRINIC, ARIN, APNIC, LACNIC and RIPE
* Supports local allow- and blocklist with MAC/IPv4/IPv6 addresses or domain names
* Supports concatenation of local MAC addresses with IPv4/IPv6 addresses, e.g. to enforce dhcp assignments
* All local input types support ranges in CIDR notation
* Auto-add the uplink subnet or uplink IP to the local allowlist
* Prevent common ICMP, UDP and SYN flood attacks and drop spoofed tcp flags & invalid conntrack packets (DoS attacks) in an additional prerouting chain
* Provides a small background log monitor to ban unsuccessful login attempts in real-time (like fail2ban, crowdsec etc.)
* Auto-add unsuccessful LuCI, nginx, Asterisk or ssh login attempts to the local blocklist
* Auto-add entire subnets to the blocklist Set based on an additional RDAP request with the monitored suspicious IP
* Fast feed processing as they are handled in parallel as background jobs (on capable multi-core hardware)
* Per feed it can be defined whether the inbound chain (wan-input, wan-forward) or the outbound chain (lan-forward) should be blocked
* Automatic blocklist backup & restore, the backups will be used in case of download errors or during startup
* Automatically selects one of the following download utilities with ssl support: curl, uclient-fetch or full wget
* Provides HTTP ETag support to download only ressources that have been updated on the server side, to speed up banIP reloads and to save bandwith
* Supports an 'allowlist only' mode, this option restricts the internet access only to specific, explicitly allowed IP segments
* Supports external allowlist URLs to reference additional IPv4/IPv6 feeds
* Optionally always allow certain protocols/destination ports in the inbound chain
* Deduplicate IPs accross all Sets (single IPs only, no intervals)
* Provides comprehensive runtime information
* Provides a detailed Set report, incl. a map that shows the geolocation of your own uplink addresses (in green) and the location of potential attackers (in red)
* Provides a Set search engine for certain IPs
* Feed parsing by fast & flexible regex rulesets
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support (start/stop/restart/reload/status/report/search/content)
* Procd network interface trigger support
* Add new or edit existing banIP feeds on your own with the LuCI integrated custom feed editor
* Supports destination port & protocol limitations for external feeds (see the feed list above). To change the default assignments just use the custom feed editor
* Supports allowing / blocking of certain VLAN forwards
* Provides an option to transfer logging events on remote servers via cgi interface

<a id="prerequisites"></a>
## Prerequisites
* **[OpenWrt](https://openwrt.org)**, latest stable release 24.x or a development snapshot with nft/firewall 4 support
* A download utility with SSL support: 'curl', full 'wget' or 'uclient-fetch' with one of the 'libustream-*' SSL libraries, the latter one doesn't provide support for ETag HTTP header
* A certificate store like 'ca-bundle', as banIP checks the validity of the SSL certificates of all download sites by default
* For E-Mail notifications you need to install and setup the additional 'msmtp' package

**Please note:**
* Devices with less than 256MB of RAM are **_not_** supported
* Latest banIP 1.5.x does **_not_** support OpenWrt 23.x because the kernel and the nft library are outdated (use former banIP 1.0.x instead)
* Any previous custom feeds file of banIP 1.0.x must be cleared and it's recommended to start with a fresh banIP default config

<a id="installation-and-usage"></a>
## Installation and Usage
* Update your local opkg/apk repository
* Install the LuCI companion package 'luci-app-banip' which also installs the main 'banip' package as a dependency
* Enable the banIP system service (System -> Startup) and enable banIP itself (banIP -> General Settings)
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of banIP, the application is located in LuCI under the 'Services' menu
* It's also recommended to configure a 'Reload Trigger Interface' to depend on your WAN ifup events during boot or restart of your router
* To be able to use banIP in a meaningful way, you must activate the service and possibly also activate a few blocklist feeds
* If you're using a complex network setup, e.g. special tunnel interfaces, than untick the 'Auto Detection' option under the 'General Settings' tab and set the required options manually
* Start the service with '/etc/init.d/banip start' and check everything is working by running '/etc/init.d/banip status', also check the 'Processing Log' tab

<a id="banip-cli-interface"></a>
## banIP CLI interface
* All important banIP functions are accessible via CLI, too. If you're going to configure banIP via CLI, edit the config file '/etc/config/banip' and enable the service, add pre-configured feeds and add/change other options to your needs, see the options reference table below.  

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
	content         [<Set name>] [true|false] Listing of all or only elements with hits of a given banIP Set
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

<a id="banip-config-options"></a>
## banIP config options

| Option                  | Type   | Default                       | Description                                                                                                       |
| :---------------------- | :----- | :---------------------------- | :---------------------------------------------------------------------------------------------------------------- |
| ban_enabled             | option | 0                             | enable the banIP service                                                                                          |
| ban_nicelimit           | option | 0                             | ulimit nice level of the banIP service (range 0-19)                                                               |
| ban_filelimit           | option | 1024                          | ulimit max open/number of files (range 1024-4096)                                                                 |
| ban_loglimit            | option | 100                           | scan only the last n log entries permanently. A value of '0' disables the monitor                                 |
| ban_logcount            | option | 1                             | how many times the IP must appear in the log to be considered as suspicious                                       |
| ban_logterm             | list   | regex                         | various regex for logfile parsing (default: dropbear, sshd, luci, nginx, asterisk and cgi-remote events)          |
| ban_logreadfile         | option | /var/log/messages             | alternative location for parsing a log file via tail, to deactivate the standard parsing via logread              |
| ban_autodetect          | option | 1                             | auto-detect wan interfaces, devices and subnets                                                                   |
| ban_debug               | option | 0                             | enable banIP related debug logging                                                                                |
| ban_icmplimit           | option | 25                            | threshold in number of packets to detect icmp DoS in prerouting chain. A value of '0' disables this safeguard     |
| ban_synlimit            | option | 10                            | threshold in number of packets to detect syn DoS in prerouting chain. A value of '0' disables this safeguard      |
| ban_udplimit            | option | 100                           | threshold in number of packets to detect udp DoS in prerouting chain. A value of '0' disables this safeguard      |
| ban_logprerouting       | option | 0                             | log supsicious packets in the prerouting chain                                                                    |
| ban_loginbound          | option | 0                             | log supsicious packets in the inbound chain (wan-input and wan-forward)                                           |
| ban_logoutbound         | option | 0                             | log supsicious packets in the outbound chain (lan-forward)                                                        |
| ban_autoallowlist       | option | 1                             | add wan IPs/subnets and resolved domains automatically to the local allowlist (not only to the Sets)              |
| ban_autoblocklist       | option | 1                             | add suspicious attacker IPs and resolved domains automatically to the local blocklist (not only to the Sets)      |
| ban_autoblocksubnet     | option | 0                             | add entire subnets to the blocklist Sets based on an additional RDAP request with the suspicious IP               |
| ban_autoallowuplink     | option | subnet                        | limit the uplink autoallow function to: 'subnet', 'ip' or 'disable' it at all                                     |
| ban_allowlistonly       | option | 0                             | restrict the internet access only to specific, explicitly allowed IP segments                                     |
| ban_allowflag           | option | -                             | always allow certain protocols(tcp or udp) plus destination ports or port ranges, e.g.: 'tcp 80 443-445'          |
| ban_allowurl            | list   | -                             | external allowlist feed URLs, one or more references to simple remote IP lists                                    |
| ban_basedir             | option | /tmp                          | base working directory while banIP processing                                                                     |
| ban_reportdir           | option | /tmp/banIP-report             | directory where banIP stores report files                                                                         |
| ban_backupdir           | option | /tmp/banIP-backup             | directory where banIP stores compressed backup files                                                              |
| ban_errordir            | option | /tmp/banIP-error              | directory where banIP stores processing error files                                                               |
| ban_protov4             | option | - / autodetect                | enable IPv4 support                                                                                               |
| ban_protov6             | option | - / autodetect                | enable IPv6 support                                                                                               |
| ban_ifv4                | list   | - / autodetect                | logical wan IPv4 interfaces, e.g. 'wan'                                                                           |
| ban_ifv6                | list   | - / autodetect                | logical wan IPv6 interfaces, e.g. 'wan6'                                                                          |
| ban_dev                 | list   | - / autodetect                | wan device(s), e.g. 'eth2'                                                                                        |
| ban_vlanallow           | list   | -                             | always allow certain VLAN forwards, e.g. br-lan.20                                                                |
| ban_vlanblock           | list   | -                             | always block certain VLAN forwards, e.g. br-lan.10                                                                |
| ban_trigger             | list   | -                             | logical reload trigger interface(s), e.g. 'wan'                                                                   |
| ban_triggerdelay        | option | 20                            | trigger timeout during interface reload and boot                                                                  |
| ban_deduplicate         | option | 1                             | deduplicate IP addresses across all active Sets (see optional feed flag 'dup' below)                              |
| ban_splitsize           | option | 0                             | split the processing/loading of Sets in chunks of n lines/members (saves RAM)                                     |
| ban_cores               | option | - / autodetect                | limit the cpu cores used by banIP (saves RAM)                                                                     |
| ban_nftloglevel         | option | warn                          | nft loglevel, values: emerg, alert, crit, err, warn, notice, info, debug                                          |
| ban_nftpriority         | option | -100                          | nft priority for the banIP table (the prerouting table is fixed to priority -150)                                 |
| ban_nftpolicy           | option | memory                        | nft policy for banIP-related Sets, values: memory, performance                                                    |
| ban_nftexpiry           | option | -                             | expiry time for auto added blocklist members, e.g. '5m', '2h' or '1d'                                             |
| ban_nftretry            | option | 5                             | number of Set load attempts in case of an error                                                                   |
| ban_nftcount            | option | 0                             | enable nft counter for every Set element                                                                          |
| ban_map                 | option | 0                             | enable a GeoIP Map with suspicious Set elements                                                                   |
| ban_feed                | list   | -                             | external download feeds, e.g. 'yoyo', 'doh', 'country' or 'talos' (see feed table)                                |
| ban_asn                 | list   | -                             | ASNs for the 'asn' feed, e.g.'32934'                                                                              |
| ban_asnsplit            | option | -                             | the selected ASNs are stored in separate Sets                                                                     |
| ban_region              | list   | -                             | Regional Internet Registry (RIR) country selection. Supported regions are: AFRINIC, ARIN, APNIC, LACNIC and RIPE  |
| ban_country             | list   | -                             | country iso codes for the 'country' feed, e.g. 'ru'                                                               |
| ban_countrysplit        | option | -                             | the selected countries are stored in separate Sets                                                                |
| ban_blocktype           | option | drop                          | 'drop' packets silently on input and forwardwan chains or actively 'reject' the traffic                           |
| ban_feedin              | list   | -                             | limit the selected feeds to the inbound chain (wan-input and wan-forward)                                         |
| ban_feedout             | list   | -                             | limit the selected feeds to the outbound chain (lan-forward)                                                      |
| ban_feedinout           | list   | -                             | set the selected feeds to the inbound and outbound chain (lan-forward)                                            |
| ban_feedreset           | list   | -                             | override the default feed configuration and remove existing port/protocol limitations                             |
| ban_feedcomplete        | list   | -                             | opt out the selected feeds from the deduplication process                                                         |
| ban_fetchcmd            | option | - / autodetect                | 'uclient-fetch', 'wget' or 'curl'                                                                                 |
| ban_fetchparm           | option | - / autodetect                | set the config options for the selected download utility                                                          |
| ban_fetchretry          | option | 5                             | number of download attempts in case of an error (not supported by uclient-fetch)                                  |
| ban_fetchinsecure       | option | 0                             | don't check SSL server certificates during download                                                               |
| ban_mailreceiver        | option | -                             | receiver address for banIP related notification E-Mails                                                           |
| ban_mailsender          | option | no-reply@banIP                | sender address for banIP related notification E-Mails                                                             |
| ban_mailtopic           | option | banIP notification            | topic for banIP related notification E-Mails                                                                      |
| ban_mailprofile         | option | ban_notify                    | mail profile used in 'msmtp' for banIP related notification E-Mails                                               |
| ban_mailnotification    | option | 0                             | receive E-Mail notifications with every banIP run                                                                 |
| ban_reportelements      | option | 1                             | count Set elements in the report, disable this option to speed up the report significantly                        |
| ban_resolver            | option | -                             | external resolver used for DNS lookups, by default the local resolver/forwarder will be used                      |
| ban_remotelog           | option | 0                             | enable the cgi interface to receive remote logging events                                                         |
| ban_remotetoken         | option | -                             | unique token to communicate with the cgi interface                                                                |

<a id="examples"></a>
## Examples
**banIP report information**  

```
~# /etc/init.d/banip report
:::
::: banIP Set Statistics
:::
    Timestamp: 2025-06-08 23:24:54
    ------------------------------
    blocked syn-flood packets  : 0
    blocked udp-flood packets  : 0
    blocked icmp-flood packets : 0
    blocked invalid ct packets : 133
    blocked invalid tcp packets: 0
    ---
    auto-added IPs to allowlist: 0
    auto-added IPs to blocklist: 0

    Set                  | Count        | Inbound (packets)     | Outbound (packets)    | Port/Protocol         | Elements (max. 50)    
    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------
    allowlist.v4         | 1            | ON: 0                 | ON: 0                 | -                     |                       
    allowlist.v4MAC      | 1            | -                     | ON: 177               | -                     | 65:34:31:1f:a5:b1     
    allowlist.v6         | 1            | ON: 0                 | ON: 0                 | -                     |                       
    allowlist.v6MAC      | 1            | -                     | ON: 264               | -                     | 65:34:31:1f:a5:b1     
    blocklist.v4         | 2            | ON: 0                 | ON: 0                 | -                     |                       
    blocklist.v4MAC      | 0            | -                     | ON: 0                 | -                     |                       
    blocklist.v6         | 0            | ON: 0                 | ON: 0                 | -                     |                       
    blocklist.v6MAC      | 0            | -                     | ON: 0                 | -                     |                       
    cinsscore.v4         | 11498        | ON: 444               | -                     | -                     | 3.92.139.143, 5.39.61.11
                         |              |                       |                       |                       | 8, 8.137.54.171, 8.211.4
                         |              |                       |                       |                       | 7.67, 8.219.147.10, 8.21
                         |              |                       |                       |                       | 9.159.103, 8.219.206.212
                         |              |                       |                       |                       | , 8.221.142.130, 8.222.1
                         |              |                       |                       |                       | 60.62, 8.222.187.153, 18
                         |              |                       |                       |                       | .212.38.183, 20.14.75.2,
                         |              |                       |                       |                       |  20.15.164.37, 20.15.200
                         |              |                       |                       |                       | .1, 20.46.231.114, 20.64
                         |              |                       |                       |                       | .106.91, 20.65.193.0, 20
                         |              |                       |                       |                       | .65.194.143, 20.80.83.86
                         |              |                       |                       |                       | , 20.98.164.46, 20.118.3
                         |              |                       |                       |                       | 2.59, 20.118.217.162, 20
                         |              |                       |                       |                       | .118.217.181, 20.163.76.
                         |              |                       |                       |                       | 6, 20.168.7.168, 20.168.
                         |              |                       |                       |                       | 122.52, 20.168.122.88, 3
                         |              |                       |                       |                       | 1.14.32.4, 34.147.75.236
                         |              |                       |                       |                       | , 34.207.164.186, 35.203
                         |              |                       |                       |                       | .210.7, 35.203.210.43, 3
                         |              |                       |                       |                       | 5.203.210.90, 35.203.210
                         |              |                       |                       |                       | .128, 35.203.210.141, 35
                         |              |                       |                       |                       | .203.210.196, 35.203.210
                         |              |                       |                       |                       | .213, 35.203.210.243, 35
                         |              |                       |                       |                       | .203.211.3, 35.203.211.3
                         |              |                       |                       |                       | 4, 35.203.211.76, 35.203
                         |              |                       |                       |                       | .211.123, 35.203.211.156
                         |              |                       |                       |                       | , 35.203.211.162, 35.203
                         |              |                       |                       |                       | .211.175, 35.203.211.206
                         |              |                       |                       |                       | , 35.203.211.242, 40.90.
                         |              |                       |                       |                       | 235.65, 40.124.173.90, 4
                         |              |                       |                       |                       | 2.112.20.235          
    country.v4           | 36432        | ON: 221               | -                     | -                     | 15.236.0.0, 24.56.0.0, 2
                         |              |                       |                       |                       | 7.34.232.0, 27.148.0.0, 
                         |              |                       |                       |                       | 32.0.0.0, 36.96.0.0, 37.
                         |              |                       |                       |                       | 254.0.0, 42.63.0.0, 43.1
                         |              |                       |                       |                       | 76.0.0, 45.150.236.0, 46
                         |              |                       |                       |                       | .100.0.0, 47.56.0.0, 51.
                         |              |                       |                       |                       | 254.0.0, 57.101.0.0, 58.
                         |              |                       |                       |                       | 192.0.0, 59.88.0.0, 59.1
                         |              |                       |                       |                       | 72.0.0, 64.59.224.0, 64.
                         |              |                       |                       |                       | 226.64.0, 68.183.0.0, 71
                         |              |                       |                       |                       | .20.0.0, 83.239.0.0, 84.
                         |              |                       |                       |                       | 22.128.0, 87.103.128.0, 
                         |              |                       |                       |                       | 91.196.148.0, 94.253.0.0
                         |              |                       |                       |                       | , 95.144.0.0, 100.0.0.0,
                         |              |                       |                       |                       |  103.141.110.0, 103.203.
                         |              |                       |                       |                       | 56.0, 104.248.0.0, 110.5
                         |              |                       |                       |                       | .128.0, 113.62.0.0, 116.
                         |              |                       |                       |                       | 95.0.0, 117.122.0.0, 118
                         |              |                       |                       |                       | .139.192.0, 119.161.120.
                         |              |                       |                       |                       | 0, 120.52.0.0, 123.4.0.0
                         |              |                       |                       |                       | , 125.64.0.0, 129.79.0.0
                         |              |                       |                       |                       | , 129.144.0.0, 134.209.0
                         |              |                       |                       |                       | .0, 138.67.0.0, 147.182.
                         |              |                       |                       |                       | 0.0, 147.185.108.0, 150.
                         |              |                       |                       |                       | 107.176.0, 152.32.128.0,
                         |              |                       |                       |                       |  157.245.0.0, 159.59.0.0
    country.v6           | 23665        | ON: 0                 | -                     | -                     |                       
    debl.v4              | 13147        | ON: 19                | -                     | -                     | 54.37.81.238, 57.129.64.
                         |              |                       |                       |                       | 237, 78.153.140.224, 87.
                         |              |                       |                       |                       | 255.194.135, 91.196.152.
                         |              |                       |                       |                       | 3, 93.123.109.230, 111.6
                         |              |                       |                       |                       | 7.199.209, 141.98.11.147
                         |              |                       |                       |                       | , 147.185.132.58, 176.65
                         |              |                       |                       |                       | .148.10, 194.0.234.19, 2
                         |              |                       |                       |                       | 05.210.31.65          
    debl.v6              | 136          | ON: 0                 | -                     | -                     |                       
    doh.v4               | 1727         | -                     | ON: 2233              | tcp, udp: 53, 80, 443 | 8.8.8.8               
    doh.v6               | 1217         | -                     | ON: 0                 | tcp, udp: 53, 80, 443 |                       
    hagezi.v4            | 35287        | -                     | ON: 0                 | tcp, udp: 80, 443     |                       
    threat.v4            | 1041         | ON: 107               | -                     | -                     | 45.135.193.0, 45.153.34.
                         |              |                       |                       |                       | 0, 80.94.95.0, 83.222.19
                         |              |                       |                       |                       | 0.0, 87.121.84.0, 141.98
                         |              |                       |                       |                       | .10.0, 176.65.137.0, 176
                         |              |                       |                       |                       | .65.148.0, 196.251.69.0,
                         |              |                       |                       |                       |  196.251.83.0, 204.76.20
                         |              |                       |                       |                       | 3.0, 213.209.143.0    
    turris.v4            | 4553         | ON: 131               | -                     | -                     | 74.50.211.178, 109.205.2
                         |              |                       |                       |                       | 13.115, 109.205.213.123,
                         |              |                       |                       |                       |  109.205.213.248, 109.20
                         |              |                       |                       |                       | 5.213.250, 109.205.213.2
                         |              |                       |                       |                       | 52, 122.222.152.65, 186.
                         |              |                       |                       |                       | 91.25.141, 190.203.106.1
                         |              |                       |                       |                       | 13, 200.123.238.20    
    turris.v6            | 44           | ON: 0                 | -                     | -                     |                       
    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------
    19                   | 128753       | 12 (922)              | 11 (2674)             | 8                     | 137                   
```

**banIP runtime information**  

```
~# /etc/init.d/banip status
::: banIP runtime information
  + status            : active (nft: ✔, monitor: ✔)
  + version           : 1.5.6-r4
  + element_count     : 128 751 (chains: 7, sets: 19, rules: 47)
  + active_feeds      : allowlist.v4MAC, allowlist.v6MAC, allowlist.v4, allowlist.v6, cinsscore.v4, debl.v4, country.v6, debl.v6, doh.v4, doh.v6, country.v4, threat.v4, hagezi.v4, turris.v4, turris.v6, blocklist.v4MAC, blocklist.v6MAC, blocklist.v4, blocklist.v6
  + active_devices    : wan: pppoe-wan / wan-if: wan, wan_6 / vlan-allow: - / vlan-block: -
  + active_uplink     : 91.61.111.35, 2004:fc:45fe:678:c890:e2a3:c729:dc13
  + nft_info          : ver: 1.1.1-r1, priority: -100, policy: performance, loglevel: warn, expiry: 2h, limit (icmp/syn/udp): 25/10/100
  + run_info          : base: /mnt/data/banIP, backup: /mnt/data/banIP/backup, report: /mnt/data/banIP/report, error: /mnt/data/banIP/error
  + run_flags         : auto: ✔, proto (4/6): ✔/✔, log (pre/in/out): ✘/✘/✔, count: ✔, dedup: ✔, split: ✘, custom feed: ✔, allowed only: ✘
  + last_run          : mode: restart, 2025-06-08 21:11:21, duration: 0m 22s, memory: 1310.16 MB available
  + system_info       : cores: 4, log: logread, fetch: curl, Bananapi BPI-R3, mediatek/filogic, OpenWrt SNAPSHOT r29955-8b24289a52 
```

**banIP search information**  

```
~# /etc/init.d/banip search 8.8.8.8
:::
::: banIP Search
:::
    Looking for IP '8.8.8.8' on 2025-01-13 22:13:36
    ---
    IP found in Set 'country.v4'
    IP found in Set 'doh.v4'
```

**banIP Set content information**  
List all elements of a given Set with hit counters, e.g.:  

```
~# /etc/init.d/banip content turris.v4
:::
::: banIP Set Content
:::
    List elements of the Set 'turris.v4' on 2025-06-08 23:28:55
    ---
1.4.228.135, packets:  0
1.23.16.3, packets:  0
1.33.35.42, packets:  0
1.33.231.132, packets:  0
1.34.29.158, packets:  0
1.34.231.106, packets:  0
1.52.91.174, packets:  0
1.64.149.142, packets:  0
1.69.243.13, packets:  0
1.70.139.250, packets:  0
1.70.171.246, packets:  0
1.82.191.114, packets:  0
[...]
```

List only elements with hits of a given Set with hit counters, e.g.:  
```
~# /etc/init.d/banip content turris.v4 true
:::
::: banIP Set Content
:::
    List elements of the Set 'turris.v4' on 2025-06-08 23:30:59
    ---
74.50.211.178, packets:  1
109.205.213.115, packets:  18
109.205.213.123, packets:  35
109.205.213.248, packets:  29
109.205.213.250, packets:  20
109.205.213.252, packets:  30
122.222.152.65, packets:  1
186.91.25.141, packets:  2
190.203.106.113, packets:  2
200.123.238.20, packets:  1
```

<a id="best-practise-and-tweaks"></a>
## Best practise and tweaks
**Recommendation for low memory systems**  
nftables supports the atomic loading of firewall rules (incl. elements), which is cool but unfortunately is also very memory intensive. To reduce the memory pressure on low memory systems (i.e. those with 256-512MB RAM), you should optimize your configuration with the following options:  

* point 'ban_basedir', 'ban_reportdir', 'ban_backupdir' and 'ban_errordir' to an external usb drive or ssd
* set 'ban_cores' to '1' (only useful on a multicore system) to force sequential feed processing
* set 'ban_splitsize' e.g. to '1024' to split the load of an external Set after every 1024 lines/elements
* set 'ban_nftcount' to '0' to deactivate the CPU- and memory-intensive creation of counter elements at Set level

**Sensible choice of blocklists**  
The following feeds are just my personal recommendation as an initial setup:  
* cinsscore, debl, turris and doh in their default chains

In total, this feed selection blocks about 20K IP addresses. It may also be useful to include some countries to the country feed.  
Please note: don't just blindly activate (too) many feeds at once, sooner or later this will lead to OOM conditions.  

**Log Terms for logfile parsing**  
Like fail2ban and crowdsec, banIP supports logfile scanning and automatic blocking of suspicious attacker IPs.  
In the default config only the log terms to detect failed login attempts via dropbear and LuCI are in place. The following search pattern has been tested as well:  

```
dropbear : 'Exit before auth from'
LuCI     : 'luci: failed login'
sshd1    : 'error: maximum authentication attempts exceeded'
sshd2    : 'sshd.*Connection closed by.*\[preauth\]'
asterisk : 'SecurityEvent=\"InvalidAccountID\".*RemoteAddress='
nginx    : 'received a suspicious remote IP .*'
openvpn  : 'TLS Error: could not determine wrapping from \[AF_INET\]'
AdGuard  : 'AdGuardHome.*\[error\].*/control/login: from ip'
```

You find the 'Log Terms' option in LuCI under the 'Log Settings' tab. Feel free to add more log terms to meet your needs and protect additional services.  

**Allow-/Blocklist handling**  
banIP supports local allow- and block-lists, MAC/IPv4/IPv6 addresses (incl. ranges in CIDR notation) or domain names. These files are located in /etc/banip/banip.allowlist and /etc/banip/banip.blocklist.  
Unsuccessful login attempts or suspicious requests will be tracked and added to the local blocklist (see the 'ban_autoblocklist' option). The blocklist behaviour can be further tweaked with the 'ban_nftexpiry' option.  
Depending on the options 'ban_autoallowlist' and 'ban_autoallowuplink' the uplink subnet or the uplink IP will be added automatically to local allowlist.  
Furthermore, you can reference external Allowlist URLs with additional IPv4 and IPv6 feeds (see 'ban_allowurl').  
Both local lists also accept domain names as input to allow IP filtering based on these names. The corresponding IPs (IPv4 & IPv6) will be extracted and added to the Sets.  

**Allowlist-only mode**  
banIP supports an "allowlist only" mode. This option restricts Internet access only to certain, explicitly permitted IP segments - and blocks access to the rest of the Internet. All IPs that are _not_ listed in the allowlist or in the external allowlist URLs are blocked. In this mode it might be useful to limit the allowlist feed to the inbound chain, to still allow outbound communication to the rest of the world.  

**MAC/IP-binding**
banIP supports concatenation of local MAC addresses/ranges with IPv4/IPv6 addresses, e.g. to enforce dhcp assignments or to free connected clients from outbound blocking.  
The following notations in the local allow- and block-list are supported:

```
MAC-address only:
C8:C2:9B:F7:80:12                                  => this will be populated to the v4MAC- and v6MAC-Sets with the IP-wildcards 0.0.0.0/0 and ::/0

MAC-address range:
C8:C2:9B:F7:80:12/24                               => this populate the MAC-range C8:C2:9B:00:00:00", "C8:C2:9B:FF:FF:FF to the v4MAC- and v6MAC-Sets with the IP-wildcards 0.0.0.0/0 and ::/0

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

**MAC-address logging in nftables**  
The MAC-address logging format in nftables is a little bit unusual. It is generated by the kernel's NF_LOG module and places all MAC-related data into one flat field, without separators or labels. For example, the field MAC=7e:1a:2f:fc:ee:29:68:34:21:1f:a7:b1:08:00 is actually a concatenation of the following:  

```
[Source MAC (6 bytes)] + [Destination MAC (6 bytes)] + [EtherType (2 bytes)]
7e:1a:2f:fc:ee:29 → the source MAC address
68:34:21:1f:a7:b1 → the destination MAC address
08:00 → the EtherType for IPv4 (0x0800)
```

**Set reporting, enable the GeoIP Map**  
banIP includes a powerful reporting tool on the Set Reporting tab which shows the latest NFT banIP Set statistics. To get the latest statistics always press the "Refresh" button.  
In addition to a tabular overview banIP reporting includes a GeoIP map in a modal popup window/iframe that shows the geolocation of your own uplink addresses (in green) and the locations of potential attackers (in red). To enable the GeoIP Map set the following options (in "Feed/Set Settings" config tab):  

    * set 'ban_nftcount' to '1' to enable the nft counter for every Set element
    * set 'ban_map' to '1' to include the external components listed below and activate the GeoIP map

To make this work, banIP uses the following external components:  
* [Leaflet](https://leafletjs.com/) is a lightweight open-source JavaScript library for interactive maps
* [OpenStreetMap](https://www.openstreetmap.org/) provides the map data under an open-source license
* [CARTO basemap styles](https://github.com/CartoDB/basemap-styles) based on [OpenMapTiles](https://openmaptiles.org/schema)
* The free and quite fast [IP Geolocation API](https://ip-api.com/) to resolve the required IP/geolocation information

**CGI interface to receive remote logging events**  
banIP ships a basic cgi interface in '/www/cgi-bin/banip' to receive remote logging events (disabled by default). The cgi interface evaluates logging events via GET or POST request (see examples below). To enable the cgi interface set the following options:  

    * set 'ban_remotelog' to '1' to enbale the cgi interface
    * set 'ban_remotetoken' to a secret transfer token, allowed token characters consist of '[A-Za-z]', '[0-9]', '.' and ':'

  Examples to transfer remote logging events from an internal server to banIP via cgi interface:  

    * POST request: curl --insecure --data "<ban_remotetoken>=<suspicious IP>" https://192.168.1.1/cgi-bin/banip
    * GET request: wget --no-check-certificate https://192.168.1.1/cgi-bin/banip?<ban_remotetoken>=<suspicious IP>

Please note: for security reasons use this cgi interface only internally and only encrypted via https transfer protocol.

**Download options**  
By default banIP uses the following pre-configured download options:

```
    * curl: --connect-timeout 20 --retry-delay 10 --retry 5 --retry-all-errors --fail --silent --show-error --location -o
    * wget: --no-cache --no-cookies --timeout=20 --waitretry=10 --tries=5 --retry-connrefused --max-redirect=0 -O
    * uclient-fetch: --timeout=20 -O
```

To override the default set 'ban_fetchretry', 'ban_fetchinsecure' or globally 'ban_fetchparm' to your needs.

**Configure E-Mail notifications via 'msmtp'**  
To use the email notification you must install and configure the package 'msmtp'.  
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

Finally add a valid E-Mail receiver address in banIP.

**Send status E-Mails and update the banIP lists via cron job**  
For a regular, automatic status mailing and update of the used lists on a daily basis set up a cron job, e.g.

```
55 03 * * * /etc/init.d/banip report mail
00 04 * * * /etc/init.d/banip reload
```

**Redirect asterisk security logs to lodg/logread**  
By default banIP scans the logfile via logread, so to monitor attacks on asterisk, its security log must be available via logread. To do this, edit '/etc/asterisk/logger.conf' and add the line 'syslog.local0 = security', then run 'asterisk -rx reload logger' to update the running asterisk configuration.

**Change/add banIP feeds and set optional feed flags**  
The banIP default blocklist feeds are stored in an external JSON file '/etc/banip/banip.feeds'. All custom changes should be stored in an external JSON file '/etc/banip/banip.custom.feeds' (empty by default). It's recommended to use the LuCI based Custom Feed Editor to make changes to this file.  
A valid JSON source object contains the following information, e.g.:

```
	[...]
	"doh":{
		"url_4": "https://raw.githubusercontent.com/dibdot/DoH-IP-blocklists/master/doh-ipv4.txt",
		"url_6": "https://raw.githubusercontent.com/dibdot/DoH-IP-blocklists/master/doh-ipv6.txt",
		"rule_4": "/^127\\./{next}/^(([1-9][0-9]{0,2}\\.){1}([0-9]{1,3}\\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\\/(1?[0-9]|2?[0-9]|3?[0-2]))?)[[:space:]]/{printf \"%s,\\n\",$1}",
		"rule_6": "/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\\/(1?[0-2][0-8]|[0-9][0-9]))?)[[:space:]]/{printf \"%s,\\n\",$1}",
		"chain": "out",
		"descr": "public DoH-Provider",
		"flag": "tcp udp 80 443"
	},
	[...]
```

Add an unique feed name (no spaces, no special chars) and make the required changes: adapt at least the URL, the regex, the chain and the description for a new feed.  
Please note: the flag field is optional, it's a space separated list of options: supported are 'gz' as an archive format and protocols 'tcp' or 'udp' with port numbers/port ranges for destination port limitations.  

**Debug options**  
Whenever you encounter banIP related processing problems, please enable "Verbose Debug Logging", restart banIP and check the "Processing Log" tab.  
Typical symptoms:  
* The nftables initialization failed: untick the 'Auto Detection' option in the 'General Settings' config section and set the required device and tools options manually  
* A blocklist feed does not work: maybe a temporary server problem or the download URL has been changed. In the latter case, just use the Custom Feed Editor to point this feed to a new URL  

In case of a nft processing error, banIP creates an error directory (by default '/tmp/banIP-error') with the faulty nft load files.  
For further troubleshooting, you can try to load such an error file manually to determine the exact cause of the error, e.g.: 'nft -f error.file.nft'.  

Whenever you encounter firewall problems, enable the logging of certain chains in the "Log Settings" config section, restart banIP and check the "Firewall Log" tab.  
Typical symptoms:  
* A feed blocks a legit IP: disable the entire feed or add this IP to your local allowlist and reload banIP  
* A feed (e.g. doh) interrupts almost all client connections: check the feed table above for reference and reset the feed to the defaults in the "Feed/Set Settings" config tab section  
* The allowlist doesn't free a certain IP/MAC address: check the current content of the allowlist with the "Set Content" under the "Set Reporting" tab to make sure that the desired IP/MAC is listed - if not, reload banIP  

<a id="support"></a>
## Support
Please join the banIP discussion in this [forum thread](https://forum.openwrt.org/t/banip-support-thread/16985) or contact me by mail <dev@brenken.org>  
If you want to report an error, please describe it in as much detail as possible - with (debug) logs, the current banIP status, your banIP configuration, etc.  

<a id="removal"></a>
## Removal
Stop all banIP related services with _/etc/init.d/banip stop_ and remove the banip package if necessary.

<a id="donations"></a>
## Donations
You like this project - is there a way to donate? Generally speaking "No" - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.  

If you still insist to donate some bucks ...  
* I would be happy if you put your money in kind into other, social projects in your area, e.g. a children's hospice
* Let's meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
* Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken) and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!  

Have fun!  
Dirk
