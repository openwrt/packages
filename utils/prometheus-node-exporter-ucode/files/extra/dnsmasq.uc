const x = ubus.call("dnsmasq", "metrics");
if (!x)
	return false;

for (let i in x)
	gauge(`dnsmasq_${i}_total`)(null, x[i]);
