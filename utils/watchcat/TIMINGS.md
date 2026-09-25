# watchcat timing notes

This file documents the intended timing for the `restart_iface` and
`run_script` paths in `watchcat.sh`, especially around the optional
`reset_failure_timer` flag.

The main point is that the repeated restart window in the default behavior is
intentional. It is not an accidental side effect.

## Terms

- `failure_period`: how long failed reachability must continue before the
  recovery action is triggered
- `ping_frequency_interval`: how often reachability is checked
- `recovery action`: either restarting the interface or running the configured
  script

## Default behavior

By default, watchcat is meant to keep retrying during a sustained outage.

This is useful for cases like WireGuard or OpenVPN, where the upstream
internet may recover before the monitored path through the tunnel becomes
usable again. Since watchcat is probing through the monitored interface, it
may continue to see failed checks until that interface is restarted again.

In this mode, if failed checks continue and the outage lasts long enough to
cross multiple trigger windows, multiple recovery attempts are expected.

Example:

- `failure_period=60`
- failed checks continue throughout the outage
- the recovery action itself takes 15 seconds

```text
t=0    outage starts
t=60   restart #1 starts
t=75   restart #1 finishes
t=120  restart #2
```

If connectivity has recovered by the next check, there should be no further
restart. If failed checks continue and another trigger window is crossed,
another restart is expected.

## `reset_failure_timer=1`

This mode is more conservative.

Once the recovery action finishes, a fresh failure window starts from that
point. Time spent inside the recovery action no longer counts toward the next
trigger.

Example:

- `failure_period=60`
- failed checks continue throughout the outage
- the recovery action itself takes 15 seconds

```text
t=0    outage starts
t=60   restart #1 starts
t=75   restart #1 finishes
t=135  restart #2 would be the earliest next retry
```

This mode is useful when repeated or closely spaced recovery actions are less
desirable and a fresh failure window is preferred after each completed action.
