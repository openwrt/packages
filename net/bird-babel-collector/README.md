# bird-babel-collector

Samples the Babel neighbours and default route selection of BIRD into an
in-memory history of up to 24 hours and serves it on ubus as `bird-babel`.
It is the backend of luci-app-bird-babel. A single ucode script
(`files/bird-babel-collector`), run by procd.

These notes explain how it works and why, for whoever changes it next.

## Data sources

- BIRD's control socket, opened in restricted (read-only) mode, without
  forking birdc: `show babel neighbors`, `show babel interfaces`, the
  default routes of the Babel tables (`show route ... for 0.0.0.0/0 all`,
  sadr tables for IPv6), and rarely `show babel routes` for standby
  routes (stock BIRD only puts the best route into the table).
- Names: the hosts files (`/etc/hosts`, `/tmp/hosts/*`), reverse DNS via
  the local resolver, and the IPv4 address in Babel router IDs
  ("randomize router id" puts it in the last four bytes). Found names are
  kept per device (MAC) for a week.
- Vendor and model: the neighbour's `luci-rpc getBoardJSON`, where it is
  open to anonymous sessions (over IPv4 or link-local IPv6).

## Sampling

The interval follows the RAM (`SAMPLE_TIERS`): 60 s below 96 MB, 30 s
below 192 MB, 15 s below 384 MB, else 4 s. 4 s is BIRD's default Babel
hello interval; link cost and RTT only change with hellos, sampling faster
would only repeat them. `option interval` overrides it.

## History storage

Per neighbour, one string per 15 minutes (`BLOCK`, on multiples of 900 s):

    header      start (u32), seconds covered (u16), records (u16), histogram bytes (u16)
    15 x        minute summary (MIN_FMT, 22 bytes): seconds present, cost
                sum/min/max, seconds with an RTT and its sum/min/max, role4,
                role6 (ROLE_MIXED unless the same for the whole minute)
    histogram   sparse (bin u8, seconds u16) pairs, cost then RTT after a 255;
                8 bins per octave, for the 99th percentiles
    records     8 bytes each (REC_FMT): seconds into the block, cost, RTT
                (0.1 ms), role4, role6; one whenever any value changes

- A record lasts until the next one. A neighbour that disappears gets a
  record with role ROLE_ABSENT. The block being filled keeps its records
  in a growing string (`hist[key].open`) and gets its summaries when it
  closes.
- `state.cover` lists the stretches the collector sampled; records are
  clipped to it, and its gaps are reported as "no data". A gap of up to
  two sampling intervals still counts as continuous.
- Everything is weighted by seconds, not samples, so averages and
  percentiles do not depend on the sampling interval.
- Data older than 24 hours ages out by whole blocks. `memory_budget`
  (default 1/64 of RAM, 256 KiB to 16 MiB) only shortens the history if
  it is ever reached.

Why change records: on a real router 94% of 1 s samples repeated the
previous one, and ucode spends far more on object bookkeeping than on the
data. Measured for 8 neighbours over 24 hours:

| layout                                    | memory      |
|-------------------------------------------|-------------|
| 6 byte sample per interval, 60-sample chunks with summary objects (the first version) | ~39 MB |
| change records in 15 minute blocks, stable links | 0.7 MB (1.5 MB for the whole process) |
| change records, RTT changing on every hello      | 1.8 MB (2.6 MB for the whole process) |

Run length encoding per field was 13-32% smaller but needs three streams
merged per query. Delta, delta-of-delta and Gorilla style XOR encodings
were no smaller in practice: they decode every sample, so they need dense
summaries to keep queries fast, and bit operations are slow in ucode. zlib
and xz need modules and cannot seek. A 6 byte sample per interval in
packed strings (no compression) would take ~6 MB.

## Queries

`history` buckets the series of each neighbour:

- Buckets are at least the sampling interval, whole minutes from a minute
  up and a divisor of a minute below, and start on multiples of their
  width. So they line up with the minute summaries and the blocks, and a
  refresh does not reshuffle samples.
- Whole minutes inside a bucket come from the minute summaries, when the
  neighbour was present all minute with the same roles; everything else
  is replayed from the records, clipped to the coverage. Ranges that do
  not start on a whole minute with buckets of a minute or more would
  replay everything; the bucket choice above avoids that.
- With `since`, only buckets from there on are computed, without
  percentiles: the UI polls with it every 30 s and keeps what it has.
  Merging the histograms of all blocks is most of a full query's cost.
- Percentiles come from the block histograms (block granularity at the
  range edges, ~9% resolution). They cannot be exact client side, the UI
  only gets bucket averages, minimums and maximums.
- Results are cached briefly (a few entries). Calls without a login (the
  all-zero session, for a public status page) are rounded so viewers share
  cached results, and those that need computing are rate limited; polls
  for the last few minutes are not.

Measured for 8 neighbours over 24 hours (x86-64): a full 24 h query
~200-240 ms, a poll ~20-35 ms.

## Route to the gateway

`status` has `route4` and `route6`: the next hop and the originator of the
selected default route from BIRD (its address from the router ID, looked up
only if private), whether the next hop is the gateway, and the traced path.

Babel is distance-vector, so the routers in between are found with
traceroute (`TRACE_*`): only when the selected route switches to one
without a path from the last hour (a route flapping between two known paths
needs none), and again while the gateway was not reached; at most every
5 minutes per family. Paths are kept per route. Until a path is known,
`trace_next` says when the next trace runs. The IPv4 target is the address
in the router ID; the IPv6 target an address in a prefix the originator
announces, and the first hop inside it is the gateway.

## Saving to flash

Off by default (`option persist`). History is saved gzip compressed only
when the collector stops (reboot, shutdown, restart; procd allows 60 s),
right before sysupgrade or a config backup takes the file (the
`/lib/upgrade` hook calls `save`), and on `ubus call bird-babel save`.
Written to a temporary file and renamed. The format (`version: 4`) is JSON
with the blocks base64 encoded; other versions are not read.

## ubus

- `status`: live data (refreshed at most once a second): neighbours with
  names, roles and link quality, interfaces, default routes, the routes to
  the gateways, the collector's interval, budget, history size and oldest
  data.
- `history { range, points, end, since }`: see above.
- `events { since }`: neighbour and default route changes.
- `save`: save now (local only, not in the LuCI ACL).

## ucode notes

- Under `-S` a function must be declared before any function using it is
  compiled; later declarations give "access to undeclared variable" at
  runtime.
- Integer division truncates: `int(x) / 100` is an integer, use `100.0`.
- A `'\x8b'` string literal is UTF-8 encoded; compare raw bytes as hex.
- Build `struct` formats once per size and reuse them (`unpacker()`),
  creating them is slow.
- Many small objects cost far more than the data in them; keep bulk data
  in packed strings.

## Tests

`tests/bird-babel-collector` in the development repository: recorded BIRD
conversations replayed to the collector in an OpenWrt container (`run.sh`),
and a history test with changing replies, checking the queries and a save
and restart (`history-test.sh`).
