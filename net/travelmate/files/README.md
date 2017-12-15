# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt/LEDE supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate set all station interfaces in an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt/LEDE environment
* strong LuCI-Support with builtin interface wizard and a wireless station manager
* fast uplink connections
* support all kinds of uplinks, incl. hidden and enterprise uplinks
* trigger- or automatic-mode support, the latter one is the default and checks the existing uplink connection regardless of ifdown event trigger actions every n seconds
* support of devices with multiple radios
* procd init and hotplug support
* runtime information available via LuCI & via 'status' init command
* status & debug logging to syslog

## Prerequisites
* [LEDE](https://www.lede-project.org) 17.01 or latest snapshot
* iwinfo for wlan scanning

## LEDE trunk Installation & Usage
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/packages)
* install 'travelmate' (_opkg install travelmate_)
* configure your network:
    * recommended: use the LuCI frontend with builtin interface wizard and a wireless station manager
    * manual: see detailed configure steps below
    * at least you need one configured AP and one STA interface

## LuCI travelmate companion package
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/luci)
* install 'luci-app-travelmate' (_opkg install luci-app-travelmate_)
* the application is located in LuCI under 'Services' menu

## Travelmate config options
* usually the pre-configured travelmate setup works quite well and no manual config overrides are needed, all listed options apply to the 'global' config section:
    * trm\_enabled => main switch to enable/disable the travelmate service (default: '0', disabled)
    * trm\_debug => enable/disable debug logging (default: '0', disabled)
    * trm\_automatic => keep travelmate in an active state (default: '1', enabled)
    * trm\_maxwait => how long (in seconds) should travelmate wait for a successful wlan interface reload action (default: '30')
    * trm\_maxretry => how many times should travelmate try to connect to an uplink, '0' means unlimited retries. (default: '3')
    * trm\_timeout => timeout in seconds for "automatic mode" (default: '60')
    * trm\_radio => limit travelmate to a dedicated radio, e.g. 'radio0' (default: not set, use all radios)
    * trm\_iface => main uplink / procd trigger network interface (default: trm_wwan)
    * trm\_triggerdelay => additional trigger delay in seconds before travelmate processing starts (default: '2')

## Runtime information

**receive travelmate runtime information:**
<pre><code>
::: travelmate runtime information
 travelmate_version : 1.0.0
 station_connection : true
 station_id         : blackhole/04:F0:21:2F:B7:64
 station_interface  : trm_wwan
 station_radio      : radio1
 last_rundate       : 15.12.2017 13:51:30
 system             : TP-LINK RE450, OpenWrt SNAPSHOT r5422+84-9fe59abef8
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
        option ssid 'example_01'
        option encryption 'psk2+ccmp'
        option key 'abc'
        option disabled '1'
[...]
config wifi-iface
        option device 'radio0'
        option network 'trm_wwan'
        option mode 'sta'
        option ssid 'example_02'
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
**Q:** What's about 'trigger' and 'automatic' mode?  
**A:** In "trigger" mode travelmate will be triggered solely by procd interface down events, whenever an uplink disappears travelmate tries n times (default 3) to find a new uplink or reconnect to the old one. The 'automatic' mode keeps travelmate in an active state and checks every n seconds the connection status / the uplink availability regardless of procd event trigger.  

**Q:** What happen with misconfigured uplinks, e.g. due to outdated wlan passwords?  
**A:** Travelmate tries n times (default 3) to connect, then the respective uplink SSID will be marked / renamed to '_SSID_\_err'. In this case use the builtin wireless station manager to update your wireless credentials. To disable this functionality at all set the Connection Limit ('trm\_maxretry') to '0', which means unlimited retries.  

**Q:** Is travelmate compatible with CC/Openwrt?  
**A:** Travelmate was never tested with an ancient CC/OpenWrt release ... it should still work, but no promises.  

[...] to be continued [...]
## Support
Please join the travelmate discussion in this [forum thread](https://forum.lede-project.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* optional: remove the travelmate package (_opkg remove travelmate_)

Have fun!  
Dirk  
