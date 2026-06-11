const mode = oneline("/sys/fs/selinux/enforce");
const enabled = gauge("node_selinux_enabled");

if (mode == null) {
	enabled(null, 0);
	return;
}

enabled(null, 1);
gauge("node_selinux_current_mode")(null, mode);
