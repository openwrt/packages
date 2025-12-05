const devs = ubus.call("network.device", "status");

if (!devs)
	return false;

for (let dev in devs) {
	const m = ubus.call(`odhcp6c.${dev}`, "get_statistics");

	// not all interfaces are exposed unless odhcp6c runs on it
	if (!m)
		continue;

	for (let i in m)
		gauge(`node_odhcp6c_${i}`, `Total DHCPv6 messages of type ${i}`)({ dev: dev }, m[i]);

}
