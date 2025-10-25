#!/usr/bin/lua

--[[
Mini-MWAN Daemon
Manages multi-WAN failover and load balancing
]]--

local uci = require("uci")
local nixio = require("nixio")
local fs = require("nixio.fs")
local json = require("cjson")

-- Configuration
local cursor = uci.cursor()
local LOG_FILE = "/var/log/mini-mwan.log"
local STATUS_FILE = "/var/run/mini-mwan.status"

-- Persistent interface state (survives config reloads)
local interface_state = {}

-- Logging function
local function log(msg)
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local log_msg = string.format("[%s] %s\n", timestamp, msg)

	-- Write to log file
	local f = io.open(LOG_FILE, "a")
	if f then
		f:write(log_msg)
		f:close()
	end

	-- Also write to syslog
	os.execute(string.format("logger -t mini-mwan '%s'", msg))
end

-- Execute command and capture output
local function exec(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return nil, "Failed to execute command"
	end

	local output = handle:read("*a")
	handle:close()
	return output
end

-- Ping check function through specific interface
local function check_ping(target, count, timeout, device, gateway)
	count = count or 3
	timeout = timeout or 2

	-- Ping through specific interface using source routing
	-- Use -I to specify interface
	local cmd = string.format("ping -I %s -c %d -W %d %s 2>&1", device, count, timeout, target)
	local output = exec(cmd)

	if not output then
		return false, 0
	end

	-- Parse ping statistics
	local received = output:match("(%d+) packets received")
	if received and tonumber(received) > 0 then
		-- Parse average latency
		local avg_latency = output:match("min/avg/max[^=]+=.-/(.-)/")
		return true, tonumber(avg_latency) or 0
	end

	return false, 0
end

-- Check if interface exists and is UP
local function check_interface_up(iface)
	local cmd = string.format("ip addr show dev %s 2>/dev/null", iface)
	local output = exec(cmd)

	if not output or output:match("does not exist") then
		return false, "not_exist"
	end

	-- Check if interface has UP flag
	-- Example: "3: wan: <BROADCAST,MULTICAST,UP,LOWER_UP>"
	if output:match("<[^>]*UP[^>]*>") then
		return true, "up"
	end

	return false, "down"
end

-- Get network statistics for interface (TX/RX bytes)
local function get_interface_stats(device)
	if not device or device == "" then
		return "0", "0"
	end

	local rx_path = string.format("/sys/class/net/%s/statistics/rx_bytes", device)
	local tx_path = string.format("/sys/class/net/%s/statistics/tx_bytes", device)

	local rx_bytes = "0"
	local tx_bytes = "0"

	-- Read RX bytes
	local rx_file = io.open(rx_path, "r")
	if rx_file then
		local content = rx_file:read("*l")  -- Read one line, automatically strips newline
		rx_file:close()
		if content and content ~= "" then
			rx_bytes = content
		end
	end

	-- Read TX bytes
	local tx_file = io.open(tx_path, "r")
	if tx_file then
		local content = tx_file:read("*l")  -- Read one line, automatically strips newline
		tx_file:close()
		if content and content ~= "" then
			tx_bytes = content
		end
	end

	return rx_bytes, tx_bytes
end

-- Get gateway for interface using ifstatus (netifd)
local function get_gateway(iface)
	local cmd = string.format("ifstatus %s 2>/dev/null", iface)
	local output = exec(cmd)

	if not output or output == "" then
		return nil
	end

	-- Parse JSON using cjson
	local success, data = pcall(json.decode, output)
	if not success or not data then
		log(string.format("Failed to parse ifstatus JSON for %s", iface))
		return nil
	end

	-- Look for default route (target 0.0.0.0, mask 0)
	if data.route then
		for _, route in ipairs(data.route) do
			if route.target == "0.0.0.0" and route.mask == 0 and route.nexthop then
				return route.nexthop
			end
		end
	end

	-- No gateway found - might be a point-to-point interface (VPN tunnel)
	return nil
end

-- Add/update default route with fallback
-- Always keeps a high-metric (999) route for ping checks even when interface is "down"
local function set_route(gateway, metric, iface, keep_fallback)
	-- Remove existing default route for this interface first
	if gateway and gateway ~= "" then
		exec(string.format("ip route del default via %s dev %s 2>/dev/null", gateway, iface))
	else
		exec(string.format("ip route del default dev %s 2>/dev/null", iface))
	end

	-- Add new default route with metric
	local cmd
	if gateway and gateway ~= "" then
		-- Regular interface with gateway (e.g., ethernet)
		cmd = string.format("ip route add default via %s dev %s metric %d", gateway, iface, metric)
	else
		-- Point-to-point interface without gateway (e.g., VPN tunnel)
		cmd = string.format("ip route add default dev %s metric %d", iface, metric)
	end

	local result = exec(cmd)
	log(string.format("Set route: gw=%s iface=%s metric=%d", gateway or "none", iface, metric))

	-- Always add high-metric fallback route for ping checks
	if keep_fallback then
		local fallback_cmd
		if gateway and gateway ~= "" then
			fallback_cmd = string.format("ip route add default via %s dev %s metric 999 2>/dev/null", gateway, iface)
		else
			fallback_cmd = string.format("ip route add default dev %s metric 999 2>/dev/null", iface)
		end
		exec(fallback_cmd)
	end

	return true
end

-- Ensure fallback route exists for ping checks
local function ensure_fallback_route(gateway, iface)
	-- Check if route already exists
	local check_cmd
	if gateway and gateway ~= "" then
		check_cmd = string.format("ip route show | grep -q 'default via %s dev %s metric 999'", gateway, iface)
	else
		check_cmd = string.format("ip route show | grep -q 'default dev %s.*metric 999'", iface)
	end

	local result = os.execute(check_cmd)
	if result == 0 then
		-- Route already exists
		return
	end

	-- Add fallback route
	local cmd
	if gateway and gateway ~= "" then
		cmd = string.format("ip route add default via %s dev %s metric 999", gateway, iface)
	else
		cmd = string.format("ip route add default dev %s metric 999", iface)
	end

	exec(cmd)
	log(string.format("Added fallback route: gw=%s iface=%s metric=999", gateway or "none", iface))
end

-- Remove default route
local function remove_route(gateway, iface)
	local cmd
	if gateway and gateway ~= "" then
		cmd = string.format("ip route del default via %s dev %s 2>/dev/null", gateway, iface)
	else
		cmd = string.format("ip route del default dev %s 2>/dev/null", iface)
	end
	exec(cmd)
	log(string.format("Removed route: gw=%s iface=%s", gateway or "none", iface))
end

-- Load configuration
local function load_config()
	cursor:load("mini-mwan")

	local config = {
		enabled = cursor:get("mini-mwan", "settings", "enabled") == "1",
		mode = cursor:get("mini-mwan", "settings", "mode") or "failover",
		check_interval = tonumber(cursor:get("mini-mwan", "settings", "check_interval")) or 30,
		interfaces = {}
	}

	-- Load all interface configurations dynamically
	cursor:foreach("mini-mwan", "interface", function(section)
		local name = section['.name']

		-- Restore persistent state if it exists
		local saved_state = interface_state[name] or {}

		local iface = {
			name = name,
			enabled = section.enabled == "1",
			device = section.device,
			metric = tonumber(section.metric) or 10,
			weight = tonumber(section.weight) or 3,
			ping_target = section.ping_target,
			ping_count = tonumber(section.ping_count) or 3,
			ping_timeout = tonumber(section.ping_timeout) or 2,
			status = saved_state.status or "unknown",
			status_since = saved_state.status_since,
			latency = saved_state.latency or 0,
			gateway = nil,
			last_check = saved_state.last_check
		}

		if iface.device and iface.device ~= "" then
			iface.gateway = get_gateway(iface.device)
		end

		table.insert(config.interfaces, iface)
	end)

	return config
end

-- Write status file
local function write_status(config)
	local f = io.open(STATUS_FILE, "w")
	if f then
		f:write(string.format("mode=%s\n", config.mode))
		f:write(string.format("timestamp=%d\n", os.time()))
		f:write(string.format("check_interval=%d\n", config.check_interval))

		for _, iface in ipairs(config.interfaces) do
			-- Get current network statistics
			local rx_bytes, tx_bytes = get_interface_stats(iface.device)

			f:write(string.format("\n[%s]\n", iface.name))
			f:write(string.format("device=%s\n", iface.device or ""))
			f:write(string.format("status=%s\n", iface.status))
			f:write(string.format("status_since=%s\n", iface.status_since or ""))
			f:write(string.format("last_check=%s\n", iface.last_check or ""))
			f:write(string.format("latency=%.2f\n", iface.latency))
			f:write(string.format("gateway=%s\n", iface.gateway or ""))
			f:write(string.format("ping_target=%s\n", iface.ping_target or ""))
			f:write(string.format("rx_bytes=%s\n", rx_bytes))
			f:write(string.format("tx_bytes=%s\n", tx_bytes))
		end
		f:close()
	end
end

-- Update interface status with timestamp tracking
local function update_interface_status(iface)
	if not (iface.enabled and iface.device and iface.ping_target) then
		local new_status = "disabled"
		iface.last_check = os.time()

		if iface.status ~= new_status then
			iface.status_since = os.time()
		end
		iface.status = new_status

		-- Save state
		interface_state[iface.name] = {
			status = iface.status,
			status_since = iface.status_since,
			latency = 0,
			last_check = iface.last_check
		}
		return
	end

	-- Check if interface exists and is UP
	local if_up, if_state = check_interface_up(iface.device)
	if not if_up then
		local new_status = if_state == "not_exist" and "interface_down" or "interface_down"
		iface.last_check = os.time()

		-- Track status changes
		if iface.status ~= new_status then
			iface.status_since = os.time()
			log(string.format("%s (%s): Status changed from %s to %s (interface %s)",
				iface.name, iface.device, iface.status or "unknown", new_status, if_state))
		end

		iface.status = new_status
		iface.latency = 0

		-- Save state
		interface_state[iface.name] = {
			status = iface.status,
			status_since = iface.status_since,
			latency = iface.latency,
			last_check = iface.last_check
		}
		return
	end

	-- Interface is UP, now ping through it to check connectivity
	-- Note: gateway can be nil for point-to-point interfaces (e.g., VPN tunnels)
	local alive, latency = check_ping(iface.ping_target, iface.ping_count, iface.ping_timeout, iface.device, iface.gateway)
	local new_status = alive and "up" or "down"
	iface.last_check = os.time()

	-- Track status changes
	if iface.status ~= new_status then
		iface.status_since = os.time()
		log(string.format("%s (%s): Status changed from %s to %s",
			iface.name, iface.device, iface.status or "unknown", new_status))
	end

	iface.status = new_status
	iface.latency = latency

	-- Save state for next config reload
	interface_state[iface.name] = {
		status = iface.status,
		status_since = iface.status_since,
		latency = iface.latency,
		last_check = iface.last_check
	}

	log(string.format("%s (%s): %s (latency: %.2fms, ping via %s to %s)",
		iface.name, iface.device, iface.status, latency, iface.device, iface.ping_target))
end

-- Failover mode logic
local function handle_failover(config)
	-- Check all interfaces
	for _, iface in ipairs(config.interfaces) do
		update_interface_status(iface)
	end

	-- Separate interfaces into up and down
	local sorted_ifaces = {}
	local down_ifaces = {}
	for _, iface in ipairs(config.interfaces) do
		if iface.status == "up" then
			table.insert(sorted_ifaces, iface)
		elseif iface.enabled and iface.device and iface.status ~= "interface_down" then
			table.insert(down_ifaces, iface)
		end
	end
	table.sort(sorted_ifaces, function(a, b) return a.metric < b.metric end)

	-- For down interfaces: set very high metric (900) so they don't interfere but pings still work
	for _, iface in ipairs(down_ifaces) do
		-- Remove any existing routes for this interface
		if iface.gateway and iface.gateway ~= "" then
			exec(string.format("ip route del default via %s dev %s 2>/dev/null", iface.gateway, iface.device))
		else
			exec(string.format("ip route del default dev %s 2>/dev/null", iface.device))
		end

		-- Add high-metric route for ping checks (900 = still allows pings but won't be used for traffic)
		if iface.gateway and iface.gateway ~= "" then
			exec(string.format("ip route add default via %s dev %s metric 900 2>/dev/null", iface.gateway, iface.device))
		else
			exec(string.format("ip route add default dev %s metric 900 2>/dev/null", iface.device))
		end
		log(string.format("Set high-metric route for down interface %s (%s) metric=900", iface.name, iface.device))
	end

	if #sorted_ifaces == 0 then
		log("WARNING: No WAN connections are available!")
		return
	end

	-- Use the highest priority (lowest metric) interface as primary
	local primary = sorted_ifaces[1]
	set_route(primary.gateway, primary.metric, primary.device)
	log(string.format("Using %s (%s) as primary with metric %d", primary.name, primary.device, primary.metric))

	-- Set backup routes with their original metrics
	for i = 2, #sorted_ifaces do
		local backup = sorted_ifaces[i]
		set_route(backup.gateway, backup.metric, backup.device)
		log(string.format("Setting %s (%s) as backup with metric %d", backup.name, backup.device, backup.metric))
	end
end

-- Multi-uplink mode logic with multipath routing
local function handle_multiuplink(config)
	-- Check all interfaces
	for _, iface in ipairs(config.interfaces) do
		update_interface_status(iface)
	end

	-- Separate active and down interfaces
	local active_ifaces = {}
	local down_ifaces = {}
	for _, iface in ipairs(config.interfaces) do
		if iface.status == "up" then
			table.insert(active_ifaces, iface)
		elseif iface.enabled and iface.device and iface.status ~= "interface_down" then
			table.insert(down_ifaces, iface)
		end
	end

	-- For down interfaces: set very high metric (900) so pings still work
	for _, iface in ipairs(down_ifaces) do
		-- Remove any existing routes for this interface
		if iface.gateway and iface.gateway ~= "" then
			exec(string.format("ip route del default via %s dev %s 2>/dev/null", iface.gateway, iface.device))
		else
			exec(string.format("ip route del default dev %s 2>/dev/null", iface.device))
		end

		-- Add high-metric route for ping checks
		if iface.gateway and iface.gateway ~= "" then
			exec(string.format("ip route add default via %s dev %s metric 900 2>/dev/null", iface.gateway, iface.device))
		else
			exec(string.format("ip route add default dev %s metric 900 2>/dev/null", iface.device))
		end
		log(string.format("Set high-metric route for down interface %s (%s) metric=900", iface.name, iface.device))
	end

	if #active_ifaces == 0 then
		log("WARNING: No active WAN connections!")
		return
	end

	-- Remove all existing default routes (except metric 900)
	exec("ip route show | grep '^default' | grep -v 'metric 900' | while read route; do ip route del $route 2>/dev/null; done")

	-- Build multipath route command
	-- ip route replace default nexthop via GW1 dev DEV1 weight W1 nexthop dev DEV2 weight W2
	local route_parts = {}
	for _, iface in ipairs(active_ifaces) do
		local nexthop
		if iface.gateway and iface.gateway ~= "" then
			nexthop = string.format("nexthop via %s dev %s weight %d", iface.gateway, iface.device, iface.weight)
		else
			nexthop = string.format("nexthop dev %s weight %d", iface.device, iface.weight)
		end
		table.insert(route_parts, nexthop)
		log(string.format("Multi-uplink: %s (%s) weight %d", iface.name, iface.device, iface.weight))
	end

	local multipath_cmd = "ip route replace default " .. table.concat(route_parts, " ")
	exec(multipath_cmd)
	log(string.format("Multipath route set: %s", multipath_cmd))
end

-- Main daemon loop
local function main()
	log("Mini-MWAN daemon starting")

	while true do
		local config = load_config()

		if config.enabled then
			-- Validate configuration
			local wan1_configured = config.interfaces[1] and config.interfaces[1].device and config.interfaces[1].device ~= ""
			local wan2_configured = config.interfaces[2] and config.interfaces[2].device and config.interfaces[2].device ~= ""

			if wan1_configured and wan2_configured then
				-- Run appropriate mode
				if config.mode == "failover" then
					handle_failover(config)
				elseif config.mode == "multiuplink" then
					handle_multiuplink(config)
				end

				-- Write status
				write_status(config)
			else
				log("ERROR: Both WAN interfaces must be configured")
			end
		else
			log("Service disabled, waiting...")
		end

		nixio.nanosleep(config.check_interval)
	end
end

-- Run daemon
-- Note: Signal handling is managed by procd, no custom handlers needed
main()
