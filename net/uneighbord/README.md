# uneighbord

uneighbord synchronizes hostapd 802.11k Neighbor Reports between local
`hostapd.*` BSSes and other OpenWrt access points on the same LAN, over
IPv6 link-local UDP multicast. Reports are only shared between BSSes with
the same SSID, and installed through hostapd's ubus API.

## Requirements

`ucode`, `ucode-mod-ubus`, `ucode-mod-uloop`, `ucode-mod-socket`, `ucode-mod-uci`, `ucode-mod-log`.

## Build and install

```sh
make menuconfig                  # select Network -> uneighbord
make package/uneighbord/compile V=s
```

Install the resulting package, then:

```sh
/etc/init.d/uneighbord enable
/etc/init.d/uneighbord start
```

## Configuration

```uci
config uneighbord 'main'
        option enabled '1'
        option network 'lan'
```

`network` is an OpenWrt logical network name (not a device name); its
`l3_device` is used for multicast membership and scope.

## How it works

Every 30 seconds each AP announces its local Neighbor Reports (from
`rrm_nr_get_own`) as a small JSON packet to a fixed IPv6 multicast group on
port 32027. For each local BSS, same-SSID reports from other local BSSes
and remote peers are merged, excluding the BSS's own entry, and installed
via `rrm_nr_set`. Remote peers are dropped after 90 seconds without a
fresh announcement.

uneighbord assumes a trusted L2/backhaul network: announcements are
unauthenticated, so any host able to reach the multicast group can
influence the installed Neighbor Report list.

## Debugging

```sh
ubus list 'hostapd.*'
ubus call hostapd.<interface> rrm_nr_list
logread -e uneighbord
ss -6 -u -a -n | grep 32027
ip -6 maddr show dev br-lan
```
