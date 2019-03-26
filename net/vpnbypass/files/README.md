# VPN Bypass
A simple PROCD-based ```vpnbypass``` service for OpenWrt/LEDE Project. Useful if your router accesses internet thru VPN client/tunnel, but you want specific traffic (ports, IP ranges, domains or local IP ranges) to be routed outside of this tunnel.

## Features
- Allows to define local ports so that traffic to them is routed outside of the VPN tunnel (by default routes Plex Media Server traffic (port 32400) outside of the VPN tunnel).
- Allows to define IPs/subnets in local network so that their traffic is routed outside of the VPN tunnel (by default routes traffic from 192.168.1.81-192.168.1.87 outside of the VPN tunnel).
- Allows to define remote IPs/ranges that they are accessed outside of the VPN tunnel (by default routes LogmeIn Hamachi traffic (25.0.0.0/8) outside of the VPN tunnel).
- Allows to define list of domain names which are accessed outside of the VPN tunnel (useful for Netflix, Hulu, etc).
- Doesn't stay in memory -- creates the iptables rules which are automatically updated on WAN up/down.
- Has a companion package (luci-app-vpnbypass) so everything can be configured with Web UI.
- Proudly made in Canada, using locally-sourced electrons.

## Screenshot (luci-app-vpnbypass)
![screenshot](https://raw.githubusercontent.com/stangri/screenshots/master/vpnbypass/screenshot02.png "screenshot")

## Requirements
This service requires following packages to be installed on your router: ```ipset``` and ```iptables```. Additionally, if you want to use Domain Bypass feature, you need to install ```dnsmasq-full``` (```dnsmasq-full``` requires you uninstall ```dnsmasq``` first).

To fully satisfy the requirements for both IP/Port VPN Bypass and Domain Bypass features connect to your router via ssh and run the following commands:
```sh
opkg update; opkg remove dnsmasq; opkg install ipset iptables dnsmasq-full
```

To satisfy the requirements for just IP/Port VPN Bypass connect to your router via ssh and run the following commands:
```sh
opkg update; opkg install ipset iptables
```

#### Unmet dependencies
If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How to install
<!---
#### From Web UI/Luci
Navigate to System->Software page on your router and then perform the following actions:
1. Click "Update Lists"
2. Wait for the update process to finish.
3. In the "Download and install package:" field type ```vpnbypass luci-app-vpnbypass```
4. Click "OK" to install ```vpnbypass``` and ```luci-app-vpnbypass```

If you get an ```Unknown package 'vpnbypass'``` error, your router is not set up with the access to repository containing these packages and you need to add custom repository to your router first.

#### From console/ssh
--->
Please make sure that the [requirements](#requirements) are satisfied and install ```vpnbypass``` and ```luci-app-vpnbypass``` from Web UI or connect to your router via ssh and run the following commands:
```sh
opkg update
opkg install vpnbypass luci-app-vpnbypass
```
If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt 15.05.1
```sh
opkg update; opkg install ca-certificates wget libopenssl
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

###### LEDE Project 17.01.x and OpenWrt 18.xx or later
```sh
opkg update; opkg install uclient-fetch libustream-mbedtls
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

## Default Settings
Default configuration has service disabled (use Web UI to enable/start service or run ```uci set vpnbypass.config.enabled=1```) and routes Plex Media Server traffic (port 32400) outside of the VPN tunnel, routes LogmeIn Hamachi traffic (25.0.0.0/8) outside of the VPN tunnel and also routes internet traffic from local IPs 192.168.1.81-192.168.1.87 outside of the VPN tunnel. You can safely delete these example rules if they do not apply to you.

## Documentation / Discussion
Please head to [LEDE Project Forum](https://forum.lede-project.org/t/vpn-bypass-split-tunneling-service-luci-ui/1106) for discussions of this service.

#### Bypass Domains Format/Syntax
Domain lists should be in following format/syntax: ```/domain1.com/domain2.com/vpnbypass```. Please don't forget the leading ```/``` and trailing ```/vpnbypass```. There's no validation if you enter something incorrectly -- it just won't work. Please see [Notes/Known Issues](#notesknown-issues) if you want to edit this setting manually, without Web UI.

## What's New
1.3.0
- No longer depends on hardcoded WAN interface name (```wan```) works with other interface names (like ```wwan```).
- Table ID, IPSET name and FW_MARK as well as FW_MASK can be defined in config file.
- Uses iptables, not ip rules for handling local IPs/ranges.
- More reliable creation/destruction of VPNBYPASS iptables chain.
- Updated Web UI enables/start and stops service.
- Beautified output.

1.2.0
- More elegant handling of iptables (thanks [@hnyman](https://github.com/hnyman) and [@tohojo](https://github.com/tohojo)!).

1.1.1
- More reliable way of obtaining WAN gateway on boot (thanks [@dibdot](https://github.com/dibdot) for the hint!).

1.1.0:
- Detects individual IP addresses in the config and converts them to subnet automatically.
- Proper implementation of reload on vpnbypass config change.

1.0.0:
- Hotplug script created during install.

0.1.0:
- Package built.
- Support for user-defined ports implemented.
- Support for user-defined routes implemented.
- Support for user-defined local ranges implemented.

0.0.1:
- Initial release.

## Notes/Known Issues
1. Domains to be accessed outside of VPN tunnel are handled by dnsmasq and thus are not defined in ```/etc/config/vpnpass```, but rather in ```/etc/config/dhcp```. To add/delete/edit domains you can use VPN Bypass Web UI or you can edit ```/etc/config/dhcp``` manually or run following commands:
```sh
uci add_list dhcp.@dnsmasq[-1].ipset='/github.com/plex.tv/google.com/vpnbypass'
uci add_list dhcp.@dnsmasq[-1].ipset='/hulu.com/netflix.com/nhl.com/vpnbypass'
uci commit dhcp
/etc/init.d/dnsmasq restart
```
This feature requires ```dnsmasq-full``` to work. See [Requirements](#requirements) paragraph for more details.
