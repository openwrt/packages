gauge("node_entropy_available_bits", "Bits of available entropy.")
	(null, oneline("/proc/sys/kernel/random/entropy_avail"));
gauge("node_entropy_pool_size_bits", "Bits of entropy pool.")
	(null, oneline("/proc/sys/kernel/random/poolsize"));
