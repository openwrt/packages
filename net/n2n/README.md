# openwrt-n2n
Fork of MuJJus' openwrt-n2n package that doesn't break compatibility with standard N2N networks

## Build
Example for ar71xx and trunk.
```
wget http://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/OpenWrt-SDK-ar71xx-generic_gcc-4.8-linaro_musl-1.1.11.Linux-x86_64.tar.bz2
tar jxf OpenWrt-SDK-ar71xx-generic_gcc-4.8-linaro_musl-1.1.11.Linux-x86_64.tar.bz2
cd OpenWrt-SDK-ar71xx-generic_gcc-4.8-linaro_musl-1.1.11.Linux-x86_64/package
git clone https://github.com/MuJJus/openwrt-n2n n2n
cd ..
make menuconfig # (selected Network -> VPN -> n2n-edge and n2n-supernode)
make package/n2n/compile V=s
```


## Usage
The `n2n` protocol options:

Name          | Type    | Required | Default | Description
--------------|---------|----------|---------|------------------------------------------------
server        | string  | yes      | (none)  | Supernode server
port          | int     | yes      | (none)  | Supernode port
server2       | string  | no       | (none)  | Supernode server of slave
port2         | int     | no       | (none)  | Supernode port of slave
community     | string  | yes      | (none)  | N2N community
key           | string  | no       | (none)  | The key of the community
mode          | string  | yes      | (none)  | For dhcp or static
ipaddr        | string  | no       | (none)  | IPv4 Address of the interface
netmask       | string  | no       | (none)  | Netmask of the interface
gateway       | string  | no       | (none)  | Gateway of the interface
ip6addr       | string  | no       | (none)  | IPv6 Address of the interface
ip6prefixlen  | int     | no       | (none)  | IPv6 Prefix Length of the interface
ip6gw         | string  | no       | (none)  | IPv6 Gateway of the interface
macaddr       | string  | no       | random  | MAC Address
mtu           | int     | no       | 1440    | Maximum Transmit Unit
forwarding    | boolean | no       | false   | Enable packet forwarding through n2n community
dynamic       | boolean | no       | false   | Periodically resolve supernode IP
localport     | int     | no       | random  | Fixed local UDP port
mgmtport      | int     | no       | (none)  | Management UDP Port (for multiple edges on a machine)
multicast     | boolean | no       | false   | Accept multicast MAC addresses
verbose       | boolean | no       | false   | Make more verbose

For supernode
```
# vi /etc/config/n2n
config supernode
        option enable '1'
        option port '80'

# /etc/init.d/n2n start
```

## LuCI
* edge [luci-proto-n2n](https://github.com/MuJJus/luci-proto-n2n)
* supernode [luci-app-n2n](https://github.com/MuJJus/luci-app-n2n)
