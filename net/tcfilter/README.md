# tcfilter

A thin UCI front-end for persistent `tc filter ... ingress` rules.

It does **not** model the flower match/action fields. You write that part as
raw `tc` syntax in `option spec`; the package only manages the device, the
`pref` number, enable/disable, persistence across boot, and re-applying the
rules when the network is reconfigured.

Meant for driving hardware tc-flower offload (e.g. the Realtek DSA PIE
offload) where no higher-level config layer exists.

## Config

`/etc/config/tcfilter`:

```
config tcfilter 'global'
	option enabled '1'

config rule
	option label   'Drop-HomePlug-AV (FRITZ!Box)'
	option device  'lan1'
	option enabled '1'
	option pref    '49152'
	option spec    'protocol 0x88e1 flower skip_sw action drop'
```

The shipped default config carries a few such rules with `enabled '0'`
as ready-to-use examples (FRITZ!Box powerline discovery, mDNS) — set
`device` and flip `enabled` to `1`.

`label` is optional and cosmetic — it only tags the log messages and the
LuCI rows.

`spec` is everything that would follow

```
tc filter add dev <device> ingress pref <pref>
```

* `pref` is **required** — it is how the rule is deleted again.
* Use `skip_sw` so a match the hardware cannot offload fails loudly instead
  of silently installing in software.
* One `rule` per `pref` per device.

## Commands

```
/etc/init.d/tcfilter start        # apply all enabled rules
/etc/init.d/tcfilter stop         # remove them
/etc/init.d/tcfilter reload       # stop + start
/etc/init.d/tcfilter show         # tc -s filter show for every configured device
/etc/init.d/tcfilter reapply_dev lan1
```

## Notes / limitations

* ingress / `clsact` only.
* The `clsact` qdisc is added if missing but never removed on stop (other
  users may share it); only the individual filters are deleted.
* Installed `(device, pref)` pairs are tracked in `/var/run/tcfilter.state`
  so a rule removed from the config is still torn down on the next reload.
* Re-apply hooks: `hotplug.d/iface` runs `start` on `ifup`, `hotplug.d/net`
  runs `reapply_dev` on netdev `add`. `start` is idempotent.
* A `procd_add_reload_trigger` reloads the service when the `tcfilter`
  config changes, so LuCI Save & Apply and `uci commit tcfilter &&
  reload_config` take effect on their own; a bare `uci commit` still needs
  an explicit `/etc/init.d/tcfilter reload`.
* No dry-run validation — an invalid `spec` is reported via logread only.
* Free-form `spec` is passed to `tc` by word-split (no shell). Anyone who can
  edit the config can install redirect/mirror rules, i.e. tap traffic.

### Hardware packet counters (Realtek rtl930x PIE offload)

Older rtl930x kernels mis-read the per-rule LOG packet counter: with more
than one offloaded flower rule, only the rule whose PIE rule id was
even-aligned reported a working `tc -s` hardware packet count and the
others stayed at 0 (`rtl930x_packet_cntr_read()` assumed the L3-route
counter layout). Dropping / trapping / redirecting was never affected.

Fixed in the kernel driver upstream (openwrt/openwrt#24994); every
offloaded rule now reports its own count. Firmware built before that
patch still shows the old behaviour.
