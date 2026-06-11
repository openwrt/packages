## Wireguard Installer

This tool can be used to automatically create wireguard tunnels. Using rpcd a new wireguard interface is created on the server where the client can connect to.

## Installation

For Server

    opkg install wireguard-installer-server

For Client

    opkg install wireguard-installer-client

Wiregurad server automatically installs a user and associated ACL to use the wireguard-installer-server features.
The user is called wginstaller and so is the password.

## Usage

Get Usage Statistics

    wg-client-installer get_usage --ip 127.0.0.1 --user wginstaller --password wginstaller

Register Tunnel Interface

    wg-client-installer register --ip 127.0.0.1 --user wginstaller --password wginstaller --bandwidth 10

## Hotplugs

- wg-installer-server-hotplug-babeld: mesh automatically via wireguard with babeld
