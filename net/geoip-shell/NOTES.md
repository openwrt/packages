## **Notes**
1) On OpenWrt, geoip-shell expects that the default shell (called by the `sh` command) is _ash_, and the automatic shell detection feature implemented for other platforms is disabled on OpenWrt.

2) Firewall rules structure created by geoip-shell:
    <details> <summary>Read more:</summary>

    ### **iptables**
    - With **iptables**, all firewall rules created by geoip-shell are in the table `mangle`. The reason to use `mangle` is that this table has a built-in chain called `PREROUTING` which is attached to the `prerouting` hook in the netfilter kernel component. Via a rule in this chain, geoip-shell creates one set of rules which applies to all ingress traffic for a given ip family, rather than having to create and maintain separate rules for chains INPUT and FORWARDING which would be possible in the default `filter` table.
    - This also means that any rules you might have in the `filter` table will only see traffic which is allowed by geoip-shell rules, which may reduce the CPU load as a side-effect.
    - Note that **iptables** features separate tables for ipv4 and ipv6, hence geoip-shell creates separate rules for each family (unless the user restricts geoip-shell to a certain family during installation).
    - Inside the table `mangle`, geoip-shell creates the custom chain `GEOIP-SHELL` and redirects traffic to it via a rule in the `PREROUTING` chain. geoip-shell calls that rule the "enable" rule which can be removed or re-added on-demand with the commands `geoip-shell on` and `geoip-shell off`. If the "enable" rule is not present, system firewall will act as if all other geoip-shell rules (for a given ip family) are not present.
    - If specific network interfaces were set during installation, the "enable" rule directs traffic to a 2nd custom chain `GEOIP-SHELL_WAN` rather than to the `GEOIP-SHELL` chain. geoip-shell creates rules in the `GEOIP-SHELL_WAN` chain which selectively direct traffic only from the specified network interfaces to the `GEOIP-SHELL` chain.
    - With iptables, geoip-shell removes the "enable" rule before making any changes to the ip sets and rules, and re-adds it once the changes have been successfully made. This is a precaution measure intended to minimize any chance of potential problems. Typically ip list updates do not take more than a few seconds, and on reasonably fast systems less than a second, so the time when geoip blocking is not enabled is typically very brief.

    ### **nftables**
    - With **nftables**, all firewall rules created by geoip-shell are in the table named `geoip-shell`, family "inet", which is a term nftables uses for tables applying to both ip families. The `geoip-shell` table includes rules for both ip families and any nftables sets geoip-shell creates. geoip-shell creates 2 chains in that table: `GEOIP-BASE` and `GEOIP-SHELL`. The base chain attaches to netfilter's `prerouting` hook and has a rule which directs traffic to the `GEOIP-SHELL` chain. That rule is the geoip-shell "enable" rule for nftables-based systems which acts exactly like the "enable" rule in the iptables-based systems, except it applies to both ip families.
    - **nftables** allows for more control over which network interfaces each rule applies to, so when certain network interfaces are specified during installation, geoip-shell specifies these interfaces directly in the rules inside the `GEOIP-SHELL` chain, and so (contrary to iptables-based systems) there is no need in an additional chain.
    - **nftables** features atomic rules updates, meaning that when issuing multiple nftables commands at once, if any command fails, all changes get cancelled and the system remains in the same state as before. geoip-shell utilizes this feature for fault-tolerance and to completely eliminate time when geoip blocking is disabled during an update of the sets or rules.
    - **nftables** current version (up to 1.0.8 and probably 1.0.9) has some bugs related to unnecessarily high transient memory consumption when performing certain actions, including adding new sets. These bugs are known and for the most part, already have patches implemented which should eventually roll out to the distributions. This mostly matters for embedded hardware with less than 512MB of memory. geoip-shell works around these bugs as much as possible. One of the workarounds is to avoid using the atomic replacement feature for nftables sets. Instead, when updating sets, geoip-shell first adds new sets one by one, then atomically applies all other changes, including rules changes and removing the old sets. In case of an error during any stage of this process, all changes get cancelled, old rules and sets remain in place and geoip-shell then destroys the new sets. This is less efficient but with current versions of nftables, this actually lowers the minimum memory bar for the embedded devices. Once a new version of nftables will be rolled out to the distros, geoip-shell will adapt the algorithm accordingly.

    ### **nftables and iptables**
    - With both **nftables** and **iptables**, geoip-shell goes a long way to make sure that firewall rules and ip sets are correct and matching the user-defined config. Automatic corrective mechanisms are implemented which should restore geoip-shell firewall rules in case they do not match the config (which normally should never happen).
    - geoip-shell implements rules and ip sets "tagging" to distinguish between its own rules and other rules and sets. This way, geoip-shell never makes any changes to any rules or sets which geoip-shell did not create.
    - When uninstalling, geoip-shell removes all its rules, chains and ip sets.

    </details>

3) geoip-shell uses RIPE as the default source for ip lists. RIPE is a regional registry, and as such, is expected to stay online and free for the foreseeable future. However, RIPE may be fairly slow in some regions. For that reason, I implemented support for fetching ip lists from ipdeny. ipdeny provides aggregated ip lists, meaning in short that there are less entries for same effective geoip blocking, so the machine which these lists are installed on has to do less work when processing incoming connection requests. All ip lists the suite fetches from ipdeny are aggregated lists.

4) The scripts intended as user interface are: **-install**, **-uninstall**, **-manage** (also called by running '**geoip-shell**' after installation) and **check-ip-in-registry.sh**. The -manage script saves the config to a file and implements coherence checks between that file and the actual firewall state. While you can run the other scripts individually, if you make changes to firewall geoip rules, next time you run the -manage script it may insist on reverting those changes since they are not reflected in the config file. The **-backup** script can be used individually. By default, it creates a backup of geoip-shell state after every successful action involving changes to or updates of the ip lists. If you encounter issues, you can use it with the 'restore' command to restore geoip-shell to its previous state. It also restores the config, so the -manage script will not mind.

5) How to manually check firewall rules created by geoip-shell:
    - With nftables: `nft -t list table inet geoip-shell`. This will display all geoip-shell rules and sets.
    - With iptables: `iptables -vL -t mangle` and `ip6tables -vL -t mangle`. This will report all geoip-shell rules. To check ipsets created by geoip-shell, use `ipset list -n | grep geoip-shell`. For a more detailed view, use this command: `ipset list -t`.

6) The run, fetch and apply scripts write to syslog in case an error occurs. The run and fetch scripts also write to syslog upon success. To verify that cron jobs ran successfully, on Debian and derivatives run `cat /var/log/syslog | grep geoip-shell`. On other distributions, you may need to figure out how to access the syslog.

7) These scripts will not run in the background consuming resources (except for a short time when triggered by the cron jobs). All the actual blocking is done by the netfilter component in the kernel. The scripts offer an easy and relatively fool-proof interface with netfilter, config persistence, automated ip lists fetching and auto-update.

8) Sometimes ip list source servers are temporarily unavailable and if you're unlucky enough to attempt installation during that time frame, the fetch script will fail which will cause the installation to fail as well. Try again after some time or use another source. Once the installation succeeds, an occasional fetch failure during autoupdate won't cause any issues as last successfully fetched ip list will be used until the next autoupdate cycle succeeds.

9) How to geoblock or allow specific ports (applies to the _-install_ and _-manage_ scripts).
    The general syntax is: `-p <[tcp|udp]:[allow|block]:[all|<ports>]>`
    Where `ports` may be any combination of comma-separated individual ports or port ranges (for example: `125-130` or `5,6` or `3,140-145,8`).
    You can use the `-p` option twice to cover both tcp and udp, for example: `-p tcp:allow:22,23 -p udp:block:128-256,3`

    Examples with the -install script:

    `sh geoip-shell-install -c de -m whitelist -p tcp:allow:125-135,7` - for tcp, allow incoming traffic on ports 125-135 and 7, geoblock incoming traffic on other tcp ports (doesn't affect UDP traffic)

    `sh geoip-shell-install -c de -m blacklist -p udp:allow:3,15-20,1024-2048` - for udp, allow incoming traffic on ports 15-20 and 3, geoblock all other incoming udp traffic (doesn't affect TCP traffic)

    Examples with the -manage script (also called via 'geoip-shell' after installation) :

    `geoip-shell configure -p tcp:block:all` - for tcp, geoblock all ports (default behavior)

    `geoip-shell configure -p udp:allow:all` - for udp, don't geoblock any ports (completely disables geoblocking for udp)

    `geoip-shell configure -p tcp:block:125-135,7` - for tcp, only geoblock incoming traffic on ports 125-135 and 7, allow incoming traffic on all other tcp ports

10) How to remove specific ports assignment:

    use `-p [tcp|udp]:block:all`.

    Example: `geoip-shell configure -p tcp:block:all` will remove prior port-specific rules for the tcp protocol. All tcp packets on all ports will now go through geoip filter.

11) How to make all packets for a specific protocol bypass geoip blocking:

    use `p [tcp|udp]:allow:all`

    Example: `geoip-shell configure -p udp:allow:all` will allow all udp packets on all ports to bypass the geoip filter.

12) Firewall rules persistence, as well as automatic list updates, is implemented via cron jobs: a periodic job running by default on a daily schedule, and a job that runs at system reboot (after 30 seconds delay). Either or both cron jobs can be disabled (run the *install script with the -h option to find out how, or read [DETAILS.md](DETAILS.md)). On OpenWrt, persistence is implemented via an init script and a firewall include rather than via a cron job.

13) You can specify a custom schedule for the periodic cron job by passing an argument to the install script. Run it with the '-h' option for more info.

14) If you want to change the autoumatic update schedule but you don't know the crontab expression syntax, check out https://crontab.guru/ (no affiliation). geoip-shell includes a script which validates cron expressions you request, so don't worry about making a mistake.

15) Note that cron jobs will be run as root.

16) If you have nftables installed but for some reason you are using iptables rules (via the nft_compat kernel module which is provided by packages like nft-iptables etc), you can and probably should install geoip-shell with the option `-w ipt` which will force it to use iptables+ipset. For example: `geoip-shell install -w ipt`.

17) If you upgrade your system from iptables to nftables, you can either re-install geoip-shell and it will then automatically use nftables, or you can use this command without reinstalling: `geoip-shell configure -w nft`, which will remove all iptables rules and ipsets and re-create nftables rules and sets based on your existing config. If you are on OpenWrt, this does not apply: instead, you will need to install the geoip-shell package for nftables-based OpenWrt.

18) To test before deployment:
    <details> <summary>Read more:</summary>

    - You can run the install script with the "-N true" (N stands for noblock) option to apply all actions and create all firewall rules except the geoip-shell "enable" rule. This way you can make sure that no errors are encountered and check the resulting firewall rules before committing to actual blocking. To enable blocking later, use the command `geoip-shell on`.
    - You can run the install script with the "-n true" (n stands for nopersistence) option to skip creating the reboot cron job which implements persistence and with the '-s disable' option to skip creating the autoupdate cron job. This way, a simple machine restart should undo all changes made to the firewall (unless you have some software which restores firewall settings after reboot). For example: `sh geoip-shell-install -c <country_code> -m whitelist -n true -s disable`. To enable persistence and automatic updates later, reinstall without both options.

    </details>

19) How to get yourself locked out of your remote server and how to prevent this:
    <details> <summary>Read more:</summary>

    There are 4 scenarios where you can lock yourself out of your remote server with this suite:
    - install in whitelist mode without including your country in the whitelist
    - install in whitelist mode and later remove your country from the whitelist
    - blacklist your country (either during installation or later)
    - your remote machine has no dedicated WAN interfaces (it is behind a router) and you incorrectly specified LAN subnets the machine belongs to

    As to the first 3 scenarios, the -manage script will warn you in each of these situations and wait for your input (you can press Y and do it anyway), but that depends on you correctly specifying your country code during installation. The -install script will ask you about it. If you prefer, you can skip by pressing Enter - that will disable this feature. If you do provide the -install script your country code, it will be added to the config file on your machine and the -manage script will read the value and perform the necessary checks, during installation or later when you want to make changes to the blacklist/whitelist.

    As to the 4th scenario, geoip-shell implements LAN subnets automatic detection and asks you to verify that the detected LAN subnets are correct. If you are not sure how to verify this, reading the [SETUP.md](SETUP.md) file should help. Read the documentation, follow it and you should be fine. If you specify your own LAN ip addresses or subnets (rather than using the automatically detected ones), geoip-shell validates them, meaning it makes sure that they appear to be valid by checking them with regex, and asking the kernel. This does not prevent a situation where you provide technically valid ip's/subnets which however are not actually used in the LAN your machine belongs to. So double-check. Also note that LAN subnets **may** change in the future, for example if someone changes some config in the router or replaces the router etc. For this reason, when installing the suite for **all** network interfaces, the -install script offers to enable automatic detection of LAN subnets at each periodic update. If for some reason you do not enable this feature, you will need to make the necessary precautions when changing LAN subnets your remote machine belongs to.

	As an additional measure, during installation you can specify trusted ip addresses anywhere on the Internet which will not be geoblocked, so in case something goes very wrong, you will be able to regain access to the remote machine. This does require to have a known static public ip address or subnet. To specify ip's, call the install script with this option: `-t <"[trusted_ips]">`.

    </details>
