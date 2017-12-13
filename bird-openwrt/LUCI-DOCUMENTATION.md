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

# LUCI Bird{4|6} v0.3 Packages Documentation
*  BIRD Daemon's official documentation: http://bird.network.cz/?get_doc
*  Extra documentation in English & Catalan: https://github.com/eloicaso/bgp-bmx6-bird-docn
*  If you want to add new options to bird*-openwrt packages add a pull request or issue in: https://github.com/eloicaso/bird-openwrt

> *Clarification*: This documentation covers luci-app-bird{4|6} as both are completely aligned and only those IPv4/6-specific options will be covered separately.
>
> Bird v1.6.3 has been used to test luci-app-bird{4|6}. Using newer versions of the Daemon might change the behaviour or messages documented here. Create an issue or pull request if you spot any mismatch in this document to address it.

# Table of contents
1. [Status Page](#status)
2. [Log Page](#log)
3. [Overview Page](#overview)
4. [General Protocols Page](#general)
5. [BGP Portocol](#bgp)
6. [Filters and Functions](#fnf)


## Status Page <a name="status"></a>
The Status Page allows you to Start, Stop and restart the service as well as to check the result of these operations.

#### Components
- *Button* **Start**: Execute a Bird Daemon Service Start call. Operation's result is shown in the *Service Status* Text Box.
- *Button* **Stop**: Execute a Bird Daemon Service Stop call. Operation's result is shown in the *Service Status* Text Box.
- *Button* **Restart**: Execute a Bird Daemon Service Restart call. Operation's result is shown in the *Service Status* Text Box.
- *Text Box* **Service Status**: Executes a Bird Daemon Service Status call. Operation's result is shown as plain text.

#### Service Status common messages
* *Running*: Service is running with no issues
* *Already started*: You have clicked *Start* when the service was already running. No action taken.
* *Stopped*: You have clicked *Stop* when the service was running. Service has been stopped.
* *Already stopped*: You have clicked *Stop* when the service was already stopped. No action taken.
* *Stopped ... Started*: You have pressed *Restart* when the service was running. The service has been restarted.
* *Already stopped .. Started*: You have pressed *Restart* when the service was already stopped. The service has been started.
* *Failed - ERROR MESSAGE*: There is a configuration or validation issue that prevents Bird to start. Check the *Error Message* and the Log Page to debug it and fix it.

#### Error Examples
1. Validation issues:
  `bird4: Failed - bird: /tmp/bird4.conf, line 65: syntax error`

If we check the file shown: `/tmp/bird4.conf` :
```
protocol bgp BGPExample {
import Filter NonExistingFilter;
}
```
We have entered an invalid (non-existent in this case) filter name. In order to fix this, write the correct Filter Name or remove its reference from the BGP Protocol Configuration Page and start the service again.

2. Configuration issues:
  ` bird4: Failed - bird: /tmp/bird4.conf, line 76: Only internal neighbor can be RR client`

In this case, it is easy to spot that we have incorrectly selected the *Route Reflector Server* option incorrectly and we only need to untick it and start the service to solve it.

Usuarlly, any configuration issue will be flagged appropiately through Bird service messages. However, in the event where you do not have enough information, please look for advice in either Bird's documentation or in the affected Protocol's documentation.

## Log Page <a name="log"></a>
The Log Page shows the last 30 lines of the configured Bird Daemon Log file. This information is automatically refreshed each second.

#### Components
- *Text Area* **Log File**: 30 lines text area that shows the Log file information
- *Text* **Using Log File** and **File Size**: The first line of the Text Area is fixed and shows the file being used and its current size. **Please**, check this size information regularly to avoid letting the Log information overflow your Storage as it will make your service stop and prevent it to start until you fix it.
- *Text* **File Contents**: The next 30 lines show information about the events and debug information happening live. Main information are state changes and *info, warning, fatal or trace*. If you hit any issue starting the service, you can investigate the issue from this page.


## Overview Page <a name="overview"></a>
The Overview Page includes the configuration of basic Bird Daemon settings such as UCI usage, Routing Tables definition and Global Options.

### Bird File Settings (UCI Usage)
This section enables/disables the use of this package's capabilities.

#### Components
- *Check Box* **Use UCI configuration**:
  - If enabled, the package will use the UCI configuration generated by this web settings and translate it into a Bird Daemon configuration file.
  - If disabled, the package will do nothing and you will have to manually edit a Bird Daemon configuration file.
- *Text Box* **UCI File**: This file specifies the selected location for the translated Bird Daemon configuration file. Do not leave blank.

### Tables Configuration
This section allows you to set the Routing tables that will be used later in the different protocols. You can *Add* as many instances as required.

#### Components
- *Text Box* **Table Name**: Set an unique (meaningful) routing table name.
> In some instances or protocols, you may want or be required to set a specific ID to a Table. In order to do this, please, follow this -right now- [manual procedure](https://github.com/eloicaso/bgp-bmx6-bird-docn/blob/master/EN/manual_procedures.md).


### Global Options
This section allows you to configure basic Bird Daemon settings.

#### Components
- *Text Box* **Router ID**: Set the Identificator to be used in this Bird Daemon instance. This option must be:
> IPv4, this option will be set by default to the lowest IP Address configured. Otherwise, the identificator must be an IPv4 address.

> IPv6, this option is **mandatory** and must be a HEX value (Hexadecimal). This package (bird6-uci), provides the HEX value *0xCAFEBABE* as a default value to avoid initial crashes.

- *Text Box* **Log File**: Set the Name and Location of the Log file. By default, its location will be /tmp/bird{4|6}.log as the non-persistent partition.
- *Mutiple Value* **Log**: Set which elements you want Bird Daemon to log in the configured file.
> *Caution I*: if you select *All*, the other selected options will have no validity as, by definition, they are already included.
> *Caution II*: Take into consideration that the more elements Bird has to log, the more space you will require to store this log file. If your storage is full, Bird will fail to start until you free some space to store its Log data.

- *Multi Value* **Debug**: Set which Debug information elements you want Bird Daemon to log in the configured file.
> *Caution I*: if you select *All*, the other selected options will have no validity as, by definition, they are already included.
> *Caution II*: Take into consideration that the more elements Bird has to log, the more space you will require to store this log file (this is particularly critical in Debug as it can log MegaBytes of data quickly). If your storage is full, Bird will fail to start until you free some space to store its Log data.

## General Protocols <a name="general"></a>
The General Protocols Page includes the configuration of key OS Protocols or Network Basic Settings such as Kernel, Device or Static Routes.

### Kernel Options
This section allows you to set all the Kernel Protocols required to do Networking.
> The first Kernel instance is the Primary one and must be left by default for OS usage. Do not set its "Table" or "Kernel Table" options.

#### Components
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *List Value* **Table**: Select the Routing Table to be used in the Kernel Protocol instance.
> The Primary Kernel Protocol cannot be empty.

- *Text Box* **Import**: Set if the protocol must import routes and which ones.
  - **all**: Accept all the incoming routes.
  - **none**: Reject all the incoming routes.
  - **filter filterName**: Call an existing filter to define which incoming routes will be accepted or rejected.
- *Text Box* **Export**: Set if the protocol must export routes and which ones.
  - **all**: Accept all the outgoing routes.
  - **none**: Reject all the outgoing routes.
  - **filter filterName**: Call an existing filter to define which outgoing routes will be accepted or rejected.
- *Text Box* **Scan time**: Set the time between Kernel Routing Table scans. This value must be the same for all the Kernel Protocols.
- *Check Box* **Learn**: Set this option to allow the Kernel Protocol to learn Routes form other routing daemons or manually added by an admin.
- *Check Box* **Persist**: Set this option to store the routes learnt in the table until it is removed. Unset this option if you want to clean the routes on the fly.
- *Text Box* **Kernel Table**: Select the specific exitisting Routing Table for this Protocol instance.
> The Kernel Table ID must be previously set by the administrator during the Routing Table configuration. Currently (v0.3), this process is done manually. Please, follow this [manual procedure](https://github.com/eloicaso/bgp-bmx6-bird-docn/blob/master/EN/manual_procedures.md).

### Device Options
This section allows you to set all the Device *Protocol*. The Device *Protocol* is just a mechanism to bound the interfaces and Kernel tables in order to get its information.

#### Components
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *Text Box* **Scan Time**: Set the time between Kernel Routing Table scans. This value must be the same for all the Kernel Protocols.

### Static Options
This section allows you to create the container for Routes definition. Static protocol instances allows you to manually create Routes that Bird will use and which Routing Table should hold this information. It also helps to manage routes by marking them (i.e. *Unreachable*, *Blocked*, ...).

#### Components
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *List Value* **Table**: Select the Routing Table to be used in the Static Protocol instance.

### Routes
This section allows to set which Routes will be set in a specific Static Protocol and how these should be handled.

#### Components
- *List Value* **Route Instance**: Set which Static Protocol instance will contain this route infromation.
> Routes require an existing Static Protocol as parent.

- *Text Box* **Route Prefix**: Set the Route instance to be defined.
> Examples of routes are:. 10.0.0.0/8 (IPv4) or 2001:DB8:3000:0/16 (IPv6)

- *List Value* **Type Of Route**: This value will set the conditional settings. Options are:
  - **Router**: Classic routes going through specific IP Addresses. 
    - *Text Box* **Via**: Set the target IP Address to be used for Routing
    > I.e. 10.0.0.0/8 via 10.1.1.1

  - **MultiPath**: Multiple paths Route.
    - *List of Text Box* **Via**: Set the target Route to be used for Routing. This option allows several instances of **Via** elements.
    > I.e. 10.0.0.0/8 via 10.1.1.1
    >            via 10.1.1.100
    >            via 10.1.1.200

  - **Special**: Special treated Route.
    - *Text Box* **Attribute**: Block special consideration of routes.
    > **unreachable**: Return route cannot be reached.
    > **prohibit**: Return route has been administratively blocked.
    > **blackhole**: Silently drop the route.

  - **Iface**: Classic routes going through specific interfaces.
    - *List Value* **Interface**: Select the target interface to route.

  - **Recursive**: Set a static recursive route. Its next hope will depen on the table's lookup for each target IP Address.

### Direct Protocol
This section allows to set pools of *directly* connected interfaces. Direct Protocol instances will make use of the *Device* Protocol in order to generate routes between the selected interfaces.

#### Components
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *Text Box* **Interfaces**: This is the key option allowing to *tie* the interfaces and create direct routes between different sides. Enter each interface's name you want to couple.
  - If you leave this option empty, it will tie all the interfaces together.
  - Each interface must be quoted: i.e. `"eth0"`
  - Several interfaces must be entered comma-separated: i.e. `"eth0", "wlan0"`
  - If you want to restrict this to specific interfaces, you have to enter them using its name or a pattern: i.e. All the ethernet interfaces `"eth*"`
  - You are allowed to **exclude** specific interfaces by adding `-` before the interface name: i.e. Exclude all the Wireless interfaces `"-wlan*"`
  > Example: All the wired interfaces (eth and em) but exclude all the wireless and point-to-point interfaces: `"eth*", "em*", "-wlan*", "-ptp_*"`

> Current version 0.3 requires you to enter each interface you want to **include** or **exclude** manually. This will be enhanced in future versions.

### Pipe Protocol
This section allows to set instances of *linked* routing tables. Each instance will allow you to share the routes from a primary table to a secondary one.

#### Components
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *List Value* **Table**: Select the **Primary** Routing Table to be used.
- *List Value* **Peer Table**: Select the **Secondary** Routing Table to be used.
- *List Value* **Mode**: Set if you want to work in *transparent* or *opaque* mode.
  - **Transparent**: Retransmits all the routes and its attributes. Therefore, you get two identical routing tables. This is the default behaviour.
  - **Opaque**: This mode is not recommended for new configurations and it is not recommended. Tables will only share the optimal routes and overwrite route's attributes with new ones (Pipe).
- *Text Box* **Import**: Set if the protocol must import routes and which ones.
  - **all**: Accept all the incoming routes.
  - **none**: Reject all the incoming routes.
  - **filter filterName**: Call an existing filter to define which incoming routes will be accepted or rejected.
- *Text Box* **Export**: Set if the protocol must export routes and which ones.
  - **all**: Accept all the outgoing routes.
  - **none**: Reject all the outgoing routes.
  - **filter filterName**: Call an existing filter to define which outgoing routes will be accepted or rejected.


## BGP Protocol<a name="bgp"></a>
The BGP Protocol Page includes all the settings to configure BGP Templates and BGP instances.
BGP Templates and Instances share most of the options as Templates are meant to diminish the requirements on Instances.
> An extreme example case could be the Template holding all the options and the Instance only referencing to the Template as the only option..

### BGP Templates
This section allows you to set BGP Templates, which are commonly used BGP configuration*themes* to reduce the number of repeated settings while adding BGP Instances.

### BGP Instances
This section allows you to set BGP Instances. The Instances are the ones starting the BGP Protocol and can, or not, use a BGP Template to re-use the common properties.
> **Caution**: Any duplicated option between an Instance and a Template will resolve by using the Instance option and dismissing the Template one. **Instance** > *Template*.

#### BGP Instance Specific Option
- *List Value* **Templates**: Set the BGP Template that will feed the instance. Any option in the Template will be inherited.

#### Common Options
- *Check Box* **Disabled**: Set this Check Box if you do not want to configure and use this Protocol.
- *Text Area* **Description**: Set a descriptive text to identify this protocol and what it does.
- *Text Box* **Import**: Set if the protocol must import routes and which ones.
  - **all**: Accept all the incoming routes.
  - **none**: Reject all the incoming routes.
  - **filter filterName**: Call an existing filter to define which incoming routes will be accepted or rejected.
- *Text Box* **Export**: Set if the protocol must export routes and which ones.
  - **all**: Accept all the outgoing routes.
  - **none**: Reject all the outgoing routes.
  - **filter filterName**: Call an existing filter to define which outgoing routes will be accepted or rejected.
- *List Value* **Table**: Select the Routing Table to be used.
- *List Value* **IGP Table**: Set the IGP Routing Table (Internal BGP). Bird uses the same Routing Table for both External BGP and Internal BGP by default.
- *Text Area* **Source Address**: Set the local IP Address. By default the Router ID will be used.
- *Text Area* **Local AS**: Set the local BGP Autonomous System ID.
- *Text Area* **Local BGP Address**: Set the local BGP Autonomous System IP Address.
- *Text Area* **Neighbor IP Address**: Set BGP neighbour's IP Address.
- *Text Area* **Neighbor AS**: Set BGP neighbour's Autonomous System ID.
- *Check Box* **Next Hop Self**: Overwrite Next Hop cost attributes with its own source address as next hop. Disabled by default as it is only used in some specific instances.
- *Check Box* **Next Hop Keep**: Forward the same Next Hop information even in situations where the system would use its own source address instead. Disabled by default.
- *Check Box* **Route Reflector Server**: Set if BGP instance must act as a Route Reflector Server and expect neighbours AS to act as clients
- *Text Value* **Route Reflector Cluster ID**: Route Reflector service ID to avoid loops. This options is only allowed in the Server (not clients) and it is Router's ID by default.
- *Text Box* **Routes Import Limit**: Set the maximum number of routes the protocol will import.
- *List Value* **Routes Import Limit Action**: Set the action to apply if the *Routes Import Limit* is exceeded. Options are:
  - **block**: Block any route exceeding the limit.
  - **disable**: Stop the protocol.
  - **warn**: Print Log warnings.
  - **restart**: Restart the protocol.
- *Text Box* **Routes Export Limit**: Set the maximum number of routes the protocol will export.
- *List Value* **Routes Export Limit Action**: Set the action to apply if the *Routes Export Limit* is exceeded. Options are:
  - **block**: Block any route exceeding the limit.
  - **disable**: Stop BGP protocol.
  - **warn**: Print Log warnings.
  - **restart**: Restart BGP protocol.
- *Text Box* **Routes Received Limit**: Set the maximum number of shared routes the Protocol must accept and remember (the **number** of imported routes is not affected by this option).
- *List Value* **Routes Received Limit Action**: Set the action to apply if the *Routes Received Limit* is exceeded. Options are:
  - **block**: Block any route exceeding the limit.
  - **disable**: Stop BGP protocol.
  - **warn**: Print Log warnings.
  - **restart**: Restart BGP protocol.


## Filters and Functions<a name="fnf"></a>
The Filters and the Functions Page allows you to edit Bird Daemon Filter and Functions files without requiring you to go to command line.  Both Pages share the same code base and the only main change is where they are getting the files from. Therefore, and for documentation simplicity sake, both pages will be covered in this section.
> From version 0.3 onwards:
> The default and supported place to store filter files is under `/etc/bird{4|6}/filters`. 
> The default and supported place to store function files is under `/etc/bird{4|6}/functions`. 

> Current version 0.3 does not allow changing file names. You will have to change the default filenames through SSH. This will be enhanced in future versions.

#### Components
- *List Value* **Filter Files** / **Function Files**: Set the Filter or Function file to edit from the ones under `/etc/bird{4|6}/filters` / `/etc/bird{4|6}/functions`.
> If you want to create a new Filter or Function file, use the **New File** element in the list.

> The default behaviour is to allow administrators to create new files using this scheme:
> */etc/bird{4|6}/filters/filter*-**TIMESTAMP**. *Timestamp* is: YYYYMMDD-HHMM. I.e. */etc/bird4/filters/filter-20170705-2030*
> */etc/bird{4|6}/functions/function*-**TIMESTAMP**. *Timestamp* is: YYYYMMDD-HHMM. I.e. */etc/bird4/functions/function-20170705-2030*

- *Button* **Load File**: Click this button to Load the file selected in the *{filter|function} Files* list. This button **must** be pressed in order to edit the target file.
- *Read Only Text Box* **Editing File**: This Read-Only field is empty by default. It will get populated with the target file to edit. 
> **Caution**: Only if this field shows a file path, the contents of the target file can be edited and saved. 

- *Text Area* **File Contents**: This text area will show the contents of the file shown in the *Editting File*. Save the contents of this text area by pressing the Button **Submit**
> Use **spaces** instead of **tabs** for indentation.

> **Caveat**: If you save your filter or function using the *New File* option, until you refresh the page, the **saved** file will still appear as *New File*. However, the file will be created and correctly stored and you will be able to edit it with no problems.
> After refreshing the page, your file will appear normally together with a new *New File* option.
> This behaviour will be enhanced in future versions.

#### Common Errors
Most common errors produced by Filters and Functions are:

- Syntax errors: `bird: /etc/bird4/filters/filter-20170507-0951, line 4: syntax error` 
> This instances require you to check where your errors is following Bird's hints.

- Non-existing filter: `bird: /tmp/bird4.conf, line 71: No such filter.`
> Check your Filter name or define it in the **Filters Page**

- Calls to functions not defined in the Functions files or not part of the Bird filter/function definition *language*: `, line 4: You can't call something which is not a function. Really.`
> Check you Function definition, your call name or Bird's official documentation to get the right reference.

#### Critical Errors
There are some critical errors that could escape from first sight as Bird Daemon will start working *correctly*.

If you set your Filter **without** *accept* or *reject* calls, your filter will fail to work and let all the routes pass by as accepted. This will be shown in the **Log Page**:

Example: **Filter "doNothing"**
```
filter doNothing
{
    print "HelloWorld";
}
```
This *wrong* filter has been used in our BGP instance and Bird Daemon runs correctly. However, if we check the **Log Page** we find:
```
2017-05-07 10:18:49 <ERR> Filter doNothing did not return accept nor reject. Make up your mind
2017-05-07 10:18:49 <INFO> HelloWorld
```
> Do not leave any filter without *accept* or *reject* calls to avoid this wrong behaviour that will incurr in a waste of resources.