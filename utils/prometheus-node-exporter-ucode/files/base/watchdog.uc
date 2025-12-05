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
		metrics[m]({ name: `${wd_path}` }, oneline(`${SC_WATCHDOG_PATH}/${wd_path}/${m}`));
}

// watchdog summary info properties
for (let wd_path in wd_paths) {
	const path = `${SC_WATCHDOG_PATH}/${wd_path}`;
	info_gauge({ 
		name:		`${wd_path}`,
		options:	`${oneline(`${path}/options`)}`,
		identity:	`${oneline(`${path}/identity`)}`,
		state:		`${oneline(`${path}/state`)}`,
		status:		`${oneline(`${path}/status`)}`,
		pretimeout_governor: `${oneline(`${path}/pretimeout_governor`)}`,
	}, 1);
}

for (let wd_path in wd_paths) {
	const pa = split(oneline(`${SC_WATCHDOG_PATH}/${wd_path}/pretimeout_available_governors`), ' ');
	for (let gov in pa) {
		if (!gov) continue;
		avail_gauge({ available: gov, device: `${wd_path}` }, 1)
	}
}
