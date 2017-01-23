# Simple AdBlock
A simple DNSMASQ-based adblocking service for OpenWrt/LEDE Project. Largely based on [bole5's](https://forum.openwrt.org/profile.php?id=45571) adblocking with performance improvements, added features and Web UI (as a separate package).

If you want a more robust AdBlocking with better documentation, check out [@dibdot's adblock](https://github.com/openwrt/packages/tree/master/net/adblock/files).

# Features
- Supports OpenWrt Designated Driver and LEDE Project
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ and firewall to redirect requests to a 1x1 transparent gif served with uhttpd
- Supports both hosts files and domains lists for blocking
- Supports remote whitelist URLs, just put whitelisted domains one per line
- Supports whitelisted domains in config file
- Uses (lightweight) ufetch-client on DD/LEDE instead of wget
- As some of the standard lists URLs are using https, requires either wget/libopenssl (AA, CC) or libustream-mbedtls (DD/LEDE)
- Has setup function which installs dependencies and configures everything (/etc/init.d/adblock setup)
- Has update function which downloads updated script version from github.com (/etc/init.d/adblock update)
- Very lightweight and easily hackable, the whole script is just one /etc/init.d/adblock file
- Logs single entry in the system log with the number of blocked domains if verbosity is set to 0
- (Optionally) shows ad blocking status in the banner
- From version 2.0 onward (yes, I'm very generous with version numbers) retains the downloaded/sorted adblocking list on service stop and reuses it on service start (use reload if you want to force re-download of the list)
- From version 3.0 onward also elegantly blocks ads served over https

# Documentation / Discussion
Please head to OpenWrt forum for discussion of this script: https://forum.openwrt.org/viewtopic.php?pid=307950

# How to install
On LEDE Project just install the [simple-adblock](https://github.com/stangri/openwrt-simple-adblock/raw/master/simple-adblock-latest.ipk) and [luci-app-simple-adblock](https://github.com/stangri/luci-app-simple-adblock/raw/master/luci-app-simple-adblock-latest.ipk) packages linked below.
On OpenWrt run the following command: 
```wget --no-check-certificate -qO - https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/files/simple-adblock.init | /bin/sh -s setup```.
Please note that in order to succeed, this requires either wget/libopenssl or ufetch-client/libustream-mbedtls already installed on your router.

# What's New
1.0.0:
- Initial release

# Notes
The script manipulates the /etc/banner file to reflect the status of the adblock _if_ the */etc/banner.orig* file exists. 