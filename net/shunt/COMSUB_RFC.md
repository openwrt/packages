# RFC: ComSub - asynchronous community domain subscriptions for shunt

This is a design/RFC patch for adding remote community domain lists to `shunt`
without changing the routing model or making the daemon wait on network I/O.

The goal is to keep `shunt` small and resolver-independent while making large,
community-maintained domain sets practical.  The proposed name for the feature is
**ComSub** (Community Subscriptions).

## Why

Today a policy accepts repeated `list domain` entries.  This is excellent for a
small hand-maintained set, but awkward for community lists containing thousands or
tens of thousands of domains.  Expanding such lists into UCI is also undesirable:
UCI should store subscription metadata, not the downloaded dataset.

The existing matcher is already a good fit for this feature: policies are parsed
into `domains[]`, then `match.compile()` builds the exact/wildcard maps used by
both passive DNS snooping and active resolution.  ComSub should therefore be an
input layer between UCI parsing and matcher compilation, not a new routing engine.

## Proposed UCI model

```uci
config source 'antifilter'
        option enabled '1'
        option type 'remote'
        option url 'https://example.org/domains.txt'
        option format 'domains'
        option refresh '43200'
        option active_poll '0'

config policy 'vpn'
        option interface 'wg0'
        list source 'antifilter'
        list domain 'my-local-exception.example'
```

`list source` and ordinary `list domain` entries are additive.

Downloaded content must never be written back as thousands of UCI `list domain`
entries.  A source is cached as a plain file, for example under
`/tmp/.shunt/comsub/` initially; a persistent cache directory could be considered
later if desired.

## Non-blocking requirement

The routing daemon must never wait for a ComSub download.

Startup behaviour:

1. Load configuration and any last-known-good cache immediately.
2. Build/apply routing and nftables state immediately.
3. Start passive DNS observation and the normal poll loop immediately.
4. Schedule missing/stale ComSub sources for background refresh through `uloop`.
5. When a background download completes successfully, parse and validate the
   temporary file, atomically replace the cache, and rebuild only the domain
   matcher/source view needed by DNS learning.

If the network is down, a server hangs, DNS for the source URL fails, or the new
file is invalid, normal shunt routing continues unchanged.

A source update must be **single-flight**: if an update for a source is still in
progress, another timer tick must not spawn a second downloader for the same
source.

## Last-known-good and atomic update

The update sequence should be:

```text
spawn downloader asynchronously
        |
        v
source.tmp
        |
        +-- download failed --------> keep current cache
        |
        v
parse + validate
        |
        +-- empty / HTML / invalid -> keep current cache
        |
        v
atomic rename
        |
        v
rebuild matcher
```

A partially downloaded file must never replace a working cache.

## Large lists must not enter the active poll loop by default

This is the important scaling rule.

A manual domain list is usually small, so the existing behaviour remains useful:
manual domains can be learned by both active polling and passive DNS snooping.

A community list may contain 10k, 50k or more names.  Feeding all of them into the
existing periodic resolver would create an unnecessary DNS storm and defeat the
point of a lightweight daemon.  Therefore remote sources should default to:

```text
ComSub -> matcher -> passive DNS snoop -> learned address -> nft set
```

and **not** to:

```text
ComSub -> resolve every domain every poll interval
```

`option active_poll '0'` should be the default for remote sources.  If support for
active polling of a remote source is retained at all, it should be an explicit
opt-in and probably have a conservative entry limit.

This suggests keeping two logical domain views per policy:

- `domains`: all manual + ComSub patterns used by `match.compile()`;
- `poll_domains`: manual domains plus only sources explicitly allowed to poll.

The existing `poll.names()` can then consume `poll_domains` with almost no change
to the routing/nft side.

## Minimal backend shape

The following is intentionally a sketch, not a claim that these exact APIs must be
used.

### `config.uc`

Parse `config source` sections and source references from policies:

```ucode
let policies = [], sources = [], issues = [];

// source
push(sources, {
        name: s.name,
        enabled: to_bool(v.enabled, true),
        type: v.type ?? 'remote',
        url: v.url,
        format: v.format ?? 'domains',
        refresh: +v.refresh || 43200,
        active_poll: to_bool(v.active_poll, false)
});

// policy
push(policies, {
        // existing fields ...
        domains: to_list(v.domain),
        sources: to_list(v.source)
});

return { global: g, policies, sources, issues };
```

### New `source.uc`

Responsibilities should stay narrow:

```ucode
export function load_cached(sources) {
        // read last-known-good cache files
        // parse domains
        // return { by_source, issues, status }
}

export function expand(policies, cached) {
        // merge referenced source domains into policy.domains
        // build policy.poll_domains separately
        // unknown source references become issues, not fatal errors
}

export function parse_domains(text) {
        // trim whitespace
        // ignore blank lines and # comments
        // one exact or leading-* wildcard pattern per line
        // validation can be shared with shunt.match where practical
}
```

The first format can deliberately be only a plain domain list.  `hosts` or
`dnsmasq` formats can be added later without affecting the rest of the design.

### `shunt.uc`

At startup:

```ucode
let cfg = load_config();
let cached = source_load_cached(cfg.sources);
let expanded = source_expand(cfg.policies, cached);
cfg.policies = expanded.policies;

let matcher = match_compile(cfg.policies);
let targets = poll_names(cfg.policies); // uses poll_domains when present
```

For refreshes, use an asynchronous child integrated with `uloop`; do not call a
blocking `system([ 'uclient-fetch', ... ])` from the main event loop.

Conceptually:

```ucode
function refresh_source(src) {
        if (jobs[src.name])
                return;                 // single-flight

        let tmp = tmp_path(src.name);

        jobs[src.name] = spawn_async([
                '/usr/bin/uclient-fetch',
                '-q', '-O', tmp, src.url
        ], (rc) => {
                delete jobs[src.name];

                if (rc != 0)
                        return source_failed(src, 'download failed');

                let parsed = parse_and_validate(tmp);
                if (!parsed.ok)
                        return source_failed(src, parsed.error);

                atomic_replace(tmp, cache_path(src.name));
                rebuild_domain_matcher();
        });
}
```

The exact child-process helper should follow the ucode/uloop API already preferred
by OpenWrt.  The architectural requirement is that HTTP I/O is outside the main
blocking path.

### `poll.uc`

A minimal compatibility change can keep existing behaviour for hand-entered
patterns while excluding passive-only ComSub entries:

```ucode
for (let p in policies)
        for (let d in (p.poll_domains ?? p.domains ?? []))
                // existing poll target logic
```

No nftables or route compiler changes should be required.

## Status / ubus / LuCI

A useful source status object would expose:

```text
name
state: ready | updating | stale | pending | error
entries
last_success
last_attempt
next_update
cache_age
error
```

This can later feed a small LuCI `Domain Sources` page with an `Update now` action.
The backend feature should not depend on LuCI existing first.

## Failure model

ComSub errors should be local to the source:

- unknown source referenced by a policy: report issue, continue;
- missing cache on first boot: source is pending, continue;
- HTTP/download error: keep previous cache, continue;
- parse error or empty result: keep previous cache, continue;
- one source failing must not disable other sources or policies;
- downloader timeout must not stall DNS snooping, route events or nft refreshes.

This mirrors shunt's current philosophy that bad individual entries are reported
and skipped instead of taking the service down.

## Scope for a first implementation

A deliberately small first patch could support only:

- remote HTTPS/HTTP URL;
- plain domain-list format (`domain.tld` / `*.domain.tld`, comments and blanks);
- last-known-good cache;
- asynchronous/single-flight refresh;
- atomic replacement;
- `list source` references from policies;
- passive-only remote sources by default;
- ubus/log status.

ETag/Last-Modified, additional formats and LuCI can follow separately.

The main design constraint is simple: **community subscriptions extend the domain
matcher, but must not turn network downloads or mass DNS resolution into blocking
work in the shunt daemon.**
