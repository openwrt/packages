# adsbexchange-stats

Optional ranking-dashboard statistics uploader for ADSBexchange.com on
OpenWrt. Companion to [`readsb-wiedehopf`](../readsb-wiedehopf/) -- it
periodically reads `aircraft.json` from the local readsb daemon,
aggregates per-aircraft RSSI and counts, and POSTs the result to
ADSBexchange identified by the shared station UUID. Pure feeding does
**not** require this package; install it only if you want your station
listed on the per-station web ranking.

## Contents

* [Quick start](#quick-start)
* [What gets installed](#what-gets-installed)
* [Configuration](#configuration)
  * [`/etc/config/adsbexchange-stats` -- main section options](#etcconfigadsbexchange-stats----main-section-options)
* [Station UUID](#station-uuid)
* [Service control](#service-control)
* [Logging and diagnostics](#logging-and-diagnostics)
  * [Log levels](#log-levels)
* [Relationship to readsb-wiedehopf](#relationship-to-readsb-wiedehopf)
* [License](#license)

## Quick start

```sh
opkg install readsb-wiedehopf       # required dependency
opkg install adsbexchange-stats
readsb-uuid                          # generate / set the shared station UUID
service adsbexchange-stats start
service adsbexchange-stats showurl   # print this station's stats URL
```

The `postinst` step enables the service. It auto-starts only if
`readsb.main.uuid` is already set; otherwise it prints a banner with
the next steps and waits for you to run `readsb-uuid`. After the UUID
is set, run:

```sh
service adsbexchange-stats start
```

To watch the uploader:

```sh
logread -e adsbexchange-stats
```

## What gets installed

| Path                                                  | Purpose                                                                              |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `/usr/share/adsbexchange-stats/json-status`           | patched upstream uploader (bash; runs under procd)                                   |
| `/etc/config/adsbexchange-stats`                      | UCI config (declarative; see below)                                                  |
| `/etc/init.d/adsbexchange-stats`                      | procd init script (`service adsbexchange-stats start\|stop\|reload\|status\|showurl`) |
| `/usr/lib/adsbexchange-stats/functions.sh`            | shared sh helpers (logging, UUID, json path resolution)                              |
| `/usr/lib/adsbexchange-stats/json-status-helpers.sh`  | upload-side helpers (curl wrapper, periodic summary)                                 |
| `/var/run/adsbexchange-stats/`                        | runtime dir (env file, uuid, scratch JSON; tmpfs)                                    |

## Configuration

`/etc/config/adsbexchange-stats` is **declarative-only by design** --
it carries options, not documentation. Comments (lines starting with
`#`) do not survive `uci commit`: every committer (manual `uci`, LuCI,
this package's own reload trigger, `readsb-uuid`) rewrites the file in
canonical form and strips them. All option documentation therefore
lives in this README and in `service adsbexchange-stats info`, never
inside the conffile itself. (The same convention is used by the
companion `readsb-wiedehopf` package.)

The init script reads the conffile together with `readsb.main.uuid`
and `readsb.main.write_json` from `/etc/config/readsb`, renders an env
file at `/var/run/adsbexchange-stats/env`, and supervises the uploader
under procd.

Reload triggers are registered on **both** `adsbexchange-stats` and
`readsb`, so the recommended workflow is:

```sh
uci set adsbexchange-stats.main.<option>=<value>
uci commit adsbexchange-stats
service adsbexchange-stats reload
```

### `/etc/config/adsbexchange-stats` -- main section options

| Option                 | Default | Notes                                                                                                                                                          |
| ---------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `enabled`              | `1`     | set to `'0'` to keep the package installed but stop the uploader                                                                                               |
| `json_paths_override`  | empty   | space-separated list of directories searched for `aircraft.json`, in preferred order. Empty = derive from `readsb.main.write_json` plus built-in fallbacks. Tokens are restricted to `[A-Za-z0-9/_.+-]`. |
| `log_level`            | `1`     | uploader verbosity: `0` errors only, `1` + periodic summary, `2` + per-cycle line, `3` + full curl `-v` headers                                                |
| `log_summary_interval` | `300`   | seconds between summary lines at `log_level >= 1`                                                                                                              |
| `dns_cache`            | `0`     | enable the uploader's in-process DNS self-cache. Auto-disabled if a `127.0.0.0/8` resolver is in use or if `host`/`perl` are missing.                          |
| `dns_ttl`              | `600`   | DNS cache TTL in seconds when `dns_cache=1`                                                                                                                    |
| `dns_ignore_local`     | `0`     | when `dns_cache=1`, set to `'1'` to bypass the cache for `127.0.0.0/8` answers                                                                                 |

`json_paths_override` resolution order:

1. `option json_paths_override` (this file)
2. `readsb.main.write_json` from `/etc/config/readsb`, plus the built-in
   fallbacks (`/var/run/readsb`, `/run/adsbexchange-feed`, `/run/dump1090`,
   `/run/dump1090-fa`)
3. built-in fallbacks alone

Tokens that contain shell-metacharacters are dropped at startup with a
`warn`-level log line.

## Station UUID

The uploader identifies your station with the same UUID readsb uses
for its BEAST connectors. There is **one** UUID per station, stored at
`readsb.main.uuid` in `/etc/config/readsb`. Manage it with:

```sh
readsb-uuid                # interactive: generate / show / replace
readsb-uuid --auto         # non-interactive: generate if missing
readsb-uuid --print        # print current value
```

The init script never auto-generates the UUID, because doing so would
race with `readsb-uuid` running concurrently on the same box. If
`readsb.main.uuid` is missing or malformed (not 8-4-4-4-12 hex), the
service refuses to start and logs an `err`-level line pointing at
`readsb-uuid`.

## Service control

```sh
service adsbexchange-stats start
service adsbexchange-stats stop
service adsbexchange-stats restart
service adsbexchange-stats reload      # picks up UCI / readsb-uuid changes
service adsbexchange-stats status      # procd state
service adsbexchange-stats enable      # start at boot
service adsbexchange-stats disable
service adsbexchange-stats showurl     # public per-station stats URL
```

`showurl` derives the URL from the live `readsb.main.uuid`, so it
always reflects the current registered identity. The same URL is also
printed by `readsb-feeder --url adsbexchange` from the
`readsb-wiedehopf` package.

## Logging and diagnostics

All uploader and init-script output goes to syslog under the tag
`adsbexchange-stats`:

```sh
logread -e adsbexchange-stats
```

To persist logs to a file or forward to a remote syslog server, use
the system-wide OpenWrt logging knobs (this package does not impose
its own log routing):

```sh
# Persist to a file (rotated by busybox at log_size KiB):
uci set system.@system[0].log_file=/var/log/messages
uci set system.@system[0].log_size=200
uci commit system && /etc/init.d/log restart
```

### Log levels

`option log_level` (UCI) controls uploader verbosity. All lines follow
RFC 5424 / OpenWrt severity convention; filter with `logread -p <level>`.

| `log_level` | Output                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------- |
| `0`         | errors only (curl transport failures, decoder stalls)                                             |
| `1`         | + periodic upload summary every `log_summary_interval` seconds                                    |
| `2`         | + one line per upload cycle (aircraft, http code, gzipped bytes, elapsed time)                    |
| `3`         | + full curl `-v` request/response headers (TLS handshake; verbose, mostly useful for debugging)   |

Init-script lifecycle events (start, stop, refused-UUID, unsafe path
token) log at `notice` / `warn` / `err` regardless of `log_level`.

## Relationship to readsb-wiedehopf

This package **hard-depends** on `readsb-wiedehopf` (`DEPENDS:= ...
+readsb-wiedehopf`) for three reasons:

* **Shared UUID.** `readsb.main.uuid` is the single station identity
  consumed by both readsb's BEAST connectors and this uploader.
  `readsb-uuid` configures it for both.
* **Shared helpers.** `/usr/lib/readsb/functions.sh` provides
  `readsb_is_uuid` (the 8-4-4-4-12 hex validator) which this package's
  helpers source.
* **Shared `aircraft.json`.** The default `json_paths_override` reads
  from `readsb.main.write_json` (default `/var/run/readsb`).

The dependency link is one-way: `adsbexchange-stats` depends on
`readsb-wiedehopf`, not the other way around. Reload triggers are
registered on both UCI files so edits via `readsb-uuid`, manual `uci`
commands on `/etc/config/readsb`, or LuCI all propagate without a
manual restart.

### Discovery from the readsb side

Once both packages are installed, the readsb-side CLIs detect this
package automatically and surface its state in their own output -- you
do not have to remember to run a separate health check:

| readsb command                            | What it does about adsbexchange-stats                                                                                                          |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `readsb-feeder --url adsbexchange`        | Prints the same per-station stats URL as `service adsbexchange-stats showurl` (derived from `readsb.main.uuid`). Works whether or not this package is installed. |
| `readsb-feeder --companions [adsbexchange]` | For each enabled `adsbexchange` feeder, reports whether `adsbexchange-stats` is installed and whether its service is running. Prints the exact `opkg install` / `service ... start` command if not. |
| `readsb-setup --status`                   | Same companion-package check as above; surfaces this package's `controls` line including the `showurl` extra action.                            |
| `readsb-setup --health`                   | Adds a `[ recent log scan: adsbexchange-stats ]` block showing this uploader's last log line, recent error/warn count, and most-recent error -- so a single command covers daemon + uploader. |

These integrations rely only on what this package already ships:
the `service adsbexchange-stats` init script, the `showurl` extra
action, and the `adsbexchange-stats` syslog tag. No extra glue is
required on either side.

## License

Dual-license:

* OpenWrt packaging files (Makefile, init script, helpers, patches) --
  GPL-2.0-only (matches the surrounding OpenWrt feed).
* Upstream `json-status` payload (ADSBexchange.com, (c) 2020) -- MIT,
  preserved as-is in the source tarball.
