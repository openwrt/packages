
const x = ubus.call("service", "list", {verbose: true});
if (!x)
	return false;

let m_running = gauge("procd_service_running", "procd service is running");
let m_pid = gauge("procd_service_pid", "procd service pid");
let m_exit_code = gauge("procd_service_exit_code", "procd stopped service exit code");
// NOTE: possible extra metrics: is jailed, amount of triggers

for (let service, srv_data in x) {
	for (let instance, state in srv_data.instances) {
		let labels = {
			procd_service: service,
			procd_instance: instance,
		};

		m_running(labels, (state.running) ? 1 : 0);
		m_pid(labels, state.pid);
		if (state?.exit_code !== null) {
			m_exit_code(labels, state.exit_code);
		}
	}
}
