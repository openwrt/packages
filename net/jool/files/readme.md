# [Jool](https://nicmx.github.io/Jool/en/index.html)

## Documentation

[See here](https://nicmx.github.io/Jool/en/documentation.html).

You might also want to see [contact info](https://nicmx.github.io/Jool/en/contact.html).

## Usage

### Start script

This package includes a start script that will:

  1. Read the configuration file `/etc/config/jool`
  2. Determine what services are active
  3. Run `jool` with procd

### For now this means that
  
- The services will be disabled by default in the uci config `(/etc/config/jool)`
- The only uci configuration support available for the package is to enable or disable each instance or the entire deamon
- There is no uci support and configuration will be saved at `/etc/jool/`
- Only one instance of jool(nat64) can run with the boot script
- Only one instance of jool(siit) can run with the boot script
- For now there is no way of overriding of the configuration file's paths

The configuration files the startup script uses for each jool instance are:

- jool(nat64): `/etc/jool/jool-nat64.conf.json`
- jool(siit): `/etc/jool/jool-siit.conf.json`

### OpenWrt tutorial

For a more detailed tutorial refer to this [wiki page](https://openwrt.org/docs/guide-user/network/ipv6/nat64).
