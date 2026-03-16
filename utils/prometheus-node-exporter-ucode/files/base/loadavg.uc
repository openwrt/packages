const x = wsplit(oneline("/proc/loadavg"));

if (length(x) < 3)
	return false;

gauge("node_load1")(null, x[0]);
gauge("node_load5")(null, x[1]);
gauge("node_load15")(null, x[2]);
