let uloop = require("uloop");
let uclient = require("uclient");

const api_url = config["api_url"];
if (!api_url)
	return false;

let m_up = gauge("go2rtc_up");
let m_producer_info = gauge("go2rtc_producer_info");
let m_consumer_info = gauge("go2rtc_consumer_info");
let m_producer_rx = counter("go2rtc_producer_received_bytes_total");
let m_consumer_tx = counter("go2rtc_consumer_sent_bytes_total");


function get_streams_info(api_url) {
	let data = '';

	const url = `${api_url}/api/streams`;

	uloop.init();
	uc = uclient.new(url, null, {
		data_read: (cb) => {
			let chunk;
			while (length(chunk = uc.read()) > 0)
				data += chunk;
		},
		data_eof: (cb) => {
			uloop.end();
		},
		error: (cb, code) => {
			warn(`failed to get url: ${url}: ${code}\n`);
			data = null;
			uloop.end();
		}
	});

	if (!uc.set_timeout(5000)) {
		warn("failed to set timeout\n");
		return null;
	}

	if (!uc.ssl_init({verify: false})) {
		warn("failed to initialize SSL\n");
		return null;
	}

	if (!uc.connect()) {
		warn("failed to connect\n");
		return null;
	}

	if (!uc.request("GET", {headers: {"User-Agent": "prometheus-node-exporter-ucode/1.0"}})) {
		warn("failed to send request\n");
		return null;
	}

	uloop.run();

	if (data == null) {
		return null;
	}

	return json(data);
}

const x = get_streams_info(api_url);

if (!x) {
	m_up({url: api_url}, 0);
	return false;
}

m_up({url: api_url}, 1);

for (let stream, info in x) {

	for (let producer in info.producers) {
		m_producer_info({
			stream: stream,
			format_name: producer.format_name,
			protocol: producer.protocol,
			remote_addr: producer.remote_addr,
			user_agent: producer.user_agent,
		}, (!producer.remote_addr) ? 0 : 1);
		m_producer_rx({
			stream: stream,
			remote_addr: producer.remote_addr,
		}, producer.bytes_recv);
	}

	for (let consumer in info.consumers) {
		m_consumer_info({
			stream: stream,
			format_name: consumer.format_name,
			protocol: consumer.protocol,
			remote_addr: consumer.remote_addr,
			user_agent: consumer.user_agent,
		}, 1);
		m_consumer_tx({
			stream: stream,
			remote_addr: consumer.remote_addr,
		}, consumer.bytes_send);
	}

}
