# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt/LEDE supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate set all station interfaces in an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt/LEDE environment
<<<<<<< HEAD
* strong LuCI-Support to simplify the interface setup
=======
* strong LuCI-Support with builtin interface wizard and wireless interface manager
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
* fast uplink connections
* manual / automatic mode support, the latter one checks the existing uplink connection regardless of ifdown event trigger actions every n seconds
* support of devices with multiple radios
* procd init and hotplug support
* runtime information available via LuCI & via 'status' init command
* status & debug logging to syslog

## Prerequisites
* [LEDE](https://www.lede-project.org) 17.01 or latest snapshot
<<<<<<< HEAD
* iw for wlan scanning
=======
* iwinfo for wlan scanning
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d

## LEDE trunk Installation & Usage
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/packages)
* install 'travelmate' (_opkg install travelmate_)
* configure your network:
<<<<<<< HEAD
    * automatic: use the LuCI frontend with automatic interface setup, that's the recommended way
    * manual: see detailed configure steps below
=======
    * recommended: use the LuCI frontend with automatic STA interface setup and connection manager
    * manual: see detailed configure steps below
    * at least you need one configured AP and one STA interface
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d

## LuCI travelmate companion package
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/luci)
* install 'luci-app-travelmate' (_opkg install luci-app-travelmate_)
* the application is located in LuCI under 'Services' menu

## Travelmate config options
* travelmate config options:
    * trm\_enabled => main switch to enable/disable the travelmate service (default: '0', disabled)
    * trm\_debug => enable/disable debug logging (default: '0', disabled)
    * trm\_automatic => keep travelmate in an active state (default: '1', enabled)
    * trm\_maxwait => how long (in seconds) should travelmate wait for a successful wlan interface reload action (default: '30')
    * trm\_maxretry => how many times should travelmate try to find an uplink after a trigger event (default: '3')
    * trm\_timeout => timeout in seconds for "automatic mode" (default: '60')
    * trm\_radio => limit travelmate to a dedicated radio, e.g. 'radio0' (default: not set, use all radios)
    * trm\_iface => restrict the procd interface trigger to a (list of) certain wan interface(s) or disable it at all (default: trm_wwan)
    * trm\_triggerdelay => additional trigger delay in seconds before travelmate processing starts (default: '1')

## Runtime information

**receive travelmate runtime information:**
<pre><code>
root@adb2go:~# /etc/init.d/travelmate status
::: travelmate runtime information
 travelmate_version : 0.7.2
 station_connection : true
 station_ssid       : blackhole
 station_interface  : trm_wwan
 station_radio      : radio1
 last_rundate       : 06.05.2017 06:58:22
 system             : LEDE Reboot SNAPSHOT r4051-3ddc1914ba
</code></pre>

<<<<<<< HEAD
## Setup
=======
## Manual Setup
>>>>>>> fb00f8f39d2fd26dba01970cd859777609a5b91d
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
config wifi-iface
        option device 'radio0'
        option network 'trm_wwan'
        option mode 'sta'
        option ssid 'example_02'
        option encryption 'psk2+ccmp'
        option key 'xyz'
        option disabled '1'
config wifi-iface
        option device 'radio0'
        option network 'trm_wwan'
        option mode 'sta'
        option ssid 'example_03'
        option encryption 'none'
        option disabled '1'
[...]
</code></pre>

**4. reload network configuration & start travelmate:**
<pre><code>
/etc/init.d/network reload
/etc/init.d/travelmate start
</code></pre>

## Support
Please join the travelmate discussion in this [forum thread](https://forum.lede-project.org/t/travelmate-support-thread/5155) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* optional: remove the travelmate package (_opkg remove travelmate_)

Have fun!  
Dirk  
