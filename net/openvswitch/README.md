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

# How to use them

Open vSwitch provides a few very useful helper script in
`/usr/share/openvswitch/scripts/`.  A simple initscript is provided.  It's
mainly a wrapper around `ovs-ctl` and `ovn-ctl` with simple knobs from
`/etc/config/openvswitch`.  Procd is not used here.

	/etc/init.d/openvswitch start
	/etc/init.d/openvswitch stop
	/etc/init.d/openvswitch stop north
	/etc/init.d/openvswitch restart ovs
	/etc/init.d/openvswitch status

Use `ovs-ctl` and `ovn-ctl` directly for more functionalities

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

There are 4 config section types in package openvswitch:
ovs ovn_northd, ovn_controller & ovs_bridge.

Each of these supports a disabled option, which should be 
set to 0 to launch the respective daemons.

The ovs_bridge section also supports the options below,
for initialising a virtual bridge with an OpenFlow controller.

| Name       | Type    | Required | Default                        | Description                                                |
|------------|---------|----------|--------------------------------|------------------------------------------------------------|
| disabled   | boolean | no       | 0                              | If set to true, disable initialisation of the named bridge |
| name       | string  | no       | Inherits UCI config block name | The name of the switch in the OVS daemon                   |
| controller | string  | no       | (none)                         | The endpoint of an OpenFlow controller for this bridge     |
