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
