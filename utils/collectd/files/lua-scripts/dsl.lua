-- Copyright 2019 Florian Eckert <fe@dev.tdt.de>
-- Copyright 2021 Jeroen Peelaerts <jeroen@steganos.dev>
-- Licensed to the public under the GNU General Public License v2.

local ubus = require("ubus")

local hostname_file = "/proc/sys/kernel/hostname"

local line_vars = {
	{
		name = "vector",
		type = "bool"
	},
	{
		name = "trellis",
		type = "bool"
	},
	{
		name = "bitswap",
		type = "bool"
	},
	{  
		name = "retx",
		type = "bool"
	},
	{
		name = "satn",
		type = "gauge"
	},
	{
		name = "latn",
		type = "gauge"
	},
	{
		name = "attndr",
		type = "bitrate"
	},
	{
		name = "snr",
		type = "snr"
	},
	{
		name = "data_rate",
		type = "bitrate"
	},
	{
		name = "interleave_delay",
		type = "latency"
	}
}

local errors = {
	{
		name = "uas",
		type = "count"
	},
	{
		name = "rx_corrupted",
		type = "errors"
	},
	{
		name = "rx_uncorrected_protected",
		type = "errors"
	},
	{
		name = "rx_retransmitted",
		type = "errors"
	},
	{
		name = "rx_corrected",
		type = "errors"
	},
	{
		name = "tx_retransmitted",
		type = "errors"
	},
	{
		name = "crc_p",
		type = "errors"
	},
	{
		name = "crcp_p",
		type = "errors"
	}
}

local erb_vars = {
	{
		name = "sent",
		type = "gauge"
	},
	{
		name = "discarded",
		type = "gauge"
	}
}

local general_vars = {
	{
		name = "state_num",
		type = "gauge"
	},
	{
		name = "power_state_num",
		type = "gauge"
	},
	{
		name = "uptime",
		type = "uptime"
	}
}

local function build_metric(name, direction)
	if direction ~= '' then
		return string.format("%s_%s", name, direction)
	else
		return name 
	end
end

local function get_values(hostname, variables, metrics, direction)
	for _, information in pairs(variables) do
		local name = information["name"]
		local type = information["type"]

		if metrics and metrics[name] ~= nil then
			local value = metrics[name]

			local metric = build_metric(name, direction)
			if type == "bool" then
				if metrics[name] == true then
					value = 1
				else
					value = 0
				end
			end

			local t = {
				host = host,
				plugin = 'dsl',
				type = type,
				type_instance = metric,
				values = {value}
			}
			collectd.log_debug(string.format("%s: %s=%s", "collectd-mod-dsl(lua)", metric, tostring(value)))
			collectd.dispatch_values(t)
		else
			collectd.log_info(string.format("%s: Unable to get %s", "collectd-mod-dsl(lua)", name))
		end
	end
end

local function read()
	local lines = io.lines(hostname_file)
	local hostname = lines()

	local conn = ubus.connect()
	if not conn then
		collectd.log_error("collectd-mod-dsl(lua): Failed to connect to ubus")
		return 0
	end

	local metrics = conn:call("dsl", "metrics", {})

	if metrics then
		if metrics["up"] then
			local near_errors = metrics["errors"]["near"]
			local far_errors = metrics["errors"]["far"]
			local down_line = metrics["downstream"]
			local up_line = metrics["upstream"]
			local erb = metrics["erb"]

			get_values(hostname, errors, near_errors, "near")
			get_values(hostname, errors, far_errors, "far")
			get_values(hostname, line_vars, down_line, "down")
			get_values(hostname, line_vars, up_line, "up")
			get_values(hostname, erb_vars, erb, "")
		end
		get_values(hostname, general_vars, metrics, "")
		return 0
	end

	collectd.log_error("collectd-mod-dsl(lua): No ubus dsl object found")
	return 0
end

collectd.register_read(read)
