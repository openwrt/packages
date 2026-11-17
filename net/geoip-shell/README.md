# **geoip-shell**
Geoip blocker for Linux. Supports both **nftables** and **iptables** firewall management utilities.

The idea of this project is making geoip blocking easy on (almost) any Linux system, no matter which hardware, including desktop, server, VPS or router, while also being reliable and providing flexible configuration options for the advanced users.

Supports running on OpenWrt. Supports ipv4 and ipv6.

## Table of contents
- [Main Features](#main-features)
- [Usage](#usage)
- [Pre-requisites](#pre-requisites)
- [Notes](#notes)
- [In detail](#in-detail)
- [OpenWrt](#openwrt)
- [Privacy](#privacy)

## **Main Features**
* Core functionality is creating either a whitelist or a blacklist in the firewall using automatically downloaded ip lists for user-specified countries.

* ip lists are fetched either from **RIPE** (regional Internet registry for Europe, the Middle East and parts of Central Asia) or from **ipdeny**. Both sources provide updated ip lists for all regions.

* All firewall rules and ip sets required for geoip blocking to work are created automatically during installation or setup.

* Implements optional (enabled by default) persistence of geoip blocking across system reboots and automatic updates of the ip lists.

* After installation, a utility is provided to check geoip status and firewall rules or change country codes and geoip-related config.

### **Reliability**:
- Downloaded ip lists go through validation which safeguards against application of corrupted or incomplete lists to the firewall.

<details> <summary>Read more:</summary>

- With nftables, utilizes nftables atomic rules replacement to make the interaction with the system firewall fault-tolerant and to completely eliminate time when geoip is disabled during an automatic update.
- All scripts perform extensive error detection and handling.
- All user input is validated to reduce the chance of accidental mistakes.
- Verifies firewall rules coherence after each action.
- Automatic backup of geoip-shell state (optional, enabled by default except on OpenWrt).
- Automatic recovery of geoip-shell firewall rules after a reboot (a.k.a persistence) or in case of unexpected errors.
- Supports specifying trusted ip addresses anywhere on the Internet which will bypass geoip blocking to make it easier to regain access to the machine if something goes wrong.
</details>

### **Efficiency**:
- Utilizes the native nftables sets (or, with iptables, the ipset utility) which allows to create efficient firewall rules with thousands of ip ranges.

<details><summary>Read more:</summary>

- With nftables, optimizes geoip blocking for low memory consumption or for performance, depending on the RAM capacity of the machine and on user preference. With iptables, automatic optimization is implemented.
- Ip list parsing and validation are implemented through efficient regex processing which is very quick even on slow embedded CPU's.
- Implements smart update of ip lists via data timestamp checks, which avoids unnecessary downloads and reconfiguration of the firewall.
- Uses the "prerouting" hook in kernel's netfilter component which shortens the path unwanted packets travel in the system and may reduce the CPU load if any additional firewall rules process incoming traffic down the line.
- Supports the 'ipdeny' source which provides aggregated ip lists (useful for embedded devices with limited memory).
- Scripts are only active for a short time when invoked either directly by the user or by the init script/reboot cron job/update cron job.

</details>

### **User-friendliness**:
- Good command line interface and useful console messages.

<details><summary>Read more:</summary>

- Extensive and (usually) up-to-date documentation.
- Sane settings are applied during installation by default, but also lots of command-line options for advanced users or for special corner cases are provided.
- Provides a utility (symlinked to _'geoip-shell'_) for the user to change geoip config (turn geoip on or off, change country codes, change geoip blocking mode, change ip lists source, change the cron schedule etc).
- Provides a command _('geoip-shell status')_ to check geoip blocking status, which also reports if there are any issues.
- In case of an error or invalid user input, provides useful error messages to help with troubleshooting.
- All main scripts display detailed 'usage' info when executed with the '-h' option.
- The code should be fairly easy to read and includes a healthy amount of comments.
</details>

### **Compatibility**:
- Since the project is written in POSIX-compliant shell code, it is compatible with virtually every Linux system (as long as it has the [pre-requisites](#pre-requisites)). It even works well on simple embedded routers with 8MB of flash storage and 128MB of memory (for nftables, 256MB is recommended if using large ip lists such as the one for US until the nftables team releases a fix reducing memory consumption).

<details><summary>Read more:</summary>

- Supports running on OpenWrt.
- The project avoids using non-common utilities by implementing their functionality in custom shell code, which makes it faster and compatible with a wider range of systems.
</details>

## **Usage**

If you want to change geoip blocking config or check geoip blocking status, you can do that via the provided utilities.
A selection of options is given here, for additional options run `geoip-shell -h` or read [NOTES.md](NOTES.md)and [DETAILS.md](DETAILS.md).

**To check current geoip blocking status:** `geoip-shell status`. For a list of all firewall rules in the geoip chain and for a detailed count of ip ranges in each ip list: `geoip-shell status -v`.

**To add or remove ip lists for countries:** `geoip-shell <add|remove> -c <"country_codes">`

_<details><summary>Examples:</summary>_
- example (to add ip lists for Germany and Netherlands): `geoip-shell add -c "DE NL"`
- example (to remove the ip list for Germany): `geoip-shell remove -c DE`
</details>

**To enable or disable geoip blocking:** `geoip-shell <on|off>`

**To change ip lists source:** `geoip-shell configure -u <ripe|ipdeny>`

**To change geoip blocking mode:** `geoip-shell configure -m <whitelist|blacklist>`

**To have certain trusted ip addresses or subnets bypass geoip blocking:** `geoip-shell configure -t <["ip_addresses"]|none>`. `none` removes previously set trusted ip addresses.

**To have certain LAN ip addresses or subnets bypass geoip blocking:** `geoip-shell configure -l <["ip_addresses"]|auto|none>`. `auto` will automatically detect LAN subnets (only use this if the machine has no dedicated WAN interfaces). `none` removes previously set LAN ip addresses. This is only needed when using geoip-shell in whitelist mode, and typically only if the machine has no dedicated WAN network interfaces. Otherwise you should apply geoip blocking only to those WAN interfaces, so traffic from your LAN to the machine will bypass the geoip filter.

**To change protocols and ports geoblocking applies to:** `geoip-shell configure -p <[tcp|udp]:[allow|block]:[all|<ports>]>`

_(for detailed description of this feature, read [NOTES.md](NOTES.md), sections 9-11)_

**To enable or change the automatic update schedule:** `geoip-shell configure -s <"schedule_expression">`

_<details><summary>Example</summary>_

`geoip-shell configure -s "1 4 * * *"`

</details>

**To disable automatic updates of ip lists:** `geoip-shell configure -s disable`

**To update or re-install geoip-shell:** run the -install script from the (updated) distribution directory. It will first run the -uninstall script of the older/existing version, then install the new version.

On OpenWrt, if installed via an ipk package: `opkg uninstall <geoip-shell|geoip-shell-iptables>`

## **Pre-requisites**
- **Linux**. Tested on Debian-like systems and on OpenWrt, should work on any desktop/server distribution and possibly on some other embedded distributions.
- **POSIX-compliant shell**. Works on most relatively modern shells, including **bash**, **dash**, **ksh93**, **yash** and **ash** (including Busybox **ash**). Likely works on **mksh** and **lksh**. Other flavors of **ksh** may or may not work _(please let me know if you try them)_. Does **not** work on **tcsh** and **zsh**.

- **nftables** - firewall management utility. Supports nftables 1.0.2 and higher (may work with earlier versions but I do not test with them).
- OR **iptables** - firewall management utility. Should work with any relatively modern version.
- for **iptables**, requires the **ipset** utility - install it using your distribution's package manager
- standard Unix utilities including **tr**, **cut**, **sort**, **wc**, **awk**, **sed**, **grep**, **pgrep**, **pidof** and **logger** which are included with every server/desktop linux distribution (and with OpenWrt). Both GNU and non-GNU versions are supported, including BusyBox implementation.
- **wget** or **curl** or **uclient-fetch** (OpenWrt-specific utility).
- for the autoupdate functionality, requires the **cron** service to be enabled.

## **Notes**
For some helpful notes about using this suite, read [NOTES.md](NOTES.md).

## **In detail**
For specifics about each script, read [DETAILS.md](DETAILS.md).

## **OpenWrt**
For information about OpenWrt support, read the [OpenWrt README](OpenWrt-README.md).

## **Privacy**
geoip-shell does not share your data with anyone.
If you are using the ipdeny source then note that they are a 3rd party which has its own data privacy policy.

