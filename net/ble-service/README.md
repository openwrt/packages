# BLE service (experimental)

This package builds the standalone
[OpenWrt Orbi BLE service](https://github.com/Leo-ATP/openwrt-orbi-ble-service)
at the fixed `v0.1.1` source commit. It provides the rpcd object `ble` and six
methods: `status`, `start`, `stop`, `scan`, `connect` and `disconnect`. It is
usable directly through authenticated ubus/rpcd calls and does not require a
web UI.

**This backend is Orbi RBR50/RBS50 v1-specific, not a general adapter manager.**
It accepts only the exact `netgear,rbr50` and `netgear,rbs50` board identities,
with the same UART and controller ownership checks on both. Other boards and
v2 identities remain rejected. RBS50 acceptance originally followed a
successful prototype migration using the same volatile initialization
sequence. The exact v0.1.1 package payload was subsequently validated on an
RBS50 v1 running Linux 6.18.55 with the upstream-enabled UART; exact RBR50
package validation remains pending.

The source is fetched from the public repository at the immutable commit
`11778dbc07536a8c99cf4ecd3563e0bb39e8a3f7`, also referenced by the annotated
tag `v0.1.1`, and verified by the OpenWrt mirror hash. No prebuilt binary or
runtime UART-registration module is used. The service source is GPL-2.0-only
through its root `LICENSE`, SPDX headers and package metadata. The only Go
dependency, `github.com/godbus/dbus/v5` v5.1.0, is pinned by `go.mod` and
`go.sum`; its original BSD-2-Clause notice is retained as `LICENSE.godbus`.
No license file is copied from the feed root or installed into the target
filesystem.

## Hardware and ownership boundary

The candidate requires the device-tree UART enablement proposed in
[openwrt/openwrt#26072](https://github.com/openwrt/openwrt/pull/26072)
(current candidate `2ce7662fb47cb384c8668a0d0c8f4dd7587e1e85`; patch-identical
runtime-tested candidate `2312ef8821bf3c999108a2f6b45675a3e461d618`):

- `/soc/serial@78b0000`, `qcom,msm-uartdm-v1.4`, registers
  `0x078b0000` / `0x200`, enabled and bound to `msm_serial`;
- GPIO8-11 assigned to `blsp_uart1` by the device tree;
- the standard `kmod-hci-uart` with BCSP and `hciextn=Y`, plus the packaged
  BlueZ `hciattach`, `hciconfig`, `hcitool` and `bluetoothd`.

The service discovers the unique TTY through its device-tree ancestry. It
accepts either the older direct `platform/msm_serial -> tty` hierarchy or
Linux 6.18's exact `platform/msm_serial -> serial-base/ctrl ->
serial-base/port -> tty` hierarchy. Every layer must retain the target
device-tree node and exact subsystem and driver identity. It does not assume
`ttyMSM1` or `hci0`, rebind the UART, add aliases, or touch the console or
GPIO48.
The node must be enabled in the running device tree on either board; a legacy
runtime UART-registration module does not satisfy this requirement.
The HCI must be a descendant of that TTY. Operations recheck the live child,
TTY and HCI identity; an existing controller or an open TTY blocks attachment.
The foreground `hciattach -n -t 10 -s 115200 <tty> bcsp 115200 noflow` process
is a directly owned child, not a PID read from a reusable PID file. BlueZ's
BCSP implementation supplies even parity.

The service-owned isolation model is intentionally retained:
one root-only isolated D-Bus and one service-owned, official `bluetoothd`.
All optional BlueZ plugins are disabled, the controller is non-pairable and
non-discoverable, and there is no automatic scan or connection. BlueZ core
still performs service discovery and may write the standard Service Changed
CCC; this is not an application GATT-write interface.

**There must be no other `bluetoothd` or HCI controller on the host.**
`/var/lib/bluetooth` must be absent or a real directory with this service's
ownership marker, on OpenWrt's volatile `/var`. An existing directory without
that marker, or the stock symlink to `/etc/bluetooth/keys`, is rejected.
Neither the daemon nor package installation stops/disables an existing
Bluetooth service, changes the system bus, removes that symlink, or imports
pairing keys. An administrator must explicitly arrange a dedicated, exclusive
installation before using this candidate. Installation alone does not resolve
these conflicts; with the stock `bluetoothd` enabled, BLE startup will fail
explicitly rather than take over.

The procd init service is `/etc/init.d/ble`. Normal OpenWrt service enablement
starts it once at boot; no respawn policy is installed. It owns a root-only
Unix control socket under `/var/run/ble-service`, never a TCP listener.
Runtime package installation and removal reload `rpcd` so the exec object
appears or disappears immediately; image-root installation skips that reload.
No anonymous RPC ACL, pairing, trust, application-specific GATT API, automatic
peripheral workflow or external client leases are included. This package does
not install a web UI or client ACL.

## Volatile CSR initialization

Each Start performs an initial GET, then exactly one SET of
`PSKEY_ANA_FREQ` (`0x01fe`) to **26000 kHz (26 MHz)** in **PSRAM store 8**,
one matching GET, one warm-reset dispatch, same-TTY detach/reattach and a
post-reset GET. The controller is brought down again before BlueZ starts.
The initial GET is a response/identity gate; its value does not skip the SET.

Command echoes, response size, sequence, variable ID, key and store are checked.
The candidate also checks the complete observed SET response payload (the
prototype returned type 1), rather than accepting only sequence/status.
A warm-reset timeout with an exact command echo proves dispatch only, not
reset completion; reattachment and post-GET are still mandatory.

The pending marker `/var/run/ble-service/ana-freq.pending` is created before
SET. A failed mutation retains it and blocks another Start until reboot
clears the volatile runtime. There is no loop, automatic retry, marker-clearing
RPC, EEPROM/ART/calibration/bootloader access, factory address programming,
or GPIO reset. In-flight mutation and attach steps finish under bounded
contexts even after Stop, then cleanup runs. The procd termination window
is 150 seconds.

Stop first reports `stopping`, cancels bounded operations, and stops only owned
processes. Storage is removed only after the owned BlueZ process has exited.
HCI detach is gated on BlueZ, the isolated bus daemon and its client lifetime
all ending. A changed owner or incomplete shutdown is an explicit failure,
not permission to kill another process or overwrite another controller.
The device-tree UART remains bound. A state-persistence error is reported but
does not suppress an already requested shutdown.

## RPC contract

rpcd's exec signature is exactly:

```json
{
  "status": {},
  "start": {},
  "stop": {},
  "scan": { "seconds": 32 },
  "connect": { "address": "" },
  "disconnect": { "address": "" }
}
```

`32` denotes an integer argument type, not a scan duration or default.
`status`, `start` and `stop` take `{}`. Scan requires integer `seconds`
from 5 through 10 inclusive. Connect/disconnect require a complete,
colon-separated Bluetooth address; lowercase hex is accepted and normalized
to uppercase. rpcd's `ubus_rpc_session` metadata is accepted. Unknown or
duplicate fields, non-object input and trailing JSON are rejected.

A successful ready response has this shape; all addresses here are synthetic:

```json
{
  "ok": true,
  "state": {
    "version": "0.1.1",
    "phase": "ready",
    "adapter": {
      "hci": "hci4",
      "address": "02:00:00:00:00:FE",
      "powered": true,
      "discovering": false
    },
    "devices": [{
      "address": "02:00:00:00:00:01",
      "address_type": "random",
      "name": "Example sensor",
      "rssi": -60,
      "connected": false,
      "paired": false,
      "services_resolved": false,
      "uuids": []
    }]
  }
}
```

`detail` is optional, `rssi` is optional and measured in dBm, `address_type`
is `public` or `random`, and `devices` is always an array. Connected devices
sort first, then by address. Non-ready states omit `adapter` and have an empty
device array. The phases are `stopped`, `starting`, `ready`, `stopping` and
`failed`.

Start can return `ok:true` with `starting` while initialization continues.
Stop normally returns `stopping` before teardown completes. Neither response
means the transition is complete. A UI may follow a user-triggered transition
with bounded status requests; the backend does not start a scan for it.
Connect succeeds only after `Connected && ServicesResolved`. A failed fresh
connection attempt is cancelled, but failure while waiting on a connection
that was already established does not disconnect that pre-existing link.

Errors generally contain `ok:false`, `code`, `error`, optional `state` and
`retryable`. The preserved codes are:

| Code | Retryable | Meaning |
| --- | --- | --- |
| `INVALID_REQUEST` | false | Invalid method or parameters |
| `INTERNAL` | false | Lifecycle, state or D-Bus read failure |
| `BACKEND_STOPPED` | true | Operation could not reach the daemon |
| `BUSY` | true | Another scan/connect/disconnect is in progress |
| `SERVICE_NOT_READY` | true | Daemon is not ready |
| `DEVICE_NOT_FOUND` | true | Scan/connect failed (historical mapping) |
| `DEVICE_NOT_CONNECTED` | true | Disconnect failed |

The prototype's status semantics are retained: a live `failed` state may
return `ok:false` and `error` without `code`/`retryable`. Reading a saved
`failed` state with no process can return `ok:true`; this also permits an
inactive Stop to preserve an old failure without reporting a new Stop error.
**Always inspect `state.phase`; do not infer readiness from `ok`.**
A stale saved `ready` state is reported as `failed`, never fabricated readiness.

| Request | rpcd wrapper deadline | Daemon operation deadline |
| --- | --- | --- |
| status | 6 seconds | 4 seconds |
| start | 8 seconds | wait-ready: 4 seconds per request |
| stop | 8 seconds | shutdown response: 2 seconds |
| scan/connect/disconnect | 16 seconds | 14 seconds |

Scan has an independent 2-second StopDiscovery cleanup. Connect waits up to
10 seconds and has a 2-second failure cleanup. Long startup/teardown runs in
the daemon, not inside rpcd's request timeout.

### Current named-device presentation policy

The service preserves the prototype's **current named-device presentation
policy**. `snapshot` uses BlueZ Device1 `Alias`, trims whitespace, and excludes
empty aliases, separator-only aliases, or aliases whose normalized identifier
equals the device's own MAC. The existing normalization accepts colon, hyphen,
underscore, dot and Unicode whitespace separators. A different MAC-like alias
is not excluded merely for looking like an address.

This filters the returned device list, also used for selection. It does **not**
stop RF/HCI scanning and does **not** mean that an omitted device lacks BLE
support. It can hide legitimate unnamed peripherals. The default is retained
for review, not presented as an ideal universal policy; no show-all switch is
added.

## Evidence and remaining work

FCC ID **PY316200341** documents the corresponding hardware/software capability:

- Attachment **3510567**, "Description of Permissive Change", 2017-08-14, p.1:
  "adding BT LE function through software enabling".
  [Official FCC attachment](https://apps.fcc.gov/eas/GetApplicationAttachment.html?id=3510567);
  [verified document mirror](https://fccid.io/PY316200341/Letter/Cover-Letter-Description-of-Change-rev-2-pdf-3510567.pdf).
- Attachment **3926908**, report RF160621C27V-2, issued 2018-06-04:
  p.1 names RBR50 and the RBS50 series, p.4 identifies an engineering sample,
  and p.6 section 3.1 note 3 says the models are electrically identical except
  firmware, with RBR50 the representative.
  [Official FCC attachment](https://apps.fcc.gov/eas/GetApplicationAttachment.html?id=3926908);
  [verified document mirror](https://fccid.io/PY316200341/Test-Report/Test-Report-DTS-BT-LE-rev-3-pdf-3926908.pdf).
- [Internal photos, attachment 3926901](https://fccid.io/PY316200341/Internal-Photos/Internal-Photos-RBR50-RBS50-rev-pdf-3926901.pdf),
  PDF p.9 / printed p.17, label a "BT Module".

The official attachment endpoints returned HTTP 403 during preparation;
verification used the linked mirrors of the FCC documents, not an assertion
that `fccid.io` is an official FCC domain. These records concern the submitted
series/engineering samples, not every production revision or this package.

The old RBR50 prototype worked on OpenWrt 25.12.5 / Linux 6.12.94, including
LE reception and connections. On 2026-10-20, the v1.11.1 prototype was also
migrated to an RBS50 v1 on the same OpenWrt/kernel versions. That migration
completed the same PSRAM store 8 / 26000 kHz SET, GET, warm reset, same-TTY
reattachment and post-GET sequence, exercised UART/HCI/LE operation, and
reached `ready` before and after a controlled reboot. These are prototype
results using its legacy runtime UART module, not an installation or runtime
test of this package or the proposed Linux 6.18 device-tree input. They justify
using the same initialization path for the two exact v1 board identities,
without generalizing to other hardware.

The v0.1.1 source and package payload were subsequently installed on an RBS50
v1 running Linux 6.18.55 with the upstream-enabled UART. After a cold boot,
rpcd exposed the exact six methods immediately. Start reached `ready` in about
10 seconds after the 26000 kHz PSRAM SET/GET, warm reset, same-TTY reattach and
post-GET sequence. The owned HCI was UP/RUNNING with CSR manufacturer 10. A
10-second scan and status refresh found a named validation peripheral; connect
reached `Connected && ServicesResolved`, followed by successful disconnect and
Stop. An authenticated RPC client completed the same lifecycle. With the
service enabled, one controlled reboot returned automatically to `ready` with
the HCI up before another successful Stop. No Pair, Trust or
application-specific GATT write was performed.

A sysupgrade-preserved legacy `ttyMSM1::askfirst` entry initially retained the
UART. Restoring the candidate image's default `askconsole` inittab removed that
pre-existing ownership conflict; a subsequent cold boot produced the passing
result above. This is consistent with the backend's fail-closed ownership
policy, not a package-code failure.

Known follow-up work:

- exact RBR50 v1 runtime validation with this package and the enabled upstream
  device-tree UART;
- broader repeated-lifecycle, power-cycle and RF coexistence coverage beyond
  the completed RBS50 cold-boot and controlled-reboot validation;
- unique public BD_ADDR / factory address byte order, unresolved in the
  prototype; no hardcoded address or factory ART data is used here;
- maintainer agreement on the standalone source repository, service-owned
  isolated BlueZ model and the named-device presentation policy.

GPIO48 hardware reset has not been validated and is not implemented.

## Local checks (no Bluetooth hardware)

From a standalone source checkout or the `v0.1.1` archive, with Go 1.24 or
newer and `dbus-daemon` available on Linux:

```sh
gofmt -l *.go
go test -mod=readonly -race -count=1 -timeout=90s .
go vet -mod=readonly .
GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=0 \
  go build -mod=readonly -trimpath -buildvcs=false -o /tmp/ble-service .
```

The tests use synthetic device addresses, isolated D-Bus instances and temporary
sysfs/process fixtures. They never run the real hardware preparation path.
`test.sh` checks only version, the exact RPC whitelist and invalid-parameter
rejection. A Go cross-build is not an OpenWrt SDK build or hardware validation.
The final external-source package definition was also built with the official
OpenWrt 25.12.5 ipq40xx SDK. That package build does not establish installation
or hardware runtime behavior.
