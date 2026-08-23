<!-- markdownlint-disable -->

# shunt - policy based routing by mac, source, destination and domain

## Table of Contents
* [Description](#description)
* [Quick Start](#quick-start)
* [Main Features](#main-features)
* [Prerequisites](#prerequisites)
  * [Which tunnels work](#which-tunnels-work)
* [Installation and Usage](#installation-and-usage)
* [shunt CLI interface](#shunt-cli-interface)
* [shunt config options](#shunt-config-options)
* [How addresses are learned](#how-addresses-are-learned)
  * [What polling costs](#what-polling-costs)
* [Examples](#examples)
* [What it shells out to](#what-it-shells-out-to)
* [What shunt creates on the system](#what-shunt-creates-on-the-system)
* [Coexistence with pbr and mwan3](#coexistence-with-pbr-and-mwan3)
* [Troubleshooting & debug options](#troubleshooting-and-debug-options)
* [Known limitations](#known-limitations)
* [Support](#support)
* [Removal](#removal)
* [Donations](#donations)

<a id="description"></a>
## Description
shunt routes selected traffic into a policy interface - a VPN tunnel, a second uplink, a mobile connection - chosen by client address, client MAC, destination or domain. It keeps its own nftables table and one routing table per policy, so it coexists with fw4 and with other routing tools instead of competing with them.

The one thing that defines the project: **shunt is not bound to any DNS backend.** It works unchanged with dnsmasq, unbound, smartdns, AdGuard Home or anything else, because it never asks the resolver for anything and never sits in the DNS path. Domain to address mapping comes from two sources shunt owns itself, described under [How addresses are learned](#how-addresses-are-learned).

<a id="quick-start"></a>
## Quick Start
For a typical setup these few steps are enough - see the sections below for details:
1. Install the LuCI companion package: `apk update && apk add luci-app-shunt` (this pulls in the `shunt` backend as a dependency).
2. Make reverse path filtering loose and give the policy interface a masquerading firewall zone - both once, both shown under [Prerequisites](#prerequisites). Without the first, marked traffic is dropped; without the second it is marked and routed and then goes nowhere, which looks exactly like shunt not working.
4. Open LuCI under `Services -> shunt`, add a policy on the `Policies` tab: pick the `Interface`, name the clients under `Source addresses` or `Source MAC addresses`, and list the `Domains` you want routed.
5. Start and verify:

```sh
/etc/init.d/shunt enable
/etc/init.d/shunt start
shunt check
```

**Please note:** a domain policy only takes effect for a client's *next* connection to an address that has just been learned - see [Known limitations](#known-limitations).

<a id="main-features"></a>
## Main Features
* Routes by client address, client MAC, destination CIDR and domain, in any combination
* Resolver independent: works with any DNS backend, and with an encrypted upstream, because it reads the plaintext leg between client and resolver
* Wildcard domains (`*.example.com`), learned passively as clients use them
* Per-policy killswitch: hold the traffic when the interface drops, instead of leaking it out of the normal uplink
* Own nftables table and routing tables, disjoint mark range - runs beside `pbr` and `mwan3`
* IPv4 and IPv6 throughout, with a MAC selecting a host in both at once
* Per-element counters on every set, a ubus status object and a LuCI frontend
* No dependency on a specific DNS backend, no resolver configuration, no include files, no hooks into fw4's ruleset

<a id="prerequisites"></a>
## Prerequisites
* OpenWrt with fw4/nftables
* `ucode` plus `ucode-mod-fs`, `ucode-mod-socket`, `ucode-mod-uci`, `ucode-mod-uloop`, `ucode-mod-resolv`, `ucode-mod-ubus`, `ucode-mod-rtnl`, `ucode-mod-log` and `rpcd-mod-ucode` - all pulled in by the package

`ucode-mod-resolv` and `ucode-mod-ubus` are soft at runtime: without resolv, poll is skipped and the observer carries the service alone; without ubus, gateway discovery and interface events are skipped and the config's own values are used. Both cost one warning in the log, not a failed start.

<a id="which-tunnels-work"></a>
### Which tunnels work

Any of them, and there is no supported-protocols list to check against, because shunt never asks what protocol an interface speaks. It consumes two things: the device to route into, and a gateway if one is needed. Both come from netifd, and a device netifd does not manage is taken as given.

* **Point to point tunnels** - wireguard, OpenVPN `tun*`, L2TP, PPTP, Tailscale, NetBird and the like - need no gateway at all. The route is `default dev <device> table <n>`.
* **Ethernet style interfaces** - OpenVPN `tap*`, a second wired uplink, a mobile connection - use the gateway discovered from netifd, or `gw4`/`gw6` if you set them.
* **Interfaces netifd does not manage** work by name too. On OpenWrt this is the exception rather than the rule - wireguard, OpenVPN, L2TP and the rest all have netifd protocols and are managed like any other interface. It applies to a tunnel brought up outside netifd, by `wg-quick` or a script of your own. If such an interface does need a gateway, discovery cannot find one and you have to set `gw4`/`gw6` yourself.

The one thing that does not work is anything that is not a routable interface. Tor is the usual example: it normally offers a SOCKS port, and sending traffic there is a redirect, not a route. shunt marks a packet and looks up a routing table; without a device to put a default route on, there is nothing for it to do. Transparent proxying is out of scope by design, not for want of a special case.

Two kernel-side prerequisites. shunt never changes either one behind your back - the first can be handed to shunt explicitly (`rp_filter_manage`, below), the second stays with fw4:

**`rp_filter` must be loose on the policy interface.** Marked traffic takes an asymmetric path, so strict reverse path filtering drops it. The kernel decides per incoming packet using `max(net.ipv4.conf.all.rp_filter, net.ipv4.conf.<dev>.rp_filter)`, where `2` is loose - so setting the policy interface alone to `2` suffices even while `all` stays strict. Prefer this: it leaves reverse path filtering intact on every other interface.

```sh
cat > /etc/sysctl.d/99-shunt.conf <<'EOF'
net.ipv4.conf.phy0-sta0.rp_filter=2
EOF
sysctl -p /etc/sysctl.d/99-shunt.conf
```

Replace `phy0-sta0` with your policy interface's device - the `Interface` column on the overview shows it - one line per policy device.

There is a boot-order catch. A device that does not exist yet - a tunnel, or a wifi client interface brought up late - has no `conf/<dev>` entry at boot, so `sysctl -p` cannot set it and skips the line. When the device finally appears it inherits `net.ipv4.conf.default.rp_filter`, and if that is strict the device comes up strict and stays that way until the next `sysctl -p` - which for most setups means until the next reboot, i.e. never in practice. Two ways around it: set `net.ipv4.conf.default.rp_filter=2` as well, which makes every later-appearing interface inherit loose (a little broader, but far short of `all`), or let shunt handle it with the option below.

**`rp_filter_manage` (optional, off by default).** With it set, shunt itself sets `rp_filter=2` on its own policy devices - at start and again whenever one comes up, which is exactly the boot-order moment a static file misses. It only ever touches the devices shunt routes into, never `all` or `default`, and only while the service runs. It is off by default because changing a security setting should be a deliberate choice:

```sh
uci set shunt.@global[0].rp_filter_manage='1'
uci commit shunt
/etc/init.d/shunt restart
```

Whichever way you choose, the daemon checks the live per-device values - at start and again whenever a policy interface comes up - and warns, naming the device, only when a policy device exists and is still strict. A device that is not there yet carries no traffic and triggers no warning; it is checked the moment it appears. With `rp_filter_manage` on the warning therefore simply does not appear - not because the switch is set, but because the values read back are actually loose. With `all` at `2` (or `0`) nothing is ever reported. The package deliberately ships no box-wide sysctl file: `rp_filter` on `all`/`default` is a distribution default OpenWrt sets strict in `/etc/sysctl.d/10-default.conf`, and loosening it there weakens anti-spoofing on every interface, well beyond shunt's own traffic.

**Masquerading stays fw4's job.** shunt marks and routes; it does not touch the firewall's NAT. The policy interface needs a zone with `masq` enabled and forwarding from `lan`, exactly as any other uplink. If the interface is a netifd one - say a wireguard interface named `vpn`:

```sh
uci add firewall zone
uci set firewall.@zone[-1].name='vpn'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci add_list firewall.@zone[-1].network='vpn'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpn'

uci commit firewall
/etc/init.d/firewall reload
```

`network` names a **logical interface**, not a device. For a device netifd does not manage - a tunnel brought up outside netifd - use `uci add_list firewall.@zone[-1].device='wg0'` instead. And if the policy interface already has a zone, because it is an ordinary second uplink, there is nothing to do here.

Symptoms of getting this wrong are worth knowing, because they do not look like a firewall problem: the prerouting counters rise, `nft list set` shows the learned address being hit, and the client's connection simply times out.

<a id="installation-and-usage"></a>
## Installation and Usage
* Update your router's apk repository (`apk update`)
* Install the LuCI companion package `luci-app-shunt`, which also installs the main `shunt` package as a dependency
* Make `rp_filter` loose and give the policy interface a masquerading firewall zone - both are one-time steps with copy-paste commands under [Prerequisites](#prerequisites)
* Configure at least one policy, either in LuCI under `Services -> shunt` or by editing `/etc/config/shunt`
* Enable and start the service, then run `shunt check` - it prints the mark, routing table and rule priority of every accepted policy, and every rejected value with its reason
* Check the `Set Reporting` tab to see which addresses were learned, and the `Processing Log` tab for the service's own messages

<a id="shunt-cli-interface"></a>
## shunt CLI interface
All functions are available from the command line, and the config file can be edited directly if you prefer that to LuCI.

```sh
shunt check        # render everything, print marks and issues, change nothing
shunt run          # foreground, the procd service entry point
shunt flush        # tear down table, rules, routes and the mapping file
shunt -v <cmd>     # echo every message to the terminal as well
```

`shunt check` is safe at any time, including while the service runs, because it only renders - it never touches the kernel. Run it after every config change. Note that it says nothing about whether the service is *running*; that is what `/etc/init.d/shunt status` and the LuCI overview are for.

Exit codes: 0 ok, 1 runtime failure, 2 usage or unusable config.

Logging goes to syslog under the tag `shunt`, so `logread -e shunt` shows everything - the daemon's own lines carry its pid, `shunt[1234]:`. Debug lines stay off unless `-v` is given or `option debug '1'` is set - under procd there is no command line, so a bug report needs the config switch. Expect volume: on a router running adblock roughly half of all observed answers are error replies, and debug gives each one a line.

`shunt flush` is the escape hatch if the daemon ever dies without tearing down. It is idempotent and safe on a box that never ran shunt.

<a id="shunt-config-options"></a>
## shunt config options

### Global section

| Option | Default | Description |
| :--- | :--- | :--- |
| enabled | `1` | master switch; `0` means the service starts and exits |
| debug | `0` | log every observed answer and every set write |
| rp_filter_manage | `0` | set rp_filter=2 on shunt's own policy devices, at start and on ifup |
| poll_interval | `300` | seconds between poll cycles, at least 30 |
| entry_ttl | `1200` | nftables timeout on learned elements, at least 60 |
| snoop | `1` | enable the passive DNS observer |
| snoop_device | `br-lan` | LAN devices to observe, a list, one entry per segment |

Values below the minimum are clamped, not rejected, and the clamp is logged. `entry_ttl` should stay well above `poll_interval` - an element is rewritten once its remaining timeout drops below half of `entry_ttl`, so the default pair refreshes comfortably within two poll cycles.

### Policy sections

Each `config policy` section is one routing policy. **The section must be named, and the name must match `[A-Za-z0-9_]{1,24}`** - it becomes an nftables identifier, so a section without a name, or one with a hyphen or a dot in it, is rejected as an issue and never rendered. LuCI enforces the same pattern when a policy is added.

| Option | Description |
| :--- | :--- |
| enabled | `0` skips the section entirely |
| interface | netifd logical name (`wan`, `trm_wwan`) or raw netdev (`wg0`, `phy0-sta0`) |
| fallback | `main` (default) or `block`, see below |
| gw4 / gw6 | gateway override; normally unnecessary |
| src | client addresses or CIDRs whose traffic this policy owns |
| src_mac | client MAC addresses, ORed with `src` |
| proto | `tcp`, `udp`, or both; a port without one covers both |
| dport | destination ports, single or a range like `8000-8080` |
| dst | destination addresses or CIDRs |
| domain | domain patterns, see below |

`src`, `src_mac`, `dst` and `domain` are lists and may repeat.

Interfaces are resolved through netifd: a logical name resolves to its `l3_device`, a raw netdev is adopted if netifd knows it, and a device netifd knows nothing about passes through as given - which on OpenWrt means a tunnel started outside netifd, since wireguard and the other tunnel types have netifd protocols of their own. Gateways are discovered from the same dump, merged across sibling entries, because netifd splits families. `gw4`/`gw6` override discovery and always win; on a point to point interface no gateway is needed at all.

There is deliberately no list of supported tunnel protocols. shunt asks netifd for the device and the gateway and renders a default route into the policy table - `default via <gw> dev <device>` when a gateway is known, `default dev <device>` when none is needed. Wireguard, OpenVPN in both `tun` and `tap` mode, L2TP, PPTP, Tailscale, NetBird, a second physical uplink or a mobile connection all reduce to those two shapes, so none of them needs a case of its own. See [Which tunnels work](#which-tunnels-work) for the one thing that genuinely does not fit.

### Selectors are ANDed, client selectors OR each other

* `src` or `src_mac` alone marks everything from those clients
* `dst`, `domain`, `dport` or `proto` alone marks that traffic from everyone
* clients plus destinations marks only those clients' traffic to those destinations

`dport` and `proto` AND with everything else, so a policy with a client, a domain and `dport 443` covers that client's HTTPS traffic to that domain and nothing more. A port without a protocol matches **both** tcp and udp - "port 443" almost always means QUIC too, and requiring the protocol would let it slip through unnoticed. If ports or protocols were configured and none of them is usable, the policy is skipped rather than rendered without the narrowing.

This is the single most common source of "it did not work" reports: with a client and a domain both set, a generic `curl ifconfig.me` from that client correctly takes the normal uplink, because `ifconfig.me` is not in the domain list. That is the policy working, not failing.

A client MAC and a client address OR each other, so a host may be named either way. If client selectors were configured and **none** of them is usable - a typo in the only address, say - the policy is skipped with an issue rather than falling back to "every client", which is what an absent client selector otherwise means.

### Selecting clients by MAC

`src_mac` exists mainly for IPv6. Clients prefer rotating privacy addresses for outgoing traffic, so a single IPv6 address is not a usable selector and the LAN prefix covers every host in the segment. A MAC picks exactly one host, in both address families, and keeps doing so when the addresses change. A policy with only `src_mac` therefore needs no v6 address to route v6.

Three limits, none of them guessable:

* **Same layer 2 segment only.** Anything behind another router arrives with that router's MAC.
* **Never the router itself.** The `output` chain sees traffic the router generated, which has no ethernet sender, so MAC rules are not installed there. An address based policy does cover the router; a MAC-only one does not.
* **Phones randomise their MAC**, though usually stable per network. Use the address the client shows in your DHCP leases, not the one on the label.

### Domain patterns

```
example.com      matches the apex only
*.example.com    matches subdomains only, at any depth, NOT the apex
```

List both to cover both. This is more typing than dnsmasq's implicit subdomain inclusion, and it is deliberate: dnsmasq's behaviour surprises people regularly, this one does not.

Precedence, in order:

1. an exact match always beats any wildcard
2. among wildcards the longest suffix wins, so `*.cdn.example.com` beats `*.example.com` regardless of which policy declared them
3. the same pattern in two policies belongs to **both**

Rule 3 is what makes one domain usable by two client groups over two different uplinks: the address is written into each policy's set, and each policy's rule matches only its own clients, so they stay apart. Rules 1 and 2 still decide specificity - a shared `*.example.com` never overrides somebody's exact `www.example.com`.

Matching is label aligned, never string suffix: `evilexample.com` does not match `*.example.com`. A bad pattern is collected as an issue, never fatal.

### Policy precedence

Section order in `/etc/config/shunt`, top to bottom. There is no `priority` option - one less value to set wrong. A packet matching two policies takes the earlier one; rule evaluation ends at the first match.

Note that domain precedence is resolved *before* this, at the matcher: the most specific pattern wins even if it sits in a later section.

### Fallback: main or block

`fallback 'main'` (default) renders no default route into the policy table, so when the policy interface is down the table is empty and marked traffic falls through to `main` - the normal uplink. Traffic keeps flowing, unpolicied.

`fallback 'block'` adds a blackhole default at metric 9999 to the policy table. While the interface is up its own default has the lower metric and wins; when the interface drops, the kernel withdraws that route and the blackhole catches everything. That is the killswitch: traffic belonging to the policy stops rather than leaking out of the wrong interface.

<a id="how-addresses-are-learned"></a>
## How addresses are learned
Two sources feed the same nftables sets, union with an element timeout. They are complementary, not alternative modes.

* **poll** resolves the configured names through whatever system resolver exists, on a fixed interval. It warms the sets before the first client packet, so first contact does not race. Wildcards are not names and cannot be polled.
* **snoop** passively observes DNS responses on the LAN side via AF_PACKET with a BPF filter matching **UDP source port 53** - answers, not questions - including one level of VLAN tagging. It covers CDN variance and wildcards, which poll cannot. It reads; it never writes anything back onto the wire and never sits between a client and its resolver. If it dies, DNS keeps working and only the policy stops applying.

<a id="what-polling-costs"></a>
### What polling costs

"Polling" invites the assumption of waste, so here is the arithmetic. One cycle is a single call asking for A and AAAA of every listed name: two lookups per name per interval, against the **local** resolver. Ten names at the default 300 seconds is 240 lookups an hour - about what a dozen web page loads cost, on a network whose own DNS traffic runs to hundreds of answers in a few minutes. There is no polling of anything else: no interface scanning, no ruleset re-rendering, no periodic writes. An element is only rewritten when its remaining lifetime has dropped below half.

Two costs worth knowing:

* The query is synchronous. A name that does not resolve blocks the cycle until it times out (2s, one retry), which delays the service start noticeably if several are wrong. This is why an unresolvable name is reported by name.
* For names with a TTL shorter than the interval the local cache has expired, so poll does refetch upstream rather than answering from cache.

What that means in practice:

* **Pick the device the answers cross on their way to the clients**, normally `br-lan`. It must be an **Ethernet type** device - a bridge, a VLAN device, a physical port, a wireless interface. A tunnel or PPP interface has no ethernet header, so neither the packet filter nor the decoder can read it, and the failure is silent: nothing matches, nothing is logged.
* **Only the client-to-resolver leg matters, and only whether *it* is encrypted.** What the resolver does upstream is irrelevant: the usual OpenWrt setup - unbound or dnsmasq on the router, forwarding upstream over DoT or DoH
  - is fully covered, because the client asked in plain text over the LAN and the answer comes back the same way.
* **A client that speaks DoH or DoT itself is invisible**, because it bypasses the local resolver. That is the one encryption case that costs coverage.
* **One entry per layer 2 segment.** A guest or IoT VLAN on its own device never carries the answers of the main LAN, so it needs its own `snoop_device` entry. A device that cannot be opened costs one warning; the others keep running.
* **The router's own lookups are not seen.** poll's queries leave through the uplink, not the LAN device.
* Not seen either: DNS over TCP, DNS on a port other than 53, and a second stacked VLAN tag.

A name in a `domain` list that never resolves is reported once, by name and policy:

```
poll: www.example.com (policy vpn) has no address - the policy entry has no effect until it resolves
```

Once on the way in and once on recovery, never in between. The first cycle runs immediately at start, so a typo shows up within seconds. Wildcards cannot produce this message - nothing can tell whether `*.example.com` was ever meant to match anything.

<a id="examples"></a>
## Examples

**One client, one domain family, over a wireguard tunnel**

```
config policy 'vpn'
	option enabled   '1'
	option interface 'wg0'
	option fallback  'main'
	list  src        '192.168.1.50'
	list  domain     'example.com'
	list  domain     '*.example.com'
```

**A whole IoT VLAN over a mobile uplink, killswitch on**

The client is named by MAC, so it is covered in both address families without listing a rotating IPv6 address:

```
config global
	list  snoop_device 'br-lan'
	list  snoop_device 'br-iot'

config policy 'iot'
	option enabled   '1'
	option interface 'trm_wwan'
	option fallback  'block'
	list  src_mac    'aa:bb:cc:dd:ee:ff'
	list  domain     '*.vendor-cloud.com'
```

**The same domain for two client groups over two uplinks**

Both policies claim `www.example.com`; each routes only its own clients:

```
config policy 'wwan'
	option interface 'trm_wwan'
	list  src        '10.168.30.70'
	list  domain     'www.example.com'

config policy 'vpn'
	option interface 'wg0'
	list  src        '10.168.1.20'
	list  domain     'www.example.com'
```

**A destination range without any domain**

```
config policy 'office'
	option interface 'wg0'
	list  src        '192.168.1.0/24'
	list  dst        '10.0.0.0/8'
```

<a id="what-it-shells-out-to"></a>
### What it shells out to

Almost nothing. The daemon and the rpcd backend work through ucode's native bindings - `fs`, `socket` for the AF_PACKET observer, `uci`, `uloop`, `ubus`, `resolv`, `rtnl` and `log` - and rpcd carries the LuCI side, so there is no shell glue, no `awk`, no temporary state files. Logging goes to syslog through the binding, not through a `logger` process per line.

Two external commands remain:

| Command | Why |
| :--- | :--- |
| `nft` | the ruleset is applied and read as one atomic batch; ucode has no nftables binding |
| `ip` | routes and rules are written this way, although `rtnl` already reads them - replaceable |

Nothing is ever handed to a shell for parsing: `system()` takes an argument array, and where stderr has to be captured the wrapper is `sh -c 'exec "$0" "$@"'`, which passes arguments through untouched. `popen()` only ever runs fixed command lines - `nft -f -` in the daemon and `nft -j list table` in the rpcd backend - so no configuration value or captured data reaches a command line.

<a id="what-shunt-creates-on-the-system"></a>
## What shunt creates on the system

```
table inet shunt                     own table, survives fw4 reloads
  chain prerouting                   filter hook prerouting, priority mangle
  chain output                       route hook output, priority mangle
  set d4_<policy> / d6_<policy>      learned, flags timeout, per-element counter
  set s4_<policy> / s6_<policy>      static dst, flags interval, counter
  set c4_<policy> / c6_<policy>      client src selectors, interval, counter
  set m_<policy>                     client MACs, no family digit, counter

fwmark                               <index> << 24, mask 0xff000000
ip rule pref                         31000 + <index>
routing table                        8000 + <index>
/etc/iproute2/rt_tables.d/shunt.conf the table name mapping
```

The mark mask is fixed at `0xff000000`, which allows 255 policies. The `output` chain is `type route` so the router's own marked traffic is re-routed after the mark is set.

Every set carries per-element counters, so "is this element ever hit" is one look at `nft list set inet shunt <set>` rather than a tcpdump session. The two kinds count different things: nftables tests a rule left to right, so a **client** set counts every packet that matched the selector, whether or not the destination matched afterwards; a **learned** set is the last lookup in the rule, so a hit there means the packet really was marked. A busy client beside learned addresses at zero is a client that has not visited any of the routed domains, not a fault.

**Writes are batched, and the interval adapts.** `nft -f` reads the entire ruleset from the kernel before it resolves a single name, so on a box that also runs a tool with very large sets - banIP with 238k elements, measured - one `add element` costs seconds of CPU, and `nft --check` alone costs the same. That is a known bug in nftables (netfilter bugzilla #1735, open since 2024), not something shunt can fix, so observed addresses are collected and applied together by a timer.

The interval follows what the last write actually cost, between 2 and 60 seconds: on an ordinary box a write takes milliseconds and the interval stays at its floor, where the batching is invisible. Where it is expensive the interval grows until nftables takes a bounded share of the machine instead of all of it, at the price of a learned address reaching its set later. Both numbers show up under `debug`.

**A reload wipes learned state.** Applying the configuration destroys and re-creates the table atomically, so the learned sets start empty. poll rewarms them within one interval and snoop refills from live traffic; expect a short window after a restart where domain policies do not apply yet.

<a id="coexistence-with-pbr-and-mwan3"></a>
## Coexistence with pbr and mwan3
shunt is an independent implementation, not a fork of `pbr` and not a drop-in for it - there is no config migration and no attempt at feature parity. Within its scope it is a full alternative.

Running both at once during a migration is safe by construction:

| | pbr | mwan3 | shunt |
| :--- | :--- | :--- | :--- |
| fwmark mask | `0x00ff0000` | `0x00003f00` | `0xff000000` |
| ip rule pref | 30000 counting down | ~1001-3250 | 31000 counting up |
| routing tables | dynamic from ~256 | 1-250 | 8000+n |
| nft | chains in fw4's table | | own `inet shunt` table |

The mark bits are disjoint and all three mask their writes. Where pbr and shunt both match, pbr's lower rule priority wins, deterministically. So move policies over one at a time and retire pbr once its config is empty.

Anything shunt cannot see is worth knowing about: marks set via `SO_MARK` on a daemon socket (OpenVPN's `--mark`) or by an eBPF program are invisible to any inspection. If a box uses those, check the mark ranges by hand.

<a id="troubleshooting-and-debug-options"></a>
## Troubleshooting & debug options

### Did the policy actually match?

The authoritative check needs no route lookups at all:

```sh
nft reset counters table inet shunt
# generate traffic from the client
nft list chain inet shunt prerouting        # rule counters moved?
tcpdump -ni <policy-interface> host <addr>  # the flow leaves where it should
```

The wire capture is ground truth - but capture a **learned address**, not everything: on a router whose policy interface is also a normal uplink, an unfiltered capture shows traffic that has nothing to do with shunt. An IP echo service is a convenient confirmation, but it only discriminates uplinks that actually have different exits.

The route lookup variant asks the kernel directly:

```sh
ip route get <addr> mark 0x1000000
ip route get <addr>
```

The first answer must name the policy table, the second the normal uplink.

**The first line needs iproute2's `ip`**, because BusyBox's `route get` does not understand `mark` - one build rejects it outright, the OpenWrt one sends an incomplete netlink request that the kernel answers with `EINVAL`. shunt's `ip` dependency (`ip-tiny`) covers it: `route` and `rule` are complete there, the tiny build only strips exotic objects. The second line, without a mark, works with BusyBox too.

Adding `from <client> iif br-lan` makes the lookup more precise, with one further catch worth a confused test session: **`iif` is not optional** there. Without it, `from` a non-local address makes the kernel validate a locally originated lookup and answer `ENETUNREACH` regardless of any table's content, which reads like broken routing and is not.

### What the observer discards, and why

Most DNS answers on a network are of no use to a routing policy, so snoop counts what it discarded and why. `ubus call shunt status` reports those counters, and the LuCI overview shows them with readable labels.

| Verdict | Meaning |
| :--- | :--- |
| qtype | the question was not for an address at all |
| noaddr | an address was asked for, the answer carried none |
| nomatch | the name belongs to no policy |
| dns:E_* | the message did not parse, e.g. `E_RCODE` for NXDOMAIN |
| frame:E_* | the packet did not decode, e.g. `E_FRAG` for a fragment |

`qtype` is usually the largest category and that is expected: current browsers and operating systems ask for **HTTPS records (type 65)** alongside every A and AAAA. `noaddr` is the other half of that distinction: the question *was* A or AAAA, the reply is well formed, and the answer section still holds no address - NODATA.

The checks run in order and the **first** one wins, so these are "first reason to discard" rather than independent counters: a PTR query for a name you route counts as `qtype`, never as `nomatch`.

A high discard count is therefore not a fault. The one number that says whether the observer is doing its job is the matched count next to them.

### When a policy stops applying after a reconnect

The kernel removes routes from a policy table when the interface goes down, after which the fwmark rule falls through to `main` while every counter keeps counting. shunt handles this on two levels: a ubus listener on `network.interface` rebuilds the route half on ifup/ifdown, and every poll tick replays the route commands as a keeper. Learned sets survive both. If ubus is unavailable, only the keeper remains, so recovery takes up to one `poll_interval`.

### Debug logging

```sh
uci set shunt.@global[0].debug='1'
uci commit shunt
/etc/init.d/shunt restart
logread -e shunt
```

Set it back to `0` afterwards. Every observed answer and every set write gets a line, which on a busy network is a lot.

<a id="known-limitations"></a>
## Known limitations
These are consequences of the design, stated rather than worked around:

* **Clients that speak DoH or DoT themselves are invisible to snoop.** poll still covers the names you list explicitly; wildcards do not work for those clients. A *resolver* forwarding upstream over DoT or DoH changes nothing.
* **Wildcards require snoop.** poll can only resolve names it was given, and `*.example.com` is not a name.
* **One CDN address serves many domains.** If a policy routes `example.com` and the address behind it also serves a thousand other sites, those sites follow the same policy. This is unsolvable at layer 3 by anything that routes on addresses.
* **The first connection to a newly seen address takes the old path.** snoop learns from the response the client is reading at that moment, so the client's SYN is usually out before the element reaches the set. Measured on a live router: the entire first connection stayed on the normal uplink, and the next connection to the same host started on the policy interface. The switch happens at a connection boundary; shunt does not touch conntrack, so no established flow is ever yanked to a different exit mid-stream. Listing the entry point explicitly closes the gap, because poll warms it before any client asks.
* **DNS over TCP is not observed.** Port 53 over TCP needs reassembly, which is out of scope; answers large enough to force TCP are rare in the traffic shunt cares about.
* **Route and rule application is best effort.** At boot a tunnel interface may not exist yet. A rule over an empty table falls through to `main`, so the failure mode is "policy not applied yet", never "traffic broken". Each distinct reason is one warning line.
* **No interface hotplug.** A device that appears later is picked up on the next `ifup` event or within one poll interval, not immediately.

**Out of scope permanently:** resolver-integrated set population (dnsmasq `nftset`, AdGuard Home etc.). Being independent of the DNS backend is the entire point of the project, so adopting a backend-specific mechanism would give up the one property that distinguishes it. Also out: DSCP tagging and user include files.

<a id="support"></a>
## Support
Please report issues with as much detail as possible - the output of `shunt check`, the relevant part of `logread -e shunt` with `debug` enabled, your `/etc/config/shunt`, and the OpenWrt version of the device. Please join the shunt discussion in this [forum thread](https://forum.openwrt.org/t/shunt-policy-based-routing-for-any-dns-backend/252748) or contact me by mail <dev@brenken.org>.

<a id="removal"></a>
## Removal
Stop the service with `/etc/init.d/shunt stop`, which also tears down the nftables table, the routing tables and the ip rules, then remove the `shunt` and `luci-app-shunt` packages if necessary. `shunt flush` does the teardown alone, should anything be left behind.

<a id="donations"></a>
## Donations
You like this project - is there a way to donate? Generally speaking "No" - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.

If you still insist to donate some bucks ...
* I would be happy if you put your money in kind into other, social projects in your area, e.g. a children's hospice
* Let's meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
* Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken) and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!

Have fun!  
Dirk
