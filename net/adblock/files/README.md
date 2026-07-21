<!-- markdownlint-disable -->

# DNS based ad/abuse domain blocking

## Table of Contents
* [Description](#description)
* [Quick Start](#quick-start)
* [Main Features](#main-features)
* [Prerequisites](#prerequisites)
* [Installation & Usage](#installation-and-usage)
* [Adblock CLI interface](#adblock-cli-interface)
* [Adblock Config Options](#adblock-config-options)
* [Examples](#examples)
* [Best practice and tweaks](#best-practice-and-tweaks)
* [Troubleshooting & debug options](#troubleshooting-and-debug-options)
* [Support](#support)
* [Removal](#removal)
* [Donations](#donations)

<a id="description"></a>
## Description
A lot of people already use adblocker plugins within their desktop browsers, but what if you are using your (smart) phone, tablet, watch or any other (wlan) gadget!? Getting rid of annoying ads, trackers and other abuse sites (like facebook) is simple: block them with your router.

When the DNS server on your router receives DNS requests, you will sort out queries that ask for the resource records of ad servers and return a simple `NXDOMAIN`. This is nothing but **N**on-e**X**istent Internet or Intranet domain name, if a domain name cannot be resolved using the DNS server, a condition called the `NXDOMAIN` occurred.

<a id="quick-start"></a>
## Quick Start
For a typical setup these few steps are enough to get adblock up and running — see the sections below for details:
1. Install the LuCI companion package: `apk update && apk add luci-app-adblock` (this pulls in the `adblock` backend as a dependency).
2. Enable the adblock system service under `System → Startup`, then open LuCI under `Services → Adblock`, tick `Enabled` and (recommended) set a `Startup Trigger Interface` to your WAN interface (avoid IPv6/wan6).
3. Keep the small, pre-selected default feed selection to start with (e.g. `adguard`, `adguard_tracking` and `certpl`, ≈280K domains).
4. Start and verify the service:

```sh
/etc/init.d/adblock start
/etc/init.d/adblock status
```

**Please note:** don't blindly enable (too) many feeds at once — on low memory devices this will sooner or later lead to OOM conditions.

<a id="main-features"></a>
## Main Features
Support of the following fully pre-configured domain blocklist feeds (free for private usage, for commercial use please check their individual licenses)

| Feed                | Enabled | Size | Focus            | Information                                                                       |
| :------------------ | :-----: | :--- | :--------------- | :-------------------------------------------------------------------------------- |
| 1Hosts              |         | VAR  | compilation      | [Link](https://github.com/badmojr/1Hosts)                                         |
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
| divested            |         | XXL  | compilation      | [Link](https://divested.dev/pages/dnsbl)                                          |
| doh_blocklist       |         | S    | doh_server       | [Link](https://github.com/dibdot/DoH-IP-blocklists)                               |
| firetv_tracking     |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| games_tracking      |         | S    | tracking         | [Link](https://www.gameindustry.eu)                                               |
| hagezi              |         | VAR  | compilation      | [Link](https://github.com/hagezi/dns-blocklists)                                  |
| hblock              |         | XL   | compilation      | [Link](https://hblock.molinero.dev)                                               |
| ipfire_dbl          |         | VAR  | compilation      | [Link](https://www.ipfire.org/dbl)                                                |
| oisd_big            |         | XXL  | general          | [Link](https://oisd.nl)                                                           |
| oisd_nsfw           |         | XXL  | porn             | [Link](https://oisd.nl)                                                           |
| oisd_nsfw_small     |         | M    | porn             | [Link](https://oisd.nl)                                                           |
| oisd_small          |         | L    | general          | [Link](https://oisd.nl)                                                           |
| phishing_army       |         | S    | phishing         | [Link](https://phishing.army)                                                     |
| smarttv_tracking    |         | S    | tracking         | [Link](https://github.com/Perflyst/PiHoleBlocklist)                               |
| spam404             |         | S    | general          | [Link](https://github.com/Dawsey21)                                               |
| stevenblack         |         | VAR  | compilation      | [Link](https://github.com/StevenBlack/hosts)                                      |
| stopforumspam       |         | S    | spam             | [Link](https://www.stopforumspam.com)                                             |
| utcapitole          |         | VAR  | general          | [Link](https://dsi.ut-capitole.fr/blacklists/index_en.php)                        |
| wally3k             |         | S    | compilation      | [Link](https://firebog.net/about)                                                 |
| whocares            |         | M    | general          | [Link](https://someonewhocares.org)                                               |
| winspy              |         | S    | win_telemetry    | [Link](https://github.com/crazy-max/WindowsSpyBlocker)                            |
| yoyo                |         | S    | general          | [Link](https://pgl.yoyo.org/adservers)                                            |

**Please note:** Feeds marked with size **VAR** (`1Hosts`, `hagezi`, `ipfire_dbl`, `stevenblack`, `utcapitole`) additionally require a category selection via the options `adb_hst_feed`, `adb_hag_feed`, `adb_ipf_feed`, `adb_stb_feed` and `adb_utc_feed` (or via the LuCI feed configuration). Without a category the feed is skipped during processing.  

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
* Fast downloads & list processing as they are handled in parallel running background jobs with multicore support
* The download engine supports ETAG headers to download only updated feeds
* Supports a wide range of router modes, even AP modes are supported
* Full IPv4 and IPv6 support
* Provides top level domain compression (`tld compression`), this feature removes thousands of needless host entries from the blocklist and lowers the memory footprint for the DNS backend
* Provides a `DNS Blocklist Shift`, where the generated final DNS blocklist is moved to the backup directory and only a soft link to this file is set in memory. As long as your backup directory is located on an external drive, you should activate this option to save valuable RAM.
* Feed parsing by a very fast & secure domain validator, all domain rules and feed information are placed in an external JSON file (`/etc/adblock/adblock.feeds`)
* Overall duplicate removal in generated blocklist file `adb_list.overall`
* Additional local allowlist for manual overrides, located in `/etc/adblock/adblock.allowlist`
* Additional local blocklist for manual overrides, located in `/etc/adblock/adblock.blocklist`
* Implements firewall‑based DNS Control to force DNS interfaces/ports and to redirect to external unfiltered/filtered DNS server
* Includes firewall‑based Remote DNS Allow, a CGI-Interface to allow certain MACs temporary bypass the local adblock DNS
* Supports firewall‑based temporary DNS Bridging, to ensure a Zero‑Downtime during adblock-related DNS Restarts
* Connection checks during blocklist update to ensure a reliable DNS backend service
* Minimal status & error logging to syslog, enable debug logging to receive more output
* Procd based init system support (`start`, `stop`, `restart`, `reload`, `enable`, `disable`, `running`, `status`, `suspend`, `resume`, `search`, `report`)
* Auto-Startup via procd network interface trigger or via classic time based startup
* Suspend & Resume adblock temporarily without blocklist re-processing
* Provides comprehensive runtime information
* Provides a detailed DNS Report with DNS related information about client requests, top (blocked) domains and more
* Provides a powerful search function to quickly find blocked (sub-)domains, e.g. to allow certain domains
* Implements a jail mode - only domains on the allowlist are permitted, all other DNS requests are rejected
* Automatic blocklist backup & restore: backups are used on `start`/`restart` and as a fallback on download errors — feeds are only actually refreshed via `reload`
* Send notification E-Mails, see example configuration below
* Add new adblock  feeds on your own with the `Custom Feed Editor` in LuCI or via CLI, see example below
* Strong LuCI support, all relevant options are exposed to the web frontend

<a id="prerequisites"></a>
## Prerequisites
* **[OpenWrt](https://openwrt.org)**, latest stable release or a development snapshot
* A usual setup with a working DNS backend
* A download utility with SSL support: `wget`, `uclient-fetch` with one of the `libustream-*` ssl libraries or `curl` is required
* A certificate store such as `ca-bundle` or `ca-certificates`, as adblock checks the validity of the SSL certificates of all download sites by default
* For E-Mail notifications you need to install and setup the additional `msmtp` package
* For DNS reporting you need to install the additional package `tcpdump-mini` or `tcpdump`

**Please note:**  
* Devices with less than 128MB of RAM are **_not_** supported
* For performance reasons, adblock depends on gnu sort and gawk
* Before update from former adblock releases please make a backup of your local allow- and blocklists. In the latest adblock these lists have been renamed to `/etc/adblock/adblock.allowlist` and `/etc/adblock/adblock.blocklist`. There is no automatic content transition to the new files.
* The uci configuration of adblock is automatically migrated during package installation via the uci-defaults mechanism using a housekeeping script
* Only `reload` actually refreshes the feeds (ETag check plus download of changed feeds). `start`, `restart` — and `boot`/`resume` — restore the existing blocklist backups and only download feeds that have **no** backup yet; they do **not** re-fetch already cached feeds. To update your blocklists (e.g. from a cron job) always use `reload`


<a id="installation-and-usage"></a>
## Installation & Usage
* Make a backup and update your local opkg/apk repository
* Install the LuCI companion package `luci-app-adblock` which also installs the main `adblock` package as a dependency
* Enable the adblock system service (System -> Startup) and enable adblock itself (adblock -> General Settings)
* It's strongly recommended to use the LuCI frontend to easily configure all aspects of adblock, the application is located in LuCI under the `Services` menu
* It's also recommended to configure a `Startup Trigger Interface` to depend on your WAN ifup events during boot or restart of your router. Avoid IPv6 (wan6) interfaces here, as IPv6/netifd is chatty and would trigger frequent unnecessary adblock restarts

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
	search          <domain> Search active blocklists and backups for a specific domain
	report          [<cli>|<mail>|<gen>|<json>] Print DNS statistics
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

The `report` sub-command accepts an output mode: `cli` (default, human-readable table printed to the console), `json` (machine-readable output, incl. GeoIP map data when `adb_map=1`), `mail` (send the report via `msmtp`) and `gen` (regenerate the report data files in the background, used by the LuCI frontend).

<a id="adblock-config-options"></a>
## Adblock Config Options
* Usually the auto pre-configured adblock setup works quite well and no manual overrides are needed

| Option               | Default                            | Description/Valid Values                                                                           |
| :------------------- | :--------------------------------- | :------------------------------------------------------------------------------------------------- |
| adb_enabled          | 1, enabled                         | set to 0 to disable the adblock service                                                            |
| adb_feedfile         | /etc/adblock/adblock.feeds         | full path to the used adblock feed file                                                            |
| adb_dns              | -, auto-detected                   | `dnsmasq`, `unbound`, `named`, `kresd`, `smartdns` or `raw`                                        |
| adb_cores            | -, auto-detected                   | limit the cpu cores used by adblock to save RAM; auto-detected and capped to the available memory  |
| adb_fetchcmd         | -, auto-detected                   | `uclient-fetch`, `wget` or `curl`                                                                  |
| adb_fetchparm        | -, auto-detected                   | manually override the config options for the selected download utility                             |
| adb_fetchretry       | 5                                  | number of download attempts in case of an error (not supported by uclient-fetch)                   |
| adb_fetchinsecure    | 0, disabled                        | don't check SSL server certificates during download                                                |
| adb_trigger          | -, not set                         | logical reload trigger interface(s), e.g. `wan` (avoid IPv6 interfaces)                            |
| adb_triggerdelay     | 5                                  | additional trigger delay in seconds before adblock processing begins                               |
| adb_debug            | 0, disabled                        | set to 1 to enable the debug output                                                                |
| adb_nicelimit        | 0, standard prio.                  | valid nice level range 0-19 of the adblock processes                                               |
| adb_dnsshift         | 0, disabled                        | shift the blocklist to the backup directory and only set a soft link to this file in memory        |
| adb_dnsdir           | -, auto-detected                   | path for the generated blocklist file `adb_list.overall`                                           |
| adb_dnstimeout       | 20                                 | timeout in seconds to wait for a successful DNS backend restart                                    |
| adb_dnsinstance      | 0, first instance                  | set the relevant dnsmasq backend instance used by adblock                                          |
| adb_dnsflush         | 0, disabled                        | set to 1 to flush the DNS Cache before & after adblock processing                                  |
| adb_lookupdomain     | localhost                          | domain to check for a successful DNS backend restart                                               |
| adb_report           | 0, disabled                        | set to 1 to enable the background tcpdump gathering process for reporting                          |
| adb_map              | 0, disabled                        | enable a GeoIP Map with blocked domains                                                            |
| adb_reportdir        | /tmp/adblock-report                | path for DNS related report files                                                                  |
| adb_repiface         | -, auto-detected                   | name of the reporting interface or `any` used by tcpdump                                           |
| adb_repport          | 53                                 | list of reporting port(s) used by tcpdump                                                          |
| adb_repchunkcnt      | 5                                  | report chunk count used by tcpdump                                                                 |
| adb_repchunksize     | 1                                  | report chunk size used by tcpdump in MB                                                            |
| adb_represolve       | 0, disabled                        | resolve reporting IP addresses using reverse DNS (PTR) lookups                                     |
| adb_tld              | 1, enabled                         | set to 0 to disable the top level domain compression (tld) function                                |
| adb_basedir          | /tmp                               | path for all adblock related runtime operations, e.g. downloading, sorting, merging etc.           |
| adb_backupdir        | /tmp/adblock-backup                | path for adblock backups                                                                           |
| adb_safesearch       | 0, disabled                        | enforce SafeSearch for google, bing, brave, duckduckgo, yandex, youtube and pixabay                |
| adb_safesearchlist   | -, not set                         | limit SafeSearch to certain provider (see above)                                                   |
| adb_mail             | 0, disabled                        | set to 1 to enable notification E-Mails in case of a processing errors                             |
| adb_mailreceiver     | -, not set                         | receiver address for adblock notification E-Mails                                                  |
| adb_mailsender       | no-reply@adblock                   | sender address for adblock notification E-Mails                                                    |
| adb_mailtopic        | adblock notification               | topic for adblock notification E-Mails                                                             |
| adb_mailprofile      | adb_notify                         | mail profile used in `msmtp` for adblock notification E-Mails                                      |
| adb_jail             | 0                                  | jail mode - only domains on the allowlist are permitted, all other DNS requests are rejected       |
| adb_nftforce         | 0, disabled                        | redirect all local DNS queries from specified LAN zones to the local DNS resolver                  |
| adb_nftdevforce      | -, not set                         | firewall LAN Devices/VLANs that should be forced locally                                           |
| adb_nftportforce     | -, not set                         | firewall ports that should be forced locally                                                       |
| adb_nftallow         | 0, disabled                        | routes MACs or interfaces to an unfiltered external DNS resolver, bypassing local adblock          |
| adb_nftmacallow      | -, not set                         | listed MAC addresses will always use the configured unfiltered DNS server                          |
| adb_nftdevallow      | -, not set                         | entire interfaces or VLANs will be routed to the unfiltered DNS server                             |
| adb_allowdnsv4       | -, not set                         | external IPv4 DNS resolver applied to MACs and interfaces using the unfiltered DNS policy          |
| adb_allowdnsv6       | -, not set                         | external IPv6 DNS resolver applied to MACs and interfaces using the unfiltered DNS policy          |
| adb_nftremote        | 0, disabled                        | routes MACs to an unfiltered external DNS resolver, bypassing local adblock                        |
| adb_nftmacremote     | -, not set                         | Allows listed MACs to remotely access an unfiltered external DNS resolver, bypassing local adblock |
| adb_nftremotetimeout | 15                                 | Time limit in minutes for remote DNS access of the listed MAC addresses                            |
| adb_remotednsv4      | -, not set                         | external IPv4 DNS resolver applied to MACs using the unfiltered remote DNS policy                  |
| adb_remotednsv6      | -, not set                         | external IPv6 DNS resolver applied to MACs using the unfiltered remote DNS policy                  |
| adb_nftblock         | 0, disabled                        | routes MACs or interfaces to a filtered external DNS resolver, bypassing local adblock             |
| adb_nftmacblock      | -, not set                         | listed MAC addresses will always use the configured filtered DNS server                            |
| adb_nftdevblock      | -, not set                         | entire interfaces or VLANs will be routed to the filtered DNS server                               |
| adb_blockdnsv4       | -, not set                         | external IPv4 DNS resolver applied to MACs and interfaces using the filtered DNS policy            |
| adb_blockdnsv6       | -, not set                         | external IPv6 DNS resolver applied to MACs and interfaces using the filtered DNS policy            |
| adb_nftbridge        | -, not set                         | enables a temporary DNS bridge to an external DNS resolver during local DNS restarts               |
| adb_bridgednsv4	     | -, not set                         | external IPv4 DNS resolver used during bridging                                                    |
| adb_bridgednsv6	     | -, not set                         | external IPv6 DNS resolver used during bridging                                                    |
| adb_hst_feed         | -, not set                         | category selection for the `1hosts` feed (required to enable it)                                   |
| adb_hag_feed         | -, not set                         | category selection for the `hagezi` feed (required to enable it)                                   |
| adb_ipf_feed         | -, not set                         | category selection for the `ipfire_dbl` feed (required to enable it)                               |
| adb_stb_feed         | -, not set                         | category selection for the `stevenblack` feed (required to enable it)                              |
| adb_utc_feed         | -, not set                         | category selection for the `utcapitole` feed (required to enable it)                               |

<a id="examples"></a>
## Examples

**Change the DNS backend to `unbound`:**  
No further configuration is needed, adblock deposits the final blocklist `adb_list.overall` in `/var/lib/unbound` by default.
To preserve the DNS cache after adblock processing please install the additional package `unbound-control`.

**Change the DNS backend to `bind`:**  
Adblock deposits the final blocklist `adb_list.overall` in `/var/lib/bind` by default.
To preserve the DNS cache after adblock processing please install the additional package `bind-rndc`.
To use the blocklist please modify `/etc/bind/named.conf`:

```
in the `options` namespace add:
  response-policy { zone "rpz"; };

and at the end of the file add:
  zone "rpz" {
    type master;
    file "/var/lib/bind/adb_list.overall";
    allow-query { none; };
    allow-transfer { none; };
  };
```

**Change the DNS backend to `kresd`:**  
Adblock deposits the final blocklist `adb_list.overall` in `/tmp/kresd`, no further configuration needed.

**Change the DNS backend to `smartdns`:**  
No further configuration is needed, adblock deposits the final blocklist `adb_list.overall` in `/tmp/smartdns` by default.

**Service status output:**  
In LuCI you'll see the realtime status in the `Runtime` section on the overview page.
To get the status in the CLI, just call _/etc/init.d/adblock status_ or _/etc/init.d/adblock status\_service_:

```sh
root@blackhole:~# /etc/init.d/adblock status
::: adblock runtime information
  + adblock_status  : enabled
  + frontend_ver    : 4.5.2-r4
  + backend_ver     : 4.5.2-r4
  + blocked_domains : 888 135
  + active_feeds    : 1hosts, adguard, adguard_tracking, bitcoin, certpl, doh_blocklist, hagezi, ipfire_dbl, phishing_army, smarttv_tracking, stevenblack, winspy
  + dns_backend     : unbound (1.24.2-r1), /mnt/data/adblock/backup, 346.57 MB
  + run_ifaces      : trigger: wan, report: br-lan
  + run_information : base: /mnt/data/adblock, dns: /var/lib/unbound, backup: /mnt/data/adblock/backup, report: /mnt/data/adblock/report, error: /dev/null
  + run_flags       : shift: ✔, custom feed: ✘, ext. DNS (std/prot/remote/bridge): ✘/✔/✔/✔, force: ✔, flush: ✘, tld: ✔, search: ✘, report: ✔, mail: ✔, jail: ✘, debug: ✘
  + last_run        : mode: reload, 2026-03-12T19:08:41+01:00, duration: 0m 57s, 1337.01 MB available
  + system_info     : cores: 4, fetch: curl, Bananapi BPI-R3, mediatek/filogic, OpenWrt SNAPSHOT (r33360-ab0872a734)
```

<a id="best-practice-and-tweaks"></a>
## Best practice and tweaks

**Recommendation for low memory systems**  
adblock keeps all working data in RAM to avoid unnecessary flash wear. The number of parallel processing jobs and the sort buffer size are automatically scaled to the available memory, so on constrained devices adblock already throttles itself during feed processing. On devices with only 128–256 MB RAM, you can further reduce memory pressure with the following optimizations:
* Limit CPU parallelism: the core count is auto-capped to the available memory; you can additionally set `adb_cores=1` to force single-threaded processing with minimal peak memory
* Use external storage: Set adb_basedir, adb_backupdir and adb_reportdir to a USB drive or SSD to offload temporary and persistent data
* Enable blocklist shifting: Activate adb_dnsshift to store the generated blocklist on external storage and keep only a symlink in RAM
* Use firewall‑based DNS redirection: Route DNS queries via nftables to external filtered DNS resolvers and keep only a minimal local blocklist active
* Use compressed swap: install the `zram-swap` package so the kernel can page out cold memory into compressed RAM under pressure (see below)

**Use compressed swap (zram-swap) on low memory devices**  
The simplest way to survive the memory peak during feed processing is to give the kernel a compressed swap device and let it page out cold memory under pressure. The `zram-swap` package sets this up automatically at boot — no scripting, no changes to adblock, and adblock benefits transparently. Because the swap lives in compressed RAM rather than on flash, this incurs no flash wear.

```sh
apk add zram-swap
```
Size the swap device relative to your physical RAM — a sensible rule of thumb is half to one times the installed RAM. Note that the compressed pages occupy RAM themselves, so do not oversize it on very small devices:

| Installed RAM | Suggested `zram_size_mb` |
| :------------ | :----------------------- |
| 128 MB        | 64–128                   |
| 256 MB        | 128–256                  |
| 512 MB        | 256–512                  |
| 1 GB and more | 512                      |

The device size is configured in `/etc/config/system` via LuCI (System -> ZRam Settings) or via CLI:

```sh
uci set system.@system[0].zram_size_mb='128'
uci commit system
/etc/init.d/zram restart
```

A running zram device cannot be resized in place, so the `restart` is required for a changed size to take effect.  
To make the kernel reclaim into zram more eagerly during the short processing peak, raise the swappiness and persist it across reboots, e.g.:

```sh
echo 'vm.swappiness=100' >> /etc/sysctl.conf
sysctl -p
```

Leave `adb_basedir` and `adb_backupdir` at their defaults. On very small devices (128 MB) compressed swap helps, but heavy swapping costs CPU — if RAM is truly marginal, the more honest fix is to activate fewer feeds.

**Sensible choice of blocklists**  
The following feeds are just my personal recommendation as an initial setup:
* `adguard`, `adguard_tracking` and `certpl`

In total, this feed selection blocks about 280K domains. It may also be useful to include compilations like hagezi, stevenblack or oisd.
Please note: don`t just blindly activate too many feeds at once, sooner or later this will lead to OOM conditions.

**DNS reporting, enable the GeoIP Map**  
adblock includes a powerful reporting tool on the DNS Report tab which shows the latest DNS statistics generated by tcpdump. To get the latest statistics always press the "Refresh" button.
In addition to a tabular overview adblock reporting includes a GeoIP map in a modal popup window/iframe that shows the geolocation of your own uplink addresses (in green) and the locations of blocked domains in red. To enable the GeoIP Map set the following option in "Advanced Report Settings" config tab: set `adb_map` to `1` to include the external components listed below and activate the GeoIP map.

To make this work, adblock uses the following external components:
* [Leaflet](https://leafletjs.com/) is a lightweight open-source JavaScript library for interactive maps
* [OpenStreetMap](https://www.openstreetmap.org/) provides the map data under an open-source license
* [CARTO basemap styles](https://github.com/CartoDB/basemap-styles) based on [OpenMapTiles](https://openmaptiles.org/schema)
* The free and quite fast [IP Geolocation API](https://ip-api.com/) to resolve the required IP/geolocation information (max. 45 blocked Domains per request)

**External adblock test**  
In addition to the built‑in DNS reporting and GeoIP map, adblock users can verify the effectiveness of their configuration with an external test page. The [Adblock Test](https://adblock.turtlecute.org/) provides a simple way to check whether your current adblock setup is working as expected. It loads a series of test elements (ads, trackers, and other resources) and reports whether they are successfully blocked by your configuration.

The test runs entirely in the browser and does not require additional configuration. For best results, open the page in the same environment where adblock is active and review the results displayed.

**Firewall‑Based DNS Control**  
adblock provides several advanced firewall‑integrated features that allow you to enforce DNS policies directly at the network layer. These mechanisms operate independently of the local DNS resolver and ensure that DNS traffic follows your filtering rules, even when clients attempt to bypass them.
* Unfiltered external DNS Routing: routes DNS queries from selected devices or interfaces to an external unfiltered DNS resolver
* Filtered external DNS Routing: routes DNS queries from selected devices or interfaces to an external filtered DNS resolver
* Force DNS: blocks or redirects all external DNS traffic to ensure that clients use the local resolver

The DNS routing allows you to apply external DNS (unfiltered and/or filtered) to specific devices or entire network segments. DNS queries from these targets are transparently redirected to a chosen external resolver (IPv4 and/or IPv6):
* MAC‑based targeting for individual devices
* Interface/VLAN targeting for entire segments
* Separate IPv4/IPv6 resolver selection
* Transparent DNS redirection without client‑side configuration
This mode is ideal for guest networks, IoT devices, or environments where certain clients require stricter/lesser DNS filtering.

force DNS ensures that all DNS traffic on your network by specific devices or entire network segments is processed by the local resolver. Any attempt to use external DNS servers is blocked or redirected.
* Blocks external DNS on port 53 and redirects DNS queries to the local resolver when appropriate
* Also prevents DNS bypassing by clients with hardcoded DNS settings on other ports, e.g. on port 853
This mode guarantees that adblock’s filtering pipeline is always applied.

adblock's firewall rules are based on nftables in a separate isolated nftables table (inet adblock) and chains (prerouting), with MAC addresses stored in a nftables set. The configuration is carried out centrally in LuCI on the ‘Firewall Settings’ tab in adblock.

**Remote DNS Allow (Temporary MAC‑Based Bypass)**  
This additional firewall feature lets selected client devices temporarily bypass local DNS blocking and use an external, unfiltered DNS resolver. It is designed for situations where a device needs short‑term access to content normally blocked by the adblock rules.

A lightweight CGI endpoint handles the workflow:
* The client opens the URL, e.g. http(s)://\<ROUTER-IP\>/cgi-bin/adblock (preferably transferred via QR code shown in LuCI)
* The script automatically detects the device’s MAC address
* If the MAC is authorized, the script displays the current status:
  * Not in the nftables set → option to request a temporary allow (“Bypass”)
  * Already active → shows remaining timeout
* When renewing, the CGI adds the MAC to an nftables Set with a per‑entry timeout

The CGI interface is mobile‑friendly and includes a LuCI‑style loading spinner during the renew process, giving immediate visual feedback while the nftables entry is created. All operations are atomic and safe even when multiple devices renew access in parallel.

**Temporary DNS Bridging (Zero‑Downtime during DNS Restarts)**  
Adblock can optionally enable a temporary DNS bridging mode to avoid DNS downtime during DNS backend restarts.
When this feature is enabled, all DNS queries from LAN clients are briefly redirected to an external fallback resolver until the local DNS backend becomes available again. This ensures that DNS resolution continues to work seamlessly for all clients, even while adblock reloads blocklists or restarts the DNS service. Just set the options `adb_nftbridge`, `adb_bridgednsv4` and `adb_bridgednsv6` accordingly.

**Jail mode (allowlist-only):**  
Enforces a strict allowlist‑only DNS policy in which only domains listed in the allowlist file are resolved, while every other query is rejected. This mode is intended for highly restrictive environments and depends on a carefully maintained allowlist, typically managed manually.

**Download options**  
By default adblock uses the following pre-configured download options:

```
    * curl: --connect-timeout 20 --retry-delay 10 --retry 4 --retry-max-time 80 --retry-all-errors --fail --silent --show-error --location -o
    * wget: --no-cache --no-cookies --timeout=20 --waitretry=10 --tries=5 --retry-connrefused -O
    * uclient-fetch: --timeout=20 -O
```

To override the default set `adb_fetchretry`, `adb_fetchinsecure` or globally `adb_fetchparm` to your needs.

**Enable E-Mail notification via `msmtp`:**  
To use the email notification you have to install & configure the package `msmtp`.
Modify the file `/etc/msmtprc`:
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
Finally enable E-Mail support, add a valid E-Mail receiver address in LuCI and setup an appropriate cron job.

**Automatic adblock feed updates and E-Mail reports**  
For a regular, automatic update of the used feeds or other regular adblock tasks set up a cron job. Use `reload` here — `start`/`restart` would only restore the backups instead of fetching fresh feeds. In LuCI you find the cron settings under `System` => `Scheduled Tasks`. On the command line the cron file is located at `/etc/crontabs/root`:  

Example 1
```sh
# update the adblock feeds every morning at 4 o'clock
00 04 * * * /etc/init.d/adblock reload
```

Example 2
```sh
# update the adblock feeds every hour
0 */1 * * * /etc/init.d/adblock reload
```

Example 3
```sh
# send an adblock E-Mail report every morning at 3 o'clock
00 03 * * * /etc/init.d/adblock report mail
```

**Change/add adblock feeds**  
The adblock default blocklist feeds are stored in an external JSON file `/etc/adblock/adblock.feeds`. This file is shipped with the package and is **overwritten on every package update**, so never edit it directly. All of your custom changes belong in the separate JSON file `/etc/adblock/adblock.custom.feeds` (empty by default), which is preserved across updates. It's recommended to use the LuCI based Custom Feed Editor (`Custom Feed Editor` tab), which validates the JSON for you.

**Please note:** if `/etc/adblock/adblock.custom.feeds` exists and is non-empty, it is loaded **instead of** the shipped `adblock.feeds` — it replaces the feed set, it does not merge with it. A custom feed file must therefore contain *every* feed you want active, not just your additions. The Custom Feed Editor handles this for you by working on a full copy.

A feed is a single JSON object, keyed by a unique feed name (no spaces, no special characters). Example:

```json
	[...]
	"stevenblack": {
		"url": "https://raw.githubusercontent.com/StevenBlack/hosts/master/",
		"rule": "feed 0.0.0.0 2",
		"size": "VAR",
		"descr": "compilation"
	},
	[...]
```

The object supports the following fields:

| Field | Required | Description                                                                                               |
| :---- | :------: | :-------------------------------------------------------------------------------------------------------- |
| url   | yes      | download URL of the domain list (for category feeds: the base URL, see below)                             |
| rule  | yes      | the parsing ruleset, max. 4 space separated parameters (see below)                                        |
| size  | yes      | size hint shown in LuCI: `S`, `M`, `L`, `XL`, `XXL` or `VAR` (see the feed table legend in Main Features) |
| descr | yes      | a short human-readable description shown in LuCI and the feed table                                       |

**The `rule` field**  
The rule consists of max. 4 individual, space separated parameters:
1. **type**: always `feed` (required). adblock only supports the `feed` type for external sources; any source whose rule does not start with `feed` is skipped.
2. **prefix**: an optional search term (a literal string, not a regex) that a line must contain to be treated as a valid entry. Use it to pick the relevant rows of a hosts-style file, e.g. `0.0.0.0`. Omit it for a plain list with one bare domain per line.
3. **column**: the 1-based column that holds the domain within a matching line, e.g. `2` for a `0.0.0.0 example.com` hosts file or `1` for a bare list (required). When no prefix is used, give the column directly, e.g. `feed 1`.
4. **separator**: an optional field separator; default is the whitespace character class `[[:space:]]+`. Pass a literal character such as `,` for comma-separated sources.

Examples:
* `feed 1` — plain list, one domain per line, domain in column 1
* `feed 0.0.0.0 2` — hosts-style file, keep only `0.0.0.0` lines, domain in column 2
* `feed 1 ,` — comma-separated source, domain in the first field

**Category-based feeds (size `VAR`)**  
The feeds marked `VAR` in the feed table (`1hosts`, `hagezi`, `ipfire_dbl`, `stevenblack`, `utcapitole`) are built-in feeds that require an additional category selection via the dedicated options `adb_hst_feed`, `adb_hag_feed`, `adb_ipf_feed`, `adb_stb_feed` and `adb_utc_feed` (or the LuCI feed configuration). For these, the `url` is a **base URL** to which the selected category is appended at download time. This category mechanism is wired to those specific feed names in the backend, so it cannot be reused for arbitrary new feeds — a custom feed you add yourself should point `url` at a single, complete list URL.

After editing `/etc/adblock/adblock.custom.feeds`, reload adblock (`/etc/init.d/adblock reload`) and check the `Log View` tab (or `logread -e adblock-`). With `adb_debug` enabled, a malformed JSON object or a wrong column/separator typically shows up there as a feed that produces zero domains.

<a id="troubleshooting-and-debug-options"></a>
## Troubleshooting & debug options
Adblock provides an optional debug mode that writes diagnostic information to the system log and captures internal error output in a dedicated error logfile - by default located in the adblock base directory as `/tmp/adb_error.log`. The log file is automatically cleared at the beginning of each run. Under normal conditions, all error messages are discarded to keep regular runs clean and silent. To enable debug mode, set the option `adb_debug` to `1`. When enabled, the script produces significantly more log output to assist with troubleshooting.

Whenever you encounter adblock related processing problems, please enable debug logging, restart adblock and check the `Log View` tab in LuCI (or the syslog via `logread -e adblock-`).

<a id="support"></a>
## Support
Please join the adblock discussion in this [forum thread](https://forum.openwrt.org/t/adblock-support-thread/507) or contact me by mail <dev@brenken.org>

<a id="removal"></a>
## Removal
Stop all adblock related services with _/etc/init.d/adblock stop_ and remove the adblock package if necessary.

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
