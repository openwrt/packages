# Which packages to install

Install `openvswitch` if you need OpenFlow virtual switch function.  It
contains ovs-vswitchd, ovsdb-server and helper utilities such as ovs-vsctl,
ovs-ofctl, ovs-ctl etc.

Linux kernel datapath module openvswitch.ko will also be installed along with
package `openvswitch`.  Tunnel encap support for gre, geneve, vxlan can be
included by installing `kmod-openvswitch-{gre,geneve,vxlan}` respectively

For OVN deployment

- Install `openvswitch-ovn-north` for ovs-northd, ovsdb-server, ovn helper utitlies
- Install `openvswitch-ovn-host` for ovn-controller and `openvswitch`

# Open vSwitch in-tree Linux datapath modules

The Open vSwitch build system uses regexp and conditional-compilation
heuristics to support building the shipped kernel module source code against a
wide range of kernels, as of openvswitch-2.10, the list is supposed to include
vanilla linux 3.10 to 4.15, plus a few distro kernels.

It may NOT work

 - Sometimes the code does not compile
 - Sometimes the code compiles but insmod will fail
 - Sometimes modules are loaded okay but actually does not function right

For these reasons, the in-tree datapath modules are NOT visible/enabled by
default.

Building and using in-tree datapath modules requires some level of devel
abilities to proceed.  You are expected to configure build options and build
the code on your own

E.g. pair openvswitch userspace with in-tree datapath module

	CONFIG_DEVEL=y
	CONFIG_PACKAGE_openvswitch=y
	# CONFIG_PACKAGE_kmod-openvswitch is not set
	CONFIG_PACKAGE_kmod-openvswitch-intree=y

E.g. replace in-tree datapath module with upstream version

	opkg remove --force-depends kmod-openvswitch-intree
	opkg install kmod-openvswitch
	ovs-ctl force-reload-kmod

# UCI configuration options

There are 6 config section types in package openvswitch:
ovsdb, vswitchd, northd, controller, ovs_bridge & ovs_port.

The deprecated section types are ovs, ovn_northd & ovn_controller.
ovs was updated to ovsdb and vswitchd;
ovn_northd was updated to ovsdb and northd;
ovn_controller was updated controller.

The following configurations are common to all sections.

| Name         | Type    | Required | Default | Description                             |
|--------------|---------|----------|---------|-----------------------------------------|
| disabled     | boolean | no       | 0       | If set to 1, do not configure           |
| ssl          | boolean | no       | 0       | If set to 1, do configure SSL           |
| ca           | string  | no       | *       | ssl CA certificate                      |
| sslbootstrap | string  | no       | *       | create CA, if ca does not exist         |
| cert         | string  | no       | *       | ssl certificate                         |
| key          | string  | no       | *       | ssl private key                         |
| sslprotocols | string  | no       | *       | list of SSL protocols to enable         |
| sslciphers   | string  | no       | *       | list of SSL ciphers to enable           |
| loglevel     | string  | no       | warn    | set logging levels                      |
| logfilelevel | string  | no       | off     | set logging levels for output to a file |
| logfile      | string  | no       | *       | logging to specified FILE               |
| pidfile **   | string  | no       | *       | create pidfile                          |

\* *Different sections have different default values, which are listed below*

\*\* *Only the section with daemon process has this configuration item*

| section | ca | sslbootstrap | cert | key | sslprotocols | sslciphers | logfile | pidfile |
|---|---|---|---|---|---|---|---|---|
| ovsdb | * | * | * | * | * | * | * | * |
| vswitchd | (none) | 0 | (none) | (none) | (none) | (none) | /var/log/openvswitch/${instance//_/-}.log ** | /var/run/openvswitch/${instance//_/-}.pid ** |
| northd | (none) | 0 | (none) | (none) | (none) | (none) | /var/log/ovn/${instance//_/-}.log ** | /var/run/ovn/${instance//_/-}.pid ** |
| controller | (none) | 0 | (none) | (none) | (none) | (none) | /var/log/ovn/${instance//_/-}.log ** | /var/run/ovn/${instance//_/-}.pid ** |
| ovs_bridge | (none) | 0 | (none) | (none) | (none) | (none) | /var/log/openvswitch/${name//_/-}.log *** | - |
| ovs_port | (none) | 0 | (none) | (none) | (none) | (none) | /var/log/openvswitch/${port//_/-}.log **** | - |

\* *View the default configuration of ovsdb*

\*\* *instance is Inherits UCI config block name*

\*\*\* *name is the name configuration item of ovs_bridge section*

\*\*\*\* *port is the port configuration item of ovs_port section*

The ovsdb section also supports the options below, to configure a set of
ovsdb daemon.

| Name     | Type   | Required | Default | Description                                    |
|----------|--------|----------|---------|------------------------------------------------|
| dbfile   | string | no       | *       | a database file in ovsdb format                |
| role     | string | no       | ovs     | Affects the default value of ovsdb, available options are 'ovs', 'ovnnb' & 'ovnsb' |
| dbschema | string | no       | *       | The schema used to create or update the dbfile |
| remote   | list   | no       | *       | connect or listen to REMOTE                    |
| unixctl  | string | no       | *       | override default control socket name           |

\* *Different sections have different default values, which are listed below*

| role | dbfile | dbschema | remote | unixctl | ca | sslbootstrap | cert | key | sslprotocols | sslciphers | logfile | pidfile |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ovs | /etc/openvswitch/conf.db | /usr/share/openvswitch/vswitch.ovsschema | ["punix:/var/run/openvswitch/db.sock"] | /var/run/openvswitch/${instance//_/-}.ctl * | db:Open_vSwitch,SSL,ca_cert | 1 | db:Open_vSwitch,SSL,certificate | db:Open_vSwitch,SSL,private_key | (none) | (none) | /var/log/openvswitch/${instance//_/-}.log * | /var/run/openvswitch/${instance//_/-}.pid * |
| ovnnb | /etc/ovn/${instance}.db * | /usr/share/ovn/ovn-nb.ovsschema | ["punix:/var/run/ovn/$instance.sock", "db:OVN_Northbound,NB_Global,connections"] * | /var/run/ovn/${instance}.ctl * | (none) | 0 | db:OVN_Northbound,SSL,certificate | db:OVN_Northbound,SSL,private_key | db:OVN_Northbound,SSL,ssl_protocols | db:OVN_Northbound,SSL,ssl_ciphers | /var/log/ovn/${instance}.log * | /var/run/ovn/${instance}.pid * |
| ovnsb | /etc/ovn/${instance}.db * | /usr/share/ovn/ovn-sb.ovsschema | ["punix:/var/run/ovn/$instance.sock", "db:OVN_Southbound,SB_Global,connections"] * | /var/run/ovn/${instance}.ctl * | (none) | 0 | db:OVN_Southbound,SSL,certificate | db:OVN_Southbound,SSL,private_key | db:OVN_Southbound,SSL,ssl_protocols | db:OVN_Southbound,SSL,ssl_ciphers | /var/log/ovn/${instance}.log * | /var/run/ovn/${instance}.pid * |

\* *instance is Inherits UCI config block name*

The vswitchd section also supports the options below, to configure a set of
vswitchd daemon.

| Name          | Type   | Required | Default     | Description                             |
|---------------|--------|----------|-------------|-----------------------------------------|
| ovsdb         | string | no       | unix:/var/run/openvswitch/db.sock | is a socket on which ovsdb is listening |
| hostname      | string | no       | $(uname -n) | hostname                                |
| systemtype    | string | no       | openwrt     | set system type                         |
| systemversion | string | no       | *           | set system version                      |
| systemid      | string | no       | random **   | set specific ID to uniquely identify this system |

\* *Will use $(ubus call system board) to read the release version number of openwrt*

\*\* *The random configuration checks whether the file*
*/etc/openvswitch/system-id.conf exists, and if it exists,*
*reads the value from the file, otherwise randomly generates*
*a UUID value and outputs the value to /etc/openvswitch/system-id.conf*

The northd section also supports the options below, to configure a set of
northd daemon.

| Name    | Type   | Required | Default     | Description                             |
|---------|--------|----------|-------------|-----------------------------------------|
| ovnnbdb | string | no       | unix:/var/run/ovn/ovnnb_db.sock | connect to ovn-nb database |
| ovnsbdb | string | no       | unix:/var/run/ovn/ovnsb_db.sock | connect to ovn-sb database |

The controller section also supports the options below, to configure a set of
controller daemon.

| Name   | Type   | Required | Default     | Description                             |
|--------|--------|----------|-------------|-----------------------------------------|
| ovsdb  | string | no       | unix:/var/run/openvswitch/db.sock | is a socket on which ovsdb is listening |
| remote | string | no       | unix:/var/run/ovn/ovnsb_db.sock | connect to ovn-sb database |
| bridge | string | no | (none) | The integration bridge to which logical ports are attached |
| encap_type | string | no | (none) | The encapsulation type that a chassis should use to connect to this node |
| encap_ip | string | no | (none) | The IP address that a chassis should use to connect to this node using encapsulation types specified by encap_type |

The ovs_bridge section also supports the options below,
for initialising a virtual bridge with an OpenFlow controller.

| Name               | Type    | Required | Default                        | Description                                                |
|--------------------|---------|----------|--------------------------------|------------------------------------------------------------|
| name               | string  | no       | br-$instance * | The name of the switch in the OVS daemon                   |
| ovsdb              | string  | no       | unix:/var/run/openvswitch/db.sock | is a socket on which ovsdb is listening |
| controller         | string  | no       | (none)                         | The endpoint of an OpenFlow controller for this bridge     |
| datapath_id        | string  | no       | (none)                         | The OpenFlow datapath ID for this bridge                   |
| datapath_desc      | string  | no       | (none)                         | The OpenFlow datapath description for this bridge          |
| drop_unknown_ports | boolean | no       | 0                              | Remove ports not defined in UCI from the bridge            |
| fail_mode          | string  | no       | standalone                     | The bridge failure mode                                    |
| ports              | list    | no       | (none)                         | List of ports to add to the bridge                         |

\* *instance is Inherits UCI config block name*

The ovs_port section can be used to add ports to a bridge. It supports the options below.

| Name     | Type    | Required | Default | Description
| ---------|---------|----------|---------|------------------------------------------------|
| ovsdb    | string  | no       | unix:/var/run/openvswitch/db.sock | is a socket on which ovsdb is listening |
| bridge   | string  | yes      | (none)  | Name of the bridge to add the port to          |
| port     | string  | no       | $bridge-$instance * | Name of the port to add to the bridge |
| ofport   | integer | no       | (none)  | OpenFlow port number to be used by the port    |
| tag      | integer | no       | (none)  | 802.1Q VLAN tag to set on the port             |
| type     | string  | no       | (none)  | Port type, e.g. internal, erspan, type, ...    |

\* *bridge is the value of the bridge configuration item, instance is Inherits UCI config block name*
