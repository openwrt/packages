'use strict';

// Self-contained regression test for the procd collector.
// Mocks ubus + gauge, loads files/extra/procd.uc and asserts the emitted
// metrics for running, stopped, jailed and instance-less services.

let failures = 0;

function fail(msg) {
	warn("FAIL: ", msg, "\n");
	failures++;
}

function check(cond, msg) {
	if (!cond)
		fail(msg);
}

let services = {
	// running, new procd (incarnation), jailed
	dnsmasq: {
		instances: {
			cfg01411c: {
				running: true,
				pid: 2345,
				incarnation: 17,
				term_timeout: 5,
				jail: { name: "dnsmasq", procfs: false, sysfs: false },
			},
		},
	},
	// stopped: no pid, has exit_code; old procd: no incarnation
	crashy: {
		instances: {
			instance1: {
				running: false,
				term_timeout: 5,
				exit_code: 1,
			},
		},
	},
	// two instances, one clean exit (exit_code 0 must still be emitted)
	multi: {
		instances: {
			a: { running: true, pid: 100 },
			b: { running: false, exit_code: 0 },
		},
	},
	// service without instances
	firewall: {},
};

let emitted = [];

const gauge = function(name, help) {
	return function(labels, value) {
		if (value == null)
			fail(`${name} emitted with a null value`);
		push(emitted, { name, labels, value });
	};
};

function load(ubus) {
	let func = loadfile("./files/extra/procd.uc", { strict_declarations: true, raw_mode: true });
	if (!func) {
		warn("failed to load procd.uc\n");
		exit(1);
	}

	emitted = [];
	return call(func, null, { ubus, gauge });
}

function find(name, service, instance) {
	for (let e in emitted)
		if (e.name == name && e.labels.service == service && e.labels.service_instance == instance)
			return e;
	return null;
}

function value(name, service, instance) {
	return find(name, service, instance)?.value;
}

let request = null;
let rv = load({
	call: function(object, method, args) {
		request = { object, method, args };
		return services;
	},
});

check(rv != false, "collector returned false");
check(request?.object == "service" && request?.method == "list", "calls service list");
check(request?.args?.verbose == true, "requests verbose output");

// running + jailed + incarnation
check(value("procd_service_running", "dnsmasq", "cfg01411c") == 1, "dnsmasq running");
check(value("procd_service_pid", "dnsmasq", "cfg01411c") == 2345, "dnsmasq pid");
check(value("procd_service_jail", "dnsmasq", "cfg01411c") == 1, "dnsmasq jailed");
check(value("procd_service_incarnation", "dnsmasq", "cfg01411c") == 17, "dnsmasq incarnation");
check(find("procd_service_exit_code", "dnsmasq", "cfg01411c") == null, "no exit code while running");

// stopped: no pid sample at all
check(value("procd_service_running", "crashy", "instance1") == 0, "crashy not running");
check(find("procd_service_pid", "crashy", "instance1") == null, "no pid when stopped");
check(value("procd_service_exit_code", "crashy", "instance1") == 1, "crashy exit code");
check(value("procd_service_jail", "crashy", "instance1") == 0, "crashy not jailed");
check(find("procd_service_incarnation", "crashy", "instance1") == null, "no incarnation on old procd");

// multiple instances, exit code 0 is still reported
check(value("procd_service_pid", "multi", "a") == 100, "multi/a pid");
check(value("procd_service_exit_code", "multi", "b") === 0, "multi/b exit code 0");

// labels carry no procd_ prefix and do not collide with the scraper's "instance"
for (let e in emitted)
	check(join(",", sort(keys(e.labels))) == "service,service_instance",
	      `unexpected labels on ${e.name}: ${keys(e.labels)}`);

// nothing for a service without instances
for (let e in emitted)
	check(e.labels.service != "firewall", "no samples for instance-less service");

check(length(emitted) == 13, "expected 13 samples, got " + length(emitted));

// ubus failure
check(load({ call: function() { return null; } }) == false, "returns false when ubus fails");
check(length(emitted) == 0, "no samples when ubus fails");

if (failures) {
	warn(failures, " check(s) failed\n");
	exit(1);
}
