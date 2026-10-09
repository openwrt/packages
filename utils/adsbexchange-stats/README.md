# adsbexchange-stats

Optional ranking-dashboard statistics uploader for ADSBexchange.com on
OpenWrt. Companion to [`readsb-wiedehopf`](../readsb-wiedehopf/) -- it
periodically reads `aircraft.json` from the local readsb daemon,
aggregates per-aircraft RSSI and counts, and POSTs the result to
ADSBexchange identified by the selected feeder's effective UUID. Pure feeding does
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
* [Tests](#tests)
* [License](#license)

## Quick start

```sh
opkg install readsb-wiedehopf       # required dependency
opkg install adsbexchange-stats
readsb-uuid                          # station UUID, unless the feeder overrides it
readsb-feeder --setup-companions adsbx # use your enabled ADSBx feeder section name
service adsbexchange-stats showurl   # print this station's stats URL
```

Installation **does not enable or start uploads**. OpenWrt's generic
package hooks may register and invoke the init script, but the default
`enabled=0` permission prevents any uploader process from starting.
The readsb wizard
offers the optional package only when installed or available in cached
configured-feed metadata. A separate default-No prompt explains the
statistics upload before installation or activation. Selecting No leaves
normal ADSBexchange feeding unchanged.

For explicit noninteractive activation (this command constitutes consent
to the external statistics upload):

```sh
service adsbexchange-stats activate adsbx
```

The named section must exist, use `preset adsbexchange`, be enabled,
and have a valid effective UUID. `activate` selects it, enables the
uploader's UCI setting and boot service, then restarts the uploader.
Pending readsb or uploader edits must be explicitly committed or
reverted before activation.
There is one uploader selection; changing it replaces the previous
selection rather than starting a second upload process.

Upgrades preserve the existing boot-enable state and do not auto-enable
a previously disabled service. Older installations that have no
`feeder` selection must explicitly select one before uploading; the
package never guesses which of several feeders to use.

To watch the uploader:

```sh
logread -e adsbexchange-stats
```

## What gets installed

| Path                                                  | Purpose                                                                              |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `/usr/share/adsbexchange-stats/json-status`           | patched upstream uploader (bash; runs under procd)                                   |
| `/etc/config/adsbexchange-stats`                      | UCI config (declarative; see below)                                                  |
| `/etc/init.d/adsbexchange-stats`                      | procd service and `activate`, `showurl`, `about` actions |
| `/usr/lib/adsbexchange-stats/functions.sh`            | shared sh helpers (logging, UUID, json path resolution)                              |
| `/usr/lib/adsbexchange-stats/json-status-helpers.sh`  | upload-side helpers (curl wrapper, periodic summary)                                 |
| `/var/run/adsbexchange-stats/`                        | runtime dir (env file, uuid, scratch JSON; tmpfs)                                    |

## Configuration

`/etc/config/adsbexchange-stats` is **declarative-only by design** --
it carries options, not documentation. Comments (lines starting with
`#`) do not survive `uci commit`: every committer (manual `uci`, LuCI,
this package's own reload trigger, `readsb-uuid`) rewrites the file in
canonical form and strips them. All option documentation therefore
lives in this source-repository README and in `service adsbexchange-stats about`, never
inside the conffile itself. (The same convention is used by the
companion `readsb-wiedehopf` package.)

The init script reads the conffile together with the selected feeder's
UUID and `readsb.main.write_json` from `/etc/config/readsb`, renders an env
file at `/var/run/adsbexchange-stats/env`, and supervises the uploader
under procd.
Scalar values in that generated file are shell-quoted, including log
tags and runtime paths; quotes, whitespace, and shell punctuation are
preserved as data rather than interpreted as commands.

The shared helpers preserve preconfigured `ADSBX_RUNTIME_DIR`,
`ADSBX_ENV_FILE`, `ADSBX_UUID_FILE`, and `ADSBX_UPLOADER` values.
When file paths are unset, they are derived from the runtime directory.

Reload triggers are registered on **both** `adsbexchange-stats` and
`readsb`, so the recommended workflow is:

```sh
uci set adsbexchange-stats.main.<option>=<value>
uci commit adsbexchange-stats
service adsbexchange-stats reload
```

### `/etc/config/adsbexchange-stats` -- main section options

Only the named `config adsbexchange-stats 'main'` section is supported.
Additional sections do not create uploader instances and cannot override
the main section's consent, feeder selection, or environment. A missing
or incorrectly typed main section is reported as a configuration error.

| Option                 | Default | Notes                                                                                                                                                          |
| ---------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `enabled`              | `0`     | separate opt-in for external statistics uploads; installation alone does not change it |
| `feeder`               | empty   | one enabled `adsbexchange` feeder section in `/etc/config/readsb`; chosen by the setup wizard or `activate` |
| `json_paths_override`  | empty   | space-separated list of directories searched for `aircraft.json`, in preferred order. Empty = derive from `readsb.main.write_json` plus built-in fallbacks. Tokens are restricted to `[A-Za-z0-9/_.+-]`. |
| `log_level`            | `1`     | uploader verbosity: `0` errors only, `1` + periodic summary, `2` + per-cycle line, `3` + redacted curl `-v` diagnostics |
| `log_summary_interval` | `300`   | seconds between summary lines at `log_level >= 1`                                                                                                              |
| `dns_cache`            | `0`     | enable the uploader's in-process DNS self-cache. Auto-disabled if a `127.0.0.0/8` resolver is in use or if `host`/`perl` are missing.                          |
| `dns_ttl`              | `600`   | DNS cache TTL in seconds when `dns_cache=1`                                                                                                                    |
| `dns_ignore_local`     | `0`     | when `dns_cache=1`, set to `'1'` to bypass the cache for `127.0.0.0/8` answers                                                                                 |

The uploader and selected feeder accept OpenWrt's true boolean values
`1`, `on`, `true`, `yes`, and `enabled` consistently at startup and before
uploads. False or unrecognized values do not authorize uploading.

`json_paths_override` resolution order:

1. `option json_paths_override` (this file)
2. `readsb.main.write_json` from `/etc/config/readsb`, plus the built-in
   fallbacks (`/var/run/readsb`, `/run/adsbexchange-feed`, `/run/dump1090`,
   `/run/dump1090-fa`)
3. built-in fallbacks alone

Tokens that contain shell-metacharacters are dropped at startup with a
`warn`-level log line.

## Station UUID

The uploader uses the identity of the selected ADSBexchange feeder:

1. Nonempty `readsb.<feeder>.uuid`, if configured.
2. Otherwise `readsb.main.uuid`.

A malformed override is rejected, not silently replaced by the main
UUID. The station fallback can be managed with:

```sh
readsb-uuid                # interactive: generate / show / replace
readsb-uuid --auto         # non-interactive: generate if missing
readsb-uuid --print        # print current value
```

The init script never auto-generates the UUID, because doing so would
race with `readsb-uuid` running concurrently on the same box. If
the selected feeder is missing, disabled, not an ADSBexchange preset,
or its effective UUID is missing/malformed, the service refuses to
start with an explicit error. The upload wrapper rechecks consent,
selection and identity before each request. If the feeder is disabled,
removed, reassigned, or its UUID changes without a reload, uploads are
blocked rather than sent under stale consent or identity.
Request-time checks use one keyed UCI batch snapshot per upload rather
than spawning a separate UCI process for each setting. A failed or
incomplete snapshot blocks the request; configuration values are not
cached across upload cycles.

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
service adsbexchange-stats about       # package help (not procd's built-in info)
```

`showurl` uses the selected feeder's effective UUID, matching
`readsb-feeder --url <selected-feeder-name>`.

After the uploader stops, the service removes its environment, UUID,
temporary JSON files, compressed upload, and fallback curl diagnostics.
Unexpected files are retained with a warning rather than recursively
deleted.

To revoke upload permission without disabling the normal feed:

```sh
uci set adsbexchange-stats.main.enabled=0
uci commit adsbexchange-stats
service adsbexchange-stats stop
service adsbexchange-stats disable
```

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
| `3`         | + redacted curl `-v` diagnostics (TLS handshake; verbose, mostly useful for debugging) |

Curl diagnostics redact the station UUID, authorization headers, and
cookies before logging, including on transport failures. Hostnames,
addresses, URLs, and other connection details remain visible; use level
3 only when needed for troubleshooting. Startup notices omit the UUID.

Errors go to syslog and, by default, stderr for interactive or scripted
commands. Procd sets `ADSBX_LOG_STDERR=0` for the uploader to prevent
duplicate errors through captured stderr; manual callers can use the
same flag to suppress stderr explicitly.

Init-script lifecycle events (start, stop, refused-UUID, unsafe path
token) log at `notice` / `warn` / `err` regardless of `log_level`.
Aircraft/byte metrics are normalized as decimal unsigned integers
before accounting. Empty, malformed, negative, fractional, or oversized
values use zero with a warning instead of breaking shell arithmetic.
The same checked integer conversion is used for DNS and summary
interval settings, with their documented defaults on invalid input;
individual inputs must be within `0`..`2147483647`.

## Relationship to readsb-wiedehopf

This package **hard-depends** on `readsb-wiedehopf` (`DEPENDS:= ...
+readsb-wiedehopf`) for three reasons:

* **Selected feeder identity.** The uploader follows that feeder's UUID
  override or the common station UUID. It never chooses an arbitrary feeder.
* **Shared helpers.** `/usr/lib/readsb/functions.sh` provides
  identity validators and checked private UCI update helpers, which
  this package's helpers source. Feeder-aware activation requires the
  matching readsb companion-integration update.
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
| `readsb-feeder --url <name>` | Prints the named feeder's stats URL. With the selected name it matches `showurl`; works without the uploader installed. |
| `readsb-feeder --companions [adsbexchange]` | Shows cached availability, installed/disabled/running state, and the selected feeder. Missing or disabled uploads are optional, not faults. |
| `readsb-feeder --setup-companions <name>` | Default-No consent to optional installation and feeder-specific activation; only for an enabled feeder. |
| `readsb-setup --status`                   | Same companion-package check as above; surfaces this package's `controls` line including the `showurl` extra action.                            |
| `readsb-setup --health` | Shows uploader logs when uploads are opted in; deliberately disabled uploaders do not degrade daemon health due to old warnings. |

The optional service is independent of readsb's daemon lifecycle.
Uploader failures do not stop normal decoding or feeder connections.

## Tests

From this package's feed root, with the companion-aware decoder source
available:

```sh
sh utils/adsbexchange-stats/tests/stats.sh /path/to/utils/readsb-wiedehopf
```

The tests use mocked UCI, procd, package hooks and HTTP calls. They cover
default-off installation, upgrade enable-state preservation, selected
feeder UUID resolution, explicit activation, option validation and
per-request consent/identity guards. They perform no uploads or host
configuration changes. Run with `bash` or `busybox ash` as well for
shell compatibility.
The shared helpers target OpenWrt's BusyBox ash and are tested with
dash and Bash; they use the supported `local` extension and do not
claim strict POSIX-only portability. Test cleanup preserves the test
exit status and warns about leftovers without recursively deleting
unexpected files.

## License

Licenses by component:

* OpenWrt packaging files (Makefile, init script, helpers, patches) --
  GPL-2.0-only (matches the surrounding OpenWrt feed).
* Upstream `json-status` payload (ADSBexchange.com, (c) 2020) -- MIT,
  preserved as-is in the source tarball.
