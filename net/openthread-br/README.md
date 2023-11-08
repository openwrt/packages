# OpenThread Border Router

This package contains the OpenThread Border Router.

## Requirements

To use this package, you need a Thread Radio Co-Processor (RCP). Testing of
this package was done with Nordic Semiconductor nRF52840 USB dongles.

Building and flashing the dongle with the Thread RCP firmware is out of scope
of this document.

One caveat for this dongle is worth mentioning here. The nRF52840 USB dongle
seems to come with the U2F bootloader. To get it in mass storage mode to copy a
firmware file, you need to plug it in while pressing the reset button. However,
after the initial flash with the ot-rcp firmware, this method stops working.
Instead, you need to double press the reset button after plugging in the dongle.

## Packaging decisions

### Configurable package build

OpenThread is complex software. Adding config options to change the build of
the package will likely result in more bug reports. As the package and its
dependencies are unlikely to fit in any router with small flash (16MB or less),
I don't see much point in making things configurable for reducing size either.

### Firewall support

OpenWrt uses firewall4 with nftables by default, but the OpenThread firewall
implementation uses IPTables and IPset. While we still support firewall3 with
IPTables, it's not a good idea to add new dependencies to old things.
Therefore, firewall support is disabled completely.

This can be revised once the following feature request is implemented:
https://github.com/openthread/ot-br-posix/issues/1675

### mDNSResponder

The package depends on mDNSResponder. The alternative, Avahi, depends on D-Bus,
which is not something I feel comfortable with running on any router. While
there are Avahi packages without D-Bus support, using OpenThread Border Router
with Avahi requires libavahi-client, and this requires Avahi to be built with
D-Bus support.

### REST Server

The REST server is enabled to make this package compatible with Home Assistant.

### TREL support

Thread Radio Encapsulation Link support is enabled, as it allows Border Routers
to communicate over other links (e.g. Ethernet), reducing traffic over the
802.15.4 radios.

The following Github discussion contains a good explanation of TREL:
https://github.com/openthread/openthread/discussions/8478

### UCI/netifd support

The package contains a minimal netifd protocol handler. This allows configuring
the Thread network in /etc/config/network. The agent will be started by netifd,
rather than using an init script.

OpenThread does not store prefix information in non-volatile storage. As a
result, every time the agent is restarted, a different prefix would be used.
This is not very nice, and makes it very difficult to run the OpenThread Border
Router on a device that is not your main router. Therefore, prefixes can be
configured in /etc/config/network. This way, you can add a static route to the
Thread prefix(es) in your main router, making it possible to access devices on
the Thread network from your entire network.

## Create network

When starting the OpenThread Border Router for the first time, a Thread network
must be created.

As the agent is started by netifd, we first need to create an interface in
/etc/config/network:

```
config interface 'thread'
        option device 'wpan0'
        option proto 'openthread'
        option backbone_network 'lan'
        option radio_url 'spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=460800'
        list prefix 'fd6f:5772:5468:7200::/64 paros'
        option verbose '0'
```

Prefix and verbose are optional. Everything else is required. The protocol
handler will fail if a required setting is missing. If something isn't working,
check ifstatus for the OpenThread interface:

```
# ifup thread
# ifstatus thread
{
        "up": false,
        "pending": false,
        "available": true,
        "autostart": false,
        "dynamic": false,
        "proto": "openthread",
        "data": {

        },
        "errors": [
                {
                        "subsystem": "openthread",
                        "code": "MISSING_BACKBONE_NETWORK"
                }
        ]
}
```

In the above example, the backbone_network option is missing.

The protocol handler will automatically start the the Thread network, so we
need to bring it down for the initial setup. This only needs to be done once.

```
ubus call otbr threadstop
```

### LuCI

Creating a network in LuCI appears to be broken for the moment.

### CLI

```
ot-ctl dataset init new
ot-ctl dataset panid 0x12ab
ot-ctl dataset extpanid 12ab12ab12ab12ab
ot-ctl dataset networkname OpenWrThread
ot-ctl dataset networkkey ddf429af1c52d1735ffaf36fae343ee8
ot-ctl dataset commit active
ot-ctl ifconfig up
ot-ctl thread start
ot-ctl netdata register
```

### Configure route

Before you can join a device to your new Thread network, you must add a route
to the Thread prefix on the commissioner device via the OpenWrt router running
the OpenThread Border Router.

Get the prefix:
```
ot-ctl prefix
```

Example output:

```
fd6b:a92f:c531:1::/64 paros low f000
Done
```

Configuring the route is out of scope of this document, but it must be done, or
joining Thread devices will fail.

### Get hex-encoded operational dataset TLV

This is needed to join devices to the Thread Network.

```
ot-ctl dataset active -x
```

Example output:

```
0e080000000000010000000300001035060004001fffe00708fd488c6a892ec30c04106e220c964a14a7e10e9004691920ec390c0402a0f7f80102ffff030b5468726541646c6576696f0208ffffffffffffffff0510ddf429af1c52d1735ffaf36fae343ee8
```

## Join another OpenThread Border Router

Simply configure the active dataset in /etc/config/network:

```
config interface 'thread'
        option device 'wpan0'
        option proto 'openthread'
        option backbone_network 'lan'
        option dataset '0e080000000000010000000300000f35060004001fffe0020836b86cd9746ab3080708fd9850cbe719b1d205101f11a11320828c7a6ebc2f2e675c0dca030e686f6d652d617373697374616e740102716f041025804ed78614258ebedf4e2db37b3b6e0c0402a0f7f8'
        list prefix 'fd6f:5772:5468:7200::/64 paros'
        option radio_url 'spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=460800'
        option verbose '0'
```

Afterwards, bring up the interface:

```
ifup thread
```

## Join a Thread device via Matter

### ESP32
The following procedure has been tested with an ESP32-C6 using [the Matter
lighting-app example](https://github.com/project-chip/connectedhomeip/tree/master/examples/lighting-app/esp32).
Building and flashing that app is out of scope of this document.

During startup, the lighting app will print the SetupQRCode to the serial
console:

```
I (1614) chip[SVR]: SetupQRCode: [MT:Y.K9042C00KA0648G00]
I (1624) chip[SVR]: Copy/paste the below URL in a browser to see the QR Code:
I (1634) chip[SVR]: https://project-chip.github.io/connectedhomeip/qrcode.html?data=MT%3AY.K9042C00KA0648G00
I (1644) chip[SVR]: Manual pairing code: [34970112332]
```

Decide on a node ID for the device.

```
./chip-tool pairing code-thread 0x65737933320000 hex:0e080000000000010000000300001035060004001fffe00708fd488c6a892ec30c04106e220c964a14a7e10e9004691920ec390c0402a0f7f80102ffff030b5468726541646c6576696f0208ffffffffffffffff0510ddf429af1c52d1735ffaf36fae343ee8 MT:Y.K9042C00KA0648G00 --paa-trust-store-path /path/to/connectedhomeip/credentials/test/attestation/
```

