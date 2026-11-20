
const x = ubus.call("service", "list", {verbose: true});
if (!x)
	return false;

let m_running = gauge("procd_service_running", "procd service is running");
let m_pid = gauge("procd_service_pid", "procd service pid");
let m_exit_code = gauge("procd_service_exit_code", "procd stopped service exit code");
let m_incarnation = gauge("procd_service_incarnation", "procd service incarnation, changes on every (re)start");
let m_jail = gauge("procd_service_jail", "procd service runs in a jail");

for (let service, srv_data in x) {
	for (let instance, state in srv_data.instances) {
		let labels = {
			service,
			// "instance" is a target label, the scraper would rename ours
			service_instance: instance,
		};

		m_running(labels, state.running ? 1 : 0);
		m_jail(labels, state.jail != null ? 1 : 0);

		// only present while the instance is running
		if (state.pid != null)
			m_pid(labels, state.pid);

		// only present once the instance has stopped
		if (state.exit_code != null)
			m_exit_code(labels, state.exit_code);

		// not reported by older procd
		if (state.incarnation != null)
			m_incarnation(labels, state.incarnation);
	}
}
