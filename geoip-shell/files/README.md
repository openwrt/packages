# **geoip-shell**
Geoip blocker for Linux. Supports both **nftables** and **iptables** firewall management utilities.

The idea of this project is making geoip blocking easy on (almost) any Linux system, no matter which hardware, including desktop, server, VPS or router, while also being reliable and providing flexible configuration options for the advanced users.

Supports running on OpenWrt. Supports ipv4 and ipv6.

## Table of contents
- [Main Features](#main-features)
- [Installation](#installation)
- [Usage](#usage)
- [Pre-requisites](#pre-requisites)
- [Notes](#notes)
- [In detail](#in-detail)
- [OpenWrt](#openwrt)
- [Privacy](#privacy)

## **Main Features**
* Core functionality is creating either a whitelist or a blacklist in the firewall using automatically downloaded ip lists for user-specified countries.

* ip lists are fetched either from **RIPE** (regional Internet registry for Europe, the Middle East and parts of Central Asia) or from **ipdeny**. Both sources provide updated ip lists for all regions.

* All firewall rules and ip sets required for geoip blocking to work are created during installation.

* Implements optional (enabled by default) persistence of geoip blocking across system reboots and automatic updates of the ip lists.

* After installation, a utility is provided to check geoip status and firewall rules or change geoip-related config.

### **Reliability**:
- Downloaded ip lists go through validation which safeguards against application of corrupted or incomplete lists to the firewall.

<details> <summary>Read more:</summary>

- Default source for ip lists is RIPE, which allows to avoid dependency on non-official 3rd parties.
- With nftables, utilizes nftables atomic rules replacement to make the interaction with the system firewall fault-tolerant and to completely eliminate time when geoip is disabled during an automatic update.
- All scripts perform extensive error detection and handling.
- Verifies firewall rules coherence after each action.
- Automatic backup of geoip-shell state (optional, enabled by default).
- Automatic recovery of geoip-shell state after a reboot (a.k.a persistence) or in case of unexpected errors.
- During installation, you can specify trusted ip addresses anywhere on the Internet which will bypass geoip blocking to make it easier to regain access to the machine if something goes wrong.
</details>

### **Efficiency**:
- Utilizes the native nftables sets (or, with iptables, the ipset utility) which allows to create efficient firewall rules with thousands of ip ranges.

<details><summary>Read more:</summary>

- With nftables, optimizes geoip blocking for low memory consumption or for performance, depending on user preference. With iptables, automatic optimization is implemented.
- Ip list parsing and validation are implemented through efficient regex processing which is very quick even on slow embedded CPU's.
- Implements smart update of ip lists via data timestamp checks, which avoids unnecessary downloads and reconfiguration of the firewall.
- Uses the "prerouting" hook in kernel's netfilter component which shortens the path unwanted packets travel in the system and may reduce the CPU load if any additional firewall rules process incoming traffic down the line.
- Supports the 'ipdeny' source which provides aggregated ip lists (useful for embedded devices with limited memory).
- Scripts are only active for a short time when invoked either directly by the user or by the init script/reboot cron job/update cron job.

</details>

### **User-friendliness**:
- Installation is easy and normally takes a very short time.

<details><summary>Read more:</summary>

- Good command line interface and useful console messages.
- Extensive and (usually) up-to-date documentation.
- Comes with an *uninstall script which completely removes the suite and the geoip firewall rules. No restart is required.
- Sane settings are applied during installation by default, but also lots of command-line options for advanced users or for special corner cases are provided.
- Pre-installation, provides a utility _(check-ip-in-source.sh)_ to check whether specific ip addresses you might want to blacklist or whitelist are indeed included in the list fetched from the source (RIPE or ipdeny).
- Post-installation, provides a utility (symlinked to _'geoip-shell'_) for the user to change geoip config (turn geoip on or off, change country codes, change geoip blocking mode, change ip lists source, change the cron schedule etc).
- Post-installation, provides a command _('geoip-shell status')_ to check geoip blocking status, which also reports if there are any issues.
- In case of an error or invalid user input, provides useful error messages to help with troubleshooting.
- Most scripts display detailed 'usage' info when executed with the '-h' option.
- The code should be fairly easy to read and includes a healthy amount of comments.
</details>

### **Compatibility**:
- Since the project is written in POSIX-compliant shell code, it is compatible with virtually every Linux system (as long as it has the [pre-requisites](#pre-requisites)). It even works well on simple embedded routers with 8MB of flash storage and 128MB of memory (for nftables, 256MB is recommended if using large ip lists such as the one for US until the nftables team releases a fix reducing memory consumption).

<details><summary>Read more:</summary>

- Supports running on OpenWrt.
- The project avoids using non-common utilities by implementing their functionality in custom shell code, which makes it faster and compatible with a wider range of systems.
</details>

## **Installation**
NOTE: Installation can be run interactively, which does not require any command line arguments and gathers the important config via dialog with the user. Alternatively, config may be provided via command-line arguments.

Some features are only accessible via command-line arguments.
_To find out more, use `sh geoip-shell-install.sh -h` or read [NOTES.md](/Documentation/NOTES.md) and [DETAILS.md](/Documentation/DETAILS.md)_

_(Note that some commands require root privileges, so you will likely need to run them with `sudo`)_

**1)** If your system doesn't have `wget`, `curl` or (OpenWRT utility) `uclient-fetch`, install one of them using your distribution's package manager. Systems which only have `iptables` also require the `ipset` utility.

**2)** Download the latest realease: https://github.com/friendly-bits/geoip-shell/releases. Unless you are installing on OpenWrt, download **Source code (zip or tar.gz)**. For installation on OpenWrt, read the [OpenWrt README](/OpenWrt-README.md).
  _<details><summary>Or download using the command line:</summary>_
  - either run `git clone https://github.com/friendly-bits/geoip-shell` - this will include all the latest changes but may not always be stable
  - or to download the latest release (requires curl):

    `curl -L "$(curl -s https://api.github.com/repos/friendly-bits/geoip-shell/releases | grep -m1 -o 'https://api.github.com/repos/friendly-bits/geoip-shell/tarball/[^"]*')" > geoip-shell.tar.gz`
  
  - to extract, run: `tar -xvf geoip-shell.tar.gz`
  </details>

**3)** Extract all files included in the release into the same folder somewhere in your home directory and `cd` into that directory in your terminal.

**4)** For interactive installation, run `sh geoip-shell-install.sh`.

  **NOTE:** If the install script says that your shell is incompatible but you have another compatible shell installed, use it instead of `sh` to call the -install script. For example: `dash geoip-shell-install.sh`. Check out [Pre-Requisites](#pre-requisites) for a list of compatible shells. If you don't have one of these installed, use your package manager to install one (you don't need to make it your default shell).

  _<details><summary>Examples for non-interactive installation options:</summary>_

  - installing on a server located in Germany, which has nftables and is behind a firewall (no direct WAN connection), whitelist Germany and Italy and block all other countries:

  `sh geoip-shell-install.sh -m whitelist -c "DE IT" -r DE -i all -l auto -O performance`

  - installing on a router located in the US, blacklist Germany and Netherlands and allow all other countries:

  `sh geoip-shell-install.sh -m blacklist -c "DE NL" -r US -i pppoe-wan`

  - if you prefer to fetch the ip lists from a specific source, add `-u <source>` to the arguments, where <source> is `ripe` or `ipdeny`.
  - to block or allow specific ports or ports ranges, use `<[tcp|udp]:[allow|block]:[ports]>`. This option may be used twice in one command to specify ports for both tcp and udp _(for examples, read [NOTES.md](/Documentation/NOTES.md), sections 9-11)_.
  - to exclude certain trusted ip addresses or subnets on the internet from geoip blocking, add `-t <"[trusted_ips]">` to the arguments
  - if your machine uses nftables and has enough memory, consider installing with the `-O performance` option
  - if your distro (or you) have enabled automatic nftables/iptables rules persistence, you can disable the built-in cron-based persistence feature by adding the `-n` (for no-persistence) option when running the -install script.
  - if for some reason you need to install the suite in strictly non-interactive mode, you can call the install script with the `-z` option which will avoid asking the user any questions and will fail if required config is incomplete or invalid.
  </details>

**5)** The install script will ask you several questions to configure the installation, then initiate download and application of the ip lists. If you are not sure how to answer some of the questions, read [INSTALLATION.md](/Documentation/INSTALLATION.md).

**6)** That's it! By default, ip lists will be updated daily at 4:15am local time (4:15 at night) - you can verify that automatic updates are working by running `geoip-shell status`: this will report geoip-shell status and time of last successful update (note that this time doesn't change if ip lists are already up-to-date during an automatic update). Alternatively, run `cat /var/log/syslog | grep geoip-shell` on the next day to check geoip-shell log messages (change syslog path if necessary, according to the location assigned by your distro. on OpenWrt and some other distributions a different command should be used, such as `logread`).

## **Usage**
_(Note that all commands require root privileges, so you will likely need to run them with `sudo`)_

Generally, once the installation completes, you don't have to do anything else for geoip blocking to work (if you installed via an OpenWrt ipk package, read the [OpenWrt README](/OpenWrt-README.md)). If you want to change geoip blocking config or check geoip blocking status, you can do that via the provided utilities.
A selection of options is given here, for additional options run `geoip-shell -h` or read [DETAILS.md](/Documentation/DETAILS.md).

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

_(for details, read [NOTES.md](/Documentation/NOTES.md), sections 9-11)_

**To enable or change the automatic update schedule:** `geoip-shell configure -s <"schdedule_expression">`

_<details><summary>Example</summary>_

`geoip-shell configure -s "1 4 * * *"`

</details>

**To disable automatic updates of ip lists:** `geoip-shell configure -s disable`

**To update or re-install geoip-shell:** run the -install script from the (updated) distribution directory. It will first run the -uninstall script of the older/existing version, then install the new version.

**To uninstall:**

`geoip-shell-uninstall.sh`

On OpenWrt, if installed via an ipk package: `opkg uninstall <geoip-shell|geoip-shell-iptables>`

## **Pre-requisites**
(if a pre-requisite is missing, the _-install.sh_ script will tell you which)
- **Linux**. Tested on Debian-like systems and on OPENWRT, should work on any desktop/server distribution and possibly on some other embedded distributions.
- **POSIX-compliant shell**. Works on most relatively modern shells, including **bash**, **dash**, **ksh93**, **yash** and **ash** (including Busybox **ash**). Likely works on **mksh** and **lksh**. Other flavors of **ksh** may or may not work _(please let me know if you try them)_. Does **not** work on **tcsh** and **zsh**.

    **NOTE:** If the install script says that your shell is incompatible but you have another compatible shell installed, use it instead of `sh` to call the -install script. For example: `dash geoip-shell-install.sh` The shell you use to install geoip-shell will be the shell it runs in after installation. Generally prefer the simpler shells (like dash or ash) over complex shells (like bash and ksh) due to better performance.
- **nftables** - firewall management utility. Supports nftables 1.0.2 and higher (may work with earlier versions but I do not test with them).
- OR **iptables** - firewall management utility. Should work with any relatively modern version.
- for **iptables**, requires the **ipset** utility - install it using your distribution's package manager
- standard Unix utilities including **tr**, **cut**, **sort**, **wc**, **awk**, **sed**, **grep**, and **logger** which are included with every server/desktop linux distribution (and with OpenWrt). Both GNU and non-GNU versions are supported, including BusyBox implementation.
- **wget** or **curl** or **uclient-fetch** (OpenWRT-specific utility).
- for the autoupdate functionality, requires the **cron** service to be enabled. Except on OpenWrt, persistence also requires the cron service.

**Optional**: the _check-ip-in-source.sh_ optional script requires **grepcidr**. install it with `apt install grepcidr` on Debian and derivatives. For other distros, use their built-in package manager.

## **Notes**
For some helpful notes about using this suite, read [NOTES.md](/Documentation/NOTES.md).

## **In detail**
For specifics about each script, read [DETAILS.md](/Documentation/DETAILS.md).

## **OpenWrt**
For information about OpenWrt support, read the [OpenWrt README](/OpenWrt-README.md).

## **Privacy**
These scripts do not share your data with anyone, as long as you downloaded them from the official source, which is
https://github.com/friendly-bits/geoip-shell
If you are using the ipdeny source then note that they are a 3rd party which has its own data privacy policy.

