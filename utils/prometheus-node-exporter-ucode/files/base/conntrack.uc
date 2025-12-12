gauge("node_nf_conntrack_entries")
	(null, oneline("/proc/sys/net/netfilter/nf_conntrack_count"));
gauge("node_nf_conntrack_entries_limit")
	(null, oneline("/proc/sys/net/netfilter/nf_conntrack_max"));
