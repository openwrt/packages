import * as log from "log";

const api_url = config["api_url"];
if (!api_url)
	return false;

let m_up = gauge("go2rtc_up");
let m_producer_info = gauge("go2rtc_producer_info");
let m_consumer_info = gauge("go2rtc_consumer_info");
let m_producer_rx = counter("go2rtc_producer_received_bytes_total");
let m_consumer_tx = counter("go2rtc_consumer_sent_bytes_total");


function get_streams_info(api_url) {

	const url = `${api_url}/api/streams`;

	// NOTE: ucode-mod-uclient not so easy to use, also it brings problems with ujail library mount.
	let ret = ubus.call("file", "exec", {command: "uclient-fetch", params: ["-T", "5", "-O", "-", url]});
	if (ret?.code != 0) {
		log.ERR("failed to fetch url: %s rc: %d: err: %s", url, ret?.code, ret?.stderr);
		return null;
	}

	return json(ret.stdout);
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
