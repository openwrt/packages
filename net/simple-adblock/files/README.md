# Simple AdBlock

[![HitCount](http://hits.dwyl.com/stangri/openwrt/simple-adblock.svg)](http://hits.dwyl.com/stangri/openwrt/simple-adblock)

A simple DNSMASQ/Unbound-based AdBlocking service for OpenWrt/LEDE Project.

## Features

- Super-fast due to the nature of supported block-lists and parallel downloading/processing of the block-lists.
- Supports hosts files and domains lists for blocking.
- Everything is configurable from Web UI.
- Allows you to easily add your own domains to allow-list or block-list.
- Allows you to easily add URLs to your own blocked hosts or domains lists to allow/block-list (just put allowed domains one per line in the file you're linking).
- Supports multiple modes of AdBlocking implementations with DNSMASQ and Unbound.
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ/Unbound and firewall rules to serve NXDOMAIN or 127.0.0.1 reply or to reject access (depending on settings) for blocked domains.
- As some of the default lists are using https, reliably works with either wget/libopenssl,  uclient-fetch/libustream-mbedtls or curl.
- Very lightweight and easily hackable, the whole script is just one ```/etc/init.d/simple-adblock``` file.
- Retains the downloaded/sorted AdBlocking list on service stop and reuses it on service start (use ```dl``` command if you want to force re-download of the list).
- Has an option to store a compressed copy of the AdBlocking list in persistent memory which survives reboots.
- Blocks ads served over https (unlike PixelServ-derived solutions).
- Blocks ads inside browsers with [DNS-over-HTTPS proxy](https://en.wikipedia.org/wiki/DNS_over_HTTPS) built-in, like [Mozilla Firefox](https://support.mozilla.org/en-US/kb/firefox-dns-over-https#w_about-dns-over-https) or [Google Chrome/Chromium](https://blog.chromium.org/2019/09/experimenting-with-same-provider-dns.html) -- with the ```dnsmasq.ipset``` option.
- Proudly made in Canada, using locally-sourced electrons.

If you want a more robust AdBlocking, supporting free memory detection and complex block-lists, supporting IDN, check out ```net/adblock``` on [GitHub](https://github.com/openwrt/packages/tree/master/net/adblock/files)/[jsDelivr](https://cdn.jsdelivr.net/gh/openwrt/packages@master/net/adblock/files/README.md).

## Screenshots (luci-app-simple-adblock)

Service Status

![screenshot](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/simple-adblock/screenshot08-status.png "Service Status")

Configuration - Basic Configuration

![screenshot](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/simple-adblock/screenshot08-config-basic.png "Configuration - Basic Configuration")

Configuration - Advanced Configuration

![screenshot](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/simple-adblock/screenshot08-config-advanced.png "Configuration - Advanced Configuration")

Allowed and Blocked Lists Management

![screenshot](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/simple-adblock/screenshot09-lists.png "Allow-list and Block-list Management")

## Requirements

To download the hosts/domains files this service requires one of the following packages to be installed on your device: ```wget``` or ```uclient-fetch``` or ```curl```. If you want to download lists over HTTPS (recommended), you also need to install support for HTTPS/SSL downloads on your device. For most devices starting with OpenWrt 15.05.1 and up the following commands will install the minimal requirements:

```sh
opkg update; if ubus -S call system board | grep -q '15.05'; then
opkg install ca-certificates wget libopenssl; else
opkg install uclient-fetch libustream-mbedtls ca-bundle ca-certificates; fi
```

### Requirements for file:// Scheme

If you want to include some local files as the allow-lists or block-lists, you need to install ```curl```:

```sh
opkg update; opkg install curl;
```

### Requirements for DNS Resolver

In order to actually block the ads, this service requires one of the following DNS resolvers to be installed on your router: ```dnsmasq``` or ```dnsmasq-full``` or ```unbound```. The ```dnsmasq``` package is usually included in the default OpenWrt installation.

If you want to use the [```dnsmasq.ipset``` option](#dns-resolution-option) you need to install ```ipset``` and  ```dnsmasq-full``` instead of the ```dnsmasq```. To do that, connect to your router via ssh and run the following command:

```sh
opkg update; cd /tmp/; opkg download dnsmasq-full; opkg install ipset;
opkg remove dnsmasq; opkg install /tmp/dnsmasq-full*; rm -f /tmp/dnsmasq-full*;
```

### Requirements for IPv6 Support

For IPv6 support additionally install ```ip6tables-mod-nat``` and ```kmod-ipt-nat6``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install ip6tables-mod-nat kmod-ipt-nat6;
```

### Requirements for Faster Block-list Processing

The ```coreutils-sort``` is an optional, but recommended package as it speeds up sorting and removing duplicates from the merged list dramatically. If opkg complains that it can't install ```coreutils-sort``` because /usr/bin/sort is already provided by busybox, you can run the following command:

```sh
opkg --force-overwrite install coreutils-sort
```

## Unmet Dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How To Install

Install ```simple-adblock``` and ```luci-app-simple-adblock``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install simple-adblock luci-app-simple-adblock
```

If ```simple-adblock``` and ```luci-app-simple-adblock``` packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to add a custom repo to your router following instructions on [GitHub](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router)/[jsDelivr](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/README.md#on-your-router) first.

## Default Settings

Default configuration has the service disabled (use Web UI to enable/start service or run ```uci set simple-adblock.config.enabled=1; uci commit simple-adblock;```) and selected ad/malware lists suitable for routers with 64Mb RAM.

If your router has less then 64Mb RAM, edit the configuration file, located at ```/etc/config/simple-adblock```. The configuration file has lists in ascending order starting with smallest ones and each list has a preceding comment indicating its size, comment out or delete the lists you don't want or your router can't handle.

## How To Customize

You can use Web UI (found in Services/Simple AdBlock) to add/remove/edit links to:

- [hosts files](https://en.wikipedia.org/wiki/Hosts_(file)) (127.0.0.1 or 0.0.0.0 followed by space and domain name per line) to be blocked.
- domains lists (one domain name per line) to be blocked.
- domains lists (one domain name per line) to be allowed. It is useful if you want to run ```simple-adblock``` on multiple routers and maintain one centralized allow-list which you can publish on a web-server.

Please note that these lists **must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix. Some of the top block-lists (both hosts files and domains lists) suitable for routers with at least 8MB RAM are used in the default ```simple-adblock``` installation.

You can also use Web UI to add individual domains to be blocked or allowed.

If you want to use CLI to customize ```simple-adblock``` config, refer to the [Customization Settings](#customization-settings) section.

## How To Use

Once the service is enabled in the [config file](#default-settings), run ```/etc/init.d/simple-adblock start``` to start the service. Either ```/etc/init.d/simple-adblock restart``` or ```/etc/init.d/simple-adblock reload``` will only restart the service and/or re-download the lists if there were relevant changes in the config file since the last successful start. Had the previous start resulted in any error, either ```/etc/init.d/simple-adblock start```, ```/etc/init.d/simple-adblock restart``` or ```/etc/init.d/simple-adblock reload``` will attempt to re-download the lists.

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
||dns_instance|string|0|String of space-separated DNSMASQ instance numbers (or '*' for all) to be affected by the service. See [table below](#dns-resolution-option) for addtional information.|
|Advanced|ipv6_enabled|boolean|0|Add IPv6 entries to block-list if ```dnsmasq.addnhosts``` is used. This option is only visible in Web UI if the ```dnsmasq.addnhosts``` is selected as the DNS resolution option.|
|Advanced|boot_delay|integer|120|Delay service activation for that many seconds on boot up. You can shorten it to 10-30 seconds on modern fast routers. Routers with built-in modems may require longer boot delay.|
|Advanced|download_timeout|integer|10|Time-out downloads if no reply received within that many last seconds.|
|Advanced|curl_retry|integer|3|If ```curl``` is installed and detected, attempt that many retries for failed downloads.|
|Advanced|parallel_downloads|boolean|1|If enabled, all downloads are completed concurrently, if disabled -- sequentioally. Concurrent downloads dramatically speed up service loading.|
|Advanced|debug|boolean|0|If enabled, output service full debug to ```/tmp/simple-adblock.log```. Please note that the debug file may clog up the router's RAM on some devices. Use with caution.|
|Advanced|allow_non_ascii|boolean|0|Enable support for non-ASCII characters in the final AdBlocking file. Only enable if your target service supports non-ASCII characters. If you enable this on the system where DNS resolver doesn't support non-ASCII characters, it will crash. Use with caution.|
|Advanced|compressed_cache|boolean|0|Create compressed cache of the AdBlocking file in router's persistent memory. Only recommended to be used on routers with large ROM and/or routers with metered/flaky internet connection.|
||allowed_domain|list/string||List of allowed domains.|
||allowed_domains_url|list/string||List of URL(s) to text files containing allowed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix. Useful if you want to keep/publish a single allow-list for multiple routers.|
||blocked_domain|list/string||List of blocked domains.|
||blocked_domains_url|list/string||List of URL(s) to text files containing blocked domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|
||blocked_hosts_url|list/string||List of URL(s) to [hosts files](https://en.wikipedia.org/wiki/Hosts_(file)) containing block-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|

### DNS Resolution Option

Currently supported options are:

|Option|Explanation|
| --- | --- |
|```dnsmasq.addnhosts```|Creates the DNSMASQ additional hosts file ```/var/run/simple-adblock.addnhosts``` and modifies DNSMASQ settings, so that DNSMASQ resolves all blocked domains to "local machine": 127.0.0.1. This option doesn't allow block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), so it results in a much larger block-list file, but, unlike other DNSMASQ-based options, it has almost no effect on the DNS look up speed. This option also allows quick reloads of DNSMASQ on block-list updates. This setting also allows you to configure which DNSMASQ instances would be affected by AdBlocking via ```dns_instance``` option.|
|```dnsmasq.conf```|Creates the DNSMASQ config file ```/var/dnsmasq.d/simple-adblock``` so that DNSMASQ replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file. This option will slow down DNS look up speed somewhat.|
|```dnsmasq.ipset```|Creates the DNSMASQ ipset file ```/var/dnsmasq.d/simple-adblock.ipset``` and the firewall rule to reject the matching requests. This is the only option for AdBlocking if you're using a browser with [DNS-over-HTTPS proxy](https://en.wikipedia.org/wiki/DNS_over_HTTPS) built-in, like [Mozilla Firefox](https://support.mozilla.org/en-US/kb/firefox-dns-over-https#w_about-dns-over-https) or [Google Chrome/Chromium](https://blog.chromium.org/2019/09/experimenting-with-same-provider-dns.html). This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file. This option requires you install ```dnsmasq-full``` and ```ipset``` [as described here](#how-to-use-dnsmasq-ipset).<br/>PLEASE NOTE, that unlike other options which are truly domain name based blocking, this is essentially an IP address based blocking, ie: if you try to block ```google-analytics.com``` with this option, it may also block/break things like YouTube, Hangouts and other Google services if they share IP address(es) with ```google-analytics.com```.|
|```dnsmasq.servers```|Creates the DNSMASQ servers file ```/var/run/simple-adblock.servers``` and modifies DNSMASQ settings so that DNSMASQ replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file. This option will slow down DNS look up speed somewhat. This is a default setting as it results in the smaller block-file and allows quick reloads of DNSMASQ. This setting also allows you to configure which DNSMASQ instances would be affected by AdBlocking via ```dns_instance``` option.|
|```unbound.adb_list```|Creates the Unbound config file ```/var/lib/unbound/adb_list.simple-adblock``` so that Unbound replies with NXDOMAIN: "domain not found". This option allows the block-list optimization (by removing secondary level domains if the top-level domain is also in the block-list), resulting in the smaller block-list file.|

## How Does It Work

This service downloads (and processes in the background, removing comments and other useless data) lists of hosts and domains to be blocked, combines those lists into one big block-list, removes duplicates and sorts it and then removes your allowed domains from the block-list before converting to to DNSMASQ/Unbound-compatible file and restarting DNSMASQ/Unbound if needed. The result of the process is that DNSMASQ/Unbound return NXDOMAIN or 127.0.0.1 (depending on settings) for the blocked domains.

If you specify ```google.com``` as a domain to be allowed, you will have access to ```google.com```, ```www.google.com```, ```analytics.google.com```, but not fake domains like ```email-google.com``` or ```drive.google.com.verify.signin.normandeassociation.com``` for example. If you only want to allow ```www.google.com``` while blocking all other ```google.com``` subdomains, just specify ```www.google.com``` as domain to be allowed.

In general, whatever domain is specified to be allowed; it, along with with its subdomains will be allowed, but not any fake domains containing it.

## How It Does Not Work

For most of the [DNS Resolution Options](#dns-resolution-option) to work, your local LAN clients need to be set to use your router's DNS (by default ```192.168.1.1```). The ```dnsmasq.addnhosts``` is the only option which can help you block ads if your local LAN clients are NOT using your router's DNS. There are multiple ways your local LAN clients can be set to NOT use your router's DNS:

  1. Hardcoded on the device. Some Android Lollipop 5.0 phones, some media-centric tablets and some streaming devices for example are known to have hardcoded DNS servers and they ignore your router's DNS settings. You can fix this by either:
      - Rooting your device and changing it from hardcoded DNS servers to obtaining DNS servers from DHCP.
      - Enabling ```simple-adblock```'s ```force_dns``` setting to override the hardcoded DNS on your device.
  2. Manually set on the device. Instead of setting your device to obtain the DNS settings via DHCP, you can set the DNS servers manually. There are some guides online which recommend manually changing the DNS servers on your computer to Google's (8.8.8.8) or Cloudflare's (1.1.1.1) or OpenDNS (208.67.222.222). You can fix this by either:
      - Changing the on-device DNS settings from manual to obtaining DNS servers from DHCP and changing your [router's DNS settings](https://openwrt.org/docs/guide-user/base-system/dhcp#all_options) to use the DNS from Google, Cloudflare or OpenDNS respectively.
      - Enabling ```simple-adblock```'s ```force_dns``` setting to override the hardcoded DNS on your device.
  3. Sent to your device from router via [DHCP Options](https://openwrt.org/docs/guide-user/base-system/dhcp_configuration#dhcp_options). You can fix this by either:
      - Removing [DHCP Options](https://openwrt.org/docs/guide-user/base-system/dhcp_configuration#dhcp_options) 5 and 6 from your router's ```/etc/config/dhcp``` file.
      - Enabling ```simple-adblock```'s ```force_dns``` setting to override the hardcoded DNS on your device.
  4. By using the DNS-over-TLS, DNS-over-HTTPS or DNSCrypt on your local device or (if supported) by browser on your local device. You can fix this only by:
      - Stopping/removing/disabling DNS-over-TLS, DNS-over-HTTPS or DNSCrypt on your local device and using the secure DNS on your router instead. There are merits to all three of the options above, I can recommend the ```https-dns-proxy``` and ```luci-app-https-dns-proxy``` packages for enabling DNS-over-HTTPS on your router.
  5. If you are running a wireguard "server" on your router and remote clients connect to it, the AdBlocking may not work properly for your remote clients until you add the following to ```/etc/network``` (credit to [dibdot](https://forum.openwrt.org/t/wireguard-and-adblock/49351/6)):

      ```sh
      config route
        option interface 'wg0'
        option target '192.168.1.0'
        option netmask '255.255.255.0'
      ```

## Documentation / Discussion

Please head to [OpenWrt Forum](https://forum.openwrt.org/t/simple-adblock-fast-lean-and-fully-uci-luci-configurable-adblocking/1327/) for discussion of this package.

## Thanks

I'd like to thank everyone who helped create, test and troubleshoot this service. Special thanks to [@hnyman](https://github.com/hnyman) for general package/luci guidance, [@dibdot](https://github.com/dibdot) for general guidance and block-list optimization code, [@ckuethe](https://github.com/ckuethe) for the curl support, non-ASCII filtering and compressed cache code, [@EricLuehrsen](https://github.com/EricLuehrsen) for the Unbound support information, [@mushoz]( https://github.com/mushoz) for performance testing and [@phasecat](https://forum.openwrt.org/u/phasecat/summary) for submitting various bugs and testing.
