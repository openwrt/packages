
// modelled after: https://github.com/prometheus/node_exporter/blob/master/collector/thermal_zone_linux.go
// See also: https://docs.kernel.org/driver-api/thermal/sysfs-api.html

// thermal collector
const thermal_devs = [];

for (let idx = 0; ; idx++) {
	const devPath = `/sys/class/thermal/thermal_zone${idx}`;
	const typ = oneline(devPath + "/type");
	if (!typ) break;

	const policy = oneline(devPath + "/policy");
	if (!policy) break;

	const temp = oneline(devPath + "/temp");
	if (!temp) break;

	push(thermal_devs, {
		idx,
		typ,
		policy,
		temp,
		mode: oneline(devPath + "/mode"),
		passive: oneline(devPath + "/passive"),
	});
}

if (length(thermal_devs) > 0) {	
	const temp_metric = gauge("node_thermal_zone_temp", "Zone temperature in Celsius");

	for (let d in thermal_devs) {
		const labels = { zone: `${d.idx}`, type: d.typ, policy: d.policy };
		if (d.mode) labels.mode = d.mode;
		if (d.passive) labels.passive = d.passive;

		temp_metric(labels, d.temp / 1000.00);
	}
}

// cooling collector
const cooling_devs = [];

for (let idx = 0; ; idx++) {
	const devPath = `/sys/class/thermal/cooling_device${idx}`;
	const typ = oneline(devPath + "/type");
	if (!typ) break;

	push(cooling_devs, {
		idx,
		typ,
		cur: oneline(devPath + "/cur_state"),
		max: oneline(devPath + "/max_state"),
	});
}

if (length(cooling_devs) > 0) {	

	const cur_throttle = gauge("node_cooling_device_cur_state", "Current throttle state of the cooling device");

	for (let d in cooling_devs) {
		const labels = { name: `${d.idx}`, type: d.typ };

		cur_throttle(labels, d.cur);
	}

	const max_throttle = gauge("node_cooling_device_max_state", "Maximum throttle state of the cooling device");

	for (let d in cooling_devs) {
		const labels = { name: `${d.idx}`, type: d.typ };

		max_throttle(labels, d.max);
	}
}
