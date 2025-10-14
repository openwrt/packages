<!-- markdownlint-disable -->

# Travelmate, a wlan connection manager for travel routers

## Description
If you’re taking your laptop, tablet, or phone on
an upcoming vacation or business trip, you'll want
to connect with friends or complete work on the go.
But many hotels don’t have a secure wireless network setup or
limit you to using a single device at a time.  

Travelmate lets you use a small "travel router" to connect
all of your devices at once while having total control over your own
personal wireless network.  

Travelmate runs on OpenWrt, and provides an "uplink" to the hotel's wireless access point/hotspot.
Travelmate then becomes the Access Point (AP) for you and your companions,
providing secure access to the internet.
See the [Installation and Usage](#installation-and-usage) section below.  

Travelmate manages all the network settings, firewall settings,
connections to a hotel network, etc. and
automatically (re)connnects to configured APs/hotspots as they become available.  

## Main Benefits and Features

* Easy setup from LuCI web interface
  with **Interface Wizard** and **Wireless Station manager**
* Display a QR code to
  transfer the wireless credentials to your mobile devices
* Fast uplink connections
* Supports routers with multiple radios in any order
* Supports all kinds of uplinks, including hidden and enterprise uplinks.
  (WEP-based uplinks are no longer supported)
* Continuously checks the existing uplink quality,
  e.g. for conditional uplink (dis)connections
* Automatically add open uplinks to your wireless config, e.g. hotel captive portals
* Captive portal detection with a
  'heartbeat' function to keep the uplink connection up and running
* Captive portal hook for auto-login configured via uci/LuCI.
  Use an external script for
  captive portal auto-logins (see example below)
* VPN hook supports 'wireguard' or 'openvpn' client
  setups to handle VPN (re)connections automatically
* Email hook via 'msmtp' sends notification e-mails
  after every successful uplink connect
* Proactively scan and switch to a higher priority uplink,
  replacing an existing connection
* Connection tracking logs start and end date of an uplink connection
* Automatically disable the uplink after n minutes, e.g. for timed connections
* Automatically (re)enable the uplink after n minutes, e.g. after failed login attempts
* (Optional) Generate a random unicast MAC address for each uplink connection
* NTP time sync before sending emails
* procd init and ntp-hotplug support
* Runtime information available via LuCI & via 'status' init command
* Log status and debug information to syslog
* STA interfaces operate in an "always off" mode,
  to make sure that the AP is always accessible

## Prerequisites
* [OpenWrt](https://openwrt.org), tested/compatible with current stable 23.x and latest OpenWrt snapshot
* The `luci-app-travelmate` ensures these packages are present:
  * 'dnsmasq' as dns backend
  * 'iw' for wlan scanning
  * 'curl' for connection checking and all kinds of captive portal magic,
     e.g. cp detection and auto-logins
  * a 'wpad' variant to support various WPA encrypted networks
    (WEP-based uplinks are no longer supported!)
* optional: 'wireguard' or 'openvpn' for vpn client connections
* optional: 'msmtp' to send out Travelmate related status messages via email

## Installation and Usage
* Install OpenWrt on your router, and set it up to allow wireless connections.
  Be sure to set a strong password on the wireless channel(s) so that only
  you and your companions can use it.
* Decide which radio you'll use for the Travelmate uplink (radio0, radio1, etc):
  * 2.4GHz allows a longer (more distant) link; 5GHz provides a faster link
  * Travelmate works on all radios.
  But for better performance, configure the AP on a separate radio from
  the one you're planning to use as the uplink.
* Use LuCI web interface to install both **travelmate** and **luci-app-travelmate**
* Open the Travelmate LuCI application - **Services -> Travelmate**
* You must use the Travelmate **Interface Wizard** one time to
  configure the uplink, firewall and other network settings
* Use the **Wireless Stations** tab to add an uplink station
  * **Scan** the radio you chose for the uplink
  * Click **Add Uplink...** for the desired SSID.
    If there are multiples, choose the one with the largest _Strength_
  * You'll need to enter the credentials (password, etc)
  * You should be "on the air" - test by browsing the internet
* You may add additional uplinks (for different locations)
  by repeating the previous step
* Happy traveling ...

## Travelmate config options
* usually the pre-configured Travelmate setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' section:  

| Option             | Default                            | Description/Valid Values                                                                              |
| :----------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------- |
| trm_enabled        | 0, disabled                        | set to 1 to enable the travelmate service (this will be done by the Interface Wizard as well!)        |
| trm_debug          | 0, disabled                        | set to 1 to get the full debug output (logread -e "trm-")                                             |
| trm_iface          | -, not set                         | uplink- and procd trigger network interface, configured by the 'Interface Wizard'                     |
| trm_radio          | -, not set                         | restrict travelmate to a single radio or change the overall scanning order ('radio1 radio0')          |
| trm_scanmode       | -, active                          | send active probe requests or passively listen for beacon frames with 'passive'                       |
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
| trm_captiveurl     | http://detectportal.firefox.com    | pre-configured provider URLs that will be used for connectivity- and captive portal checks            |
| trm_useragent      | Mozilla/5.0 ...                    | pre-configured user agents that will be used for connectivity- and captive portal checks              |
| trm_nice           | 0, normal priority                 | change the priority of the travelmate background processing                                           |
| trm_mail           | 0, disabled                        | sends notification e-mails after every succesful uplink connect                                       |
| trm_mailreceiver   | -, not set                         | e-mail receiver address for travelmate notifications                                                  |
| trm_mailsender     | no-reply@travelmate                | e-mail sender address for travelmate notifications                                                    |
| trm_mailtopic      | travelmate connection to '<sta>'   | topic for travelmate notification E-Mails                                                             |
| trm_mailprofile    | trm_notify                         | profile used by 'msmtp' for travelmate notification E-Mails                                           |
| trm_vpn            | 0, disabled                        | VPN connections will be managed by travelmate                                                         |
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
Please read one of the following guides to get a working vpn client setup on your travel router:

* [Wireguard client setup guide](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client)
* [OpenVPN client setup guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci)

**Please note:** Make sure to uncheck the "Bring up on boot" option during vpn interface setup, so that netifd doesn't interfere with travelmate.  
Also please prevent potential vpn protocol autostarts, e.g. add in newer openvpn uci configs an additional 'globals' section:  
<pre><code>
config globals 'globals'
        option autostart '0'
</code></pre>
Once your vpn client connection setup is correct, you can reference to that config in travelmate to handle VPN (re-) connections automatically.

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

Finally enable E-Mail support in Travelmate and add a valid E-Mail receiver address.

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

**Receive Travelmate runtime information:**
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

To debug travelmate runtime problems, please always enable the 'trm\_debug' flag, restart Travelmate and check the system log afterwards (_logread -e "trm-"_)

## Support
Please join the Travelmate discussion in this [forum thread](https://forum.openwrt.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the Travelmate daemon with _/etc/init.d/travelmate stop_
* remove the Travelmate package (_opkg remove luci-app-travelmate_, _opkg remove travelmate_)

## Donations
You like this project - is there a way to donate? Generally speaking "No" - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.  

If you still insist to donate some bucks ...  
* I would be happy if you put your money in kind into other, social projects in your area, e.g. a children's hospice
* Let's meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
* Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken) and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!  

Have fun!  
Dirk  
