const x = ubus.call("dsl", "metrics");

if (!x)
	return false;

gauge("dsl_info")({
	atuc_vendor:		x.atu_c.vendor,
	atuc_system_vendor:	x.atu_c.system_vendor,
	chipset:		x.chipset,
	firmware_version:	x.firmware_version,
	api_version:		x.api_version,
	driver_version:		x.driver_version,
}, 1);

gauge("dsl_line_info")({
	annex:		x.annex,
	standard:	x.standard,
	mode:		x.mode,
	profile:	x.profile,
}, 1);

gauge("dsl_up")({ detail: x.state }, x.up);
gauge("dsl_uptime_seconds")(null, x.uptime);

gauge("dsl_line_attenuation_db")
	({ direction: "down" }, x.downstream.latn)
	({ direction: "up" }, x.upstream.latn);
gauge("dsl_signal_attenuation_db")
	({ direction: "down" }, x.downstream.satn)
	({ direction: "up" }, x.upstream.satn);
gauge("dsl_signal_to_noise_margin_db")
	({ direction: "down" }, x.downstream.snr)
	({ direction: "up" }, x.upstream.snr);
gauge("dsl_aggregated_transmit_power_db")
	({ direction: "down" }, x.downstream.actatp)
	({ direction: "up" }, x.upstream.actatp);

if (x.downstream.interleave_delay)
	gauge("dsl_latency_seconds")
		({ direction: "down" }, x.downstream.interleave_delay / 1000000.0)
		({ direction: "up" }, x.upstream.interleave_delay / 1000000.0);
gauge("dsl_datarate")
	({ direction: "down" }, x.downstream.data_rate)
	({ direction: "up" }, x.upstream.data_rate);
gauge("dsl_max_datarate")
	({ direction: "down" }, x.downstream.attndr)
	({ direction: "up" }, x.upstream.attndr);

counter("dsl_error_seconds_total")
	({ err: "forward error correction", loc: "near" }, x.errors.near.fecs)
	({ err: "forward error correction", loc: "far" }, x.errors.far.fecs)
	({ err: "errored", loc: "near" }, x.errors.near.es)
	({ err: "errored", loc: "far" }, x.errors.far.es)
	({ err: "severely errored", loc: "near" }, x.errors.near.ses)
	({ err: "severely errored", loc: "far" }, x.errors.far.ses)
	({ err: "loss of signal", loc: "near" }, x.errors.near.loss)
	({ err: "loss of signal", loc: "far" }, x.errors.far.loss)
	({ err: "unavailable", loc: "near" }, x.errors.near.uas)
	({ err: "unavailable", loc: "far" }, x.errors.far.uas);

counter("dsl_errors_total")
	({ err: "header error code error", loc: "near" }, x.errors.near.hec)
	({ err: "header error code error", loc: "far" }, x.errors.far.hec)
	({ err: "non pre-emptive crc error", loc: "near" }, x.errors.near.crc_p)
	({ err: "non pre-emptive crc error", loc: "far" }, x.errors.far.crc_p)
	({ err: "pre-emptive crc error", loc: "near" }, x.errors.near.crcp_p)
	({ err: "pre-emptive crc error", loc: "far" }, x.errors.far.crcp_p);

if (x.erb)
	counter("dsl_erb_total")
		({ counter: "sent" }, x.erb.sent)
		({ counter: "discarded" }, x.erb.discarded);
