<!-- markdownlint-disable -->

# readsb-wiedehopf

ADS-B / Mode-S decoder daemon for OpenWrt -- the actively maintained
[wiedehopf fork](https://github.com/wiedehopf/readsb) of readsb. Used
upstream by tar1090, adsb.lol, airplanes.live, adsb.fi, and similar
aggregators.

## Contents

* [Quick start](#quick-start)
* [What gets installed](#what-gets-installed)
* [Configuration model](#configuration-model)
* [`/etc/config/readsb` -- main section options](#etcconfigreadsb----main-section-options)
* [SDR / hotplug behavior](#sdr--hotplug-behavior)
  * [Single-SDR setup](#single-sdr-setup)
  * [Multi-SDR setup](#multi-sdr-setup)
* [Boot-time behavior](#boot-time-behavior)
* [Aggregator feeders](#aggregator-feeders)
  * [Built-in presets](#built-in-presets)
  * [Adding a feeder](#adding-a-feeder)
  * [`silent_fail` semantics](#silent_fail-semantics)
  * [Per-feeder UUID override](#per-feeder-uuid-override)
  * [adsbexchange supplemental stats](#adsbexchange-supplemental-stats)
  * [adsblol map](#adsblol-map)
* [Out-of-scope aggregators](#out-of-scope-aggregators)
* [MLAT](#mlat)
* [Logging and diagnostics](#logging-and-diagnostics)
  * [Log levels](#log-levels)
* [Companion packages](#companion-packages)
* [Conflicts](#conflicts)

## Quick start

```sh
opkg install readsb-wiedehopf
readsb-setup            # guided first-boot: lat/lon, UUID, SDR, feeders, reload
```

The package is fully usable without `readsb-setup` -- the postinst step
enables and starts the daemon with safe defaults, and `opkg install`
prints a banner pointing at the wizard. Run `readsb-setup` when you're
ready to actually receive aircraft (you need at minimum a station
location and, for most aggregators, a UUID).

The wizard walks through five steps; each is skippable and re-running
it is idempotent. Steps:

1. station latitude / longitude (auto-fill from public IP, or enter manually)
2. station UUID (auto-generate)
3. SDR tuning -- gain / PPM / AGC / bias-T (**auto-skipped** if no SDR present)
4. at least one aggregator feeder (delegates to `readsb-feeder`)
5. apply changes (offers `service readsb reload`)

For a non-interactive at-a-glance state report, e.g. from cron or for
health-check scripts:

```sh
readsb-setup --status        # configuration check (essentials, mode,
                             #  ports, SDRs, feeders, companion packages)
                             # exit 0 if all essentials present, 1 if not
readsb-setup --health        # runtime health (process metrics, host
                             #  load, live data flow, per-feeder TCP
                             #  probe + cmdline-presence + per-source
                             #  log scan: readsb + each installed
                             #  companion package)
                             # exit 0 = HEALTHY, 1 = DEGRADED, 2 = DOWN
readsb-setup --stats         # ONLY the most recent periodic stats
                             #  block (signal, decoded msgs, tracks,
                             #  CPU). Same parser as --health.
                             # exit 0 = printed, 2 = daemon DOWN,
                             #        3 = no block buffered yet
```

The three are intentionally split:

* **`--status`** -- *"is this box set up correctly?"* Walks UCI + USB +
  the opkg control file. Stable across reloads. Safe to run before the
  daemon is up.
* **`--health`** -- *"is this box working right now?"* Reads
  `/proc/<pid>/`, `/var/run/readsb/*.json`, the live readsb cmdline,
  and the recent syslog buffer. Requires the daemon to be running.
  The recent-log section is split per source: one block for the
  daemon, then one per *installed* companion package (e.g.
  `adsbexchange-stats`). Use for monitoring / cron health checks.
* **`--stats`** -- *"how is reception/decoding doing right now?"*
  Parses the most recent periodic stats block out of `logread` and
  prints just that block (signal dBFS, Mode-S preambles + CRCs,
  decoded messages, positions, tracks, CPU).

`--status` also runs an optional companion-package check for every
*enabled* feeder section: for any preset that has a recommended
companion package (currently `adsbexchange` -> `adsbexchange-stats`),
it reports whether that package is installed and (when applicable)
whether the bundled service is running. Missing/stopped findings are
printed with the exact `opkg install` / `service ... start` command
to fix them, and are mirrored to syslog.

`--health` delegates the per-feeder runtime breakdown to
`readsb-feeder --health` (also runnable standalone, with an optional
`<name>` argument). Per-feeder states:

* `LIVE` -- in cmdline + (TCP probe ok OR active socket in
  `/proc/net/tcp`) + log clean.
* `DEGRADED` -- in cmdline + reachable but recent error events for
  that connector.
* `UNREACHABLE` -- in cmdline + TCP probe FAIL **and** no active
  socket. The active-socket cross-check is the authoritative
  tie-breaker because some aggregator firewalls (notably
  `feed1.adsbexchange.com:30004`) drop drive-by SYN+close probes but
  accept readsb's persistent feeder stream.
* `NOT-LOADED` -- in UCI but missing from the live cmdline; run
  `service readsb reload`.
* `DISABLED` -- `enabled=0` in UCI; only shown when explicitly named.

To dump the live UCI config in a human-readable form (without the noise
of `uci show`):

```sh
readsb-setup --config        # pretty-printed /etc/config/readsb
                             # plus /etc/config/<pkg> for each
                             # installed companion package
```

To re-display the orientation banner that's printed once at install
time (the "what can I do?" reference card):

```sh
readsb-setup --help
```

## What gets installed

| Path                          | Purpose                                                           |
| ----------------------------- | ----------------------------------------------------------------- |
| `/usr/bin/readsb`             | the daemon (and `viewadsb` from the companion subpackage)         |
| `/etc/config/readsb`          | UCI config (declarative; see below)                               |
| `/etc/init.d/readsb`          | procd init script (`service readsb start|stop|reload|status`)     |
| `/etc/hotplug.d/usb/30-readsb`| RTL-SDR auto-detect on USB plug/unplug                            |
| `/usr/lib/readsb/functions.sh`| shared sh helpers (sourced by every helper CLI)                   |
| `/usr/sbin/readsb-setup`      | guided first-boot wizard (also: `--status`, `--health`, `--stats`, `--config`, `--help` for the master CLI banner) |
| `/usr/sbin/readsb-feeder`     | feeder management CLI (`--list`, `--probe`, `--health`, ...; see `readsb-feeder -h`) |
| `/usr/sbin/readsb-uuid`       | station UUID wizard / generator (`--print`, `--auto`, `--force`)  |
| `/usr/sbin/readsb-geoip`      | public-IP-based lat/lon auto-fill                                 |

## Configuration model

`/etc/config/readsb` is **declarative-only** by design. It contains:

* exactly one `config readsb 'main'` section (daemon-wide settings)
* zero or more `config feeder '<name>'` sections (outbound aggregator
  connections, one per section)

**Comments do not survive `uci commit`.** Every UCI commit -- whether
from the USB hotplug handler, from `readsb-uuid`, from `readsb-geoip`,
from LuCI, or from a manual `uci set ...; uci commit readsb` -- rewrites
the file in canonical form and strips every line starting with `#`. For
that reason, all human-facing documentation lives here in the README and
in each CLI's `--help`, not inside the config file.

Mutating workflows (in order of preference):

1. **interactive wizards** -- `readsb-setup`, `readsb-feeder`, `readsb-uuid`
   (each prompt accepts `q`, `quit`, or `exit` -- or `Ctrl-D` -- to
   abort cleanly; aborting before the apply step makes no changes)
2. **non-interactive helper CLIs** -- e.g. `readsb-feeder --add`, `readsb-uuid --auto`
3. **plain UCI** -- `uci set readsb.main.lat=...; uci commit readsb`
4. **hand-edit `/etc/config/readsb`** -- always works, but the moment
   anything else commits to UCI you lose any comments you added

None of the helper CLIs auto-restart the daemon. After a batch of
changes, run:

```sh
service readsb reload
```

## `/etc/config/readsb` -- main section options

Only options that need explanation are documented here. The full list
ships in the conffile; setting an option to `''` (empty) means "let
readsb apply its built-in default". Boolean options take `'0'` or `'1'`.

### Identity and location

| Option            | Default        | Notes                                                 |
| ----------------- | -------------- | ----------------------------------------------------- |
| `lat`, `lon`      | empty          | station coordinates; required for CPR position decoding. Set with `readsb-setup`, `readsb-geoip`, or hand-edit. |
| `uuid`            | empty          | station UUID, shared as the default for every feeder section that doesn't override it. Generate with `readsb-uuid`. |
| `uuid_file`       | empty          | path readsb reads at startup and applies to every uuid-capable output that doesn't carry an embedded `uuid=`. Independent of `option uuid`; setting only the file is fine if you don't use `config feeder` sections. |

### Boot-time waits

| Option                 | Default | Notes                                                  |
| ---------------------- | ------- | ------------------------------------------------------ |
| `geoip_wait_timeout`   | `60`    | seconds the init script blocks until `readsb-geoip` resolves lat/lon. Covers the cold-boot case where WAN isn't ready when `START=90` fires. Set to `0` to disable (single-shot lookup). |
| `geoip_wait_interval`  | `10`    | poll interval for the geoip wait loop.                 |
| `usb_wait_timeout`     | `0`     | seconds the init script blocks until a USB SDR appears in `/sys`. Default `0` (off) so net-only deployments pay no boot cost. Only honored when `option hotplug 1` is set. |
| `usb_wait_interval`    | `2`     | poll interval for the USB wait loop.                   |

### SDR / RF

The interactive way to set these on a unit with an attached RTL-SDR is
step 3 of `readsb-setup` (auto-skipped on net-only units). Hand-editing
also works.

| Option            | Default | Notes                                                 |
| ----------------- | ------- | ----------------------------------------------------- |
| `gain`            | `auto`  | `auto`, `max`, or a numeric dB value (`0`..`50`)      |
| `device`          | empty   | RTL-SDR serial; auto-filled by the USB hotplug handler |
| `device_type`     | empty   | `rtlsdr`, `bladerf`, etc. (only `rtlsdr` is supported in this build) |
| `freq`            | empty   | center frequency; defaults to 1090 MHz                |
| `ppm`             | `0`     | tuner PPM correction                                  |
| `enable_agc`, `enable_biastee` | `0` | hardware-side toggles                          |

### Network

| Option              | Default          | Notes                                          |
| ------------------- | ---------------- | ---------------------------------------------- |
| `net`               | `1`              | enable network I/O                             |
| `net_only`          | `1`              | run without an SDR (network-only consumer)     |
| `net_bi_port`       | `30004,30104`    | inbound BEAST                                  |
| `net_bo_port`       | `30005`          | outbound BEAST -- this is what you point external feeder clients (e.g. `piaware`, `fr24feed`) at |
| `net_ri_port`       | `30001`          | inbound raw                                    |
| `net_ro_port`       | `30002`          | outbound raw                                   |
| `net_sbs_port`      | `30003`          | outbound SBS/BaseStation                       |
| `net_beast_reduce_out_port` | `30006`  | outbound reduced BEAST                         |

### Periodic stats block

The daemon emits a multi-line health/status summary into syslog on a
fixed interval. readsb writes this to stderr; procd routes stderr at
`daemon.err` on stock OpenWrt -- this matches dnsmasq/hostapd/ntpd
convention, not a severity claim. Filter with:

```sh
logread -e readsb
```

| Option         | Default | Notes                                              |
| -------------- | ------- | -------------------------------------------------- |
| `stats`        | `1`     | set to `'0'` to silence the periodic block         |
| `stats_every`  | `120`   | cadence in seconds (sensible range 60..900)        |
| `stats_range`  | `0`     | set to `'1'` to add the per-range histogram        |

### `extra_args`

Passthrough for upstream readsb flags not surfaced as a UCI option, e.g.
the camelCase `--write-binCraft-old` / `--write-json-binCraft-only=<n>`,
`--dump-beast=<dir>,<interval>,<level>`, `--receiver-focus`,
`--cpr-focus`, `--leg-focus`, `--trace-focus`, `--aggressive`.
Whitespace-separated; appended verbatim to the daemon command line.

## SDR / hotplug behavior

The USB hotplug handler (`/etc/hotplug.d/usb/30-readsb`) auto-configures
the first `config readsb` section on RTL-SDR plug/unplug events. To
opt a section out (e.g. for a hand-managed multi-SDR setup), set:

```
option hotplug '0'
```

The handler reacts to USB IDs from librtlsdr's `known_devices[]` table
and pins the section to the dongle's serial; on the last RTL-SDR being
removed, it switches the section back to `net_only=1`.

### Single-SDR setup

No configuration required. Plug the RTL-SDR in; the handler sets
`device_type=rtlsdr`, `device=<serial>`, `net_only=0`, `enabled=1`
and restarts the service. Unplug -> reverts to net-only.

### Multi-SDR setup

If two or more RTL-SDRs are attached to the same router (e.g. one for
1090 MHz ADS-B and one for 978 MHz UAT), the auto-pin needs to know
which dongle is which. The package follows the **wiedehopf / FlightAware
convention**: label each dongle with its target frequency in MHz via
`rtl_eeprom`, then the handler pins by exact `serial == freq` match:

```sh
opkg install rtl-sdr                                # provides rtl_eeprom
# With ONLY the 1090 dongle plugged in:
rtl_eeprom -s 1090
# Unplug, plug ONLY the 978 dongle, then:
rtl_eeprom -s 978
# Now both can be plugged in; the handler will pin each section by freq.
```

The section's `option freq` (in Hz, MHz, or `1090MHz`-style) selects
which serial it claims. If no serial matches, the handler logs the
available serials at warn level and leaves `option device` empty so
you can set it manually.

## Boot-time behavior

The init script (`START=90`) handles three pre-flight conditions before
spawning the daemon:

1. **USB-settle wait** -- only when at least one section sets
   `option hotplug 1` and `option usb_wait_timeout` is non-zero. Polls
   `/sys/bus/usb/devices/` every `usb_wait_interval` seconds until an
   RTL-SDR appears or the timeout elapses. Off by default so net-only
   units pay no boot cost.
2. **No-USB reconciliation** -- if a section is hotplug-managed and
   no RTL-SDR is attached at boot, the section is normalized back to
   net-only (clears `device_type` / `device`, sets `net_only=1`) before
   the daemon starts. Avoids a stale `device=<serial>` from a
   no-longer-attached dongle blocking startup.
3. **Geoip wait** -- if any enabled section has empty `lat`/`lon` and
   `/usr/sbin/readsb-geoip` is installed, polls until lookup succeeds
   or `geoip_wait_timeout` elapses. Avoids the cold-boot race where
   WAN isn't routable when `START=90` fires.

Already-attached USB devices are also re-injected into the hotplug
handler (with `READSB_HOTPLUG_SEED=1` to suppress the recursive
restart) so the boot path produces the same UCI state as a live
plug-in event.

## Aggregator feeders

Each enabled `config feeder '<name>'` section becomes one outbound
`--net-connector` line on the readsb command line. There is no priority
ordering; every enabled feeder gets the same decoded message stream.

Strategy:

* **zero feeders** -- daemon still listens on `net_bi_port`/`net_bo_port`
  etc. but does not push to any aggregator
* **one feeder** -- single aggregator
* **many feeders** -- parallel push to several aggregators (one outbound
  TCP connection per enabled section). No upper limit beyond memory and
  uplink bandwidth.

To temporarily mute a feeder without losing the section:

```sh
readsb-feeder --disable <name>
service readsb reload
```

### Built-in presets

Hosts and ports are baked in -- check syslog after enabling, endpoints
can change without notice. All presets use protocol `beast_reduce_plus_out`.

| Preset           | Endpoint                            |
| ---------------- | ----------------------------------- |
| `adsblol`        | `in.adsb.lol:30004`                 |
| `airplaneslive`  | `feed.airplanes.live:30004`         |
| `adsbfi`         | `feed.adsb.fi:30004`                |
| `planespotters`  | `feed.planespotters.net:30004`      |
| `theairtraffic`  | `feed.theairtraffic.com:30004`      |
| `flyitaly`       | `dati.flyitalyadsb.com:4905`        |
| `avdelphi`       | `data.avdelphi.com:24999`           |
| `adsbexchange`   | `feed1.adsbexchange.com:30004`      |
| `flyrealtraffic` | `feed.flyrealtraffic.com:30004`     |

For anything else, use `preset 'custom'` and supply `host`, `port`,
and (optionally) `protocol`. Run `readsb-feeder --presets` on the device
to dump the live list.

### Adding a feeder

Interactive (recommended -- prompts for everything, validates as you go):

```sh
readsb-feeder
service readsb reload
```

Non-interactive (scriptable):

```sh
# from a preset
readsb-feeder --add adsblol adsblol enabled=1 silent_fail=1

# custom endpoint
readsb-feeder --add mycustom custom \
    host=feed.example.com port=30004 protocol=beast_reduce_plus_out \
    enabled=1 silent_fail=1
service readsb reload
```

Other useful commands -- run `readsb-feeder -h` for the full list. All
commands are `--flag` style (matching `readsb-setup --status` /
`--config` / `--help`):

```sh
readsb-feeder --list           # show all sections + resolved endpoints
readsb-feeder --show <n>       # dump one section
readsb-feeder --probe          # TCP-probe each enabled feeder host:port
readsb-feeder --url            # public stats URL (where one is published)
readsb-feeder --companions     # optional companion package(s) per enabled feeder
readsb-feeder --companions <p> # ... or for one specific preset
readsb-feeder --examples       # ready-to-paste UCI blocks for scripted setups
readsb-feeder --set <n> <k>=<v>...
readsb-feeder --enable  <name>
readsb-feeder --disable <name>
readsb-feeder --remove  <name>
```

When a preset has an optional companion package (currently
`adsbexchange` only), the wizard prints the install command before
asking for confirmation, and `readsb-feeder --add` / `--enable` log the
same recommendation to syslog -- so headless setups see it too via
`logread -e readsb`.

### `silent_fail` semantics

Every feeder section accepts `option silent_fail '0'|'1'`, default `'1'`.
When set, brief connection failures (DNS hiccup, aggregator-side
restart, transient network drop) are retried silently. When unset,
each failed connection attempt produces a log line on the daemon's
stderr stream (visible via `logread -e readsb`).

Keep the default unless you're actively debugging a feeder that won't
stay connected.

### Per-feeder UUID override

UUID resolution order per section:

1. `option uuid` on the section -- use to give one aggregator its own
   identity (e.g. you registered separately at adsbexchange)
2. `option uuid` in the readsb `main` section -- the common case, one
   station UUID shared across all aggregators
3. omitted -- the aggregator de-dupes by source IP only

### adsbexchange supplemental stats

Feeding to ADSBx works on its own from the `adsbexchange` preset. The
optional supplemental stats uploader (rssi/throttled telemetry posted to
`/api/receive`, used only for the per-station ranking on the web
dashboard) is a **separate** companion package:

```sh
opkg install adsbexchange-stats
```

It hard-depends on this package, reads `option uuid` from the readsb
`main` section, and reads `aircraft.json` from readsb's run dir.
Install only if you want the dashboard ranking; pure feeding does not
need it.

The public per-UUID lookup URL is printed by
`readsb-feeder --url adsbexchange` whether the uploader is installed or
not. When the uploader **is** installed it also exposes the same URL
via its own `/etc/init.d/adsbexchange-stats showurl` action and a
project-info banner via `/etc/init.d/adsbexchange-stats info`. Both
appear on the companion package's `controls` line in
`readsb-setup --status` and `readsb-setup --help`. opkg has no
`Recommends`/`Suggests` field, so the link between the two packages
is one-way: `adsbexchange-stats` DEPENDS on `readsb-wiedehopf`, not
the other way around.

### adsblol map

Map redirect by source IP:

```
https://api.adsb.lol/0/my
```

Printed by `readsb-feeder --url adsblol`. Other Family A aggregators
publish dashboards keyed on the source IP you signed up with -- consult
each aggregator's website for the specific URL.

## Out-of-scope aggregators

These aggregators do **not** accept a raw BEAST push from readsb. They
require their own vendor feeder client which performs aggregator-specific
station registration, protocol framing, and MLAT:

| Aggregator      | Vendor client | Notes                                              |
| --------------- | ------------- | -------------------------------------------------- |
| FlightAware     | `piaware`     | open-source TCL; FA-managed claim flow, own per-station feeder-id, bundled mlat-client. Not packaged for OpenWrt; runs on a separate host. |
| FlightRadar24   | `fr24feed`    | closed binary, FR24-supplied builds.               |
| RadarBox        | `rbfeeder`    | closed binary.                                     |
| Planefinder     | `pfclient`    | closed binary.                                     |
| AussieADSB      | (interactive) | enrolment is per-station; port varies.             |

To feed those, leave them off here and run their official client on
another host pointed at this readsb's BEAST output (`net_bo_port`,
default `30005`). Each vendor client uses its **own** station ID --
the `option uuid` in this package does NOT carry over to FlightAware's
feeder-id, FR24's sharing-key, etc.

## MLAT

Out of scope for this package. MLAT requires a separate `mlat-client`
process. The aggregators above each advertise an MLAT endpoint on
`mlat.<host>:31090` (or `:31090` on the same host) -- consult the
aggregator's own docs.

## Logging and diagnostics

All script-side and daemon-side logging goes to syslog under the tag
`readsb` (and `readsb-geoip` for the geolocation helper). View with:

```sh
logread -e readsb
```

To also persist logs to a file and/or forward them to a remote syslog
server, configure system-wide logging (this is the OpenWrt convention --
packages don't impose log routing). Examples:

```sh
# Persist to a file (rotated by busybox at log_size KiB):
uci set system.@system[0].log_file=/var/log/messages
uci set system.@system[0].log_size=200
uci commit system && /etc/init.d/log restart

# Mirror to a remote syslog server:
uci set system.@system[0].log_ip='192.0.2.10'
uci set system.@system[0].log_port='514'
uci set system.@system[0].log_proto='udp'
uci commit system && /etc/init.d/log restart
```

To raise script-side verbosity (debug-level lines from this package):

```sh
uci set system.@system[0].log_level='debug'
uci commit system && /etc/init.d/log restart
```

Diagnostic helpers:

```sh
readsb-setup --status            # at-a-glance state report (rc 0/1)
                                 # also checks optional companion packages
readsb-setup --stats             # most recent stats block only
                                 # (rc 0 = printed, 2 = down, 3 = no block yet)
readsb-setup --config            # pretty-printed /etc/config/readsb dump
                                 # + /etc/config/<pkg> for each installed companion
readsb-setup --help              # re-print the post-install welcome banner
readsb-feeder --list             # feeder sections + resolved endpoints
readsb-feeder --probe            # TCP-probe each enabled feeder
readsb-feeder --companions       # optional companion package(s) per feeder
readsb-geoip --self-test         # read-only PASS/FAIL diagnostic
service readsb status            # procd status
```

### Log levels

All script-side logging follows RFC 5424 / OpenWrt severity convention.
Filter with `logread -p <level>` or by reading the `daemon.<level>`
facility:

| Level    | Used for                                                            |
| -------- | ------------------------------------------------------------------- |
| `err`    | hard failure that aborted the operation (UCI commit failed, no UUID source, geoip self-test FAILs, hotplug commit/restart failure) |
| `warn`   | recoverable issue / degraded mode (feeder unreachable, geoip provider returned no coords, hotplug detected blocking kernel module, no SDR matched freq, geoip wait timed out) |
| `notice` | significant operator event (config mutation committed, service started, mode flip net-only<->SDR, UUID written, hotplug auto-pinned a dongle) |
| `info`   | routine progress (feeder probe summary OK, geoip lookup result, init waits)             |
| `debug`  | trace; only visible with `system.@system[0].log_level=debug`. Per-feeder routing detail at startup, UCI load traces, geoip fallback flow |

The daemon itself emits its periodic stats block on stderr; procd routes
that to `daemon.err` on stock OpenWrt. The severity tag is OpenWrt's
routing convention, **not** a severity claim from the daemon -- silence
the block with `option stats '0'` if it gets noisy.

## Companion packages

Not pulled in automatically (opkg has no `Recommends` field):

* **adsbexchange-stats** -- optional ranking-dashboard stats uploader
  for ADSBx. Hard-depends on this package; only install if you want
  ADSBx's per-station web ranking.

`readsb-setup --status` and `readsb-feeder --companions` walk every
*enabled* feeder section, look up the recommended companion package(s)
for each preset, and report whether each one is **installed** and
(when it ships an init script) **running**. Missing or stopped
packages are printed with the exact command to install / start them
and are mirrored to syslog so they also appear in
`logread -e readsb` for headless setups.

## Conflicts

This package `PROVIDES:=readsb` and `CONFLICTS:=readsb` (likewise for
`viewadsb`). Either this package or the upstream `readsb` package can
satisfy a `readsb` dependency, but the two cannot be installed
side-by-side.
