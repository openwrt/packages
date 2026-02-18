const f = fs.open("/proc/net/dev");

if (!f)
	return false;

const metrics = [
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

// Per-counter results array
/* results[i] = { dev1: value, dev2: value, ... } */
let results = [];
for (let i = 0; i < length(metrics); i++)
	results[i] = {};

// Parse file first
let line;
for (let k = 0; line = nextline(f); k++) {
	if (k < 2)
		continue; // skip the header lines
	const x = wsplit(ltrim(line), " ");

	const dev = substr(x[0], 0, -1);

	for (let i = 1; i < length(x); i++) {
		results[i][dev] = x[i];
	}
}

// Build label objects
let label_cache = {};
for (let i = 1; i < length(results); i++) {
	for (let dev in results[i]) {
		if (!(dev in label_cache))
			label_cache[dev] = { device: dev };
	}
}

// Emit metrics grouped by counter
for (let i = 1; i < length(metrics); i++) {
	const metric = metrics[i];
	if (!metric)
		continue;

	for (let dev in results[i]) {
		metric(label_cache[dev], results[i][dev]);
	}
}

return true;
