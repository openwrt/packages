const poe_info = ubus.call("poe", "info");

if (!poe_info)
	return false;

// possible poe modes for a port
//   realtek-poe/src/main.c
//   static int poe_reply_port_ext_config()
const POE_MODES = [
	"PoE",
	"Legacy",
	"pre-PoE+",
	"PoE+",
];

// possible poe states for a port
//   realtek-poe/src/main.c
//   static int poe_reply_4_port_status()
const POE_STATES = [
	"Disabled",
	"Searching",
	"Delivering power",
	"Fault",
	"Other fault",
	"Requesting power",
];


// start main scraping function:


// helper vars
const mcu         = poe_info["mcu"];
const ports       = poe_info["ports"];
const budget      = poe_info["budget"];
const firmware    = poe_info["firmware"];
const consumption = poe_info["consumption"];

// push info, budget and consumption metric
gauge(`realtek_poe_switch_info`)({ mcu: mcu, firmware: firmware }, 1);
gauge(`realtek_poe_switch_budget_watts`)(null, budget);
gauge(`realtek_poe_switch_consumption_watts`)(null, consumption);

// push per port priority metrics
const priority_metric = gauge(`realtek_poe_port_priority`);
for (port, values in ports) {
	priority_metric({ device: port }, values["priority"]);
}

// push per port consumption metrics
const consumption_metric = gauge(`realtek_poe_port_consumption_watts`);
for (port, values in ports) {
	consumption_metric({ device: port }, (values["consumption"] || 0));
}

// push per port state metrics
const state_metric = gauge(`realtek_poe_port_state`);
for (let state in POE_STATES) {
	for (port, values in ports) {
		state_metric({ device: port, state: state }, (values["status"] == state) ? 1 : 0);
	}
}

// push per port mode metrics
const mode_metric = gauge(`realtek_poe_port_mode`);
for (let mode in POE_MODES) {
	for (port, values in ports) {
		mode_metric({ device: port, mode: mode }, (values["mode"] == mode) ? 1 : 0);
	}
}


