# [Jool](https://www.jool.mx)

## Documentation

[See here](https://www.jool.mx/en/documentation.html).

You might also want to see [contact info](https://www.jool.mx/en/contact.html).

## Usage

### Start script

This package includes a start script that will:
    1. Read the configuration file `/etc/config/jool`
    2. Determine what services are active
    3. Run jool with procd

For now this means that:
    * The services will be disabled by default in the uci config `(/etc/config/jool)`
    * The only uci configuration support available for the package is to enable or disable each instance or the entire deamon
    * There is no uci support and configuration will be saved at `/etc/jool/*
    * Only one instance of jool(nat64) can run with the boot script
    * Only one instance of jool(siit) can run with the boot script
    * For now there is no way of overriding of the configuration file's paths

The configuration files the startup script useses for each jool instance are:
    * jool(nat64): `/etc/jool/jool-nat64.conf.json`
    * jool(siit): `/etc/jool/jool-siit.conf.json`
