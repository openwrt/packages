# cache-domains

hotplug script to dynamically configure the local DNS (dnsmasq) to redirect game content servers to a LAN cache. Definitive list dynamically obtained from https://github.com/uklans/cache-domains.

## Configuration
The configuration file (`/etc/cache-domains.json`) follows the same [syntax as the upsteam file](https://github.com/uklans/cache-domains/blob/master/scripts/config.example.json). The key for each `cache_domains` member matches the name of one of the `.txt` files in the [upstream root directory](https://github.com/uklans/cache-domains/blob/master/), except for the `default` key which matches the all the unreferenced `.txt` files. The value of each `cache_domains` member maps to one of the keys of the `ips` members, Thus mapping a cached domain to a list of IP addresses/LAN cache server.

```json
{
	"ips": {
		"server1":	["10.10.3.10", "10.10.3.11"],
		"server2":	"10.10.3.12",
		"server3":	"10.10.3.13"
	},
	"cache_domains": {
		"default":	"server1",
		"blizzard":	"server1",
		"origin":	"server1",
		"steam":	"server2",
		"wsus":		"server3",
		"xboxlive":	"server3"
	}
}
```

## Configure/Cleanup
`/usr/bin/cache-domains configure` will configure the local DNS (dnsmasq) to redirect the configured cache domains. `/usr/bin/cache-domains cleanup` will cleanup redirection. The hotplug script calls `/usr/bin/cache-domains configure` when the WAN interface is brought up.

## Testing
After configuring with the above example configuration, running `nslookup lancache.steamcontent.com` would return `10.10.3.12`
