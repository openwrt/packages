# OpenWrt package feed for etherwake-nfqueue


## Wake up computers on netfilter match

This repository contains the OpenWrt package feed for
[etherwake-nfqueue](https://github.com/mister-benjamin/etherwake-nfqueue),
a fork of the **etherwake** Wake-on-LAN client, with support to send magic
packets only after a queued packet is received from the Linux *nfnetlink_queue*
subsystem.

When running **etherwake-nfqueue** on a residential gateway or other type of
router, it can wake up hosts on its network based on packet filtering rules.

For instance, when your set-top box wants to record a TV programme and
tries to access a network share on your NAS, which is in sleep or standby mode,
**etherwake-nfqueue** can wake up your NAS. Or when you set up port forwarding
to a host on your home network, **etherwake-nfqueue** can wake up your host
when you try to access it over the Internet.

The documentation below is mostly OpenWrt specific. For more information on
etherwake-nfqueue itself and use case examples, please consult its
[Readme](https://github.com/mister-benjamin/etherwake-nfqueue/blob/master/README.md).


## Building the package

Currently, no pre-built packages are provided. The following assumes that you
already have a working OpenWrt build system for your target device.

If you haven't, you can follow one of these guides:

* If you only want to compile packages, and no firmware image:
  [Build system – Installation](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem) and
  [Using the SDK](https://openwrt.org/docs/guide-developer/using_the_sdk)

* To quickly build a firmware image off a development snapshot:
  [Quick Image Building Guide](https://openwrt.org/docs/guide-developer/quickstart-build-images)

* Or when you are completely new to using build systems:
  [Beginners guide to building your own firmware](https://openwrt.org/docs/guide-user/additional-software/beginners-build-guide)

### Dependencies

**etherwake-nfqueue** depends on these OpenWrt packages:

* libnetfilter-queue
* iptables-mod-nfqueue

They will be automatically selected and compiled for you. If they are not
installed on your target device, *opkg* will try to resolve dependencies with
packages in the repositories.

### Adding the package feed

First, you need to add the **etherwake-nfqueue** package feed to your build
system.  In the root directory of your OpenWrt build system, find the file
*feeds.conf* (or *feeds.conf.default* if the former shouldn't exist) and add
the following line to it:

```
src-git ethernfq https://github.com/mister-benjamin/etherwake-nfqueue-openwrt.git
```

Then update and install the package feed:
```
user@host:~/openwrt$ scripts/feeds update ethernfq
user@host:~/openwrt$ scripts/feeds install -a -p ethernfq
```

After that, enter OpenWrt's configuration menu
```
user@host:~/openwrt$ make menuconfig
```
and enable **etherwake-nfqueue** in the **Network** sub-menu. It can either be selected
as built-in (\*) or module (M), depending on your decision to include it into a
firmware image or just build the *opkg* package for installation.

Then you should be able to compile the package:
```
user@host:~/openwrt$ make package/etherwake-nfqueue/compile
```

The path of the resulting package depends on your selected *Target System*.
In case of the Linksys WRT1200AC, it can be found here:
```
bin/packages/arm_cortex-a9_vfpv3/ethernfq/etherwake-nfqueue_2019-09-10-67e9d4ca-1_arm_cortex-a9_vfpv3.ipk
```


## Installation

One way to install the package is by simply copying it over to the device with *scp*:
```
user@host:~$ scp etherwake-nfqueue_2019-09-10-67e9d4ca-1_arm_cortex-a9_vfpv3.ipk root@gateway:~
```
And then, install it on the device:
```
root@gateway:~# opkg install etherwake-nfqueue_2019-09-10-67e9d4ca-1_arm_cortex-a9_vfpv3.ipk
```


## Configuration

### WoL Targets

After a fresh installation, no target is configured. Targets are referred
to as the hosts to wake up. Multiple targets can coexist.

Targets can be configured with OpenWrt's UCI.

For example, to add a target called **nas**, with MAC address
 **00:25:90:00:d5:fd**, which is reachable over the VLAN configured
on **eth0.3**, issue this command sequence on your router:

```
uci add etherwake-nfqueue target
uci set etherwake-nfqueue.@target[-1].name=nas
uci set etherwake-nfqueue.@target[-1].mac=00:25:90:00:d5:fd
uci set etherwake-nfqueue.@target[-1].interface=eth0.3
uci commit
```

For each target, one instance of **etherwake-nfqueue** will be started.

Each instance should bind to a different *nfnetlink_queue*. A queue can
be referenced by its queue number. Counting starts from 0, which is the default.
To use a different queue, provide the **nfqueue_num** option. The
following could have been added to the sequence above to use queue 1 instead
of 0:

```
uci set etherwake-nfqueue.@target[-1].nfqueue_num=1
```

The necessity of a queue number will probably become clear, when the iptables
rules are configured in section [Setup firewall rules](#setup-firewall-rules).

The full list of options for a target is:

| Option      | Required | Description                                      |
| ----------- | -------- | ------------------------------------------------ |
| name        | no       | Name of the target, e.g. name=example            |
| mac         | yes      | MAC address of the host to wake up, e.g. mac=00:22:44:66:88:aa |
| nfqueue_num | no       | The queue number used for receiving filtered packets, default is nfqueue_num=0 |
| interface   | no       | The interface used for sending the magic packet, default is interface=eth0 |
| broadcast   | no       | Send magic packet to broadcast address, default is broadcast=off |
| password    | no       | Set a password (required by some adapters), e.g. password=00:22:44:66:88:aa or 192.168.1.1 |
| enabled     | no       | Optionally disable the target, default is enabled=true |

After committing your changes, the settings are persisted to
*/etc/config/etherwake-nfqueue*. This is an illustrative example:
```
config etherwake-nfqueue 'setup'
        option sudo 'off'
        option debug 'off'

config target
        option name 'nas'
        option mac '00:25:90:00:d5:fd'
        option interface 'eth0.3'

config target
        option name 'xyz-board'
        option mac '00:25:90:00:d5:fc'
        option nfqueue_num '1'
        option enabled 'false'

config target
        option name 'ip-camera'
        option mac '00:25:90:00:d5:fb'
        option nfqueue_num '2'
        option interface 'eth0.3'
        option broadcast 'on'
        option password '00:25:90:00:d5:fb'
```

When all target(s) are configured, restart the *etherwake-nfqueue* service:
```
/etc/init.d/etherwake-nfqueue restart
```

### Setting up filters

Without any firewall rules which tell the kernel to match and add packets
to a *nfnetlink_queue*, **etherwake-nfqueue** will never send out a magic
packet to wake its target.

#### Prerequisites

In order to let the *netfilter* framework of the kernel see the packets,
they need to pass through the router. This is usually not the case when
hosts are on the same subnet and don't require network layer routing.
The data will only pass through the router's switch on the link layer.

As a consequence, we can only use packets as a trigger which need to be
routed or bridged by the router. Packets being forwarded between WAN
and LAN are of that type. For other SOHO use cases, partitioning your
network by means of subnets or VLANs might be necessary. The latter
is often used to set up a DMZ.

For VLANs:

* There's a mini howto referring to the **LuCI Web Interface**
  *(Network -> Switch)* way of configuring VLANs:
  [How-To: Creating an additional virtual switch on a typical home router](https://openwrt.org/docs/guide-user/network/vlan/creating_virtual_switches)

* The manual approach is documented here:
  [VLAN](https://openwrt.org/docs/guide-user/network/vlan/switch_configuration)

Guides to setup a DMZ can be found here:

* [Guide to set up DMZ via LUCI](https://forum.openwrt.org/t/guide-to-set-up-dmz-via-luci/21616)

* [fw3 DMZ Configuration Using VLANs](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/fw3_dmz)

The physical switch layout is device specific. E.g. the layout for the Linksys
WRT AC Series is documented
[here](https://oldwiki.archive.openwrt.org/toh/linksys/wrt_ac_series#switch_layout).


Using two LANs or VLANs with the same network address and bridging them again
is a trick to setup a transparent (or bridging) firewall on the same subnet.
This way, packets can be seen by *netfilter* on the router even if the
packets are not routed. Unfortunately this doesn't help when the host
which we want to wake up is offline, as the ARP requests for the destination
IP address are not answered and thus the client trying to reach out to its
destination will not send any *network layer* packets. We could use *arptables*
instead to wake the host when someone requests its MAC address, but this
would probably happen too often and no fine-grained control would be possible.

As a workaround, it might be possible to configure a static ARP entry on your
router (untested), e.g. with:
```
ip neigh add 192.168.0.10 lladdr 00:25:90:00:d5:fd nud permanent dev eth0.3
```
Note that this requires the *ip-full* OpenWrt package to be installed.

To make your firewall rules work with bridging, you need to install the
*kmod-br-netfilter* package and add `net.bridge.bridge-nf-call-iptables=1`
to */etc/sysctl.conf*.


#### Setup firewall rules

One way to setup custom firewall rules in OpenWrt is through its
*/etc/firewall.user* script. This file can also be edited by means of
the **LuCI Web Interface** *(Network -> Firewall -> Custom Rules)*.

The file is interpreted as a shell script, so we can simply use **iptables**
to add our custom firewall rules.

Notice the comment
```
# Internal uci firewall chains are flushed and recreated on reload, so
# put custom rules into the root chains e.g. INPUT or FORWARD or into the
# special user chains, e.g. input_wan_rule or postrouting_lan_rule.
```

Refer to [Packet flow](https://oldwiki.archive.openwrt.org/doc/uci/firewall#packet_flow)
for usable chains. In the example below, the chains *forwarding_lan_rule* and
*forwarding_wan_rule* are used. To inspect the rule sets of the different tables, one can
use

```
iptables --list                  # default is --table filter
iptables --table nat --list
iptables --table mangle --list
iptables --table raw --list      # requires kmod-ipt-raw
```

The following is an example of what could be added to */etc/firewall.user*:

```
iptables --insert forwarding_lan_rule\
         --protocol tcp --in-interface=br-lan --out-interface=eth0.3\
         --destination 192.168.0.10 --destination-port 445\
         --match conntrack --ctstate NEW\
         --match limit --limit 3/hour --limit-burst 1\
         --jump NFQUEUE --queue-num 0 --queue-bypass\
         --match comment --comment "Wake up NAS on LAN SMB"
iptables --insert forwarding_lan_rule\
         --protocol tcp --in-interface=br-lan --out-interface=eth0.3\
         --destination 192.168.0.11 --match multiport --destination-ports 515,54921,631\
         --match conntrack --ctstate NEW\
         --match limit --limit 3/hour --limit-burst 1\
         --jump NFQUEUE --queue-num 0 --queue-bypass\
         --match comment --comment "Wake up NAS on print request"
iptables --insert forwarding_lan_rule\
         --protocol udp --in-interface=br-lan --out-interface=eth0.3\
         --destination 192.168.0.11 --destination-port 161\
         --match conntrack --ctstate NEW\
         --match limit --limit 3/hour --limit-burst 1\
         --jump NFQUEUE --queue-num 0 --queue-bypass\
         --match comment --comment "Wake up NAS on print request"
iptables --insert forwarding_wan_rule\
         --protocol tcp --in-interface=eth1.2 --out-interface=eth0.3\
         --destination 192.168.0.10 --destination-port 22\
         --match conntrack --ctstate NEW\
         --match limit --limit 3/hour --limit-burst 1\
         --jump NFQUEUE --queue-num 0 --queue-bypass\
         --match comment --comment "Wake up NAS on WAN SSH"
```

In this example, packets are filtered based on the protocol, their input
and output interfaces, their destination (IP address) and their destination
port(s).

The option `--match conntrack --ctstate NEW` only matches packets of a new
connection and `--match limit --limit 3/hour --limit-burst 1` limits the
amount of packets that are matched. The latter option roughly matches
only one packet per 20 minutes. The intention here is to not be too intrusive
and avoid sending a lot of magic packets.

The `--jump NFQUEUE --queue-num 0` options tell the *netfilter*
framework to enqueue a matching packet to the NFQUEUE number 0. In this
example, all four rules send the matching packets into queue 0. The
additional option `--queue-bypass` helps in the situation, when
**etherwake-nfqueue** isn't running. Packets will then be handled
as if the rule wasn't present.


## Disabling targets

To disable targets, first find their index:
```
uci show etherwake-nfqueue
```

Then set its *enabled* option to false and restart the service.
For index 0, it can be done like this:
```
uci set etherwake-nfqueue.@target[0].enabled=false
/etc/init.d/etherwake-nfqueue restart
```


## Troubleshooting

### Debug mode

In order to see what's going on in syslog and get some debug output when
starting the service, enable etherwake-nfqueue's debug mode:
```
uci set etherwake-nfqueue.setup.debug=on
```
In another user session tail the log:
```
logread -f
```
And then restart the service:
```
/etc/init.d/etherwake-nfqueue restart
```

### Inspect netfilter

To inspect the working of your firewall rules, you can print statistics
of the chains you used, e.g.:
```
iptables --verbose --list forwarding_lan_rule
```

If you happen to have the *procps-ng-watch* package installed, you can watch
them:
```
watch iptables --verbose --list forwarding_lan_rule
```

To see, if your queues are in place, use:
```
cat /proc/net/netfilter/nfnetlink_queue
```

## Potential improvements

* Add **LuCI Web Interface** configuration frontend for *targets* and *filter rules*
* Add an option to set *nice* values for instances
