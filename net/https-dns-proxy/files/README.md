# DNS Over HTTPS Proxy (https-dns-proxy)

A lean RFC8484-compatible (no JSON API support) DNS-over-HTTPS (DoH) proxy service which supports DoH servers ran by AdGuard, CleanBrowsing, Cloudflare, Google, ODVR (nic.cz) and Quad9. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/https-dns-proxy/files/README.md) for further information. Based on [@aarond10](https://github.com/aarond10)'s [https-dns-proxy](https://github.com/aarond10/https_dns_proxy).

## Features

- [RFC8484](https://tools.ietf.org/html/rfc8484)-compatible DoH Proxy.
- Compact size.
- Web UI (```luci-app-https-dns-proxy```) available.
- (By default) automatically updates DNSMASQ settings to use DoH proxy when it's started and reverts to old DNSMASQ resolvers when DoH proxy is stopped.

## Screenshots (luci-app-https-dns-proxy)

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/https-dns-proxy/screenshot01.png "https-dns-proxy screenshot")

## Requirements

This proxy requires the following packages to be installed on your router: ```libc```, ```libcares```, ```libcurl```, ```libev```, ```ca-bundle```. They will be automatically installed when you're installing ```https-dns-proxy```.

## Unmet Dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How To Install

Install ```https-dns-proxy``` and ```luci-app-https-dns-proxy``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install https-dns-proxy luci-app-https-dns-proxy;
```

## Default Settings

Default configuration has service enabled and starts the service with Google and Cloudflare DoH servers. In most configurations, you will keep the default ```DNSMASQ``` service installed to handle requests from devices in your local network and point ```DNSMASQ``` to use ```https-dns-proxy``` for name resolution.

By default, the service will intelligently override existing ```DNSMASQ``` servers settings on start to use the DoH servers and restores original ```DNSMASQ``` servers on stop. See the [Configuration Settings](#configuration-settings) section below for more information and how to disable this behavior.

## Configuration Settings

Configuration contains the (named) "main" config section where you can configure which ```DNSMASQ``` settings the service will automatically affect and the typed (unnamed) https-dns-proxy instance settings. The original config file is included below:

```text
config main 'config'
  option update_dnsmasq_config '*'

config https-dns-proxy
  option bootstrap_dns '8.8.8.8,8.8.4.4'
  option resolver_url 'https://dns.google/dns-query'
  option listen_addr '127.0.0.1'
  option listen_port '5053'
  option user 'nobody'
  option group 'nogroup'

config https-dns-proxy
  option bootstrap_dns '1.1.1.1,1.0.0.1'
  option resolver_url 'https://cloudflare-dns.com/dns-query'
  option listen_addr '127.0.0.1'
  option listen_port '5054'
  option user 'nobody'
  option group 'nogroup'
```

The ```update_dnsmasq_config``` option can be set to dash (set to ```'-'``` to not change ```DNSMASQ``` server settings on start/stop), can be set to ```'*'``` to affect all ```DNSMASQ``` instance server settings or have a space-separated list of ```DNSMASQ``` instances to affect (like ```'0 4 5'```). If this option is omitted, the default setting is ```'*'```.

Starting with ```https-dns-proxy``` version ```2019-12-03-3``` and higher, when the service is set to update the DNSMASQ servers setting on start/stop, it does not override entries which contain either ```#``` or ```/```, so the entries like listed below will be kept in use:

```test
  list server '/onion/127.0.0.1#65453'
  list server '/openwrt.org/8.8.8.8'
  list server '/pool.ntp.org/8.8.8.8'
  list server '127.0.0.1#15353'
  list server '127.0.0.1#55353'
  list server '127.0.0.1#65353'
```

The https-dns-proxy instance settings are:

|Parameter|Type|Default|Description|
| --- | --- | --- | --- |
|bootstrap_dns|IP Address||The non-encrypted DNS servers to be used to resolve the DoH server name on start.|
|edns_subnet|Subnet||EDNS Subnet address can be supplied to supported DoH servers to provide local resolution results.|
|listen_addr|IP Address|127.0.0.1|The local IP address to listen to requests.|
|listen_port|port|5053 and up|If this setting is omitted, the service will start the first https-dns-proxy instance on port 5053, second on 5054 and so on.|
|logfile|Full filepath||Full filepath to the file to log the instance events to.|
|resolver_url|URL||The https URL to the RFC8484-compatible resolver.|
|proxy_server|URL||Local proxy server to use when accessing resolvers.|
|user|String|nobody|Local user to run instance under.|
|group|String|nogroup|Local group to run instance under.|
|use_http1|Boolean|0|If set to 1, use HTTP/1 on installations with broken/outdated ```curl``` package. Included for posterity reasons, you will most likely not ever need it on OpenWrt.|
|verbosity|Integer|0|logging verbosity level. fatal = 0, error = 1, warning = 2, info = 3, debug = 4|
|use_ipv6_resolvers_only|Boolean|0|If set to 1, Forces IPv6 DNS resolvers instead of IPv4|

## Thanks

This OpenWrt package wouldn't have been possible without [@aarond10](https://github.com/aarond10)'s [https-dns-proxy](https://github.com/aarond10/https_dns_proxy) and his active participation in the OpenWrt package itself. Special thanks to [@jow-](https://github.com/jow-) for general package/luci guidance.
