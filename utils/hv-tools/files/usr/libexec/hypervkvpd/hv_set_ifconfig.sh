#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

# This script activates a network interface based on the specified
# configuration file for OpenWrt.

# Check if the configuration file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <configuration_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Parse the configuration file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Read settings from the configuration file
source "$CONFIG_FILE"

# Extract values from the configuration
INTERFACE_NAME=$(awk -F= '/DEVICE/ {print $2}' "$CONFIG_FILE" | tr -d '\r')
BOOTPROTO=$(awk -F= '/BOOTPROTO/ {print $2}' "$CONFIG_FILE" | tr -d '\r')

# Initialize UCI network configuration for the interface
uci batch <<EOF
set network.$INTERFACE_NAME=interface
set network.$INTERFACE_NAME.proto=$BOOTPROTO
EOF

# Function to set up IPv4 configuration
configure_ipv4() {
    index=0
    while true; do
        ip=$(awk -F= "/IPADDR${index}/ {print \$2}" "$CONFIG_FILE" | tr -d '\r')
        netmask=$(awk -F= "/NETMASK${index}/ {print \$2}" "$CONFIG_FILE" | tr -d '\r')

        if [ -n "$ip" ] && [ -n "$netmask" ]; then
            uci set network.$INTERFACE_NAME.ipaddr="$ip"
            uci set network.$INTERFACE_NAME.netmask="$netmask"
            index=$(expr $index + 1)
        else
            break
        fi
    done

    # Set the gateway
    gateway=$(awk -F= '/GATEWAY/ {print $2}' "$CONFIG_FILE" | tr -d '\r')
    if [ -n "$gateway" ]; then
        uci set network.$INTERFACE_NAME.gateway="$gateway"
    fi

    # Set DNS servers
    index=0
    while true; do
        dns=$(awk -F= "/DNS${index}/ {print \$2}" "$CONFIG_FILE" | tr -d '\r')
        if [ -n "$dns" ]; then
            uci add_list network.$INTERFACE_NAME.dns="$dns"
            index=$(expr $index + 1)
        else
            break
        fi
    done
}

# Function to set up IPv6 configuration
configure_ipv6() {
    index=0
    while true; do
        ip=$(awk -F= "/IPV6ADDR${index}/ {print \$2}" "$CONFIG_FILE" | tr -d '\r')
        if [ -n "$ip" ]; then
            uci add_list network.$INTERFACE_NAME.ip6addr="$ip"
            index=$(expr $index + 1)
        else
            break
        fi
    done

    # Set the IPv6 gateway
    gateway=$(awk -F= '/IPV6_DEFAULTGW/ {print $2}' "$CONFIG_FILE" | tr -d '\r')
    if [ -n "$gateway" ]; then
        uci set network.$INTERFACE_NAME.ip6gw="$gateway"
    fi

    # Set IPv6 DNS servers
    index=0
    while true; do
        dns=$(awk -F= "/IPV6DNS${index}/ {print \$2}" "$CONFIG_FILE" | tr -d '\r')
        if [ -n "$dns" ]; then
            uci add_list network.$INTERFACE_NAME.dns="$dns"
            index=$(expr $index + 1)
        else
            break
        fi
    done
}

# Configure IPv4 and IPv6 settings
configure_ipv4
configure_ipv6

# Commit the changes
uci commit network

# Restart network service to apply changes
/etc/init.d/network restart

echo "Network configuration for $INTERFACE_NAME applied successfully."
