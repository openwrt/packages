# UDP Broadcast Relay

This program listens for packets on a specified UDP broadcast port. When a packet is received, it sends that packet to all specified interfaces but the one it came from as though it originated from the original sender.

The primary purpose of this is to allow devices or game servers on separated local networks (Ethernet, WLAN, VLAN) that use udp broadcasts to find each other to do so.

---

>[!NOTE]
>This package is built from https://github.com/marjohn56/udpbroadcastrelay. More examples and information can be found there.

### Package Config File Information  
`/etc/config/udpbroadcastrelay`

| Name | Type | CMD Option | Description |
| --- | --- | --- | --- |
| option id | integer | `--id` | Must be unique number between instances with range 1-63. This is used to set the DSCP of outgoing packets to determine if a packet is an echo and should be discarded. |
| option port | integer | `--port` | Destination udp port to listen to. Range 1-65535. Example values for common services are given below. |
| list network | network name | `--dev` | Specifies the name of an interface to receive and transmit packets on. This option needs to be specified at least twice for 2 separate interfaces otherwise this tool won't actually do anything. |
| option blockcidr | CIDR | `--blockcidr` | Can be used to block packets from a range of IP source addresses, given in CIDR notation. This option can be specified multiple times to block more than one range. Where multiple overlapping CIDRs are specified with the `blockcidr` and `allowcidr` options the most specific match (longest prefix) will take effect. |
| option allowcidr | CIDR | `--allowcidr` | Can be used to only allow packets from a range of IP source addresses, given in CIDR notation. This option can be specified multiple times to allow more than one range. Once this option is specified the default behaviour for packets which does not any CIDRs changes from Allow to Block. |
| option src_override | IP | `-s` | The source address for all packets can be modified with `src_override`. This is unusual. A special source ip of `-s 1.1.1.1` can be used to change the source ip of the relayed packets to match the ip address of the relay server's destination interface. Additionally, the source UDP port for the server's destination interface is set to the same destination port found in the original packet. `-s 1.1.1.2` does the same but leaves the UDP ports unchanged. These values are notably required to cater for the Chromecast system. |
| option multicast | IP | `--multicast` | Can listen for and relay packets using multicast groups. |
| option debug | 0 or 1 | `-d -d` | Set to 1 for more debug output. |


### mDNS example
```
config udpbroadcastrelay
    option id 1
    option port 5353
    list network lan
    list network guest
    option multicast 224.0.0.251
    option src_override 1.1.1.1
```

### SSDP example
```
config udpbroadcastrelay
    option id 2
    option port 1900
    list network lan
    list network guest
    option multicast 239.255.255.250
```

### mDNS example which allows messages from hosts on 192.168.1.0/24 and 192.168.20.0/24 subnets but blocks host 192.168.20.20
```
config udpbroadcastrelay
    option id 3
    option port 5353
    list network lan
    list network guest
    option multicast 224.0.0.251
    option src_override 1.1.1.1
    option allowcidr 192.168.1.0/24
    option allowcidr 192.168.20.0/24
    option blockcidr 192.168.20.20/32
```
