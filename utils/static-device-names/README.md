# static-device-names package for OpenWRT

Copyright (C) 2024 qualIP Software.
Released under the GPL v3.0 or later.

Inspired in part by @bobafetthotmail's script published here:
https://forum.openwrt.org/t/how-does-openwrt-ensure-network-device-names-are-consistent/90185/3

The purpose of this package is to make sure that network device names are
always assigned to the correct devices on systems, like x86, where moving a NIC
to a different motherboard slot may device names to be assigned in a different
order during boot.

The static-device-names service matches network devices by a number of
criteria, like their MAC address, PCI ID, or PCI/USB slot.

When it encounters a network device (e.g., "eth0") that matches a criterion
(e.g., a MAC address) it will rename the network device to match the target
name (`eth20`).

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
easier to configure. The section name can be anything, like "wan", or a network
device name like "eth0".

Add a new `device` section called "wan" to hold options for the network device
named "eth0":

    uci set static-device-names.wan=device
    uci set static-device-names.wan.name=eth0

Here's how to assign a specific **MAC address** to the "wan" device section:

    uci set static-device-names.wan.mac=08:00:27:7a:4e:87

Matching based on MAC address is the preferred method since all Ethernet
devices have a unique "burnt-in" MAC address (with the exception of virtual
devices for which the MAC address is auto-generated or configurable).

For advanced setups, you may want to match based on other criteria below.

Here's how to assign **PCI ID** for a PCI or USB device:

    uci set static-device-names.wan.pci_id=10ec:8125

PCI IDs are in the industry-standard hexadecimal "\<vendor\>:\<device\>" form.

Or, a **PCI slot**:

    uci set static-device-names.wan.pci_slot=07:00.0

PCI slots are assigned by the Linux kernel and are generally in the
"\<bus\>:\<device\>.\<func\>" form.

Or, a **USB slot**:

    uci set static-device-names.wan.usb_slot=9-1:1.0

USB slots are assigned by the Linux kernel and are generally in the
"\<bus\>-\<port\>:\<port\>.\<if\>" form.

Don't forget to commit the configuration changes:

    uci commit static-device-names

Any of `mac`, `pci_id`, `pci_slot`, and `usb_slot` options can be lists.
This can be useful if configurations are staged or tested on a virtual machine
or meant to be used on multiple devices:

    uci add_list static-device-names.wan.mac=08:00:27:7a:4e:87
    uci add_list static-device-names.wan.mac=08:00:28:8a:5e:88
    uci commit static-device-names

> [!TIP]
> To determine the criteria that match your inserted devices, run the service's
> status command:
>
> ```
> /etc/init.d/static-device-names status
> INFO:  eth0 (mac=00:1b:21:xx:yy:zz pci_id=8086:a01f pci_slot=07:00.0)
> INFO:  eth1 (mac=48:22:54:xx:yy:zz pci_id=10ec:8125 pci_slot=05:00.0)
> INFO:  eth2 (mac=bc:ae:c5:xx:yy:zz pci_id=1043:820d pci_slot=09:01.0)
> INFO:  wlan0 (mac=00:1d:0f:xx:yy:zz pci_id=0cf3:9170 usb_slot=9-1:1.0)
> ```

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

To see the current status of network devices without making any changes:

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

## Debugging

If you run into any issues, run the service's `debug` command to dump the
configuration, device details and other useful information:

```sh
service static-device-names debug
```

Please provide the full output of this command when opening issues/tickets.
