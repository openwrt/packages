# Tor Hidden service configurator
**tor-hs** packages tries to simplify creating of hidden services on OpenWrt routers.

## Requirements
To run **tor-hs**, you need Tor package with uci config support (it was added
with [this commit](https://github.com/openwrt/packages/commit/ca6528f002d74445e3d0a336aeb9074fc337307a) ).

## Instalation
To install package simple run
```
opkg update
opkg install tor-hs
```

## Configuration
Uci configuration is located in **/etc/config/tor-hs**

### Required section of configuration
There is  one required section **common**

Example of this section
```
config tor-hs common
	option GenConf "/etc/tor/torrc_hs"
	option HSDir "/etc/tor/hidden_service"
	option RestartTor "true"
	option UpdateTorConf "true"
```

#### Table with options description
| Type | Name | Default | Description |
| ------ | ------ | ------ | ------ |
| option |GenConf | /etc/tor/torrc_generated|Generated config by tor-hs.|
| option | HSDir |/etc/tor/hidden_service|Directory with meta-data for hidden services (hostname,keys,etc).|
| option | RestartTor | true| It will restart tor after running **/etc/init.d/tor-hs start**.|
| option | UpdateTorConf | true|Update /etc/config/tor with config from **GenConf** option.|

### Hidden service configuration
If you want to create a new hidden service, you have to add a hidden-service section. For every hidden service, there should be a new **hidden-service** section.

Example of hidden service section for ssh server:

```
config hidden-service
	option Name 'sshd'
	option Description "Hidden service for ssh"
	option Enabled 'false'
	option IPv4 '127.0.0.1'
	#public port=2222, local port=22
	list PublicLocalPort '2222;22'
```

#### Table with options description

| Type | Name | Example value | Description |
| ------ | ------ | ------ | ------ |
|	option | Name | sshd| Name of hidden service. It is used as directory name in **HSDir**|
|	option | Description| Hidden service for ssh| Description used in **rpcd** service|
|	option | Enabled |false| Enable hidden service after running **tor-hs** init script|
|	option |IPv4 |127.0.0.1|Local IPv4 address of service. Service could run on another device, in that case OpenWrt will redirect comunication.  |
|	list | PublicLocalPort| 2222;22| Public port is port accesible via Tor network. Local port is normal port of service.|
|option| HookScript |'/etc/tor/nextcloud-update.php'| Path to script which is executed after starting tor-hs. Script is executed with paramters **--update-onion** **hostname** . Hostname is replaced with Onion v3 address for given hidden service.

## Running service

To enable tor-hs service run
```
/etc/init.d/tor-hs enable
/etc/init.d/tor-hs start

```
In case you enabled option *RestartTor* and *UpdateTorConf* hidden service should be running.
Otherwise, you should also restart tor daemon.

```
/etc/init.d/tor restart
```

After that you should also restart rpcd daemon, so you can use tor-hs RPCD service.
```
/etc/init.d/rpcd restart
```

### RPCD

RPCD servis helps users to access basic informations about hidden services on router. After running HS it contains onion url for given hidden service in hostname value.
```
root@turris:/# ubus call tor-hs-rpc list-hs '{}'
{
	"hs-list": [
		{
			"name": "sshd",
			"description": "Hidden service for ssh",
			"enabled": "1",
			"ipv4": "127.0.0.1",
			"hostname": "****hidden-service-hostname****.onion",
			"ports": [
				"22;22"
			]
		}
	]
}
```

