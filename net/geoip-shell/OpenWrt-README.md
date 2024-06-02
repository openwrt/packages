## geoip-shell on OpenWrt

Currently geoip-shell fully supports OpenWrt, both with firewall3 + iptables and with firewall4 + nftables, while providing the same user interface and features as on any other Linux system. So usage is the same as described in the main [README.md](README.md) file, while some parts of the backend (namely persistence implementation), some defaults and the location of the data directory are different.

The _geoip-shell-iptables_ package is for firewall3+iptables OpenWrt systems, while the _geoip-shell_ package is for firewall4+nftables OpenWrt systems.

A LuCi interface has not been implemented (yet). As on any other Linux system, all user interface is via a command line (but my goal is to make this an easy experience regardless). If this discourages you from using geoip-shell, please let me know. A few people asking for this feature may motivate me to prioritize it.

## Usage after installation via ipk
After installing the ipk package, geoip-shell will be inactive until you configure it. To do so, run `geoip-shell configure` and follow the interactive setup. You can also run `geoip-shell -h` before that to find out about configuration options and then append certain options after the `configure` action, for example: `geoip-shell configure -c "de nl" -m whitelist` to configure geoip-shell in whitelist mode for countries Germany and Netherlands. The interactive setup will ask you about all the important options but some niche options are only available non-interactively (for example if you want to configure geoblocking for certain selection of ports). You can always change these settings after initial configuration via the same `geoip-shell configure` command.

## Uninstallation of geoip-shell if installed via ipk
- For nftables-based systems: `opkg remove geoip-shell`
- For iptables-based systems: `opkg remove geoip-shell-iptables`

## Resources management on OpenWrt
Because OpenWrt typically runs on embedded devices with limited memory and very small flash storage, geoip-shell implements some techniques to conserve these resources as much as possible:
- During installation on OpenWrt, comments and the debug code are stripped from the scripts to reduce their size.
- Only the required modules are installed, depending on the system (iptables- or nftables- based).
- I've researched the most memory-efficient way for loading ip lists into nftables sets. Currently, nftables has some bugs related to this process which may cause unnecessarily high memory consumption. geoip-shell works around these bugs as much as possible.
- To avoid unnecessary flash storage wear, all filesystem-related tasks geoip-shell does which do not require permanent storage are done in the /tmp directory which in the typical OpenWrt installation is mounted on the ramdisk.
- Some defaults on OpenWrt are different to further minimize flash storage wear (read below).

### Scripts size
Typical geoip-shell installation on an OpenWrt system currently consumes around 120kB. The distribution folder itself weighs quite a bit more (mainly because of documentation) but you can install via an ipk which doesn't remain in storage after installation, or if installing via the -install script, delete the distribution folder and free up space taken by it. geoip-shell does not install its documentation into the system.
I have some plans to reduce that size by compressing certain scripts which provide user interface and implementing automatic extraction to /tmp when the user wants to access them, but this is not yet implemented.

To view all installed geoip-shell scripts in your system and their sizes, run `ls -lh /usr/bin/geoip-shell-* /usr/lib/geoip-shell/*`.

## Persistence on OpenWrt
- Persistence of geoip firewall rules and ip sets works differenetly on OpenWrt than on other Linuxes, since geoip-shell has an OpenWrt-specific procd init script.
- The cron job which implements persistence on other Linuxes and runs at reboot is not created on OpenWrt.
- geoip-shell integrates into firewall3 or firewall4 via what's called a "firewall include". On OpenWrt, a firewall include is a setting which tells firewall3 or firewall4 to do something specific in response to certain events.
- The only task of the init script for geoip-shell is to call the geoip-shell-mk-fw-include.sh script, which makes sure that the firewall include exists and is correct, if not then creates the include.
- The firewall include is what does the actual persistence work. geoip-shell firewall include triggers on firewall reload (which happens either at reboot or when the system decides that a reload of the firewall is necessary, or when initiated by the user).
- When triggered, the include script calls the -run script with the "restore" action.
- The -run script verifies that geoip nftables/iptables rules and ip sets exist, and if not then it restores them from backup, or (if backup doesn't exist) initiates re-fetch of the ip lists and then re-creates the rules and the ip sets.
- By default, geoip-shell does not create backups on OpenWrt because typically the permanent storage is very small and prone to wear.
- Automatic updates of ip lists on OpenWrt are triggered from a cron job like on other Linuxes.

## Defaults for OpenWrt
Generally the defaults are the same as for other systems, except:
- the data directory which geoip-shell uses to store the status file and the backups is by default in `/tmp/geoip-shell-data`, rather than in `/var/lib/geoip-shell` as on other Linux systems. This is to avoid flash wear. You can change this by running the install script with the `-a <path>` option, or after installation via the command `geoip-shell configure -a <path>`.
- the 'nobackup' option is set to 'true', which configures geoip-shell to not create backups of the ip lists. With this option, geoip-shell will work as usual, except after reboot (and for iptables-based systems, after firewall restart) it will re-fetch the ip lists, rather than loading them from backup. You can change this by running the -install script with the `-o false` option (`-o` stands for nobackup), or after installation via the command `geoip-shell configure -o false`. To have persistent ip list backups, you will also need to change the data directory path as explained above.
- if using geoip-shell on a router with just a few MB of embedded flash storage, consider either leaving the nobackup and datadir path defaults as is, or connecting an external storage device to your router (preferably formatted to ext4) and configuring a directory on it as your geoip-shell data directory, then enabling automatic backups. For example, if your external storage device is mounted on _/mnt/somedevice_, you can do all this via this command: `geoip-shell configure -a /mnt/somedevice/geoip-shell-data -o false`.
- the default ip lists source for OpenWrt is ipdeny (rather than ripe). While ipdeny is a 3rd party, they provide aggregated lists which consume less memory (on nftables-based systems the ip lists are automatically optimized after loading into memory, so there the source does not matter, but a smaller initial ip lists size will cause a smaller memory consumption spike while loading the ip list).

This is about it for this document. Much more information is available in the main [README.md](README.md) and in the extra _.md_ files inside the Documentation directory. If you have any questions, contact me in this thread:
https://forum.openwrt.org/t/geoip-shell-flexible-geoip-blocker-for-linux-now-supports-openwrt/189611

If you use this project, I will be happy to hear about your experience in the above thread. If for some reason geoip-shell is not working for you, I will want to know that as well so I can improve it.

