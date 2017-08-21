# OpenVPN Policy-Based Routing

## Description
This service allows you to define rules (policies) for routing traffic via WAN or your OpenVPN tunnel(s). Policies can be set based on any combination of local/remote ports, local/remote IPv4 or IPv6 addresses/subnets or domains. This service supersedes the [VPN Bypass](https://github.com/openwrt/packages/blob/master/net/vpnbypass/files/README.md) service, by supporting IPv6 and by allowing you to set explicit rules not just for WAN gateway (bypassing OpenVPN tunnel), but for multiple OpenVPN tunnels and Wireguard interfaces as well.

## Features

#### Gateways/Tunnels
- Any policy can target either WAN or an OpenVPN tunnel.
- Multiple OpenVPN interfaces/tunnels supported (with device names tun\* or tap\*).
- Multiple Wireguard interfaces supported (with protocol names wireguard\*).

#### IPv4/IPv6/Port-Based Policies
- Policies based on local names, IPs or subnets. You can specify a single IP (as in ```192.168.1.70```) or a local subnet (as in ```192.168.1.81/29```) or a local device name (as in ```nexusplayer```). IPv6 addresses are also supported.
- Policies based on local ports numbers. Can be set as an individual port number (```32400```), comma-separated list (```80,8080```) or a range (```5060-5061```). Limited to 15 ports per policy.
- Policies based on remote IPs/subnets or domain names. Same format/syntax as local IPs/subnets.
- Policies based on remote ports numbers. Same format/syntax and restrictions as local ports.
- You can mix and match IP addresses/subnets and device (or domain) names in one field separating them by space or semi-colon (like this: ```66.220.2.74 he.net tunnelbroker.net```).

#### DSCP-tag Based Policies
You can also set policies for traffic with specific DSCP tag. Instructions for tagging specific app traffic in Windows 10 can be found [here](http://serverfault.com/questions/769843/cannot-set-dscp-on-windows-10-pro-via-group-policy).

#### Strict enforcement
- Supports strict policy enforcement, even if the policy gateway is down -- resulting in network being unreachable for specific policy (enabled by default).

#### Use DNSMASQ
- Service can be set to utilize ```dnsmasq```'s ```ipset``` support. This requires the ```dnsmasq-full``` to be installed (see [How to install dnsmasq-full](#how-to-install-dnsmasq-full)) and it significantly improves the start up time because dnsmasq resolves the domain names and adds them to ipsets in the background. Another benefit if using ```dnsmasq```'s ```ipset``` is that it also automatically adds third-level domains to the ipset; if ```domain.com``` is added to the policy, this policy will affect all ```*.domain.com``` subdomains.

#### Customization
- Can be fully configured with uci commands or by editing ```/etc/config/openvpn-policy-routing``` file.
- Has a companion package (luci-app-openvpn-policy-routing) so everything can be configured with Web UI.

#### Other Features
- Doesn't stay in memory, creates the ip tables and iptables rules which are automatically updated when supported/monitored interface changes.
- Proudly made in Canada, using locally-sourced electrons.

## Screenshot (luci-app-openvpn-policy-routing)
![screenshot](https://raw.githubusercontent.com/stangri/screenshots/master/openvpn-policy-routing/screenshot01.png "screenshot")

## Requirements
This service requires the following packages to be installed on your router: ```ipset```, ```resolveip```, ```kmod-ipt-ipset``` and ```iptables```.

To satisfy the requirements, connect to your router via ssh and run the following commands:
```sh
opkg update; opkg install ipset resolveip kmod-ipt-ipset iptables
```

#### How to install dnsmasq-full
If you want to use ```dnsmasq```'s ```ipset``` support, you will need to install ```dnsmasq-full``` instead of the ```dnsmasq```. To do that, connect to your router via ssh and run the following command:
```sh
opkg update; opkg remove dnsmasq; opkg install dnsmasq-full
```


#### Unmet dependencies
If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How to install
Please make sure that the [requirements](#requirements) are satisfied and install ```openvpn-policy-routing``` and ```luci-app-openvpn-policy-routing``` from Web UI or connect to your router via ssh and run the following commands:
```sh
opkg update
opkg install openvpn-policy-routing luci-app-openvpn-policy-routing
```
If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt CC 15.05.1
```sh
opkg update; opkg install wget libopenssl
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

###### LEDE Project and OpenWrt DD trunk
```sh
opkg update; opkg install uclient-fetch libustream-mbedtls
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

## Default Settings
Default configuration has service disabled (use Web UI to enable/start service or run ```uci set openvpn-policy-routing.config.enabled=1```) and has some example policies which can be safely deleted.

## Discussion
Please head to [LEDE Project Forum](https://forum.lede-project.org/t/openvpn-policy-based-routing-web-ui/1422) for discussions of this service.

## What's New
5.0.1
- This version is config-incompatible with earlier versions! Please use ```--force-maintainer``` when installing this version.
- Uses interface names rather than device names in policies.
- No longer depends on ```dmnsmasq-full```.
- Allows to mix and match IP addresses and device/domain names in local addresses or remote addresses fields of the policy.
- Allows to specify more than one item in each policy field (separated by spaces or semi-colon).

4.1.4
- No longer depends on specific WAN interface name (```wan```) can be used with custom WAN interface names (like ```wwan```).
- Include WAN interface information in ```support``` command.
- Starting table number, FW_MARK and FW_MASK can be defined in the config.
- Return to config-file based service enable/disable.

4.1.3
- More reliable creation/destruction of iptables OVPBR_MARK chain.

4.1.2
- Better output logic/format.

4.1.1
- New extra command: ```support```. Run ```/etc/init.d/openvpn-policy-routing``` for details.

4.1.0
- More elegant handling of iptables (thanks [@hnyman](https://github.com/hnyman) and [@tohojo](https://github.com/tohojo)!).

4.0.0
- Return to dnsmasq-full for domain-based policy routing (enabled by updated luci-app-openvpn-policy-routing directly editing dnsmasq config).
- README overhaul in preparation for official OpenWrt feed PR.

3.3.5
- Attempt to implement internal (dnsmasq-full independent) domain-based policy routing.
- More reliable way of obtaining WAN gateway on boot (thanks [@dibdot](https://github.com/dibdot) for the hint!).
- Changed format of config file for domains-based routing.
- Fixed bugs:
  - Duplicate ipset entries after using luci-app-openvpn-policy-routing.
  - Domains-based routing only targeting last dnsmasq config.
- Added support for routed domains in format ```/domain1.com/domain2.com/gwroute``` where ```gwroute``` could be ```wanroute```, ```tun0route```, etc.
- Support for automatic reload of openvpn-policy-routing service on OpenVPN tunnels changes.
- Support for strict policy enforcement, even if the policy gateway is down -- resulting in network being unreachable for specific policy (enabled by default).
- Support for multiple OpenVPN tunnels.

2.0.0:
- Proper support for local/remote IP addresses/ranges and ports.

1.0.0:
- Initial release.

## Notes/Known Issues
- In order to select specific OpenVPN tunnel in Web UI, the appropriate tunnel must be running. You can assign an inactive tunnel to any policy with the uci command or by manually editing ```/etc/config/openvpn-policy-routing``` file.

- Service does not alter the default routing. Depending on your OpenVPN settings (and settings of the OpenVPN server you are connecting to), the default routing might be set to go via WAN or via OpenVPN tunnel. This service affects only routing of the traffic matching the policies. If you want to override default routing, consider adding the following to your OpenVPN tunnel(s) configs:
```
option route_nopull '1'
```
<!-- option route '0.0.0.0 0.0.0.0'  -->

## Thanks
I'd like to thank everyone who helped create, test and troubleshoot this service. Without contributions from [@hnyman](https://github.com/hnyman), [@dibdot](https://github.com/dibdot), [@danrl](https://github.com/danrl), [@tohojo](https://github.com/tohojo), [@cybrnook](https://github.com/cybrnook), [@nidstigator](https://github.com/nidstigator), [@AndreBL](https://github.com/AndreBL) and rigorous testing by [@dziny](https://github.com/dziny), [@bluenote73](https://github.com/bluenote73) and [@buckaroo](https://github.com/pgera) it wouldn't have been possible.
