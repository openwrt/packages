
# Stubby for OpenWRT

## Stubby Description

[Stubby](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby) is
an application that acts as a local DNS Privacy stub resolver (using
DNS-over-TLS). Stubby encrypts DNS queries sent from a client machine to a DNS
Privacy resolver increasing end user privacy.

Stubby is useful on an OpenWRT device, because it can sit between the usual DNS
resolver (dnsmasq by default) and the upstream DNS resolver and be used to
ensure that DNS traffic is encrypted between the OpenWRT device and the
resolver.

Stubby is developed by the [getdns](http://getdnsapi.net/) project.

For more background and FAQ see the [About
Stubby](https://dnsprivacy.org/wiki/display/DP/About+Stubby) page.


## Installation

Installation of this package can be achieved at the command line using `opkg
install stubby`, or via the LUCI Web Interface. Installing the stubby package
will also install the required dependency packages, including the
`ca-bundle` package.

## Configuration

The default configuration of the package has been chosen to ensure that stubby
should work after installation.

By default, configuration of stubby is integrated with the OpenWRT UCI system
using the file `/etc/config/stubby`. The configuration options available are
also documented in that file. If for some reason you wish to configure stubby
using the `/etc/stubby/stubby.yml` file, then you simply need to set `option
manual '1'` in `/etc/config/stubby` and all other settings in
`/etc/config/stubby` will be ignored.

### Stubby port and addresses

The default configuration ensures that stubby listens on port 5453 on the
loopback interfaces for IPv4 and IPv6. As such, by default, stubby will respond
only to lookups from the OpenWRT device itself.

By setting the listening ports to non-standard values, this allows users to keep
the main name server daemon in place (dnsmasq/unbound/etc.) and have that name
server forward to stubby.

### Upstream resolvers

The default package configuration uses the CloudFlare resolvers, configured for
both IPv4 and IPv6. 

CloudFlare have not published SPKI pinsets, and even though they are available,
they have made no commitment to maintaining them. Using the currently known SPKI
pinsets for CloudFlare brings the risk that in the future they may be changed by
CloudFlare, and DNS would stop working. The default configuration has those SPKI
entries commented out for this reason.

[CloudFlare's privacy
statement](https://developers.cloudflare.com/1.1.1.1/commitment-to-privacy/)
details how they treat data from DNS requests.

More resolvers are available in the [upstream stubby example
configuration](https://github.com/getdnsapi/stubby/blob/develop/stubby.yml.example)
and the [DNS Privacy
list](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers).

## Integration of stubby with dnsmasq

The recommended way to use stubby on an OpenWRT device is to integrate it with a
caching resolver. The default caching resolver in OpenWRT is dnsmasq.

### Set dnsmasq to send DNS requests to stubby

Since dnsmasq responds to LAN DNS requests on port 53 of the OpenWRT device by
default, all that is required is to have dnsmasq forward those requests to
stubby which is listening on port 5453 of the OpenWRT device. To achieve this,
we need to set the `server` option in the dnsmasq configuration in the
`/etc/config/dhcp` file to `'127.0.0.1#5453'`. We also need to tell dnsmasq not
to use resolvers found in `/etc/resolv.conf` by setting the dnsmasq option
`noresolv` to `1` in the same file. This can be achieved by editing the
`/etc/config/dhcp` file directly or executing the following commands at the
command line:

    uci add_list dhcp.@dnsmasq[-1].server='127.0.0.1#5453'
    uci dhcp.@dnsmasq[-1].noresolv=1
    uci commit && reload_config

The same outcome can be achieved in the LUCI web interface as follows:

1. Select the Network->DHCP and DNS menu entry.
2. In the "General Settings" tab, enter the address `127.0.0.1#5453` as the only
   entry in the "DNS Forwardings" dialogue.
3. In the "Resolv and Host files" tab tick the "Ignore resolve file" checkbox.

### Disable sending DNS requests to ISP provided DNS servers

The configuration changes in the previous section ensure that DNS queries are
sent over TLS encrypted connections *once dnsmasq and stubby are started*. When
the OpenWRT device is first brought up, there is a possibility that DNS queries
can go to ISP provided DNS servers ahead of dnsmasq and stubby being active. In
order to mitigate this leakage, it's necessary to ensure that upstream resolvers
aren't available, and the only DNS resolver used by the system is
dnsmasq+stubby. 

This requires setting the option `peerdns` to `0` and the option `dns` to the
loopback address for both the `wan` and `wan6` interfaces in the
`/etc/config/network` file. This can be achieved by editing the
`/etc/config/network` file directly, or by executing the following commands:

    uci set network.wan.peerdns='0'
    uci set network.wan.dns='127.0.0.1'
    uci set network.wan6.peerdns='0'
    uci set network.wan6.dns='0::1'
    uci commit && reload_config

The same outcome can also be achieved using the LUCI web interface as follows:

1. Select the Network->Interfaces menu entry.
2. Click on Edit for the WAN interfaces.
3. Choose the Advanced Settings tab.
4. Unselect the "Use DNS servers advertised by peer" checkbox
5. Enter `127.0.0.1` in the "Use custom DNS servers" dialogue box.
6. Repeat the above steps for the WAN6 interface, but use the address `0::1`
   instead of `127.0.0.1`.
   
### Enabling DNSSEC

The configuration described above ensures that DNS queries are executed over TLS
encrypted links. However, the responses themselves are not validated; DNSSEC
provides the ability to validate returned DNS responses, and mitigate against
DNS poisoning risks.

With the combination of stubby+dnsmasq there are two possible ways to enable
DNSSEC:

1. Configure stubby to perform DNSSEC validation, and configure dnsmasq to proxy
   the DNSSEC data to clients.
2. Configure stubby not to perform DNSSEC validation and configure dnsmasq to
   require DNSSEC validation.

Either option achieves the same outcome, and there appears to be little reason
for choosing one over the other other than that the second option is easier to
configure in the LUCI web interface. Both options are detailed below, and both
require that the `dnsmasq` package on the OpenWRT device is replaced with the
`dnsmasq-full` package. That can be achieved by running the following command:

    opkg install dnsmasq-full --download-only && opkg remove dnsmasq && opkg install dnsmasq-full --cache . && rm *.ipk

#### DNSSEC by stubby

Configuring stubby to perform DNSSEC validation requires setting the stubby
configuration option `dnssec_return_status` to `'1'` in `/etc/config/stubby`,
which can be done by editing the file directly or by executing the commands:

    uci set stubby.global.dnssec_return_status=1
    uci commit && reload_config
    
With stubby performing DNSSEC validation, dnsmasq needs to be configured to
proxy the DNSSEC data to clients. This requires setting the option `proxydnssec`
to 1 in the dnsmasq configuration in `/etc/config/dhcp`. That can be achieved by
the following commands:

    uci set dhcp.@dnsmasq[-1].proxydnssec=1
    uci commit && reload_config

#### DNSSEC by dnsmasq

Configuring dnsmasq to perform DNSSEC validation requires setting the dnsmasq
option `dnssec` to `1` in the `/etc/config/dhcp` file. In addition, it is
advisable to also set the dnsmasq option `dnsseccheckunsigned` to `1`. this can
be achieved by editing the file `/etc/config/dhcp` or by executing the following
commands:

    uci set dhcp.@dnsmasq[-1].dnssec=1
    uci set dhcp.@dnsmasq[-1].dnsseccheckunsigned=1
    uci commit && reload_config

The same options can be set in the LUCI web interface as follows:

1. Select the "Network->DHCP and DNS" menu entry.
2. Select the "Advanced Settings" tab.
3. Ensure both the "DNSSEC" and "DNSSEC check unsigned" check boxes are ticked.

#### Validating DNSSEC operation

Having configured DNSSEC validation using one of the two approaches above, it's
important to check it's actually working. The following command can be used:

    dig dnssectest.sidn.nl +dnssec +multi @192.168.1.1
    
This command should return output like the following:

    ; <<>> DiG 9.11.4-P1-RedHat-9.11.4-5.P1.fc28 <<>> dnssectest.sidn.nl +dnssec +multi @192.168.1.1
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26579
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags: do; udp: 512
    ;; QUESTION SECTION:
    ;dnssectest.sidn.nl.	IN A

    ;; ANSWER SECTION:
    dnssectest.sidn.nl.	14399 IN A 213.136.9.12
    dnssectest.sidn.nl.	14399 IN RRSIG A 8 3 14400 (
				20181104071058 20181005071058 42033 sidn.nl.
				YAQl3tef36M9EQUOmCneHKCCkxox3csLpfUOql5i/6ND
				zPrQFsNr3g32HPoxOsi+hD2BE5+bEsnARayDSVLyx0qU
				6Hpi2rzQ0zGNZZkCJhCsdp3wnM1BWlMgPrCD0iIsJDok
				+DH5zu+yYufVUdSLQrMqA3MZDFUIqDUqSZuYDF4= )

    ;; Query time: 77 msec
    ;; SERVER: 192.168.1.1#53(192.168.1.1)
    ;; WHEN: Sat Oct 06 20:36:25 BST 2018
    ;; MSG SIZE  rcvd: 230

The key thing to note is the `flags: qr rd ra ad` part - the `ad` flag signifies
that DNSSEC validation is working. If that flag is absent DNSSEC validation is
not working.

## Appendix: stubby configuration options

This section details the options available for use in the `/etc/config/stubby`
file. The `global` configuration section specifies the configuration parameters
for the stubby daemon. One or more `resolver` sections are used to configure
upstream resolvers for the stubby daemon to use.

### `global` section options

#### `option manual`

Specify whether to use this file to configure the stubby service. If this is set
to `'1'` stubby will be configured using the file `/etc/stubby/stubby.yml`. If this
is set to `'0'`, configuration options will be taken from this file, and the service
will be managed through UCI.

#### `option trigger`

This specifies an interface to trigger stubby start up on; stubby startup will
be triggered by a procd signal associated with this interface being ready. If
this interface is restarted, stubby will also be restarted. 

This option can also be set to `'timed'`, in which case a time, specified by the
option `triggerdelay`, will be waited before starting stubby.


#### `option triggerdelay`

If the `trigger` option specifies an interface, this option sets the time that
is waited after the procd signal is received before starting stubby. 

If `trigger` is set to `'timed'` then this is the delay before starting stubby.
This option is specified in seconds and defaults to the value `'2'`.

#### `list dns_transport`

The `dns_transport` list specifies the allowed transports. Allowed values are:
`GETDNS_TRANSPORT_UDP`, `GETDNS_TRANSPORT_TCP` and `GETDNS_TRANSPORT_TLS`. The
transports are tried in the order listed.

#### `option tls_authentication`

This option specifies whether TLS authentication is mandatory. A value of `'1'`
mandates TLS authentication, and is the default.

If this is set to `'0'`, and `GETDNS_TRANSPORT_TCP` or `GETDNS_TRANSPORT_UDP`
appears in the `dns_transport` list, stubby is allowed to fall back to non-TLS
authenticated lookups. You probably don't want this though.

#### `option tls_query_padding_blocksize`

This option specifies the block size to pad DNS queries to. You shouldn't need
to set this to anything but `'128'` (the default), as recommended by
https://tools.ietf.org/html/draft-ietf-dprive-padding-policy-03

#### `option tls_connection_retries`

This option specifies the number of connection failures stubby permits before
Stubby backs-off from using an individual upstream resolver. You shouldn't need
to change this from the default value of `'2'`.

#### `option tls_backoff_time`

This option specifies the maximum time in seconds Stubby will back-off from
using an individual upstream after failures. You shouldn't need to change this
from the default value of `'3600'`.

#### `option timeout`

This option specifies the timeout on getting a response to an individual
request. This is specified in milliseconds. You shouldn't need to change this
from the default value of ` '5000'`.

#### `option dnssec_return_status`

This option specifies whether stubby should require DNSSEC validation. Specify
to `'1'` to turn on validation, and `'0'` to turn it off. By default it is off.

#### `option appdata_dir`

This option specifies the location for storing stubby runtime data. In
particular, if DNSSEC is turned on, stubby will store its automatically
retrieved trust anchor data here. The default value is `'/var/lib/stubby'`.

#### `option trust_anchors_backoff_time`

When Zero configuration DNSSEC failed, because of network unavailability or
failure to write to the appdata directory, stubby will backoff trying to refetch
the DNSSEC trust-anchor for a specified amount of time expressed in milliseconds
(which defaults to two and a half seconds).

#### `option dnssec_trust_anchors`

This option sets the location of the file containing the trust anchor data used
for DNSSEC validation. If this is not specified, stubby will automatically
retrieve a trust anchor at startup. It's unlikely you'll want to manage the
trust anchor data manually, so in most cases this is not needed. By default,
this is unset.

#### `option edns_client_subnet_private`

This option specifies whether to enforce ECS client privacy. The default is
`'1'`. Set to `'0'` to disable client privacy.

For more details see Section 7.1.2 [here](https://tools.ietf.org/html/rfc7871).

#### `option idle_timeout`

This option specifies the time (in milliseconds) to hold TLS connections open to
avoid the overhead of opening a new connection for every query. You should not
normally need to change this from the default value (currently `'10000'`).

See [here](https://tools.ietf.org/html/rfc7828) for more details.

#### `option round_robin_upstreams`

This option specifies how stubby will use the upstream DNS resolvers. Set to
`'1'` (the default) to instruct stubby to distribute queries across all
available name servers - this will use multiple simultaneous connections which
can give better performance in most (but not all) cases. Set to `'0'` to treat
the upstream resolvers as an ordered list and use a single upstream resolver
until it becomes unavailable, then use the next one.

#### `list listen_address`

This list sets the addresses and ports for the stubby daemon to listen for
requests on. the default configuration configures stubby to listen on port 5453
on the loopback interface for both IPv4 and IPv6.

#### `option log_level`

If set, this option specifies the level of logging from the stubby
daemon. By default, this option is not set.

The possible levels are:

    '0': EMERG  - System is unusable
    '1': ALERT  - Action must be taken immediately
    '2': CRIT   - Critical conditions
    '3': ERROR  - Error conditions
    '4': WARN   - Warning conditions
    '5': NOTICE - Normal, but significant, condition
    '6': INFO   - Informational message
    '7': DEBUG  - Debug-level message

#### `option command_line_arguments`

This option specifies additional command line arguments for
stubby daemon. By default, this is an empty string.

#### `option tls_cipher_list`

If set, this specifies the acceptable ciphers for DNS over TLS. With OpenSSL
1.1.1 this list is for TLS1.2 and older only. Ciphers for TLS1.3 should be set
with the `tls_ciphersuites` option. This option can also be given per upstream
resolver. By default, this option is not set.

#### `option tls_ciphersuites`

If set, this specifies the acceptable cipher for DNS over TLS1.3. OpenSSL
version 1.1.1 or greater is required for this option. This option can also be
given per upstream resolver. By default, this option is not set.

#### `option tls_min_version`

If set, this specifies the minimum acceptable TLS version. Works with OpenSSL
1.1.1 or greater only. This option can also be given per upstream resolver. By
default, this option is not set.

#### `option tls_max_version`

If set, this specifies the maximum acceptable TLS version. Works with OpenSSL
1.1.1 or greater only. This option can also be given per upstream resolver. By
default, this option is not set.


### `resolver` section options

#### `option address`

This option specifies the resolver IP address, and can either be an IPv4 or an
IPv6 address.

#### `option tls_auth_name`

This option specifies the upstream domain name used for TLS authentication with
the supplied server certificate

#### `option tls_port`

This option specifies the TLS port for the upstream resolver. If not specified,
this defaults to 853.

#### `option tls_cipher_list`

If set, this specifies the acceptable ciphers for DNS over TLS. With OpenSSL
1.1.1 this list is for TLS1.2 and older only. Ciphers for TLS1.3 should be set
with the `tls_ciphersuites` option. By default, this option is not set. If set,
this overrides the global value.

#### `option tls_ciphersuites`

If set, this specifies the acceptable cipher for DNS over TLS1.3. OpenSSL
version 1.1.1 or greater is required for this option. By default, this option is
not set. If set, this overrides the global value.

#### `option tls_min_version`

If set, this specifies the minimum acceptable TLS version. Works with OpenSSL
1.1.1 or greater only. By default, this option is not set. If set, this
overrides the global value.

#### `option tls_max_version`

If set, this specifies the maximum acceptable TLS version. Works with OpenSSL
1.1.1 or greater only. By default, this options is not set. If set, this
overrides the global value.

#### `list spki`

This list specifies the SPKI pinset which is verified against the keys in the
server cerrtificate. The value takes the form `'<digest type>/value>'`, where
the `digest type` is the hashing algorithm used, and the value is the Base64
encoded hash of the public key. At present, only `sha256` is
supported for the digest type.

This should ONLY be used if the upstream resolver has committed to maintaining
the pinset. CloudFlare have made no such commitment, and so we do not specify
the SPKI values in the default configuration, even though they are available.
