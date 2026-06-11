let f = fs.open("/proc/net/dev");

if (!f)
	return false;

const m = [
	null,
	counter("node_network_receive_bytes_total"),
	counter("node_network_receive_packets_total"),
	counter("node_network_receive_errs_total"),
	counter("node_network_receive_drop_total"),
	counter("node_network_receive_fifo_total"),
	counter("node_network_receive_frame_total"),
	counter("node_network_receive_compressed_total"),
	counter("node_network_receive_multicast_total"),
	counter("node_network_transmit_bytes_total"),
	counter("node_network_transmit_packets_total"),
	counter("node_network_transmit_errs_total"),
	counter("node_network_transmit_drop_total"),
	counter("node_network_transmit_fifo_total"),
	counter("node_network_transmit_colls_total"),
	counter("node_network_transmit_carrier_total"),
	counter("node_network_transmit_compressed_total"),
];

let line;
while (line = nextline(f)) {
	const x = wsplit(ltrim(line), " ");

	if (length(x) < 2)
		continue;

	if (substr(x[0], -1) != ":")
		continue;

	const count = min(length(x), length(m));
	const labels = { device: substr(x[0], 0, -1) };
	for (let i = 1; i < count; i++)
		m[i](labels, x[i]);
}
