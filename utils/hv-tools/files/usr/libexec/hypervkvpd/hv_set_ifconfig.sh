#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# This script activates a network interface based on the specified
# configuration file for OpenWrt.

# The configuration file contains network settings that need to be applied.
# This script assumes the configuration file follows a custom format
# similar to what was described, adapted for OpenWrt's UCI system.

# Check if the configuration file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <configuration_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Parse the configuration file
source "$CONFIG_FILE"

# Extract values from the configuration
INTERFACE_NAME=$(awk -F= '/DEVICE/ {print $2}' "$CONFIG_FILE")
BOOTPROTO=$(awk -F= '/BOOTPROTO/ {print $2}' "$CONFIG_FILE")

# Function to set up IPv4 configuration
configure_ipv4() {
    # Get IPv4 addresses and netmasks
    local index=0
    local ip netmask

    while :; do
        ip=$(awk -F= "/IPADDR${index}/ {print \$2}" "$CONFIG_FILE")
        netmask=$(awk -F= "/NETMASK${index}/ {print \$2}" "$CONFIG_FILE")

        if [ -n "$ip" ] && [ -n "$netmask" ]; then
            uci add_list network."$INTERFACE_NAME".ipaddr="$ip"
            uci add_list network."$INTERFACE_NAME".netmask="$netmask"
            ((index++))
        else
            break
        fi
    done

    # Set the gateway
    gateway=$(awk -F= '/GATEWAY/ {print $2}' "$CONFIG_FILE")
    if [ -n "$gateway" ]; then
        uci set network."$INTERFACE_NAME".gateway="$gateway"
    fi

    # Set DNS servers
    index=0
    while :; do
        dns=$(awk -F= "/DNS${index}/ {print \$2}" "$CONFIG_FILE")
        if [ -n "$dns" ]; then
            uci add_list network."$INTERFACE_NAME".dns="$dns"
            ((index++))
        else
            break
        fi
    done
}

# Function to set up IPv6 configuration
configure_ipv6() {
    # Get IPv6 addresses
    local index=0
    local ip

    while :; do
        ip=$(awk -F= "/IPV6ADDR${index}/ {print \$2}" "$CONFIG_FILE")
        if [ -n "$ip" ]; then
            uci add_list network."$INTERFACE_NAME".ip6addr="$ip"
            ((index++))
        else
            break
        fi
    done

    # Set the IPv6 gateway
    gateway=$(awk -F= '/IPV6_DEFAULTGW/ {print $2}' "$CONFIG_FILE")
    if [ -n "$gateway" ]; then
        uci set network."$INTERFACE_NAME".ip6gw="$gateway"
    fi

    # Set IPv6 DNS servers
    index=0
    while :; do
        dns=$(awk -F= "/IPV6DNS${index}/ {print \$2}" "$CONFIG_FILE")
        if [ -n "$dns" ]; then
            uci add_list network."$INTERFACE_NAME".dns="$dns"
            ((index++))
        else
            break
        fi
    done
}

# Set interface configuration using UCI
uci batch <<EOF
set network.$INTERFACE_NAME=interface
set network.$INTERFACE_NAME.proto=$BOOTPROTO
EOF

# Configure IPv4 and IPv6 settings
configure_ipv4
configure_ipv6

# Commit the changes
uci commit network

# Restart network service to apply changes
/etc/init.d/network restart

echo "Network configuration for $INTERFACE_NAME applied successfully."