# Tailscale
This readme should help you with tailscale client setup.

## Install
There are two packages related to tailscale. Tailscaled (daemon which has to run every time you want to be connected to VPN) and tailscale (package with a utility which is necessary for registering device).

To install them run
```
opkg install tailscale tailscaled
```

## First setup

First, enable and run daemon

```
/etc/init.d/tailscale enable
/etc/init.d/tailscale start
```

Then you should use tailscale utility to get a login link for your device.

Run command and finish device registration with the given URL.
```
tailscale up
```

After that, you should see your router in tailscale admin page.
