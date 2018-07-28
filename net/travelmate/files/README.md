# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate set all station interfaces in an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt environment
* strong LuCI-Support with builtin interface wizard and a wireless station manager
* fast uplink connections
* support all kinds of uplinks, incl. hidden and enterprise uplinks
* continuously checks the existing uplink connection (quality), e.g. for conditional uplink (dis-) connections
* captive portal detection with internet online check and a 'heartbeat' function to keep the uplink connection up & running
* support of devices with multiple radios
* procd init and hotplug support
* runtime information available via LuCI & via 'status' init command
* status & debug logging to syslog
* optional: the LuCI frontend shows the WiFi QR codes from all configured Access Points. It allows you to connect your Android or iOS devices to your router’s WiFi using the QR code

## Prerequisites
* [OpenWrt](https://openwrt.org), tested with the stable release series (17.01.x) and with the latest OpenWrt snapshot
* iwinfo for wlan scanning, uclient-fetch for captive portal detection
* optional: qrencode 4.x for QR code support

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
    * trm\_minquality => minimum signal quality threshold as percent for conditional uplink (dis-) connections (int/default: '35', valid range: 20-80)
    * trm\_maxwait => how long (in seconds) should travelmate wait for a successful wlan interface reload action (int/default: '30', valid range: 20-40)
    * trm\_maxretry => how many times should travelmate try to connect to an uplink (int/default: '3', valid range: 1-10)
    * trm\_timeout => overall retry timeout in seconds (int/default: '60', valid range: 30-300)
    * trm\_radio => limit travelmate to a dedicated radio, e.g. 'radio0' (default: not set, use all radios)
    * trm\_iface => main uplink / procd trigger network interface (default: trm_wwan)
    * trm\_triggerdelay => additional trigger delay in seconds before travelmate processing begins (int/default: '2')

## Runtime information

**receive travelmate runtime information:**
<pre><code>
~# /etc/init.d/travelmate status
::: travelmate runtime information
  + travelmate_status  : connected (net ok/78)
  + travelmate_version : 1.2.1
  + station_id         : radio1/blackhole/01:02:03:04:05:06
  + station_interface  : trm_wwan
  + faulty_stations    : 
  + last_rundate       : 28.07.2018 21:17:45
  + system             : TP-LINK RE450, OpenWrt SNAPSHOT r7540+5-20c4819c7b
</code></pre>

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

## FAQ
**Q:** What happen with misconfigured, faulty uplinks, e.g. due to outdated wlan passwords?  
**A:** Travelmate tries n times (default 3) to connect, then the respective uplink will be marked as "faulty" in the JSON runtime file and hereafter ignored. To reset the JSON runtime file, simply restart travelmate.  
**Q:** How to connect to hidden uplinks?  
**A:** See 'example\_hidden' STA configuration above, option 'SSID' and 'BSSID' must be specified for successful connections.  

## Support
Please join the travelmate discussion in this [forum thread](https://forum.lede-project.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* optional: remove the travelmate package (_opkg remove travelmate_)

Have fun!  
Dirk  
