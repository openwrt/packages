# Configuring NTPD with UCI

## Precedent
Sysntpd is the lightweight implementation of the NTP protocol under
Busybox.  It supports many (but not all) of the same parameters.

It is configured as a `config timeserver ntp` section in `/etc/config/system`,
below.

## Configuration

A sample configuration looks like:

**/etc/config/system**:

```
config timeserver ntp
	option enabled 1
	option enable_server 1
	list server tick.udel.edu
	list server tock.udel.edu
	list interface eth0
	list interface eth1
	list interface eth2
```

If you want to temporarily disable the service without deleting all of the
configuration state, this is done by clearing the `enabled` parameter.  If
this parameter is `1` (the default), the service is enabled.

The service can run as a stand-alone client (`enable_server 0`, the default)
or it can also operate as a server in turn to local clients, by setting this
parameter to `1`.

The parameter(s) `server` enumerate a list of servers to be used for
reference NTP servers by the local daemon.  At least one is required,
and two or more are recommended (unless you have an extremely available
local server).  They should be picked to be geographically divergent,
and preferably reachable via different network carriers to protect
against network partitions, etc.  They should also be high-quality
time providers (i.e. having stable, accurate clock sources).

The `interface` parameter enumerates the list of interfaces on which
the server is reachable (see `enable_server 1` above), and may be a
subset of all of the interfaces present on the system.  For security
reasons, you may elect to only offer the service on internal networks.
If omitted, it defaults to _all_ interfaces.

## Differences with `sysntpd`

Busybox `sysntpd` supports configuring servers based on DHCP
provisioning (option 6, per the [DHCP and BOOTP
Parameter](https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml)
list from IANA).  This functionality is enabled (in Busybox) with the
`use_dhcp` boolean parameter (default `1`), and the `dhcp_interface`
list parameter, which enumerates the interfaces whose provisioning
is to be utilized.

### Considerations for DHCP-provisioned NTP servers

Most terrestrial and satellite ISPs have access to very high-quality
clock sources (these are required to maintain synchronization on T3,
OC3, etc trunks or earth terminals) but seldom offer access to those
time sources via NTP in turn to their clients, mostly from a misplaced
fear that their time source might come under attack (a slave closely
tied to the master could also provide extremely high-quality time
without the risk of network desynchronization should it come under
sophisticated attack).

As a result, the NTP servers that your ISP may point you at are
often of unknown/unverified quality, and you use them at your own
risk.

Early millennial versions of Windows (2000, XP, etc) used NTP only
to _initially set_ the clock to approximately 100ms accuracy (and
not maintain synchronization), so the bar wasn't set very high.
Since then, requirements for higher-quality timekeeping have
arisen (e.g. multi-master SQL database replication), but most ISPs
have not kept up with the needs of their users.

Current releases of Windows use Domain Controllers for time
acquisition via the [NT5DS protocol](https://blogs.msdn.microsoft.com/w32time/2007/07/07/what-is-windows-time-service/)
when domain joined.

Because of the unreliable quality of NTP servers DHCP-provisioned by
ISPs, support for this functionality was deemed unnecessary.
