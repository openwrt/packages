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
* [Third-party network connections](#third-party-network-connections)
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
  * [Feeder probe results](#feeder-probe-results)
  * [Log levels](#log-levels)
* [Companion packages](#companion-packages)
* [Conflicts](#conflicts)
* [Regression tests](#regression-tests)

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
*enabled* feeder section. An externally supplied `adsbexchange-stats`
package is recognized only if it is already installed; its absence is
not a warning and does not trigger an installation offer. For installed
companions, stopped-service findings include the command to start the
service and are mirrored to syslog.

`--health` delegates the per-feeder runtime breakdown to
`readsb-feeder --health` (also runnable standalone, with an optional
`<name>` argument). Per-feeder states:

* `LIVE` -- in cmdline + (TCP probe ok OR active socket in
  `/proc/net/tcp`) + log clean.
* `DEGRADED` -- in cmdline but recent error events are present, no probe
  tool or active socket is available, or exact socket attribution is
  indeterminate and a TCP probe cannot confirm reachability. Attribution
  can be uncertain when multiple connectors share a remote port and
  `resolveip` is missing, the socket uses IPv6, or DNS has rotated.
* `UNREACHABLE` -- in cmdline + TCP probe FAIL **and** no active
  socket (not merely indeterminate attribution). The active-socket
  cross-check is the authoritative tie-breaker because some aggregator
  firewalls (notably `feed1.adsbexchange.com:30004`) drop drive-by SYN+close
  probes but accept readsb's persistent feeder stream.
* `NOT-LOADED` -- in UCI but missing from the live cmdline; run
  `service readsb reload`.
* `DISABLED` -- `enabled=0` in UCI; only shown when explicitly named.

An explicitly requested feeder name is checked before the daemon's
running state. `readsb-feeder --health <name>` exits 3 if that feeder
does not exist (or names a non-feeder section), even while readsb is
stopped; an existing feeder with a stopped daemon still exits 2.

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

The daemon package depends on `uclient-fetch`, `ca-bundle`, and
`libustream-mbedtls` (OpenWrt's default TLS provider) so GeoIP has HTTPS
support on minimal images. Installing these dependencies does not opt in
to any external lookup. The network-only viewer does not pull in the
helpers' HTTP/TLS dependencies.

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
  abort cleanly; `readsb-setup` saves each completed step immediately,
  so aborting retains completed steps but prevents later ones)
2. **non-interactive helper CLIs** -- e.g. `readsb-feeder --add`, `readsb-uuid --auto`
3. **plain UCI** -- `uci set readsb.main.lat=...; uci commit readsb`
4. **hand-edit `/etc/config/readsb`** -- always works, but the moment
   anything else commits to UCI you lose any comments you added

None of the helper CLIs auto-restart the daemon. After a batch of
changes, run:

```sh
service readsb reload
```

## Third-party network connections

The package does not contact geolocation services or aggregators by
default. Public-IP geolocation and every outbound feeder are separate,
explicit opt-ins. Local listeners such as ports `30001` through `30006`
do not create outbound connections by themselves and bind to loopback by
default. Set `net_bind_address` explicitly to expose them to other hosts.

The setup wizard explains the destination and data flow before asking.
All third-party consent prompts default to **no**. Choosing a one-time
GeoIP lookup does not enable future automatic lookups; that is a separate
prompt and UCI option. Adding a feeder does not enable it unless the user
answers yes to the feeder connection prompt.

| Connection | Destination / transport | Data disclosed | Default state | Opt in / opt out |
| ---------- | ----------------------- | -------------- | ------------- | ---------------- |
| Primary GeoIP | `ipapi.co` over HTTPS | the request reveals the router's public IP; the service returns approximate city-level coordinates | automatic lookup off (`geoip_auto=0`) | one time: choose auto-detect in `readsb-setup` and consent, or run `readsb-geoip`; persistent: set `geoip_auto=1`; opt out with `geoip_auto=0` |
| Fallback GeoIP | `ipwho.is` over HTTPS, attempted only if `ipapi.co` fails | same as primary GeoIP | automatic lookup off | controlled by the same one-time consent or `geoip_auto` setting |
| `adsblol` feeder | `in.adsb.lol:30004` over TCP | received Mode-S/ADS-B stream and station UUID when configured | no feeder section; no connection | add with `readsb-feeder`, then explicitly enable; disable with `readsb-feeder --disable <name>` |
| `airplaneslive` feeder | `feed.airplanes.live:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `adsbfi` feeder | `feed.adsb.fi:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `planespotters` feeder | `feed.planespotters.net:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `theairtraffic` feeder | `feed.theairtraffic.com:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `flyitaly` feeder | `dati.flyitalyadsb.com:4905` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `avdelphi` feeder | `data.avdelphi.com:24999` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `adsbexchange` feeder | `feed1.adsbexchange.com:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| `flyrealtraffic` feeder | `feed.flyrealtraffic.com:30004` over TCP | same feeder data | no feeder section; no connection | same feeder opt-in / disable flow |
| Custom feeder | user-supplied host and TCP port | received Mode-S/ADS-B stream and station UUID when configured | no feeder section; no connection | add with the custom preset and explicitly enable; disable or remove with `readsb-feeder` |

`readsb-geoip --self-test` is also an explicit network operation: it
tests DNS and HTTPS access to both GeoIP providers. The optional
external `adsbexchange-stats` companion is not provided by the official
feeds or recommended for installation here. If installed separately,
enabling its external statistics upload requires its own consent,
defaulting to **no**; adding a feeder is not consent for that upload.
`readsb-feeder --url` only prints a dashboard URL and does not fetch it.

For non-interactive configuration:

```sh
# Permit automatic GeoIP only when coordinates are missing:
uci set readsb.main.geoip_auto=1
uci commit readsb

# Revoke automatic GeoIP permission:
uci set readsb.main.geoip_auto=0
uci commit readsb

# Feeder sections remain inert until enabled:
readsb-feeder --add myfeed adsblol enabled=0
readsb-feeder --enable myfeed
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

Without `--force`, `readsb-geoip` fills only missing coordinates. If
latitude or longitude is already set, that value is preserved even
when the other coordinate needs a lookup. Use `--force` only when both
values should be replaced with the approximate GeoIP result.
The setup wizard follows the same rule for partial locations. If both
coordinates exist and you explicitly choose to change the location,
it explains that auto-detection will replace both values before asking
for consent. `--dry-run` previews the eligible writes without staging
or committing any UCI changes; lookup or write failures return nonzero.

Coordinate updates are staged in a private UCI directory and committed
only after every eligible write succeeds. A failed write or commit
discards those private changes, preserving both the original coordinates
and shared pending edits. A later unrelated commit cannot pick up part
of a failed lookup. After a successful commit, pending edits to the keys
explicitly updated are cleared so they cannot mask the new values.

### Boot-time waits

| Option                 | Default | Notes                                                  |
| ---------------------- | ------- | ------------------------------------------------------ |
| `geoip_auto`           | `0`     | opt in to automatic public-IP geolocation when an enabled section has empty coordinates. This contacts `ipapi.co`, falling back to `ipwho.is`. Manual `readsb-geoip` use is always available. |
| `geoip_wait_timeout`   | `60`    | seconds the init script blocks until `readsb-geoip` resolves lat/lon when `geoip_auto` is enabled. Covers the cold-boot case where WAN isn't ready when `START=90` fires. Set to `0` for a single-shot lookup. |
| `geoip_wait_interval`  | `10`    | poll interval for the geoip wait loop.                 |
| `usb_wait_timeout`     | `0`     | seconds the init script blocks until a USB SDR appears in `/sys`. Default `0` (off) so net-only deployments pay no boot cost. Only honored when `option hotplug 1` is set. |
| `usb_wait_interval`    | `2`     | poll interval for the USB wait loop.                   |

Each polling sleep is capped to the remaining wait budget. For example,
a one-second timeout with a ten-second interval sleeps only one second
before the final probe. Individual probe execution time is additional
to this sleep budget.

### SDR / RF

The interactive way to set these on a unit with an attached RTL-SDR is
step 3 of `readsb-setup` (auto-skipped on net-only units). Hand-editing
also works.

| Option            | Default | Notes                                                 |
| ----------------- | ------- | ----------------------------------------------------- |
| `gain`            | `auto`  | `auto`, `max`, or a numeric dB value (`0`..`50`); `max` omits `--gain` to select upstream's maximum-gain default |
| `device`          | empty   | RTL-SDR serial or numeric index; auto-filled by the USB hotplug handler |
| `device_auto`     | empty   | internal marker recording the last automatic pin; clear it when choosing a manual pin |
| `device_type`     | empty   | `rtlsdr`, `bladerf`, etc. (only `rtlsdr` is supported in this build) |
| `freq`            | empty   | integer MHz (`978`, `1090`), suffixed MHz (`1090MHz`, `1090m`), or integer Hz (`1090000000`); converted to Hz before startup; empty uses 1090 MHz |
| `ppm`             | `0`     | integer tuner correction in `-100`..`100`; fractional values are not supported by the RTL-SDR backend |
| `enable_agc`, `enable_biastee` | `0` | hardware-side toggles; bias-T support is compiled in but remains off unless explicitly enabled on compatible hardware |

Bare frequency values below `1000000` are interpreted as MHz; larger
values are Hz. The normalized frequency must fit a positive signed
32-bit integer. Invalid frequency or PPM settings are logged and
prevent the SDR instance from starting instead of being silently
truncated. Net-only instances do not apply SDR tuning options.

### Network

| Option              | Default          | Notes                                          |
| ------------------- | ---------------- | ---------------------------------------------- |
| `net`               | `1`              | enable network I/O                             |
| `net_only`          | `1`              | run without an SDR (network-only consumer)     |
| `net_bind_address`  | `127.0.0.1`      | listen only on this router by default; set an appropriate LAN address explicitly to permit remote clients |
| `net_bi_port`       | `30004,30104`    | inbound BEAST                                  |
| `net_bo_port`       | `30005`          | outbound BEAST -- this is what you point external feeder clients (e.g. `piaware`, `fr24feed`) at; reachable from other hosts only once `net_bind_address` is widened |
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

No hardware configuration is required. Plug the RTL-SDR in; the handler
sets `device_type=rtlsdr`, `device=<serial>`, `device_auto=<serial>`, and
`net_only=0`, then restarts the service if it is enabled. A dongle with
no serial uses index `0`. It preserves `enabled=0` as an administrative
choice. Unplug -> reverts to net-only and clears the automatic pin.

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
# Now both can be plugged in; the handler selects the serial matching freq.
```

The section's `option freq` (in Hz, MHz, or `1090MHz`-style) selects
which serial it claims. Automatically selected pins are re-evaluated
on subsequent add events and boot-time replay. Thus plugging the `978`
dongle first does not prevent selecting `1090` when that dongle arrives.
If no serial matches, a still-attached automatic serial is kept only
when it is unlabelled or its parsed frequency matches the configured
band. For example, an automatic `978` pin is not retained by a `1090`
instance when another SDR is attached. This check also recognizes MHz
suffixes and Hz-form labels. Unlabelled serials remain stable, and a
valid manual pin remains an explicit operator choice. An automatic
numeric index without a matching serial is not stable enough to retain
with multiple SDRs.

With no matching serial, valid manual choice, or retained automatic
serial, `device` stays empty and `net_only=1`; an omitted device must
not silently select upstream's index 0. The handler logs the available
serials and asks for a device selection. Selecting a device manually or
attaching a frequency-matched dongle re-enables SDR mode on the next
hotplug add or restart. Boot replay follows the same rule.

An attached manual pin is not replaced by the frequency convention.
To make a manual choice, including freezing the current automatic
choice:

```sh
uci set readsb.main.device='chosen-serial'
uci -q delete readsb.main.device_auto
uci commit readsb
service readsb restart
```

Changing `device` to a value different from `device_auto` also makes it
manual. Existing non-empty pins without a marker are treated as manual;
clear `device` to opt them back into automatic selection. Removal of the
selected dongle still clears its pin and switches to network-only until
reselection. Use `hotplug=0` to opt out of all automatic device changes.

Hotplug computes the device, automatic-pin marker, device type, and
network-only mode together before staging them privately. A failed
write or commit discards the whole hotplug update without leaving a
partial pin for a later shared UCI commit. Service restart and success
logging occur only after the update is committed.

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
   net-only (clears `device_type` / `device` / `device_auto`, sets `net_only=1`) before
   the daemon starts. Avoids a stale `device=<serial>` from a
   no-longer-attached dongle blocking startup.
3. **Geoip wait** -- if `geoip_auto` is enabled and any enabled section
  has empty `lat`/`lon`, polls until `/usr/sbin/readsb-geoip` succeeds
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

`--add` validates all options before staging a new named section and
checks every write. A failed write or commit returns 2 without an
"added" message and removes the partial new section; unrelated staged
UCI edits are left alone. If cleanup also fails, the command reports
that explicitly so the pending configuration can be inspected.

`--set` also validates every option before applying changes. If any
`uci set` or `uci delete` fails, it stops immediately with exit 2,
reports the failed option, and does not commit or print a success
message. Earlier successful writes can remain staged; inspect pending
changes before committing or retrying. The existing feeder and unrelated
pending edits are not deleted or reverted automatically.

`--enable` and `--disable` also check their UCI write before committing.
If it fails, they return 2 without committing unrelated pending changes,
printing a success message, or starting companion checks.

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
optional external `adsbexchange-stats` uploader is **not available in
the official feeds**. This package neither recommends an `opkg install`
for it nor warns when it is absent. Pure feeding does not require it.

If an operator separately installs that package, the diagnostics can
recognize its opkg metadata and display its service status, configuration
and logs. Starting a stopped uploader requires separate explicit consent
(default **no**) because it sends supplemental statistics to ADSBx.

The public per-UUID lookup URL is printed by
`readsb-feeder --url adsbexchange` whether the uploader is installed or
not. When the uploader **is** installed it also exposes the same URL
via its own `/etc/init.d/adsbexchange-stats showurl` action and a
project-info banner via `/etc/init.d/adsbexchange-stats info`. Both
appear on the installed companion's `controls` line in
`readsb-setup --status` and `readsb-setup --help`.

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

The health helpers filter by the exact syslog tag before taking the
recent-log window. Warnings from `readsb-setup`, `readsb-feeder`,
`readsb-uuid`, or `readsb-geoip` do not count as daemon errors merely
because their tags contain `readsb`.

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

### Feeder probe results

`readsb-feeder --probe [<name>]` checks the daemon's owned sockets first,
then attempts a bounded TCP probe if no socket can be attributed to the
feeder. When run under Bash with `timeout` available, it uses Bash's
`/dev/tcp` support with a three-second timeout. Otherwise it uses `nc -w 3`
only if that option is supported. Stock BusyBox `nc` may lack `-w`; no
unbounded connection is attempted.

| Result | Meaning |
| ------ | ------- |
| `LIVE` | readsb has an attributable established socket; no probe was sent |
| `OK` | a TCP probe succeeded |
| `SKIP` | no supported bounded probe is available, or a probe failed while socket attribution was indeterminate |
| `FAIL` | a TCP probe failed and no potentially active readsb socket was found |
| `DISABLED` | the explicitly named feeder is disabled; no probe was sent |

`--probe` exits **0 when there are no confirmed failures, even if every
result is `SKIP`**. Exit 0 alone does not confirm connectivity. It exits
2 when any feeder reports `FAIL`, 3 when no enabled feeder matches (or
the named section does not exist), and 1 for a usage error.

`--health` is stricter: indeterminate checks are `DEGRADED`, not
`UNREACHABLE`, and produce exit 2. A successful probe can still establish
`LIVE` when socket attribution is indeterminate, provided the connector
is loaded and there are no recent errors. Use `--health` rather than
`--probe` when monitoring requires a confirmed healthy feed.

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

* **resolveip** -- improves IPv4 socket attribution when multiple feeders
  share a remote port. Install with `opkg install resolveip` to enable
  per-host checks. Without it, successful TCP probes still work;
  inconclusive checks report `SKIP` in `--probe` or `DEGRADED` in
  `--health`. IPv6 sockets and DNS-rotated addresses may still be
  indeterminate even with `resolveip` installed.

`readsb-setup --status` and `readsb-feeder --companions` walk every
*enabled* feeder section and report recognized, already-installed
external companions (currently `adsbexchange-stats`, not `resolveip`).
They do not recommend installing unavailable packages. Stopped services
are reported with their start command and mirrored to syslog so they
also appear in `logread -e readsb` for headless setups.

## Conflicts

This package `PROVIDES:=readsb` and `CONFLICTS:=readsb` (likewise for
`viewadsb`). Either this package or the upstream `readsb` package can
satisfy a `readsb` dependency, but the two cannot be installed
side-by-side.

## Regression tests

From the packages feed root, run:

```sh
sh utils/readsb-wiedehopf/tests/feeder.sh
sh utils/readsb-wiedehopf/tests/runtime.sh
sh utils/readsb-wiedehopf/tests/geoip.sh
```

The tests exercise production feeder diagnostics, SDR argument
translation, automatic/manual pin handling, consent, exact-tag log
filtering, and GeoIP coordinate preservation. OpenWrt services, hardware
and network tools are mocked; the tests do not change the host's UCI or
contact external services. The scripts can also be run with `bash` or
`busybox ash` to check shell compatibility.
