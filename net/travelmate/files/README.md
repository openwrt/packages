<!-- markdownlint-disable -->

# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate will set all station interfaces to an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt environment
* strong LuCI-Support with builtin interface wizard and a wireless station manager
* render the QR-Code of the selected Access Point in LuCI to comfortably transfer the WLAN credentials to your mobile devices
* fast uplink connections
* support all kinds of uplinks, incl. hidden and enterprise uplinks (WEP-based uplinks are no longer supported!)
* continuously checks the existing uplink connection (quality), e.g. for conditional uplink (dis-) connections
* automatically add open uplinks to your wireless config, e.g. hotel captive portals
* captive portal detection with internet online check and a 'heartbeat' function to keep the uplink connection up & running
* captive portal auto-login hook (configured via uci/LuCI), you are able to reference an external script for captive portal auto-logins (see example below)
* includes a vpn hook with support for 'wireguard' or 'openvpn' client setups to handle VPN (re-) connections automatically
* includes an email hook to 'msmtp' to send notification e-mails after every succesful uplink connect
* proactively scan and switch to a higher prioritized uplink, despite of an already existing connection
* connection tracking which keeps start and end date of an uplink connection
* automatically disable the uplink after n minutes, e.g. for timed connections
* automatically (re-)enable the uplink after n minutes, e.g. after failed login attempts
* option to generate a random unicast MAC address for each uplink connection
* ntp time sync before sending emails
* support devices with multiple radios in any order
* procd init and ntp-hotplug support
* runtime information available via LuCI & via 'status' init command
* status & debug logging to syslog

## Prerequisites
* [OpenWrt](https://openwrt.org), tested/compatible with current stable 23.x and latest OpenWrt snapshot
* 'dnsmasq' as dns backend
* 'iwinfo' for wlan scanning
* 'curl' for connection checking and all kinds of captive portal magic, e.g. cp detection and auto-logins
* a 'wpad' variant to support various WPA encrypted networks (WEP-based uplinks are no longer supported!)
* optional: 'qrencode' for AP QR code support
* optional: 'wireguard' or 'openvpn' for vpn client connections
* optional: 'msmtp' to send out travelmate related status messages via email

## Installation & Usage
* **Please note:** before you start with travelmate ...
    * you should setup at least one Access Point, ideally on a separate radio,
    * if you're updating from a former 1.x release, please use the '--force-reinstall --force-maintainer' options in opkg,
    * and remove any existing travelmate related uplink stations in your wireless config manually
* download [travelmate](https://downloads.openwrt.org/snapshots/packages/x86_64/packages)
* download [luci-app-travelmate](https://downloads.openwrt.org/snapshots/packages/x86_64/luci)
* install both packages (_opkg install travelmate_, _opkg install luci-app-travelmate_)
* the LuCI application is located under the 'Services' menu
* start the travelmate 'Interface Wizard' once
* add multiple uplink stations as you like via the 'Wireless Stations' tab
* happy traveling ...

## Travelmate config options
* usually the pre-configured travelmate setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' section:  

| Option             | Default                            | Description/Valid Values                                                                              |
| :----------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------- |
| trm_enabled        | 0, disabled                        | set to 1 to enable the travelmate service (this will be done by the Interface Wizard as well!)        |
| trm_debug          | 0, disabled                        | set to 1 to get the full debug output (logread -e "trm-")                                             |
| trm_iface          | -, not set                         | uplink- and procd trigger network interface, configured by the 'Interface Wizard'                     |
| trm_radio          | -, not set                         | restrict travelmate to a single radio or change the overall scanning order ('radio1 radio0')          |
| trm_captive        | 1, enabled                         | check the internet availability and handle captive portal redirections                                |
| trm_netcheck       | 0, disabled                        | treat missing internet availability as an error                                                       |
| trm_proactive      | 1, enabled                         | proactively scan and switch to a higher prioritized uplink, despite of an already existing connection |
| trm_autoadd        | 0, disabled                        | automatically add open uplinks like hotel captive portals to your wireless config                     |
| trm_randomize      | 0, disabled                        | generate a random unicast MAC address for each uplink connection                                      |
| trm_triggerdelay   | 2                                  | additional trigger delay in seconds before travelmate processing begins                               |
| trm_maxretry       | 3                                  | retry limit to connect to an uplink                                                                   |
| trm_minquality     | 35                                 | minimum signal quality threshold as percent for conditional uplink (dis-) connections                 |
| trm_maxwait        | 30                                 | how long should travelmate wait for a successful wlan uplink connection                               |
| trm_timeout        | 60                                 | overall retry timeout in seconds                                                                      |
| trm_maxautoadd     | 5                                  | limit the max. number of automatically added open uplinks. To disable this limitation set it to '0'   |
| trm_maxscan        | 10                                 | limit nearby scan results to process only the strongest uplinks                                       |
| trm_captiveurl     | http://detectportal.firefox.com    | pre-configured provider URLs that will be used for connectivity- and captive portal checks            |
| trm_useragent      | Mozilla/5.0 ...                    | pre-configured user agents that will be used for connectivity- and captive portal checks              |
| trm_nice           | 0, normal priority                 | change the priority of the travelmate background processing                                           |
| trm_mail           | 0, disabled                        | sends notification e-mails after every succesful uplink connect                                       |
| trm_mailreceiver   | -, not set                         | e-mail receiver address for travelmate notifications                                                  |
| trm_mailsender     | no-reply@travelmate                | e-mail sender address for travelmate notifications                                                    |
| trm_mailtopic      | travelmate connection to '<sta>'   | topic for travelmate notification E-Mails                                                             |
| trm_mailprofile    | trm_notify                         | profile used by 'msmtp' for travelmate notification E-Mails                                           |
| trm_stdvpnservice  | -, not set                         | standard vpn service which will be automatically added to new STA profiles                            |
| trm_stdvpniface    | -, not set                         | standard vpn interface which will be automatically added to new STA profiles                          |
  

* per uplink exist an additional 'uplink' section in the travelmate config, with the following options:  

| Option             | Default                            | Description/Valid Values                                                                              |
| :----------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------- |
| enabled            | 1, enabled                         | enable or disable the uplink, automatically set if the retry limit or the conn. expiry was reached    |
| device             | -, not set                         | match the 'device' in the wireless config section                                                     |
| ssid               | -, not set                         | match the 'ssid' in the wireless config section                                                       |
| bssid              | -, not set                         | match the 'bssid' in the wireless config section                                                      |
| con_start          | -, not set                         | connection start (will be automatically set after a successful ntp sync)                              |
| con_end            | -, not set                         | connection end (will be automatically set after a successful ntp sync)                                |
| con_start_expiry   | 0, disabled                        | automatically disable the uplink after n minutes, e.g. for timed connections                          |
| con_end_expiry     | 0, disabled                        | automatically (re-)enable the uplink after n minutes, e.g. after failed login attempts                |
| script             | -, not set                         | reference to an external auto login script for captive portals                                        |
| script_args        | -, not set                         | optional runtime args for the auto login script                                                       |
| macaddr            | -, not set                         | use a specified MAC address for the uplink
| vpn                | 0, disabled                        | automatically handle VPN (re-) connections                                                            |
| vpnservice         | -, not set                         | reference the already configured 'wireguard' or 'openvpn' client instance as vpn provider             |
| vpniface           | -, not set                         | the logical vpn interface, e.g. 'wg0' or 'tun0'                                                       |


## VPN client setup
Please follow one of the following guides to get a working vpn client setup on your travel router:

* [Wireguard client setup guide](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client)
* [OpenVPN client setup guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client)

**Please note:** Make sure to uncheck the "Bring up on boot" option during vpn interface setup, so that netifd doesn't interfere with travelmate.  
Once your vpn client connection is running, you can reference to that setup in travelmate to handle VPN (re-) connections automatically.

## E-Mail setup
To use E-Mail notifications you have to setup the package 'msmtp'.  

Modify the file '/etc/msmtprc', e.g. for gmail:
<pre><code>
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
</code></pre>

Finally enable E-Mail support in travelmate and add a valid E-Mail receiver address.

## Captive Portal auto-logins
For automated captive portal logins you can reference an external shell script per uplink. All login scripts should be executable and located in '/etc/travelmate' with the extension '.login'. The package ships multiple ready to run auto-login scripts:  
    * 'wifionice.login' for ICE hotspots (DE)
    * 'db-bahn.login' for german DB railway hotspots via portal login API (still WIP, only tested at Hannover central station)
    * 'chs-hotel.login' for german chs hotels
    * 'h-hotels.login' for Telekom hotspots in h+hotels (DE)
    * 'julianahoeve.login' for Julianahoeve beach resort (NL)
    * 'telekom.login' for telekom hotspots (DE)
    * 'vodafone.login' for vodafone hotspots (DE)
    * 'generic-user-pass.login' a template to demonstrate the optional parameter handling in login scripts

A typical and successful captive portal login looks like this:
<pre><code>
[...]
Thu Sep 10 13:30:16 2020 user.info trm-2.0.0[26222]: captive portal domain 'www.wifionice.de' added to to dhcp rebind whitelist
Thu Sep 10 13:30:19 2020 user.info trm-2.0.0[26222]: captive portal login '/etc/travelmate/wifionice.login ' for 'www.wifionice.de' has been executed with rc '0'
Thu Sep 10 13:30:19 2020 user.info trm-2.0.0[26222]: connected to uplink 'radio1/WIFIonICE/-' with mac 'B2:9D:F5:96:86:A4' (1/3)
[...]
</code></pre>

Hopefully more scripts for different captive portals will be provided by the community!

## Runtime information

**receive travelmate runtime information:**
<pre><code>
root@2go:~# /etc/init.d/travelmate status
::: travelmate runtime information
  + travelmate_status  : connected (net ok/51)
  + travelmate_version : 2.1.1
  + station_id         : radio0/403 Forbidden/00:0C:46:24:50:00
  + station_mac        : 94:83:C4:24:0E:4F
  + station_interfaces : trm_wwan, wg0
  + wpa_flags          : sae: ✔, owe: ✔, eap: ✔, suiteb192: ✔
  + run_flags          : captive: ✔, proactive: ✔, netcheck: ✘, autoadd: ✘, randomize: ✔
  + ext_hooks          : ntp: ✔, vpn: ✔, mail: ✘
  + last_run           : 2023.10.21-14:29:14
  + system             : GL.iNet GL-A1300, OpenWrt SNAPSHOT r24187-bb8fd41f9a
</code></pre>

To debug travelmate runtime problems, please always enable the 'trm\_debug' flag, restart travelmate and check the system log afterwards (_logread -e "trm-"_)

## Support
Please join the travelmate discussion in this [forum thread](https://forum.lede-project.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* remove the travelmate package (_opkg remove luci-app-travelmate_, _opkg remove travelmate_)

Have fun!  
Dirk  
