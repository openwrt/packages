# [Jool](https://nicmx.github.io/Jool/en/index.html)

## Documentation

[See here](https://nicmx.github.io/Jool/en/documentation.html).

You might also want to see [contact info](https://nicmx.github.io/Jool/en/contact.html).

## Usage

### Start script

This package includes a start script that will:

  1. Read the configuration file `/etc/config/jool`
  2. Determine what services are active
  3. Run `jool` with procd

### For now this means that
  
- The services will be disabled by default in the uci config `(/etc/config/jool)`
- The only uci configuration support available for the package is to enable or disable each instance or the entire deamon
- There is no uci support and configuration will be saved at `/etc/jool/`
- Only one instance of jool(nat64) can run with the boot script
- Only one instance of jool(siit) can run with the boot script
- For now there is no way of overriding of the configuration file's paths

The configuration files the startup script uses for each jool instance are:

- jool(nat64): `/etc/jool/jool-nat64.conf.json`
- jool(siit): `/etc/jool/jool-siit.conf.json`

### netifd proto (clat)

The optional `jool-clat-proto` package ships a `jool_clat` proto helper for
CLAT setups using Jool SIIT inside a dedicated network namespace, with one end
of a veth pair exposed on the host. This allows translation of traffic sourced
from the router itself and more flexible routing, which are infeasible when
running Jool SIIT directly because it hooks PREROUTING and processes traffic
indiscriminately.

Example `/etc/config/network` section:

```uci
config interface 'clat0'
	option proto 'jool_clat'
	option plat_prefix '64:ff9b::/96'
	option clat_v6 '2001:db8:100::2'
	option defaultroute '1' # default
	option metric '1470'
```

Map explicit subnets and avoid extra masquerade:

```uci
config interface 'clat1'
	option proto 'jool_clat'
	option plat_prefix '64:ff9b::/96'
	option veth_host_v4 '192.0.2.0/31'
	option veth_ns_v4 '192.0.2.0/31'
	list clat_v6 '2001:db8:100::/120'
	list clat_v4 '192.168.1.0/24'
	list clat_v6 '2001:db8:101::0/128'
	list clat_v4 '192.0.2.0'
	option defaultroute '0'
```

Supported proto options:

- `plat_prefix`: required PLAT (Jool pool6) prefix.
- `clat_v4` and `clat_v6`: arrays of IPv6/IPv4 address/prefix(es) mapped one-to-one in order, to be added as Jool's EAMT entries.
  - `clat_v6`: required IPv6 address/prefix(es) used by the CLAT and mapped from `clat_v4`.
  - `clat_v4`: optional IPv4 address/prefix(es) mapped to `clat_v6`. If omitted, it defaults to `veth_host_v4`; in that case, the CLAT interface only accepts traffic sourced from its own IPv4 address unless additional MASQUERADE is applied.
- `veth_host_v4`, `veth_ns_v4`: optional addresses for the host and namespace ends of the CLAT veth pair. If omitted, they default to `192.0.2.0/31` and `192.0.2.1/31`.
- `veth_host_ifname`, `veth_ns_ifname`, `netns`: optional names for the host veth, namespace veth, and network namespace.
- `defaultroute`: optional boolean, defaults to `1`. When enabled, the host side installs an IPv4 default route via the CLAT veth interface.
- `metric`: optional metric for the default IPv4 route installed on the host side.

Notes:

- Ensure the network namespace kernel feature is enabled. This appears to be the default on official builds.
- Enable IPv6 forwarding on the host (`net.ipv6.conf.all.forwarding=1`). This also appears to be the default on official builds.
- Apply MASQUERADE on the CLAT interface if you want to translate traffic sourced from LAN hosts or other local IPv4 addresses.
- To avoid extra MASQUERADE, specify `clat_v4` manually with all the IPv4 subnet(s) you want to map (usually the interface IP and LAN subnets) and provide the corresponding `clat_v6` entries yourself.
- With `mwan3` enabled or more complex policy routing rules, using MASQUERADE may be simpler. In that case, you may also want to add a custom policy rule, for example `uci add network rule && uci set network.@rule[-1].out='clat0' && uci set network.@rule[-1].lookup='main' && uci commit network && service network reload`, to make `ping -I` (`SO_BINDDEVICE`) testing easier.

### OpenWrt tutorial

For a more detailed tutorial refer to this [wiki page](https://openwrt.org/docs/guide-user/network/ipv6/nat64).
