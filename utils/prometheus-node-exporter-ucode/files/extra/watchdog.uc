// based loosely on https://github.com/prometheus/node_exporter/blob/master/collector/watchdog.go

const SC_WATCHDOG_PATH = "/sys/class/watchdog/";

const metrics = {
	bootstatus: gauge("node_watchdog_bootstatus",
		"Value of /sys/class/watchdog/<watchdog>/bootstatus"),
	fw_version: gauge("node_watchdog_fw_version",
		"Value of /sys/class/watchdog/<watchdog>/fw_version"),
	nowayout: gauge("node_watchdog_nowayout",
		"Value of /sys/class/watchdog/<watchdog>/nowayout"),
	timeleft: gauge("node_watchdog_timeleft_seconds",
		"Value of /sys/class/watchdog/<watchdog>/timeleft"),
	timeout: gauge("node_watchdog_timeout_seconds",
		"Value of /sys/class/watchdog/<watchdog>/timeout"),
	pretimeout: gauge("node_watchdog_pretimeout_seconds",
		"Value of /sys/class/watchdog/<watchdog>/pretimeout"),
	access_cs0: gauge("node_watchdog_access_cs0",
		"Value of /sys/class/watchdog/<watchdog>/access_cs0"),
};

const info_gauge = gauge("node_watchdog_info",
	"Info of /sys/class/watchdog/<watchdog>");
const avail_gauge = gauge("node_watchdog_available",
	"Info of /sys/class/watchdog/<watchdog>/pretimeout_available_governors");


const wd_paths = [];

for (let wd_path in fs.lsdir(SC_WATCHDOG_PATH, "watchdog*")) {
	push(wd_paths, wd_path);
}

// watchdog metrics
for (let m in metrics) {
	for (let wd_path in wd_paths)
		if(fs.access(`${SC_WATCHDOG_PATH}/${wd_path}/${m}`))
			metrics[m]({ name: `${wd_path}` }, oneline(`${SC_WATCHDOG_PATH}/${wd_path}/${m}`));
}

// watchdog summary info properties
for (let wd_path in wd_paths) {
	const path = `${SC_WATCHDOG_PATH}/${wd_path}`;
	const opts = oneline(`${path}/options`);
	const iden = oneline(`${path}/identity`);
	const stat = oneline(`${path}/state`);
	const stus = oneline(`${path}/status`);
	const prtg = oneline(`${path}/pretimeout_governor`);

	const labels = { name: wd_path };

	if (opts) labels.options = opts;
	if (iden) labels.identity = iden;
	if (stat) labels.state = stat;
	if (stus) labels.status = stus;
	if (prtg) labels.pretimeout_governor = prtg;

	info_gauge(labels, 1);
}

for (let wd_path in wd_paths) {
	if (!fs.access(`${SC_WATCHDOG_PATH}/${wd_path}/pretimeout_available_governors`))
		continue;

	const pa = split(oneline(`${SC_WATCHDOG_PATH}/${wd_path}/pretimeout_available_governors`), ' ');
	for (let gov in pa) {
		if (!gov) continue;
		avail_gauge({ available: gov, device: `${wd_path}` }, 1)
	}
}
