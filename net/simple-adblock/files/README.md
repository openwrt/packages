# Simple AdBlock
A simple DNSMASQ-based AdBlocking service for OpenWrt/LEDE Project. Loosely based on [bole5's](https://forum.openwrt.org/profile.php?id=45571) idea with major performance improvements, added features and Web UI (as a separate package); inspired by @dibdot's innovation.

## Features
- Supports OpenWrt Designated Driver and LEDE Project.
- Super-fast due to the nature of supported block lists and backgrounding of already downloaded data while next list is downloading.
- Supports both hosts files and domains lists for blocking (to keep it lean and fast).
- Everything is configurable from Web UI.
- Allows you to easily add your own domains to whitelist or blacklist.
- Allows you to easily add URLs to your own blocked hosts or domains lists to block/whitelist (just put whitelisted domains one per line).
- Requires no configuration for the download utility wherever you want to use wget/libopenssl or uclient-fetch/libustream-mbedtls.
- Installs dependencies automatically (DD/LEDE-default uclient-fetch libustream-mbedtls).
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ and firewall rules to serve "domain not found reply".
- As some of the default lists are using https, reliably works with either wget/libopenssl or uclient-fetch/libustream-mbedtls.
- Very lightweight and easily hackable, the whole script is just one /etc/init.d/simple-adblock file.
- Logs single entry in the system log with the number of blocked domains if verbosity is set to 0.
- Retains the downloaded/sorted adblocking list on service stop and reuses it on service start (use reload if you want to force re-download of the list).
- Blocks ads served over https.
- Proudly made in Canada, using locally-sourced electrons.

If you want a more robust AdBlocking, supporting free memory detection and complex block lists, check out [@dibdot's adblock](https://github.com/openwrt/packages/tree/master/net/adblock/files).


## Screenshot (luci-app-simple-adblock)
![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/simple-adblock/screenshot06.png "screenshot")


## Requirements
This service requires the following packages to be installed on your router: ```dnsmasq``` or ```dnsmasq-full``` and either ```ca-certificates```, ```wget``` and ```libopenssl``` (for OpenWrt 15.05.1) or ```uclient-fetch``` and ```libustream-mbedtls``` (for OpenWrt DD trunk and all LEDE Project builds). Additionally installation of ```coreutils-sort``` is highly recommended as it speeds up blocklist processing.

To satisfy the requirements for connect to your router via ssh and run the following commands:
###### OpenWrt 15.05.1
```sh
opkg update; opkg install ca-certificates wget libopenssl coreutils-sort dnsmasq
```

###### LEDE Project 17.01.x and OpenWrt 18.xx or later
```sh
opkg update; opkg install uclient-fetch libustream-mbedtls coreutils-sort dnsmasq
```

###### IPv6 Support
For IPv6 support additionally install ```ip6tables-mod-nat``` and ```kmod-ipt-nat6``` packages from Web UI or run the following in the command line:
```sh
opkg update; opkg install ip6tables-mod-nat kmod-ipt-nat6
```

###### Speed up blocklist processing with coreutils-sort
The ```coreutils-sort``` is an optional, but recommended package as it speeds up sorting and removing duplicates from the merged list dramatically. If opkg complains that it can't install ```coreutils-sort``` because /usr/bin/sort is already provided by busybox, you can run ```opkg --force-overwrite install coreutils-sort```.


#### Unmet dependencies
If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.


## How to install
Install ```simple-adblock``` and ```luci-app-simple-adblock``` packages from Web UI or run the following in the command line:
```sh
opkg update; opkg install simple-adblock luci-app-simple-adblock
```

If ```simple-adblock``` and ```luci-app-simple-adblock``` packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.


#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt 15.05.1
```sh
opkg update; opkg install ca-certificates wget libopenssl
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

###### LEDE Project and OpenWrt 18.xx or later
```sh
opkg update
opkg list-installed | grep -q uclient-fetch || opkg install uclient-fetch
opkg list-installed | grep -q libustream || opkg install libustream-mbedtls
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```


#### Default Settings
Default configuration has service disabled (use Web UI to enable/start service or run ```uci set simple-adblock.config.enabled=1```) and selected ad/malware lists suitable for routers with 64Mb RAM. The configuration file has lists in descending order starting with biggest ones, comment out or delete the lists you don't want or your router can't handle.


## How to customize
You can use Web UI (found in Services/Simple AdBlock) to add/remove/edit links to:
- hosts files (127.0.0.1 or 0.0.0.0 followed by space and domain name per line) to be blocked.
- domains lists (one domain name per line) to be blocked.
- domains lists (one domain name per line) to be whitelisted. It is useful if you want to run simple-adblock on multiple routers and maintain one centralized whitelist which you can publish on a web-server.

Please note that these lists **have** to include either ```http://``` or ```https://``` prefix. Some of the top block lists (both hosts files and domains lists) suitable for routers with at least 8MB RAM are used in the default simple-adblock installation.

You can also use Web UI to add individual domains to be blocked or whitelisted.

If you want to use CLI to customize simple-adblock config, you can probably figure out how to do it by looking at the contents of ```/etc/config/simple-adblock``` or output of the ```uci show simple-adblock``` command.

## How does it work
This service downloads (and processes in the background, removing comments and other useless data) lists of hosts and domains to be blocked, combines those lists into one big block list, removes duplicates and sorts it and then removes your whitelisted domains from the block list before converting to to dnsmasq-compatible file and restarting dnsmasq. The result of the process is that dnsmasq returns "domain not found" for the blocked domains.

If you specify ```google.com``` as a domain to be whitelisted, you will have access to ```google.com```, ```www.google.com```, ```analytics.google.com```, but not fake domains like ```email-google.com``` or ```drive.google.com.verify.signin.normandeassociation.com``` for example. If you only want to allow ```www.google.com``` while blocking all other ```google.com``` subdomains, just specify ```www.google.com``` as domain to be whitelisted.

In general, whatever domain is specified to be whitelisted; it, along with with its subdomains will be whitelisted, but not any fake domains containing it.

## Documentation / Discussion
Please head [LEDE Project Forum](https://forum.lede-project.org/t/simple-adblock-fast-lean-and-fully-uci-luci-configurable-adblocking/1327/) for discussion of this package.

## What's New
1.5.8:
- Better start/stop/reload logic.
- Better uninstall logic.
- Better start/stop/reload from Web UI.
- New command-line ```check``` command.

1.5.7:
- Much stricter filters for hosts and domains lists resulting in better garbage removal.
- Better handling of service start/enable from Web UI and enabled flag management.
- Implemented support to set one of the router LEDs on/off based on the AdBlocking status.
- Fixed the output bug when verbosity=1.
- No longer using enabled in config file, Simple AdBlocking Web UI now enables/disables service directly.
- Reworked console/system log output logic and formatting.
- Processes already downloaded lists in the background while downloading next list from config, dramatically increasing overall speed.

1.0.0:
- Initial release
