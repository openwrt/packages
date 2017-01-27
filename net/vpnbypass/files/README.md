# OpenWrt Simple VPNBypass
A simple PROCD-based vpnbypass init script for OpenWrt/LEDE Project. Useful if your router accesses internet thru VPN client/tunnel, but you want specific traffic (ports, IP ranges, domains or local IP ranges) to be routed outside of this tunnel.

# Features
- Routes Plex Media Server traffic outside of the VPN tunnel.
- Allows you to define IPs/ranges in local network so that their traffic is routed outside of the VPN tunnel.
- Allows you to define list of domain names which are accessed outside of the VPN tunnel (useful for Netflix, Hulu, etc).
- Doesn't stay in memory -- creates the iptables rules which are automatically updated on WAN up/down.

# Requirements
This service requires following packages to be installed on your router: ip-full ipset iptables dnsmasq-full (dnsmasq-full requires you uninstall dnsmasq first). Run the following commands to satisfy the requirements:
```sh
opkg update
opkg remove dnsmasq ip; opkg install ip-full ipset iptables dnsmasq-full
```

# How to install
```sh
opkg update
opkg install vpnbypass luci-app-vpnbypass
```
Default install routes Plex Media Server traffic (port 32400) outside of the VPN tunnel, routes LogmeIn Hamachi traffic (25.0.0.0/8) outside of the VPN tunnel and also routes internet traffic from local IPs 192.168.1.80-192.168.1.88 outside of the VPN tunnel.

# Documentation / Discussion
Please head to OpenWrt/LEDE Project Forums for discussion of this script.

# What's New
1.0.0:
- Hotplug script created during install.

0.1.0:
- Package built.
- Support for user-defined ports implemented.
- Support for user-defined routes implemented.
- Support for user-defined local ranges implemented.

0.0.1:
- Initial release.

# Known Issues
Until user-defined domains are supported within vpnbypass config, you can set domains to be accessed outside of VPN tunnel like so:
```sh
uci add_list dhcp.@dnsmasq[-1].ipset='/github.com/plex.tv/google.com/vpnbypass'
uci add_list dhcp.@dnsmasq[-1].ipset='/hulu.com/netflix.com/nhl.com/vpnbypass'
uci commit dhcp
/etc/init.d/dnsmasq restart
```