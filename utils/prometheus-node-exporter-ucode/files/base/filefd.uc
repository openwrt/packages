const x = wsplit(oneline("/proc/sys/fs/file-nr"));

if (length(x) < 3)
	return false;

gauge("node_filefd_allocated")(null, x[0]);
gauge("node_filefd_maximum")(null, x[2]);
