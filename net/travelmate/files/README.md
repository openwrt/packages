# travelmate, a wlan connection manager for travel router

## Description
If you’re planning an upcoming vacation or a business trip, taking your laptop, tablet or smartphone give you the ability to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or you’re limited on using a single device at once. Investing in a portable, mini travel router is a great way to connect all of your devices at once while having total control over your own personalized wireless network.  
A logical combination of AP+STA mode on one physical radio allows most of OpenWrt/LEDE supported router devices to connect to a wireless hotspot/station (STA) and provide a wireless access point (AP) from that hotspot at the same time. Downside of this solution: whenever the STA interface looses the connection it will go into an active scan cycle which renders the radio unusable for AP mode operation, therefore the AP is taken down if the STA looses its association.  
To avoid these kind of deadlocks, travelmate set all station interfaces in an "always off" mode and connects automatically to available/configured hotspots.  

## Main Features
* STA interfaces operating in an "always off" mode, to make sure that the AP is always accessible
* easy setup within normal OpenWrt/LEDE environment
* fast uplink connections
* procd init system support
* procd based hotplug support, the travelmate start will be triggered by interface triggers
* status & debug logging to syslog

## Prerequisites
* [OpenWrt](https://openwrt.org) or [LEDE](https://www.lede-project.org) trunk
* iw (default) or iwinfo for wlan scanning

## OpenWrt / LEDE trunk Installation & Usage
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/packages)
* install 'travelmate' (_opkg install travelmate_)
* configure your network to support (multiple) wlan uplinks and set travelmate config options (details see below)
* set 'trm\_enabled' option in travelmate config to '1'
* travelmate starts automatically during boot and will be triggered by procd interface triggers

## LuCI travelmate companion package
* download the package [here](https://downloads.lede-project.org/snapshots/packages/x86_64/luci)
* install 'luci-app-travelmate' (_opkg install luci-app-travelmate_)
* the application is located in LuCI under 'Services' menu
* _Thanks to Hannu Nyman for this great LuCI frontend!_

## Chaos Calmer installation notes
* 'travelmate' and 'luci-app-travelmate' are _not_ available as ipk packages in the Chaos Calmer download repository
* download the packages from a development snapshot directory (see download links above)
* manually transfer the packages to your routers temp directory (with tools like _sshfs_ or _winscp_)
* install the packages as described above

## Travelmate config options
* travelmate config options:
    * trm\_enabled => main switch to enable/disable the travelmate service (default: '0', disabled)
    * trm\_debug => enable/disable debug logging (default: '0', disabled)
    * trm\_maxwait => how long (in seconds) should travelmate wait for wlan interface reload action (default: '20')
    * trm\_maxretry => how many times should travelmate try to find an uplink after a trigger event (default: '3')
    * trm\_iw => set this option to '0' to use iwinfo for wlan scanning (default: '1', use iw)
    * trm\_iface => restrict the procd interface trigger to a (list of) certain wan interface(s) or disable it at all (default: not set, disabled)

## Setup
**1. configure a wwan interface in /etc/config/network:**
<pre><code>
[...]
config interface 'wwan'
        option proto 'dhcp'
[...]
</code></pre>

**2. add this interface to your firewall configuration in /etc/config/firewall:**
<pre><code>
[...]
config zone
        option name 'wan'
        option input 'REJECT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option network 'wan wan6 wwan'
[...]
</code></pre>

**3. add required ap and wwan stations to your wireless configuration in etc/config/wireless:**
<pre><code>
[...]
config wifi-iface
        option device 'radio0'
        option network 'lan'
        option ifname 'wlan0'
        option mode 'ap'
        option ssid 'example_ap'
        option encryption 'psk2+ccmp'
        option key 'abc'
        option disabled '0'
[...]
config wifi-iface
        option device 'radio0'
        option network 'wwan'
        option mode 'sta'
        option ssid 'example_01'
        option ifname 'wwan01'
        option encryption 'psk2+ccmp'
        option key 'abc'
        option disabled '1'
config wifi-iface
        option device 'radio0'
        option network 'wwan'
        option mode 'sta'
        option ssid 'example_02'
        option ifname 'wwan02'
        option encryption 'psk2+ccmp'
        option key 'xyz'
        option disabled '1'
config wifi-iface
        option device 'radio0'
        option network 'wwan'
        option mode 'sta'
        option ssid 'example_03'
        option ifname 'wwan03'
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
Please join the travelmate discussion in this [forum thread](https://forum.openwrt.org/viewtopic.php?id=67697) or contact me by [mail](mailto:dev@brenken.org)  

## Removal
* stop the travelmate daemon with _/etc/init.d/travelmate stop_
* optional: remove the travelmate package (_opkg remove travelmate_)

Have fun!  
Dirk  
