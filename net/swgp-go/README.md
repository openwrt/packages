# swgp-go
This readme should help you configure swgp-go.

## Configuration
Edit `/etc/swgp.json` with your desired configuration (Client, Server or both).

If you're configuring a server, also properly allow that port in your firewall.

Note the pprof feature is disabled in this package. If you try to enable it
regardless, `swgp-go` will show an error on startup.

## Start daemon
Once you have created your config, enable and run swgp-go using its init script:

```
/etc/init.d/swgp-go enable
/etc/init.d/swpg-go start
```

Please refer to the [Project README](https://github.com/database64128/swgp-go) for more configuration info and examples.
