# UCI Configuration
Most option names are the same as those used in json config files: [`server.json`](https://github.com/xtaci/kcptun/blob/master/examples/server.json) and [`local.json`](https://github.com/xtaci/kcptun/blob/master/examples/local.json). Please check `validate_xxx_options` func definition of the [service script](files/kcptun.init) and kcptun's own [documentation](https://github.com/xtaci/kcptun) for supported options and expected value types. And a [sample config file](files/kcptun.config) is also provided for reference.

A `kcptun` config file can contain two types of config section: `server` and `client`, one of which represents a server or client instance. A `server` section can contain one or more options in [Common options](#common-options) and [Server options](#server-options). And a `client` section can contain one or more options in [Common options](#common-options) and [Client options](#client-options).

Every section has a `disabled` option to temporarily turn off the instance.

## [Common options](#common-options)
| Name | Type | Option | Description |
| ---- | ---- | ------ | ----------- |
| disabled | boolean |  | disable current config section when set to 1 (default: 0) |
| key | string | --key | pre-shared secret between client and server (default: "it's a secrect") |
| crypt | enum | --crypt | aes, aes-128, aes-192, salsa20, blowfish, twofish, cast5, 3des, tea, xtea, xor, sm4, none (default: "aes") |
| mode | enum | --mode | profiles: fast3, fast2, fast, normal, manual (default: "fast") |
| mtu | integer | --mtu | set maximum transmission unit for UDP packets (default: 1350) |
| sndwnd | integer | --sndwnd | set send window size(num of packets) (default: 1024 for server, 128 for client) |
| rcvwnd | integer | --rcvwnd | set receive window size(num of packets) (default: 1024 for server, 512 for client) |
| datashard | integer | --datashard, --ds | set reed-solomon erasure coding - datashard (default: 10) |
| parityshard | integer | --parityshard, --ps | set reed-solomon erasure coding - parityshard (default: 3) |
| dscp | integer | --dscp | set DSCP(6bit) (default: 0) |
| nocomp | boolean | --nocomp | disable compression |
| sockbuf | integer | --sockbuf | per-socket buffer in bytes (default: 4194304) |
| smuxver | integer | --smuxver | specify smux version, available 1,2 (default: 1) |
| smuxbuf | integer | --smuxbuf | the overall de-mux buffer in bytes (default: 4194304) |
| streambuf | integer | --streambuf | per stream receive buffer in bytes, for smux v2+ (default: 2097152) |
| keepalive | integer | --keepalive | seconds between heartbeats (default: 10) |
| snmplog | string | --snmplog | collect snmp to file, aware of timeformat in golang, like: ./snmp-20060102.log |
| snmpperiod | integer | --snmpperiod | snmp collect period, in seconds (default: 60) |
| tcp | boolean | --tcp | to emulate a TCP connection(linux), need root privilege |
| quiet | boolean | --quiet | suppress the 'stream open/close' messages |
| gogc | integer |  | set GOGC environment variable, see [Memory Control](https://github.com/xtaci/kcptun#memory-control). |
| syslog | boolean |  | redirect logs to syslog when set to 1, implemented by [procd](https://openwrt.org/docs/guide-developer/procd-init-scripts#service_parameters). (default: 0) |
| user | string |  | run as another user, implemented by [procd](https://openwrt.org/docs/guide-developer/procd-init-scripts#service_parameters). |

### Limitation
* As kcptun outputs all logs to stderr by default, you may receive lots of **LOG_ERR** level message when set syslog to 1.

## [Server options](#server-options)
| Name | Type | Option | Description |
| ---- | ---- | ------ | ----------- |
| listen | port number | --listen, -l | kcp server listen port (default: ":29900") |
| target | host | --target, -t | target server address (default: "127.0.0.1:12948") |
| target_port | port number | --target, -t | target server port (default: "127.0.0.1:12948") |
| pprof | boolean | --pprof | start profiling server on :6060 |

## [Client options](#client-options)
| Name | Type | Option | Description |
| ---- | ---- | ------ | ----------- |
| bind_address | IP address | --localaddr, -l | local listen address (default: ":12948") |
| local_port | port number | --localaddr, -l | local listen port (default: ":12948") |
| server | host | --remoteaddr, -r | kcp server address (default: "vps:29900") |
| server_port | port number | --remoteaddr, -r | kcp server port (default: "vps:29900") |
| conn | integer | --conn | set num of UDP connections to server (default: 1) |
| autoexpire | integer | --autoexpire | set auto expiration time(in seconds) for a single UDP connection, 0 to disable (default: 0) |
| scavengettl | integer | --scavengettl | set how long an expired connection can live(in sec), -1 to disable (default: 600) |
