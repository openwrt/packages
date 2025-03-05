gauge("node_entropy_available_bits")
	(null, oneline("/proc/sys/kernel/random/entropy_avail"));
gauge("node_entropy_pool_size_bits")
	(null, oneline("/proc/sys/kernel/random/poolsize"));
