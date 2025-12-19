const root = "/sys/class/net/";
const devices = fs.lsdir(root);
const dev_length = length(devices);

if (dev_length < 1)
	return false;

const m_info = gauge("node_network_info");
const m_speed = gauge("node_network_speed_bytes");
const metrics = {
	addr_assign_type:	gauge("node_network_address_assign_type"),
	carrier:		gauge("node_network_carrier"),
	carrier_changes:	counter("node_network_carrier_changes_total"),
	carrier_down_count:	counter("node_network_carrier_down_changes_total"),
	carrier_up_count:	counter("node_network_carrier_up_changes_total"),
	dev_id:			gauge("node_network_device_id"),
	dormant:		gauge("node_network_dormant"),
	flags:			gauge("node_network_flags"),
	ifindex:		gauge("node_network_iface_id"),
	iflink:			gauge("node_network_iface_link"),
	link_mode:		gauge("node_network_iface_link_mode"),
	mtu:			gauge("node_network_mtu_bytes"),
	name_assign_type:	gauge("node_network_name_assign_type"),
	netdev_group:		gauge("node_network_net_dev_group"),
	type:			gauge("node_network_protocol_type"),
	tx_queue_len:		gauge("node_network_transmit_queue_length"),
};

for (let i = 0; i < dev_length; i++) {
	const devroot = root + devices[i] + "/";

	m_info({
		device: devices[i],
		address:	oneline(devroot + "address"),
		broadcast:	oneline(devroot + "broadcast"),
		duplex:		oneline(devroot + "duplex"),
		operstate:	oneline(devroot + "operstate"),
		ifalias:	oneline(devroot + "ifalias"),
	}, 1);
}

for (let m in metrics) {
	for (let i = 0; i < dev_length; i++) {
		metrics[m]({ device: devices[i] }, oneline(root + devices[i] + "/" + m));
	}
}

for (let i = 0; i < dev_length; i++) {
	const speed = int(oneline(root + devices[i] + "/" + "speed"));
	if (speed > 0)
			m_speed({ device: devices[i] }, speed * 1000 * 1000 / 8);
}
