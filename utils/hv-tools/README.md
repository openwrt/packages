# Explanation
**Interface Name**: The script uses the interface name from the configuration file and applies settings via UCI.
**IP Addresses and Netmasks**: IPv4 and IPv6 addresses and netmasks are configured by reading values from the configuration file.
**Gateway and DNS**: The script also sets up gateway and DNS settings using UCI.
**Protocol**: The script supports dynamic (DHCP) and static configurations based on the BOOTPROTO setting.
**Network Restart**: After applying the changes, the network service is restarted to ensure settings are applied.

## Configuration File Format
Ensure your configuration file follows this format:

```
# Configuration file format example
DEVICE=eth0
BOOTPROTO=static

# IPv4
IPADDR0=192.168.1.10
NETMASK0=255.255.255.0
GATEWAY=192.168.1.1
DNS0=8.8.8.8
DNS1=8.8.4.4

# IPv6
IPV6ADDR0=2001:0db8:85a3::8a2e:0370:7334/64
IPV6_DEFAULTGW=2001:0db8:85a3::1
IPV6DNS0=2001:4860:4860::8888
IPV6DNS1=2001:4860:4860::8844
```

## Usage
Run the script with the configuration file as an argument:

```ash
./hv_set_ifconfig.sh /path/to/configuration_file
```
This script provides a simple yet powerful way to configure network interfaces in OpenWrt environments using UCI, tailored for integration with Hyper-V tools. Adjustments can be made as needed to fit more complex configurations or additional network options.