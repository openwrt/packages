<!--
---------------------------------------------------------------------
(C) 2014 - 2017 Eloi Carbo <eloicaso@openmailbox.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------
-->

# Bird{4|6} UCI Packages Documentation
*  BIRD Daemon's original documentation: http://bird.network.cz/?get_doc
* Usage examples (Gitlab): https://gitlab.labs.nic.cz/labs/bird/wikis/home
* Extra documentation in English & Catalan: https://github.com/eloicaso/bgp-bmx6-bird-docn
* If you want to add new options to bird*-openwrt packages add a pull request or issue in: https://github.com/eloicaso/bird-openwrt

### Options used in /etc/config/bird{4|6}
> *Clarification*: Any reference to **{4|6}** in this document means that it applies to both Bird4 and Bird6 packages and configurations. Otherwise, the text will clarify which specific package is affected by it.

#### CONFIGURATION SECTION 1: 'bird'
Usage example :
``` Bash
config bird 'bird'
    option use_UCI_config '1'
    option UCI_config_file '/tmp/bird4.conf'
```

* **use_UCI_config**: *Boolean*
This option allows you to use package's UCI configuration translation instead of using the original Bird config file (hand-edited). If true/1, birdX init.d script will use the translation placed in "UCI_config_file". Otherwise, it will use the default "/etc/birdX.conf" configuration.
**\[HINT**\] This could be used to allow multiple configurations and swap them easily.
*Default: 0*

* **UCI_config_file**: *String* File_path
This option sets where will be placed the translation of the UCI configuration file.
*Default: /tmp/birdX.conf*


#### CONFIGURATION SECTION 2: 'global NAME'
Usage example:
```Bash
config global 'global'
    option log_file '/tmp/bird4.log'
    option log 'all'
    option debug 'off'
    option router_id '172.16.1.6'
```

* **log_file**: *String* File_path
This option sets the path of the file used to save Bird Log and Debug's information.
*Default: /tmp/bird{4|6}.log*

* **log**: *String/Enumeration* (all/off, info, warning, error, fatal, debug, trace, remote, auth, bug)
This option allows you to set which information you want to save in the Log file.
**\[HINT\]** Use the enumeration like: { info, waning, error }. Do not enter any extra option if you select "all" (Bird will fail to start).
*Default: all*

* **debug**: *String/Enumeration* ( all/off, states, routes, filters, interfaces, events, packets)
This option allows you to set which **extra** debug information will be saved in the "log_file" file.
**\[HINT\]** Use the enumeration like: { info, waning, error }. Do not enter any extra option if you select "all" (Bird will fail to start).
*Default: off*

* **router_id**: IP Address
This option sets which will be the Router ID.
**\[HINT\]** In **Bird4** this field is the lowest IP address (not loopback) among the existing interfaces by default (Optional property).
In **Bird6** there is no default value and it is mandatory.

* **listen_bgp_addr**: IP Address
This option sets the IP address that Bird BGP instances will listen by default.
*Default: 0.0.0.0*

* **listen_bgp_port**: *Integer* Port
This option sets the port that Bird BGP instances will listen by default.
*Default: IP 0.0.0.0 and Port 179*

* **listen_bgp_dual**: *Boolean*
**\[Bird6\]** This option configures Bird6 BGP instances to listen only IPv6 or IPv4/6 BGP routes.


#### <a name="table"></a>CONFIGURATION SECTION 3: 'table'
Usage example:
``` Bash
config table
    option name 'aux'
```

* **name**: *String*
This option allows you to set the name of the auxiliar kernel tables used for Bird. This option is mandatory for most of the protocols.


#### CONFIGURATION SECTION 4: 'kernel NAME'
Usage example:
``` Bash
config kernel kernel1
    option table 'aux'
    option import 'all'
    option export 'all'
    option kernel_table '100'
    option scan_time '10'
    option learn '1'
    option persist '0'
    option disabled '0'
```

* **table**: *String*
Set an auxiliary table for the current kernel routing instance. This table **MUST** exist as a [table](#table) instance.
**\[HINT\]** If there is an Kernel protocol instance that uses the "main" kernel table, not using table/kernel_table options, this should be included before the rest of Kernel instances (which will use auxiliary tables).

* **import**: *String/Filter* function
This option delimits which routes coming from other protocols will be accepted. 
Options are:
**All/none**: allows to import all the routes or none of them.
**Filter name**: \[import 'bgp_filter_in'\] the protocol will use the filter with the given name (Specified filter **must** exists in any file under /etc/bird{4|6}/filters/ folder).

* export: String/Filter function
This option delimits which routes going out from the protocol. This option allows filters in different manners:
**All/none**: allows to export all the routes or none of them.
**Filter name**: \[export 'bgp_filter_out'\] the protocol will use the filter with the given name(Specified filter **must** exists in any file under /etc/bird{4|6}/filters/ folder).

* **kernel_table**: *Integer*
This option sets the identification number of the Kernel table that will be used instead of the main one.
*Default: main table (254)*

* **scan_time**: *Integer*
This option sets the time between checks to target kernel table.

* **learn**: *Boolean*
Set if kernel table will add the routes from other routing protocols or the system administrator.

* **persist**: *Boolean*
Set if Bird Daemon will save the known routes when exiting or if it will clean the routing table.

* **disable**: *Boolean*
This option sets if the protocol will be used or dismissed.
*Default: 0*


#### CONFIGURATION SECTION 5: 'device NAME'
Usage example:
``` Bash
config device device1
    option scan_time '10'
    option disabled '0'
```

* **scan_time***: *Integer*
This option sets the time between checks to the selected kernel table.

* **disable**: *Boolean*
This option sets if the protocol will be used or dismissed.
*Default: 0*


#### CONFIGURATION SECTION 6: 'static NAME'
Usage example:
``` Bash
config static static1
    option table 'aux'
    option disabled '0'
```

* **table**: *String*
Set an auxiliary table for the current static instance. This table **MUST** exist as a [table](#table) instance.
**\[HINT\]** If there is an static instance that uses the "main" kernel table (not using table/kernel_table options), this should be included before the rest of static instances (which will use auxiliary tables).

* **disable**: *Boolean*
This option sets if the protocol will be used or dismissed.
*Default: 0*


#### CONFIGURATION SECTION 7 & 8: 'bgp NAME' & 'bgp_template NAME'
This section merges two different configuration sections: BGP *instances* and *templates*. The first one is the basic BGP configuration part and the second one is the template used to minimize the number of options written in the configuration file for each unique instance. Both configuration sections have the same options but, when Bird finds duplicities, the instance will overwrite the template options.

Usage examples:
``` Bash
# instance
config bgp bgp1
    option template 'bgp_common'
    option description 'Description of the BGP instance'
    option neighbor_address '172.16.1.5'
    option neighbor_as '65530'
    option source_address '172.16.1.6'
    option next_hop_self '0'
    option next_hop_keep '0'
    option rr_client '1'
    option rr_cluster_id '172.16.1.6'
```

``` Bash
# template
config bgp_template bgp_common
    option table 'aux'
    option import 'all'
    option export 'all'
    option local_address '172.16.1.6'
    option local_as '65001'
    option import_limit '100'
    option import_limit_action 'warn'
    option export_limit '100'
    option export_limit_action 'warn'
    option receive_limit '100'
    option receive_limit_action 'warn'
    option disabled '0'
```

* **template**: *String*
This option states the template used for current BGP instance. This template MUST exist.

* **description**: *String*
This option allows to add a description of the bgp instance and its function.

* **local_addr**: IP address
This option allows to set the IP source of our Autonomous System (AS).

* **local_as**: *Integer*
This option allows to set the identification number of our AS number. This option is mandatory for each BGP instance.

* **neighbor_addr**: IP address 
Each BGP instance has a neighbor connected to. This option allows to set its IP address.

* **neighbor_as**: *Integer*
Each BGP instance has a neighbor connected to. This option allows to set its AS ID.

* **next_hop_self**: *Boolean*
If this option is true, BGP protocol will avoid to calculate the next hop and always advertise own "Router id" IP.
*Default: 0*

* **next_hop_keep**: *Boolean*
If this option is true, BGP will always use the received next_hop information to redirect the route.
*Default: 0*

* **rr_client**: *Boolean*
IF this option is true, the router will be set as Route Reflector and will treat the rest of the routers as RR clients.
*Default: 0*

* **rr_cluster_id**: *Integer*
This option sets the identification number of the RR cluster. All the nodes in a cluster needs this option and share the same number.
*Default: Router id*

* **import_limit**: *Integer*
This option sets the limit of routes that a protocol can import until take the action indicated in the import_limit_action.
import_limit also counts filtered routes (even dropped ones).
*Default: 0 (no limit)*

* **import_limit_action**: *String*
This option allows to decide the action to take when reached the limit of imported routes.
Actions are: warn, block, restart, disable

* **export_limit**: *Integer*
This option sets the limit of routes that a protocol can export until take the action indicated in the export_limit_action.
*Default: 0 (no limit)*

* **export_limit_action**: *String*
This option allows to decide the action to take when reached the limit of exported routes.
Actions are: warn, block, restart, disable

* **receive_limit**: *Integer*
This option sets the limit of routes that a protocol can receive until take the action indicated in the receive_limit_action. receive_limit only counts accepted routes from the protocol.
*Default: 0 (no limit)*

* **receive_limit_action**: *String*
This option allows to decide the action to take when reached the limit of received routes.
Actions are: warn, block, restart, disable

* **disable**: *Boolean*
This option sets if the protocol will be used or dismissed.
*Default: 0*


#### CONFIGURATION SECTION 9: 'route' 
Usage example:
``` Bash
config route
    option instance 'static1'
    option type 'router'
    option prefix '192.168.9.0/24'
    option via '10.99.105.159'

config route
    option instance 'static1'
    option type 'special'
    option prefix '192.168.2.0/24'
    option attribute 'unreachable'

config route
    option instance 'static1'
    option type 'iface'
    option prefix '192.168.3.0/24'
    option iface 'mgmt0'

config route
    option instance 'static1'
    option type 'recursive'
    option prefix '192.168.4.0/24'
    option ip '192.168.1.1'

config route
    option instance 'static1'
    option type 'multipath'
    option prefix '192.168.30.0/24'
    list l_via '172.16.1.5'
    list l_via '172.16.1.6'
```

* **instance**: *String*
This option indicates the route that the static protocol instance will apply.

* **type**: *String*
This option states the type of route that will be applied. Also defines the options available for it.
Types are: 'router', 'special', 'iface', 'recursive' or 'multipath'.

* **prefix**: IP address/network
This option allows to define the network that you want to define.
**\[router only\]** 
**via**: IP Address
This option indicates the IP address of the neighbor router where the routes will pass through.
**\[special only\]**
**attribute**: *String*
This option will mark the behaviour of the route.
Attribures are: 'blackhole', 'unreachable' or 'prohibit'.
**\[iface only\]**
**iface**: *String*
This option indicates the interface used to redirect the BGP routes. Careful, the interface MUST exist, or Bird will fail to start.
**\[recursive only\]**
**ip**: IP address
This option states the IP address which the next hop will depend on.
**\[multipath only\]**
This is a list, not an option. Use it as in the example, or check the UCI configuration documentation.
**l_via**: IP address
This list of IPs specifies the list (following the sequence) of routers that the route will follow as next hops.


#### CONFIGURATION SECTION 10 & 11: 'filter NAME' & 'function Name'
Filters are written in separated files under **/etc/bird{4|6}/filters/** and **/etc/bird{4|6}/functions/**. Their syntax can be found [here.](http://bird.network.cz/?get_doc&f=bird-5.html)
The content of each filter and file file will be included in the resulting bird{4|6}.conf file without checking its syntax, so you could find errors during start time.

* Clarification for any existing **v0.2** user: an automated upgrade path has been added to switch your old "filter" or "function" sections. It is safe to upgrade, but doing regular backups of your key files is always a good practise to avoid frustration.
