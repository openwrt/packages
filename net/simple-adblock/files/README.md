# Simple AdBlock

A simple DNSMASQ/Unbound-based AdBlocking service for OpenWrt/LEDE Project.

## Features

- Super-fast due to the nature of supported block lists and parallel downloading/processing of the blacklists.
- Supports both hosts files and domains lists for blocking (to keep it lean and fast).
- Everything is configurable from Web UI.
- Allows you to easily add your own domains to whitelist or blacklist.
- Allows you to easily add URLs to your own blocked hosts or domains lists to block/whitelist (just put whitelisted domains one per line).
- Requires no configuration for the download utility wherever you want to use wget/libopenssl or uclient-fetch/libustream-mbedtls.
- Installs dependencies automatically.
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ/Unbound and firewall rules to serve NXDOMAIN or 127.0.0.1 (depending on settings) reply for blocked domains.
- As some of the default lists are using https, reliably works with either wget/libopenssl,  uclient-fetch/libustream-mbedtls or curl.
- Very lightweight and easily hackable, the whole script is just one ```/etc/init.d/simple-adblock``` file.
- Retains the downloaded/sorted AdBlocking list on service stop and reuses it on service start (use ```dl``` command if you want to force re-download of the list).
- Blocks ads served over https (unlike PixelServ-derived solutions).
- Proudly made in Canada, using locally-sourced electrons.

If you want a more robust AdBlocking, supporting free memory detection and complex block lists, supporting IDN, check out [net/adblock](https://github.com/openwrt/packages/tree/master/net/adblock/files).

## Screenshot (luci-app-simple-adblock)

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/simple-adblock/screenshot07.png "screenshot")

## Requirements

This service requires the following packages to be installed on your router: ```dnsmasq``` or ```dnsmasq-full``` or ```unbound``` and either ```ca-certificates```, ```wget``` and ```libopenssl``` (for OpenWrt 15.05.1) or ```uclient-fetch``` and ```libustream-mbedtls``` (for LEDE Project and OpenWrt 18.06.xx or newer). Additionally installation of ```coreutils-sort``` is highly recommended as it speeds up blocklist processing.

To satisfy the requirements for connect to your router via ssh and run the following commands:

### OpenWrt 15.05.1 Requirements

```sh
opkg update; opkg install ca-certificates wget libopenssl coreutils-sort dnsmasq
```

### LEDE Project 17.01.x and OpenWrt 18.xx (or newer) Requirements

```sh
opkg update; opkg install uclient-fetch libustream-mbedtls coreutils-sort dnsmasq
```

### IPv6 Support

For IPv6 support additionally install ```ip6tables-mod-nat``` and ```kmod-ipt-nat6``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install ip6tables-mod-nat kmod-ipt-nat6
```

### Speed Up Blocklist Processing

The ```coreutils-sort``` is an optional, but recommended package as it speeds up sorting and removing duplicates from the merged list dramatically. If opkg complains that it can't install ```coreutils-sort``` because /usr/bin/sort is already provided by busybox, you can run ```opkg --force-overwrite install coreutils-sort```.

## Unmet Dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How To Install

Install ```simple-adblock``` and ```luci-app-simple-adblock``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install simple-adblock luci-app-simple-adblock
```

If ```simple-adblock``` and ```luci-app-simple-adblock``` packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.

## Default Settings

Default configuration has service disabled (use Web UI to enable/start service or run ```uci set simple-adblock.config.enabled=1; uci commit simple-adblock;```) and selected ad/malware lists suitable for routers with 64Mb RAM. The configuration file has lists in descending order starting with biggest ones, comment out or delete the lists you don't want or your router can't handle.

## How To Customize

You can use Web UI (found in Services/Simple AdBlock) to add/remove/edit links to:

- [hosts files](https://en.wikipedia.org/wiki/Hosts_(file)) (127.0.0.1 or 0.0.0.0 followed by space and domain name per line) to be blocked.
- domains lists (one domain name per line) to be blocked.
- domains lists (one domain name per line) to be whitelisted. It is useful if you want to run ```simple-adblock``` on multiple routers and maintain one centralized whitelist which you can publish on a web-server.

Please note that these lists **must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix. Some of the top block lists (both hosts files and domains lists) suitable for routers with at least 8MB RAM are used in the default ```simple-adblock``` installation.

You can also use Web UI to add individual domains to be blocked or whitelisted.

If you want to use CLI to customize ```simple-adblock``` config, refer to the [Customization Settings](#customization-settings) section.

## How To Use

Once the service is enabled in the [config file](#default-settings), run ```/etc/init.d/simple-adblock start``` to start the service. Either ```/etc/init.d/simple-adblock restart``` or ```/etc/init.d/simple-adblock reload``` will only restart the service and/or re-donwload the lists if there were relevant changes in the config file since the last successful start. Had the previous start resulted in any error, either ```/etc/init.d/simple-adblock start```, ```/etc/init.d/simple-adblock restart``` or ```/etc/init.d/simple-adblock reload``` will attempt to re-download the lists.

If you want to force simple-adblock to re-download the lists, run ```/etc/init.d/simple-adblock dl```.

If you want to check if the specific domain (or part of the domain name) is being blocked, run ```/etc/init.d/simple-adblock check test-domain.com```.

## Configuration Settings

In the Web UI the ```simple-adblock``` settings are split into ```basic``` and ```advanced``` settings. The full list of configuration parameters of ```simple-adblock.config``` section is:

|Web UI Section|Parameter|Type|Default|Description|
| --- | --- | --- | --- | --- |
|Basic|enabled|boolean|0|Enable/disable the ```simple-adblock``` service.|
|Basic|verbosity|integer|2|Can be set to 0, 1 or 2 to control the console and system log output verbosity of the ```simple-adblock``` service.|
|Basic|force_dns|boolean|1|Force router's DNS to local devices which may have different/hardcoded DNS server settings. If enabled, creates a firewall rule to intercept DNS requests from local devices to external DNS servers and redirect them to router.|
|Basic|led|string|none|Use one of the router LEDs to indicate the AdBlocking status.|
|Advanced|dns|string|dnsmasq.servers|DNS resolution option. See [table below](#dns-resolution-option) for addtional information.|
|Advanced|ipv6_enabled|boolean|0|Add IPv6 entries to block-list if ```dnsmasq.addnhosts``` is used. This option is only visible in Web UI if the ```dnsmasq.addnhosts``` is selected as the DNS resolution option.|
|Advanced|boot_delay|integer|120|Delay service activation for that many seconds on boot up. You can shorten it to 10-30 seconds on modern fast routers. Routers with built-in modems may require longer boot delay.|
|Advanced|download_timeout|integer|10|Time-out downloads if no reply received within that many last seconds.|
|Advanced|curl_retry|integer|3|If ```curl``` is installed and detected, attempt that many retries for failed downloads.|
|Advanced|parallel_downloads|boolean|1|If enabled, all downloads are completed concurrently, if disabled -- sequentioally. Concurrent downloads dramatically speed up service loading.|
|Advanced|debug|boolean|0|If enabled, output service full debug to ```/tmp/simple-adblock.log```. Please note that the debug file may clog up the router's RAM on some devices. Use with caution.|
|Advanced|allow_non_ascii|boolean|0|Enable support for non-ASCII characters in the final AdBlocking file. Only enable if your target service supports non-ASCII characters. If you enable this on the system where DNS resolver doesn't support non-ASCII characters, it will crash. Use with caution.|
|Advanced|compressed_cache|boolean|0|Create compressed cache of the AdBlocking file in router's persistent memory. Only recommended to be used on routers with large ROM and/or routers with metered/flaky internet connection.|
||whitelist_domain|list/string||List of white-listed domains.|
||whitelist_domains_url|list/string||List of URL(s) to text files containing white-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix. Useful if you want to keep/publish a single white-list for multiple routers.|
||blacklist_domains_url|list/string||List of URL(s) to text files containing black-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|
||blacklist_hosts_url|list/string||List of URL(s) to [hosts files](https://en.wikipedia.org/wiki/Hosts_(file)) containing black-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|

### DNS Resolution Option

Currently supported options are:

|Option|Explanation|
| --- | --- |
|```dnsmasq.addnhosts```|Creates the DNSMASQ additional hosts file ```/var/run/simple-adblock.addnhosts``` and modifies DNSMASQ settings, so that DNSMASQ resolves all blocked domains to "local machine": 127.0.0.1. This option doesn't allow block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), so it results in a much larger block-list file, but, unlike other DNSMASQ-based options, it has almost no effect on the DNS look up speed. This option also allows quick reloads of DNSMASQ on block-list updates.|
|```dnsmasq.conf```|Creates the DNSMASQ config file ```/var/dnsmasq.d/simple-adblock``` so that DNSMASQ replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file. This option will slow down DNS look up speed somewhat.|
|```dnsmasq.servers```|Creates the DNSMASQ servers file ```/var/run/simple-adblock.servers``` and modifies DNSMASQ settings so that DNSMASQ replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file. This option will slow down DNS look up speed somewhat. This is a default setting as it results in the smaller block-file and allows quick reloads of DNSMASQ.|
|```unbound.adb_list```|Creates the Unbound config file ```/var/lib/unbound/adb_list.simple-adblock``` so that Unbound replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file.|

## How Does It Work

This service downloads (and processes in the background, removing comments and other useless data) lists of hosts and domains to be blocked, combines those lists into one big block list, removes duplicates and sorts it and then removes your whitelisted domains from the block list before converting to to DNSMASQ/Unbound-compatible file and restarting DNSMASQ/Unbound if needed. The result of the process is that DNSMASQ/Unbound return NXDOMAIN or 127.0.0.1 (depending on settings) for the blocked domains.

If you specify ```google.com``` as a domain to be whitelisted, you will have access to ```google.com```, ```www.google.com```, ```analytics.google.com```, but not fake domains like ```email-google.com``` or ```drive.google.com.verify.signin.normandeassociation.com``` for example. If you only want to allow ```www.google.com``` while blocking all other ```google.com``` subdomains, just specify ```www.google.com``` as domain to be whitelisted.

In general, whatever domain is specified to be whitelisted; it, along with with its subdomains will be whitelisted, but not any fake domains containing it.

## Documentation / Discussion

Please head to [OpenWrt Forum](https://forum.openwrt.org/t/simple-adblock-fast-lean-and-fully-uci-luci-configurable-adblocking/1327/) for discussion of this package.

## Thanks

I'd like to thank everyone who helped create, test and troubleshoot this service. Special thanks to [@hnyman](https://github.com/hnyman) for general package/luci guidance, [@dibdot](https://github.com/dibdot) for general guidance and block-list optimization code, [@ckuethe](https://github.com/ckuethe) for the curl support, non-ASCII filtering and compressed cache code, [@EricLuehrsen](https://github.com/EricLuehrsen) for the Unbound support information and [@phasecat](https://forum.openwrt.org/u/phasecat/summary) for submitting bugs and testing.
