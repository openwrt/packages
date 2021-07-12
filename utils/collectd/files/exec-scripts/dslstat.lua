-- Copyright 2019 Florian Eckert <fe@dev.tdt.de>
-- Licensed to the public under the GNU General Public License v2.

local ubus = require("ubus")
local fs = require("nixio.fs")

local hostname_file = "/proc/sys/kernel/hostname"

local line_vars = {
	{
		name = "vector",
		type = "bool",
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
		type = "bool",
	},
	{
		name = "satn",
		type = "snr"
	},
	{
		name = "latn",
		type = "snr"
	},
	{
		name = "attndr",
		type = "bitrate"
	},
	{
		name = "snr",
		type = "snr",
	},
	{
		name = "data_rate",
		type = "bitrate"
	},
	{
		name = "latn",
		type = "latency"
	}
}

local errors = {
	{
		name = "uas",
		type = "gauge"
	},
	{
		name = "rx_corrupted",
		type = "gauge",
	},
	{
		name = "rx_retransmitted",
		type = "gauge",
	},
	{
		name = "tx_retransmitted",
		type = "gauge",
	}
}


local general_vars = {

	{
		name = "profile",
		type = "gauge"
	},
	{
		name = "mode",
		type = "gauge",
	},
	{
		name = "state",
		type = "gauge"
	},
	{
		name = "power_state",
		type = "gauge"
	},
	{
		name = "uptime",
		type = "uptime"
	}
}

local function build_metric(value, direction)
	if direction ~= '' then
		return string.format("%s_%s", value, direction)
	else
		return value
	end
end

local function get_values(hostname, variables, status, direction)
	for _, info in pairs(variables) do
		local value = info["name"]
		if status and status[value] ~= nil then
			local metric = build_metric(value, direction)

			local t = {
				host = host,
				plugin = 'dsl',
				type = info["type"],
				type_instance = metric,
				values = {status[value]}
			}
			collectd.log_info(string.format("%s: %s", metric, tostring(status[value])))
			collectd.dispatch_values(t)
		else
			collectd.log_warning(string.format("Unable to get %s",value))
		end
	end
end

local function read()
	local hostname = fs.readfile(hostname_file)
	local host = hostname:sub(1, -2)

	local conn = ubus.connect()
	if not conn then
		collectd.log_error("Failed to connect to ubus")
		return 0
	end

	local status = conn:call("dsl", "metrics", {})
	
	if status["up"] then
		local near_errors = status["errors"]["near"]
		local far_errors = status["errors"]["far"]
		local down_line = status["downstream"]
		local up_line = status["upstream"]

		get_values(host, errors, near_errors, "near")
		get_values(host, errors, far_errors, "far")
		get_values(host, line_vars, down_line, "down")
		get_values(host, line_vars, up_line, "up")
	end
	get_values(host, general_vars, status, "")

	return 0
end

collectd.register_read(read)
