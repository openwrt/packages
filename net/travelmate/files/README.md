# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate will set all station interfaces to an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt environment
* strong LuCI-Support with builtin interface wizard and a wireless station manager
* fast uplink connections
* support all kinds of uplinks, incl. hidden and enterprise uplinks
* continuously checks the existing uplink connection (quality), e.g. for conditional uplink (dis-) connections
* automatically add open uplinks to your wireless config, e.g. hotel captive portals
* captive portal detection with internet online check and a 'heartbeat' function to keep the uplink connection up & running
* captive portal auto-login hook (configured via uci/LuCI), you could reference an external script for captive portal auto-logins (see example below)
* proactively scan and switch to a higher prioritized uplink, despite of an already existing connection
* support devices with multiple radios in any order
* procd init and hotplug support
* runtime information available via LuCI & via 'status' init command
* status & debug logging to syslog
* optional: the LuCI frontend shows the WiFi QR codes from all configured Access Points. It allows you to connect your Android or iOS devices to your router’s WiFi using the QR code

## Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series (19.07.x) and with the latest OpenWrt snapshot
* iwinfo for wlan scanning, uclient-fetch for captive portal detection, dnsmasq as dns backend
* optional: qrencode 4.x for QR code support
* optional: wpad (the full version, not wpad-mini) to use Enterprise WiFi
* optional: curl to use external scripts for captive portal auto-logins

## Installation & Usage
* download the package [here](https://downloads.openwrt.org/snapshots/packages/x86_64/packages)
* install 'travelmate' (_opkg install travelmate_)
* configure your network:
    * recommended: use the LuCI frontend with builtin interface wizard and a wireless station manager
    * manual: see detailed configuration steps below
    * at least you need one configured AP and one STA interface

## LuCI travelmate companion package
* download the package [here](https://downloads.openwrt.org/snapshots/packages/x86_64/luci)
* install 'luci-app-travelmate' (_opkg install luci-app-travelmate_)
* the application is located in LuCI under 'Services' menu

## Travelmate config options
* usually the pre-configured travelmate setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' section:
    * trm\_enabled => main switch to enable/disable the travelmate service (bool/default: '0', disabled)
    * trm\_debug => enable/disable debug logging (bool/default: '0', disabled)
    * trm\_captive => enable/disable the captive portal detection (bool/default: '1', enabled)
    * trm\_proactive => enable/disable the proactive uplink switch (bool/default: '1', enabled)
    * trm\_autoadd => automatically add open uplinks to your wireless config (bool/default: '0', disabled)
    * trm\_minquality => minimum signal quality threshold as percent for conditional uplink (dis-) connections (int/default: '35', valid range: 20-80)
    * trm\_maxwait => how long (in seconds) should travelmate wait for a successful wlan interface reload action (int/default: '30', valid range: 20-40)
    * trm\_maxretry => how many times should travelmate try to connect to an uplink (int/default: '3', valid range: 1-10)
    * trm\_timeout => overall retry timeout in seconds (int/default: '60', valid range: 30-300)
    * trm\_radio => limit travelmate to a single radio (e.g. 'radio1') or change the overall scanning priority (e.g. 'radio1 radio2 radio0') (default: not set, use all radios 0-n)
    * trm\_iface => uplink / procd trigger network interface (default: trm_wwan)
    * trm\_triggerdelay => additional trigger delay in seconds before travelmate processing begins (int/default: '2')

## Captive Portal auto-logins
For automated captive portal logins you could reference external shell scripts. All login scripts should be executable and located in '/etc/travelmate' with the extension '.login'. The provided 'wifionice.login' script example requires curl and automates the login to german ICE hotspots, it also explains the principle approach to extract runtime data like security tokens for a successful login. Hopefully more scripts for different captive portals will be provided by the community ...

A typical/successful captive portal login looks like this:
<pre><code>
[...]
Mon Aug  5 10:15:48 2019 user.info travelmate-1.4.10[1481]: travelmate instance started ::: action: start, pid: 1481
Mon Aug  5 10:16:17 2019 user.info travelmate-1.4.10[1481]: captive portal login '/etc/travelmate/wifionice.login' for 'www.wifionice.de' has been executed with rc '0'
Mon Aug  5 10:16:23 2019 user.info travelmate-1.4.10[1481]: connected to uplink 'radio1/WIFIonICE/-' (1/5, GL.iNet GL-AR750S, OpenWrt SNAPSHOT r10644-cb49e46a8a)
[...]
</code></pre>

## Runtime information

**receive travelmate runtime information:**
<pre><code>
~# /etc/init.d/travelmate status
::: travelmate runtime information
  + travelmate_status  : connected (net ok/100)
  + travelmate_version : 1.4.10
  + station_id         : radio1/blackhole/-
  + station_interface  : trm_wwan
  + faulty_stations    : 
  + last_rundate       : 2019.08.03-20:37:19
  + system             : GL.iNet GL-AR750S, OpenWrt SNAPSHOT r10644-cb49e46a8a
</code></pre>

To debug travelmate runtime problems, please always enable the 'trm\_debug' flag, restart travelmate and scan the system log (_logread -e "travelmate"_)

## Manual Setup
**1. configure the travelmate wwan interface in /etc/config/network:**
<pre><code>
[...]
config interface 'trm_wwan'
        option proto 'dhcp'
[...]
</code></pre>

**2. add this interface to your firewall configuration in /etc/config/firewall:**
<pre><code>
[...]
config zone
        option name 'wan'
        option network 'wan wan6 trm_wwan'
[...]
</code></pre>

**3. at least add one ap and (multiple) wwan stations to your wireless configuration in etc/config/wireless:**
<pre><code>
[...]
config wifi-iface
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'example_ap'
        option encryption 'psk2+ccmp'
        option key 'abc'
        option disabled '0'
[...]
config wifi-iface
        option device 'radio0'
        option network 'trm_wwan'
        option mode 'sta'
        option ssid 'example_usual'
        option encryption 'psk2+ccmp'
        option key 'abc'
        option disabled '1'
[...]
config wifi-iface
        option device 'radio0'
        option network 'trm_wwan'
        option mode 'sta'
        option ssid 'example_hidden'
        option bssid '00:11:22:33:44:55'
        option encryption 'psk2+ccmp'
        option key 'xyz'
        option disabled '1'
[...]
</code></pre>

**4. start travelmate:**
<pre><code>
edit /etc/config/travelmate and set 'trm_enabled' to '1'
/etc/init.d/travelmate restart
</code></pre>

## Support
Please join the travelmate discussion in this [forum thread](https://forum.lede-project.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* optional: remove the travelmate package (_opkg remove travelmate_)

Have fun!  
Dirk  
