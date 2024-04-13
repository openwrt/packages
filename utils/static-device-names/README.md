# static-device-names package for OpenWRT

Inspired in part by @bobafetthotmail's script published here:
https://forum.openwrt.org/t/how-does-openwrt-ensure-network-device-names-are-consistent/90185/3

The purpose of this package is to make sure that network device names are
always assigned to the correct devices on systems, like x86, where moving a NIC
to a different motherboard slot may device names to be assigned in a different
order during boot.

The static-device-names service matches network devices by a number of
criteria, like their MAC address or PCI ID.

When it encounters a network device (e.g., "eth0") that matchs a criterion (a
MAC address) it will rename the network device to match the target name
(`eth20`).

If a different interface already occupies the same name it will be moved out of
the way by being renamed in turn.

The result is stable and predictable network device naming at every boot.

Hotplugging is also supported: Inserted USB NICs will be assigned the correct
device name.


## Configuration

### Configuration file

    /etc/config/static-device-names

If configuration is missing, create a new one:

```sh
touch /etc/config/static-device-names
uci set static-device-names.globals=globals
uci commit static-device-names
```


### Configuring a static device name

Each `device` section of the configuration should have a name to make them
easier to configure. The section name can be anything, like "WAN", or a network
device name like "eth0".

Add a new `device` section called "WAN" to hold options for the network device
named "eth0":

   uci set static-device-names.WAN=device
   uci set static-device-names.WAN.name=eth0

Here's how to assign a specific MAC address to the "WAN" device section:

   uci set static-device-names.WAN.mac=08:00:27:7a:4e:87

Here's how to assign a PCI ID to the "WAN" device section:

   uci set static-device-names.WAN.pci_id=10ec:8125

Don't forget to commit the configuration changes:

   uci commit static-commit-names

Both `mac` and `pci_id` options can be lists. This can be useful if
configurations are staged or tested on a virtual machine or meant to be used on
multiple devices:

   uci add_list static-device-names.WAN.mac=08:00:27:7a:4e:87
   uci add_list static-device-names.WAN.mac=08:00:28:8a:5e:88
   uci commit static-commit-names

## Service

Service init script:

    /etc/init.d/static-device-names

To enable the service so it runs automatically on boot:

```sh
service static-device-names enable
```

To disable the service:

```sh
service static-device-names disable
```

To rename device names, start/restart/reload the service:

```sh
service static-device-names reload
```

To see the current status of network devices:

```sh
service static-device-names status
```

## Hotplug

> [!TIP]
> The hotplug script is enabled by default even if the service is not.

Hotplug script:

	/etc/hotplug.d/net/00-00-static-device-names

To enable hotplug support:

```sh
uci set static-device-names.globals.hotplug=1
uci commit static-device-names
```

To disable hotplug support:

```sh
uci set static-device-names.globals.hotplug=0
uci commit static-device-names
```

