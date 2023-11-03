import { cursor } from "uci";

const uci = cursor();
uci.load("dhcp");

let m = gauge("dhcp_host_info");

uci.foreach('dhcp', `host`, (s) => {
	m({
		name: s.name,
		mac: s.mac,
		ip: s.ip,
	}, 1);
});
