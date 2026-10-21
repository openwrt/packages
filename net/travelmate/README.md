<!-- markdownlint-disable -->

# Travelmate, a wlan connection manager for travel routers

## Table of Contents
* [Description](#description)
* [Quick Start](#quick-start)
* [Main Features](#main-features)
* [Prerequisites](#prerequisites)
* [Installation and Usage](#installation-and-usage)
* [Travelmate CLI interface](#travelmate-cli-interface)
* [Travelmate config options](#travelmate-config-options)
* [Examples](#examples)
* [Best practice and tweaks](#best-practice-and-tweaks)
* [Troubleshooting & debug options](#troubleshooting-and-debug-options)
* [Support](#support)
* [Removal](#removal)
* [Donations](#donations)

<a id="description"></a>
## Description
If you're taking your laptop, tablet, or phone on an upcoming vacation or business trip, you'll want to connect with friends or complete work on the go. But many hotels don't have a secure wireless network setup or limit you to using a single device at a time.

Travelmate lets you use a small "travel router" to connect all of your devices at once while having total control over your own personal wireless network.

Travelmate runs on OpenWrt and provides an "uplink" to the hotel's wireless access point/hotspot. Travelmate then becomes the Access Point (AP) for you and your companions, providing secure access to the internet. It manages all the network settings, firewall settings, connections to a hotel network, etc. and automatically (re)connects to configured APs/hotspots as they become available.

<a id="quick-start"></a>
## Quick Start
For a typical setup these few steps are enough to get travelmate up and running — see the sections below for details:
1. Install the LuCI companion package: `apk update && apk add luci-app-travelmate` (this pulls in the `travelmate` backend as a dependency).
2. Open LuCI under `Services → Travelmate` and run the **Interface Wizard** once. It creates the uplink interface, the firewall assignment and the required network settings.
3. Switch to the **Wireless Stations** tab, scan the radio you want to use as uplink, click `Add Uplink...` for the desired SSID and enter its credentials.
4. Start and verify the service:

```sh
/etc/init.d/travelmate start
/etc/init.d/travelmate status
```

**Please note:** configure your AP on a different radio than the uplink whenever your router has more than one. Sharing a single radio between AP and uplink works, but costs a noticeable amount of throughput.

<a id="main-features"></a>
## Main Features
* Easy setup from the LuCI web interface with **Interface Wizard** and **Wireless Station manager**
* Display a QR code to transfer the wireless credentials to your mobile devices
* Fast uplink connections
* Supports routers with multiple radios in any order
* Supports all kinds of uplinks, including hidden and enterprise uplinks (WEP-based uplinks are no longer supported)
* Continuously checks the existing uplink quality, e.g. for conditional uplink (dis)connections
* Automatically add open uplinks to your wireless config, e.g. hotel captive portals
* Captive portal detection with a 'heartbeat' function to keep the uplink connection up and running
* Captive portal hook for auto-login configured via uci/LuCI, using an external ucode script (see the examples below)
* VPN hook handles VPN (re)connections automatically, for 'wireguard', 'openvpn' and every other vpn protocol netifd brings up, e.g. 'openconnect' or 'vpnc'
* E-mail hook via 'msmtp' sends notification e-mails after every successful uplink connect
* Proactively scan and switch to a higher priority uplink, replacing an existing connection
* Check router subnet vs. uplink subnet, to show conflicts with the router LAN network
* (Optional) Generate a random unicast MAC address for each uplink connection
* (Optional) Evil twin protection by skipping access points with locally-administered (LAA) BSSIDs
* Configurable retry limit per uplink, with optional unlimited retry mode
* NTP time sync before sending e-mails
* procd init and ntp-hotplug support
* Runtime information available via LuCI and via the 'status' init command
* Log status and debug information to syslog
* STA interfaces operate in an "always off" mode, to make sure that the AP is always accessible

<a id="prerequisites"></a>
## Prerequisites
* [OpenWrt](https://openwrt.org), tested/compatible with current stable and latest OpenWrt snapshot
* The `luci-app-travelmate` package ensures these dependencies are present:
  * 'dnsmasq' as dns backend
  * 'ubus iwinfo' for wlan scanning
  * 'curl' for connection checking and all kinds of captive portal magic, e.g. cp detection and auto-logins
* The `travelmate` package brings the 'ucode' interpreter and its fs, ubus, uci and log modules, the backend is written in ucode
  * a 'wpad' variant to support various WPA encrypted networks (WEP-based uplinks are no longer supported!)
* optional: a vpn client like 'wireguard', 'openvpn' or another netifd vpn protocol for vpn client connections
* optional: 'msmtp' to send out travelmate related status messages via e-mail

<a id="installation-and-usage"></a>
## Installation and Usage
* Install OpenWrt on your router and set it up to allow wireless connections. Be sure to set a strong password on the wireless channel(s) so that only you and your companions can use it
* Decide which radio you'll use for the travelmate uplink (radio0, radio1, etc.). 2.4GHz allows a longer (more distant) link, 5GHz provides a faster link. Travelmate works on all radios, but for better performance configure the AP on a separate radio from the one you're planning to use as the uplink
* Install both **travelmate** and **luci-app-travelmate**, the application is located in LuCI under the `Services` menu
* You must use the travelmate **Interface Wizard** one time to configure the uplink, firewall and other network settings
* Use the **Wireless Stations** tab to add an uplink station:
  * **Scan** the radio you chose for the uplink
  * Click `Add Uplink...` for the desired SSID. If there are multiples, choose the one with the largest _Strength_
  * Enter the credentials (password, etc.)
  * You should be "on the air" - test by browsing the internet
* You may add additional uplinks for different locations by repeating the previous step
* Happy traveling ...

The buttons at the bottom of the LuCI overview page behave as follows:

| Button               | Description                                                                                                        |
| :------------------- | :----------------------------------------------------------------------------------------------------------------- |
| **Stop**             | Stops the travelmate service. Greyed out while the service is not running                                            |
| **Interface Wizard** | One-time setup of the uplink interface, firewall zone and metric                                                     |
| **Interface Restart** | Restarts the travelmate uplink interface without touching the configuration                                         |
| **AP QR-Codes**      | Displays a QR code per AP to transfer the wireless credentials to your mobile devices                                |
| **Save & Restart**   | Applies pending configuration changes and restarts the service, this also brings a stopped service back up           |

While a run cycle is in progress (status `processing`), all buttons except **Stop** are temporarily locked to avoid overlapping actions. **Stop** always stays available, so an unwanted or long running cycle can be interrupted at any time - e.g. right after the **Interface Wizard** on a fresh setup, when no uplink station has been configured yet.

<a id="travelmate-cli-interface"></a>
## Travelmate CLI interface
* All important travelmate functions are accessible via CLI, too. If you're going to configure travelmate via CLI, edit the config file `/etc/config/travelmate` and enable the service, see the options reference tables below.

```sh
~# /etc/init.d/travelmate
Syntax: /etc/init.d/travelmate [command]

Available commands:
	start           Start the service
	stop            Stop the service
	restart         Restart the service
	reload          Reload configuration files (or restart if service does not implement reload)
	enable          Enable service autostart
	disable         Disable service autostart
	enabled         Check if service is started on boot
	scan            [<radio>|<ifname>] Scan for available nearby uplinks
	setup           [<iface>] [<zone>] [<metric>] Setup the travelmate uplink interface, by default 'trm_wwan' with firewall zone 'wan' and metric '100'
	running         Check if service is running
	status          Service status
	trace           Start with syscall trace
	info            Dump procd service info
```

The `setup` sub-command is the CLI equivalent of the LuCI **Interface Wizard** and only needs to be run once. The `scan` sub-command writes its result as JSON array to `/var/run/travelmate/travelmate.scan`, sorted by signal quality, and is used by the **Wireless Stations** tab in LuCI as well.

The `status` sub-command prints the current runtime information:

```sh
~# /etc/init.d/travelmate status
::: travelmate runtime information
  + travelmate_status  : connected, net ok/100
  + frontend_ver       : 3.0.0-r1
  + backend_ver        : 3.0.0-r1
  + station_id         : radio0/blackhole.nl/-
  + station_mac        : 26:b7:ad:14:08:f7
  + station_interfaces : wwan, wireguard
  + station_subnet     : 192.168.1.0 (lan: 10.200.1.0)
  + run_flags          : autoadd: ✔, captive: ✔, eviltwin: ✘, mail: ✔, netcheck: ✔, ntp: ✔, proactive: ✔, randomize: ✔, vpn: ✔
  + last_run           : mode: start, date / time: 2026-10-21 17:34:13, memory: 306.00 MB available
  + system_info        : cores: 2, fetch: curl, Cudy TR3000 v1, mediatek/filogic, OpenWrt SNAPSHOT (r37596-df70de353d)
```

The `travelmate_status` field reports one of the following states:

| State           | Description                                                                                                     |
| :-------------- | :-------------------------------------------------------------------------------------------------------------- |
| `connected`     | An uplink is connected, followed by the connection details, e.g. `connected, net ok/100`                          |
| `processing`    | A run cycle is currently in progress, e.g. scanning the radios or waiting for an uplink to come up                |
| `not connected` | No uplink is connected and no run cycle is active, i.e. travelmate is idle and waiting for the next trigger       |
| `program error` | A fatal error occurred, the daemon has stopped, please check the syslog                                           |

A stopped service does not report a state at all, it truncates the runtime file instead - LuCI shows this as `stopped`.

<a id="travelmate-config-options"></a>
## Travelmate config options
* Usually the pre-configured travelmate setup works quite well and no manual config overrides are needed. All options listed below apply to the 'global' section:

| Option             | Default                            | Description/Valid Values                                                                              |
| :----------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------- |
| trm_enabled        | 0, disabled                        | set to 1 to enable the travelmate service (this will be done by the Interface Wizard as well!)        |
| trm_debug          | 0, disabled                        | set to 1 to get the full debug output (logread -e "trm-")                                             |
| trm_iface          | -, not set                         | uplink- and procd trigger network interface, configured by the 'Interface Wizard'                     |
| trm_laniface       | -, lan                             | logical LAN network interface, default is 'lan'                                                       |
| trm_radio          | -, not set                         | restrict travelmate to certain radio(s)                                                               |
| trm_revradio       | 0, disabled                        | change the radio processing order, e.g. 'radio1 radio0'                                               |
| trm_captive        | 1, enabled                         | check the internet availability and handle captive portal redirections                                |
| trm_netcheck       | 0, disabled                        | treat missing internet availability as an error, see the note below                                   |
| trm_proactive      | 0, disabled                        | proactively scan and switch to a higher prioritized uplink, despite of an already existing connection |
| trm_autoadd        | 0, disabled                        | automatically add open uplinks like hotel captive portals to your wireless config                     |
| trm_ssidfilter     | -, not set                         | list of SSID patterns for filtering/skipping specific open uplinks, e.g. 'Chromecast*'                |
| trm_randomize      | 0, disabled                        | generate a random unicast MAC address for each uplink connection                                      |
| trm_eviltwin       | 0, disabled                        | detect and skip access points with locally administered (LAA) BSSIDs to mitigate evil twin attacks    |
| trm_triggerdelay   | 5                                  | additional trigger delay in seconds before travelmate processing begins                               |
| trm_maxretry       | 3                                  | retry limit to connect to an uplink, set to '0' for unlimited retries                                 |
| trm_minquality     | 35                                 | minimum signal quality threshold as percent for conditional uplink (dis-) connections                 |
| trm_maxwait        | 30                                 | how long should travelmate wait for a successful wlan uplink connection                               |
| trm_timeout        | 30                                 | overall retry timeout in seconds                                                                      |
| trm_maxautoadd     | 5                                  | limit the max. number of automatically added open uplinks. To disable this limitation set it to '0'   |
| trm_captiveurl     | http://detectportal.firefox.com    | custom/pre-configured provider URLs that will be used for connectivity- and captive portal checks     |
| trm_useragent      | Mozilla/5.0 ...                    | pre-configured user agents that will be used for connectivity- and captive portal checks              |
| trm_nice           | 0, normal priority                 | change the priority of the travelmate background processing                                           |
| trm_mail           | 0, disabled                        | sends notification e-mails after every succesful uplink connect                                       |
| trm_mailreceiver   | -, not set                         | e-mail receiver address for travelmate notifications                                                  |
| trm_mailsender     | no-reply@travelmate                | e-mail sender address for travelmate notifications                                                    |
| trm_mailtopic      | travelmate connection to '<sta>'   | topic for travelmate notification E-Mails                                                             |
| trm_mailprofile    | trm_notify                         | profile used by 'msmtp' for travelmate notification E-Mails                                           |
| trm_vpn            | 0, disabled                        | VPN connections will be managed by travelmate                                                         |
| trm_vpnifacelist   | -, not set                         | limit vpn processing to these interfaces, default: all wireguard/openvpn and all referenced vpn ones  |
| trm_stdvpniface    | -, not set                         | standard vpn interface which will be automatically added to new STA profiles                          |

**Please note:** 'trm_netcheck' is evaluated independently of 'trm_captive'. A detected captive portal does not count as an error as long as 'trm_captive' is enabled - such an uplink stays connected so that a manual or script based portal login is still possible. With 'trm_captive' disabled travelmate can neither allowlist the portal domain nor run a login script, so a detected portal is treated like a failed connectivity check. Only a failed connectivity check counts, and it is confirmed by a second probe before it is acted on. Such a failure is then handled like a failed connection attempt: after 'trm_maxretry' tries the affected uplink gets disabled in the travelmate config. A longer lasting outage of your upstream provider may therefore disable all configured uplinks, which have to be re-enabled manually.

* Per uplink there is an additional 'uplink' section in the travelmate config, with the following options:

| Option             | Default                            | Description/Valid Values                                                                              |
| :----------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------- |
| enabled            | 1, enabled                         | enable or disable the uplink, automatically set if the retry limit was reached                        |
| revive             | 0, disabled                        | re-enable this uplink after n run cycles if the retry limit disabled it, minimum '10'                 |
| device             | -, not set                         | match the 'device' in the wireless config section                                                     |
| ssid               | -, not set                         | match the 'ssid' in the wireless config section                                                       |
| bssid              | -, not set                         | match the 'bssid' in the wireless config section                                                      |
| script             | -, not set                         | reference to an external auto login script for captive portals                                        |
| script_args        | -, not set                         | optional runtime args for the auto login script                                                       |
| macaddr            | -, not set                         | use a specified MAC address for the uplink                                                            |
| vpn                | 0, disabled                        | automatically handle VPN (re-) connections                                                            |
| vpniface           | -, not set                         | the logical vpn interface, e.g. 'wg0'                                                                 |

<a id="examples"></a>
## Examples
**VPN client setup**  
Please read one of the following guides to get a working vpn client setup on your travel router:

* [Wireguard client setup guide](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client)
* [OpenVPN client setup guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci)

Make sure to uncheck the "Bring up on boot" option during vpn interface setup, so that netifd doesn't interfere with travelmate.

Once your vpn client connection setup is correct, you can reference the vpn interface in travelmate ('vpniface' per uplink or 'trm_stdvpniface' for new uplinks) to handle VPN (re-) connections automatically. Travelmate takes the vpn interface up and down via netifd, the vpn service follows its protocol: 'wireguard' and 'openvpn' interfaces are always known, interfaces with any other protocol (e.g. 'openconnect', 'vpnc', 'l2tp') are handled as soon as they are referenced or listed in 'trm_vpnifacelist'. The former 'vpnservice' and 'trm_stdvpnservice' options are gone.

**Please note:** OpenVPN is a netifd protocol ('proto openvpn') now, the former setup with an openvpn init instance on a 'proto none' interface is no longer supported. Uplinks that referenced such an interface are pointed to the migrated openvpn interface on update.

**E-Mail setup**  
To use e-mail notifications you have to set up the package 'msmtp'. Modify the file `/etc/msmtprc`, e.g. for gmail:

```
[...]
defaults
auth            on
tls             on
tls_certcheck   off
timeout         5
syslog          LOG_MAIL
[...]
account         trm_notify
host            smtp.gmail.com
port            587
from            xxx@gmail.com
user            yyy
password        zzz
```

Finally enable e-mail support in travelmate and add a valid e-mail receiver address.

The mail body is rendered from the ucode template `/etc/travelmate/mail.template` (option 'trm_mailtemplate'), which gets `banner`, `board` (ubus 'system board'), `status` (as printed by `/etc/init.d/travelmate status`) and `station_id` as variables.

**Captive portal auto-logins**  
For automated captive portal logins you can reference an external ucode script per uplink. All login scripts have to be executable and located in `/etc/travelmate` with the extension `.uc`, shell scripts (formerly `.login`) are no longer supported. On upgrade, an uplink that still references one of the shipped `.login` scripts is switched to the `.uc` script of the same name. A login script signals its result via the exit code: `0` means the login succeeded, any other value means it failed. Only `0` makes travelmate re-check the connectivity right away, every other value is just logged. The package ships multiple ready to run auto-login scripts:

* 'wifibahn.uc' for german DB railway hotspots
* 'telekom.uc' for telekom hotspots (DE)
* 'vodafone.uc' for vodafone hotspots (DE)
* 'generic-user-pass.uc' a template to demonstrate the optional parameter handling in login scripts

A typical and successful captive portal login looks like this:

```
[...]
user.info trm-3.0.0-r1[26222]: captive portal domain 'www.wifibahn.de' added to dhcp rebind allowlist
user.info trm-3.0.0-r1[26222]: captive portal login script for 'www.wifibahn.de' has been finished with rc '0'
user.info trm-3.0.0-r1[26222]: connected to uplink 'radio1/WIFI@DB/-' with mac 'B2:9D:F5:96:86:A4' (1/3)
[...]
```
**Building your own login script**  
The fastest way to a working script is to record the login once by hand and then replay it with curl. Any browser's developer tools can do the recording:

1. Connect a client to the hotspot - either directly, or through travelmate's own AP while the uplink is up - and open the portal page.
2. Open the developer tools (usually `F12`) and switch to the `Network` tab. Enable `Preserve log` (Chromium, Edge, Safari) resp. `Persist Logs` (Firefox, behind the gear icon) and `Disable cache`. A portal login almost always ends in a redirect, and without these options the recorded entries are dropped at that point.
3. Perform the login manually and watch which requests are sent.
4. Right-click the request that carries your credentials and choose `Copy` -> `Copy as cURL`. You now have the exact URL, method, headers, cookies and form fields as the browser sent them. `Save All As HAR` resp. `Export HAR` records the whole session if you want to study it later - note that recent Chromium versions strip cookies and authorization headers from the export unless you allow sensitive data in the devtools settings.
5. Strip the copied command down: the browser adds a lot of `Accept*`, `Sec-*` and `Priority` headers that no portal cares about. Keep the request body, the `Content-Type` and whatever the portal actually validates, and pass them as `args` to `fetch()` from the `travelmate.login` module. `fetch(url, { args: [ '--data', 'a=b' ] })` runs curl with travelmate's own settings (timeouts, uplink device, user agent) and returns `{ rc, body }`, `follow: false` keeps curl from following redirects and `write_out` adds a curl `--write-out` format. The module also provides `lookup()`, `urlencode()`, `between()` (text between two tags, the usual way to cut an url out of a portal page), `https_on(url, host)` (check an url taken from a portal page before credentials are sent to it) and the configured `captiveurl` and `useragent`.
6. Look for values that are only valid for one session - CSRF tokens, session ids, `sid` parameters. Those must not be copied into the script but fetched at runtime, see `wifibahn.uc` (cookie jar) or `vodafone.uc` (json response) for the two usual patterns.
7. Never hardcode credentials. Pass them via the uplink's `script_args` option and read them as `ARGV[0]` and `ARGV[1]`, like `generic-user-pass.uc` does.
8. Test the script on the router while the portal is actually in the way: `ucode /etc/travelmate/my.uc user pass; echo "rc: ${?}"`. Make sure it only exits `0` when the login really succeeded - a script that reports success too eagerly is worse than one that fails, because travelmate will happily keep the uplink.

The portal domain travelmate detected is in the system log: `logread -e "trm-"` shows it as `captive portal domain '<domain>' added to dhcp rebind allowlist`.

Hopefully more scripts for different captive portals will be provided by the community!

<a id="best-practice-and-tweaks"></a>
## Best practice and tweaks
**Radio assignment**  
If your router has more than one radio, keep the AP and the uplink on separate radios - sharing one radio between both costs a noticeable amount of throughput. Use `trm_radio` to restrict travelmate to the uplink radio(s) and `trm_revradio` to change the processing order, e.g. to prefer 5GHz over 2.4GHz.

**Signal quality thresholds**  
`trm_minquality` (default 35%) decides twice: a scan result below the threshold is not considered as a connection candidate at all, and an existing connection that drops below it is torn down so that travelmate can look for something better. Raising the value makes travelmate switch away earlier, lowering it keeps weak uplinks alive longer. Values well above 50% tend to make travelmate restless in hotels.

**Retry behaviour**  
`trm_maxretry` (default 3) limits the connection attempts per uplink. When the limit is reached, the affected uplink is disabled in the travelmate config and has to be re-enabled manually - which is intentional for permanently broken credentials, but worth keeping in mind in combination with `trm_netcheck`. Set `trm_maxretry` to '0' for unlimited retries if you never want an uplink to be disabled automatically. The disable shows up in the log as `uplink has been disabled '<radio>/<ssid>/<bssid>' (3/3)`, re-enable the uplink with the **On/Off** button in the LuCI station list or via `uci set travelmate.<section>.enabled='1'` and `uci commit travelmate`. With only one configured uplink, consider `revive` (see below), otherwise a longer outage or a slow radio after a wifi reload leaves you without uplink until you step in.

Per uplink, `revive` softens that. With a value of n, an uplink disabled by the retry limit is set back to 'enabled' after n run cycles, so a network that was only temporarily unavailable comes back on its own. Values below 10 are raised to 10, since a run cycle is roughly `trm_timeout` seconds long and shorter intervals only produce needless reconnect attempts. The number of revivals is capped by the global `trm_maxretry`, which also means that `revive` has no effect with `trm_maxretry` set to '0'. The cycle and round counters are kept in the runtime file '/var/run/travelmate/travelmate.revive', they are never written to the config and are cleared when the service is stopped or restarted, e.g. by a config change, so an uplink switched off by hand stays off. A successful connection clears the counters of that uplink. The enable and disable itself is still recorded in the travelmate config, so the LuCI station list always shows the real state.

**Open uplinks**  
`trm_autoadd` adds open networks to your wireless config on the fly, which is handy in hotels and on trains. Keep `trm_maxautoadd` at a sane value so that a busy location doesn't flood your config, and use `trm_ssidfilter` to skip the usual noise, e.g. `Chromecast*` or printer and camera SSIDs.

**Privacy and evil twin protection**  
`trm_randomize` generates a new random unicast MAC address for each uplink connection, so a hotspot operator can't trivially recognize your router across visits. `trm_eviltwin` skips access points with a locally administered (LAA) BSSID, which is a cheap indicator for a spoofed access point - note that some legit setups (mesh, repeaters) use LAA BSSIDs as well.

**Timing**  
`trm_maxwait` (default 30s) is the budget for a single connection attempt (association and DHCP) and scales the internal wait times, the curl requests use a fixed timeout of 5s per attempt. Some drivers need 30s and more to associate after a wifi reload, if attempts regularly time out ('uplink connection could not be established after ... seconds'), raise it to 45-60s. Lowering it makes travelmate give up on weak candidates faster. `trm_triggerdelay` adds a delay before processing starts after an ifup event, which is useful if your uplink needs a moment to settle.

**Subnet conflicts**  
Travelmate compares the uplink subnet against your router LAN network and logs a warning if both overlap. If you run into this frequently, change your LAN network to something uncommon, e.g. `10.200.1.0/24`, because most hotel networks use `192.168.0.0/24` or `192.168.1.0/24`.

<a id="troubleshooting-and-debug-options"></a>
## Troubleshooting & debug options
Travelmate provides an optional debug mode that writes detailed diagnostic information about every processing step to the system log. Under normal conditions only the relevant status messages are logged, to keep regular runs clean and silent. To enable debug mode, set the option `trm_debug` to `1`.

Whenever you encounter travelmate related processing problems, please enable `trm_debug`, restart travelmate and check the `Log View` tab in LuCI (or the syslog via `logread -e "trm-"`).

Typical symptoms:
* No uplink is found although it is in range: compare the reported signal quality in the debug log against `trm_minquality`, and make sure the uplink is still enabled in the travelmate config - the retry limit may have disabled it (log line `uplink has been disabled`, see 'Retry behaviour' above)
* An uplink connects but has no internet: the debug output of `f_net` shows the probe host, the effective url and the resulting state (`net ok`, `net cp '<domain>'` or `net nok`). A `net cp` state means a captive portal was detected and is waiting for a login
* A captive portal login script doesn't run: it has to be an executable ucode script located in `/etc/travelmate` with the extension `.uc`, everything else is rejected for security reasons
* The connection drops right after connecting: check for a subnet conflict warning between the uplink network and your router LAN network

<a id="support"></a>
## Support
Please join the travelmate discussion in this [forum thread](https://forum.openwrt.org/t/travelmate-support-thread/5155) or contact me by mail <dev@brenken.org>
If you want to report an error, please describe it in as much detail as possible - with (debug) logs, the current travelmate status and your travelmate configuration.

<a id="removal"></a>
## Removal
Stop the travelmate daemon with _/etc/init.d/travelmate stop_ and remove the travelmate packages if necessary.

<a id="donations"></a>
## Donations
You like this project - is there a way to donate? Generally speaking "No" - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.

If you still insist to donate some bucks ...
* I would be happy if you put your money in kind into other, social projects in your area, e.g. a children's hospice
* Let's meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
* Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken) and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!

Have fun!  
Dirk
